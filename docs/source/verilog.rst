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
number. The *right* way of doing this is probably using the `CORDIC
<https://dspguru.com/dsp/faqs/cordic/>`_ algorithm. In OpenOFDM, we use look up
table.

More specifically, we calculate the phase using the :math:`arctan` function. 


.. math::

    \theta = \angle(\langle I, Q\rangle) = arctan(\frac{Q}{I})

The overall steps are:

1. Project the complex number to the :math:`[0, \pi/4]` range, so that the
   :math:`tan(\theta)` range is :math:`[0, 1]`.
#. Calculate :math:`arctan` (division required)
#. Looking up the quantized :math:`arctan` table
#. Project the phase back to the :math:`[-\pi, \pi)` range

Here we use both quantization and look up table techniques.

Step 1 can be achieved by this transformation:

.. math::

    \langle I, Q\rangle \rightarrow \langle max(|I|, |Q|), min(|I|, |Q|)\rangle


In the lookup table used in step 3, we use :math:`int(tan(\theta)*256)` as the
key, which effectively maps the :math:`[0.0, 1.0]` range of :math:`tan` function
to the integer range of :math:`[0, 256]`. In other words, we quantize the
:math:`[0, \pi/4]` quadrant into 256 slices.

This :math:`arctan` look up table is generated using the
``scripts/gen_atan_lut.py`` script. The core logic is as follows:

.. code-block:: python
    :linenos:

    SIZE = 2**8
    SCALE = SIZE*2
    data = []
    for i in range(SIZE):
        key = float(i)/SIZE
        val = int(round(math.atan(key)*SCALE))
        data.append(val)


Note that we also scale up the :math:`arctan` values to distinguish adjacent
values. This also systematically scale up :math:`\pi` in OpenOFDM. In fact,
:math:`\pi` is defined as :math:`1608=int(\pi*512)` in
``verilog/common_params.v``.

The generated lookup table is stored in the ``verilog/atan_lut.coe``
file (see `COE File Syntax
<https://www.xilinx.com/support/documentation/sw_manuals/xilinx11/cgn_r_coe_file_syntax.htm>`_).
Refer to `this guide
<https://www.xilinx.com/itp/xilinx10/isehelp/cgn_p_memed_single_block.htm>`_ on
how to create a look up table in Xilinx ISE. The generated module is stored in
``verilog/coregen/atan_lut.v``.
