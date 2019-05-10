# [Home](../..)/[Documentation](..)/[General](.)
This directory contains general information about the DCC format. These documents were found on the World Wide Web.

## [Digital Compact Cassette (DCC) - Matsushita and Philips Develop New Standard](./Digital%20Compact%20Cassette%20(DCC)%20-%20Matsushita%20and%20Philips%20Develop%20New%20Standard.pdf)
This was downloaded from [www.cieri.net](http://www.cieri.net/Documenti/Documenti%20audio/Digital%20Compact%20Cassette%20(DCC)%20-%20Matsushita%20and%20Philips%20Develop%20New%20Standard.pdf). I found it via Google when I looked for "DCC tape frame".

The website that shares it, claims to have context information for most of its downloads but I can't find the document through the menus, let alone any accompanying text about where it originated (the website is in Italian and my Italian is not very good). It appears that this may have been a hand-out given to those that were present at a Matsushita announcement of the DCC format. It contains lots of interesting details that are not otherwise available to the public, such as bit rates of binary data streams, and the length and formatting of tape blocks and tape frames. This really helps when reading the datasheets of e.g. the Drive Processors where the reader is assumed to have this information.

## [Panasonic Technical Guide vol. 31: Auto DCC Technology](CQ-DC1.pdf)
The [web page](https://servlib.com/panasonic/car-audio/cq-dc1.html) where this document was downloaded, pretends that this is a service manual for the (rare) CQ-DC1 car stereo with DCC player. However, it appears to be a service bulletin of some sort, for Panasonic technicians who were interested in DCC technology.

The document describes the DCC mechanism inside the CQ-DC1 car stereo, but doesn't even offer complete schematics for it. But on the other hand, it has a fairly complete description of the DCC system, including PASC, tape formatting, description of the AUXINFO data (unfortunately not much information about SYSINFO), error correction, and a lot of information about the early Philips DCC chipset (for which there are no datasheets).

Thanks for Ralf "Dr. DCC" Porankiewicz at the DCC Museum for finding this!

## [I2S Bus Specification](I2SBUS.pdf)
The I2S (Inter IC Sound) bus is used to transfer digital audio between chips in DCC recorders (and other hardware). It's a simple protocol that defines how two channels of audio of up to 24 bits per sample can be transported over three lines: a clock line, a data line and a line that selects the left or right channel. This document describes the protocol.

## [DCC Chips Overview (Excel format)](Chips.xls)
A list of all the recorders for which I have [service manuals](../Service%20Manuals), and the chips that they use. Draw your own conclusions :-)

## [DCC900 Cursus Materiaal](DCC900CursusMateriaal.pdf)
Philips organized a course for repair technicians so they could learn how the new DCC900 worked and how they could fix it when it didn't work. It contains a lot of details about how PASC works, which aren't available elsewhere. The document is in Dutch; I will eventually publish an English translation. Thanks to Dr. DCC from the DCC museum for scanning this!

## [DCC Mastering](DCC%20Mastering.pdf)
Brochure from Philips Key Modules about how pre-recorded DCC's are mastered. Some interesting details about equipment that was used.

## [Tape Design (and some history)](Peter%20Doodson%20Tape%20Design.pdf)
Various documents shared with the DCC Museum by [Peter Doodson](http://www.doodson.co.uk/Peter.html), the designer of the CD Jewel Case and the DCC cassette. Including:


- A report of a presentation by Gijs Wirtz (Product Manager DCC at Philips) and Cor van Dijk (Managing Director at Polygram) about the need for a digital compact cassette, code named "Project Decor".
- A drawing of the DCC cassette with basic dimensions. 
- Requirements for the DCC cassette outer packaging, including proposals to put the DCC cassette in a CD Jewel Case.
- Meeting minutes from 1990 where it was decided to use a box with the same outer dimensions as the analog cassette. Also includes interesting tidbits about EMI and BMG "expressing great interest" in DCC text (ITTS), and about a settlement in a lawsuit that evidently made audio CD licenses twice as expensive as before.
- DCC double pack design drawings; these were never produced as far as we know.
- A document from from 1994 by Smulders Corporate and Marketing Communications BV, Helmond, The Netherlands, with what looks like the concept text for a press release about DCC design.
- Reproduction of an article about DCC design in Domus Magazine, January 1994.
- Reproduction of an article in a Dutch newspaper reporting that all prerecorded DCC cassettes in Japan were recalled just before DCC recorders were introduced (Dutch).
- Reproduction of a page of "Philips News" of September 28, 1992 reporting the opening of the DCC tape factory in Amersfoort, the Netherlands. But also has some bad news about Philips delisting their stocks at the Tokyo stock exchange and the expectation that Philips' net income of 1992 would be only half of 1991.
- Some concept art of various variations of designs for the DCC cassette.

Thank you, Peter!
