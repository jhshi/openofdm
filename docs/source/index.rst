.. OpenOFDM documentation master file, created by
   sphinx-quickstart on Mon Apr  3 14:42:17 2017.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

|project|: Synthesizable, Modular Verilog Implementation of 802.11 OFDM Decoder
===============================================================================

|project| is a open source Verilog implementation of 802.11 OFDM decoder.
Highlights are:

- Supports 802.11a/g (all bit rates) and 802.11n (20MHz BW, MCS 0 - 7)
- Modular design, easy to extend
- Fully synthesizable, tested on USRP N210

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   overview
   detection
   freq_offset
   sync_long
   eq
   decode
   sig
   setting
   verilog
   usrp

