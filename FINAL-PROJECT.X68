*-----------------------------------------------------------
* Title      :CSS 422 Final project
* Written by :TEAM TED
* Date       :
* Description: DISASSEMBLER FOR MOTOROLA 68K ARCHITECTURE
*------------------------------------------------------------

*************************************************************************
******************** SUBROUTINE CONSTANTS *******************************

*ADDRESS REGISTERS -------------------------------------------------------
AREG0   EQU    %000
AREG1   EQU    %001
AREG2   EQU    %010
AREG3   EQU    %011
AREG4   EQU    %100
AREG5   EQU    %101
AREG6   EQU    %111

* DATA REGISTERS----------------------------------------------------------
DREG0   EQU    %000
DREG1   EQU    %001
DREG2   EQU    %010
DREG3   EQU    %011
DREG4   EQU    %100
DREG5   EQU    %101
DREG6   EQU    %110
DREG7   EQU    %111
*-------------------------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A
*-------------------------------------------------------------------------


***** INSTRUCTION DECOMPOTION SUBROUTINE**********************************
*A1 CONTAINS THE WORD READ FROM THE MEMORY
*DONT MODIFY the contents of ADDRESS REGISTER --- A1 --- IN THIS SUBROUTINE 
*-------------------------------------------------------------------------

        ORG    $1000
Opcode_Decifer:           *SUBROUTINE STARTS HERE     
       
        MOVE.L      (A1),D0  ;
        ROL         #2, D0 ;GETTING THE 2 MSB TO THE FRONT 
        AND.B       #%00000011,D0 ;MASK THE BITS FROM POSITION 2 AND UP
        CMP.B       #0, D0
        BEQ         MOVE_MOVEA ;THE TWO MOST LEFT BITS ARE 00 BITS: MOVE || MOVEA
        MOVE.B      (A1),D0 ;
        CLR.L       D1
        MOVE        #27, D1
        LSR         D1, D0 ;BRINGTING THE LAST NIBBLE TO THE FRONT
        CMP.B       #%0101, D0 
        BEQ         ADDQ_INSTRUCTION ;ADDQ 
        CMP.B       #%0111, D0
        BEQ         MOVEQ_INSTRUCTION ;MOVEQ
        CMP.B       #%1000, D0
        BEQ         OR_INSTRUCTION ;OR
        CMP.B       #%1001, D0
        BEQ         SUB_INSTRUCTION ;SUB
        CMP.B       #%1100, D0 
        BEQ         AND_INSTRUCTION ;AND
        CMP.B       #%1101, D0 
        BEQ         ADD_ADDA ;ADDA, ADD
        CMP.B       #%1110, D0
        BEQ         SHIFT
        CMP.B       #%0110, D0
        BEQ         BRA_BGT_BLE_BEQ ;BRA, BGT, BEQ
        CMP.B       #%0100,D0
        BEQ         NOT_NOP_RTS_MOVEM_LEA_JSR ;NOT, NOP, RTS, MOVEM, LEA, JSR
        
        LEA         WRONG_INSTRUCTION, A2 ;ELSE IT IS WRONG INSTRUCTION
        
 
      
        
      
                    
MOVE_MOVEA 
WRONG_INSTRUCTION
                
                
                           
ADDQ_INSTRUCTION  
MOVEQ_INSTRUCTION
OR_INSTRUCTION
SUB_INSTRUCTION
AND_INSTRUCTION
ADD_ADDA
SHIFT
BRA_BGT_BLE_BEQ
NOT_NOP_RTS_MOVEM_LEA_JSR






        
        
         SIMHALT             



    END    Opcode_Decifer        ; last line of source
*********SOURCE FILE ENDS HERE **************************************************


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~8~
