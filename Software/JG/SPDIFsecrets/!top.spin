CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  ser:          "FullDuplexSerial"
  biphase:      "BiphaseDec"

PUB main

  'cognew(@spdifblink, @@0)
  'cognew(@inputtest, @@0)
  biphase.biphasedec
  
  ser.Start(31, 30, %0000, 115200)                      'requires 1 cog for operation

  waitcnt(cnt + (1 * clkfreq))                          'wait 1 second for the serial object to start
  
  ser.Str(STRING("Testing the FullDuplexSerial object."))     'print a test string
  ser.Tx($0D)                                                 'print a new line
  
  ser.Str(STRING("All Done!"))

  waitcnt(cnt + (1 * clkfreq))                          'wait 1 second for the serial object to finish printing
  
  ser.Stop                                              'Stop the object

DAT

{{ This checks the input based on inputmask and sets the LEDs on pins 16 and 17
   based on whether the input is on or off.
   This code can be used to check whether you're getting any input signal and
   whether the 74HC04 is working: for all values 1 2 and 4 for inputmask, the
   LEDs should be equally bright. }}
                        org     0
inputtest
                        mov     dira, maskall
                        mov     outa, maskall

loop0
                        test    inputmask, ina wz
                        muxz    data, mask16
                        muxnz   data, mask17                                                                   
                        mov     outa, data
                        jmp     #loop0

data                    long    0                                
maskall                 long    |<16 | |<17
mask16                  long    |<16
mask17                  long    |<17
inputmask               long    8


DAT

{{ This checks the R-C based delays between the 74HC04 ports. The SPDIF signal
   is delayed by the propagation delay and by the R-C networks that are between
   the ports. So the Propeller should see the incoming data on pin 0, then pin
   1, then pin 2, with about 60ns delay in between.
   This code tests two of the bits and then uses the parity result in the Carry
   flag to determine whether the pins have equal values.
   Between pins 0 and 1, and between pins 1 and 2, the delay is so short that
   most of the time, the pins are equal, so the parity is equal and one LED is
   significantly brighter. Between pins 0 and 2, the delay is longer so the
   difference in brightness is smaller (but still pretty clear to see, unless
   the incoming signal is dead or there's no real SPDIF)
    
                        org     0
delaytest
                        mov     dira, maskall1
                        mov     outa, maskall1

loop1
                        mov     data1, ina
                        test    data1, #5 wc            ' 3 or 6 to test delay over 1 port, 5=2 ports
                        muxc    data1, mask16a          ' pins are different
                        muxnc   data1, mask17a          ' pins are equal
                        mov     outa, data1
                        jmp     #loop1

data1                   long    0
maskall1                long    |<16 | |<17
mask16a                 long    |<16
mask17a                 long    |<17
                                        
}}                        
                                                            