*-----------------------------------------------------------
* Title      :   HW 2 - Question 4
* Written by :   Misha War
* Date       :   04/27/2019
* Description:   Converts Floating Point Hex and Provides Analysis
*-----------------------------------------------------------

   ORG   $4000
START:            ; first instruction of program
    LEA     MESSAGE1,A1 *Loads message into ad6dress register A1
    MOVE.B  #14,D0      *Moves number 14 into data regiter D0
    TRAP    #15         *Displays Message
   
    LEA     INPUT,A1   ; Where to store input string
    MOVE.B  #2,D0       ; Read string
    TRAP    #15

    LEA     MESSAGE2,A1 *Loads message into address register A1
    MOVE.B  #14,D0      *Moves number 14 into data regiter D0
    TRAP    #15         *Displays Message

*PRINT STRING FOR CONFIMATION
    LEA     INPUT,A1   ; String to display
    MOVE.B  #13,D0      ; Display string with newline
    TRAP    #15

    LEA INPUT, a0  * save the input into memory addres
**** FOR LOOP TO PASS THROUGH INPUT ****
    move.l  #0, d4          * counter
    move.l  #8, d5          * size of INPUT (assuming correct input)
LOOP_1    cmp.l d4,d5   *Do the comparison test (n < 8)
    beq     next_code 
    *{ Execute some other loop instructions}
    add.b #1,d4 *Increment the counter 
    move.b  (a0)+, d7
    *move.b  d1, d7
    cmp.b   #$30, d7
    BNE X1

    MOVE.B  #0, -(A3)
    MOVE.B  #0, -(A3)
    MOVE.B  #0, -(A3)
    MOVE.B  #0, -(A3)
    bra LOOP_1
    
X1  cmp.b   #$31, d7
    bne x2 
    MOVE.B  #0, -(A3)
    MOVE.B  #0, -(A3)
    MOVE.B  #0, -(A3)
    MOVE.B  #1, -(A3)
    bra LOOP_1
    
X2  cmp.b   #$32, d7
    bne x3
    *lea message4, a1
    *move.b #14, d0
    *trap #15    
    MOVE.B  #0, -(A3)
    MOVE.B  #0, -(A3)
    MOVE.B  #1, -(A3)
    MOVE.B  #0, -(A3)
    bra LOOP_1
    
X3  cmp.b   #$33, d7
    bne x4  
    MOVE.B  #0, -(A3)
    MOVE.B  #0, -(A3)
    MOVE.B  #1, -(A3)
    MOVE.B  #1, -(A3)
    bra LOOP_1
    
X4  cmp.b   #$34, d7
    bne x5 
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #0,-(A3)
    bra LOOP_1
   
X5  cmp.b   #$35, d7
    bne x6 
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    bra LOOP_1
    
X6  cmp.b   #$36, d7
    bne x7 
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    bra LOOP_1
    
    
X7  cmp.b   #$37, d7
    bne x8 
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    bra LOOP_1
    
    
X8  cmp.b   #$38, d7
    bne x9 
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #0,-(A3)
    bra LOOP_1
    
X9  cmp.b   #$39, d7
    bne xA 
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    bra LOOP_1
    
XA  cmp.b   #$41, d7
    bne xB 
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    bra LOOP_1
    
XB  cmp.b   #$42, d7
    bne xC 
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    bra LOOP_1
    
XC  cmp.b   #$43, d7
    bne xD 
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #0,-(A3)
    bra LOOP_1
   
XD  cmp.b   #$44, d7
    bne xE 
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    MOVE.B  #1,-(A3)
    bra LOOP_1
   
XE  cmp.b   #$45, d7
    bne xF 
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #0,-(A3)
    bra LOOP_1
    
XF    
    *MOVE.B  #6, D0
    *TRAP #15
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    MOVE.B  #1,-(A3)
    bra LOOP_1 *Go back
    
    
*********** LOOP THROUGH ARRAY IN A3 ******************
next_code *{ Execute the instructions after the loop } 
        move.b #0, d1  * bit                  
        move.b #0, d2  * boolean value for mantissa
        move.l #0, d3  actual value
        move.l #1, d4  keep track of scale of the amount...
        move.b #0, d5  keep track if you reset numbers
        move.l #33, d6  * go from 32 to 9 didgets 
LOOP_2    MOVE.B #3,D0        ; trap task 3, display signed number from D1
        SUB.B   #1,d6   * update int i
        cmp.b #1, d6
        beq sign
    
        cmp.b #9, d6
        beq turnOnExponetFlag
        cmp.b  #1, d5
        beq   exponetSection
    
        MOVE.B (A3)+,D1
        *TRAP #15     display mantissa bit
        cmp.b   #1, d2   * check if the flag is set to 1
        beq checkBinaryBit  * if it is, then do other logic
        cmp.b   #1, d1   * else check to see if the bit currently is 1
        beq startProcess
        bra LOOP_2
        
startProcess
        move.b #1, d2
        add.l    #1, d3
        muls   #2, d4
        bra LOOP_2

checkBinaryBit        * check the bit at this location against the flag
        cmp.b #1, d1   * check binary bit to 1
        beq secondProcess  * if it does equal to 1
        muls   #2, d4   * else multiply the scale by 2
        bra LOOP_2  * loop

secondProcess
        add.l  d4, d3
        muls  #2, d4
        bra LOOP_2
    
    
exponetSection
LOOP_3  MOVE.B #3,D0
        MOVE.B (A3)+,D1        
        *TRAP #15   * display exponet bit
        *if bit is 1, then add the multiplier to the value tracker
        cmp.b  #0, d1
        bne startExProcess
        muls #2, d4
        bra LOOP_2
        
startExProcess
        add.l d4,d3
        muls #2, d4
        bra LOOP_2    
    
turnOnExponetFlag
       *SIMHALT
        lea message5, a1
        MOVE.B  #14,D0      *Moves number 14 into data regiter D0
        TRAP    #15         *Displays Message
        move.l d3, d1
        move.b #3, d0
        trap #15
        lea newSpace, a1
        MOVE.B  #14,D0      *Moves number 14 into data regiter D0
        TRAP    #15         *Displays Message
        
        move.b #1, d5
        move.l #0, d3  actual value
        move.l #1, d4  keep track of scale of the amount...
        bra exponetSection
    

sign        
        lea message4, a1        
        MOVE.B  #14,D0      *Moves number 14 into data regiter D0
        TRAP    #15         *Displays Message
        move.l d3, d1
        move.b #3, d0
        trap #15
        lea newSpace, a1
        MOVE.B  #14,D0      *Moves number 14 into data regiter D0
        TRAP    #15         *Displays Message
        MOVE.B (A3)+, D1 
        *move.b  (A3), d1
        *trap #15    show sign bit
        cmp.b  #0, d1
        beq positive
        lea message3neg, a1
        MOVE.B  #14,D0      *Moves number 14 into data regiter D0
        TRAP    #15         *Displays Message
        bra endOfProgram
positive
        lea message3pos, a1
        MOVE.B  #14,D0      *Moves number 14 into data regiter D0
        TRAP    #15         *Displays Message
        bra endOfProgram

*  C0680000
*  Sign bit: - 
*  Exponent:128
*  Mantissa: 13
    
endOfProgram
    
* Variables and Strings
        ORG $5000 
CR EQU $0D
LF EQU $0A

message1 dc.b 'Enter your hexidecimal number (please capitalize letters): ',0
message2 dc.b 'The hexidecimal that you entered was: ',0
message0 dc.b 'test 0',0
newSpace dc.b ' ', CR, LF, 0
message3pos dc.b 'Sign bit:  +', CR, LF, 0
message3neg dc.b 'Sign bit:  -', CR, LF, 0
message4 dc.b    'Exponet:   ', 0
message5 dc.b    'Mantissa:  ', 0
signBit  dc.b  1
exponent dc.b  1
mantissa dc.w  1
         ds.w    0  ; force even address
INPUT    ds.l    0  ; input string storage
array    dc.b  80
         END START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
