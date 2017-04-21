#!/usr/bin/env python

import os
import numpy as np
import cmath
import collections
import itertools
import array
import math
from cStringIO import StringIO

import commpy.channelcoding.convcode as cc

from wltrace import dot11

LONG_PREAMBLE_TXT =\
    """
0 -0.078 0.000 40 0.098 -0.026 80 0.062 0.062 120 -0.035 -0.151
1 0.012 -0.098 41 0.053 0.004 81 0.119 0.004 121 -0.122 -0.017
2 0.092 -0.106 42 0.001 -0.115 82 -0.022 -0.161 122 -0.127 -0.021
3 -0.092 -0.115 43 -0.137 -0.047 83 0.059 0.015 123 0.075 -0.074
4 -0.003 -0.054 44 0.024 -0.059 84 0.024 0.059 124 -0.003 0.054
5 0.075 0.074 45 0.059 -0.015 85 -0.137 0.047 125 -0.092 0.115
6 -0.127 0.021 46 -0.022 0.161 86 0.001 0.115 126 0.092 0.106
7 -0.122 0.017 47 0.119 -0.004 87 0.053 -0.004 127 0.012 0.098
8 -0.035 0.151 48 0.062 -0.062 88 0.098 0.026 128 -0.156 0.000
9 -0.056 0.022 49 0.037 0.098 89 -0.038 0.106 129 0.012 -0.098
10 -0.060 -0.081 50 -0.057 0.039 90 -0.115 0.055 130 0.092 -0.106
11 0.070 -0.014 51 -0.131 0.065 91 0.060 0.088 131 -0.092 -0.115
12 0.082 -0.092 52 0.082 0.092 92 0.021 -0.028 132 -0.003 -0.054
13 -0.131 -0.065 53 0.070 0.014 93 0.097 -0.083 133 0.075 0.074
14 -0.057 -0.039 54 -0.060 0.081 94 0.040 0.111 134 -0.127 0.021
15 0.037 -0.098 55 -0.056 -0.022 95 -0.005 0.120 135 -0.122 0.017
16 0.062 0.062 56 -0.035 -0.151 96 0.156 0.000 136 -0.035 0.151
17 0.119 0.004 57 -0.122 -0.017 97 -0.005 -0.120 137 -0.056 0.022
18 -0.022 -0.161 58 -0.127 -0.021 98 0.040 -0.111 138 -0.060 -0.081
19 0.059 0.015 59 0.075 -0.074 99 0.097 0.083 139 0.070 -0.014
20 0.024 0.059 60 -0.003 0.054 100 0.021 0.028 140 0.082 -0.092
21 -0.137 0.047 61 -0.092 0.115 101 0.060 -0.088 141 -0.131 -0.065
22 0.001 0.115 62 0.092 0.106 102 -0.115 -0.055 142 -0.057 -0.039
23 0.053 -0.004 63 0.012 0.098 103 -0.038 -0.106 143 0.037 -0.098
24 0.098 0.026 64 -0.156 0.000 104 0.098 -0.026 144 0.062 0.062
25 -0.038 0.106 65 0.012 -0.098 105 0.053 0.004 145 0.119 0.004
26 -0.115 0.055 66 0.092 -0.106 106 0.001 -0.115 146 -0.022 -0.161
27 0.060 0.088 67 -0.092 -0.115 107 -0.137 -0.047 147 0.059 0.015
28 0.021 -0.028 68 -0.003 -0.054 108 0.024 -0.059 148 0.024 0.059
29 0.097 -0.083 69 0.075 0.074 109 0.059 -0.015 149 -0.137 0.047
30 0.040 0.111 70 -0.127 0.021 110 -0.022 0.161 150 0.001 0.115
31 -0.005 0.120 71 -0.122 0.017 111 0.119 -0.004 151 0.053 -0.004
32 0.156 0.000 72 -0.035 0.151 112 0.062 -0.062 152 0.098 0.026
33 -0.005 -0.120 73 -0.056 0.022 113 0.037 0.098 153 -0.038 0.106
34 0.040 -0.111 74 -0.060 -0.081 114 -0.057 0.039 154 -0.115 0.055
35 0.097 0.083 75 0.070 -0.014 115 -0.131 0.065 155 0.060 0.088
36 0.021 0.028 76 0.082 -0.092 116 0.082 0.092 156 0.021 -0.028
37 0.060 -0.088 77 -0.131 -0.065 117 0.070 0.014 157 0.097 -0.083
38 -0.115 -0.055 78 -0.057 -0.039 118 -0.060 0.081 158 0.040 0.111
39 -0.038 -0.106 79 0.037 -0.098 119 -0.056 -0.022 159 -0.005 0.120
"""

SHORT_PREAMBLE_TXT =\
    """
16 0.046 0.046 56 0.046 0.046 96 0.046 0.046 136 0.046 0.046
17 -0.132 0.002 57 0.002 -0.132 97 -0.132 0.002 137 0.002 -0.132
18 -0.013 -0.079 58 -0.079 -0.013 98 -0.013 -0.079 138 -0.079 -0.013
19 0.143 -0.013 59 -0.013 0.143 99 0.143 -0.013 139 -0.013 0.143
20 0.092 0.000 60 0.000 0.092 100 0.092 0.000 140 0.000 0.092
21 0.143 -0.013 61 -0.013 0.143 101 0.143 -0.013 141 -0.013 0.143
22 -0.013 -0.079 62 -0.079 -0.013 102 -0.013 -0.079 142 -0.079 -0.013
23 -0.132 0.002 63 0.002 -0.132 103 -0.132 0.002 143 0.002 -0.132
24 0.046 0.046 64 0.046 0.046 104 0.046 0.046 144 0.046 0.046
25 0.002 -0.132 65 -0.132 0.002 105 0.002 -0.132 145 -0.132 0.002
26 -0.079 -0.013 66 -0.013 -0.079 106 -0.079 -0.013 146 -0.013 -0.079
27 -0.013 0.143 67 0.143 -0.013 107 -0.013 0.143 147 0.143 -0.013
28 0.000 0.092 68 0.092 0.000 108 0.000 0.092 148 0.092 0.000
29 -0.013 0.143 69 0.143 -0.013 109 -0.013 0.143 149 0.143 -0.013
30 -0.079 -0.013 70 -0.013 -0.079 110 -0.079 -0.013 150 -0.013 -0.079
31 0.002 -0.132
"""

LONG_PREAMBLE = dict()
for idx, i, q in zip(*(iter(LONG_PREAMBLE_TXT.split()),)*3):
    LONG_PREAMBLE[int(idx)] = complex(float(i), float(q))
LONG_PREAMBLE = [LONG_PREAMBLE[i] for i in sorted(LONG_PREAMBLE.keys())]

SHORT_PREAMBLE = dict()
for idx, i, q in zip(*(iter(SHORT_PREAMBLE_TXT.split()),)*3):
    idx = int(idx)
    if idx >= 16 and idx <= 31:
        SHORT_PREAMBLE[idx-16] = complex(float(i), float(q))
SHORT_PREAMBLE = [SHORT_PREAMBLE[i] for i in sorted(SHORT_PREAMBLE.keys())]


# Table 78 - Rate-dependent parameters
RATE_PARAMETERS = {
    # rate : (n_bpsc, n_cbps, n_dbps),
    6: (1, 48, 24),
    9: (1, 48, 36),
    12: (2, 96, 48),
    18: (2, 96, 72),
    24: (4, 192, 96),
    36: (4, 192, 144),
    48: (6, 288, 192),
    54: (6, 288, 216),
}

HT_MCS_PARAMETERS = {
    0: (1, 52, 26),
    1: (2, 104, 52),
    2: (2, 104, 78),
    3: (4, 208, 104),
    4: (4, 208, 156),
    5: (6, 312, 208),
    6: (6, 312, 234),
    7: (6, 312, 260),
}

PILOT_SUBCARRIES = [-21, -7, 7, 21]

PHASE_SCALE = 256


# 802.11a/g
SUBCARRIERS = range(-26, 0) + range(1, 27)
FFT_MAPPING = dict((c, c if c > 0 else 64 + c) for c in SUBCARRIERS)
LTS_REF = dict(
    zip(SUBCARRIERS,
        [1,  1, -1, -1, 1,  1, -1,  1, -1,  1,  1,  1, 1,  1, 1, -1, -1,  1,  1,
         -1,  1, -1,  1,  1, 1, 1,  1, -1, -1,  1, 1, -1, 1, -1,  1, -1, -1, -1,
         -1, -1,  1,  1, -1, -1,  1, -1,  1, -1, 1,  1,  1,  1]))
polarity = [1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, 1, -1, 1, -1, -1, 1,
            1, -1, 1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, 1,
            1, 1, -1, 1, -1, -1, -1, 1, -1, 1, -1, -1, 1, -1, -1, 1, 1, 1, 1, 1,
            -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1, -1, -1, 1, 1, -1, -1,
            -1, -1, 1, -1, -1, 1, -1, 1, 1, 1, 1, -1, 1, -1, 1, -1, 1, -1, -1,
            -1, -1, -1, 1, -1, 1, 1, -1, 1, -1, 1, 1, 1, -1, -1, 1, -1, -1, -1,
            1, 1, 1, -1, -1, -1, -1, -1, -1, -1]

RATE_BITS = {
    '1101': 6,
    '1111': 9,
    '0101': 12,
    '0111': 18,
    '1001': 24,
    '1011': 36,
    '0001': 48,
    '0011': 54,
}

# 802.11n
HT_SUBCARRIERS = range(-28, 0) + range(1, 29)
HT_FFT_MAPPING = dict((c, c if c > 0 else 64 + c) for c in HT_SUBCARRIERS)

# append 1 for negative sub carriers, -1 for positive sub carriers
HT_LTS_REF = dict(
    zip(HT_SUBCARRIERS,
        [1, 1, 1,  1, -1, -1, 1,  1, -1,  1, -1,  1,  1,  1, 1, 1, 1, -1, -1,
         1,  1, -1,  1, -1,  1,  1, 1, 1,  1, -1, -1,  1, 1, -1,  1, -1,  1, -1,
         -1, -1, -1, -1,  1,  1, -1, -1,  1, -1,  1, -1, 1,  1,  1,  1, -1,
         -1]))


def to_hex(n, n_bits):
    return hex((n + (1<<n_bits)) % (1<<n_bits))


class ChannelEstimator(object):
    """
    Frequency offset correction and channel equalization.
    """

    def __init__(self, samples):
        # samples[0] is the first sample of STS/L-STS
        self.samples = samples
        self.ht = False
        self.subcarriers = SUBCARRIERS
        self.fft_mapping = FFT_MAPPING
        self.short_gi = False

        self.fix_freq_offset()

        assert len(self.lts_samples) == 128
        lts1 = self.do_fft(self.lts_samples[:64])
        lts2 = self.do_fft(self.lts_samples[64:128])

        # print '[RAW LTS] (%s)' % (self.samples[160+32:160+32+4])
        for i in range(0):
            print '[%d] (%d, %d) -> (%d, %d) phase: %f (diff: %d)' %\
                (i,
                 int(self.samples[192+i].real),
                 int(self.samples[192+i].imag),
                 int(self.lts_samples[i].real),
                 int(self.lts_samples[i].imag),
                 cmath.phase(self.lts_samples[i]),
                 int((cmath.phase(self.lts_samples[i])-cmath.phase(samples[192+i]))*PHASE_SCALE),
                 )
        self.gain = dict((c, (lts1[c]+lts2[c])/2*LTS_REF[c])
                         for c in self.subcarriers)
        self.idx = 0
        self.polarity = itertools.cycle(polarity)

    def next_symbol(self):
        if self.short_gi:
            symbol = self.do_fft(self.data_samples[self.idx+8:self.idx+72])
            self.idx += 72
        else:
            symbol = self.do_fft(self.data_samples[self.idx+16:self.idx+80])
            self.idx += 80

        # remove randomness of pilot carriers
        p = self.polarity.next()
        if not self.ht:
            polarity = [p, p, p, -p]
        else:
            polarity = [p*p1 for p1 in self.ht_polarity]
            self.ht_polarity.rotate(-1)
        # print '[POLARITY] %d: %s' % (p, polarity)

        for c, p in zip(PILOT_SUBCARRIES, polarity):
            symbol[c] *= p

        # Correct Residual Carrier Frequency Offset
        prod_sum = 0
        for c in PILOT_SUBCARRIES:
            prod = symbol[c].conjugate()*self.gain[c]
            prod_sum += prod
        beta = cmath.phase(prod_sum)
        print "[PILOT OFFSET] %f (%d)" % (beta, int(beta*PHASE_SCALE))
        carriers = []
        for c in self.subcarriers:
            if c in PILOT_SUBCARRIES:
                continue
            symbol[c] *= cmath.exp(complex(0, beta))
            symbol[c] /= self.gain[c]
            carriers.append(symbol[c])
        return carriers

    def switch_ht(self):
        """
        Switch to HT channel estimator.
        """
        self.ht = True
        self.subcarriers = HT_SUBCARRIERS
        self.fft_mapping = HT_FFT_MAPPING

        ht_sts = self.data_samples[self.idx:self.idx+80]
        self.idx += 80

        ht_offset = cmath.phase(sum([ht_sts[i].conjugate()*ht_sts[i+16]
                                     for i in range(len(ht_sts)-16)]))/16
        print '[HT OFFSET] %f (%d)' % (ht_offset, int(ht_offset*PHASE_SCALE))
        ht_offset = 0
        self.data_samples = [c*cmath.exp(complex(0, -n*ht_offset))
                             for n, c in enumerate(self.data_samples[self.idx:])]
        self.idx = 0

        ht_lts = self.do_fft(self.data_samples[self.idx+16:self.idx+80])
        self.idx += 80

        self.gain = dict((c, ht_lts[c]*HT_LTS_REF[c]) for c in self.subcarriers)
        self.ht_polarity = collections.deque([1, 1, 1, -1])

    def do_fft(self, samples):
        assert len(samples) == 64, len(samples)
        freq = np.fft.fft(samples)
        return dict((c, freq[self.fft_mapping[c]]) for c in self.subcarriers)

    def fix_freq_offset(self):
        sts = self.samples[80:160]
        lts = self.samples[160+32:160+160]

        coarse_offset = cmath.phase(sum([sts[i]*sts[i+16].conjugate()
                                         for i in range(len(sts)-16)]))/16
        print '[COARSE OFFSET] %f (%d)' % (coarse_offset, int(coarse_offset*PHASE_SCALE))
        # coarse_offset = 0

        # coarse correction
        lts = [c*cmath.exp(complex(0, n*coarse_offset))
               for n, c in enumerate(lts)]

        fine_offset = cmath.phase(sum([lts[i]*lts[i+64].conjugate()
                                       for i in range(len(lts)-64)]))/64
        print '[FINE OFFSET] %f (%d)' % (fine_offset, int(fine_offset*PHASE_SCALE))
        fine_offset = 0

        self.lts_samples = [c*cmath.exp(complex(0, n*fine_offset))
               for n, c in enumerate(lts)]

        self.freq_offset = coarse_offset + fine_offset
        print '[FREQ OFFSET] %f (%d)' % (self.freq_offset, int(self.freq_offset*PHASE_SCALE))

        self.data_samples = [c*cmath.exp(complex(0, n*self.freq_offset))
                             for n, c in enumerate(self.samples[320:], start=128)]


class Demodulator(object):
    QAM16_MAPPING = {
        0b00: -3,
        0b01: -1,
        0b11: 1,
        0b10: 3,
    }

    QAM64_MAPPING = {
        0b000: -7,
        0b001: -5,
        0b011: -3,
        0b010: -1,
        0b110: 1,
        0b111: 3,
        0b101: 5,
        0b100: 7,
    }

    def __init__(self, rate=6, mcs=0, ht=False):
        if (not ht and rate in [6, 9]) or (ht and mcs == 0):
            # BPSK
            self.scale = 1
            self.bits_per_sym = 1
            self.cons_points = np.array([complex(-1, 0), complex(1, 0)])
        elif (not ht and rate in [12, 18]) or (ht and mcs in [1, 2]):
            # QPSK
            self.scale = 1
            self.bits_per_sym = 2
            self.cons_points = np.array(
                [complex(-1, -1), complex(-1, 1),
                    complex(1, -1), complex(1, 1)]
            )
        elif (not ht and rate in [24, 36]) or (ht and mcs in [3, 4]):
            # 16-QAM
            self.scale = 3
            self.bits_per_sym = 4
            self.cons_points = np.array(
                [complex(self.QAM16_MAPPING[i >> 2],
                         self.QAM16_MAPPING[i & 0b11]) for i in range(16)])
        elif (not ht and rate in [48, 54]) or (ht and mcs in [5, 6, 7]):
            # 64-QAM
            self.scale = 7
            self.bits_per_sym = 6
            self.cons_points = np.array(
                [complex(self.QAM64_MAPPING[i >> 3],
                         self.QAM64_MAPPING[i & 0b111]) for i in range(64)])

    def demodulate(self, carriers):
        bits = []
        for sym in carriers:
            idx = np.argmin(abs(sym*self.scale - self.cons_points))
            bits.extend([int(b) for b in ('{0:0%db}' % (self.bits_per_sym)).format(idx)])
        return bits


class Signal(object):

    def __init__(self, bits):
        assert len(bits) == 24
        str_bits = ''.join([str(b) for b in bits])
        self.rate_bits = str_bits[:4]
        self.rsvd = str_bits[4]
        self.len_bits = str_bits[5:17]
        self.parity_bits = str_bits[17]
        self.tail_bits = str_bits[18:]

        self.mcs = 0
        self.rate = RATE_BITS.get(self.rate_bits, 0)
        self.length = int(self.len_bits[::-1], 2)
        self.parity_ok = sum(bits[:18]) % 2 == 0
        self.ht = False
        self.mcs = 0


class HTSignal(object):

    def __init__(self, bits):
        assert len(bits) == 48
        str_bits = ''.join([str(b) for b in bits])
        self.mcs_bits = str_bits[:6]
        self.cbw = str_bits[7]
        self.len_bits = str_bits[8:24]
        self.smoothing = str_bits[24]
        self.not_sounding = str_bits[25]
        self.rsvd = str_bits[26]
        self.aggregation = str_bits[27]
        self.stbc = str_bits[28:30]
        self.fec = str_bits[30]
        self.short_gi = str_bits[31]
        self.num_ext_stream = str_bits[32:34]
        self.crc = str_bits[34:42]
        self.tail_bits = str_bits[42:48]

        self.mcs = int(self.mcs_bits[::-1], 2)
        try:
            self.rate = dot11.mcs_to_rate(self.mcs)
        except:
            self.rate = 0
        self.length = int(self.len_bits[::-1], 2)
        self.expected_crc = ''.join(['%d' % c for c in self.calc_crc(bits[:34])])
        self.crc_ok = self.expected_crc == self.crc
        self.ht = True

    def calc_crc(self, bits):
        c = [1] * 8

        for b in bits:
            next_c = [0] * 8
            next_c[0] = b ^ c[7]
            next_c[1] = b ^ c[7] ^ c[0]
            next_c[2] = b ^ c[7] ^ c[1]
            next_c[3] = c[2]
            next_c[4] = c[3]
            next_c[5] = c[4]
            next_c[6] = c[5]
            next_c[7] = c[6]
            c = next_c

        return [1-b for b in c[::-1]]


class Decoder(object):

    def __init__(self, path, power_thres=200, skip=0, window=80):
        if path is not None:
            self.fh = open(path, 'rb')
            size = os.path.getsize(path)
            if skip*4 < size:
                self.fh.seek(skip*4)
            else:
                print "[WARN] try to seek beyond end of file %d/%d" % (skip*4, size)
            self.power_thres = 200
            self.window = window
            self.count = skip

    def decode_next(self, *args, **kwargs):
        trigger = False
        samples = []
        glbl_index = 0

        while True:
            chunk = array.array('h', self.fh.read(self.window*4))
            chunk = [complex(i, q) for i, q in zip(chunk[::2], chunk[1::2])]
            if not trigger and any([abs(c) > self.power_thres for c in chunk]):
                trigger = True
                samples = []
                print "Power trigger at %d" % (self.count)
                glbl_index = self.count

            self.count += self.window

            if trigger:
                samples.extend(chunk)

            if trigger and all([abs(c) < self.power_thres for c in chunk]):
                start = self.find_pkt(samples)
                if start is None:
                    trigger = False
                else:
                    print "Decoding packet starting from sample %d" %\
                        (glbl_index + start)
                    return (glbl_index, ) +\
                        self.decode(samples[start:], *args, **kwargs)

    def find_pkt(self, samples):
        """
        Returns the index of the first sample of STS
        None if no packet was detected.
        """
        lts = LONG_PREAMBLE[-64:]
        peaks = np.array([abs(c) for c in np.correlate(
            samples, lts, mode='valid')]).argsort()[-2:]
        if (max(peaks) - min(peaks) == 64) and (min(peaks) - 32 - 160) > 0:
            return min(peaks) - 32 - 160
        else:
            return None

    def demodulate(self, carriers, signal=None):
        if signal is None:
            demod = Demodulator(rate=6)
        else:
            demod = Demodulator(signal.rate, signal.mcs, signal.ht)
        return demod.demodulate(carriers)

    def deinterleave(self, in_bits, rate=6, mcs=0, ht=False, verbose=False):
        if not ht:
            n_bpsc, n_cbps, n_dbps = RATE_PARAMETERS[rate]
            n_col = 16
            n_row = 3 * n_bpsc
        else:
            n_bpsc, n_cbps, n_dbps = HT_MCS_PARAMETERS[mcs]
            n_col = 13
            n_row = 4 * n_bpsc
        s = max(n_bpsc/2, 1)

        first_perm = dict()
        for j in range(0, n_cbps):
            first_perm[j] = (s * (j/s)) + ((j + n_col*j/n_cbps) % s)

        second_perm = dict()
        for i in range(0, n_cbps):
            second_perm[i] = n_col*i - (n_cbps-1)*(i/n_row)

        if verbose:
            print "Bit rate: %f Mb/s" % (rate)
            print "Bits per sub carrier: %d" % (n_bpsc)
            print "Coded bits per symbol: %d" % (n_cbps)
            print "Data bits per symbol %d" % (n_dbps)
            print "S = %d" % (s)
            print "====== Overall permutation ========="
            for j in range(0, n_cbps):
                print '%d -> %d -> %d' % (j, first_perm[j], second_perm[first_perm[j]])

        if in_bits is None:
            idx_map = []
            for k in range(n_cbps):
                idx_map.append((second_perm[first_perm[k]], k))
            return sorted(idx_map)

        if verbose:
            print '%d bits, %f samples' % (len(in_bits), float(len(in_bits))/n_cbps)

        out_bits = [0]*len(in_bits)
        for n in range(len(in_bits)/n_cbps):
            for j in range(n_cbps):
                base = n*n_cbps
                out_bits[base+second_perm[first_perm[j]]] = in_bits[base+j]
        return out_bits

    def viterbi_decode(self, bits, signal=None):
        if signal is None:
            ht = False
            rate = 6
        else:
            ht, rate, mcs = signal.ht, signal.rate, signal.mcs

        if (not ht and rate in [9, 18, 36, 54]) or (ht and mcs in [2, 4, 6]):
            print '[PUNCTURE] 3/4'
            # 3/4
            new_bits = []
            for i in range(0, len(bits), 12):
                new_bits.extend(bits[i:i+3])
                new_bits.extend([2, 2])
                new_bits.extend(bits[i+3:i+7])
                new_bits.extend([2, 2])
                new_bits.extend(bits[i+7:i+11])
                new_bits.extend([2, 2])
                new_bits.extend(bits[i+11:i+12])
            bits = new_bits
        elif (not ht and rate in [48]) or (ht and mcs in [5]):
            print '[PUNCTURE] 2/3'
            # 2/3
            new_bits = []
            for i in range(0, len(bits), 9):
                new_bits.extend(bits[i:i+3])
                new_bits.append(2)
                new_bits.extend(bits[i+3:i+6])
                new_bits.append(2)
                new_bits.extend(bits[i+6:i+9])
                new_bits.append(2)
            bits = new_bits
        elif ht and mcs in [7]:
            print '[PUNCTURE] 5/6'
            # 5/6
            new_bits = []
            for i in range(0, len(bits), 6):
                new_bits.extend(bits[i:i+3])
                new_bits.extend([2, 2])
                new_bits.extend(bits[i+3:i+5])
                new_bits.extend([2, 2])
                new_bits.append(bits[i+5])
            bits = new_bits
        else:
            print '[NO PUNCTURE]'

        extended_bits = np.array([0]*2 + bits + [0]*12)
        trellis = cc.Trellis(np.array([7]), np.array([[0133, 0171]]))
        return list(cc.viterbi_decode(extended_bits, trellis, tb_depth=35))[:-7]

    def descramble(self, bits):
        X = [0]*7
        X[0] = bits[2] ^ bits[6]
        X[1] = bits[1] ^ bits[5]
        X[2] = bits[0] ^ bits[4]
        X[3] = X[0] ^ bits[3]
        X[4] = X[1] ^ bits[2]
        X[5] = X[2] ^ bits[1]
        X[6] = X[3] ^ bits[0]

        out_bits = []
        for i, b in enumerate(bits):
            feedback = X[6] ^ X[3]
            out_bits.append(feedback ^ b)
            X = [feedback] + X[:-1]

        return out_bits

    def check_signal(self, signal):
        if signal.rate_bits not in RATE_BITS:
            print '[SIGNAL] invalid rate: %s' % (signal.rate_bits)
            return False

        if signal.rsvd != '0':
            print '[SIGNAL] wrong rsvd'
            return False

        if not signal.parity_ok:
            print '[SIGNAL] wrong parity'
            return False

        if not all([b == '0' for b in signal.tail_bits]):
            print '[SIGNAL] wrong tail: %s' % (signal.tail_bits)
            return False

        return True

    def check_ht_signal(self, signal):
        if signal.mcs > 7:
            print '[HT SIGNAL] mcs not supported: %d' % (signal.mcs)
            return False

        if signal.cbw != '0':
            print '[HT SIGNAL] CBW not supported'
            return False

        if signal.rsvd != '1':
            print '[HT SIGNAL] wrong rsvd'
            return False

        if signal.stbc != '00':
            print '[HT SIGNAL] stbc not supported: %s' % (signal.stbc)
            return False

        if signal.fec != '0':
            print '[HT SIGNAL] FEC not supported'
            return False

        if signal.num_ext_stream != '00':
            print '[HT SIGNAL] EXT spatial stream not supported: %s' % (signal.num_ext_stream)
            return False

        if not all([b == '0' for b in signal.tail_bits]):
            print '[HT SIGNAL] wrong tail: %s' % (signal.tail_bits)
            return False

        return True

    def decode(self, samples, *args, **kwargs):
        eq = ChannelEstimator(samples)

        carriers = eq.next_symbol()
        assert len(carriers) == 48
        carrier_bits = self.demodulate(carriers)
        raw_bits = self.deinterleave(carrier_bits)
        bits = self.viterbi_decode(raw_bits)
        signal = Signal(bits)
        print "[SIGNAL] %s" % (signal.__dict__)

        if not self.check_signal(signal):
            return

        cons = []

        if signal.rate == 6:
            # decode next two OFDM SYMs to detect potential 802.11n packets
            demod_out = []
            for _ in range(2):
                carriers = eq.next_symbol()
                assert len(carriers) == 48
                cons.extend(carriers)

                # HT-SIG was rotated by 90 degrees, rotate it back
                carriers = [c*complex(0, -1) for c in carriers]

                carrier_bits = self.demodulate(carriers)
                demod_out.extend(carrier_bits)

            raw_bits = self.deinterleave(demod_out)
            signal_bits = self.viterbi_decode(raw_bits)

            ht_signal = HTSignal(signal_bits)
            if ht_signal.crc_ok:
                print "[HT SIGNAL] %s" % (ht_signal.__dict__)
                if not self.check_ht_signal(ht_signal):
                    return
                signal = ht_signal
                eq.switch_ht()
                cons = []
                eq.short_gi = ht_signal.short_gi == '1'

        if signal.ht:
            num_symbol = int(math.ceil(float((16+signal.length*8+6))/
                                       HT_MCS_PARAMETERS[signal.mcs][2]))
        else:
            num_symbol = int(math.ceil(float((16+signal.length*8.0+6))/
                                       RATE_PARAMETERS[signal.rate][2]))

        print "%d DATA OFDM symbols to decode" % (num_symbol)

        if signal.rate == 6 and not signal.ht:
            num_symbol -= 2

        for _ in range(num_symbol):
            carriers = eq.next_symbol()
            if signal.ht:
                assert len(carriers) == 52, len(carriers)
            else:
                assert len(carriers) == 48, len(carriers)
            cons.extend(carriers)

        demod_out = self.demodulate(cons, signal)
        deinter_out = self.deinterleave(demod_out, signal.rate, signal.mcs, signal.ht)
        conv_out = self.viterbi_decode(deinter_out, signal)
        descramble_out = self.descramble(conv_out)

        if not all([b == 0 for b in descramble_out[:16]]):
            print '[SERVICE] not all bits are 0'

        # skip the SERVICE bits
        data_bits = descramble_out[16:]
        num_bytes = min(len(data_bits)/8, signal.length)

        data_bytes = [self.array_to_int(data_bits[i*8:(i+1)*8])
                      for i in range(num_bytes)]
        assert len(data_bytes) == num_bytes

        for i in range(0, num_bytes, 16):
            print '[%3d] %s' %\
                (i, ' '.join([format(data_bytes[j], '02x')
                              for j in range(i, min(i+16, num_bytes))]))

        fh = StringIO(''.join([chr(b) for b in data_bytes]))
        pkt = dot11.Dot11Packet(fh)

        return signal, cons, demod_out, deinter_out, conv_out, descramble_out, data_bytes, pkt

    def array_to_int(self, arr):
        assert len(arr) == 8
        return int(''.join(['%d' % (b) for b in arr[::-1]]), 2)
