#!/usr/bin/env python

"""
Generate atan Look Up Table (LUT)

Key = math.tan(phase)*SIZE -- phase \in [0, math.pi/4)
Value = int(math.atan(phase)*SIZE*2)

SIZE is LUT size. The value is scaled up by SIZE*2 so that adjacent LUT values
can be distinguished.
"""

SIZE = 2**8
SCALE = 512

import argparse
import math
import os


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out')
    args = parser.parse_args()

    if args.out is None:
        args.out = os.path.join(os.getcwd(), 'atan_lut.mif')
    coe_out = '%s.coe' % (os.path.splitext(args.out)[0])

    data = []
    with open(args.out, 'w') as f:
        for i in range(SIZE):
            key = float(i)/SIZE
            val = int(round(math.atan(key)*SCALE))
            data.append(val)
            print '%f -> %d' % (key, val)
            f.write('{0:09b}\n'.format(val))
    print "LUT SIZE %d, SCALE %d" % (SIZE, SCALE)
    print "MIL file saved as %s" % (args.out)

    with open(coe_out, 'w') as f:
        f.write('memory_initialization_radix=2;\n')
        f.write('memory_initialization_vector=\n')
        f.write(',\n'.join(['{0:09b}'.format(l) for l in data]))
        f.write(';')
    print "COE file saved as %s" % (coe_out)


if __name__ == '__main__':
    main()
