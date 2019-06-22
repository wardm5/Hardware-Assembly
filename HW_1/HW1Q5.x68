*-----------------------------------------------------------
* Title      :  HW1 5.3
* Written by :  Misha Ward
* Date       :  4/19/2019
* Description:  Program to add two user inputted numbers
*-----------------------------------------------------------
CR          EQU     $0d
LF          EQU     $0a
START       ORG $1000   

*---------- Output Code ---------*
            LEA     Input1, a1   load input message 1
            MOVE.W  #14, d0      move the input message to d0
            TRAP    #15          show message
            
*---------- Input Code ---------*
            MOVE.B  #4, d0       move input to d0
            TRAP    #15          show amount
            MOVE.W  d1, d2       move amount from d1 to d2
            
*---------- Code for output ---------*
            LEA     Input2, a1   load second input message
            MOVE.W  #14, d0      move message to d0
            TRAP    #15          show message

*---------- Code for input ---------*
            MOVE.B  #4,d0        move input to d0
            TRAP    #15          show input
            ADD.W   d2,d1        add the two amounts in d2 with d2
            BVS     OVER         determines if the v flag was activated for overflow
            MOVE    #3,d0        move amount to d0
            MOVE.W D1, $6000     move amount to $6000 address
            TRAP    #15          show amount
            STOP    #$2000       quit program

*---------- Overflow ---------------*
OVER        LEA    OVERFLOW,a1   load overflow message to a1
            MOVE.W #14,D0        move message to d0
            TRAP   #15           print message
            STOP    #$2000       stop program

*---------- Halt Simulator ---------*   
    MOVE.W  #9,d0
    TRAP    #15

* Stop execution
    STOP    #$2000

*------------- Variables --------------*
Input1      DC.B    'Enter a first number: ',0
Input2      DC.B    'Enter a second number: ',0
OVERFLOW    DC.W    'The values you entered caused an overflow condition.',0
    END START   end of program with start address specified
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
