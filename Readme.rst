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
