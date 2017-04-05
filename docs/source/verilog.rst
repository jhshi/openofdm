Verilog Hacks
=============

Because of the limited capability of FPGA computation, compromises often need to
made in the actual Verilog implementation. The most used techniques include
quantization and look up table. In OpenOFDM, these approximations are used.


Magnitude Estimation
--------------------

**Module**: ``complex_to_mag.v``

In the ``sync_short`` module, we need to calculate the magnitude of the
``prod_avg``, whose real and imagine part are both 32-bits. To avoid 32-bit
multiplication, we use the `Magnitude Estimator Trick from DSP Guru
<https://dspguru.com/dsp/tricks/magnitude-estimator/>`_. In particular, the
magnitude of complex number :math:`\langle I, Q\rangle` is estimated as:

.. math::

    M \approx \alpha*max(|I|, |Q|) + \beta*min(|I|, |Q|)

And we set :math:`\alpha = 1` and :math:`\beta = 0.25` so that only simple
bit-shift is needed.

.. _fig_complex_to_mag_wave:
.. figure:: /images/complex_to_mag_wave.png
    :align: center

    Waveform of ``complex_to_mag`` Module

:numref:`fig_complex_to_mag_wave` shows the waveform of the ``complex_to_mag``
module. In the first clock cycle, we calculate ``abs_i`` and ``abs_q``. In the
second cycle, ``max`` and ``min`` are determined. In the final cycle, the
magnitude is calculated.


Phase Estimation
----------------

**Module**:: ``phase.v``

When correcting the frequency offset, we need to estimate the phase of a complex
number, which can be calculated using the :math:`arctan` function. 


.. math::

    \angle(\langle I, Q\rangle) = arctan(\frac{Q}{I})

The overall steps are:

1. Project the complex number to the :math:`[0, \pi/4]` range.
#. Calculate :math:`arctan` (division required)
#. Looking up the quantized :math:`arctan` table
#. Project the phase back to the :math:`[-\pi, \pi)` range

Here we use both quantization and look up table techniques.

The first step can be achieved by this transformation:

.. math::

    \langle I, Q\rangle \rightarrow \langle max(|I|, |Q|), min(|I|, |Q|)\rangle


The *right* way to calculate :math:`arctan` is probably using the `CORDIC
<https://dspguru.com/dsp/faqs/cordic/>`_ algorithm. However, this function is
implemented using look up tables in OpenOFDM.

In the table, we use :math:`int(tan(\angle)*256)` as the key, which effective
map the :math:`[0.0, 1.0]` range of :math:`tan` function to the integer range of
:math:`[0, 256]`. In other words, we quantize the :math:`[0, \pi/4]` quadrant
into 256 slices.
