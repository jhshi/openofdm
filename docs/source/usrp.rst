Integration with USRP
=====================

|project| was originally developed on Ettus Research USRP N210 platform. This
short guide explains how to modify the USRP N210's FPGA code base to
accommodate |project|.

USRP N2x0 FPGA Overview
-----------------------

The top level model of USRP N2x0 (N200 and N210) can be found in
:file:`top/N2x0/u2plus.v`. It instantiates the ``u2plus_core`` module, which
contains the core modules such as the receiver and transmit chain. In
particular, the receive chain includes ``rx_frontend``, ``ddc_chain`` and
``vita_rx_chain``. Similarly, the transmit chain includes ``vita_tx_chain``,
``duc_chain`` and ``tx_frontend``.

The code base contains placeholder modules (``dsp_rx_glue`` and ``dsp_tx_glue``)
for extension. These modules are controlled by Verilog compilation flags and by
default they are simply pass-through and have no effect on the signal processing
at all.


Enable Custom Modules
---------------------

Take the receive chain as an example, inside ``dsp_rx_glue`` module, it checks
the ``RX_DSP0_MODULE`` macro and instantiates it if found. The macro can be
defined in a customized Makefile. Make a copy of the
:file:`top/N2x0/Makefile.N210R4`, name it to
:file:`top/N2x0/Makefile.N210R4.custom`. And then make these changes.

- Change ``BUILD_DIR`` to ``$(abspath build$(ISE)-N210R4-custom)``. This will
  create a new build directory for our custom build.

- Comment out ``CUSTOM_SRCS`` and ``CUSTOM_DEFS``. We will define them in a
  separate Makefile.

- Find ``Verilog Macros`` and change it to
  ``"LVDS=1|RX_DSP0_MODULE=custom_dsp_rx|RX_DSP1_MODULE=custom_dsp_rx|TX_DSP0_MODULE=custom_dsp_tx|TX_DSP1_MODULE=custom_dsp_tx|FIFO_CTRL_NO_TIME=1"``.
  This defines the macros to so that the custom modules are instantiated by the
  glue modules mentioned earlier.

After these changes, the two modules in :file:`custom/custom_dsp_rx.v` and
:file:`custom/custom_dsp_tx.v` will be instantiated. By default they are simply
pass-through. For instance, the output of RF frontend are directly connnected to
the input of DDC, and the output of DDC are directly connected to the VITA RX
module.

To integrate |project|, we only need to *insert* it after the DDC but before
VITA RX module. That is, the ``sample_in/sample_in_strobe`` of the ``dot11``
module should be connected to the ``ddc_out/ddc_out_strobe`` signal.

Also note that two receive chains are defined in ``u2plus_core`` module, so that
the two antenna ports can be configured in TX/RX or RX/RX mode. To save FPGA
resource, you may want to comment out one of the RX chains to make more room for
|project|.
