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
of a new bit in the stream. At that point, all the code needs to know to
decode the bit is:
* Is the edge counter odd or even now?
* Was the edge counter odd at the beginning of the previous bit?

If the oddness of the counter changed from odd to even or from even to
odd, there must have been only one flank in the signal, so the encoded bit
must have been a 0. If the oddness stayed the same (even to even, or odd
to odd), it means the encoded bit must have been a 1.

         +-+     +-+     +-+ +-+ +-+     +-+ +-+ +-+         +-+ +-+ +-+
XORIN    | |     | |     | | | | | |     | | | | | |         | | | | | |
         + +-----+ +-----+ +-+ +-+ +-----+ +-+ +-+ +---------+ +-+ +-+ +
 
Propeller PPPPPW  PPPPPW  PPPPPW  PPPPPW  PPPPPW  PPPPPW      PPPPPW  PP
 
PHSx      1       2       3   4   5       6   7   8           9   10  11

Oddness   ^ odd   ^ even  ^ odd   ^ odd   ^ even  ^ even      ^ odd
               
This method is amazingly reliable and very jitter-proof. It's much easier
and reliable to let a timer count edges (while the code does an exactly
predictable amount of work to make sure that it samples the timer count at
the exact right times) than it would be to write code to sample the input
to see if a second pulse arrived in the middle of a bit.

Another advantage of this method is that it's not necessary to reset the
timer/counter at the beginning of each bit. We only need to keep track of
whether the oddness changed between two bit times,

We also don't need to reset the counter at any other time. In the event
that the code starts at the wrong time and executes a WAITPxx when the
SECOND pulse of a 1-bit comes in, it will straighten itself out very
quickly (during the first 0-bit). Then when the code encounters a
preamble, it will of course post the wrong data but the next subframe will
be decoded correctly.

         +-+     +-+     +-+ +-+ +-+     +-+ +-+ +-+         +-+ +-+ +-+
XORIN    | |     | |     | | | | | |     | | | | | |         | | | | | |
         + +-----+ +-----+ +-+ +-+ +-----+ +-+ +-+ +---------+ +-+ +-+ +

Propeller             PPPPPW  PPPPPW      PPPPPW  PPPPPW      PPPPPW  PP
                      ^start  ^outofsync  ^back in sync!

So now we have an easy way to recover the bit clock (just execute a WAITPxx
followed by 5 instructions) and we have binary data from the input stream.
The next step is to figure out where one subframe ends and the next one
begins. This needs to go in a separate cog because by now, the biphase
decoder cog is just about as busy as it can be.

Each subframe starts with a preamble which deliberately violates the
biphase encoding. There are three kinds of preambles:

             +-----------+   +---+           +---
B-Preamble:  |           |   |   |           |
(S/PDIF)    -+           +---+   +-----------+

            -+           +---+   +-----------+
or:          |           |   |   |           |
             +-----------+   +---+           +---

             +-+         +-+ +-+ +-+         +-+
XORIN:       | |         | | | | | |         | |
            -+ +---------+ +-+ +-+ +---------+ +-         




             +-----------+           +---+   +---
M-Preamble:  |           |           |   |   |
(S/PDIF)    -+           +-----------+   +---+

            -+           +-----------+   +---+
or:          |           |           |   |   |
             +-----------+           +---+   +---

             +-+         +-+         +-+ +-+ +-+
XORIN:       | |         | |         | | | | | |
            -+ +---------+ +---------+ +-+ +-+ +-         




             +-----------+       +---+       +---
W-Preamble:  |           |       |   |       |
(S/PDIF)    -+           +-------+   +-------+

            -+           +-------+   +-------+
or:          |           |       |   |       |
             +-----------+       +---+       +---

             +-+         +-+     +-+ +-+     +-+
XORIN:       | |         | |     | | | |     | |
            -+ +---------+ +-----+ +-+ +-----+ +-         




                        +-----------------+-+
PRADET:                 |                 | |
            ------------+                 +-+----

Preamble cog
events (see             ^A       ^B  ^C   ^D^E
below)
            

* The B-Preamble starts a block of 192 frames (384 subframes). These are
  needed to decode the subchannel data. The first subframe in a block is
  always for the left channel.
* The M-Preamble indicates the start of a subframe for the left channel
  that's not at the beginning of a block.
* The W-Preamble indicates the start of a subframe for the right channel.

The preamble detector uses two timers: One timer counts positive edges on
the XORIN input (just like the biphase bit decoder cog), and the other is
set up as a Numerically Controlled Oscillator (NCO). We configure the NCO
so that it basically counts Propeller clock cycles from the time we reset
it, The most significant bit (msb) of the NCO counter is connected to the
PRADET (PReAmble DETect) output pin. That pin is used by other cogs to
synchronize to the beginning of a subframe.

The main loop of the preamble detector cog keeps waiting for an incoming
pulse on XORIN (with the usual 5 instructions plus WAITPxx so it doesn't
wait for extra pulses for 1-bits). As soon as execution continues after
the WAITPxx, it stores the current flank count and adds 2 to it (we'll
get back to that in a minute). Then it checks PRADET and resets the NCO.

So when there is no preamble on the input, the NCO keeps getting reset,
and the PRADET stays low. But when the first long pulse of a preamble
comes in (event ^A) in the diagram above), the preamble detector doesn't
reset the counter and falls through to the second part of the decoding.

The code executes exactly 5 instructions plus a WAITPxx. That brings the
time to point ^B for preambles B or W, or to point ^C for an M preamble:
after all, it waits a minimum of 2*t but after that, the WAITPxx
instruction continues on the next pulse.

After the WAITPxx, the code is at event ^D (for a B or M preamble) or at
event ^E (for a W preamble). Just like during normal bits, it stores the
NCO timer value and resets the NCO so that PRADET goes low. So this may
happen at two different times depending on the preamble type, but it
always happens just before the pulse that indicates the end of the
preamble and the start of the first significant data bit. The biphase
decoder waits for this to synchronize with the data bits in the next
subframe.

So now, the preamble decoder needs to know two things to recognize which
preamble is coming in:
* How many pulses have come in? If there were 2 pulses during a minimum
  of the 2*t duration, we know the preamble must be a B preamble. As I
  mentioned, the code stores the previous count plus 2, so that at this
  point, it can just compare the stored number with the actual count.
* How much time elapsed between the last reset of the NCO and just after
  the last WAITPxx inside the preamble? The previous NCO reset happened
  at the beginning of the preamble when we didn't know that it was a
  preamble yet. If the elapsed time since then is more than 5*t, this
  must mean that an M preamble is coming in because it has a single long
  pulse in the middle. Otherwise it must be a B or W preamble because
  they have a pulse that comes in 1*t earlier.

The code combines those two things, and sets the BLKDET (BLocK DETect)
output pin high or low depending on whether this is a B preamble. It
also sets the RCHAN (Right CHANnel) output high if this is a W preamble,
and low if it isn't.

There's a little bit of extra processing involved in deciding whether to
set the BLKDET and RCHAN outputs high or low, but that's okay. Any cog
that wants to know what kind of subframe this is, won't need to know it
until the end of the subframe when the next preamble is detected.
  
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
instructions) left over for other processing. I may implement this in the
Biphase cog in the future. 

(*) I just realized that 48kHz may be a little too fast for the current
code: the time-critical loops consist of 5 regular instructions (4 clocks)
plus one WAITPxx instruction (minimum 6 clocks each) which is only 0.5ns
less than 2*t at 48kHz. I would have liked at least one clock cycle
(12.5ns) to spare but oh well. It's fairly easy to overclock a Propeller
and fix the problem, you'd just have to modify the timing constant for
the preamble detection. I may unroll the loops to make the code execute
faster so 48kHz will work with the common Propeller configuration, but
unrolling the loops (i.e. copy-pasting the instructions and removing the
JMP insturctions) makes editing a pain, so I won't do that at least until
I feel that I've gotten everything there is to get from the current code.
         
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
                        mov     phsb, #0                ' Reset Timer B at exact same time as usual
                                                        ' ... but reset it to 0 so compensate for longer
                                                        '     time spent in the next few instructions
                                                        
              if_z      cmp     dpzero, #1 wc           ' Set C if Z=1

                        ' At this point:
                        ' * Z=1 indicates B preamble
                        ' * C=0 indicates W preamble
                        ' * C=1 and Z=0 indicate M preamble
                        
                        ' Set the channel block detect and channel outputs.
                        ' This happens while the mew subframe is already on its way,
                        ' but these signals won't be needed by other cogs until
                        ' they get to the end of the current subframe anyway.
                        muxz    outa, dpmask_BLKDET                                              
                        muxnc   outa, dpmask_RCHAN

                        ' NOTE: This would be a good time to read an updated value
                        ' of the timing constant from the hub (to make it possible to
                        ' run some sort of smart code that statistically determines what
                        ' it should be or to let the user influence it manually),
                        ' but if we replace it with the wrong value, we may never
                        ' get back here. I'll have to think about how to solve this
                        ' and also about how to detect when the input goes dead, which
                        ' gets everyone stuck in WAITPxx instructions.
                        
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