*-----------------------------------------------------------
* Title      :CSS 422 Final project
* Written by :TEAM TED
* Date       :
* Description: DISASSEMBLER FOR MOTOROLA 68K ARCHITECTURE
*------------------------------------------------------------


*----- parameters -------------------------------------------------------

***** INSTRUCTION_DECIFER SUBROUTINE
*A2 CONTAINS THE WORD READ FROM THE MEMORY
*A2 will be incremented afterfinishing processing the word 
* D2 used for copying values from A2
*the size of the instruction will be returned on register D6
*the address of ilegal instruction will be returned via register A6
*-------------------------------------------------------------------------
test    dc.W    $3078
OPTCREE
        

        ORG $1000
INSTRUCTION_DECIPHER:           *SUBROUTINE STARTS HERE 
        
        CLR.L   D7
                
        LEA     TEST, A2 ;DELETE THIS WHEN RUNNING THE ACTUAL CODE)        
           
        CLR.L      D2 ; CLEAR OUT D0
        MOVE.W    (A2),D2  ;
        SWAP       D2
        ROL.L      #2, D2 ;GETTING THE 2 MSB TO THE FRONT 
        AND.B      #$03,D2 ;MASK THE BITS FROM POSITION 2 AND UP
        CMP.B      #$0,D2
        BEQ        MOVE_MOVEA ;THE TWO MOST LEFT BITS ARE 00, then it's MOVE || MOVEA

  *AT THIS POINT MOVE AND MOVEA ARE FILTERED OUT INTO THIER RESPECTIVE SUBROUTINE
        CLR.L       D2
        MOVE.W     (A2),D2 ; READ THE WORD INSTRUCTION FROM A1
        SWAP        D2 ; swap the data to 15 to 31 positions
        ROL.L       #4, D2 ;BRING THE FIRST 4 MSB OF THE INSTRUCTION TO THE FRONT
        AND.B       #$0F,D2 ; MASK OTHER BITS
        
        CMP.B       #%0101, D2  ;A CODE FOR ADDQ 
        BEQ         ADDQ_MAYBE_INSTRUCTION ;THE INSTRUCTION MAY BE ADDQ OR SIMILAR INSTRUCTIONS START WITH 0101 
 
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
        BEQ         AND_MAYBE_INSTRUCTION ;MAY BE IT'S AND
  
  *AND FILTERED OUT AT THIS POINT
        CMP.B       #%1101, D2 
        BEQ         ADD_ADDA_MAYBE ;ADDA, ADD
 
 
 *ADD AND ADDA FILTERED OUT AT THIS POINT
        CMP.B       #%1110, D2
        BEQ         SHIFT
 
 *SHIFTS ARE GROUPED TOGETHER AT THIS POINT
        CMP.B       #%0110, D2
        BEQ         BRA_BGT_BLE_BEQ ;BRA, BGT, BEQ
 
  *ALL BRANCH INSTRUCTION ARE Grouped together
  
  
        CMP.B       #%0100,D2
        BEQ         NOT_NOP_RTS_MOVEM_LEA_JSR ;NOT, NOP, RTS, MOVEM, LEA, JSR
  
  *ANY INSTRUCTION NOT READ YET IS IN WRONG FORMAT/NOT INCLUDED IN OUR PROJECT INST. LIST
        
 ***************************************************************************************************************
WRONG_INSTRUCTION            MOVE.B   #5, D7 ; A WRONG INSTRUCTION 'KEY'
                             MOVEA.L  A2, A6 ;MOVING THE MEMORY ADDRESS INTO A6 WHEN INSTRUCTION IS WRONG 
                             MOVE.W  (A2),D6 ;MOVE MEMORY ADDRESS INTO D6, AND INCREMENT A2 BY WORD
                             RTS
*****************************************************************************************************************
        
      
      
                    
MOVE_MOVEA      CLR.L   D2
                MOVE.W  (A2),D2
                SWAP    D2
                ROL.L   #4,D2 ;ROLL THE 4 MSB TO THE FRONT 
                AND.B   #$0F,D2 ;MASK 4 BITS OTHER THATN THE 4 MSB
                CMP.B   #$0, D2 ;IF THE 4 MSB ARE 0, THEN IT IS ANDI, SUBI ... INSTRUCTIONS 
                BEQ     WRONG_INSTRUCTION *IF THE 4 MSB ARE 0(FOR INST LIKE ORI, ANDI,SUBI ADDI ETC...), ITS WRONG INST
               
               *ELSE IT'S EITHER MOVE OR MOVEA, SO KEEP PROCESSING
                CLR.L   D2
                MOVE.W  (A2),D2
                LSR.W   #6, D2 ;MOVE THE 8,7,6TH BITS TO THE FRONT 
                AND.B   #$07, D2 ;MASK THE OTHER BITS EXCEPT 8,7,6
                CMP.B   #$01, D2 ;IF EQUAL, ITS MOVEA
                BEQ     MOVEA_INST

                *ELSE IT IS MOVE
                
*------------------ MOVE -----------------------------------------------------------------------  
            
*01 — Byte operation
*11 — Word operation
*10 — Long operation                
MOVE_INST       LEA     MOVE_TAG, A6 ;MOVING THE INSTRUCTION TAG INTO  A6
                JSR     MOVE_MOVEA_EA
                MOVE.W (A2),D2 ;
                LSR     #8,D2  *MAKE A TOTAL OF 12 SHIFT TO PUSH 12,AND 13 BIT TO FRONT
                LSR     #4, D2 (8 + 4) SHIFTS JUST NOT TO USE REGISTERS FOR SHIFTING
                AND.B   #$03, D2 *MASK BITS
                CMP.B   #$01, D2
                BEQ     BYTE_SIZE
                CMP.B   #$03,D2
                BEQ     WORD_SIZE
                CMP.B   #$02, D2
                BEQ     LONG_SIZE
                
                *ELSE IT IS 11, WHICH IS WRONG SIZE
                JMP     WRONG_SIZE
                 
                
                
                *ELSE IT'S WRONG SIZE
WRONG_SIZE      MOVE.B  #5, D7 ;A PUT WRONG SIZE SIGN INTO D7
                MOVEA.L  A2, A6 ;MOVING THE MEMORY ADDRESS INTO A6 WHEN SIZE/INSTRUCTION IS WRONG 
                MOVE.W  (A2),D6 ;MOVE MEMORY ADDRESS INTO D6, AND INCREMENT A2 BY WORD
                RTS          ;BACK TO MAIN
                

***********************************************************************************************************  
              
* -------------- SIZE SUBROUTINES ----------------------------------------------------------------------- 
*PUTS 1 FOR BYTE, 2 FOR WORD, AND 4 FOR LONG INTO D7 AS A SIGN OF SIZES, AND RTS BACK TO MAIN
               
**********************************************************************************************************
BYTE_SIZE       ADD.B #1, D7
                RTS 
   
WORD_SIZE       ADD.B  #2, D7
                RTS
                
LONG_SIZE       ADD.B  #4, D7
                RTS
*----------------------------------------------------------------------------------------------------------
                
               
******************** MOVEA_INST ***************************************************************************
MOVEA_INST      LEA MOVEA_TAG, A6
                *JSR     MOVE_MOVEA_EA ***** CALL <EA>
                MOVE.W (A2),D2 ;
                LSR.L   #8, D2 ;GET THE 13, 12 BITS FOR SIZE
                LSR.L   #4, D2 ;TOTAL OF 11 SHIFTS 
                AND.B   #$03,D2 ;MASK THE BITS OTHER THAN SIZE BITS
                CMP.B   #$00, D2 
                BEQ     WRONG_SIZE ;IF BYTE, ITS WRONG SIZE
                CMP.B   #$01,D2
                BEQ     WORD_SIZE ;WORD SIZE
                CMP.B   #$02,D2
                BEQ     LONG_SIZE ;LONG SIZE
                
                *ELSE WRONG SIZE(11)
                JMP     WRONG_SIZE 
                
          
**********************************************************************************************************               
*NOT SURE THAT IT'S ADDQ YET
ADDQ_MAYBE_INSTRUCTION  CLR.L        D2
                        MOVE.W       (A2),D2
                        BTST         #8,D2 *TEST THE 8TH BIT IF CLEAR/SET
                        BEQ          ADDQ_INSTRUCTION * THE 8TH BIT IS ZERO, MAY BE ITS ADDQ
                        
                        *ELSE IT'S WRONG INSTRUCTION(IT MAY BE SUBQ)
                        JMP           WRONG_INSTRUCTION
 
*********************************************************************************************************
*00— Byte operation
*01— Word operation
*10— Long operation 
*7,6TH BITS ARE THE SIZE BITS FOR ADDQ                        
ADDQ_INSTRUCTION        CLR.L   D2
                        MOVE.W  (A2),D2
                        LSR.L   #6,D2
                        AND.B   #$03,D2
                        CMP.B   #$03,D2
                        BEQ     WRONG_INSTRUCTION *IT MAY BE Scc, DBcc ....
                        
                        *ELSE IT IS ADDQ                        
                        LEA ADDQ_TAG, A6 * PUT THE SIGN OF THE ADDQ TAG INTO A6
                        JSR     ADDQ_EA ***** CALL <EA>

                        MOVE.W      (A2),D2
                        LSR.L        #6, D2
                        AND.B        #$03, D2
                        CMP.B        #$00,D2
                        BEQ          BYTE_SIZE
                        CMP.B        #$1, D2
                        BEQ          WORD_SIZE
                        CMP.B        #$2, D2
                        BEQ          LONG_SIZE
                        
                        ;ELSE,ITS WRONG SIE
                        JMP          WRONG_SIZE
 
****************************************************************************************************** 
                       
*15   14   13   12 *POSITION
*0    1    1    1  * BITS * THESE BITS MAKES MOVEQ UNIQUE FROM ALL INSTRUCTIONS               
MOVEQ_INSTRUCTION       LEA   MOVEQ_TAG, A6
                        MOVE.B  #0, D7 * SIGN TO SAY IT DOESN'T NEED SIZE BITS 
                        JSR     MOVEQ_EA ***** CALL <EA> 
                        RTS
*******************************************************************************************************                       

*------------------------------------------------------------------------------------------------------
*NOTES FOR 'OR'                      
*Byte   Word    Long Operation
*000    001     010 < ea > V Dn ? Dn
*100    101     110 Dn V < ea > ? < ea >                  
OR_INSTRUCTION          MOVE.W  (A2),D2
                        LSR.L   #3, D2
                        AND.B   #$0F,D2
                        CMP.B   #$3, D2
                        BEQ     WRONG_INSTRUCTION *FILTER OUT DIVU AND DIVS
                        MOVE.W  (A2),D2
                        LSR.L   #4,D2
                        AND.B   #$1F,D2
                        CMP.B   #$10,D2
                        BEQ     WRONG_INSTRUCTION *FILTER OUT "SBCD"
                        
                         *ELSE IT IS OR INSTRUCTION

                        LEA   OR_TAG, A6  
                        JSR     EA1 ***** CALL <EA>
   



*THIS BIT_MANUP SUBROUTINE IS FOR SIZES OF THE SAME FORMAT AS BELOW
*Byte Word Long Operation
*000 001 010 < ea > ? Dn ? Dn
*100 101 110 Dn ? < ea > ? < ea >  
BIT_MANUP
                        MOVE.W  (A2),D2
                        LSR.L   #6,D2
                        AND.B   #$07,D2
                        CMP.B   #$0,D2
                        BEQ     BYTE_SIZE
                        CMP.B   #$4, D2 
                        BEQ     BYTE_SIZE

                        CMP.B   #$1, D2
                        BEQ     WORD_SIZE
                        CMP.B   #$5, D2
                        BEQ     WORD_SIZE
                        
                        CMP.B   #$2, D2
                        BEQ     LONG_SIZE
                        CMP.B   #$6, D2
                        BEQ     LONG_SIZE
                        
                        ;ELSE ITS WRONG SIZE
                        JMP      WRONG_SIZE


******************************************************************************************************************                       
*Byte Word Long Operation
*000 001 010 Dn – < ea > ? Dn
*100 101 110 < ea > – Dn ? < ea > 
SUB_INSTRUCTION         MOVE.W  (A2),D2
                        LSR.L   #6,D2
                        AND.B   #$03,D2
                        CMP.B   #$3,D2
                        BEQ     WRONG_INSTRUCTION * FILTER OUT "SUBA"
                        MOVE.W  (A2),D2
                        BTST    #8,D2 *TEST THE 8TH BIT
                        BNE     SUB_FILTER

SUB_FINAL               LEA     SUB_TAG, A6
                        JSR     EA1 ***** CALL <EA>
                        
                        JMP     BIT_MANUP ;FIGURE OUT SIZE OF OPERANDS
                        
SUB_FILTER              MOVE.W  (A2),D2
                        LSR.L    #4,D2
                        AND.B    #$03,D2
                        CMP.B    #$0,D2
                        BEQ       WRONG_INSTRUCTION     *FILTER OUT "SUBX" INSTRUCTION
                        
                        *ELSE IT IS SUB INSTRUCTION
                        JMP       SUB_FINAL     *PUT SUB_TAG TAG AND READ SIZE     
                        
*---------------------------------------------------------------------------------------------------------------                        
                        
                       
****************************************************************************************************************
*FILLTER OUT OTHER INSTRUCTIONS WITH MSB 1100    
AND_MAYBE_INSTRUCTION   CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR.L      #6,D2
                        AND.B      #$03,D2
                        CMP.B      #$03,D2
                        BEQ        WRONG_INSTRUCTION *THIS INSTRUCTION CAN BE MULU OR MULS
                        MOVE.W     (A2),D2
                        BTST       #8,D2
                        BNE        AND_FURTHER_FILTER     
                                   
                        *ELSE IS IT AND INSTRUCTION                        
AND_INSTRUCTION         LEA   AND_TAG,A6
                        JSR   EA1 ***** CALL <EA>
                        JMP    BIT_MANUP ;JUMP TO BIT_MANUP SUBROUTIN

AND_FURTHER_FILTER      CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR.L      #4,D2
                        AND.B      #$03,D2
                        CMP.B      #$0,D2
                        BEQ        WRONG_INSTRUCTION *FILTER OUT EXG AND ABCD INSTRUCTIONS
                        JMP        AND_INSTRUCTION
                

**************************************************************************************************************


*ADD_ADDA SUBROUITNE
**************************************************************************************************************
ADD_ADDA_MAYBE      CLR.L     D2
                    MOVE.W   (A2),D2
                    BTST     #8,D2 
                    BEQ      ADD_ADDA_ADDX  
    
ADD_ADDA_RETURN     LSR      #6, D2
                    AND.B    #$07, D2 ;MASK THE BITS BEFORE THE 8TH BIT
                    CMP.B    #$03, D2 ;IF THE 8, 7,6TH BIT ARE EITHER 011 OR 111, ITS ADDA
                    BEQ     ADDA_INST
                    CMP.B    #$07, D2 ;IF 8,7,6 BITS ARE 111, THEN ITS ADDA AGAIN 
                    BEQ      ADDA_INST
                
                *ELSE ITS ADD INSTRUCTION


*-------------------------------------------------------------------------------------------------------------                                 
ADD_INST        LEA     ADD_TAG, A6 ;PUT ADD_TAG INTO A6 FOR PRINT
                JSR     EA1 ***** CALL <EA>
                JMP     BIT_MANUP ;DEERMIN SiZE FROM BIT_MANUP SUBROUTINE
                
*************************************************************************************************************


*----------------------------------------------------------------------------------------------------------               
*011— Word operation; 
*111— Long operation. 
ADDA_INST       LEA     ADDA_TAG, A6
                JSR     EA4   ***** CALL <EA>
                MOVE.W  (A2),D2
                LSR.L   #6,D2
                AND.B   #$07,D2 ;MASK THE 8, 7, 6 BITS
                CMP.B   #$03, D2 ;IF %011
                BEQ     WORD_SIZE ;IF 011, ITS WORD SIZE
                CMP.B   #$07, D2 ;IF 111, ITS LONG SIZE
                BEQ     LONG_SIZE
                
                *ELSE WRONG SIZE
                JMP     WRONG_SIZE
************************************************************************************************************
ADD_ADDA_ADDX   MOVE.W  (A2),D2
                LSR.L   #4,D2
                AND.B   03,D2
                CMP.B   #$0,D2
                BEQ     WRONG_INSTRUCTION *IT IS ADDX INSTRUCTION
                
                *ELSE IT IS ADD OR ADDA
                MOVE.W  (A2),D2
                JMP     ADD_ADDA_RETURN 
*----------------------------------------------------------------------------------------------------------                       
SHIFT        CLR.L     D2
             MOVE.W    (A2),D2 ;
             LSR       #6, D2 ;MOVE THE 6,AND 7 BITS TO THE FRONT
             AND.B     #$03, D2  ;MASK THE OTHER BITS
             CMP.B     #$03, D2 ;IF THE LSB (FROM 6,7)ARE 11, IT IS A MEMORY SHIFT
             BEQ       MEMORY_SHIFT ;IF THE 6,7TH BITS ARE 11, IT'S MEMORY SHIFT 
         
            *ELSE IT IS A REGISTER SHIFT
*-------------REGISTER SHIFTS --------------------------------------------------------------------------            
REGISTER_SHIFT  CLR.L   D2
                MOVE.W  (A2),D2
                LSR     #3, D2 ;BRING THE 4TH AND 3RD BITS TO FRONT 
                AND.B   #$03, D2 ;MASK BITS OTHR THAN 2 LSM 
                CMP.B   #$00, D2
                BEQ     REGISRER_ARTHIMETIC *(ALd)
                CMP.B   #$01,D2
                BEQ     REGISTER_LOGICAL *(LSd)
                CMP.B   #$03, D2
                BEQ     REGISTER_ROTATE *(ROd)
                
                 ;ELSE WRONG INSTR IF 4, 3 BITS ARE 1 0 , WHICH IS ROXd
                JMP     WRONG_INSTRUCTION 
*-------------------------------------------------------------------------------------------------------
              
REGISRER_ARTHIMETIC     CLR.L      D2
                        MOVE.W     (A2),D2
                        BTST       #8,D2 ;TEST THE 8TH BIT IF CLEAR/SET 
                        BNE        REGISTER_ARTIMETIC_LEFT *IF 8TH BIT IS 1, IT IS REGISTER ASL
                       
                        *ELSE IT IS EGISTER ASR

                        LEA ASR_TAG,A6 *MOVE ASL_TAG INTO A6
                        JSR  EA2 ***** CALL <EA>
                        
                        *THEN SIZE OF TH OPERANDS 

REGISTER_BIT_MANUP      CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR.W      #6, D2 * THE 7TH SND 6TH BITS ARE SIZE BITS, MOVE THEM TO THE FRONT 
                        AND.B      #$03,D2
                         
*--------------------------------------------------------------------------------------------------------                        
REG_SHIFT_SIZE          CMP.B      #$0,D2
                        BEQ        BYTE_SIZE ;call BYTE_SIZE method
                        CMP.B      #$01,D2
                        BEQ        WORD_SIZE ;CALL WORD_SIZE method
                        CMP.B      #$02,D2
                        BEQ        LONG_SIZE ;CALL LONG_SIZE METHOD
                                                
                        *ELSE WRONG SIZE
                        JMP           WRONG_SIZE  ;CALL WRONG_SIZE  METHOD               
                
************************************************************************************************************                                          
REGISTER_ARTIMETIC_LEFT LEA  ASL_TAG, A6
                        JSR     EA2 ***** CALL <EA>
                        JMP   REGISTER_BIT_MANUP *DETERMINE SIZE OF THE OPERANDS 
*--------------------------------------------------------------------------------------------------------            
         
REGISTER_LOGICAL        CLR.L      D2
                        MOVE.W     (A2),D2
                        BTST       #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                        BNE        REGISTER_LOGICAL_LEFT
                        
                        *ELSE IT IS REGISTER_LOGICAL _RIGH(LSR)
                        LEA  LSR_TAG, A6
                        JSR     EA2 ***** CALL <EA> 
                        JMP     REGISTER_BIT_MANUP 
                        
******************************************************************************************************                        
REGISTER_LOGICAL_LEFT   LEA     LSL_TAG, A6
                        JSR     EA2 ***** CALL <EA>
                        JMP     REGISTER_BIT_MANUP 

*----------------------------------------------------------------------------------------------------                        
REGISTER_ROTATE         CLR.L      D2
                        MOVE.W     (A2),D2
                        BTST       #8, D2 ;TEST THE DIRECTION BIT(8TH BIT)
                        BNE        REGISTER_ROTATE_LEFT
                        
                        ;ELSE REGISTER_ROTATE RIGHT
                        LEA     ROR_TAG, A6
                        JSR     EA2 ***** CALL <EA>
                        JMP     REGISTER_BIT_MANUP     

REGISTER_ROTATE_LEFT    LEA     ROL_TAG, A6
                        JSR     EA2 ***** CALL <EA>
                        JMP     REGISTER_BIT_MANUP

             
 ********************************************************************************************            
             
*------------------------MEMORY SHIFTS ------------------------------------------------------  

*********************************************************************************************  
MEMORY_SHIFT    CLR.L     D2
                MOVE.W    (A2),D2
                LSR       #8, D2 ;LSR 8 + 1 TIMES(NOT TO USE ONOTHER REGISTER)
                LSR       #1, D2 ;A TOTAL OF 9 SHIFTS MADE
                AND.B     #$07,D2
                CMP.B     #$00,D2
                BEQ       MEMORY_ARTIMETIC ; ARTHIMETIC SHIFT(ASd)
                CMP.B     #$01, D2
                BEQ       MEMORY_LOGICAL ;LOGICAL SHIFT (LSd)
                CMP.B     #$03, D2
                BEQ       MEMORY_ROTATE ;ROTATE SHIFT (ROd)
                
                ;ELSE WRONG INSTRUCTION
                JMP    WRONG_INSTRUCTION *IT IS ROXd INSTRUCTION
                            
MEMORY_ARTIMETIC   CLR.L      D2
                   MOVE.W     (A2),D2
                   BTST       #8, D2 ;TEST THE DIRECTION BIT(8th BIT)
                   BNE        MEMORY_ARTIMETIC_LEFT    ;IF NOT ZERO, IT'S ASL
                   
                   ;ELSE MEMEORY_ARTIMETIC_RIGHT (ASR)
                    LEA     ASR_TAG, A6
                    JSR     EA3  ***** CALL <EA>
                    
LEGAL_INST_NO_SIZE  MOVE.B  #0, D7 *MOVE 0 INTO D7, TO INDICATE NO SIZE NEEDED 
                    RTS


MEMORY_ARTIMETIC_LEFT   LEA     ASL_TAG, A6 
                        JSR     EA3 ***** CALL <EA>
                        JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 AND RTS
  
MEMORY_LOGICAL     CLR.L     D2
                   MOVE.W    (A2),D2
                   BTST      #8, D2
                   BNE       MEMORY_LOGICAL_LEFT  ;LSL   
                  
                  ;ELSE MEMEORY_LOGICAL_RIGHT
                   LEA     ASR_TAG, A6
                   JSR     EA3 ***** CALL <EA>
                   JMP    LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 AND RTS



MEMORY_LOGICAL_LEFT     LEA     LSL_TAG, A6
                        JSR     EA3 ***** CALL <EA>
                        JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS


MEMORY_ROTATE      CLR.L     D2
                   MOVE.W    (A2),D2
                   BTST      #8,D2      ;TEST THE DIRECTION BIT
                   BNE       MEMORY_ROTATE_LEFT 
                    
                   *ELSE IT SI MEMORY ROTATE RIGHT (ROR)
                   LEA     ROR_TAG, A6
                   JSR     EA3 ***** CALL <EA>
                   JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS


MEMORY_ROTATE_LEFT      LEA     ROL_TAG, A6
                        JSR     EA3 ***** CALL <EA>
                        JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS


*----------------------END OF SHIFT INSTRUCTIONS -----------------------------------------------------------

***********************************************************************************************************
BRA_BGT_BLE_BEQ         CLR.L   D2
                        MOVE.W  (A2),D2
                        LSR.L   #8, D2 ;GET THE 11, 10,9,AND 8TH BITS TO THE FRONT  
                        AND.B   #$0F,D2   ;MASK THE BITS 
                        CMP.B   #$00,D2
                        BEQ     BRA_INST ;BRA
                        CMP.B   #$0E, D2
                        BEQ     BGT_INST ;BGT
                        CMP.B   #$0F, D2
                        BEQ     BLE_INST ;BLE
                        CMP.B   #$07, D2 
                        BEQ     BEQ_INST ;BEQ
                        
                        ;ELSE WRONG INST
                        JMP WRONG_INSTRUCTION                        
                       
BRA_INST        LEA     BRA_TAG, A6 *MOVE THE TAG NAME
                JSR     BRANCH_RTS 
                      
                JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS
                        
BGT_INST        LEA  BGT_TAG,A6 *MOVE THE TAG NAMEE

                JMP   BRANCH_RTS ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS
              
                        
BRANCH_RTS      MOVE.B  #8,D7
                ADD.w   (A2),D6
                RTS  
                
BLE_INST        LEA  BLE_TAG,A6 *MOVE THE TAG NAMEE
                JMP  BRANCH_RTS ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS 


BEQ_INST        LEA  BEQ_TAG,A6 *MOVE THE TAG NAMEE
                JMP  BRANCH_RTS ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS

NOT_NOP_RTS_MOVEM_LEA_JSR        CLR.L D2
                                 MOVE.W (A2),D2
                                 CMP.W  #$4E71, D2 ;NOP OPCODE 
                                 BEQ    NOP_INST
                                 
                                 CMP.W  #$4E75,D2 ;RTS OPCODE
                                 BEQ    RTS_INST     
                                        
                                 CLR.L  D2
                                 MOVE.W (A2),D2
                                 LSR.L  #8, D2
                                 AND.B  #$0F,D2
                                 CMP.B  #$06,D2
                                 BEQ    NOT_INST ;NOT
                                 
                                 MOVE.W (A2),D2
                                 LSR.L    #6, D2
                                 AND.B  #$07,D2
                                 CMP.B  #$07,D2
                                 BEQ    LEA_INST *LEA
    
                                 MOVE.W (A2),D2
                                 LSR.L  #8, D2 *MAKE A TOTAL OF 9 LSR
                                 LSR.L  #1,D2
                                 AND.B  #$07,D2 ;MASK BITS
                                 CMP.B  #$07, D2 
                                 BEQ    JSR_MAYBE_INST ;JSR, BUT NEED FURTHER FILTER 
                                 
CHECK_FOR_MOVEM                  MOVE.W (A2),D2
                                 BTST   #11,D2
                                 BNE    MOVEM_MAYBE_INST
                                 
                                 *ELSE WRONG INSTRUCTION
                                 JMP WRONG_INSTRUCTION  
                                 

JSR_MAYBE_INST  MOVE.W  (A2),D2
                LSR.L   #6,D2 *GET 8,7,6TH BITS
                AND.B   #$07,D2 *MASK UNWANTED BITS
                CMP.B   #$02,D2 *CHECK IF %010
                BEQ     JSR_INST *IF TRUE, IT IS JSR
               
                *ELSE GO BACK AND CHECK FOR MOVEM
                JMP     CHECK_FOR_MOVEM 
                  

NOP_INST      LEA NOP_TAG, A6
              CLR.B     D6 *CLEARING D6 TO SIGNIFY IT IS A COMPLETE OPCODE FOR MAIN SUBROUTINE              
              *JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS


RTS_INST      LEA RTS_TAG, A6 
              CLR.B     D6 *CLEARING D6 TO SIGNIFY IT IS A COMPLETE OPCODE FOR MAIN SUBROUTINE            
              JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS
              

NOT_INST      LEA NOT_TAG,  A6
              JSR       EA3 ***** <EA>  
              MOVE.W        (A2),D2
              LSR.L         #6,D2
              AND.B         #$03,D2
              CMP.B         #$0,D2
              BEQ           BYTE_SIZE *BYTE SIZE
              CMP.B         #$01,D2
              BEQ           WORD_SIZE *WORD SIZE
              CMP.B         #$02,D2
              BEQ           LONG_SIZE *LONG SIZE
              JMP           WRONG_SIZE *ELSE WRONG SIZE

JSR_INST      LEA     JSR_TAG, A6
              JSR       EA3  EA3 ***** <EA>  
              *JMP     LEGAL_INST_NO_SIZE      
                    

LEA_INST      LEA NOT_TAG, A6
              JSR       EA4  EA3 ***** <EA>  
              *JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED.
       
 
*----------------------MOVEM SUBROUTINE----------------------------------------------------------                    
MOVEM_MAYBE_INST     MOVE.W     (A2),D2
                     LSR.L      #7,D2
                     AND.B      #$07,D2
                     CMP.B      #$1,D2 *IF 9,8,7TH BITS ARE %001, IT COULD BE MOVEM OR EXT INST.
                     BEQ        MOVEM_EXT_INST *AT THIS POINT MOVEM AND EXT MAY HAVE THE SAME OPCODE
                     
                     *ELSE WRONG INSTRUCTION
                     JMP        WRONG_INSTRUCTION


MOVEM_EXT_INST       MOVE.W     (A2),D2
                     LSR.L      #3,D2
                     AND.B      #$07,D2
                     CMP.B      #$0,D2
                     BEQ        WRONG_INSTRUCTION *FITER OUT EXT INSTRUCTION
                      
                      *ELSE IT IS MOVEM INSTRUCTION, SO KEEP PROCESSING
                     MOVE.W    (A2),D2
                     BTST      #10,D2 *TEST THE DIRECTION (D) BIT
                     BEQ       MOVEM_REGISTER_TO_MEMORY *IF DIRECTION BIT IS 0->Register to memory. 
                      
                      *ELSE IF 1->Memory to register. 
                      
*6TH BIT HOLDS size of the registers being transferred.
*0 — Word transfer
*1 — Long transfer                      
MOVEM_MEMORY_TO_REGISTER   BTST  #6,D2  
                           BEQ   MOVEM_WORD_SIZE *WORD SIZE
                           JMP   MOVEM_LONG_SIZE *ELSE LONG SIZE   
                                                              
MOVEM_REGISTER_TO_MEMORY   JMP  MOVEM_MEMORY_TO_REGISTER
 
MOVEM_WORD_SIZE            LEA MOVEM_TAG,A6
                           MOVE.B  #7, D7
                           JSR  MOVEM_EA  EA3 ***** <EA>  
                           RTS 
                    
MOVEM_LONG_SIZE            LEA MOVEM_TAG,A6 
                           MOVE.B  #9, D7
                           JSR  MOVEM_EA  EA3 ***** <EA>  
                           RTS


      
         SIMHALT
         
*************************************************************************************************************
             
*I DON'T NEED THESE NAME TAGS,THESE ARE HERE JUST TO TEST PRINT_SUBROUTINE 

***************************************************************************************************************
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
BRA_TAG
BRA_TAG
BLE_TAG
BEQ_TAG
NOP_TAG
RTS_TAG
JSR_TAG
NOT_TAG
BGT_TAG
MOVEM_TAG

***************************************************************************************
*DANIESL SUBROUTINE LEBELS ----- TAKE THEM OUT WHEN YOU TEST YOUR PROGRAM
**************************************************************************************
NO_OPERAND_EA
MOVE_MOVEA_EA
MOVEQ_EA
MOVEM_EA
ADDQ_EA
EA1
EA2
EA3
EA4
none

**** ALL THE LEBELS ABOVE SHOULD BE TAKE OFF TO TEST YOUR PROGRAM------------------------------------------

    END    INSTRUCTION_DECIPHER  
*--------------------------------------------------------------------------------------------------------------
      
*********INSTRUCTION_DECIFER SUBROUTINE SOURCE FILE ENDS HERE **************************************************

*---------------------------------------------------------------------------------------------------------------



























*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~8~
