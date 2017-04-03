Packet Detection
================

802.11 OFDM packets start with a short PLCP Preamble sequence to help the
receiver detect the beginning of the packet. The short preamble duration is
8 us. At 20 MSPS sampling rate, it contains 10 repeating sequence of 16 I/Q
samples. The short preamble also helps the receiver for coarse frequency offset
correction , which will be discussed separately in :ref:`freq_offset`.

The core idea of detecting the short preamble is to utilize its repeating nature
by calculating the auto correlation metric. But before that, we need to make sure
we are trying to detect short preamble from "meaningful" signals. One example of
"un-meaningful" signal is constant power levels, whose auto correlation metric
is very high but does not represent packet beginning.

Power Trigger
-------------

- **Module**: ``power_trigger.v``
- **Input**: ``sample_in`` (16B I + 16B Q), ``sample_in_strobe`` (1B)
- **Output**: ``trigger`` (1B)

The first module in the pipeline is the ``power_trigger.v``. It takes the I/Q
samples as input and asserts the ``trigger`` signal during a potential packet
activity. Optionally, it can be configured to skip the first certain number of
samples before detecting a power trigger. This is useful to skip the spurious
signals during the intimal hardware stabilization phase.

