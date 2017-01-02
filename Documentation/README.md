#Documentation

In 1997, Waling Tiersma did a bit of work reverse-engineering the software that was available for the DCC-175 with PC-link cable. He got as far as writing a program that could wake up the recorder and start playback from the DOS command line.

He shared a lot of information and work-in-progress, and some of it is reproduced here.

## DCC170/DCC175 Service Manual.zip
The DCC-175 service manual consisted of the DCC-170 manual with a few dozen pages of "this is different about the DCC-175". Obviously, things such as the mechanical parts and instructions on how to put the recorder in service mode are the same between the 170 and 175, but the schematic diagram and circuit board designs are very different.

Waling Tiersma provided a paper copy of the service manual, and I scanned it at the highest resolution that my dad's scanner supported: 300dpi. The pages that were black and white were scanned in greyscale, but the pages with colors were scanned in color. Unfortunately there were a lot of "fold-out" pages that were bigger than A4 size, so those pages had to be scanned in parts. It's probably possible to use a stitching program to put them back together, but I wanted to leave the original files intact so that's what you get (except the first page which had Waling's home address written on it; I modified the file to remove the address).

### Known errata
On page 010.jpg, near the bottom, there are 8 buffers drawn, six of which are used to buffer the signals to the PC-link connector (which is on page 011.jpg, bottom right). The buffer for SBDAI (QA54-2/2, grid reference I10) is drawn the wrong way and a pin numbers is wrong: The output is pin 3, not 2 and data goes from the bottom to the top.

## DISASSEM.ZIP
This is a complete dump of Waling's work on the DCC driver for DOS (there was a DOS program to make backups on DCC, and Waling figured that it would be easier to disassemble a DOS program than a Windows program to reverse-engineer the PC-link cable, so that's what he started with).

He used IDA (Interactive DisAssembler) 3.04 and 3.5. That program is [still available](https://www.hex-rays.com/index.shtml) and there is a [free evaluation version](https://www.hex-rays.com/products/ida/support/download.shtml) that may or may not be able to open the .IDA files in this ZIP file to continue where he left off.

Obviously we're not allowed to redistribute IDA so it's not part of this ZIP file.

## plaatjes.zip
A few pictures of the inside of the PC-link cable, for those who never had one (as far as we, the members of the DCC-L email discussion list, could determine back in the 1990s, probably less than 1000 of those cables were made). I think I made these by putting the cable on top of the scanner, that's why they look so bad. I may put some better pictures online later.

## README.md
The file you're reading.

## SAA2003.PDF
The SAA2003 is the Stereo Filter and Codec (SFC) which takes care of compressing and decompressing the PASC data to/from PCM data. It looks like it may also be used to recover the clock signals (/L3REF, SBCL and SBWS) when the DCC-175 is recording from the PC, but this is not clear at the time of this writing.

## SAA3323.PDF
The SAA3323 is the Drive Processor which is in every DCC recorder of the second generation (the first generation had a different chip that did the same thing). The SAA3323 DRP and the microcontroller work together to make the DCC recorder work.

The PC-Link cable is connected to the microcontroller and the SAA3323. Unfortunately the manual assumes a lot of knowledge from the reader so it may be somewhat hard to read.

## Shuttle EPST-1 docs.ZIP
Shuttle Technologies was the name of a company that produced interfaces to connect SCSI devices to (IEEE-1284) parallel ports. This zip file contains some information about the EPST-1 parallel-to-SCSI adapter. This may be totally irrelevant to DCC and the PC-link cable, but it might help to reverse-engineer the ECP and 4-bit data transfer protocols that the PC-link cable is capable of.

There are two .PRN files in the ZIP file which were apparently schematics produced with the "Print To File" feature of Orcad. If anyone knows how to reproduce the drawings, let us know!
 
