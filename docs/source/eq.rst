Sub-carrier Equalization and Pilot Correction
=============================================

- **Module**: :file:`equalizer.v`
- **Input**: ``I (16), Q (16)``
- **Output**: ``I (16), Q (16)``

This is the first module in frequency domain. There are two main tasks:
sub-carrier gain equalization and correcting residue phase offset using the
pilot sub-carriers.

Sub-carrier Structure
---------------------

The basic channel width in 802.11a/g/n is 20 MHz, which is further divided into
64 sub-carriers (0.3125 MHz each).

.. _fig_subcarrier:
.. figure:: /images/subcarrier.png
    :align: center

    Sub-carriers in 802.11 OFDM

:numref:`fig_subcarrier` shows the sub-carrier structure of the 20 MHz band. 52
out of 64 sub-carriers are utilized, and 4 out of the 52 (-7, -21, 7, 21)
sub-carriers are used as pilot sub-carrier and the remaining 48 sub-carriers
carries data. As we will see later, the pilot sub-carriers can be used to
correct the residue frequency offset.

Each sub-carrier carries I/Q modulated information, corresponding to the output
of 64 point FFT from :file:`sync_long.v` module. 


Sub-Carrier Equalization
------------------------

.. _fig_lts_fft:
.. figure:: /images/lts_fft.png
    :align: center
    :scale: 80%

    FFT of the Perfect and Two Actual LTS

To plot :numref:`fig_lts_fft`:

.. code-block:: python

    lts1 = samples[11+160:][32:32+64]
    lts2 = samples[11+160:][32+64:32+128]
    fig, ax = plt.subplots(nrows=3, ncols=1, sharex=True);
    ax[0].plot([c.real for c in np.fft.fft(lts)], '-bo');
    ax[1].plot([c.real for c in np.fft.fft(lts1)], '-ro');
    ax[2].plot([c.real for c in np.fft.ff t(lts2)], '-ro');
    plt.show()

:numref:`fig_lts_fft` shows the FFT of the perfect LTS and the two actual LTSs
in the samples. We can see that each sub-carrier exhibits different magnitude
gain. In fact, they also have different phase drift. The combined effect of
magnitude gain and phase drift (known as *channel gain*) can clearly be seen in
the I/Q plane shown in :numref:`fig_lts_fft_iq`.


.. _fig_lts_fft_iq:
.. figure:: /images/lts_fft_iq.png
    :align: center
    :scale: 80%

    FFT in I/Q Plane of The Actual LTS


To map the FFT point to constellation points, we need to compensate for the
channel gain. This can be achieved by normalize the data OFDM symbols using the
LTS. In particular, the mean of the two LTS is used as channel gain (:math:`H`):

.. math::

    H[i] = \frac{1}{2}(LTS_1[i] + LTS_2[i])\times L[i], i \in
    [-26, 26]

where :math:`L[i]` is the sign of the LTS sequence:

.. math::

    L_{-26,26} = \{
    &1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1,\\
    &1, -1, 1, -1, 1, 1, 1, 1, 0, 1, -1, -1, 1, 1, -1, 1, -1, 1,\\
    &-1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1\}

And the FFT output at sub-carrier :math:`i` is normalized as:

.. math::

    Y[i] = \frac{X[i]}{H[i]}, i \in [-26, 26]

where :math:`X[i]` is the FFT output at sub-carrier :math:`i`.


.. _fig_raw_fft:
.. figure:: /images/raw_fft.png
    :align: center
    :scale: 80%

    FFT Without Normalization

.. _fig_norm_fft:
.. figure:: /images/norm_fft.png
    :align: center
    :scale: 80%

    FFT With Normalization

:numref:`fig_raw_fft` and :numref:`fig_norm_fft` shows the FFT before and after
normalization using channel gain.


Residual Frequency Offset Correction
------------------------------------

We can see from :numref:`fig_norm_fft` that the FFT output is tilted slightly.
This is caused by residual frequency offset that was not compensated during the
coarse CFO correction step.

This residual CFO can be corrected either by :ref:`sec_fine_cfo`, or/and by the
pilot sub-carriers. Ideally we want to do both, but since the fine CFO is
usually beyond the resolution of the phase look up table, we skip it in the
:file:`sync_long.v` module and only rely on the pilot sub-carriers.

Regardless of the data sub-carrier modulation, the four pilot sub-carriers (-21,
-7, 7, 21) always contains BPSK modulated pseudo-random binary sequence.


The polarity of the pilot sub-carriers varies symbol to symbol. For 802.11a/g,
the pilot pattern is:

.. math::

    p_{0,\ldots,126} = \{
    &1, 1, 1, 1,-1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1,\\
    &1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1,-1,-1, 1, 1, 1,-1, 1,-1,-1,-1, 1,-1,\\
    &1,-1,-1, 1,-1,-1, 1, 1, 1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1,\\
    &1,-1,-1,-1, 1, 1,-1,-1,-1,-1, 1,-1,-1, 1,-1, 1, 1, 1, 1,-1, 1,-1, 1,-1,\\
    &1,-1,-1,-1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1, 1, 1,-1,-1, 1,-1,-1,-1, 1, 1,\\
    &1,-1,-1,-1,-1,-1,-1,-1\}

And the pilot sub-carriers at OFDM symbol :math:`n` (starting at 0 from the first
symbol after the long preamble) is then:

.. math::

    P^{(n)}_{-21, -7, 7, 21} = \{p_{n\%127}, p_{n\%127}, p_{n\%127}, -p_{n\%127}\}


For 802.11n at 20MHz bandwidth with single spatial stream, the n'th pilot
sub-carriers are:

.. math::
    P^{(n)}_{-21, -7, 7, 21} = \{\Psi_{n\%4}, \Psi_{(n+1)\%4}, \Psi_{(n+2)\%4},
    \Psi_{(n+3)\%4}\}

And:

.. math::
    \Psi_{0, 1, 2, 3} = \{1, 1, 1, -1\}


In other words, the pilot sub-carries of the first few symbols are:


.. math::

    P^{(0)}_{-21, -7, 7, 21} = \{1, 1, 1, -1\}\\
    P^{(1)}_{-21, -7, 7, 21} = \{1, 1, -1, 1\}\\
    P^{(2)}_{-21, -7, 7, 21} = \{1, -1, 1, 1\}\\
    P^{(3)}_{-21, -7, 7, 21} = \{-1, 1, 1, 1\}\\
    P^{(4)}_{-21, -7, 7, 21} = \{1, 1, 1, -1\}\\
    \cdots

For other configurations (e.g., spatial stream, bandwidth), the pilot
sub-carrier pattern can be found in Section 20.3.11.10 in
:download:`802.11-2012 std <./files/802.11-2012.pdf>`.


The residual phase offset at symbol :math:`n` can then be estimated as:

.. math::

    \theta_n = \angle(\sum_{i\in\{-21, -7, 7, 21\}}\overline{X^{(n)}[i]}\times P^{(n)}[i]\times H[i])


Combine this phase offset and the previous channel gain correction together, the
adjustment to symbol :math:`n` is:

.. math::

    Y^{(n)}[i] = \frac{X^{(n)}[i]}{H[i]}e^{j\theta_n}


.. _fig_pilot_fft:
.. figure:: /images/pilot_fft.png
    :align: center
    :scale: 80%

    Residual CFO Correction Using Pilot Sub-Carriers

:numref:`fig_pilot_fft` shows the effect of correcting the residual CFO using
pilot sub-carriers. Each sub-carrier can then be mapped to constellation points
easily.

In |project|, the above tasks are implemented by the :file:`equalizer.v` module.
It first stores the first LTS, and then calculates the mean of the two LTS and
store it as channel gain.

For each incoming OFDM symbol, it first obtains the polarity of the pilot
sub-carriers in current symbol, then calculates the residual CFO using the pilot
sub-carriers and also performs the channel gain correction.
