Setting Registers
=================

- **Module**: ``usrp/setting_reg.v``
- **Input**: ``set_stb``, ``set_addr`` and ``set_data``
- **Output**: ``out``, ``changed``

To enable dynamic configuration of decoding parameters at runtime, the USRP N210
provides the setting register mechanism. Most modules in |project| have three
common inputs for such purpose:

 - ``set_stb (1)``: asserts high when the setting data is valid
 - ``set_addr (8)``: register address (256 registers possible in total)
 - ``set_data (32)``: the register value


Here is a list of setting registers in |project|.

.. table:: List of Setting Registers in |project|.
    :align: center

    +-----------------+------+-----------------+-----------+---------------+---------------------------------------------------------------+
    | Name            | Addr | Module          | Bit Width | Default Value | Description                                                   |
    +-----------------+------+-----------------+-----------+---------------+---------------------------------------------------------------+
    | SR_POWRE_THRES  | 3    | power_trigger.v | 16        | 100           | Threshold for power trigger                                   |
    +-----------------+------+-----------------+-----------+---------------+---------------------------------------------------------------+
    | SR_POWER_WINDOW | 4    | power_trigger.v | 16        | 80            | Number of samples to wait before reset the trigger signal     |
    +-----------------+------+-----------------+-----------+---------------+---------------------------------------------------------------+
    | SR_SKIP_SAMPLE  | 5    | power_trigger.v | 32        | 5000000       | Number of samples to skip initially                           |
    +-----------------+------+-----------------+-----------+---------------+---------------------------------------------------------------+
    | SR_MIN_PLATEAU  | 6    | sync_short.v    | 32        | 100           | Minimum number of plateau samples to declare a short preamble |
    +-----------------+------+-----------------+-----------+---------------+---------------------------------------------------------------+
