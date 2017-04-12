Sub-carrier Equalization and Pilot Correction
============================================

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
    [-26,\ldots, -1, 1, \ldots, 26]

where :math:`L[i]` is the sign of the LTS sequence:

.. math::

    L_{-26,26} = \{
    &1, 1, –1, –1, 1, 1, –1, 1, –1, 1, 1, 1, 1, 1, 1, –1, –1, 1,\\
    &1, –1, 1, –1, 1, 1, 1, 1, 0, 1, –1, –1, 1, 1, –1, 1, –1, 1,\\
    &–1, –1, –1, –1, –1, 1, 1, –1, –1, 1, –1, 1, –1, 1, 1, 1, 1\}

And the FFT output at sub-carrier :math:`i` is normalized as:

.. math::

    S'[i] = \frac{S[i]}{H[i]}

