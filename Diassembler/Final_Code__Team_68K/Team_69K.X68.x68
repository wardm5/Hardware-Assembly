*-----------------------------------------------------------
* Title      : 68k Disassembler
* Written by : Team 69K - Misha,  Cole,  Tri
* Date       : 5/26/2019
* Description: Disassembler project for 422, Spring, 2019
*-----------------------------------------------------------

* Starting variables
START_ADDR            EQU    $50
END_ADDR              EQU    $100
TEMP_WORD             EQU    $150
DEST_REG              EQU    $200
DEST_MODE             EQU    $250
EFFECTIVE_MODE              EQU    $300
EFFECTIVE_REG               EQU    $350
TEMP_VAR_3            EQU    $400
TEMP_VAR_4            EQU    $450
TEMP_VAR_5            EQU    $500
TEMP_VAR_6            EQU    $550
TEMP_VAR_7            EQU    $600
TEMP_BYTE             EQU    $650
TEMP_LONG             EQU    $700
MOVEM_SIZE            EQU    $750
MOVEM_DIR       EQU    $800
MOVEM_LONG_ADDRESS    EQU    $850
MOVEM_WORD_ADDRESS    EQU    $900
MARK_LIST             EQU    $950

        ORG    $1000
START:

* Get starting address from user
GET_START_ADDR
    CLR         D3
    LEA         INTRO_START, A1
    MOVE.B      #13, D0
    TRAP        #15
    MOVEA.L     #0, A1
    LEA         TEMP_VAR_5, A1
    CLR         D0
    CLR         D1
    MOVE.B      #2, D0
    TRAP        #15
    BRA         ASCII_TO_HEX  * convert user input to ascii, check input

* Get ending address from user
GET_END_ADDR
    CLR         D3
    LEA         INTRO_END, A1
    MOVE.B      #13, D0
    TRAP        #15
    LEA         TEMP_VAR_4, A1
    MOVE.B      #2, D0
    TRAP        #15
    BRA         ASCII_TO_HEX  * convert user input to ascii, check input

* Converts ascii char to hex value
ASCII_TO_HEX
    MOVE.B      (A1)+, D0   * iterate through address
    CMP.B       #$30, D0
    BLT         ERROR_BAD_INPUT    * check if less than 30, invalid
    CMP.B       #$39, D0
    BGT         CHAR_ASCII_TO_HEX   * check if greater than 39, convert to hex
    SUB.B       #$30, D0
    ADD.L       D0, D3
    SUBI        #1, D1
    CMP.B       #0, D1
    BEQ         START_END_CHECK
    LSL.L       #4, D3
    BRA         ASCII_TO_HEX

* Converts ascii char to hex value
CHAR_ASCII_TO_HEX
    CMP.B       #$41, D0                * compare if 41
    BLT         ERROR_BAD_INPUT         * if less than, bad input
    CMP.B       #$46, D0
    BGT         ERROR_BAD_INPUT         * if greater than bad input
    SUB.B       #$37, D0                * standardize input to 0
    ADD.L       D0, D3                  * add this to the address val
    SUBI        #1, D1                  * sub how many chars left to loop through
    CMP.B       #0, D1
    BEQ         START_END_CHECK
    LSL.L       #4, D3
    BRA         ASCII_TO_HEX

* checks if the value is correct
START_END_CHECK
    BTST        #0, D3
    BNE         BAD_START_ADDR          * if wrong, then restart start address
    CMP         #1, D2
    BEQ         END_COMPLETED
    ADDI        #1, D2
    MOVE.L      D3, START_ADDR
    BRA         GET_END_ADDR


END_COMPLETED
    BTST        #0, D3
    BNE         BAD_END_ADDR
    CMP.L       START_ADDR, D3
    BLE         BAD_END_ADDR
    CLR.W       D2
    MOVE.L      D3, END_ADDR
    CLR.W       D3
    LEA         SPACE, A1
    MOVE.B      #13, D0
    TRAP        #15
    BRA         START_PRGM

* restarts variables for start address, BAD_END_ADDR is same format as this
BAD_START_ADDR
    MOVEA.L     #0, A1              * clears A1
    LEA         INVALID_INPUT, A1
    MOVE.B      #13, D0
    TRAP        #15                 * prints invalid message
    CLR         D3                  * clears D3
    BRA         GET_START_ADDR      * brings user back to enter start address

* same as BAD_START_ADDR
BAD_END_ADDR
    MOVEA.L     #0, A1
    LEA         INVALID_INPUT, A1
    MOVE.B      #13, D0
    TRAP        #15
    CLR         D3
    BRA         GET_END_ADDR

* checks if the start address is good, if 1, means start address passed
* if not go to start address to re-enter
ERROR_BAD_INPUT
    CMP         #1, D2
    BEQ         BAD_END_ADDR
    BRA         BAD_START_ADDR

* Converts each hex (4 bits) to ascii char
HEX_TO_ASCII
    LEA         HEX_JMP_TABLE, A4
    JSR         HEX_HELPER_1     * gets first word, then converts that to ascii character via comparison
    JSR         HEX_HELPER_2     * gets second word, then converts that to ascii character via comparison
    JSR         HEX_HELPER_3     * gets third word, then converts that to ascii character via comparison
    JSR         HEX_HELPER_4     * gets fourth word, then converts that to ascii character via comparison
    CLR.W       D3
    RTS

* kicks off op code parsing
START_PRGM
    LEA         FIRST_HEX_VAL_JMP_TABLE, A0     * loads table hex table
    MOVE.L      START_ADDR, A2                  * moves start address to A2
    MOVE.L      END_ADDR, A3                    * moves end address to A3
    BRA         PARSE_OP_CODE                   * calls parse op code method

* method to loop through 25 times to print out op codes
CONTINUE_PROGRAM
    ADD         #1, D6
    CMP         #25, D6
    BEQ         ENTER
    LEA         SPACE, A1
    MOVE        #13, D0
    TRAP        #15
    MOVE.B      #0, TEMP_VAR_7
    RTS

* user input for enter
ENTER
    MOVE        #0, D6
    MOVE.B      #5, D0
    TRAP        #15
    JSR         PRINT_BAR
    RTS


**** OP codes print methods   - please search  PRINT_OUT_LEA for typical print statement comments
* LEA was our first opcode to tackle and so we based a lot of the future print out methods on that method
INVALID
    CMP         #%11, D3
    BNE         invalid_return
    CMP         #%001,  DEST_MODE
    BNE         INVALID_HELPER
    CMP         #%001,  EFFECTIVE_MODE
    BNE         INVALID_HELPER
invalid_return
    LEA         DATA_STR, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    JSR         PRINT_DOLLAR
    JSR         HEX_TO_ASCII
    LEA         SPACE, A1
    MOVE.B      #14, D0
    TRAP        #15
    CLR         D5
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE

INVALID_HELPER
    CMP         #9, D5
    BNE         ERROR_BAD_EA
    BRA         invalid_return

PRINT_OUT_NOP
    LEA         NOP_STR, A1
    JSR         PRINT_FUNC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_OUT_RTS
    LEA         RTS_STR, A1
    JSR         PRINT_FUNC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_OUT_JSR
    LEA         JSR_STR, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_DATA_MODE_SRC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE

PRINT_OUT_NOT
    MOVE.W      TEMP_WORD, D3
    JSR         GET_NORM_SIZE
    CMP         #%11, D3
    BEQ         INVALID
    LEA         NOT_STR, A1
    JSR         PRINT_FUNC
    JSR         PRINT_NORM_SUF
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_DATA_MODE_SRC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_NOT_NORM_SUF
    LEA         NORM_SIZE_PRINT_JMP_TABLE, A4
    JSR        MULU_6
    ADD.W       D3,A4
    JSR         (A4)
    CLR         D3
    RTS

PRINT_NORM_SUF
    MOVE.W      TEMP_WORD, D3
    JSR         GET_NORM_SIZE
    LEA         NORM_SIZE_PRINT_JMP_TABLE, A4
    CMP         #%11, D3
    BEQ         INVALID
    JSR        MULU_6
    ADD.W       D3,A4
    JSR         (A4)
    RTS

PRINT_REG_NUM
    LEA         HEX_JMP_TABLE, A4
    MOVE.W      TEMP_VAR_3, D3
    JSR        MULU_6
    ADD.W       D3,A4
    JSR         (A4)
    CLR.W       TEMP_VAR_3
    CLR.W       D3
    RTS

* Typical print statement, many of them follow a similar pattern.
PRINT_OUT_LEA
    LEA         LEA_STR, A1                 * load LEA string
    JSR         PRINT_FUNC                  * print LEA
    JSR         PRINT_SPACE                 * print space
    MOVE.W      TEMP_WORD, D3               * move the current word to d3
    JSR         CHECK_TYPE_DATA             * check the data for destination, effective address, etc
    JSR         PRINT_DATA_MODE_SRC         * prints the mode source
    JSR         PRINT_COMMA                 * prints comma
    JSR         PRINT_SPACE                 * print space
    JSR         PRINT_ADDR_REG              * print address reg
    MOVE.W      DEST_REG, TEMP_VAR_3        * move the destination variable to temp 3
    JSR         PRINT_REG_NUM               * print register number
    BSR         CONTINUE_PROGRAM            * continue the program by updating print loop
    BRA         PARSE_OP_CODE               * parse the op code
    RTS

PRINT_OUT_ADDQ
    LEA         ADDQ_STR, A1
    JSR         PRINT_FUNC
    JSR         PRINT_NORM_SUF
    JSR         PRINT_SPACE
    JSR         PRINT_HASHTAG
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    CMP         #0,  DEST_REG
    BEQ         ADDQ_HELPER_FUNC
    MOVE.W      DEST_REG, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_MODE_SRC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS
ADDQ_HELPER_FUNC
    MOVE.W      #8, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_MODE_SRC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_OUT_MULU
    LEA         MULU_STR, A1
    BRA         MULS_AND_MULU_HELPER
PRINT_OUT_MULS
    LEA         MULS_STR, A1
    BRA         MULS_AND_MULU_HELPER
MULS_AND_MULU_HELPER
    JSR         PRINT_FUNC
    JSR         PRINT_NORM_WORD_SUF
    JSR         PRINT_SPACE
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    MOVE.W      #%01,  DEST_MODE
    JSR         PRINT_DATA_MODE_SRC
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_REG
    MOVE.W      DEST_REG, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_OUT_MOVEQ
    LEA         MOVEQ_STR, A1
    JSR         PRINT_FUNC
    JSR         PRINT_NORM_LONG_SUF
    MOVE.W      TEMP_WORD, D1
    JSR         PRINT_HASHTAG
    JSR         PRINT_DOLLAR
    MOVE.W      TEMP_WORD, D3
    JSR         LSL_8
    JSR         LSR_8
    MOVE.W      D3, TEMP_WORD
    JSR         HEX_TO_ASCII
    MOVE.W      D1,  TEMP_WORD
    MOVE.W      TEMP_WORD, D3
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_DATA_REG
    MOVE.W      DEST_REG, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE

PRINT_OUT_MOVEM
    *SIMHALT
    MOVE.L      #$00000000, A5
    CLR         D5
    CLR         D7
    MOVE.B      #0, MOVEM_DIR
    MOVE.B      #0, MOVEM_SIZE
    LEA         MOVEM_STR, A1
    JSR         PRINT_FUNC
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    CMP         #12, D3
    BEQ         SET_DIR
back_from_dir
    MOVE.W      TEMP_WORD, D3
    JSR         GET_3RD_HEX_VAL
    LSR         #2,  D3             * gets the first two bits of the 3rd hex val
    CMP         #%11,  D3           * size of the data
    BEQ         SET_SIZE
    JSR         PRINT_WORD_SUF
back_from_size
    MOVE.W      TEMP_WORD, D3
    JSR         PRINT_SPACE
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    CMP         #%111, EFFECTIVE_MODE
    BNE         MOVEM_REG
    CMP         #%001, EFFECTIVE_REG
    BEQ         MOVEM_LONG
    MOVE.W      (A2)+, MARK_LIST               * mark list
    MOVE.W      (A2)+, A5                * address
    JSR         MARK_LIST_HELPER
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DOLLAR
    JSR         PRINT_MOVEM_LONG_ADDRESS
    JSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

MOVEM_REG
    MOVE.W      TEMP_WORD, D3
    MOVE.W      (A2)+, MARK_LIST                * mark list
    CMP         #1, MOVEM_DIR
    BEQ         MOVEM_REG_HELPER
    JSR         MARK_LIST_HELPER
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_MODE_SRC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

MOVEM_REG_HELPER
    JSR         PRINT_DATA_MODE_SRC
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         MARK_LIST_HELPER
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

MOVEM_LONG
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    MOVE.W      (A2)+, MARK_LIST                * mark list
    MOVE.L      (A2)+, A5                * address
    CMP         #1, MOVEM_DIR
    JSR         MOVEM_LONG_HELPER
    JSR         PRINT_DOLLAR
    JSR         PRINT_MOVEM_LONG_ADDRESS
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_MODE_SRC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

MOVEM_LONG_HELPER
    JSR         MARK_LIST_HELPER
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DOLLAR
    JSR         PRINT_MOVEM_LONG_ADDRESS
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

MARK_LIST_HELPER
    CMP         #$0280, MARK_LIST
    BEQ         PRINT_OUT_CODE_1
    CMP         #$FE00, MARK_LIST
    BEQ         PRINT_OUT_CODE_2
    CMP         #$00FE, MARK_LIST
    BEQ         PRINT_OUT_CODE_3
    CMP         #$0140, MARK_LIST
    BEQ         PRINT_OUT_CODE_4
    CMP         #$007F, MARK_LIST
    BEQ         PRINT_OUT_CODE_5
    CMP         #$7F00, MARK_LIST
    BEQ         PRINT_OUT_CODE_6
    JSR         PRINT_OUT_CODE
    RTS

SET_DIR
    MOVE.B      #1, D5
    MOVE        #1, MOVEM_DIR    * move direction
    BRA         back_from_dir

SET_SIZE
    MOVE.B      #1, MOVEM_SIZE    * move direction
    JSR         PRINT_LONG_SUF
    BRA         back_from_size
    ***** MOVE.B      #1, MOVEM_SIZE      * 1 for long, 0 for word

PRINT_OUT_ADDA
    LEA         ADDA_STR, A1
    BRA         ADDA_HELPER

ADDA_HELPER
    JSR         PRINT_FUNC
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_2ND_HEX_VAL
    JSR         LSL_8
    JSR         LSL_7
    JSR         LSR_7
    JSR         LSR_8
    ADD         #1, D3
    JSR         PRINT_NOT_NORM_SUF
    JSR         PRINT_DATA_MODE_SRC
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_ADDR_REG
    MOVE.W      DEST_REG, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_OUT_OR
    LEA         OR_STR, A1
    BRA         ADD_AND_SUB_HELPER

PRINT_OUT_ADD
    LEA         ADD_STR, A1
    BRA         ADD_AND_SUB_HELPER

PRINT_OUT_AND
    LEA         AND_STR, A1
    BRA         ADD_AND_SUB_HELPER

PRINT_OUT_SUB
    LEA         SUB_STR, A1
    BRA         ADD_AND_SUB_HELPER

ADD_AND_SUB_HELPER
    JSR         PRINT_FUNC
    JSR         PRINT_NORM_SUF
    JSR         PRINT_SPACE
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    CMP         #0,  EFFECTIVE_MODE
    BNE         SUB_HELPER_FUNC
    JSR         PRINT_DATA_MODE_SRC
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_REG
    MOVE.W      DEST_REG, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

ERROR_BAD_EA
    JSR         PRINT_SPACE
    JSR         PRINT_SPACE
    LEA         BAD_EA_MESSAGE, A1
    JSR         PRINT_FUNC
    *CMP         #0,  EFFECTIVE_MODE

    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

SUB_HELPER_FUNC
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    MOVE.W      DEST_REG, D3
    MOVE.W      EFFECTIVE_REG, DEST_REG
    MOVE.W      D3, EFFECTIVE_REG
    MOVE.W      DEST_MODE, D3
    MOVE.W      EFFECTIVE_MODE, DEST_MODE
    MOVE.W      D3, EFFECTIVE_MODE
    MOVE.W      EFFECTIVE_MODE,  D3
    MOVE.W      EFFECTIVE_REG, TEMP_VAR_3
    JSR         LSR_2
    JSR         CMP_0
    BEQ         SUB_HELPER_REG_TO_MEM
    JSR         REG_MODE_000
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_MODE_DEST
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

SUB_HELPER_REG_TO_MEM
    MOVE.W      DEST_REG, TEMP_VAR_3
    JSR         PRINT_DATA_MODE_DEST
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    MOVE.W      EFFECTIVE_REG, TEMP_VAR_3
    JSR         REG_MODE_000
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_OUT_BRA
    LEA         BRA_STR, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    JSR         PRINT_DOLLAR
    MOVE.W      A2, D4
    JSR         GET_NEXT_WORD
    ADD         D3, D4
    MOVE.W      D4,  TEMP_WORD
    JSR         HEX_TO_ASCII
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE

PRINT_OUT_Bcc
    LSL         #8, D7
    LSR         #8, D7
    LEA         B, A1
    JSR         PRINT_FUNC
    LEA         COND_JMP_TABLE, A6
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    JSR         MULU_6
    JSR         (A6, D3)
    CMP.B       #$00, D7
    BEQ         Bcc_WORD
    BRA         Bcc_NON_WORD

Bcc_NON_WORD
    JSR         PRINT_BYTE_SUF
    JSR         PRINT_SPACE
    JSR         PRINT_DOLLAR
    MOVE.W      A2, D4
    ADD         D3, D4
    MOVE.W      D4, TEMP_WORD
    JSR         HEX_TO_ASCII
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE

Bcc_WORD
    JSR         PRINT_WORD_SUF
    JSR         PRINT_SPACE
    JSR         PRINT_DOLLAR
    MOVE.W      A2, D4
    JSR         GET_NEXT_WORD
    ADD         D3, D4
    MOVE.W      D4, TEMP_WORD
    JSR         HEX_TO_ASCII
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE

PRINT_OUT_LOGICAL_SHIFT_MEM
    LEA         LS_STR, A1
    JSR         ASD_LSD_ROD_SHIFT_HELPER
    RTS

PRINT_OUT_ARITH_SHIFT_MEM
    LEA         AS_STR, A1
    JSR         ASD_LSD_ROD_SHIFT_HELPER
    RTS

ASD_LSD_ROD_SHIFT_HELPER
    JSR         PRINT_FUNC
    LEA         L_R_JMP_TABLE, A6
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_2ND_HEX_VAL
    JSR         LSL_8
    JSR         LSL_7
    JSR         LSR_7
    JSR         LSR_8
    JSR        MULU_6
    JSR         (A6, D3)
    JSR         PRINT_NORM_WORD_SUF
    MOVE.W      EFFECTIVE_REG, TEMP_VAR_3
    JSR         PRINT_DATA_MODE_SRC
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_OUT_ROT_MEM
    LEA         RO_STR, A1
    JSR         ASD_LSD_ROD_SHIFT_HELPER
    RTS

PRINT_OUT_ASD_OR_LSD
    MOVE.W      TEMP_WORD, D3
    JSR         GET_4TH_HEX_VAL
    JSR         LSR_3
    JSR         CMP_0
    BEQ         PRINT_OUT_ASD
    BRA         PRINT_OUT_LSD
    RTS

PRINT_OUT_ASD
    LEA         AS_STR, A1
    JSR         ASD_LSD_ROD_HELPER_FUNC
    RTS

PRINT_OUT_LSD
    LEA         LS_STR, A1
    JSR         ASD_LSD_ROD_HELPER_FUNC
    RTS

PRINT_OUT_ROD
    MOVE.W      TEMP_WORD, D3
    JSR         GET_4TH_HEX_VAL
    JSR         LSR_3
    CMP         #1, D3
    BNE         INVALID
    LEA         RO_STR, A1
    JSR         ASD_LSD_ROD_HELPER_FUNC
    RTS

ASD_LSD_ROD_HELPER_FUNC
    JSR         PRINT_FUNC
    LEA         L_R_JMP_TABLE, A6
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_2ND_HEX_VAL
    JSR         LSL_8
    JSR         LSL_7
    JSR         LSR_8
    JSR         LSR_7
    JSR        MULU_6
    JSR         (A6, D3)
    MOVE.W      TEMP_WORD, D3
    JSR         PRINT_NORM_SUF
    MOVE.W      TEMP_WORD, D3
    JSR         GET_3RD_HEX_VAL
    JSR         LSL_8
    JSR         LSL_6
    JSR         LSR_8
    JSR         LSR_7
    LEA         IMMED_REG_JMP_TABLE, A6
    JSR        MULU_6
    JSR         (A6, D3)
    JSR         PRINT_DATA_REG
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    MOVE.W      EFFECTIVE_REG, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

MOVE_OPCODE_HELPER
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    CMP         #%001,  DEST_MODE
    BEQ         PRINT_OUT_MOVEA
    BRA         PRINT_OUT_MOVE
    RTS

PRINT_OUT_MOVEA
    LEA         MOVEA_STR, A1
    JSR         MOVE_SECOND_OPCODE_HELPER
PRINT_OUT_MOVE
    LEA         MOVE_STR, A1
    JSR         MOVE_SECOND_OPCODE_HELPER
MOVE_SECOND_OPCODE_HELPER
    JSR         PRINT_FUNC
    LEA         MOVE_SIZE_PRINT_JMP_TABLE, A6
    MOVE.W      TEMP_WORD, D3
    JSR         GET_1ST_HEX_VAL
    JSR         MULU_6
    JSR         (A6, D3)
    JSR         PRINT_DATA_MODE_SRC
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    JSR         PRINT_DATA_MODE_DEST
    BSR         CONTINUE_PROGRAM
    BRA         PARSE_OP_CODE
    RTS

PRINT_FUNC
    MOVE.B      #14, D0
    TRAP        #15
    RTS

PRINT_DATA_MODE_SRC
    LEA         REG_MODE_JMP_TABLE, A6
    MOVE.W      EFFECTIVE_REG, TEMP_VAR_3
    MOVE        EFFECTIVE_MODE, D3
    JSR        MULU_6
    JSR         (A6, D3)
    RTS

PRINT_DATA_MODE_DEST
    LEA         REG_MODE_JMP_TABLE, A6
    MOVE.W      DEST_REG, TEMP_VAR_3
    MOVE.W      DEST_MODE, D3
    JSR         MULU_6
    JSR         (A6, D3)
    RTS

PRINT_ADDR_LOC
    MOVE.L      A2, D5
    LSR         #8, D5
    LSR         #8, D5
    MOVE.W      D5, TEMP_WORD
    JSR         HEX_TO_ASCII
    MOVE.W      A2, D5
    MOVE.W      D5, TEMP_WORD
    JSR         HEX_TO_ASCII
    JSR         PRINT_SPACE
    RTS

PRINT_MOVEM_LONG_ADDRESS
    MOVEQ   #15, D0
    MOVEQ   #16, D2
    MOVE.L  A5, D1
    TRAP   #15
    RTS

PRINT_MOVEM_WORD_ADDRESS
    MOVEQ   #15, D0
    MOVEQ   #16, D2
    MOVE.W  A5, D1
    TRAP   #15
    RTS

* Regular symbols or other easier print methods
PRINT_COMMA
    LEA         COMMA, A1
    JSR         PRINT_FUNC
    RTS
PRINT_ADDR_REG
    LEA         ADDRESS_REG, A1
    JSR         PRINT_FUNC
    RTS
PRINT_DATA_REG
    LEA         DATA_REG, A1
    JSR         PRINT_FUNC
    RTS
PRINT_OPEN_PAREN
    LEA         OPEN_PAREN, A1
    JSR         PRINT_FUNC
    RTS
PRINT_CLOSE_PAREN
    LEA         CLOSE_PAREN, A1
    JSR         PRINT_FUNC
    RTS
PRINT_PLUS
    LEA         PLUS, A1
    JSR         PRINT_FUNC
    RTS
PRINT_MINUS
    LEA         MINUS, A1
    JSR         PRINT_FUNC
    RTS
PRINT_DOLLAR
    LEA         DOLLAR, A1
    JSR         PRINT_FUNC
    RTS
PRINT_SPACE
    LEA         SPACE, A1
    JSR         PRINT_FUNC
    RTS
PRINT_HASHTAG
    LEA         HASHTAG, A1
    JSR         PRINT_FUNC
    RTS

* get data from memory
GET_1ST_HEX_VAL
    JSR         LSR_8
    JSR         LSR_4
    RTS
GET_2ND_HEX_VAL
    JSR         LSL_4
    JSR         LSR_4
    JSR         LSR_8
    RTS
GET_3RD_HEX_VAL
    JSR         LSL_8
    JSR         LSR_8
    JSR         LSR_4
    RTS
GET_4TH_HEX_VAL
    JSR         LSL_8
    JSR         LSL_4
    JSR         LSR_8
    JSR         LSR_4
    RTS

* gets next Long from memory
GET_NEXT_LONG
    MOVE.L      (A2)+, D3
    MOVE.L      D3, TEMP_LONG
    RTS

* Iterates through words, checks if they are past the end address, if it is, should show final message
GET_NEXT_WORD
    MOVE.W      (A2)+, D3
    MOVE.W      D3, TEMP_WORD
    CMPA.L      A2, A3
    BLE         FINISH_DISASSEMBLING
    RTS
* gets the next byte in memory
GET_NEXT_BYTE
    MOVE.B      (A2)+, D3
    MOVE.B      D3,  TEMP_BYTE
    RTS

GET_NORM_SIZE
    JSR         CHECK_TYPE_DATA
    MOVE.W      DEST_MODE, D3
    JSR         LSL_8
    JSR         LSL_6
    JSR         LSR_8
    JSR         LSR_6
    RTS

FINISH_DISASSEMBLING
    CLR         D6
    LEA         NEW_LINE, A1
    MOVE.B      #13, D0
    TRAP        #15
    JSR         PRINT_BAR
    LEA         FINISH, A1
    MOVE.B      #13, D0
    TRAP        #15
    LEA         END_QUESTION, A1
    MOVE.B      #13, D0
    TRAP        #15
    MOVE        #4, d0
    TRAP        #15
    CMP.B       #1, D1
    BEQ         START
    BRA         EXIT

*  checks the data in the op code
CHECK_TYPE_DATA
    MOVE.W      TEMP_WORD, D3
    JSR         LSL_4               * shifts bits to get data needed for the dest var, dest mode, source mode, and source var
    JSR         LSR_4
    JSR         LSR_8
    JSR         LSR_1
    MOVE.W      D3, DEST_REG        * determines the destination variable
    MOVE.W      TEMP_WORD, D3
    JSR         LSL_7
    JSR         LSR_7
    JSR         LSR_6
    MOVE.W      D3, DEST_MODE       * determines the destination mode
    MOVE.W      TEMP_WORD, D3
    JSR         LSL_8
    JSR         LSL_2
    JSR         LSR_8
    JSR         LSR_2
    JSR         LSR_3
    MOVE.W      D3, EFFECTIVE_MODE       * determines the source mode
    MOVE.W      TEMP_WORD, D3
    JSR         LSL_8
    JSR         LSL_5
    JSR         LSR_8
    JSR         LSR_5
    MOVE.W      D3, EFFECTIVE_REG       * determines the source variable
    MOVE.W      TEMP_WORD, D3
    RTS

FIRST_HEX_4_SECOND_HEX_E
    MOVE.W      TEMP_WORD, D3
    JSR         LSL_8
    JSR         LSR_8
    CMP.B       #$71, D3
    BEQ         PRINT_OUT_NOP
    CMP.B       #$75, D3
    BEQ         PRINT_OUT_RTS
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    MOVE.W      TEMP_WORD, D3
    JSR         GET_3RD_HEX_VAL
    LSR         #2,  D3
    CMP         #%10,  D3
    BEQ         PRINT_OUT_JSR
    BRA         INVALID
    RTS

* first hex value (for opcode) table -- offset is 6 bytes thus the MULU   #6, D3
FIRST_HEX_VAL_JMP_TABLE
    JMP         FIRST_HEX_VAL_IS_0                 * N/A
    JMP         FIRST_HEX_VAL_IS_1                 * MOVE.B,  MOVEA.B
    JMP         FIRST_HEX_VAL_IS_2                 * MOVEA.L,  MOVE.L
    JMP         FIRST_HEX_VAL_IS_3                 * MOVE.W    MOVEA.W
    JMP         FIRST_HEX_VAL_IS_4                 * NOP,  LEA,  JSR,  RTS, MOVEM (still working on)
    JMP         FIRST_HEX_VAL_IS_5                 * ADDQ
    JMP         FIRST_HEX_VAL_IS_6                 * Bcc (BGT, BLE, BEQ)
    JMP         FIRST_HEX_VAL_IS_7                 * N/A
    JMP         FIRST_HEX_VAL_IS_8                 * OR
    JMP         FIRST_HEX_VAL_IS_9                 * SUB
    JMP         FIRST_HEX_VAL_IS_A                 * N/A
    JMP         FIRST_HEX_VAL_IS_B                 * N/A
    JMP         FIRST_HEX_VAL_IS_C                 * MULS
    JMP         FIRST_HEX_VAL_IS_D                 * ADD,  ADDA
    JMP         FIRST_HEX_VAL_IS_E                 * LSR,  LSL,  ASR,  ASL,  ROL,  ROR
    JMP         FIRST_HEX_VAL_IS_F                 * N/A

REGISTER_LIST_MARK_POST
    JMP         PRINT_POST_1                 * A7
    JMP         PRINT_POST_2                 * A6
    JMP         PRINT_POST_3                 * A5
    JMP         PRINT_POST_4                 * A4
    JMP         PRINT_POST_5                 * A3
    JMP         PRINT_POST_6                 * A2
    JMP         PRINT_POST_7                 * A1
    JMP         PRINT_POST_8                 * A0
    JMP         PRINT_POST_9                 * D7
    JMP         PRINT_POST_10                 * D6
    JMP         PRINT_POST_11                 * D5
    JMP         PRINT_POST_12                 * D4
    JMP         PRINT_POST_13                 * D3
    JMP         PRINT_POST_14                 * D2
    JMP         PRINT_POST_15                 * D1
    JMP         PRINT_POST_16                 * D0

FIRST_HEX_VAL_IS_0
    BRA         INVALID
    RTS
FIRST_HEX_VAL_IS_1
    JSR         MOVE_OPCODE_HELPER
FIRST_HEX_VAL_IS_2
    JSR         MOVE_OPCODE_HELPER
FIRST_HEX_VAL_IS_3
    JSR         MOVE_OPCODE_HELPER

* typical format for a opcode being parsed
FIRST_HEX_VAL_IS_4
    CLR         D7
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    MOVE.W      D3, D7
    CMP.B       #$E, D3
    BEQ         FIRST_HEX_4_SECOND_HEX_E
    CMP         #$6, D3
    BEQ         PRINT_OUT_NOT
    CMP         #$8, D3
    BEQ         PRINT_OUT_MOVEM
    CMP         #$C, D3
    BEQ         PRINT_OUT_MOVEM
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    CMP         #%111, DEST_MODE
    BEQ         PRINT_OUT_LEA
    BRA         INVALID
    RTS
FIRST_HEX_VAL_IS_5
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORM_SIZE
    CMP         #%11, D3
    BEQ         INVALID
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    JSR         LSL_8
    JSR         LSL_7
    JSR         LSR_8
    JSR         LSR_7
    JSR         CMP_0
    BEQ         PRINT_OUT_ADDQ
    BRA         INVALID
    RTS
FIRST_HEX_VAL_IS_6
    CLR         D7
    MOVE.W      TEMP_WORD, D3
    MOVE.W      D3, D7
    JSR         GET_2ND_HEX_VAL
    CMP         #%0000, D3
    BEQ         PRINT_OUT_BRA
    CMP         #%0001, D3
    BEQ         INVALID
    BRA         PRINT_OUT_Bcc
    RTS
FIRST_HEX_VAL_IS_7
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    JSR         LSL_8
    JSR         LSL_7
    JSR         LSR_8
    JSR         LSR_7
    JSR         CMP_0
    BEQ         PRINT_OUT_MOVEQ
    BRA         INVALID
FIRST_HEX_VAL_IS_8
    CLR         D5
    MOVE.W      TEMP_WORD,  D3
    JSR         CHECK_TYPE_DATA
    CMP         #%111,  DEST_MODE
    BEQ         INVALID             * DIVS
    CMP         #%011,  DEST_MODE
    BEQ         INVALID             * DIVU
    BRA         PRINT_OUT_OR
    RTS
FIRST_HEX_VAL_IS_9
    MOVE.B      #9, D5
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORM_SIZE
    CMP         #%11, D3
    BEQ         INVALID
    BRA         PRINT_OUT_SUB
FIRST_HEX_VAL_IS_A
    BRA         INVALID
FIRST_HEX_VAL_IS_B
    BRA         INVALID
FIRST_HEX_VAL_IS_C
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORM_SIZE
    CMP         #%11,D3
    BEQ         MULU_MULS
    BRA         PRINT_OUT_AND
    RTS
MULU_MULS
    MOVE.W      TEMP_WORD,D3
    JSR         GET_2ND_HEX_VAL
    JSR         LSL_8
    JSR         LSL_7
    JSR         LSR_7
    JSR         LSR_8
    CMP         #1,D3
    BEQ         PRINT_OUT_MULS
    BRA         PRINT_OUT_MULU
FIRST_HEX_VAL_IS_D
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORM_SIZE
    CMP         #%11, D3
    BEQ         PRINT_OUT_ADDA
    BRA         PRINT_OUT_ADD
    RTS
FIRST_HEX_VAL_IS_E
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORM_SIZE
    CMP         #%11, D3
    BEQ         SPECIAL_SHIFT_INSTRUC
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_3RD_HEX_VAL
    JSR         LSL_8
    JSR         LSL_7
    JSR         LSR_7
    JSR         LSR_8
    JSR         CMP_0
    BEQ         PRINT_OUT_ASD_OR_LSD
    BRA         PRINT_OUT_ROD
    RTS
FIRST_HEX_VAL_IS_F
    RTS


SPECIAL_SHIFT_INSTRUC
    MOVE.W      TEMP_WORD, D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_2ND_HEX_VAL
    LSR         #1,  D3
    CMP         #1, D3
    BEQ         PRINT_OUT_LOGICAL_SHIFT_MEM
    JSR         CMP_0
    BEQ         PRINT_OUT_ARITH_SHIFT_MEM
    CMP         #%11, D3
    BEQ         PRINT_OUT_ROT_MEM
    BRA         INVALID
    RTS

REG_MODE_JMP_TABLE
    JMP         REG_MODE_000             * Dn
    JMP         REG_MODE_001             * An
    JMP         REG_MODE_010             * (An)
    JMP         REG_MODE_011             * (An)+
    JMP         REG_MODE_100             * -(An)
    JMP         REG_MODE_101             * N/A
    JMP         REG_MODE_110             * N/A
    JMP         REG_MODE_111             * N/A

REG_MODE_000
    JSR         PRINT_DATA_REG
    JSR         PRINT_REG_NUM
    RTS
REG_MODE_001
    JSR         PRINT_ADDR_REG
    JSR         PRINT_REG_NUM
    RTS
REG_MODE_010
    JSR         PRINT_OPEN_PAREN
    JSR         REG_MODE_001
    JSR         PRINT_CLOSE_PAREN
    RTS
REG_MODE_011
    JSR         REG_MODE_010
    JSR         PRINT_PLUS
    RTS
REG_MODE_100
    JSR         PRINT_MINUS
    JSR         REG_MODE_010
    RTS
REG_MODE_101
    BRA         INVALID
    RTS
REG_MODE_110
    BRA         INVALID
    RTS
REG_MODE_111
    LEA         REG_111_JMP_TABLE, A4
    MOVE.W      TEMP_VAR_3, D3
    JSR        MULU_6
    JSR         (A4, D3)
    LEA         SHORT_OR_LONG_PRINT, A4
    MOVE.W      TEMP_VAR_3, D3
    JSR        MULU_6
    JSR         (A4, D3)
    RTS

SHORT_OR_LONG_PRINT
    JMP         ABS_SHORT
    JMP         ABS_LONG
    JMP         COUNTER_DISPLACEMENT
    JMP         COUNTER_INDEX
    JMP         IMMED_DATA

ABS_SHORT
    JSR         GET_NEXT_WORD
    JSR         HEX_TO_ASCII
    RTS

ABS_LONG
    JSR         ABS_SHORT
    JSR         ABS_SHORT
    RTS

COUNTER_DISPLACEMENT
    BRA         INVALID

COUNTER_INDEX
    BRA         INVALID

IMMED_DATA
    JSR         GET_NORM_SIZE
    LSR         #1,  D3
    LEA         SHORT_OR_LONG_PRINT, A4
    JSR        MULU_6
    ADD.W       D3, A4
    JSR         (A4)
    RTS

REG_111_JMP_TABLE
    JMP         PRINT_DOLLAR_SIGN
    JMP         PRINT_LONG_SYMBOL
    JMP         SUP_FUNC_3
    JMP         SUP_FUNC_4
    JMP         PRINT_HASHTAG_DOLLAR

PRINT_DOLLAR_SIGN
    JSR         PRINT_DOLLAR
    RTS

PRINT_LONG_SYMBOL
    JSR         PRINT_DOLLAR
    RTS

SUP_FUNC_3
    BRA         INVALID

SUP_FUNC_4
    BRA        INVALID

PRINT_HASHTAG_DOLLAR
    JSR         PRINT_HASHTAG
    JSR         PRINT_DOLLAR
    RTS

PRINT_BAR
    LEA         BAR, A1
    MOVE.B      #13, D0
    TRAP        #15
    LEA         NEW_LINE, A1
    MOVE.B      #13, D0
    TRAP        #15
    RTS

HEX_JMP_TABLE
    JMP         PRINT_0
    JMP         PRINT_1
    JMP         PRINT_2
    JMP         PRINT_3
    JMP         PRINT_4
    JMP         PRINT_5
    JMP         PRINT_6
    JMP         PRINT_7
    JMP         PRINT_8
    JMP         PRINT_9
    JMP         PRINT_A
    JMP         PRINT_B
    JMP         PRINT_C
    JMP         PRINT_D
    JMP         PRINT_E
    JMP         PRINT_F

* Other easy print symbols, numbers, or letters
PRINT_0
    LEA         ZERO, A1
    JSR         PRINT_FUNC
    RTS
PRINT_1
    LEA         ONE, A1
    JSR         PRINT_FUNC
    RTS
PRINT_2
    LEA         TWO, A1
    JSR         PRINT_FUNC
    RTS
PRINT_3
    LEA         THREE, A1
    JSR         PRINT_FUNC
    RTS
PRINT_4
    LEA         FOUR, A1
    JSR         PRINT_FUNC
    RTS
PRINT_5
    LEA         FIVE, A1
    JSR         PRINT_FUNC
    RTS
PRINT_6
    LEA         SIX, A1
    JSR         PRINT_FUNC
    RTS
PRINT_7
    LEA         SEVEN, A1
    JSR         PRINT_FUNC
    RTS
PRINT_8
    LEA         EIGHT, A1
    JSR         PRINT_FUNC
    RTS
PRINT_9
    LEA         NINE, A1
    JSR         PRINT_FUNC
    RTS
PRINT_A
    LEA         A, A1
    JSR         PRINT_FUNC
    RTS
PRINT_B
    LEA         B, A1
    JSR         PRINT_FUNC
    RTS
PRINT_C
    LEA         C, A1
    JSR         PRINT_FUNC
    RTS
PRINT_D
    LEA         D, A1
    JSR         PRINT_FUNC
    RTS
PRINT_E
    LEA         E, A1
    JSR         PRINT_FUNC
    RTS
PRINT_F
    LEA         F, A1
    JSR         PRINT_FUNC
    RTS

TEST_PRINT_1
    LEA         TEST_1, A1
    JSR         PRINT_FUNC
    RTS

TEST_PRINT_2
    LEA         TEST_2, A1
    JSR         PRINT_FUNC
    RTS

TEST_PRINT_3
    LEA         TEST_3, A1
    JSR         PRINT_FUNC
    RTS

TEST_PRINT_4
    LEA         TEST_4, A1
    JSR         PRINT_FUNC
    RTS

MOVE_SIZE_PRINT_JMP_TABLE
    JMP         NS_MOVE_SIZE  * NS = not supported
    JMP         PRINT_BYTE_SUF
    JMP         PRINT_LONG_SUF
    JMP         PRINT_WORD_SUF

NS_MOVE_SIZE
    BRA         INVALID
    RTS

PRINT_BYTE_SUF
    LEA         BYTE_SUF, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    RTS
PRINT_LONG_SUF
    LEA         LONG_SUF, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    RTS
PRINT_WORD_SUF
    LEA         WORD_SUF, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    RTS

NORM_SIZE_PRINT_JMP_TABLE:
    JMP         PRINT_NORM_BYTE_SUF
    JMP         PRINT_NORM_WORD_SUF
    JMP         PRINT_NORM_LONG_SUF
    BRA         INVALID
PRINT_NORM_BYTE_SUF
    LEA         BYTE_SUF, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    RTS
PRINT_NORM_WORD_SUF
    LEA         WORD_SUF, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    RTS
PRINT_NORM_LONG_SUF
    LEA         LONG_SUF, A1
    JSR         PRINT_FUNC
    JSR         PRINT_SPACE
    RTS

PRINT_POST_1
    LEA         POST_1, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_2
    LEA         POST_2, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_3
    LEA         POST_3, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_4
    LEA         POST_4, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_5
    LEA         POST_5, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_6
    LEA         POST_6, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_7
    LEA         POST_7, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_8
    LEA         POST_8, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_9
    LEA         POST_9, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_10
    LEA         POST_10, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_11
    LEA         POST_11, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_12
    LEA         POST_12, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_13
    LEA         POST_13, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_14
    LEA         POST_14, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_15
    LEA         POST_15, A1
    JSR     PRINT_FUNC
    RTS
PRINT_POST_16
    LEA         POST_16, A1
    JSR     PRINT_FUNC
    RTS

PRINT_OUT_CODE
    LEA         CODE_7, A1
    JSR         PRINT_FUNC
    RTS

PRINT_OUT_CODE_1
    LEA         CODE_1, A1
    JSR         PRINT_FUNC
    RTS

PRINT_OUT_CODE_2
    LEA         CODE_2, A1
    JSR         PRINT_FUNC
    RTS

PRINT_OUT_CODE_3
    LEA         CODE_3, A1
    JSR         PRINT_FUNC
    RTS

PRINT_OUT_CODE_4
    LEA         CODE_4, A1
    JSR         PRINT_FUNC
    RTS

PRINT_OUT_CODE_5
    LEA         CODE_5, A1
    JSR         PRINT_FUNC
    RTS

PRINT_OUT_CODE_6
    LEA         CODE_6, A1
    JSR         PRINT_FUNC
    RTS

COND_JMP_TABLE
    JMP         COND_TRUE
    JMP         COND_TRUE
    JMP         COND_HIGHER
    JMP         COND_LOWER_OR_SAME
    JMP         COND_CARRY_CLEAR
    JMP         COND_CARRY_SET
    JMP         COND_NOT_EQUAL
    JMP         COND_EQUAL
    JMP         COND_OVERFLOW_CLEAR
    JMP         COND_OVERFLOW_SET
    JMP         COND_PLUS
    JMP         COND_MINUS
    JMP         COND_GRE_OR_EQUAL
    JMP         COND_LESS_THAN
    JMP         COND_GRE_THAN
    JMP         COND_LESS_OR_EQUAL

COND_TRUE
    BRA         INVALID
COND_FALSE
    BRA         INVALID
COND_HIGHER
    LEA         HIGHER_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_LOWER_OR_SAME
    LEA         LOWER_OR_SAME_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_CARRY_CLEAR
    LEA         CARRY_CLEAR_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_CARRY_SET
    LEA         CARRY_SET_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_NOT_EQUAL
    LEA         NOT_EQUAL_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_EQUAL
    LEA         EQUAL_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_OVERFLOW_CLEAR
    LEA         OVERFLOW_CLEAR_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_OVERFLOW_SET
    LEA         OVERFLOW_SET_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_PLUS
    LEA         PLUS_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_MINUS
    LEA         MINUS_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_GRE_OR_EQUAL
    LEA         GREATER_OR_EQUAL_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_LESS_THAN
    LEA         LESS_THAN_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_GRE_THAN
    LEA         GREATER_THAN_STR, A1
    JSR         PRINT_FUNC
    RTS
COND_LESS_OR_EQUAL
    LEA         LESS_OR_EQUAL_STR, A1
    JSR         PRINT_FUNC
    RTS
L_R_JMP_TABLE
    JMP         RIGHT_PRINT
    JMP         LEFT_PRINT
RIGHT_PRINT
    LEA         RIGHT, A1
    JSR         PRINT_FUNC
    RTS
LEFT_PRINT
    LEA         LEFT, A1
    JSR         PRINT_FUNC
    RTS
IMMED_REG_JMP_TABLE
    JMP         IMMED_ROT
    JMP         REG_ROT
IMMED_ROT
    LEA         HASHTAG, A1
    JSR         PRINT_FUNC
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    JSR         LSR_1
    JSR         CMP_0
    BEQ         IMMED_ROT_HELPER
    MOVE.W      D3, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    RTS
REG_ROT
    LEA         DATA_REG, A1
    JSR         PRINT_FUNC
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    JSR         LSR_1
    MOVE.W      D3, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    RTS
IMMED_ROT_HELPER
    MOVE.W      #8, TEMP_VAR_3
    JSR         PRINT_REG_NUM
    JSR         PRINT_COMMA
    JSR         PRINT_SPACE
    RTS

*Helper functions
LSR_1
    LSR         #1, D3
    RTS
LSR_2
    LSR         #2, D3
    RTS
LSR_3
    LSR         #3, D3
    RTS
LSR_4
    LSR         #4, D3
    RTS
LSR_5
    LSR         #5, D3
    RTS
LSR_6
    LSR         #6, D3
    RTS
LSR_7
    LSR         #7, D3
    RTS
LSR_8
    LSR         #8, D3
    RTS

LSL_2
    LSL          #2, D3
    RTS
LSL_4
    LSL          #4, D3
    RTS
LSL_5
    LSL          #5, D3
    RTS
LSL_6
    LSL          #6, D3
    RTS
LSL_7
    LSL          #7, D3
    RTS
LSL_8
    LSL          #8, D3
    RTS
MULU_6
    MULU         #6, D3
    RTS
CMP_0
    CMP          #0, D3
    RTS

HEX_HELPER_1
    MOVE.W      TEMP_WORD, D3
    JSR         GET_1ST_HEX_VAL
    JSR        MULU_6
    JSR         (A4, D3)
    RTS
HEX_HELPER_2
    MOVE.W      TEMP_WORD, D3
    JSR         GET_2ND_HEX_VAL
    JSR        MULU_6
    JSR         (A4, D3)
    RTS
HEX_HELPER_3
    MOVE.W      TEMP_WORD, D3
    JSR         GET_3RD_HEX_VAL
    JSR        MULU_6
    JSR         (A4, D3)
    RTS
HEX_HELPER_4
    MOVE.W      TEMP_WORD, D3
    JSR         GET_4TH_HEX_VAL
    JSR        MULU_6
    JSR         (A4, D3)
    RTS

PARSE_OP_CODE     * Function to parse the input
    JSR         PRINT_ADDR_LOC      * print location, I.E. $7000
    JSR         GET_NEXT_WORD       * get next word of data, compare current address and end address
    MOVE.W      TEMP_WORD, D3       * move to D3 for storage.
    JSR         GET_1ST_HEX_VAL        * get the first char
    JSR         MULU_6              * multiply it by 6
    JSR         (A0, D3)           * use FIRST_HEX_VAL_JMP_TABLE with offset.



DONE
    BRA FINISH_DISASSEMBLING

EXIT

* String constants located here, used for printing to screen.
INTRO_START               DC.W        'Please enter a starting address after $2000.', 0
INTRO_END                 DC.W        'Please enter a ending address after the starting address.', 0
INVALID_INPUT             DC.W        'Invalid input, please re-enter', 0
FINISH                    DC.W        'Finished, you either hit end address or ran out of data. ', 0
BAR                         DC.L        '*******************************************************************************', 0
END_QUESTION               DC.L        'Do you want to restart the program? Enter 1 for yes and 0 for no. ', 0
NEW_LINE                    DC.L        ' ', 0
BAD_EA_MESSAGE              DC.L            'NOTE:  Bad effective address entered, error. '
TEST_1                        DC.L        'Test 1 '
TEST_2                        DC.L        'Test 2 '
TEST_3                        DC.L        'Test 3 '
TEST_4                        DC.L        'Test 4 '



* Hex Numbers
ZERO                        DC.W        '0', 0
ONE                         DC.W        '1', 0
TWO                         DC.W        '2', 0
THREE                     DC.W        '3', 0
FOUR                        DC.W        '4', 0
FIVE                        DC.W        '5', 0
SIX                         DC.W        '6', 0
SEVEN                     DC.W        '7', 0
EIGHT                     DC.W        '8', 0
NINE                        DC.W        '9', 0
A                           DC.W        'A', 0
B                           DC.W        'B', 0
C                           DC.W        'C', 0
D                           DC.W        'D', 0
E                           DC.W        'E', 0
F                           DC.W        'F', 0
CODE_1                        DC.W        'A1/D7', 0
CODE_2                        DC.W        'A1-A7', 0
CODE_3                        DC.W        'D1-D7', 0
CODE_4                        DC.W        'A1/D7', 0
CODE_5                        DC.W        'A1-A7', 0
CODE_6                        DC.W        'D1-D7', 0
CODE_7                        DC.W        'A1/A2, D7', 0

* Op Codes
NOP_STR                 DC.W        'NOP', 0
MOVE_STR                DC.W        'MOVE', 0
MOVEQ_STR               DC.W        'MOVEQ', 0
MOVEM_STR               DC.W        'MOVEM', 0
MOVEA_STR               DC.W        'MOVEA', 0
ADD_STR                 DC.W        'ADD', 0
ADDA_STR                DC.W        'ADDA', 0
ADDQ_STR                DC.W        'ADDQ', 0
SUB_STR                 DC.W        'SUB', 0
LEA_STR                 DC.W        'LEA', 0
AND_STR                 DC.W        'AND', 0
NOT_STR                 DC.W        'NOT', 0
AS_STR                  DC.W        'AS', 0
LS_STR                  DC.W        'LS', 0
RO_STR                  DC.W        'RO', 0
BSR_STR                 DC.W        'BSR', 0
RTS_STR                 DC.W        'RTS', 0
JSR_STR                 DC.W        'JSR', 0
BRA_STR                 DC.W        'BRA', 0

** Not needed :D
MULS_STR                DC.W        'MULS', 0
MULU_STR                DC.W        'MULU', 0

* Logic Chars
LEFT                    DC.W        'L', 0
RIGHT                   DC.W        'R', 0
OR_STR                  DC.W        'OR', 0
DATA_STR                DC.W        'DATA', 0
HIGHER_STR              DC.W        'HI', 0
LOWER_OR_SAME_STR     DC.W        'LS', 0
CARRY_CLEAR_STR       DC.W        'CC', 0
NOT_EQUAL_STR         DC.W        'NE', 0
EQUAL_STR               DC.W        'EQ', 0
OVERFLOW_CLEAR_STR    DC.W        'VC', 0
OVERFLOW_SET_STR      DC.W        'VS', 0
PLUS_STR                DC.W        'PL', 0
MINUS_STR               DC.W        'MI', 0
GREATER_OR_EQUAL_STR  DC.W        'GE', 0
LESS_THAN_STR         DC.W        'LT', 0
GREATER_THAN_STR      DC.W        'GT', 0
LESS_OR_EQUAL_STR     DC.W        'LE', 0
CARRY_SET_STR         DC.W        'CS', 0
SR_STR                  DC.W        'SR', 0




OPEN_PAREN              DC.W        '(', 0
CLOSE_PAREN             DC.W        ')', 0
PLUS                    DC.W        '+', 0
MINUS                   DC.W        '-', 0
SLASH                   DC.W        '/', 0
DATA_REG                DC.W        'D', 0
ADDRESS_REG             DC.W        'A', 0
BYTE_SUF               DC.W        '.B', 0
WORD_SUF               DC.W        '.W', 0
LONG_SUF               DC.W        '.L', 0
COMMA                     DC.W        ', ', 0
SPACE                     DC.W        ' ', 0
DOLLAR                DC.W        '$', 0
HASHTAG   DC.W        '#', 0
POST_1                       DC.W        'A7', 0
POST_2                       DC.W        'A6', 0
POST_3                       DC.W        'A5', 0
POST_4                       DC.W        'A4', 0
POST_5                       DC.W        'A3', 0
POST_6                       DC.W        'A2', 0
POST_7                       DC.W        'A1', 0
POST_8                       DC.W        'A0', 0
POST_9                       DC.W        'D7', 0
POST_10                       DC.W        'D6', 0
POST_11                       DC.W        'D5', 0
POST_12                       DC.W        'D4', 0
POST_13                       DC.W        'D3', 0
POST_14                       DC.W        'D2', 0
POST_15                       DC.W        'D1', 0
POST_16                       DC.W        'D0', 0
TEMP_CODE                       DC.W        'A1/D7', 0

    END    START
