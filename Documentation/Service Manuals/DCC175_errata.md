# [Home](../..)/[Documentation](..)/[Service Manuals](.)/[DCC-175 Service Manual Errata](DCC175_errata.md)
The [DCC-175 Service Manual](./philips_dcc175_dcc170.pdf) has an error in the circuitry that connects to the PC-Link socket.

![Corrected schematic fragment](./philips_dcc175_correction.png)

On page 10, near the bottom, there are 8 buffers drawn, six of which are used to buffer the signals to the PC-link connector (which is on page 11, bottom right). The buffer for SBDAI (QA54-2/2, grid reference I10) is drawn the wrong way around, and a pin number is wrong: The output is pin 3, not 2, and data goes from the bottom to the top.

The diagram above shows the correct direction and pin number near the little red arrows.
