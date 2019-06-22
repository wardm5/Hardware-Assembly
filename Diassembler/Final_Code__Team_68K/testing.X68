*-----------------------------------------------------------
* Title      :      Test file - original
* Written By :      Misha Ward
* Date       :      5/28/2019
* Description:      To test our Disassembler
*-----------------------------------------------------------
    ORG    $7000
START:

* Put program code here
    NOP
    RTS

    JSR         (A2)
    JSR         $00123658
    LEA         $00001234, A5
    LEA         (A4),A5

    OR          D1,D2
    OR          D1, $00001234
    OR          D2, (A1)
    OR          (A1), D3
    OR          D1, (A2)+
    OR          -(A2), D3
    OR          D3, 0(A3,D5)
    OR          D3, 0(A3,D5)

    SUB.B       D5,D4
    SUB.W       D5,D4
    SUB.L       D5,D4
    SUB.L       D1,$00001234
    SUB.L       $00001234,D1
    SUB.L       D1, $FFFF1234
    SUB.L       $FFFF1234,D1
    SUB         (A0),D3
    SUB         D1, (A1)
    SUB         -(A1), D3
    SUB         D4, 0(A3,D5)
    SUB         D4, 0(A3,D5)

    BSR         TEST

    BRA         NO_TEST
    *BPL         TEST
    *BGE         TEST
    *BHI         TEST
    *BVC         TEST
    *BLT         TEST
    *BCS         TEST
    Bcc         TEST
    BGT         TEST
    BLE         TEST
    BEQ         TEST

    ADD.B       D0,D1
    ADD.W       D1,D0
    ADD.L       $00001234,D1
    ADD         D1,$00001234
    ADD.L       $FFFF1234,D1
    ADD.B       D2, $FFFF1234
    ADD.B        #1,D5
    ADD.W        #10,D6
    ADDA        #5,A1
    ADDA.W      $0001234,A2
    ADDA.L      $FFFF1234,A0

    ROL         $00001234
    ROL         $FFFF1123
    ROR         $00001234
    ROR         $FFFF1123
    ROR         (A1)+
    ROR         -(A2)
    ROL.B       D1,D2
    ROL.W       D1,D2
    ROL.L       D3,D4
    ROL.B       #8,D5
    ROL.W       #4,D6
    ROL.L       #1,D1

    LSL         $00001234
    LSL         $FFFF1123
    LSR         $00001234
    LSR         $FFFF1123
    LSR         (A1)+
    LSR         -(A2)
    LSL.B       D1,D2
    LSL.W       D1,D2
    LSL.L       D3,D4
    LSL.B       #8,D5
    LSL.W       #4,D6
    LSL.L       #1,D1
    ASL         $00001234
    ASL         $FFFF1123
    ASR         $00001234
    ASR         $FFFF1123
    ASR         (A1)+
    ASR         -(A2)
    ASL.B       D1,D2
    ASL.W       D1,D2
    ASL.L       D3,D4
    ASL.B       #8,D5
    ASL.W       #4,D6
    ASL.L       #1,D1

    MULS        #3, D1


    MOVE        D1,$00001234
    MOVE.L      $00001234,D0
    MOVE.W      D1, $00001234
    MOVE.B      $FFFF1234,D5
    MOVE.B      (A1),$000012134
    MOVE.W      -(A2),$FFFF1234
    MOVE.L      (A1)+, D5
    MOVE.W      A2,D3
    MOVE.W      #123, D5
    MOVE.B      #12,D6
    MOVE.L      #14,D5
    MOVE.L      #20, D7
    MOVEA.W     $00001234,A1
    MOVEA.L     $FFFF1234,A2
    MOVEA.W     (A2),A1
    MOVEA.L     (A2)+,A3
    MOVEA.W     -(A3),A3
    MOVEA.W     -(SP),A3
    MOVEA.W     -(A7),A4

    AND.W     d0,d1
    AND.W     d0,$00004000
    AND.L     $00004000,d7
    AND.W     d0,(a3)
    AND.L     (a6),d7


    NOT.B     d0
    NOT.W     $000048C0
    NOT.L     (a0)+

    neg.w     $00004000
    neg.l     (a2)


    MOVEM.W     (A2),A1
    MOVEM.L     (A2)+,A3



* Put variaBles and constants here
TEST
    MOVE.W      #0,D1
    RTS


NO_TEST
    MOVE.W     #4,D2
    RTS
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~14~
*~TaB type~1~
*~TaB size~4~
