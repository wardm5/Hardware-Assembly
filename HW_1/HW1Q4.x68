*-----------------------------------------------------------
* Title      :  HW1 Q4
* Written by :  Misha Ward
* Date       :  4/19/2019
* Description:  Program to move data around
*-----------------------------------------------------------
* like define in C
addr1   equ     $4000
addr2   equ     $4001
data2   equ     $A7FF
data3   equ     $5555
data4   equ     $0000
data5   equ     4678
data6   equ     %01001111
data7   equ     %00010111

*--------- code section ----------
    ORG    $400
start       move.w #data2, d0   * load d0
            move.b #data6, d1
            move.b #data7, d2
            move.w #data3, d3
            movea.w #addr1, a0  * load address register
            move.b  d1, (a0)+   * transfer byte to memory
            move.b  d2, (a0)+   *transfer second byte
            movea.w  #addr1, a1 *load address
            and.w   d3, (a1)    *logical AND
            
            jmp  start
            
            end $400
    
    
    



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
