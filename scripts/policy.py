#!/usr/bin/env python


import os
import argparse
import jsonschema
import json
import itertools

MCS_MAX = 7
LENGTH_MAX = 4095

MAX_ACTION_LEN = 256

HEADER_LEN = 16

SR_RATE_FILTER = 7
SR_LEN_FILTER = 8
SR_HEADER_FILTER = 9
SR_HEADER_LEN =10
SR_JAM_POLICY = 11

POLICY_JSON_SCHEMA = """
{
    "title": "Jamming Policy Format Specification",
    "type": "array",
    "items": {
        "$ref": "#/definitions/policy"
    },
    "minItems": 1,
    "additionalProperties": false,
    "definitions": {
        "policy": {
            "type": "object",
            "properties": {
                "length": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 4095
                },
                "length_min": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 4095
                },
                "length_max": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 4095
                },

                "mcs": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 7
                },
                "mcs_min": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 7
                },
                "mcs_max": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 7
                },

                "header": {
                    "type": "string",
                    "maxLength": 47
                },
                "actions": {
                    "type": "array",
                    "minItems": 1,
                    "maxItems": 256,
                    "items": {
                        "type": "string",
                        "enum": ["Jam", "Pass", "JamAck"]
                    }
                }
            },
            "additionalProperties": false
        }
    },
    "$schema": "http://json-schema.org/draft-04/schema#"
}
"""


def arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help="JSON file that contains the policy")
    parser.add_argument('--out', help="Output file")
    return parser


def check_policy(args):
    for policy in args.policies:
        if 'length' in policy and ('length_min' in policy or
                                   'length_max' in policy):
            print "[ERROR] Policy can not contain both exact and range "\
                "quantifiers for length"
            return False

        if 'mcs' in policy and ('mcs_min' in policy or 'mcs_max' in policy):
            print "[ERROR] Policy can not contain both exact and range "\
                "quantifiers for mcs"
            return False

    return True


def make_canonical(args):
    for policy in args.policies:
        has_mcs = any([k.startswith('mcs') for k in policy])
        has_length = any([k.startswith('length') for k in policy])
        has_header = 'header' in policy

        if has_mcs:
            if 'mcs' in policy:
                policy['mcs_min'] = policy['mcs']
                policy['mcs_max'] = policy['mcs']
                del policy['mcs']

            if 'mcs_min' not in policy:
                policy['mcs_min'] = 0

            if 'mcs_max' not in policy:
                policy['mcs_max'] = MCS_MAX

            policy['mcs_weight'] = 3
            if has_length:
                policy['mcs_weight'] -= 1
            if has_header:
                policy['mcs_weight'] -= 1
        else:
            policy['mcs_min'] = MCS_MAX
            policy['mcs_max'] = 0
            policy['mcs_weight'] = 0

        if has_length:
            if 'length' in policy:
                policy['length_min'] = policy['length']
                policy['length_max'] = policy['length']
                del policy['length']

            if 'length_min' not in policy:
                policy['length_min'] = 0

            if 'length_max' not in policy:
                policy['length_max'] = LENGTH_MAX

            policy['length_weight'] = 3 - policy['mcs_weight']
            if has_header:
                policy['mcs_weight'] -= 1
        else:
            policy['length_min'] = LENGTH_MAX
            policy['length_max'] = 0
            policy['length_weight'] = 0

        if has_header:
            bytes = []
            for s in policy['header'].split():
                if s == 'xx':
                    bytes.append(0x1ff)
                else:
                    bytes.append(int(s, 16))
            policy['header'] = bytes
        else:
            policy['header'] = []

        iter = itertools.cycle(policy['actions'])
        for _ in range(MAX_ACTION_LEN-len(policy['actions'])):
            policy['actions'].append(iter.next())

    args.max_header_len = max([len(p['header']) for p in args.policies])
    for policy in args.policies:
        for _ in range(args.max_header_len - len(policy['header'])):
            policy['header'].append(0x1ff)

    cano_file = '_canonical'.join(os.path.splitext(args.file))
    with open(cano_file, 'w') as f:
        f.write(json.dumps(args.policies, indent=2))


def translate(args):
    rate_data = []
    len_data = []
    header_data = []
    action_data = []

    for id, policy in enumerate(args.policies):
        val = (id<<28) + (policy['mcs_min']<<6) + (policy['mcs_max']<<2) +\
            (policy['mcs_weight']&0x3)
        rate_data.append(val)

        val = (id<<28) + (policy['length_min']<<14) +\
            (policy['length_max']<<2) + (policy['length_weight']&0x3)
        len_data.append(val)

        for addr, b in enumerate(policy['header']):
            val = (id<<28) + (addr<<23) + (b&0x1ff)
            header_data.append(val)

        for addr, a in enumerate(policy['actions']):
            val = (id<<28) + (addr<<20)
            if a == 'Jam':
                val += 1
            elif a == 'Pass':
                val += 0
            elif a == 'JamAck':
                val += 2
            action_data.append(val)

    with open(args.out, 'w') as f:
        f.write('0x%x\n' % (SR_RATE_FILTER))
        f.write('0x%x\n' % (len(rate_data)))
        for d in rate_data:
            f.write('0x%08x\n' % (d))

        f.write('0x%x\n' % (SR_LEN_FILTER))
        f.write('0x%x\n' % (len(len_data)))
        for d in len_data:
            f.write('0x%08x\n' % (d))

        f.write('0x%x\n' % (SR_HEADER_FILTER))
        f.write('0x%x\n' % (len(header_data)))
        for d in header_data:
            f.write('0x%08x\n' % (d))

        f.write('0x%x\n' % (SR_HEADER_LEN))
        f.write('0x1\n')
        f.write('0x%x\n' % (args.max_header_len))

        f.write('0x%x\n' % (SR_JAM_POLICY))
        f.write('0x%x\n' % (len(action_data)))
        for d in action_data:
            f.write('0x%08x\n' % (d))

    print "Jam file written to %s" % (args.out)


def main():
    args = arg_parser().parse_args()

    if args.out is None:
        args.out = "%s.jam" % (os.path.splitext(args.file)[0])
        print "No output file specified, using %s" % (args.out)

    schema = json.loads(POLICY_JSON_SCHEMA)

    with open(args.file, 'r') as f:
        args.policies = json.loads(f.read())

    print "Validating policy ..."
    jsonschema.validate(args.policies, schema)

    if not check_policy(args):
        return

    print "Making canonical policy..."
    make_canonical(args)

    translate(args)

if __name__ == '__main__':
    main()
