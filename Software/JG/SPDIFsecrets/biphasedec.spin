''***************************************************************************
''* Bi-phase Decoder for S/PDIF
''* Copyright (C) 2017 Jac Goudsmit
''*
''* TERMS OF USE: MIT License. See bottom of file.                                                            
''***************************************************************************
''

CON
  con_RECCLK_DELAY = 9          ' Phase delay of RECCLK. 9
  con_PRADET_DELAY = 30         ' Number of Prop clocks in a preamble

OBJ
  hw:           "hardware"      ' Pin assignments and other global constants
                              
PUB biphasedec

  cognew(@decodebiphase, 0)
  cognew(@bitmonitor, 0)

  
DAT
{{
   This cog recovers the clock from the XOR'ed input.

   Schematic:


             3.3V   SPDIN            SPDDEL
           10k|       ^                ^
              Z       |                |
         100n | |\    |  100R    |\    |     Inverters  are 74HC04
   o)--+--||--o-| >o--o--|\|--o--| >o--o     NAND ports are 74HC00
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

   The input is connected to inverter A via a small circuit that provides the
   correct input impedance, a capacitor that decouples the DC, and voltage
   divider that pulls the voltage to 1.65V. That inverter amplifies the
   signal from 0.5V to full CMOS digital. The result is fed to pin_SPDIN but
   that connection may not be needed in the future.

   The output of inverter A is fed into an RC network with another inverter,
   which act as a delay. The output of the delay is fed into pin_SPDDEL but
   may not be needed in the future.

   The rest of the circuit forms an equivalence circuit: if SPDIN and SPDDEL
   are either both 1 or both 0, the output at XORIN is a 1. Because
   of the delay and the propagation delays in the gates, this results in
   a positive pulse on XORIN that's shorter than a single instruction
   (about 30ns, whereas an instruction is 50ns).

            +-------+       +---+   +-------+   +---+           +---+   +--
   SPDIN    |   0   |   0   |   1   |   0   |   1   |     P     |   1   |
            +       +-------+   +---+       +---+   +-----------+   +---+

            --+       +-------+   +---+       +---+   +-----------+   +---+
   SPDDEL     |   0   |   0   |   1   |   0   |   1   |     P     |   1   |
              +-------+       +---+   +-------+   +---+           +---+   +
               
            +-+     +-+     +-+ +-+ +-+     +-+ +-+ +-+         +-+ +-+ +-+
   XORIN    | |     | |     | | | | | |     | | | | | |         | | | | | |
            + +-----+ +-----+ +-+ +-+ +-----+ +-+ +-+ +---------+ +-+ +-+ +

   The width of the positive pulses on XORIN depends on the R-C circuit on
   inverter B. It's pretty jittery so the code should only depend on the
   positive edges of XORIN.

   At 48kHz and when using stereo (i.e. two subframes per frame), there are
   3,072,000 bits of data per second, so each bit takes about 325ns to
   transfer. When the Propeller clock runs at 80MHz, so each Propeller clock
   cycle is 12.5ns. Most Propeller instructions are 4 cycles (50ns) so
   each bit has to be processed in about 6 instructions. Running the
   Propeller at a faster speed or processing a slower SPDIF stream can be
   done without changing the code. 
         
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

                        
                                                                          
                        
ctraval                 long    (%00100 << 26) | hw#pin_RECCLK
frqaval                 long    1
reseta                  long    $8000_0000 - con_RECCLK_DELAY
reseta2                 long    - con_RECCLK_DELAY

ctrbval                 long    (%00100 << 26) | hw#pin_PRADET
frqbval                 long    1
resetb                  long    - con_PRADET_DELAY

zero                    long    0
v8000_0000              long    $8000_0000

outputmask              long    hw#mask_RECCLK | hw#mask_PRADET {| hw#mask_DEBUG}
mask_XORIN              long    hw#mask_XORIN
mask_RECCLK             long    hw#mask_RECCLK
mask_PRADET             long    hw#mask_PRADET


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
                        
bmoutputmask            long    hw#mask_DEBUG
bmrecclkmask            long    hw#mask_RECCLK
bmxorin                 long    hw#mask_XORIN
bmdebugoutmask          long    hw#mask_DEBUG                                                        
                                                        
bmctraval               long    (%01110 << 26) | hw#pin_XORIN ' NEGEDGE without feedback                      
bmfrqaval               long    1

                        
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
