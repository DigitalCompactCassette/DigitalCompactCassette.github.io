# [Home](../../..)/[Software](../..)/[ROM Dumps](..)/[DDU-2113](.)
The DDU-2113 mechanism is used in the Philips 3rd generation recorders DCC-730 and DCC-951. It has 3 circuit boards:

 * The Read/Write board has the read-amplifier and write-amplifier chips that connect the Digital Board to the head assembly.
 * The Tape Drive Control Board controls the mechanism with an 8052 microcontroller (IC7500)
 * The Digital Board uses a NEC UPD78 microcontroller (IC7700) to perform high-level functions, based on commands from the front panel of a DCC deck
 
The same circuit boards are also used by the FW68 which uses a door instead of a tray for the DCC deck. The only difference is that pin 5 of IC7500 is pulled low with a solder jumper to indicate that the mechanism has a door (the documentation calls it a "flap", a weak translation of the Dutch word "klep"). 

More information can be found in the [Circuit Description](../../../Documentation/Service%20Manuals/philips_dcc951_circuit_description.pdf).

## [IC7500 Dump](IC7500_DDU-TDC.1.bin)
Provided by Alexander Alexandrov. This is the 8052 on the Deck Control board.

***Note: The DCC Museum also has a source code listing for the firmware in this microcontroller. It may eventually be added to the website.***
