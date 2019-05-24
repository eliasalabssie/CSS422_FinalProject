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

*----- SIZE CONSTANTS -------------------------------------------------------
BYTE    EQU    %00 ;PROBLEM---************************************************************************************************
WORD    EQU    %11
LONG    EQU    %10

*-------------------------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A
*-------------------------------------------------------------------------


***** INSTRUCTION DECOMPOTION SUBROUTINE**********************************
*A2 CONTAINS THE WORD READ FROM THE MEMORY
*a2 will beincremented after processing the word 
* D2 used for copying values from A2
*-------------------------------------------------------------------------
test    dc.w    $9240
OPTCREE
        

        ORG $1000
INSTRUCTION_Decifer:           *SUBROUTINE STARTS HERE 
                
        LEA     TEST, A2 ;THIS IS TEST VALUE (DELETE IS WHEN RUNNING THE ACTUAL CODE)        
           
        CLR.L      D2 ; CLEAR OUT D0
        MOVE.W    (A2),D2  ;
        SWAP       D2
        ROL.L      #2, D2 ;GETTING THE 2 MSB TO THE FRONT 
        AND.B      #%00000011,D2 ;MASK THE BITS FROM POSITION 2 AND UP
        CMP.B      #0, D2
        BEQ        MOVE_MOVEA ;THE TWO MOST LEFT BITS ARE 00, then it's MOVE || MOVEA

  *AT THIS POINT MOVE AND MOVEA ARE FILTERED OUT INTO THIER RESPECTIVE SUBROUTINE
        CLR.L       D2
        MOVE.W     (A2),D2 ; READ THE WORD INSTRUCTION FROM A1
        SWAP        D2 ; BRING THE LM
        ROL.L       #4, D2 ;BRING THE FIRST 4 MSB OF THE INSTRUCTION TO THE FRONT
        AND.B       #$0F,D2 ; MASK OTHER BITS
        
        CMP.B       #%0101, D2  ;A CODE FOR ADDQ 
        BEQ         ADDQ_INSTRUCTION ;THE INSTRUCTION IS ADDQ 
 
  *ADDQ FILTERED OUT AT THIS POINT
        CMP.B       #%0111, D2
        BEQ         MOVEQ_INSTRUCTION ;MOVEQ
  
  *MOVEQ FILTERED OUT AT THIS POINT
        CMP.B       #%1000, D2
        BEQ         OR_INSTRUCTION ;OR
 
 *OR FILTERED OUT AT THIS POINT
        CMP.B       #%1001, D2
        BEQ         SUB_INSTRUCTION ;SUB
 
 * SUB FILTERED OUT AT THIS POINT
        CMP.B       #%1100, D2 
        BEQ         AND_INSTRUCTION ;AND
  
  *AND FILTERED OUT AT THIS POINT
        CMP.B       #%1101, D2 
        BEQ         ADD_ADDA ;ADDA, ADD
 
 
 *ADD AND ADDA FILTERED OUT AT THIS POINT
        CMP.B       #%1110, D2
        BEQ         SHIFT
 
 *SHIFTS ARE GROUPED TOGETHER AT THIS POINT
        CMP.B       #%0110, D2
        BEQ         BRA_BGT_BLE_BEQ ;BRA, BGT, BEQ
 
  *ALL BRANCH INSTRUCTION ARE GROPED AT THIS POINT
        CMP.B       #%0100,D2
        BEQ         NOT_NOP_RTS_MOVEM_LEA_JSR ;NOT, NOP, RTS, MOVEM, LEA, JSR
  
  *ANY INSTRUCTION NOT READ AFTER WARDS IS A WRONG INSTRUCTION FORMAT
        
 ***************************************************************************************************************
WRONG_INSTRUCTION            MOVE.B   #5, D7 ; A WRONG INSTRUCTION 'KEY'
                             MOVEA.L  A2, A6 ;MOVING THE MEMORY ADDRESS INTO A6 WHEN INSTRUCTION WRONG 
                             MOVE.W  (A2)+,D6 ;THE VALUE AT THE MEMORY ADDRESS IS MOVED INTO D6 
                             RTS
*****************************************************************************************************************
        
      
      
                    
MOVE_MOVEA      CLR.L   D2
                MOVE.W  (A2),D2
                LSR.W   #6, D2 ;MOVE THE 9,8,7TH BITS TO THE FRONT 
                AND.B   #$07, D2 ;MASK THE OThER BITS EXCEPT 9,8,7
                CMP.B   #%001, D2 ;IF EQUAL, ITS MOVEA
                BEQ     MOVEA_INST
                
*------------------ MOVE -----------------------------------------------------------------------              
                *ELSE IT IS MOVE
MOVE_INST       LEA     MOVE_TAG, A6 ;MOVING THE INSTRUCTION INTO  A6
                MOVE.W (A2),D2 ;
                SWAP    D2
                ROL.L   #4, D2 ;GET THE 13, 12 BITS FOR SIZE
                AND.B   #$03,D2 ;MASK THE BITS OTHER THAN SIZE BITS
                CMP.B   #BYTE, D2
                BEQ     BYTE_SIZE
                CMP.B   #WORD,D2
                BEQ     WORD_SIZE
                CMP.B   #LONG,D2
                BEQ     LONG_SIZE
                
                
                *ELSE IT'S WRONG SIZE
WRONG_SIZE      MOVE.B  #5, D7 ;A PUT WRONG SIZE SIGN INTO D7
                RTS          ;BACK TO MAIN
                
* -------- SIZE SUBROUTINES -----------------------------------------                
BYTE_SIZE       MOVE.B #1, D7
                RTS 
   
WORD_SIZE       MOVE.B  #2, D7
                RTS
                
LONG_SIZE       MOVE.B  #4, D7
                RTS
                
               
******************** MOVEA_INST *********************************************
                
MOVEA_INST      LEA MOVEA_TAG, A6 
                MOVE.W (A2),D2 ;
                SWAP    D2
                ROL.L   #4, D2 ;GET THE 13, 12 BITS FOR SIZE
                AND.B   #$03,D2 ;MASK THE BITS OTHER THAN SIZE BITS
                CMP.B   #BYTE, D2 
                BEQ     WRONG_SIZE ;IF BYTE, ITS WRONG SIZE
                CMP.B   #WORD,D2
                BEQ     WORD_SIZE ;WORD SIZE
                CMP.B   #LONG,D2
                BEQ     LONG_SIZE ;LONG SIZE
                BRA     WRONG_SIZE ;ELSE WRONG SIZE
          
                
*00— Byte operation
*01— Word operation
*10— Long operation 
*BYTEQ   EQU    %00   
*WORDQ   EQU    %01
*LONGQ   EQU    %10                                          
ADDQ_INSTRUCTION   LEA ADDQ_TAG, A6
                   MOVE.W      (A2),D2
                   LSR.L        #6, D2
                   AND.B        #$03, D2
                   CMP.B        #BYTE,D2
                   BEQ          BYTE_SIZE
                   CMP.B        #WORD, D2
                   BEQ          WORD_SIZE
                   CMP.B        #LONG, D2
                   BEQ          LONG_SIZE
                  
                  ;ELSE,ITS WRONG SIE
                   BRA          WRONG_SIZE
                
MOVEQ_INSTRUCTION       LEA   MOVEQ_TAG, A6
                        MOVE.B  #0, D7 ;CHECK WITH TEM--------------------------------------------------
                        *---------------------------------------------------------------------------------
                        *--------------------------------------------------------------------------------
*NOTES FOR 'OR'
                       
*Byte Word Long Operation
*000 001 010 < ea > V Dn ? Dn
*100 101 110 Dn V < ea > ? < ea >
BYTE1  EQU %000
BYTE2  EQU %100
WORD1  EQU %001
WORD2  EQU %101
LONG1  EQU %010
LONG2  EQU %110   
                    
OR_INSTRUCTION          LEA   OR_TAG, A6

BIT_MANUP
                        MOVE.W  (A2),D2
                        SWAP    D2
                        LSR.L   #6,D2
                        AND.B   #$07, D2
                        CMP.B   #BYTE1,D2
                        BEQ     BYTE_SIZE
                        CMP.B   #BYTE2, D2
                        BEQ     BYTE_SIZE
                        CMP.B   #WORD1, D2
                        BEQ     WORD_SIZE
                        CMP.B   #WORD2, D2
                        BEQ     WORD_SIZE
                        CMP.B   #LONG1, D2
                        BEQ     LONG_SIZE
                        CMP.B   #LONG2, D2
                        BEQ     LONG_SIZE
                        
                        ;ELSE ITS WRONG SIZE
                        BRA      WRONG_SIZE
                       
*Byte Word Long Operation
*000 001 010 Dn – < ea > ? Dn
*100 101 110 < ea > – Dn ? < ea > 
SUB_INSTRUCTION         LEA   SUB_TAG, A6
                        JMP     BIT_MANUP ;DO THE SAME THING AS 'OR'
                        
                        
                        
                       
*Byte Word Long Operation
*000 001 010 < ea > ? Dn ? Dn
*100 101 110 Dn ? < ea > ? < ea >                         
AND_INSTRUCTION         LEA   AND_TAG,A6
                        JMP    BIT_MANUP ;JUMP TO BIT_MANUP SUBROUTIEN



*---------------------------------------
ADD_ADDA        CLR.L     D2
                MOVE.W   (A2),D2
                LSR      #6, D2
                AND.B    #$07, D2 ;MASK THE BITS BEFORE BIT 8TH
                CMP.B    #$03, D2 ;IF THE 8, 7,6TH BIT ARE EITHER 011 OR 111, ITS ADDA
                BEQ     ADDA_INST
                CMP.B    #$07, D2 ;IF 8,7,6 BITS ARE 111, THEN ITS ADDA AGAIN 
                BEQ      ADDA_INST
                
                *ELSE ITS ADD INSTRUCTION
                
*Byte Word Long Operation
*000 001 010 < ea > + Dn ? Dn
*100 101 110 Dn + < ea > ? < ea >                  
ADD_INST        LEA     ADD_TAG, A6 ;PUT ADD_TAG INTO A6 FOR PRINT
                JMP     BIT_MANUP ;DEERMIN SiZE FROM BIT_MANUP SUBROUTINE
                
               
*Opmode field—Specifies the size of the operation.
*011— Word operation; 
*111— Long operation. 
ADDA_INST       LEA     ADDA_TAG, A6
                MOVE.W  (A2),D2
                SWAP    D2
                LSR.L   #6,D2
                AND.B   #$07,D2 ;MASK THE 8, 7, 6 BITS
                CMP.B   #%011, D2
                BEQ     WORD_SIZE ;IF 011, ITS WORD SIZE
                CMP.B   #%111, D2 ;IF 111, ITS LONG SIZE
                BEQ     LONG_SIZE
                
                *ELSE WRONG SIZE
                JMP     WRONG_SIZE
                
                       
SHIFT        CLR.L     D2
             MOVE.W    (A2),D2 ;
             LSR       #6, D2 ;MOVE THE 6,AND 7 BITS TO THE FRONT
             AND.B     #$03, D2  ;MASK THE OTHER BITS
             CMP.B     #$03, D2 ;IF THE LSB (FROM 6,7)ARE 011
             BEQ       MEMORY_SHIFT ;IF THE 6,7TH BITS ARE 11, IT'S MEMORY SHIFT 
         
            *ELSE IT IS A REGISTER SHIFT
             
REGISTER_SHIFT  CLR.L   D2
                MOVE.W  (A2),D2
                LSR     #3, D2 ;BRING THE 4TH AND 3RD BITS TO FRONT 
                AND.B   #$03, D2 ;MASK BITS OTHR THAN 2 LSM 
                CMP.B   #$00, D2
                BEQ     REGISRER_ARTHIMETIC
                CMP.B   #$01,D2
                BEQ     REGISTER_LOGICAL
                CMP.B   #$03, D2
                BEQ     REGISTER_ROTATE
                
                 ;ELSE WRONG INSTR IF 4, 3 BITS ARE 1 0
                JMP     WRONG_INSTRUCTION 
              
REGISRER_ARTHIMETIC     CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                        AND.B      #01, D2
                        CMP.B      #01, D2
                        BEQ        REGISTER_ARTIMETIC_LEFT

BYTE_SHFT       EQU     %00
WORD_SHIFT      EQU     %01
LONG_SHIFT      EQU     %10

*---------------------- REGISTER ARTHIMETIC SHIFT -------------------------------------------------------
                                                LEA ASR_TAG,A6 

REGISTER_BIT_MANUP                              MOVE.W     (A2),D2
                                                LSR.L      #6, D2
                                                AND.B      #$03,D2
                         
REG_SHIFT_SIZE                                  CMP.B      #BYTE_SHFT,D2
                                                BEQ        BYTE_SIZE ;call BYTE_SSIZE method
                                                CMP.B      #WORD_SHIFT,D2
                                                BEQ        WORD_SIZE ;CALL WORD-size method
                                                CMP.B      #LONG_SHIFT,D2
                                                BEQ        LONG_SIZE ;CALL LONG_SIZE METHOD
                                                
                                                *ELSE WRONG SIZE
                                                JMP           WRONG_SIZE  ;CALL WRONG_SIZE  METHOD               
                                          
REGISTER_ARTIMETIC_LEFT        LEA  ASL_TAG, A6 
                               JMP   REGISTER_BIT_MANUP 
            
         
REGISTER_LOGICAL        CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                        AND.B      #01,D2
                        CMP.B      #1, D2
                        BEQ        REGISTER_LOGICAL_LEFT
                        
                        *ELSE IT IS REGISTER_LOGICAL _RIGH(LSR)
                        LEA  LSR_TAG, A6  
                        JMP     REGISTER_BIT_MANUP 
                        
                        
REGISTER_LOGICAL_LEFT   LEA     LSL_TAG, A6
                        JMP     REGISTER_BIT_MANUP 

                        
REGISTER_ROTATE         CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                        CMP.B      #1, D2
                        BEQ        REGISTER_ROTATE_LEFT
                        
                        ;ELSE REGISTER_ROTATE RIGHT
                        LEA     ROR_TAG, A6
                        JMP REGISTER_BIT_MANUP     

                        


REGISTER_ROTATE_LEFT    LEA     ROL_TAG, A6
                        JMP     REGISTER_BIT_MANUP

             
 *************************************************************************************************************************************************            
             
*------------------------MEMORY SHIFTS ---------------------------------------------------------------------------------------------------------  

************************************************************************************************************************************************   
MEMORY_SHIFT    CLR.L     D2
                MOVE.W    (A2),D2
                LSR       #8, D2 ;LSR 8 + 1 TIMES(NOT TO USE ONOTHER REGISTER)
                LSR       #1, D2 ;A TOTAL OF 9 SHIFTS MADE
                AND.B     #$07,D2
                CMP.B     #$00,D2
                BEQ       MEMORY_ARTIMETIC ; SHIFT
                CMP.B     #$01, D2
                BEQ       MEMORY_LOGICAL
                CMP.B     #$03, D2
                BEQ       MEMORY_ROTATE 
                 ;ELSE WRONG INSTRUCTION
                 JMP    WRONG_INSTRUCTION
         
                
     
MEMORY_ARTIMETIC   CLR.L      D2
                   MOVE.W     (A2),D2
                   LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                   CMP.B      #1, D2
                   BEQ        MEMORY_ARTIMETIC_LEFT     
                   
                ;ELSE MEMEORY_ARTIMETIC_RIGHT
                 LEA     ASR_TAG, A6 
                 MOVE.B  #0, D7 ;-----------MOVE O TO INDICATE NO SIZE NEEDED ----------------------------
                 RTS

                       



MEMORY_ARTIMETIC_LEFT  LEA     ASL_TAG, A6 
                        MOVE.B  #0, D7 ;-----------MOVE O TO INDICATE NO SIZE NEEDED ----------------------------------
                        RTS

  
MEMORY_LOGICAL     CLR.L      D2
                   MOVE.W     (A2),D2
                   LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                   CMP.B      #1, D2
                   BEQ        MEMORY_LOGICAL_LEFT     
                   ;MEMEORY_LOGICAL_RIGHT
                   LEA     ASL_TAG, A6 
                   MOVE.B  #0, D7 ;-----------MOVE O TO INDICATE NO SIZE NEEDED ----------------------------------
                   RTS


MEMORY_LOGICAL_LEFT     LEA     LSL_TAG, A6 
                        MOVE.B  #0, D7 ;-----------MOVE O TO INDICATE NO SIZE NEEDED ----------------------------------
                        RTS



MEMORY_ROTATE     CLR.L      D2
                   MOVE.W     (A2),D2
                   LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                   CMP.B      #1, D2
                   BEQ        MEMORY_ROTATE_LEFT 
                    
                ;PUT CODE FOR MEMEORY_ROTATE_RIGHT
                   LEA     ROR_TAG, A6 
                   MOVE.B  #0, D7 ;-----------MOVE O TO INDICATE NO SIZE NEEDED ----------------------------------
                   RTS




MEMORY_ROTATE_LEFT      LEA     ROL_TAG, A6 
                        MOVE.B  #0, D7 ;-----------MOVE O TO INDICATE NO SIZE NEEDED ----------------------------------
                        RTS



BRA_BGT_BLE_BEQ         CLR.L   D2
                        MOVE.W  (A2),D2
                        ASL     #8, D2 ;GET THE 11, 10,9,AND 8TH BITS TO THE FRONT  
                        AND.W   #$000F,D2   ;MASK THE BITS 
                        CMP.B   #$0, D2
                        BEQ     BRA_INST ;BRA
                        CMP.B   #$0E, D2
                        BEQ     BGT_INST ;BGT
                        CMP.B   #$0F, D2
                        BEQ     BLE_INST ;BLE
                        CMP.B   #$07, D2
                        BEQ     BEQ_INST ;BEQ
                        
                        ;PUT CODE ELSE WRONG INST
                        JMP WRONG_INSTRUCTION
                        
                       
BRA_INST ;PUT CODE
BGT_INST ;PUT CODE
BLE_INST ;PUT CODE
BEQ_INST ;PUT CODE


NOT_NOP_RTS_MOVEM_LEA_JSR        CLR.L D2
                                 MOVE.W (A2),D2
                                 CMP.W  #$4E71, D2 ;OPCODE FOR NOP
                                 BEQ    NOP_INST
                                 
                                 CMP.W  #$4E75,D2 ;RTS OPCODE
                                 BEQ    RTS_INST     
                                        
                                 CLR.L  D2
                                 MOVE.W (A2),D2
                                 LSR    #6, D2
                                 AND.W  #$03FF,D2
                                 CMP.W  #$0139, D2
                                 BEQ    JSR_INST
                                 CLR.L  D2
                                 MOVE.W (A2),D2
                                 LSR    #8, D2
                                 AND.B  #$FF,D2
                                 CMP.B  #$46,D2
                                 BEQ  NOT_INST
                                 CLR.L  D2
                                 MOVE.W (A2),D2
                                 LSR     #7, D2
                                 AND.W   #$01FF,D2
                                 CMP.B   #$19,D2
                                 BEQ     MOVEM_INST ;MOVEM(TO MEMEORY)
                                 CMP.B   #$89, D2
                                 BEQ     MOVEM_INST ;,MOVEM TO REGISTER
                                 MOVE.W  (A2),D2
                                 LSR      #6, D2
                                 AND.B    #$07,D2
                                 CMP.B    #$07,D2
                                 BEQ      LEA_INST
                                 ;PUT CODE ELSE WRONG INST
 
                                 
       



NOP_INST ;NO SIZE, DES, SOURCE OP

RTS_INST   ;NO SIZE, DES, SOURCE OP
JSR_INST  ;
NOT_INST ;
MOVEM_INST ;
LEA_INST



        
        
         SIMHALT
             
* I DONT NEED THIS SYMBALS, ITS FOR TEMSEGEN AND TO TEST MY CODE --------------------------------------------------------
MOVE_TAG
MOVEA_TAG
ADDQ_TAG
MOVEQ_TAG
OR_TAG
SUB_TAG
AND_TAG
ADD_TAG
ADDA_TAG
ASR_TAG
ASL_TAG
LSR_TAG
LSL_TAG
ROR_TAG
ROL_TAG
ASR_TAG
ASL_TAG

    END    INSTRUCTION_Decifer        ; last line of source
*********SOURCE FILE ENDS HERE **************************************************











*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~8~
