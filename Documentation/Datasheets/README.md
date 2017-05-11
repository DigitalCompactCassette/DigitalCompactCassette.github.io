# [Documentation](..)/[Datasheets](.)
This directory contains datasheets for a number of DCC-related chips by Philips. These were all found on the Internet.

Various documentation about DCC from reliable sources such as Philips, mention that there were three generations of DCC recorders and chipsets. The only generation of chips that was really well documented (and for which datasheets are available online) is the third generation.

To play a DCC tape, the player needs to:

- Amplify the signals from the 9 heads with a read amplifier. The read amplifier multiplexes the analog signal from the tape heads for further processing.
- Next, the multiplexed analog signal is demultiplexed and converted to digital. The tape data is demodulated (DCC uses 8-to-10 modulation) and errors are detected and corrected. This results in a PASC (MPEG-1 layer 1) data stream, which Philips calls "subband data". Also, the SYSINFO data is extracted which contains time codes and SCMS data. AUX data (which contains track markers and song information) is demodulated and extracted from the ninth track.
- The PASC data is decoded and filtered to generate an IEC958 (a.k.a. S/PDIF) PCM signal. In the documentation this is sometimes called "baseband data".
- The PCM signal is converted to a fixed-volume analog signal that can be used for an audio amplifier, and/or a variable analog signal for headphones.

When recording, the DCC recorder needs to:

- Optionally convert an analog signal to a digital PCM stream, unless a digital input is used
- Convert PCM digital data ("baseband data") to "filtered subband data". This is basically where the audio is separated into 32 frequency bands.
- To compress the filtered subband data into a 384kbps MPEG stream, the Adaptive Allocator and Scaler determines what should go into the stream, and what needs to be thrown away. This results in a PASC (MPEG-1 layer 1) stream at 384kbps
- The PASC stream is combined with SYSINFO data and modulated using 8-to-10 encoding, and multiplexed. The AUX data is also part of the multiplexed signal and may contain track markers. All 9 tracks can be recorded at the same time, or the 9th track can be recorded while the audio tracks are playing.
- The multiplexed signal is processed through the write amplifier and recorded on tracks 0-8 (or track 8 only, when recording track markers on existing tapes).

If you're new to the world of DCC, you will probably want to start by reading the datasheet for the SAA2023 or SAA3323 Drive Processor (DRP). They are essentially the same, except for the supply voltage (5V vs. 3.3V). DRPs were used in the last recorders that were produced, and perform a lot of functions that were done by multiple chips in earlier recorders. If you understand the functions of the DRP's, it's not too hard to understand the schematics of the earlier recorders, even though they use earlier generations of chips for which there is no datasheet.  

## [SAA2003 Stereo Filter and Codec (SFC)](./SAA2003.pdf)
The SAA2003 Stereo Filter and Codec (SFC) converts the PASC (MPEG) subband data into baseband PCM data, and vice versa. Basically, MPEG divides (filters) the audio signal into 32 frequency bands (hence "subbands") and this chip takes care of that conversion, in both directions. What it can't do is the lossy compression part of MPEG/PASC so during recording it needs help from an Adaptive Allocator and Scaler. The SAA2003 is the 18-bit version of the PASC codec, which was used in the latest produced recorders.

## [SAA2013 Adaptive Allocator and Scaler (AAS)](./SAA2013.pdf)
The SAA2013 Adaptive Allocator and Scaler (AAS) is used in the last generation of recorders to help the SFC compress the filtered recording stream into a bit stream with a bandwidth of 384 kilobits per second. In theory, if the recorder is recording a digital audio stream that's generated from a DCC player, the AAS has nothing to do because all the inaudible parts of the signal are already gone and the filtered stream from the SFC already has a low enough bit rate to fit on the tape.

## [SAA2023 Drive Processor (DRP)](./SAA2023.pdf)
The SAA2023 is the Drive Processor (DRP) which is used in the DCC730 and DCC951, and in the DCC822 car stereo(?). It takes care of all the conversion from multiplexed head signals to PASC and back, and generates timing signals for the capstan motor and the surrounding chips.

## [SAA3323 Drive Processor (DRP)](./SAA3323.pdf)
The SAA3323 is also a DRP, and it performs the same functions as the SAA2023, but it takes a 3.3V power supply instead of 5V, so it's used in the DCC134, DCC170 and DCC175 portable players and recorders.

## [SAA7366 Analog Digital Converter (ADC)](./SAA7366T.pdf)
The SAA7366T is a stereo Analog to Digital Converter (ADC) that generates an 18 bit digital PCM data stream.

## [TDA1305 Digital Analog Converter (DAC)](./TDA1305T.pdf)
The TDA1305T is a stereo Digital to Analog Converter (DAC)

## [TDA1309 Analog / Digital / Analog Converter (ADDA)](./TDA1309H.pdf)
The TDA1309H is a stereo Analog to Digital and Digital to Analog Converter (ADC/DAC).

## [TDA1315 Digital Audio Input/Output (DAIO)](./TDA1315H.pdf)
The TDA1315H is the Digital Audio Input Output Circuit (DAIO) that converts the IEC958 (S/PDIF) signal from a coax or optical input to I2S (Inter-IC Sound) bit stream, and back. It also encodes and decodes SCMS bits in the IEC958 stream.

## [TDA1318 Read Amplifier (9 heads)](./TDA1318.pdf)
The TDA1318H is a read amplifier that amplifies and filters the signals from the magneto-resistive DCC playback heads, and multiplexes the analog signals for further processing. It needs external signals to control the multiplexing. This read amplifier has 9 inputs and is intended for stationary recorders.

## [TDA1319 Write Amplifier (9 heads)](./TDA1319.pdf)
The TDA1319T is a write amplifier that's connected to the DCC recording heads. It demultiplexes the formatted digital stream with modulated data uses it to control the current through the nine recording coils in the head.

## [RDA1380 Read Amplifier (18 heads)](./TDA1380.pdf)
The TDA1380 is a read amplifier that amplifies and filters the signals from the magneto-resistive DCC playback heads, and multiplexes the analog signal for further processing. It needs external signals to control the multiplexing. As you may know, portable players have heads that are different from stationary players: portable heads have 18 MR channels whereas stationary recorders have a 9-channel head that gets rotated around for side B. This read amplifier has 18 inputs (9 for each side) and is intended for portable recorders.

## [TDA1381 Write Amplifier (18 heads)](./TDA1381.pdf)
The TDA1381 is a write amplifier that's used to generate the current for DCC recording heads. This particular write amplifier has 18 outputs (9 for each side) and is intended for portable recorders that don't have a rotating head.
