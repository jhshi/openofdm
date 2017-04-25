Overview
========

Once the RF signals are captured and down-converted to baseband, the decoding
pipeline starts, including:

1. Packet detection
#. Center frequency offset correction
#. FFT
#. Channel gain estimation
#. Demodulation
#. Deinterleaving
#. Convolutional decoding
#. Descrambling


This documentation walks through the decoding pipeline and explains how each
step is implemented in |project|.

Top Level Module
----------------

.. _fig_dot11:
.. figure:: /images/dot11.png
    :align: center
    :scale: 50%

    Dot11 Core Schematic Symbol

The top level module of |project| is :file:`dot11.v`. :numref:`fig_dot11` shows
its input/output pins. It takes I/Q samples as input, and output 802.11 packet
data bytes and various PHY properties.

.. table:: Dot11 Module Pinout
    :align: center

    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | Port Name     | Port Width | Direction | Description                                                                               |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | clock         | 1          | Input     | Rising edge clock                                                                         |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | enable        | 1          | Input     | Module enable (active high)                                                               |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | reset         | 1          | Input     | Module reset (active high)                                                                |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | set_stb       | 1          | Input     | Setting register strobe                                                                   |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | set_addr      | 8          | Input     | Setting register address                                                                  |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | set_data      | 32         | Input     | Setting register value                                                                    |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | sample_in     | 32         | Input     | High 16 bit I, low 16 bit Q                                                               |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | sample_in_stb | 1          | Input     | Sample input strobe                                                                       |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | pkt_begin     | 1          | Output    | Signal begin of a packet                                                                  |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | pkt_ht        | 1          | Output    | HT (802.11n) or legacy (802.11a/g) packet                                                 |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | pkt_rate      | 8          | Output    | For HT, the lower 7 bits is MCS. For legacy, the lower 4 bits is the rate bits in SIGNAL  |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | pkt_len       | 16         | Output    | Packet length in bytes                                                                    |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | byte_out_stb  | 1          | Output    | Byte out strobe                                                                           |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | byte_out      | 8          | Output    | Byte value                                                                                |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | fcs_out_stb   | 1          | Output    | FCS output strobe                                                                         |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+
    | fcs_ok        | 1          | Output    | FCS correct (high) or wrong (low)                                                         |
    +---------------+------------+-----------+-------------------------------------------------------------------------------------------+


Project Structure
-----------------

In the :file:`verilog` sub-directory, you will find the Verilog implementations
of various modules. The implementations were originally targeted for the Xilinx
Spartan 3A-DSP 3400 FPGA inside the USRP N210 device, thus there are various
dependences to Xilinx libraries and USRP code base. In particular:

- :file:`verilog/Xilinx` contains the Xilinx specific libraries
- :file:`verilog/coregen` contains generated IP cores from Xilinx ISE
- :file:`verilog/usrp2` contains USRP specific modules

However, the project is self-contained and is ready for simulation using `Icarus
Verilog <http://iverilog.icarus.com/>`_ tool chain, including ``iverilog`` and
``vvp``.

The :file:`scripts` directory contains various Python scripts that:

- Generate look up tables (:file:`gen_atan_lut.py`, :file:`gen_rot_lut.py`,
  :file:`gen_deinter_lut.py`)
- Convert binary I/Q file into text format so it can be read in Verilog using
  ``readmemh``.
- Consolidate sample files by removing *silent* signals (:file:`condense.py`).
- Test each step of decoding process (:file:`test.py`)
- 802.11 decoder in Python for cross validation (:file:`decode.py`)

It also contains a modified copy of the `CommPy <https://github.com/veeresht/CommPy>`_ library.

The :file:`test.py` script is for cross validation between the Python decoder
and |project| decoder. It first uses the :file:`decode.py` script to decode the
sample file and stores the expected output of each step. It then performs
Verilog simulation using ``vvp`` and compare the Verilog output against the
expected output step by step.

The :file:`testing_inputs` directory contains various sample files collected in
a conducted or over the air setup. These files covers all the bit rates (legacy
and HT) supported in |project|.

.. _sec_sample:

Sample File
-----------

Throughout this documentation we will be using a sample file that contains the
I/Q samples of a 802.11a packet at 24 Mbps (16-QAM). It'll be helpful to use a
interactive iPython session and exercise various steps discussed in the
document.

Download the sample file from :download:`here </files/samples.dat>`, the data
can be loaded as follows:

.. code-block:: python

    import scipy

    wave = scipy.fromfile('samples.dat', dtype=scipy.int16)
    samples = [complex(i, q) for i, q in zip(wave[::2], wave[1::2])]
