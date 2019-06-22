*-----------------------------------------------------------
* Title      :  HW 
* Written by :  Misha Ward
* Date       :  4/28/2019
* Description:  Pattern Finder and Cumulative Sum
*-----------------------------------------------------------
start_hw        EQU         $00006000
end_hw          EQU         $00008000
pattern         EQU         $A000   
CR              EQU         $0D
LF              EQU         $0A

	ORG         $1000
start
************ user input ******************
            lea     startMessage,a1  post message to user
            move.b  #14,d0
            trap    #15
            move.b  #2,D0       recieve user input
            trap    #15 
            *d0+0
          
************ pattern finding **************
        

            MOVE.B      #$FE, pattern  
            MOVE.B      #$FE, $00007005   test case
                                          
            lea         start_hw, a0 
            movea       a0, a4
            lea         end_hw, a1  
            lea         addr1, a2 
            move.b      pattern,d0 
              
loop        cmp.b       (a0),d0
            beq         match  
            ADDQ.l      #1, a0
            CMPA.L      a1, a0 
            BGT         no_match 
            bra         loop 
match       move.l      a0,addr1
            bra next
no_match    move.l      a4,addr1

next
************ cumulative sum **************
            lea         addr1, a2            lea         Addsum, a3 
            lea         CarryBit, a4             
            move.l      #512, d5
            move.l      #0, d4
            add         (a0), Addsum
            bcs.l       carry
            addq.l      #1, a0
            add.l       #1, d4

carry
            lea         carryMessage, a0
            move.b #14, d0
            trap  #15


messageSection        
        moveq   #15,d0   task number 15 into D0
        moveq   #16,d2   base 16, hex
        move.l  addr1,d1   load address into D1
        trap   #15   display address in D1.l in hex
        move.b   #1, CarryBit
        
            
******** variables **********
startMessage     dc.b    'Please enter two hexidecimal values (test hex = FE @ $7005): ',CR,LF,0
addr1       dc.l 1
Addsum      dc.w 1
CarryBit     ds.b 1
carryMessage     dc.b    'You had a carry bit: ',CR,LF,0
            end  start

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
