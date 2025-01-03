# [Home](../..)/[Documentation](..)/[ITTSbox](.)
If you've looked closely at any prerecorded DCC cassettes, you may have noticed that it mentions "TEXT MODE" or something similar.

![Mention of TEXT MODE on a liner of a prerecorded DCC](./0%20liner.jpg)

No DCC recorders were ever produced that had a video output to display the DCC text information, but Philips developed a DCC Video Box to decode the information from the S/PDIF output, and a small number of prototypes was produced by a contractor in England. Tape mastering facilities could use this device to verify that they had encoded the tapes correctly.

The [DCC Museum](http://dccmuseum.com) has one of these devices. There's a demo video [here](https://youtu.be/c4D_DNBCdAA). The pictures on this webpage were taken from that particular device, and the binary files were dumped from the ROMs in this machine.

The DCC Video Box box uses the digital output of a DCC recorder, and the information that it shows on the screen is encoded in the subchannels that are output by the DCC recorder. There is apparently a certain amount of static data (such as song titles and timing information) which is always generated by the recorder, even when the tape is stopped. But there is also a stream of data that gets updated in real time, for lyrics (in multiple languages!) and some animation.

The S/PDIF standard is covered by international standard IEC-60958. Annex M of part 3 of that standard describes how Interactive Text Transmission Services (ITTS) is encoded in the digital audio stream, but there is no information about how ITTS information is formatted.

The IEC-61866 standard covers ITTS, but unlike IEC-60958 (which was published by the Indian standards committee), IEC-61866 is not available for free download at this time. Also, it may not be complete: [this purchase page](https://reference.globalspec.com/standard/3887235/iec-61866-1997-audiovisual-systems-interactive-text-transmission-system-itts) says the document "Defines the higher layers of ITTS, i.e. those system characteristics which are independent of the recording or interconnection medium".   
 
**The ITTS box that's in the posession of the DCC Museum only works on first and second generation recorders**. On third-generation recorders (DCC-730, DCC-951, and the portable players), there is either no ITTS information on the S/PDIF digital output, or it cannot be decoded by this particular ITTS box.
 
## Pictures

![Front Panel](./1%20front.jpg)

![Rear Panel](./2%20rear.jpg)

![Main Board, top](./3%20main%20top.jpg)

![Main Board, top, socketed chips removed](./4%20main%20top%20chips%20removed.jpg)

![Main Board, top, annotated](./5%20main%20top%20annotated.jpg)

![Main Board, bottom](./6%20main%20bottom.jpg)

![Main Board, bottom, annotated](./7%20main%20bottom%20annotated.jpg)

![Front Panel Board, top](./8%20front%20top.jpg)

![Front Panel Board, bottom](./9%20front%20bottom.jpg)

## Datasheets
The most important chips are:

* [M51581FP Digital Audio Interface](./M51581FP.pdf)
* [SAA5260P/E Teletext/VIP Decoder](./SAA5260PE.pdf)
* [SAA1101 Universal Sync Generator](./SAA1101.pdf)
* [MC1377P RGB to NTSC/PAL converter](./MC1377P.pdf)

## [ROM dumps](/Software/ROM/ITTSbox)
Click on the title of this paragraph to navigate to the directory with ROM dumps from the ITTS box.
