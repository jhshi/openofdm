#!/usr/bin/env python

"""
Generate 802.11a/g/n Deinterleave LUT.

Output compensate for pucntureing.

"""

import argparse
import math
import decode
import os

"""
LUT ENTRY FORMAT


1 bit -- null_a
1 bit -- null_b
6 bit -- addra
6 bit -- addrb
3 bit -- bita
3 bit -- bitb
1 bit -- out_stb
1 bit -- done
-------------------
22 bits total


LUT FORMAT

+----------------+
|  BASE ADDR     |
|   32 ENTRY     |
+----------------+
|   6 MBPS       |
+----------------+
|   9 MBPS       |
+----------------+
 ....
+----------------+
|   MCS 0        |
+----------------+
 ...
+----------------+
|   MCS 7        |
+----------------+
|   PADDING      |
+----------------+
"""

RATE_BITS = {
    6: '1011',
    9: '1111',
    12: '1010',
    18: '1110',
    24: '1001',
    36: '1101',
    48: '1000',
    54: '1100',
}


RATES = [
    # (rate, mcs, ht)
    (6, 0, False),
    (9, 0, False),
    (12, 0, False),
    (18, 0, False),
    (24, 0, False),
    (36, 0, False),
    (48, 0, False),
    (54, 0, False),

    (0, 0, True),
    (0, 1, True),
    (0, 2, True),
    (0, 3, True),
    (0, 4, True),
    (0, 5, True),
    (0, 6, True),
    (0, 7, True),
]


def do_rate(rate=6, mcs=0, ht=False):
    idx_map = decode.Decoder(None).deinterleave(None, rate=rate, mcs=mcs, ht=ht)
    seq = [t[1] for t in idx_map]

    erase = '1/2'

    if ht:
        n_bpsc = decode.HT_MCS_PARAMETERS[mcs][0]
        if mcs in [2, 4, 6]:
            erase = '3/4'
            pass
        elif mcs == 5:
            erase = '2/3'
            pass
        elif mcs == 7:
            erase = '5/6'
    else:
        n_bpsc = decode.RATE_PARAMETERS[rate][0]
        if rate in [9, 18, 36, 54]:
            erase = '3/4'
        elif rate == 48:
            erase = '2/3'

    data = []

    i = 0
    puncture = 0
    while i < len(seq):
        addra = seq[i]/n_bpsc
        bita = seq[i]%n_bpsc
        if i+1 < len(seq):
            addrb = seq[i+1]/n_bpsc
            bitb = seq[i+1]%n_bpsc
        else:
            addrb = 0
            bitb = 0

        base = (addra<<14) + (addrb<<8) + (bita<<5) + (bitb<<2) + (1<<1)

        if erase == '1/2':
            mask = base
            data.append(mask)
        elif erase == '3/4':
            if puncture == 0:
                mask = base
                data.append(mask)
                puncture = 1
            else:
                mask = (1<<20) + base
                data.append(mask)
                mask = (1<<21) + base
                data.append(mask)
                puncture = 0
        elif erase == '2/3':
            if puncture == 0:
                mask = base
                data.append(mask)
                puncture = 1
            else:
                mask = (1<<20) + base
                data.append(mask)
                i -= 1
                puncture = 0
        elif erase == '5/6':
            if puncture == 0:
                mask = base
                data.append(mask)
                puncture = 1
            elif puncture == 1:
                mask = (1<<20) + base
                data.append(mask)
                mask = (1<<21) + base
                data.append(mask)
                puncture = 2
            else:
                mask = (1<<20) + base
                data.append(mask)
                mask = (1<<21) + base
                data.append(mask)
                puncture = 0
        i += 2

    # reset addra to NUM_SUBCARRIER/2
    if ht:
        mask = (26<<14) + 1
    else:
        mask = (24<<14) + 1
    data.append(mask)

    # sentinel
    data.extend([0]*4)

    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out')
    args = parser.parse_args()

    if args.out is None:
        args.out = os.path.join(os.getcwd(), 'deinter_lut.mif')

    coe_out = '%s.coe' % (os.path.splitext(args.out)[0])

    header = [0]*32
    lut = []
    offset = 32
    for rate, mcs, ht in RATES:
        if ht:
            idx = (1<<4) + mcs
        else:
            idx = int(RATE_BITS[rate], 2)
        header[idx] = offset
        print '[rate=%d, mcs=%d] -> %d' % (rate, mcs, offset)

        data = do_rate(rate=rate, mcs=mcs, ht=ht)
        offset += len(data)
        lut.extend(data)

    total = int(2**math.ceil(math.log(offset, 2)))
    print 'Total row: %d (round up to %d)' % (offset, total)

    lut.extend([0]*(total-offset))

    with open(args.out, 'w') as f:
        for l in header + lut:
            f.write('{0:022b}\n'.format(l))
    print "MIL file saved as %s" % (args.out)

    with open(coe_out, 'w') as f:
        f.write('memory_initialization_radix=2;\n')
        f.write('memory_initialization_vector=\n')
        f.write(',\n'.join(['{0:022b}'.format(l) for l in header+lut]))
        f.write(';')
    print "COE file saved as %s" % (coe_out)

if __name__ == '__main__':
    main()
