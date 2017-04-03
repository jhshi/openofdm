#!/usr/bin/env python

import os
import argparse
import scipy
import subprocess

import decode

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SIM_OUT_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), 'sim_out')


def test():
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help="Sample file to test.")
    parser.add_argument('--no_sim', action='store_true', default=False)
    parser.add_argument('--stop', type=int)
    args = parser.parse_args()

    with open(args.file, 'rb') as f:
        samples = scipy.fromfile(f, dtype=scipy.int16)
    samples = [complex(i, q) for i, q in zip(samples[::2], samples[1::2])]
    print "Using file %s (%d samples)" % (args.file, len(samples))

    memory_file = '%s.txt' % (os.path.splitext(args.file)[0])
    if not os.path.isfile(memory_file) or\
            os.path.getmtime(memory_file) < os.path.getmtime(args.file):
        subprocess.check_call('python %s/bin_to_mem.py %s --out %s' %\
                              (SCRIPT_DIR, args.file, memory_file), shell=True)

    if not args.no_sim:
        if args.stop is None:
            stop = len(samples)
        else:
            stop = min(args.stop, len(samples))
        print "Stop after %d samples" % (stop)

        try:
            subprocess.check_call('rm -rfv %s/*' % (SIM_OUT_DIR), shell=True)
        except:
            pass

        try:
            subprocess.check_call(
                'iverilog -DDEBUG_PRINT -DSAMPLE_FILE="\\"%s\\"" -DNUM_SAMPLE=%d -c dot11_modules.list dot11_tb.v'
                % (memory_file, stop), shell=True)
            subprocess.check_call('vvp -n a.out', shell=True)
        except KeyboardInterrupt:
            try:
                subprocess.check_call('pgrep -f "vvp" | xargs kill -9', shell=True)
            except:
                pass
            return

    with open('%s/signal_out.txt' % (SIM_OUT_DIR), 'r') as f:
        signal_out = [c[::-1] for c in f.read().strip().split()]

    deinterleave_out = []
    with open('%s/deinterleave_out.txt' % (SIM_OUT_DIR), 'r') as f:
        deinterleave_out = f.read().replace('\n', '')

    with open('%s/descramble_out.txt' % (SIM_OUT_DIR), 'r') as f:
        descramble_out = f.read().replace('\n', '')

    print "Decoding..."
    expected_signal, cons, expected_demod_out, expected_deinterleave_out,\
        expected_conv_out, expected_descramble_out, expected_byte_out, pkt =\
        decode.Decoder(args.file, skip=0).decode_next()

    if not expected_signal.ht:
        signal_error = False
        for idx, attr in enumerate(['rate_bits', 'rsvd', 'len_bits',
                                'parity_bits', 'tail_bits']):
            if getattr(expected_signal, attr) == signal_out[idx]:
                print "Signal.%s works" % (attr)
            else:
                print "Wrong Signal.%s: expect %s, got %s" %\
                    (attr, getattr(expected_signal, attr), signal_out[idx])
                signal_error = True

        if signal_error:
            return
        else:
            print "== DECODE SIGNAL WORKS =="

    if expected_signal.ht:
        n_bpsc, n_cbps, n_dbps = decode.HT_MCS_PARAMETERS[expected_signal.mcs]
    else:
        n_bpsc, n_cbps, n_dbps = decode.RATE_PARAMETERS[expected_signal.rate]

    # swap pos/neg sub carriers
    expected_demod_out = ''.join([str(b) for b in expected_demod_out])
    temp = []
    for i in range(0, len(expected_demod_out), n_cbps):
        temp.extend(expected_demod_out[i+n_cbps/2:i+n_cbps])
        temp.extend(expected_demod_out[i:i+n_cbps/2])
    expected_demod_out = ''.join(temp)

    expected_deinterleave_out = ''.join([str(b) for b in expected_deinterleave_out])
    expected_conv_out = ''.join([str(b) for b in expected_conv_out])
    expected_descramble_out = ''.join([str(b) for b in expected_descramble_out])

    with open('%s/conv_out.txt' % (SIM_OUT_DIR), 'r') as f:
        conv_out = f.read().replace('\n', '')

    demod_out = []
    with open('%s/demod_out.txt' % (SIM_OUT_DIR), 'r') as f:
        for line in f.readlines():
            demod_out.append(line.strip()[-n_bpsc:][::-1])
    demod_out = ''.join(demod_out)

    num_symbol = min(len(demod_out)/n_cbps, len(expected_demod_out)/n_cbps)
    print "%d OFDM symbols" % (num_symbol)

    print "Checking DEMOD.."
    error = False
    for idx in range(num_symbol):
        expected = expected_demod_out[idx*n_cbps:(idx+1)*n_cbps]
        got = demod_out[idx*n_cbps:(idx+1)*n_cbps]
        print "%10s: %s" % ("Expected", expected)
        print "%10s: %s" % ("Got", got)
        if expected != got:
            print "Demod error at SYM %d, diff: %d" %\
                (idx, len([i for i in range(len(got)) if expected[i] != got[i]]))
            error = True

    if not error:
        print "DEMOD works!"

    print "Checking DEINTER..."
    error = False
    for idx in range(num_symbol):
        expected = expected_deinterleave_out[idx*n_cbps:(idx+1)*n_cbps]
        got = deinterleave_out[idx*n_cbps:(idx+1)*n_cbps]
        print "%10s: %s" % ("Expected", expected)
        print "%10s: %s" % ("Got", got)
        if expected != got:
            print "Deinter error at SYM %d, diff: %d" %\
                (idx, len([i for i in range(len(got)) if expected[i] != got[i]]))
            error = True

    if not error:
        print "DEINTER works!"

    print "Checking CONV..."
    error = False
    for idx in range(num_symbol):
        expected = expected_conv_out[idx*n_dbps:(idx+1)*n_dbps]
        got = conv_out[idx*n_dbps:(idx+1)*n_dbps]
        print "%10s: %s" % ("Expected", expected)
        print "%10s: %s" % ("Got", got)
        if expected != got:
            print "Convolutional decoder error at symbol %d (diff %d)" %\
                (idx, len([i for i in range(len(got)) if expected[i] != got[i]]))
            error = True

    if not error:
        print "CONV works!"

    descramble_out = '0'*7 + descramble_out  # compensate for the first 7 bits
    print "Checking DESCRAMBLE..."
    error = False
    for idx in range(num_symbol):
        expected = expected_descramble_out[idx*n_dbps:(idx+1)*n_dbps]
        got = descramble_out[idx*n_dbps:(idx+1)*n_dbps]
        print "%10s: %s" % ("Expected", expected)
        print "%10s: %s" % ("Got", got)
        if expected != got:
            print "Descramble error at SYM %d, diff: %d" %\
                (idx, len([i for i in range(len(got)) if expected[i] != got[i]]))
            error = True

    if not error:
        print "DESCRAMBLE works!"

    with open('%s/byte_out.txt' % (SIM_OUT_DIR), 'r') as f:
        byte_out = [int(b, 16) for b in f.read().strip().split('\n')]

    print "Checking BYTE..."
    error = False
    for idx in range(min(len(byte_out), len(expected_byte_out))):
        expected = expected_byte_out[idx]
        got = byte_out[idx]
        print "%10s: %02x" % ("Expected", expected)
        print "%10s: %02x" % ("Got", got)
        if expected != got:
            print "BYTE error"
            error = True

    if not error:
        print "BYTE works!"

if __name__ == '__main__':
    test()
