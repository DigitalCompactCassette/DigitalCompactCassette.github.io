# [Home](../../..)/[Software](../..)/[ROM Dumps](..)/[ITTS Box](.)
This directory contains the ROM dump files from the [ITTS boxes at the DCC Museum](/Documentation/ITTSbox).

At this time we haven't analyzed the ROM dumps. When we do, more information will appear here. There are two microcontrollers in the system, both Intel 8032.

Judging from a glance at the circuit board, the EPROM and 8032 marked "DAI" are intended to extract the ITTS information from the C and U subchannels that are made available on the M51581. The first microcontroller probably also does an integrity check. It looks like an 8-bit D-flipflop is used to send the data to the second microcontroller. 

The second EPROM and 8032 do the work of interpreting the data and formatting it. It controls the Teletext chip to generate the pages of information, and used that chips's features to generate graphics, text color changes, double-wide and double-high characters etc. More information about the ITTS format is available in the [DCC System Description](/Documentation/General/Philips%20DCC%20System%20Description%20Draft.pdf) and the [ISO-61866](https://webstore.iec.ch/en/publication/6045) standard.  
 
* ["DAI V1.1"](./ITTS%20DAI%20V1.1.bin)
* [blank label](./ITTS%20blank%20label.bin)

The DCC Museum got a second ITTS decoder in 2021. The DAI EPROMs are identical between the two machines but the second machine's main EPROM is different from the EPROM with the blank label in the first machine. The second ITTS box seems to have a bit more debugging in it, and it appears that the code is older than the first machine: The first EPROM contains a string "25 June 1992 version 3.1" and the second EPROM contains "25 May 1992 version 2.3". This is an image of the main ROM of the second (older) machine:

* ["2220"](./ITTS29%202220.bin)
 