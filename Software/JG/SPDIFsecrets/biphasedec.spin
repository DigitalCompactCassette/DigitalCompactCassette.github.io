''***************************************************************************
''* Bi-phase Decoder for S/PDIF
''* Copyright (C) 2017 Jac Goudsmit
''*
''* TERMS OF USE: MIT License. See bottom of file.                                                            
''***************************************************************************
''

CON

  #0

  pin_SPDIN                     ' SPDIF in
  pin_SPDDEL                    ' SPDIF delayed and inverted
  pin_SPDDEL2                   ' SPDIF double delayed
  pin_XORIN                     ' XORed SPDIF input (SPDIN == SPDDEL)
  
  pin_4                         
  pin_5
  pin_6
  pin_7

  pin_8
  pin_9
  pin_10
  pin_11

  pin_12
  pin_13
  pin_14
  pin_15

  pin_RECCLK                    ' Recovered clock
  pin_PRADET                    ' Preamble Detect
  pin_DEBUG                     ' Debug                        
  pin_19

  pin_20
  pin_21
  pin_22
  pin_23

  pin_24
  pin_25
  pin_26
  pin_27
  
  pin_28
  pin_29
  pin_30
  pin_31

  con_MASK_SPDIN  = |< pin_SPDIN
  con_MASK_SPDDEL = |< pin_SPDDEL
  con_MASK_XORIN  = |< pin_XORIN
  con_MASK_RECCLK = |< pin_RECCLK
  con_MASK_PRADET = |< pin_PRADET
  con_MASK_DEBUG  = |< pin_DEBUG

CON
  con_RECCLK_DELAY = 9          ' Phase delay of RECCLK. 9
  con_PRADET_DELAY = 30         ' Number of Prop clocks in a preamble
                            
PUB biphasedec

  cognew(@decodebiphase, 0)
  cognew(@bitmonitor, 0)

  
DAT
{{
   This cog recovers the clock from the XOR'ed input.

   Schematic:


             3.3V     P0               P1
              |       ^                ^
              Z       |                |
              | |\    |          |\    |     Inverters  are 74HC04
   o)--+--||--o-| >o--o--|\|--o--| >o--o     NAND ports are 74HC00
       |      | |/    |       |  |/    |
       Z      Z  A    |       -   B    |
       |      |       |       -        |
      gnd    gnd      |       |        |
                      |      gnd       |
                      |                |    ___
                      |                +---|   \
                      |                |   |    )o--+
                      +--------------------|___/    |
                      |                |            |
                      |                |            |   ___
                    -----            -----          +--|   \
                    \   /            \   /             |    )o---> P3
                     \ /              \ /           +--|___/
                      o                o            |
                      |                |    ___     |
                      |                +---|   \    |
                      |                    |    )o--+
                      +--------------------|___/

   The input is connected to inverter A via a small circuit that provides the
   correct input impedance, a capacitor that decouples the DC, and voltage
   divider that pulls the voltage to 1.65V. That inverter amplifies the
   signal from 0.5V to full CMOS digital. The result is fed to P0 but that
   connection may not be needed in the future.

   The output of inverter A is fed into an RC network with another inverter,
   which act as a delay. The output of the delay is fed into P1 but may not
   be needed in the future.

   The rest of the circuit forms an equivalence circuit: if the P0 and P1
   signal are either both 1 or both 0, the output at P3 is a 1. Because
   of the delay and the propagation delays in the gates, this results in
   a positive pulse on P3 that's about 80ns long.

            +-------+       +---+   +-------+   +---+           +---+   +--
   P0       |   0   |   0   |   1   |   0   |   1   |     P     |   1   |
            +       +-------+   +---+       +---+   +-----------+   +---+

            --+       +-------+   +---+       +---+   +-----------+   +---+
   P1         |   0   |   0   |   1   |   0   |   1   |     P     |   1   |
              +-------+       +---+   +-------+   +---+           +---+   +
               
            +-+     +-+     +-+ +-+ +-+     +-+ +-+ +-+         +-+ +-+ +-+
   P3       | |     | |     | | | | | |     | | | | | |         | | | | | |
            + +-----+ +-----+ +-+ +-+ +-----+ +-+ +-+ +---------+ +-+ +-+ +

   On P3, the length of each positive pulse is always the same duration;
   it's determined by the R/C circuit between inverters A and B, and the
   propagation delay in the circuit.

   The durations of the low periods of P3 determine how the data should be
   interpreted. This low period depends on the frequency of the input signal
   and on the bits that are encoded in it.

   Nevertheless, because of inaccuracies in the components, and other
   real-time variations, the best way to recover the clock is to disregard
   the negative edge of P3, and only measure the time between positive
   edges.             
                      
   At 48kHz and when using stereo,the minimum time between two biphase level
   changes is 162.7ns: 48000 samples per second times 2 channels times 32
   bits times 2 results in 1/(48000*2*32*2) = 162.7 approximately. This
   corresponds to just over 13 Propeller clock cycles of 12.5ns each at
   80MHz.

           
}}

                        org     0
decodebiphase
                        ' Set up I/O
                        mov     dira, outputmask                        
                        mov     outa, #0

                        ' Set up timer A, used for recovering clock
                        mov     ctra, ctraval
                        mov     frqa, frqaval

                        ' Set up timer B, used for preamble detection
                        mov     ctrb, ctrbval
                        mov     frqb, frqbval

loop1
                        waitpne zero, mask_XORIN        ' Flank detected
                        mov     phsa, reseta            ' Make RECCLK low for half a bit time                        
                        mov     phsb, resetb
                        ' By now, XORIN should be 0 (pulse width must be < 150ns)
                        waitpeq zero, mask_RECCLK       ' Wait for center of bit; RECCLK goes high
                        nop
                        nop
                        ' Second pulse on XORIN should be gone now
                        waitpne zero, mask_XORIN        ' Wait for next bit
                        mov     phsa, reseta2           ' Make RECCLK high for half a bit time
                        mov     phsb, resetb
                        '
                        waitpne zero, mask_RECCLK       ' Wait for center of bit; RECCLK goes low
                        nop'xor     outa, mask_PRADET
                        jmp     #loop1

                        
                                                                          
                        
ctraval                 long    (%00100 << 26) | pin_RECCLK
frqaval                 long    1
reseta                  long    $8000_0000 - con_RECCLK_DELAY
reseta2                 long    - con_RECCLK_DELAY

ctrbval                 long    (%00100 << 26) | pin_PRADET
frqbval                 long    1
resetb                  long    - con_PRADET_DELAY

zero                    long    0
v8000_0000              long    $8000_0000

outputmask              long    con_MASK_RECCLK | con_MASK_PRADET {| con_MASK_DEBUG}
mask_XORIN              long    con_MASK_XORIN
mask_RECCLK             long    con_MASK_RECCLK
mask_PRADET             long    con_MASK_PRADET


DAT
                        org     0
bitmonitor
                        mov     dira, bmoutputmask
                        mov     outa, #0

                        ' Set up timer A, used for recovering clock
                        mov     ctra, bmctraval
                        mov     frqa, bmfrqaval

bmloop
                        waitpne bmzero, bmrecclkmask
                        nop
                        cmp     bmone, phsa wc
                        muxc    outa, bmoutputmask
                        mov     phsa, #0
                        waitpeq bmzero, bmrecclkmask
                        nop
                        cmp     bmone, phsa wc
                        muxc    outa, bmoutputmask
                        mov     phsa, #0
                        jmp     #bmloop

bmzero                  long    0
bmone                   long    1
bmtwo                   long    2
                        
bmoutputmask            long    con_MASK_DEBUG
bmrecclkmask            long    con_MASK_RECCLK
bmxorin                 long    con_MASK_XORIN
bmdebugoutmask          long    con_MASK_DEBUG                                                        
                                                        
bmctraval               long    (%01110 << 26) | pin_XORIN  ' NEGEDGE without feedback                      
bmfrqaval               long    1

DAT
{{
works (kinda) but needs cleaning up. Uses timers to generate pulses and there's too little time for
other cogs to sync then test ina.

                        org     0
decodebiphase
                        ' Set up I/O
                        mov     dira, outputmask                        
                        mov     outa, #0

                        ' Set up timer A, used for clock recovery
                        mov     ctra, ctraval
                        mov     frqa, frqaval

                        ' Set up timer B, used for preamble detection
                        mov     ctrb, ctrbval
                        mov     frqb, frqbval

loop
                        waitpne zero, inputmask         ' Wait until XOR input goes high                         
                        mov     phsa, resetaval         ' Start a delay ending in middle of a bit
                        test    v8000_0000, phsb wz     ' Check if the previous period was a preamble    
              if_z      mov     phsb, resetbval         ' If no preamble, reset preamble detection
              if_z      waitpeq zero, inputmask         ' If no preamble, wait for XOR to go low again
              if_z      jmp     #loop                   ' Repeat

                        xor     outa, ping              ' Toggle the debug output
                        nop                             ' Future functionality may go here
                        nop                             ' (e.g. to detect beginning of block)
                        nop
                        mov     phsb, resetbval         ' End of preamble; reset the preamble timer
                        waitpeq zero, inputmask         ' Wait for the first data bit in the subframe                        
                        jmp     #loop                   ' Repeat                                                  

frqaval                 long    1
resetaval               long    -9
ctraval                 long    (%00100 << 26) | 16
frqbval                 long    1
resetbval               long    ($80000000-5) -31
ctrbval                 long    (%00100 << 26) | 17
outputmask              long    |< 16 | |< 17 {| |< 18}
zero                    long    0                       ' Zero                        
inputmask               long    |< 3                    ' Read P3
v8000_0000              long    $8000_0000
ping                    long    |< 18


DAT
                        org     0
bitmonitor
                        mov     dira, bmoutputmask
                        mov     outa, #0

bmloop
                        waitpne bmzero, bmrecclkmask
                        waitpeq bmzero, bmrecclkmask
                        test    bmxor, ina wz
                        muxnz   outa, bmdebugoutmask
                        jmp     #bmloop

bmzero                  long    0                        
bmoutputmask            long    |< 18
bmrecclkmask            long    |< 16
bmxor                   long    |< 3
bmdebugoutmask          long    |< 18                                                        

}}
DAT
{{ CLOCK RECOVERY ON P16/P17 with feedback
P3=spdif xor reversed delayed spdif
100pF / 680 ohm delay
recoverd clock out on P16 
other cogs would trigger on P16 going low, and sample P3 to read input 


                        org     0
decodebiphase
                        mov     dira, outputmask
                        mov     outa, #0

                        mov     ctra, ctraval
                        mov     frqa, frqaval

                        mov     ctrb, ctrbval
                        mov     frqb, frqbval                                
loop
                        waitpne zero, inputmask 
                        mov     phsa, resetaval
                        mov     phsb, resetbval
                        waitpeq zero, inputmask
                        jmp     #loop                                     

frqaval                 long    1
resetaval               long    -9
ctraval                 long    (%00100 << 26) | 16
frqbval                 long    1
resetbval               long    -11
ctrbval                 long    (%00100 << 26) | 17
outputmask              long    |< 16 | |< 17
zero                    long    0                       ' Zero                        
inputmask               long    |< 3                    ' Read P3
inputmask2              long    |< 16 | |< 17            ' P3 or timer output pin        
measurement             long    0                       ' Measurement of current pulse
preamblelength          long    28                      ' More than this number of cycles = preamble
result0                 long    0                       ' Serialized result                        

}}

                        
CON     
''***************************************************************************
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