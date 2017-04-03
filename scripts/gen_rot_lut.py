#!/usr/bin/env python

"""
Generate the rotation vector LUT.

Key = phase -- phase \in [0, math.pi/4)
Value = SCALE*(math.cos(phase), math.sin(phase))
"""

import argparse
import math
import os

ATAN_LUT_SCALE = 512
SCALE = 2048


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out')
    args = parser.parse_args()

    if args.out is None:
        args.out = os.path.join(os.getcwd(), 'rot_lut.mif')
    coe_out = '%s.coe' % (os.path.splitext(args.out)[0])

    MAX = int(round(math.pi/4*ATAN_LUT_SCALE))
    SIZE = int(2**math.ceil(math.log(MAX, 2)))

    data = []
    with open(args.out, 'w') as f:
        for i in range(SIZE):
            key = float(i)/MAX*math.pi/4
            I = int(round(math.cos(key)*SCALE))
            Q = int(round(math.sin(key)*SCALE))
            print '%f -> %d -> (%d, %d)' % (key, i, I, Q)
            val = (I<<16) + Q
            data.append(val)
            f.write('{0:032b}\n'.format(val))

    print "SIZE = %d, scale = %d" % (SIZE, SCALE)
    print "MIL file saved as %s" % (args.out)

    with open(coe_out, 'w') as f:
        f.write('memory_initialization_radix=2;\n')
        f.write('memory_initialization_vector=\n')
        f.write(',\n'.join(['{0:032b}'.format(l) for l in data]))
        f.write(';')
    print "COE file saved as %s" % (coe_out)

if __name__ == '__main__':
    main()
