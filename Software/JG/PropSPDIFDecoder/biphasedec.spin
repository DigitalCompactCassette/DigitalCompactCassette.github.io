''***************************************************************************
''* Bi-phase Decoder for S/PDIF
''* Copyright (C) 2017 Jac Goudsmit
''*
''* TERMS OF USE: MIT License. See bottom of file.                                                            
''***************************************************************************
''
{{
Schematic:
 
 
          3.3V                          
        10k|                         
           Z                         
      100n | |\       100R    |\          Inverters  are 74HC04
o)--+--||--o-| >o--+--|\|--o--| >o--+     NAND ports are 74HC00
    |      | |/    |       |  |/    |
    Z      Z  A    |       =   B    |
 75R|   10k|       |   100p|        |
   gnd    gnd      |      gnd       |
                   |                |
                   |                |    ___
                   |                +---|   \
                   |                |   |    )o--+
                   +--------------------|___/    |
                   |                |            |
                   |                |            |   ___
                 -----            -----          +--|   \
                 \   /            \   /             |    )o---> XORIN
                  \ /              \ /           +--|___/
                   o                o            |
                   |                |    ___     |
                   |                +---|   \    |
                   |                    |    )o--+
                   +--------------------|___/
 
 
(NOTE: it's probably possible to replace the two TTL chips by a single
74HC86. I didn't test this at the time of this writing, so that is left
as an exercise to the reader :-)
 
The input is connected to inverter A via a small circuit that provides the
correct input impedance, a capacitor that decouples the DC, and a voltage
divider that pulls the voltage to the center of inverter A's sensitivity
range. Inverter A amplifies the signal from 0.5Vpp to full CMOS digital
(and inverts it) so it's basically a 1-bit A/D converter.
 
The output of inverter A is fed into inverter B via an RC network,
which act as a delay (in addition to the propagation delay of
inverter B).
 
The rest of the circuit forms an equivalence circuit (i.e. an inverted
XOR port, the inversion compensates for the inverted output signal of
inverter B): As long as the input signal doesn't change, the output of
inverter B is always the inverse of channel A and the XORIN output is
LOW. But when a positive or negative edge appears at the input, port
B takes slightly longer to change polarity than port A, so for a short
time, the outputs of ports A and B are equal and XORIN goes low during
that time, as illustrated below: 
 
         +-------+       +---+   +-------+   +---+           +---+   +--
A out    |   0   |   0   |   1   |   0   |   1   |     P     |   1   |
         +       +-------+   +---+       +---+   +-----------+   +---+
 
         --+       +-------+   +---+       +---+   +-----------+   +---+
B out      |   0   |   0   |   1   |   0   |   1   |     P     |   1   |
           +-------+       +---+   +-------+   +---+           +---+   +
            
         +-+     +-+     +-+ +-+ +-+     +-+ +-+ +-+         +-+ +-+ +-+
XORIN    | |     | |     | | | | | |     | | | | | |         | | | | | |
         + +-----+ +-----+ +-+ +-+ +-----+ +-+ +-+ +---------+ +-+ +-+ +
 
The R/C values of the delay circuit are not very critical as long as the
delay time is longer than one Propeller clock pulse (12.5ns) and shorter
than the time it takes to execute one instruction (4 clock cycles i.e.
50ns). According to my oscilloscope, the 100 Ohm, 100 pF combination
generates pulses on XORIN that are about 30ns wide so that's perfect.
There should be no need to adjust any of the resistors, and it's not
necessary to have an oscilloscope or logic analyzer to use the circuit. 
 
I noticed there is a bit of jitter on the width of the positive pulses
on XORIN. This should not be a problem because the code only waits for
the positive edge only.
 
The project supports stereo PCM data between 32kHz and 48kHz sample
frequency (Fs), stereo (only)(*). There are 32 bits in each subframe, and two
subframes in each frame (one for each channel) so the rate at which the
bits are encoded is between 2.048 and 3.072 MHz.
 
The shortest time period that we have to measure (let's call it "t")
is the time that the input signal stays at the same level during the
transmission of a "1" bit. This corresponds to half the time of one
encoded bit, and conversely the duration of one encoded bit is 2*t.
 
Here's an overview of some timing values.      
 
+--------+-----------+-------+-------+-------+--------+--------+--------+
| Sample | Bit rate  | t     | 2*t   | 3*t   | 1*t    | 2*t    | 3*t    |
| Freq.  | (64 * Fs) | (ns)  | (ns)  | (ns)  | (clks) | (clks) | (clks) |
+========+===========+=======+=======+=======+========+========+========|
| 48,000 | 3,072,000 | 162.8 | 325.5 | 488.3 | 13.0(*)| 26.0(*)| 39.1   |
| 44,100 | 2,822,000 | 177.2 | 354.4 | 531.5 | 14.2   | 28.4   | 42.5   |
| 32,000 | 2,048,000 | 244.1 | 488.3 | 732.4 | 19.5   | 39.1   | 58.6   |
+--------+-----------+-------+-------+-------+--------+--------+--------+

With most Propeller instructions taking 4 cycles of 12.5ns each, the
software has about 6 instructions time to decode and process each bit in
the incoming data stream. We use this fact to our advantage: all
timing-critical loops have a single WAITPxx instruction to synchronize
with the XORIN input, and exactly 5 additional instructions to do their
processing. That way, processing an incoming bit always takes a minimum
of about 325ns: the WAITPxx instruction takes at least 6 cycles and the
other 5 instructions take 4 cycles each.

If the data stream is slower, the WAITPxx instructions will ensure that
the Propeller stays in synch with the input signal. In other words, the
Propeller stays busy processing stuff just short enough to be able to wait
for the next pulse on XORIN.

This is illustrated in the diagram below: The letters "P" indicate the
execution of an instruction that processes the data, and the letters "W"
indicate when a WAITPxx instruction tells the Propeller to wait until
the next positive edge of the XORIN input. The minimum of 6 instructions
processing time per input cycle effectively recovers the clock on the
input signal.

The next step is to extract the data from the input stream. To do this,
we program a timer to count positive edges on the XORIN input. Whenever
execution passes a WAITPxx instruction, we know that we're at the beginning
of a new encoded bit. Since the beginning of the previous bit, edge counter
should have been increased with either a value of one (if the S/PDIF input
only changed once, for a "0" bit), or two (if the S/PDIF input changed
twice, for a "1" bit). The most efficient way to do this is to test whether
the edge counter's value is odd or even, and whether the "oddness" changed
since the beginning of the last bit. If the last count was odd and the
count changed to even during the time of one bit, there must have been only
one transition so the incoming bit was 0. The same is true when the count
changes from even to odd. If the count was odd and stayed odd, or if the
count was even and stayed even, we know that we must have gotten a 1 bit.
The next diagram illustrates this too: As you can see, the oddness changes
when there is a 0-bit, but stays the same when there is a 1-bit.

         +-+     +-+     +-+ +-+ +-+     +-+ +-+ +-+         +-+ +-+ +-+
XORIN    | |     | |     | | | | | |     | | | | | |         | | | | | |
         + +-----+ +-----+ +-+ +-+ +-----+ +-+ +-+ +---------+ +-+ +-+ +
 
Propeller PPPPPW  PPPPPW  PPPPPW  PPPPPW  PPPPPW  PPPPPW      PPPPPW  PP
 
PHSx      1       2       3   4   5       6   7   8           9   10  11
               
This method is amazingly reliable and very jitter-proof. It's much easier
and reliable to count edges than it would be to sample the input to see
if a second pulse arrived in the middle of a bit. The fact that we
only have to check for even or odd numbers (and that there are always an
even number of edges in each subframe, because the parity is always even),  
also makes it unnecessary to reset the edge counter, so there is no race
condition between the reset and a flank that comes in right about the same
time. 

So now we have an easy way to recover the bit clock (just execute a WAITPxx
followed by 5 instructions) and we have binary data from the input stream.
The next step is to figure out where one subframe ends and the next one
begins. This needs to go in a separate cog because the biphase decoder
cog is just about as busy as it can be.

Each subframe starts with a preamble which deliberately violates the
biphase encoding. There are three kinds of preambles:

* B-Preamble: 3t + 1t + 1t + 3t (11101000 or 00010111): This starts a block
  of 192 frames (384 subframes). These are needed to decode the subchannel
  data. This block is always for the left channel.
* M-Preamble: 3t + 3t + 1t + 1t (11100010 or 00011101): This starts a
  subframe for the left channel that's not the first subframe of a block.
* W-Preamble: 3t + 2t + 1t + 2t (11100100 or 00011011): This starts a
  subframe for the right channel.

The preamble detector uses two timers: One timer counts positive edges on
the XORIN input, and the other is a Numerically Controlled Oscillator. We
configure the NCO with a FRQx of 1, so it basically counts Propeller clock
cycles from the time we reset it. The Most Significant Bit (msb) of the
counter is connected to an output pin, in this case the PRADET pin (which
stands for PReAmble DETect).

The main loop of the preamble detector cog keeps waiting for an incoming
pulse on XORIN (with the usual 5 instructions plus WAITPxx so it doesn't
wait for extra pulses for 1-bits). As soon as execution continues after
the WAITPxx, it stores the current flank count and adds 2 to it (we'll
get back to that in a minute). Then it checks if the PRADET pin is high,
indicating that this was the end of a preamble's first pulse which is
always 3t. If this was not the end of a preamble's first pulse, the
preamble detector cog resets the NCO and waits for the next pulse that
occurs between two bits.

When a 3t pulse (or longer) is detected, the preamble detector doesn't
reset the timer (so the PRADET output stays HIGH for a while), but it
falls out of the loop at the time where it would normally jump back.
Then it waits for the following flank, but because this is (again) 5
instructions and a WAITPxx later than the previous WAITPxx, it can
determine what kind of preamble is coming in:
* If the flank counter is now two counts higher than just after the
  previous WAITPxx, it means that two 1t pulses came in so this must
  be a B-preamble (3t + _1t + 1t_ + 3t). Otherwise it must be an M or W
  preamble.
* The NCO count is now compared to a fixed value which pretty much means
  that the elapsed time since the first reset (at the beginning of the
  first 3t period is now more than 5t. If it is higher, the period
  between the last two WAITPxx must have been 3t and this must be an M
  preamble (3t + _3t_ + 1t + 1t). If not (and the elapsed time is shorter)
  this must be a W preamble (3t + _2t_ + 1t + 2t).

The BLKDET output is updated depending on whether this was a B block, and
the RCHAN output is updated depending on whether this was a W block. Then
the cog jumps back to the main loop again.

Another cog can recover the data from the S/PDIF input by doing the
following:
1. Wait for XORIN to go high
2. Wait for 2 (3?) more instructions (or do something else useful)
3. Read the binary bit on the BINDAT output and rotate it into the result
   from the bottom
4. Test if PRADET is HIGH. If not, go to step 1.
5. The result should have 28 significant bits. Shift the result left by 4
   bits, optionally rotating the BLKDET and RCHAN pins in. Then store the
   result in the hub.
6. Wait for PRADET low and go to step 1.
      
The time available for steps 4 to 6 (inclusive) is 4t (651.2ns worst case
at 48kHz). The worst-case timing for a WRLONG is 23 cycles (287.5ns) so if
you want to write the data to the hub, you have 463.7ns (about 9
instructions) to get it done. I may implement this in the Biphase cog in
the future. 

(*) I just realized that 48kHz may be a little too fast for the current
code: the time-critical loops consist of 5 regular instructions (4 clocks)
plus one WAITPxx instruction (minimum 6 clocks each) which is exactly the
minimum time that's available. 
         
}}

OBJ
  hw:           "hardware"      ' Pin assignments and other global constants

VAR
  long  pradet_delay            ' Number of Propeller clocks in a preamble         
                                
PUB biphasedec(par_delay)
'' par_delay (long): Number of Propeller clocks in a preamble

  pradet_delay := par_delay
  
  cognew(@decodebiphase, 0)
  cognew(@detectpreamble, @pradet_delay)

  
DAT

                        org     0
decodebiphase
                        ' Set up I/O
                        mov     dira, outputmask                        
                        mov     outa, #0

                        ' Set up timer A, used to count pulses on XORIN
                        mov     ctra, ctraval
                        mov     frqa, frqaval
                        mov     phsa, reseta

evenloop
                        waitpne zero, mask_XORIN        ' Flank detected
                        test    one, phsa wc            ' C=1 if odd number of total flanks
                        muxnc   outa, mask_BINDAT       ' We started even, so odd=0

                        test    mask_PRADET, ina wz     ' Z=0 if preamble detected
              if_nz     jmp     #preamble                    

                        
              if_nc     jmp     #evenloop               ' Go to even loop if total still even
              
oddloop
                        waitpne zero, mask_XORIN        ' Flank detected
                        test    one, phsa wc            ' C=1 if odd number of total flanks
                        muxc    outa, mask_BINDAT       ' We started odd, so odd=1

              if_nc     jmp     #evenloop
                        jmp     #oddloop                                  

preamble                andn    outa, mask_BINDAT       ' Listen for input from preamble detector
                        waitpeq zero, mask_PRADET       ' Wait until end of preamble
                        mov     phsa, #0                ' Always start even (shouldn't be needed)
                        jmp     #evenloop                             
                        
                                      

ctraval                 long    (%01010 << 26) | hw#pin_XORIN ' Count pos. edges on XORIN                   
frqaval                 long    1
reseta                  long    0

zero                    long    0
one                     long    1

data                    long    0

outputmask              long    hw#mask_BINDAT
mask_XORIN              long    hw#mask_XORIN
mask_PRADET             long    hw#mask_PRADET
mask_BINDAT             long    hw#mask_BINDAT

                        fit

DAT

                        org 0
detectpreamble
                        rdlong  dpcount, par
                        sub     dpresetb, dpcount
                        add     dpdetectm, dpcount
                        
                        ' Set up I/O
                        mov     dira, dpoutputmask                        
                        mov     outa, #0

                        ' Set up timer A, used to count pulses on XORIN
                        mov     ctra, dpctraval
                        mov     frqa, dpfrqaval
                        mov     phsa, dpreseta
                        
                        ' Set up timer B, used for preamble detection
                        mov     ctrb, dpctrbval
                        mov     frqb, dpfrqbval
                        mov     phsb, dpresetb

dploop
                        waitpne dpzero, dpmask_XORIN
                        mov     dpcount, phsa           ' Store flank count
                        test    dpmask_PRADET, ina wz   ' Z=0 if preamble                        
              if_z      mov     phsb, dpresetb          ' Reset timer B, 8 cycles too late

                        add     dpcount, #2             ' Expect two flanks for a B preamble, one otherwise                        
              if_z      jmp     #dploop

                        ' Preamble detected.                        
                        waitpne dpzero, dpmask_XORIN
                        cmp     dpcount, phsa wz        ' Z=1 C=0 for B preamble, Z=0 M or W preamble
                        cmp     dpdetectm, phsb wc      ' C=1 for M preamble, C=0 B or W preamble
                        mov     phsb, dpresetb2         ' Reset Timer B at exact same time as usual
              if_z      cmp     dpzero, #1 wc           ' Set C if Z=1

                        ' At this point:
                        ' * B-preamble signified by Z=1 C=1
                        ' * M-preamble signified by Z=0 C=1
                        ' * W-preamble signified by Z=0 C=0
                        ' Also:
                        ' * Left  channel signified by C=1
                        ' * Right channel signified by C=0
                        '
                        ' Set the channel block detect and channel outputs.
                        ' This happens pretty late into the subframe, but these signals
                        ' won't be needed until we're ready to process the data from
                        ' the current frame anyway
                        muxz    outa, dpmask_BLKDET                                              
                        muxnc   outa, dpmask_RCHAN

                        ' NOTE: we end this loop late. That's fine; there won't be another
                        ' preamble any time soon and timer B won't expire because we set
                        ' PHSB to a special value.
                        jmp     #dploop                        
                        
                        
dpctraval               long    (%01010 << 26) | hw#pin_XORIN ' Count pos. edges on XORIN                   
dpfrqaval               long    1
dpreseta                long    0

dpctrbval               long    (%00100 << 26) | hw#pin_PRADET
dpfrqbval               long    1
dpresetb                long    $8000_0000 + 8          ' Subtract 3*t cycles from this. "+8" compensates for resetting 2 instructions late
dpresetb2               long    0                       

dpcount                 long    0

dpzero                  long    0
dpdetectm               long    $8000_0000              ' Add 3*t cycles to this

dpoutputmask            long    hw#mask_PRADET | hw#mask_BLKDET | hw#mask_RCHAN
dpmask_XORIN            long    hw#mask_XORIN
dpmask_PRADET           long    hw#mask_PRADET
dpmask_BLKDET           long    hw#mask_BLKDET
dpmask_RCHAN            long    hw#mask_RCHAN        

                        fit
                                                
CON     
''***************************************************************************
''* MIT LICENSE
''*
''* Permission is hereby granted, free of charge, to any person obtaining a
''* copy of this software and associated documentation files (the
''* "Software"), to deal in the Software without restriction, including
''* without limitation the rights to use, copy, modify, merge, publish,
''* distribute, sublicense, and/or sell copies of the Software, and to permit
''* persons to whom the Software is furnished to do so, subject to the
''* following conditions:
''*
''* The above copyright notice and this permission notice shall be included
''* in all copies or substantial portions of the Software.
''*
''* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
''* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
''* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
''* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
''* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
''* OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
''* THE USE OR OTHER DEALINGS IN THE SOFTWARE.
''***************************************************************************
