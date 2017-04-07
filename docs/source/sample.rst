.. _sec_sample:

Sample File
===========

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
