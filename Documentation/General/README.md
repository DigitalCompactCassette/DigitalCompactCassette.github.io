# [Home](../..)/[Documentation](..)/[General](.)
This directory contains general information about the DCC format. These documents were found on the World Wide Web.

## [Digital Compact Cassette (DCC) - Matsushita and Philips Develop New Standard](./Digital%20Compact%20Cassette%20(DCC)%20-%20Matsushita%20and%20Philips%20Develop%20New%20Standard.pdf)
This was downloaded from [www.cieri.net](http://www.cieri.net/Documenti/Documenti%20audio/Digital%20Compact%20Cassette%20(DCC)%20-%20Matsushita%20and%20Philips%20Develop%20New%20Standard.pdf). I found it via Google when I looked for "DCC tape frame".

The website that shares it, claims to have context information for most of its downloads but I can't find the document through the menus, let alone any accompanying text about where it originated (the website is in Italian and my Italian is not very good). It appears that this may have been a hand-out given to those that were present at a Matsushita announcement of the DCC format. It contains lots of interesting details that are not otherwise available to the public, such as bit rates of binary data streams, and the length and formatting of tape blocks and tape frames. This really helps when reading the datasheets of e.g. the Drive Processors where the reader is assumed to have this information.

## [I2S Bus Specification](I2SBUS.pdf)
The I2S (Inter IC Sound) bus is used to transfer digital audio between chips in DCC recorders (and other hardware). It's a simple protocol that defines how two channels of audio of up to 24 bits per sample can be transported over three lines: a clock line, a data line and a line that selects the left or right channel. This document describes the protocol.

## [DCC Chips Overview (Excel format)](Chips.xls)
A list of all the recorders for which I have [service manuals](../Service%20Manuals), and the chips that they use. Draw your own conclusions :-)

## [DCC900 Cursus Materiaal](DCC900CursusMateriaal.pdf)
Philips organized a course for repair technicians so they could learn how the new DCC900 worked and how they could fix it when it didn't work. It contains a lot of details about how PASC works, which aren't available elsewhere. The document is in Dutch; I will eventually publish an English translation. Thanks to Dr. DCC from the DCC museum for scanning this!

## [DCC Mastering](DCC%20Mastering.pdf)
Brochure from Philips Key Modules about how pre-recorded DCC's are mastered. Some interesting details about equipment that was used.