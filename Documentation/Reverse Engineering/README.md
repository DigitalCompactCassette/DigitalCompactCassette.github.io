#Documentation/Reverse Engineering

In 1997, Waling Tiersma did a bit of work reverse-engineering the software that was available for the DCC-175 with PC-link cable. He got as far as writing a program that could wake up the recorder and start playback from the DOS command line.

He shared a lot of information and work-in-progress, and some of it is reproduced here.

## DISASSEM.ZIP
This is a complete dump of Waling's work on the DCC driver for DOS (there was a DOS program to make backups on DCC, and Waling figured that it would be easier to disassemble a DOS program than a Windows program to reverse-engineer the PC-link cable, so that's what he started with).

He used IDA (Interactive DisAssembler) 3.04 and 3.5. That program is [still available](https://www.hex-rays.com/index.shtml) and there is a [free evaluation version](https://www.hex-rays.com/products/ida/support/download.shtml) that may or may not be able to open the .IDA files in this ZIP file to continue where he left off.

Obviously we're not allowed to redistribute IDA so it's not part of this ZIP file.

## plaatjes.zip
A few pictures of the inside of the PC-link cable, for those who never had one (as far as we, the members of the DCC-L email discussion list, could determine back in the 1990s, probably less than 1000 of those cables were made). I think I made these by putting the cable on top of the scanner, that's why they look so bad. I may put some better pictures online later.

## README.md
The file you're reading.

## Shuttle EPST-1 docs.ZIP
Shuttle Technologies was the name of a company that produced interfaces to connect SCSI devices to (IEEE-1284) parallel ports. This zip file contains some information about the EPST-1 parallel-to-SCSI adapter. This may be totally irrelevant to DCC and the PC-link cable, but it might help to reverse-engineer the ECP and 4-bit data transfer protocols that the PC-link cable is capable of.

There are two .PRN files in the ZIP file which were apparently schematics produced with the "Print To File" feature of Orcad. If anyone knows how to reproduce the drawings, let us know!
 
