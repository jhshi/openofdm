Symbol Alignment
================

After detecting the packet, the next step is to determine precisely where each
OFDM symbol starts. In 802.11, each OFDM symbol is 4 |us| long. At 20 MSPS
sampling rate, this means each OFDM symbol contains 80 samples. The task is to
group the incoming streaming of samples into 80-sample OFDM symbols. This can be
achieved using the long preamble following the short preamble.

.. _fig_training:
.. figure:: /images/training.png
    :align: center

    802.11 OFDM Packet Structure (Fig 18-4 in 802.11-2012 Std)

As shown in :numref:`fig_training`, the long preamble duration is 8 |us| (160
samples), and contains two identical long training sequence (LTS), 64 samples each.
The LTS is known and we can use `matched filter
<https://en.wikipedia.org/wiki/Matched_filter>`_ to find it.

The match *score* at sample :math:`i` can be calculated as follows.

.. math:: 
    :label: eq_matched

    Y[i] = \sum_{k=0}^{63}(S[i+k]\overline{H[63-k]})

where :math:`H` is the 64 sample known LTS in time domain, and can be found in
Table L-6 in :download:`802.11-2012 std </files/802.11-2012.pdf>` (index 64 to
127). A numpy readable file of the LTS (64 samples) can be found :download:`here
</files/lts.txt>`, and can be read like this:

.. code-block:: python

    >>> import numpy as np
    >>> lts = np.loadtxt('lts.txt').view(complex)

.. _fig_lts:
.. figure:: /images/lts.png
    :align: center

    Long Preamble and Matched Filter Result

To plot :numref:`fig_lts`, load the data file (see :ref:`sec_sample`), then:

.. code-block:: python

    # in scripts/decode.py
    import decode
    import numpy as np
    from matplotlib import pyplot as plt

    fig, ax = plt.subplots(nrows=2, ncols=1, sharex=True)
    ax[0].plot([c.real for c in samples][:500])
    # lts is from the above code snippet
    ax[1].plot([abs(c) for c in np.convolve(samples, lts, mode='same')][:500], '-ro')
    plt.show()

    

:numref:`fig_lts` shows the long preamble samples and also the result of matched
filter. We can clearly see two spikes corresponding the two LTS in long
preamble. And the spike width is only 1 sample which shows exactly the beginning
of each sequence. Suppose the sample index if the first spike is :math:`N`, then
the 160 sample long preamble starts at sample :math:`N-33`.

This all seems nice and dandy, but as it comes to Verilog implementation, we
have to make a few compromises.

First, from :eq:`eq_matched` we can see for each sample, we need to perform 64
complex number multiplications, which would consume a lot FPGA resources.
Therefore, we need to reduce the matched filter size. The idea is to only use
a portion instead of all the LTS samples.

.. _fig_match_size:
.. figure:: /images/match_size.png
    :align: center

    Matched Filter with Various Size (8, 16, 32, 64)

:numref:`fig_match_size` can be plotted as:

.. code-block:: python

    lp = decode.LONG_PREAMBLE

    fig, ax = plt.subplots(nrows=5, ncols=1, sharex=True)
    ax[0].plot([c.real for c in lp])
    ax[1].plot([abs(c) for c in np.convolve(lp, lts[:8], mode='same')], '-ro')
    ax[2].plot([abs(c) for c in np.convolve(lp, lts[:16], mode='same')], '-ro')
    ax[3].plot([abs(c) for c in np.convolve(lp, lts[:32], mode='same')], '-ro');
    ax[4].plot([abs(c) for c in np.convolve(lp, lts, mode='same')], '-ro')
    plt.show()

:numref:`fig_match_size` shows the long preamble (160 samples) as well as
matched filter with different size. It can be seen that using the first 16
samples of LTS is good enough to exhibit two narrow spikes. Therefore, |project|
use matched filter of size 16 for symbol alignment. And the first sample of the
long preamble starts at :math:`N_{16}-57`, where :math:`N_{16}` is the index of
the first spike when the filter size is 16 (for completeness, it is
:math:`N_{32}-49` when filter size is
32).
