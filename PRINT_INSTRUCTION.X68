*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
ALL_REG         REG     D0-D7/A0-A6         ; all registers 
CR              EQU     $0D                 ; carriage return
LF              EQU     $0A                 ; line feed

    ORG    $1000
START:



    LEA     MOVE_TAG,A6
    MOVE.B  #$2,D7
    MOVE.B  #$C1,D6
    MOVE.B  #$0,D5
    JSR     PRINT_INSTRUCTION
    
    MOVE.L  #$89AB,A6
    MOVE.B  #5,D7
    MOVE.W  #$1234, D6
    JSR     PRINT_INSTRUCTION
    SIMHALT             ; halt simulator


*********************       THE PRINT INSTRUCTION SUBROUTINE      **********************
*PARAMETERS     A6      INSTRUCTION TAG -> for good print
*                       MEMORY ADDRESS  -> for bad print
*               A5      THE POINTER________________________________________________________????????
*               D7      SIZE (0 IF NO SIZE REQUIRED)
*                       1=B, 2=W, 4=L   -> for good print
*                                   5   -> for bad print
*               D6      SOURCE EA (sd-mod-reg) -> s = source (check this to print
*                                                              the source)
*                                              -> d = destination ( check this to print
*                                                               the destination)
*                                              -> reg + mod = EA and mode
*                       DATA (OR BAD INSTRUCTION) -> for bad print
*               D5      DESTINATION EA (00-mod-reg)

PRINT_INSTRUCTION           MOVEM.L     ALL_REG,-(SP)
                        CMP.B   #5,D7                       * 5 INDICATES BAD PRINT
                        BEQ     BAD_PRINT                   * JUMP TO BAD PRINT

                        MOVE.L  A6,A1                       * PRINT INSTRUCTION
                        MOVE.B  #14,D0
                        TRAP    #15
                        
                        BTST    #7,D6                       * CHECKING IF HAS SOURCE EA
                        BEQ     PRINT_INSTRUCTION_RETURN    * JUST OP-CODE
                        
                        JSR     PRINT_SIZE
                        JSR     PRINT_TAB
                        MOVE.B  D6,D4
                        JSR     PRINT_EA                    * PRINT SOURCE EA
                        
                        BTST    #6,D6                       * CHECKING IF HAS DEST. EA
                        BEQ     PRINT_INSTRUCTION_RETURN    * ONLY ONE EA
                        
                        JSR     PRINT_COMMA
                        MOVE.B  D5,D4
                        JSR     PRINT_EA                    * PRINT DEST. EA
                        
                        
PRINT_INSTRUCTION_RETURN    JSR         PRINT_NEWLINE
                            MOVEM.L     (SP)+,ALL_REG
                            RTS                         * RETURN TO THE CALLER
*_______________________________________________________________________________________


*___________________    BAD PRINT   ____________________________________________________
*   PARAMETER       A6      MEMORY LOCATION
*                   D6      BAD INSTRUCTION (DATA)

BAD_PRINT       MOVE.L  A6,D5
                MOVE.B  #4,D3
                JSR     PRINT_HEX
                JSR     PRINT_TAB
                LEA     DATA_TAG,A1
                MOVE.B  #14, D0
                TRAP    #15
                JSR     PRINT_TAB
                MOVE.W  D6,D5
                MOVE.B  #2,D3
                JSR     PRINT_HEX
                BRA     PRINT_INSTRUCTION_RETURN                
                
*_______________________________________________________________________________________

*_______________________    PRINT HEX   _____________________________________
*   PARAMETER       D5      THE HEX TO PRINT
*                   D3      HOW MANY BYTE OF D5 TO PRINT

PRINT_HEX       MOVEM.L     ALL_REG,-(SP)
                LEA         PRINT_BUFFER, A1        *SETTING UP PRINT BUFFER
                ADD.L       #10,A1
                MOVE.B      #0,-(A1)                *NULL FOR PRINTER TO STOP
                BRA         POPULATE_BUFFER
                
PRINT_HEX_RETURN    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS
               
POPULATE_BUFFER     CMP.B       #0,D3
                    BEQ         PRINT_HEX_RETURN
                    MOVE.B      #$0F,D4
                    AND.B       D5,D4
                    ROR.B       #4,D5
                    JSR         HEX_TO_ASCII
                    MOVE.B      D4,-(A1)
                    MOVE.B      D5,D4
                    AND.B       #$0F,D4
                    JSR         HEX_TO_ASCII
                    MOVE.B      D4,-(A1)
                    LSR.L       #8,D5
                    SUB.B       #1,D3
                    BRA         POPULATE_BUFFER

HEX_TO_ASCII            MOVEM.L     A0-A6/D0-D2/D5-D7,-(SP)
                        CMP.B       #9,D4
                        BLE         NUMBER_TO_ASCII
                        ADD.B       #$37,D4
HEX_TO_ASCII_RETURN     MOVEM.L   (SP)+,A0-A6/D0-D2/D5-D7
                        RTS
                
NUMBER_TO_ASCII     ADD.B   #$30,D4
                    BRA     HEX_TO_ASCII_RETURN
*___________________________________________________________________________________



*___________________    PRINT SIZE  ____________________________________________________
    * PARAMETER     D7      THE CODE FOR SIZE (0 IF NO SIZE REQUIRED)
    *                                           1=B, 2=W, 4=L

PRINT_SIZE      MOVEM.L ALL_REG,-(SP)
                MOVE.B  #14,D0
                CMP.B   #0, D7
                BEQ     PRINT_SIZE_RETURN
                CMP.B   #1, D7
                BNE     SIZE_CHECK_W
                LEA     BYTE_TAG,A1                 * PRINT BYTE
                TRAP    #15
                BRA     PRINT_SIZE_RETURN
                
SIZE_CHECK_W        CMP.B   #2,D7
                    BNE     PRINT_LONG
                    LEA     WORD_TAG, A1            * PRINT WORD
                    TRAP    #15
                    BRA     PRINT_SIZE_RETURN

PRINT_LONG      LEA     LONG_TAG, A1                * PRINT LONG
                TRAP    #15                    
                
PRINT_SIZE_RETURN   MOVEM.L (SP)+,ALL_REG
                    RTS
*__________________________________________________________________________________



*______________     PRINT EA    ___________________________________________________
    *PARAMETER      D4      (--MODreg)
    
PRINT_EA        MOVEM.L ALL_REG,-(SP)
                MOVE.B  #$38,D3
                AND.B   D4,D3
                AND.B   #$7, D4
                
                CMP.B   #$0, D3
                BNE     CHECK_EA_AR
                ADD.B   #$D0, D4
                CLR.L   D1
                MOVE.B  D4, D1
                JSR     PRINT_REGISTOR              * DATA REG
                BRA     PRINT_EA_RETURN

CHECK_EA_AR         CMP.B   #$8, D3
                    BNE     CHECK_EA_INDIRECT
                    ADD.B   #$A0, D4
                    CLR.L   D1
                    MOVE.B  D4, D1
                    JSR     PRINT_REGISTOR          * ADDRESS REG
                    BRA     PRINT_EA_RETURN
                    
CHECK_EA_INDIRECT       CMP.B   #$10, D3
                        BNE     CHECK_EA_POST
                        JSR     PRINT_OPEN_PARENTHESIS      * (
                        ADD.B   #$A0, D4
                        CLR.L   D1
                        MOVE.B  D4, D1
                        JSR     PRINT_REGISTOR              * ADDRESS REG
                        JSR     PRINT_CLOSED_PARENTHESIS    * )
                        BRA     PRINT_EA_RETURN
                        
CHECK_EA_POST   CMP.B   #$18,D3
                BNE     CHECK_EA_PRE
                JSR     PRINT_OPEN_PARENTHESIS      * (
                ADD.B   #$A0, D4
                CLR.L   D1
                MOVE.B  D4, D1
                JSR     PRINT_REGISTOR              * ADDRESS REG
                JSR     PRINT_CLOSED_PARENTHESIS    * )
                JSR     PRINT_PLUS                  * +
                BRA     PRINT_EA_RETURN

CHECK_EA_PRE        CMP.B   #$20,D3
                    BNE     CHECK_EA_AB_W
                    JSR     PRINT_MINUS                 * -
                    JSR     PRINT_OPEN_PARENTHESIS      * (
                    ADD.B   #$A0, D4
                    CLR.L   D1
                    MOVE.B  D4, D1
                    JSR     PRINT_REGISTOR              * ADDRESS REG
                    JSR     PRINT_CLOSED_PARENTHESIS    * )
                    BRA     PRINT_EA_RETURN

CHECK_EA_AB_W           CMP.B   #$38,D3     
                        BNE     CHECK_EA_AB_L
                        MOVE.W  (A5)+,D5             * PRINTING WORD ABSOLUTE
                        MOVE.B  #2,D3
                        JSR     PRINT_HEX
                        BRA     PRINT_EA_RETURN
                        
CHECK_EA_AB_L       CMP.B   #$39, D3
                    BNE     CHECK_EA_IMM
                    MOVE.L  (A5)+,D5            * PRINTING LONG ABSOLUTE
                    MOVE.B  #4,D3
                    JSR     PRINT_HEX
                    BRA     PRINT_EA_RETURN
                    
CHECK_EA_IMM        CMP.B   #4,D7
                    BNE     READ_WORD_IMM
                    MOVE.L  (A5)+,D5        * PRINTING LONG IMMIDIATE
                    MOVE.B  #4,D3
                    JSR     PRINT_HEX
                    BRA     PRINT_EA_RETURN
                    
READ_WORD_IMM       MOVE.W  (A5)+,D5         * PRINTING WORD/BYTE IMMIDIATE        
                    MOVE.B  #2,D3
                    JSR     PRINT_HEX

PRINT_EA_RETURN     MOVEM.L     (SP)+,ALL_REG   * THE RETURN FOR THE EA PRINTER
                    RTS
*___________________________________________________________________________________


*   _______PRINT REGISTOR ______________________________________
    *PARAMETER      D1      CONTAINS THE REGISTOR CODE
    *RETURN                 NO RETURN, JUST PRINTING VALUE WITH OUT NEW LINE
PRINT_REGISTOR      MOVEM.L     ALL_REG,-(SP)       * keeping old value
                    MOVE.W      #00,-(SP)           *for printing purpose
                    MOVE.W      #$f0,D2             *manipulating each digit
                    AND.W       D1,D2
                    ASR.W       #4,D2
                    JSR         TO_STRING           * converts to the string ASCII val
                    ASL.W       #8,D2
                    
                    AND.W       #$F,D1              * the last digit
                    MOVE.B      D1,D2               
                    JSR         TO_STRING
                    MOVE.W      D2,-(SP)            * puting on the stack to print
                    
                    MOVE.L      SP,A1               * printing
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVE.L      (SP)+, D5           * Adjesting the sp

PRINT_REGISTOR_RETURN           MOVEM.L     (SP)+,ALL_REG   *returning the original val
                                RTS
                                
TO_STRING   CMP.B   #9,D2               * check if digit or leter
            BGT     LETTERS     
            ADD.B   #$30,D2             * offseting digit
            RTS
LETTERS     ADD.B   #$37,D2             * offseting leter
            RTS   
*________________________________________________________________________________________


*________________ PRINT OPEN PARENTHESIS ________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_OPEN_PARENTHESIS  MOVEM.L     ALL_REG, -(SP)
                        LEA         OPEN_PAR_TAG, A1
                        MOVE.B      #14,D0
                        TRAP        #15
                        MOVEM.L     (SP)+,ALL_REG
                        RTS
*_________________________________________________________________________________

*________________ PRINT CLOSED PARENTHESIS ________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_CLOSED_PARENTHESIS    MOVEM.L     ALL_REG, -(SP)
                            LEA         CLOSED_PAR_TAG, A1
                            MOVE.B      #14,D0
                            TRAP        #15
                            MOVEM.L     (SP)+,ALL_REG
                            RTS
*__________________________________________________________________________________

*________________ PRINT PLUS SIGN _________________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_PLUS      MOVEM.L     ALL_REG, -(SP)
                LEA         PLUS_TAG, A1
                MOVE.B      #14,D0
                TRAP        #15
                MOVEM.L     (SP)+,ALL_REG
                RTS
*_________________________________________________________________________________

*________________ PRINT MINUS SIGN _______________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_MINUS         MOVEM.L     ALL_REG, -(SP)
                    LEA         MINUS_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS
*_________________________________________________________________________________

*________________ PRINT COMMA ____________________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_COMMA         MOVEM.L     ALL_REG,-(SP)
                    LEA         COMMA_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS
*_________________________________________________________________________________

*________________ PRINT TAB ______________________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_TAB       MOVEM.L     ALL_REG,-(SP)
                LEA         TAB_TAG, A1
                MOVE.B      #14,D0
                TRAP        #15
                MOVEM.L     (SP)+,ALL_REG
                RTS
*_________________________________________________________________________________


*_______________    PRINT NEWLINE   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
        
PRINT_NEWLINE       MOVEM.L     ALL_REG,-(SP)
                    LEA         NEWLINE_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS

*___________________________________________________________________________________

*__________________________________________________________________________________
PRINT_BUFFER    DS.B    10

DATA_TAG        DC.B    'DATA',0
NEWLINE_TAG     DC.B    CR,LF,0
PLUS_TAG        DC.B    '+',0
MINUS_TAG       DC.B    '-',0
OPEN_PAR_TAG    DC.B    '(',0
CLOSED_PAR_TAG  DC.B    ')',0
TAB_TAG         DC.B    $9,0
SPACE_TAG       DC.B    ' ',0
COMMA_TAG       DC.B    ',',0
BYTE_TAG        DC.B    '.B',0
WORD_TAG        DC.B    '.W',0
LONG_TAG        DC.B    '.L',0

NOP_TAG         DC.B    'NOP',0
MOVE_TAG        DC.B    'MOVE',0
MOVEA_TAG       DC.B    'MOVEA',0
MOVEQ_TAG       DC.B    'MOVEQ',0
MOVEM_TAG       DC.B    'MOVEM',0
ADD_TAG         DC.B    'ADD',0
ADDA_TAG        DC.B    'ADDA',0
ADDQ_TAG        DC.B    'ADDQ',0
SUB_TAG         DC.B    'SUB',0
*MULS_TAG        DC.B    'MULS',0
*DIVU_TAG        DC.B    'DIVU',0
LEA_TAG         DC.B    'LEA',0
AND_TAG         DC.B    'AND',0
OR_TAG          DC.B    'OR',0
NOT_TAG         DC.B    'NOT',0
LSL_TAG         DC.B    'LSL',0
LSR_TAG         DC.B    'LSR',0
ASL_TAG         DC.B    'ASL',0
ASR_TAG         DC.B    'ASR',0
ROL_TAG         DC.B    'ROL',0
ROR_TAG         DC.B    'ROR',0
BGT_TAG         DC.B    'BGT',0
BLE_TAG         DC.B    'BLE',0
BEQ_TAG         DC.B    'BEQ',0
JSR_TAG         DC.B    'JSR',0
RTS_TAG         DC.B    'RTS',0
BRA_TAG         DC.B    'BRA',0

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
