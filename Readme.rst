OpenOFDM
========

This project contains a Verilog implementation of 802.11 OFDM PHY decoder.
Features are:

 - Fully synthesizable (tested on Ettus Research USRP N210 platform)
 - Full support for legacy 802.11a/g
 - Support 802.11n for MCS 0 - 7 @ 20 MHz bandwidth
 - Cross validation with included Python decoder 
 - Modular design for easy modification and extension

See full documentation at http://openofdm.readthedocs.io.

Environment Setup
-----------------

This project has the following dependencies:

 - `Icarus Verilog <http://iverilog.icarus.com/>`_: for compiling Verilog files and simulation.
 - `GtkWave <http://iverilog.icarus.com/>`_: for wave form visualization.


Input and Output
----------------

In a nutshell, the top level ``dot11`` Verilog module takes 32-bit I/Q samples
(16-bit each) as input, and output decoded bytes in 802.11 packet. The sampling
rate is 20 MSPS and the clock rate is 100 MHz. This means this module expects
one pair of I/Q sample every 5 clock ticks.


License
-------

`Apache License 2.0 <https://www.apache.org/licenses/LICENSE-2.0>`_

FAQs
----

**Q: Is there any need to change host driver UHD to incorporate new changes in
FPGA?**

A: No. In fact OpenOFDM relies on the current UHD-USRP communication mechanism.
However, since the logic of the FPGA is changed in OpenOFDM, its behavior is
also different. For instance, utilities such as ``rx_samples_to_file`` do not
work as expected since the FPGA in OpenOFDM does not dumping RF signals back to
host.

**Q: Any example code to communicate with OFDM core in FPGA from host?**

A: OpenOFDM FPGA module is configurable via USRP user setting registers
(``set_user_reg`` function). The
register address definition is in `common_params.v
<https://github.com/jhshi/openofdm/blob/master/verilog/common_params.v>`_. The
whole OpenOFM FPGA module takes 32 bit I/Q samples and outputs decoded bytes. It
is supposed to be placed in the receive chain of the USRP (e.g.,
``custom_dsp_rx.v``.


**Q: Is there any change in ZPU firmware?**

A: No.
