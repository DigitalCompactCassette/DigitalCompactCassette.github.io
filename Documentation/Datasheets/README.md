# [Home](../..)/[Documentation](..)/[Datasheets](.)
This directory contains datasheets for a number of DCC-related chips by Philips. These were all found on the Internet.

For an overview of which recorders use which chips, download [this Excel spreadsheet](../General/chips.xls).

Various documentation about DCC from reliable sources such as Philips, mention that there were three generations of DCC recorders and chipsets. The only generation of chips that was really well documented (and for which datasheets are available online) is the third generation. The [DCC-951 Circuit Description](../Service%20Manuals/philips_dcc951_circuit_description.pdf) gives a good overview of how these IC's work together.

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

If you're new to the world of DCC, you will probably want to start by reading the datasheet for the SAA2023 or SAA3323 Drive Processor (DRP). They are essentially the same, except for the supply voltage (5V vs. 3.3V). DRPs were used in the last recorders that were produced, and combine a lot of functions that were done by multiple chips in earlier recorders. If you understand the functions of the DRP's, it's not too hard to understand the schematics of the later as well as the earlier recorders, even though earlier recorders use older chips for which there is no datasheet.  

## RDAMP: Read Amplifier: TDA1317, [TDA1380](.TDA1380.pdf) and [TDA1318](./TDA1318.pdf)
The Read Amplifier amplifies and filters the signals from the magneto-resistive DCC playback heads, and multiplexes the analog signals for further processing. It needs external signals to control the multiplexing. The TDA1318 is intended for 9 heads (the DCC-130 has two TDA1318's) and the TDA1380 has circuitry for 18 heads. We have no information about the TDA1317, which was used in the first and second generation recorders.

## DEQ: De-Equalizer: SAA2051 and [SAA2032](SAA2032.pdf)
The DEQ was used only in the DCC-130 to process the analog multiplexed input signal from the read amplifier. It worked together with the SAA2022 TFE. We have no information about the SAA2051 which was used in first and second generation recorders.

## ERCO: Error Correction: SAA2031
The ERCO chip was in charge of detecting and correcting errors from the incoming signal from the tape during playback, and formatted the signals that went to the tape during recording. We have no information about it.

## DDSP: Digital Drive Signal Processor: SAA2041
The DDSP controls the capstan motor based on the incoming data during playback, or runs it at a fixed speed for recording and analog cassette playback. We have no information about it.
 
## TFE: Tape Formatting and Error correction: [SAA2022](SAA2022.pdf)
The TFE is used in the DCC-130 only, to combine the functionality of the ERCO (Error Correction) and DDSP (Digital Drive Signal Processor) chips in the first and second generation recorders. It needs to work together with the SAA2032 De-Equalizer (DEQ) chip.

## DRP: Drive Processor: [SAA2023](./SAA2023.pdf) and [SAA3323](./SAA3323.pdf)
The DRP integrates the functionality of the DEQ (De-Equalizer), ERCO (Error Correction) and DDSP (Digital Drive Signal Processor) from the first and second generation recorders into a single chip. It takes care of all the conversion from multiplexed head signals to PASC and back, and generates timing signals for the capstan motor and the surrounding chips. The SAA2023 is used in the stationary 3rd generation recorders and the SAA3323 is used in the Marantz portables (DCC134, DCC170, DCC175). The only difference between the two chips appears to be that the SAA2023 uses a 5V power supply, whereas the SAA3323 uses a 3.3V power supply.

## SBC: Subband Codec: SAA2021
The SBC converts PCM to PASC (MPEG) subband data. It was used in first and second generation recorders. We have no information about this chip.

## SBF: Subband Filter: SAA2001
The SBF is used to synthesize PCM data from a PASC data stream. One of these was needed for each stereo channel. It was used in first and second generation recorders. We have no information about this chip.

## SFC: Stereo (or Subband) Filter and Codec: [SAA2002](./SAA2002.pdf) and [SAA2003](./SAA2003.pdf)
The SFC combines the functionality of the Subband Codec and Subband Filter in earlier recorders. It converts PCM baseband audio into PASC (MPEG) subband data, and vice versa. What it *can't* do is the lossy compression part of PASC, so during recording it needs help from an Adaptive Allocator and Scaler. The SAA2002 was used only in the DCC-130, whereas the SAA2003 was used in all the 3rd generation recorders.

## AAS (or ADAS): Adaptive Allocator and Scaler: SAA2011, [SAA2012](./SAA2012.pdf) and [SAA2013](./SAA2013.pdf)
The AAS is used during recording to apply the psycho-acoustic model of PASC to the subband data stream from the SFC, to determine how many bits should be allocated to each subband, and what the multiplication factor (scale) of each subband should be. The SAA2013 was used in all third generation recorders (together with the SAA2003 SFC), whereas the SAA2012, even though it appears to be more advanced, wasn't used in any recorders at all. There is no information about the SAA2011 which was used in the first and second generation recorders.

## DAC: Digital Analog Converter: [SAA7350](./SAA7350.pdf), [TDA1547](./TDA1547.pdf), SAA7321, SAA7323, [UPD63200 (Japanese)](UPD63200_jp.pdf), [TDA1313](TDA1313.pdf) and [TDA1305](./TDA1305T.pdf)
The DAC converts a PCM signal at 48kHz, 44.1kHz or 32kHz to analog. The SAA7350 can also provide timing signals to a TDA1547. It was used in many digital audio devices, not just DCC recorders. The TDA1313 was used in the DCC134. The TDA1305 is 18 bits and was used for the stationary 3rd generation recorders. The UPD63200 (18 bits) was used in the DCC130; unfortunately there's only a Japanese datasheet online for it as far as we could tell. We have no information about SAA7321 and SAA7323 which were used in second generation recorders.

## DF: Digital Filter: [SM5840](./SM5840FS.pdf) and SM5881
The SM5840 is an 8-times oversampling digital filter for digital audio, that works together with the SAA7350. We have no information about the SM5881 which was used in the DCC130 and DCC134.

## ADC: Analog Digital Converter: AK5326 and [SAA7366](./SAA7366T.pdf)
The SAA7366T is an 18 analog to digital converter used in 3rd generation recorders. We have no information about the AK5326 which was used in first and second generation recorders.

## ADC/DAC: Combined Analog-Digital and Digital-Analog converter: [TDA1309](./TDA1309H.pdf)
The TDA1309H was an 18-bit analog-to-digital and digital-to-analog converter that was used in the Marantz portable recorders (DCC170/DCC175).

## DAI/DAIO: Digital Audio Interface / Digital Audio Input/Output: [M51581](./M51581FP.pdf) and [TDA1315](./TDA1315H.pdf)
The DAI or DAIO converts the IEC958 (S/PDIF) signal from a coax or optical input to I2S (Inter-IC Sound) bit stream, and back. It also encodes and decodes SCMS bits in the IEC958 stream. The M51581 was used in first and second generation recorders. The TDA1315 supports 18 bit audio and was used in 3rd generation recorders.

## WRAMP: Write Amplifier: TDA1316, [TDA1319](./TDA1319.pdf) and [TDA1381](./TDA1381.pdf) 
The write amplifier is connected to the DCC recording heads. It demultiplexes the formatted digital stream with modulated data and uses it to control the current through the recording coils in the head. The TDA1319 support 9 heads, whereas the TDA1381 supports 18 heads. We have no information about the TDA1316 which was used in the first and second generation recorders.
