SIGNAL and HT-SIG
=================

The first OFDM symbol after long preamble is the SIGNAL field, which contains
the modulation rate and length of the packet. These information are needed to
determine how many OFDM symbols to decode and how to decode them.

Legacy SIGNAL
-------------

.. _fig_signal:
.. figure:: /images/signal.png
    :align: center
    :scale: 80%

    SIGNAL field of 802.11a/g

For 802.11a/g, the SIGNAL field is 24-bits, which expands to 48 bits after 1/2
convolutional encoding and fits precisely into one OFDM symbol.
:numref:`fig_signal` shows the format of SIGNAL. 

In |project|, we check the following properties to make sure the SIGNAL field is
decoded properly.

- Parity. Bit 17 is a even parity bit of the previous 17 bits.
- Reserved bit. Bit 4 is reserved, and should be 0.
- Tail bits. The last 6 bits should be all 0.

If any checking failed, we stop decoding immediately and wait for next power
trigger.


HT-SIG
------

For backward compatibility, 802.11n shares the same preambles and SIGNAL field
with 802.11a/g so that legacy stations can also decode the SIGNAL field and
back-off accordingly (see `NAV
<https://en.wikipedia.org/wiki/Network_allocation_vector>`_).


.. _fig_ht_ppdu:
.. figure:: /images/ht_ppdu.png
    :align: center
    :scale: 80%

    PPDU Format of 802.11n

As shown in :numref:`fig_ht_ppdu`, there are actually three PPDU formats
supported in 802.11n. The legacy mode is identical to 802.11a/g. The HT-mixed
mode provides backward compatibility, and is mostly widely used. Finally, the
HT-greenfield mode is pure 802.11n and does not have backward compatibility.
|project| supports HT-mixed mode only.

In HT-mixed mode, the rate field in SIGNAL (or L-SIG) is always 6 Mbps, and the
LENGTH is adjusted accordingly so that it reflects the actual packet air
duration.

From receiver's point of view, after decoding the SIGNAL field, if the rate is
not 6 Mbps, then this is a 802.11a/g packet and we continue to decoding the DATA
bits.  However, if the rate is 6 Mpbs, then we need to first check if this is a
802.11n packet by detecting the HT-SIG field. This is achieved by examine the
BPSK constellation points of the OFDM symbol after SIGNAL.


.. _fig_ht_sig_bpsk:
.. figure:: /images/ht_sig_bpsk.png
    :align: center
    :scale: 80%

    Constellation Points of HT-SIG vs. SIGNAL

As shown in :numref:`fig_ht_sig_bpsk`, HT-SIG is BPSK modulated using the
Quadrature component instead of the In-phase component. Therefore, we check the
number of samples in which the quadrature component is larger than in-phase, and
claim a HT-SIG if enough such samples are detected (4 in |project|).

The HG-SIG field spans two OFDM symbols, and has 48 data bits (96 coded bits) in
total. The constellation points are rotated 90 degrees clockwise before
decoding.

.. _fig_ht_sig:
.. figure:: /images/ht_sig.png
    :align: center
    :scale: 80%

    HT-SIG Format

:numref:`fig_ht_sig` shows the format of HT-SIG. The following fields are checked
in |project|:

- MCS: only supports 0 - 7.
- CBW 20/40: channel bandwidth. |project| only supports 20 MHz channel (0).
- Reserved: must be 0.
- STBC: number of `space time block code
  <https://en.wikipedia.org/wiki/Space%E2%80%93time_block_code>`_. |project|
  only supports 00 (no STBC).
- FEC coding: |project| only supports BCC (0).
- Short GI: whether short guard interval is used.
- Number of extension spatial streams: only 0 is supported.
- CRC: checksum of previous 34 bits.
- Tail bits: must all be 0.



