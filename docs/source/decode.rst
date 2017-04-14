Decoding
========

Now we have corrected the residual CFO and also have corrected the channel gain,
the next step is to map the FFT output to actual data bits. This is the reverse
process of encoding a packet.

1. demodulation: complex number to bits
#. deinterleaving: shuffle the bits inside each OFDM symbol
#. Convolution decoding: remove redundancy and correct potential bit errors
#. Descramble.

Step 1 and 3 depend on the modulation and coding scheme, which can be obtained
from the SIGNAL field. The SIGNAL field is encoded in the first OFDM symbol
after the long preamble and is always BPSK modulated regardless of the actual
modulation. Recall that in
802.11a/g, one OFDM symbol contains 48 data sub-carriers, which corresponds to
48 data bits in BPSK scheme. The SIGNAL field is also convolutional encoded at
1/2 rate so there are 24 actual data bits in the SIGNAL field.

Next, we first go through the decoding process and then explain the format of
both legacy (802.11a/g) and the HT (802.11n) SIGNAL format.

Demodulation
------------

- **Module**: :file:`demodulate.v`
- **Input**: ``rate (7), cons_i (16), cons_q (16)``
- **Output**: ``bits (6)``

This step maps the complex number in the FFT plane into bits. :numref:`fig_mod`
shows the constellation encoding schemes for BPSK, QPSK, 16-QAM and 64-QAM.
also supported in |project|.

.. _fig_mod:
.. figure:: /images/mod.png
    :align: center
    :scale: 80%

    BPSK, QPSK, 16-QAM and 64-QAM Constellation Bit Encoding

Inside each OFDM symbol, each sub-carrier is mapped into 1, 2, 4 or 6 bits
depending on the modulation.

Deinterleaving
--------------

Inside each OFDM symbol, the encoded bits are interleaved to map adjacent bits
into non-adjacent sub-carriers and also alternatively into less or more
significant bits in the constellation bits.

To understand how the block interleaver works, first we need to define a few
parameters. Here we only consider 802.11a/g and 802.11n single spatial stream
mode.

.. table:: Modulation Dependent Parameters (802.11a/g)
    :align: center

    +------------+-------------+----------+------------------+------------------+------------------+
    | Modulation | Coding Rate | Bit-Rate | :math:`N_{BPSC}` | :math:`N_{CBPS}` | :math:`N_{DBPS}` |
    +------------+-------------+----------+------------------+------------------+------------------+
    | BPSK       | 1/2         | 6        | 1                | 48               | 24               |
    +------------+-------------+----------+------------------+------------------+------------------+
    | BPSK       | 3/4         | 9        | 1                | 48               | 36               |
    +------------+-------------+----------+------------------+------------------+------------------+
    | QPSK       | 1/2         | 12       | 2                | 96               | 48               |
    +------------+-------------+----------+------------------+------------------+------------------+
    | QPSK       | 3/4         | 18       | 2                | 96               | 72               |
    +------------+-------------+----------+------------------+------------------+------------------+
    | 16-QAM     | 1/2         | 24       | 4                | 192              | 96               |
    +------------+-------------+----------+------------------+------------------+------------------+
    | 16-QAM     | 3/4         | 36       | 4                | 192              | 144              |
    +------------+-------------+----------+------------------+------------------+------------------+
    | 64-QAM     | 2/3         | 48       | 6                | 288              | 192              |
    +------------+-------------+----------+------------------+------------------+------------------+
    | 64-QAM     | 3/4         | 54       | 6                | 288              | 216              |
    +------------+-------------+----------+------------------+------------------+------------------+

where:

- :math:`N_{BPSC}`: number of bits per sub-carrier
- :math:`N_{CBPS}`: number of coded bits per OFDM symbol
- :math:`N_{DBPS}`: number of data bits per OFDM symbol

Let :math:`s=max(N_{BPSC}/2,

The interleaving process involves two permutations. Accordingly, the
de-interleaving process also contains two permutation to reverse the
interleaving.

The first permutation of de-interleaving is:

.. math::

    i = s\times\lfloor\frac{j}{s}\rfloor + (j+\lfloor16\times\frac{j}{N_{CBPS}}\rfloor)\%s, j\in[0, N_{CBPS}-1]

where :math:`s=max(N_{BPSC}/2, 1)`

The second permutation is defined as:

.. math::

    k = 16\times i - (N_{CBPS}-1)\times\lfloor\frac{16\times i}{N_{CBPS}}\rfloor

