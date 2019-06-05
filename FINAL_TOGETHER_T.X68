*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------


*________________________________________________________________________________________
*****************************     DECLARING CONSTANTS     *******************************
CR          EQU     $0D                 ; carriage return
LF          EQU     $0A                 ; line feed
HT          EQU     $09                 ; horizonatal tab
ALL_REG     REG     D0-D7/A0-A6         ; all registers 
*****************************************************************************************

*________________________________________________________________________________________
****************************                                    *************************
************************************        MAIN        *********************************
****************************                                    *************************

            * DISCRIPTION:  display WELCOME MESAGE, 
            *               accepts START & END address(long-8digit)
            *               validates, checking if START < END
            *               in not less, display error message, re-prompt
            *               if good input, start the loop
            *               decipher op-code, advance the pointer
            *               print instruction, and loop if there is more op-code
            
            
    ORG    $6000
START:
                    * Display WELCOME message
WELCOME_LABEL       LEA     WELCOME,A1
                    MOVE.B  #14,D0
                    TRAP    #15

**PROMPT THE USER FOR START AND END MEMORY ADDRESS
*              * Display the prompt for START MEMORY input
*GET_START           LEA         PROMPT_START,A1
*                    MOVE.B      #14,D0
*                    TRAP        #15
*                    JSR         GET_LONG_HEX_INPUT
*                    MOVEA.L     D0,A2               * START address in A2
*                   
*              * Display the prompt for END MEMORY input
*GET_END             LEA         PROMPT_END,A1
*                    MOVE.B      #14,D0
*                    TRAP        #15
*                    JSR         GET_LONG_HEX_INPUT
*                    MOVE.L      D0,A3               * END address in A3        
*        
*                    
*               * VALIDATING USER INPUT
*                    MOVE.L  A2,D1
*                    SUB.L   D1,D0
*                    CMP.L   #2,D0
*                    BGE     START_READING
*                    JSR     DISPLAY_INVALID_ADDRESS
*                    BRA     GET_START

                MOVE.L      #$00001000,A2
                MOVE.L      #$0000109A,A3
                
START_READING   JSR     INSTRUCTION_DECIPHER
                ADD.L   #2,A2
                JSR     PRINT_INSTRUCTION
                CMP.L   A2,A3           
                BGT     START_READING   
                                                      
END_MAIN        SIMHALT
*****************************************************************************************



*   ____________GET LONG HEX FROM USER__________
            * DESCRIPTION:  this subrouting accepts a string input
            *               from the user and turns it into HEX value
            
    *PARAMETER              NO PARAMETER
    *RETURN                 D0

GET_LONG_HEX_INPUT      MOVEM.L     D1-D7/A0-A6,-(SP)
                        LEA         INPUT_BUFFER,A1
                        MOVE.B      #2,D0
                        TRAP        #15
                        BRA         INPUT_FORMAT
                        
GET_LONG_HEX_INPUT_RETURN       MOVEM.L     (SP)+,D1-D7/A0-A6
                                RTS
                        
* PREPARE REGISTERS FOR THE FORMATING PROCESS
INPUT_FORMAT            CLR.L       D0
                        MOVE.B      #6,D1          
                        
* FORMATING THE FIRST 6 HEX DIGITS
INPUT_FORMAT0   CMP.B   #0,D1
                BEQ     INPUT_FORMAT1
                MOVE.B  (A1)+, D2
                JSR     BYTE_FORMAT0
                ASL.B   #4, D2
                MOVE.B  D2, D0
                ASL.L   #4, D0
                SUBI.B #1, D1
                BRA     INPUT_FORMAT0
                
                
* FORMATING THE LAST 2 HEX DIGITS                
INPUT_FORMAT1   MOVE.B  (A1)+, D2
                JSR     BYTE_FORMAT0
                ASL.B   #4, D2
                ADD.B   D2, D0
                MOVE.B  (A1)+, D2
                JSR     BYTE_FORMAT0
                ADD.B   D2, D0
                JMP     GET_LONG_HEX_INPUT_RETURN

* OFFSETING EACH BYTE TO GET THE ACTUAL VALUE 
BYTE_FORMAT0    CMP.B   #$39, D2                ; adjest hex value of ASCII number(0-9)
                BGT     BYTE_FORMAT2
                SUBI.B  #$30, D2
                RTS
                    
BYTE_FORMAT2    CMP.B       #$60, D2        
                BGT         BYTE_FORMAT3         
                SUBI.B      #$37, D2            ; adjest hex value of ASCII upercase(A-F)
                RTS
                
BYTE_FORMAT3    SUBI.B      #$57,D2             ; adjest hex value of ASCII lowercase(a-f)
                RTS
*_________________________________________________________________________________________


*__________________     DISPLAY INVALID ADDRESS     ______________________________________
                    *DISCRIPTION:   display input error message.
                    
*           PARAMETER       NO REGISTER PARAMETER

DISPLAY_INVALID_ADDRESS     MOVEM.L     ALL_REG, -(SP)
                            LEA         ADDRESS_ERROR_TAG, A1
                            MOVE.B      #14,D0
                            TRAP        #15
                            MOVEM.L    (SP)+,ALL_REG
                            RTS
*_________________________________________________________________________________________



*****************************************************************************************
*                               ELIAS                                                   *
*****************************************************************************************


INSTRUCTION_DECIPHER:           *SUBROUTINE STARTS HERE 
        
        CLR.L   D7
                
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
                JSR     MOVE_MOVEA_EA ***** CALL <EA>
                MOVE.W (A2),D2 ;
                LSR.L   #8, D2 ;GET THE 13, 12 BITS FOR SIZE
                LSR.L   #4, D2 ;TOTAL OF 11 SHIFTS 
                AND.B   #$03,D2 ;MASK THE BITS OTHER THAN SIZE BITS
                CMP.B   #$03, D2 
                BEQ     WORD_SIZE ;IF BYTE, ITS WORD SIZE
                CMP.B   #$02,D2
                BEQ     LONG_SIZE ;WORD SIZE
                
                
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
                   LEA     LSR_TAG, A6
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
                RTS
                        
BGT_INST        LEA  BGT_TAG,A6 *MOVE THE TAG NAMEE
                JSR  BRANCH_RTS
                RTS              
                        
BRANCH_RTS      MOVE.B  #8,D7
                MOVE.W   (A2),D6
                RTS  
                
BLE_INST        LEA  BLE_TAG,A6 *MOVE THE TAG NAMEE
                JSR     BRANCH_RTS
                RTS
                
BEQ_INST        LEA  BEQ_TAG,A6 *MOVE THE TAG NAMEE
                JSR  BRANCH_RTS 
                RTS
                
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
              JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED AND RTS


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
              JSR       EA3  *EA3 ***** <EA>  
              JMP     LEGAL_INST_NO_SIZE      
                    

LEA_INST      LEA LEA_TAG, A6
              JSR       EA4  EA3 ***** <EA>  
              JMP     LEGAL_INST_NO_SIZE ;PUT 0 INTO D7 TO INDICATE NO SIZE NEEDED.
       
 
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
                           JSR  MOVEM_EA  *EA3 ***** <EA>  
                           RTS 
                    
MOVEM_LONG_SIZE            LEA MOVEM_TAG,A6 
                           MOVE.B  #9, D7
                           JSR  MOVEM_EA  EA3 ***** <EA>  
                           RTS

                ******************************************************************
                                ******  DANIEL  ***************
                ******************************************************************

BITS0TO5_MASK   EQU %00111111
BITS7TO8_MASK   EQU %11000000
BITS9TO11_MASK  EQU %00000111000000000

FORMAT_IMMEDIATE_DATA   MOVE.B  #10,D7
                        CMP     #0,D6
                        BEQ     IMMEDIATE0
                        BRA     IMMEDIATE_END
IMMEDIATE0              MOVEQ   #8,D6

IMMEDIATE_END           RTS
 
EA1     MOVE.W  (A2),D1                 * Prepare to capture register field
        MOVE.W  (A2),D2                 * Prepare to capture EA field
        ANDI.B  #BITS0TO5_MASK,D1       * Isolate the source EA bits
        
        ANDI.W  #BITS9TO11_MASK,D2      * Isolate the source EA bits
        MOVE.B  #9,D3                   * Prepare shift count
        LSR.W   D3,D2                   * Move register bits right
        ANDI.B  #%11000111,D2           * Set EA mode
        MOVE.W  (A2),D3
        BTST    #8,D3                   * Check opmode
        BEQ     EA1_MODE_ZERO           * Check opmode
        
EA1_MODE_ONE    MOVE.W  D1,D5           * Set EA as destination
                MOVE.W  D2,D6           * Set register as source
                BRA EA1_END             * Complete subroutine
        
EA1_MODE_ZERO   MOVE.W  D1,D6           * Set EA as source
                MOVE.W  D2,D5           * Set register as destination

EA1_END         ORI.B   #BITS7TO8_MASK,D6       * Populate the S and D bits
                RTS
        
EA2             MOVE.W  (A2),D6         * Prepare to capture source EA
                ANDI.W  #BITS9TO11_MASK,D6      * Isolate the source EA bits
                MOVE.B  #9,D3                   * Prepare shift count
                LSR.W   D3,D6                   * Move register bits right
                MOVE.W  (A2),D3
                BTST    #5,D3           * Check whether shift count is immediate
                BEQ     EA2_IMMEDIATE
 
EA2_REGISTER    ORI.B   #%11000000,D6   * Set S and D bits
                BRA     EA2_END         * Complete subroutine
                
EA2_IMMEDIATE   MOVE.B  #10,D7          * Prepare to pass immediate data to print subroutine
                JSR     FORMAT_IMMEDIATE_DATA
                
EA2_END         MOVE.W  (A2),D5         * Prepare to capture destination EA
                AND.B   #%00000111,D5
                RTS
   
EA3     MOVE.W  (A2),D6
        ANDI.B  #BITS0TO5_MASK,D6       * Isolate the source EA bits
        ORI.B   #%10000000,D6
        RTS

EA4     MOVE.W  (A2),D1         
        ANDI.B  #BITS0TO5_MASK,D1       * Isolate the source EA bits
        ORI.B   #BITS7TO8_MASK,D1       * Populate the S and D bits
        MOVE.B  D1,D6                   * Pass source EA to print subroutine
        MOVE.W  (A2),D1         
        
        ANDI.W  #BITS9TO11_MASK,D1   * Isolate the destination register number
        MOVE.B  #9,D2                   * Prepare shift count
        LSR.W   D2,D1                   * Move register bits right
        ANDI.B  #%11001111,D1           * Set destination mode
        ORI.B   #%00001000,D1           * Set destination mode
        MOVE.B  D1,D5                   * Pass destination EA to print subroutine
        RTS
        
MOVE_MOVEA_EA   MOVE.W  (A2),D1
                ANDI.B  #BITS0TO5_MASK,D1           * Isolate the source EA bits
                ORI.B   #BITS7TO8_MASK,D1           * Populate the S and D bits
                MOVE.B  D1,D6                   * Pass source EA to print subroutine
                MOVE.W  (A2),D1         
                MOVE.W  (A2),D2 
                ANDI.W  #BITS9TO11_MASK,D1   * Isolate the destination register number
                MOVE.B  #9,D3                   * Prepare shift count
                LSR.W   D3,D1                   * Move destination register bits right
                ANDI.W  #%0000000111000000,D2   * Isolate the destination mode
                LSR.W   #3,D2                  * Move destination mode bits right
                OR.W    D2,D1
                MOVE.B  D1,D5                   * Pass destination EA to print subroutine
                RTS
   
ADDQ_EA MOVE.W  (A2),D6                 * Prepare source data bits
        ANDI.W  #BITS9TO11_MASK,D6      * Isolate source data bits
        MOVE.B  #9,D3                   * Prepare shift count
        LSR.W   D3,D6                  * Move source data bits right            !---
        MOVE.W  (A2),D5                 * Prepare destination bits
        ANDI.B  #BITS0TO5_MASK,D5       * Isolate destination bits
        JSR     FORMAT_IMMEDIATE_DATA
        RTS                                     !---
        
MOVEQ_EA    MOVE.W  (A2),D6                 * Prepare source data bits          !---
            AND.W   #$00FF,D6                                                   !---
            MOVE.W  (A2),D5                 * Prepare destination regiter bits
            ANDI.W  #BITS9TO11_MASK,D5      * Isolate destination register bits
            MOVE.B  #9,D3                   * Prepare shift count
            LSR.W   D3,D5                   * Move destination register bits right
            MOVE.B  #10,D7
            RTS                                 !---


WRONG_MOVEM     MOVE.B  5,D5 *KEY FOR WRONG INSTRUCTION
                MOVE.W  (A2),D6 *PUT THE OPCODE ON D6
                MOVE.L   A2,A6  *PUT THE ADDRESS OF A2 ON A6
                RTS


MOVEM_EA   MOVE.W (A2),D2
           BTST    #10, D2
           BEQ     Register_to_memory *IF THE DIRCTION BIT IS 0, 
          
           
                
          *ELSE IT IS  memory-to-register transfers
Memory_to_Register LSR.L #3, D2
                   AND.B #$07, D2
                   CMP.B #$2,D2
                   BEQ   MODE_010
                   CMP.B #$03, D2
                   BEQ   MODE_010  
                   CMP.B #$07,D2
                   BEQ   MODE_010  
                   JMP   WRONG_MOVEM        
           
MODE_010  MOVE.W    (A2),D2
          AND.B     #$3F,D2
          BSET      #7,D2 *SET THE DESTINATION INDICATOR
          MOVE.B    D2,D6
          RTS

Register_to_memory MOVE.W (A2),D2
                   LSR.L #3, D2
                   AND.B #$07, D2
                   CMP.B #$2,D2
                   BEQ   MODE_01_0
                   CMP.B #$04, D2
                   BEQ   MODE_01_0 
                   CMP.B #$07,D2
                   BEQ   MODE_01_0 
                   JMP   WRONG_MOVEM
                   

MODE_01_0       MOVE.W  (A2),D6
                ANDI.B  #$3F,D6
                RTS
         
              

*****************************************************************************************



*                                   BREAK                                               *




*****************************************************************************************
*                               PRINT_INSTRUCTION                                       *
*****************************************************************************************

*********************       THE PRINT INSTRUCTION SUBROUTINE      **********************
*PARAMETERS     A6      INSTRUCTION TAG -> for good print
*                       MEMORY ADDRESS  -> for bad print
*               A2      WHERE THE MEMORY READING IS POINTING AT----(GLOBAL)
*               A3      THE POINTER FOR THE END--------------------(GLOBAL)
*               D7      SIZE (0 IF NO SIZE REQUIRED)
*                       1=B, 2=W, 4=L   -> for good print
*                                   5   -> for bad print
*               D6      SOURCE EA (sd-mod-reg) -> s = source (check this to print
*                                                              the source)
*                                              -> d = destination ( check this to print
*                                                               the destination)
*                                              -> reg + mod = EA and mode
*                       DATA (OR BAD INSTRUCTION) -> for bad print
*

PRINT_INSTRUCTION       MOVEM.L     A0-A1/A3-A6/D0-D7,-(SP)     * BACKUP REGISTERS
                        
                        CMP.B   #5,D7                           * 5 = BAD PRINT
                        BEQ     BAD_PRINT                       
                        CMP.B   #7,D7                           * 7 = MOVEM.W
                        BEQ     PRINT_MOVEM
                        CMP.B   #8,D7                           * 8 = BRA
                        BEQ     PRINT_BRA
                        CMP.B   #9,D7                           * 9 = MOVEM.L
                        BEQ     PRINT_MOVEM
                        CMP.B   #10,D7                           * 10 = ADDQ,SUBQ
                        BEQ     PRINT_QUICK_TYPE
                        CMP.B   #11,D7                           * 11 = ASR.B,LSR.B...
                        BEQ     PRINT_QUICK_TYPE
                        CMP.B   #12,D7                           * 12 = ASR.W,LSR.W...
                        BEQ     PRINT_QUICK_TYPE
                        CMP.B   #14,D7                           * 14 = ASR.L,LSR.L...
                        BEQ     PRINT_QUICK_TYPE
                                                
PRINT_INST_TAG          JSR     PRINT_TAB
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
                            MOVEM.L     (SP)+,A0-A1/A3-A6/D0-D7
                            RTS                         * RETURN TO THE CALLER
                        
*_______________________________________________________________________________________



*___________________    PRINT THE QUICK TYPES   ________________________________________
*   PARAMETR    A6      INSTRUCTION TAG
*               D6      THE IMMIDIATE VALUE
*               D5      THE REGISTER MODE AND CODE
*               D7      SIZE + 10

PRINT_QUICK_TYPE        JSR         PRINT_TAB
                        MOVE.L      A6,A1                   * PRINT THE INSTRUCTIO TAG
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        SUB.B       #10,D7
                        JSR         PRINT_SIZE              * PRINT SIZE
                        JSR         PRINT_TAB               * RRINT TAB
                        
                        CLR.L       D1
                        
                        JSR         PRINT_HASH_SIGN         * #
                        MOVE.B      D6,D1                   * PRINT DECIMAL
                        MOVE.L      #3,D0
                        TRAP        #15
                        JSR         PRINT_COMMA             * ,
                        
                        MOVE.B      D5,D4
                        JSR         PRINT_EA                * PRINT THE REGISTER
                        
                        JMP         PRINT_INSTRUCTION_RETURN
*_______________________________________________________________________________________


*___________________    MOVEM PRINT     ________________________________________________
*   PARAMETR

PRINT_MOVEM         JSR     PRINT_TAB                   * PRINT TAB
                    MOVE.L  A6,A1                       * PRINT MOVEM
                    MOVE.B  #14,D0
                    TRAP    #15
                    
                    SUB.B   #5,D7                       * ADJEST D7 TO PRINT SIZE
                    JSR     PRINT_SIZE                  * PRINT SIZE
                    JSR     PRINT_TAB
                    
                    BTST    #7,D6
                    BEQ     PRINT_MOVEM_MASK            * PRINT THE REGSTER/S FIRST
                    
                    MOVE.B  D6,D4
                    JSR     PRINT_EA
                    JSR     PRINT_COMMA
                    
PRINT_MOVEM_MASK        MOVE.W  (A2)+,D4
                        JSR     PRINT_MASK
                        BTST    #7,D6                       * CHECK DIRCTION
                        BNE     PRINT_INSTRUCTION_RETURN
                        
                        JSR     PRINT_COMMA
                        MOVE.B  D6,D4
                        JSR     PRINT_EA
                        JMP     PRINT_INSTRUCTION_RETURN
                        
*________________PRINTS THE MASK
*   PARAMETER   D4      THE MASK (WORD)
*               D6      THE DIRECTION (BIT#7)
                        
PRINT_MASK      MOVEM.L     ALL_REG,-(SP)
                BTST        #7,D6                   * CHECKING DIRECTION
                BNE         MEM_TO_REG

REG_TO_MEM          MOVE.L      #15,D1              * START OF FLIPPING THE MASK
                    
FLIP_DIRECTION      CMP.B       #0,D1
                    BLT         REG_TO_MEMO_OK
                    MOVE.B      #31,D0
                    SUB.B       D1,D0
                    BTST        D1,D4
                    BNE         FLIP_SET
FLIP_CLR            BCLR        D0,D4
                    BRA         FLIP_LOOP_INCR
FLIP_SET            BSET        D0,D4                    
FLIP_LOOP_INCR      SUB.B   #1,D1
                    BRA     FLIP_DIRECTION 
REG_TO_MEMO_OK      SWAP    D4

MEM_TO_REG          MOVE.B  #0, D3
PRINT_MASK_LOOP     CMP.B   #16, D3
                    BEQ     PRINT_MASK_RETURN
                    BTST    D3,D4
                    BNE     SET_MASK
                    BRA     PRINT_MASK_LOOP_INCR
SET_MASK        CMP.B   #7,D3
                BGT     A_REG
D_REG           MOVE.B  #$D0, D1
                ADD.B   D3,D1
                JSR     PRINT_REGISTOR
                JSR     PRINT_FORWARD_SLASH
                BRA     PRINT_MASK_LOOP_INCR
A_REG               MOVE.B  #$98,D1
                    ADD.B   D3,D1
                    JSR     PRINT_REGISTOR
                    JSR     PRINT_FORWARD_SLASH
PRINT_MASK_LOOP_INCR    ADD.B   #1,D3
                        SUB.B   #1,D1
                        BRA     PRINT_MASK_LOOP
PRINT_MASK_RETURN       MOVEM.L     (SP)+, ALL_REG
                        RTS
*_______________________________________________________________________________________



*___________________    PRINT BRA   ____________________________________________________
*   PARAMETER       A6      BRA_TAG
*                   D6      THE OP-CODE

PRINT_BRA       JSR         PRINT_TAB
                MOVE.L      A6,A1           * PRINT THE BRA_TAG
                MOVE.B      #14,D0
                TRAP        #15
                JSR         PRINT_TAB       * PRINT TAB
                
                CLR.L       D1
                
                CMP.B       #$00,D6                 * WORD DISPLACEMENT
                BEQ         WORD_DISPLACEMENT
                CMP.B       #$FF,D6                 * LONG DISPLACEMENT
                BEQ         LONG_DISPLACEMENT
                
                MOVE.B      D6,D1                   * BYTE DISPLACEMENT
                BTST        #7,D1                
                BEQ         PRINT_BRA_RETURN        * POSITIVE DISPLACEMENT
                
                NOT.B       D1                      * 1'S COMPLEMENT    (ON BYTE)
                ADD.W       #$1,D1                   * -> 2'S COMPLEMENT
                NEG.L       D1
                BRA         PRINT_BRA_RETURN

WORD_DISPLACEMENT       MOVE.W      (A2)+,D1         * READ THE DISPLACEMENT (WORD)
            
                        BTST    #15,D1
                        BEQ         PRINT_BRA_RETURN        * POSITIVE DISPLACEMENT
                        
                        NOT.W       D1                      * 1'S COMPLEMENT    (ON WORD)
                        ADD.L       #$1,D1                   * -> 2'S COMPLEMENT
                        NEG.L       D1
                        BRA         PRINT_BRA_RETURN

LONG_DISPLACEMENT           MOVE.L      (A2)+,D1         * READ THE DISPLACEMENT (LONG)
    
PRINT_BRA_RETURN    MOVE.L  #3,D0                   * PRINTIN THE DISPLACEMENT
                    TRAP    #15
                    JMP     PRINT_INSTRUCTION_RETURN
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
                JMP     PRINT_INSTRUCTION_RETURN                
                
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
    
PRINT_EA        MOVEM.L A0-A1/A3-A6/D0-D7,-(SP)
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

CHECK_EA_AB_W           ADD.B   D4,D3
                        CMP.B   #$38,D3     
                        BNE     CHECK_EA_AB_L
                        JSR     PRINT_DOLLAR        * $
                        MOVE.W  (A2)+,D5            * PRINTING WORD ABSOLUTE
                        MOVE.B  #2,D3
                        JSR     PRINT_HEX
                        BRA     PRINT_EA_RETURN
                        
CHECK_EA_AB_L       CMP.B   #$39, D3
                    BNE     CHECK_EA_IMM
                    JSR     PRINT_DOLLAR        * $
                    MOVE.L  (A2)+,D5            * PRINTING LONG ABSOLUTE
                    MOVE.B  #4,D3
                    JSR     PRINT_HEX
                    BRA     PRINT_EA_RETURN
                    
CHECK_EA_IMM        CMP.B   #4,D7
                    BNE     READ_WORD_IMM
                    JSR     PRINT_HASH_SIGN     * #
                    JSR     PRINT_DOLLAR        * $
                    MOVE.L  (A2)+,D5            * PRINTING LONG IMMIDIATE
                    MOVE.B  #4,D3
                    JSR     PRINT_HEX
                    BRA     PRINT_EA_RETURN
                    
READ_WORD_IMM       JSR     PRINT_HASH_SIGN     * #
                    JSR     PRINT_DOLLAR        * $
                    MOVE.W  (A2)+,D5            * PRINTING WORD/BYTE IMMIDIATE        
                    MOVE.B  #2,D3
                    JSR     PRINT_HEX

PRINT_EA_RETURN     MOVEM.L     (SP)+,A0-A1/A3-A6/D0-D7   * THE RETURN FOR THE EA PRINTER
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


*_______________    PRINT HASH SIGN   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
        
PRINT_HASH_SIGN     MOVEM.L     ALL_REG,-(SP)
                    LEA         HASH_SIGN_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS

*___________________________________________________________________________________



*_______________    PRINT DOLLAR   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
        
PRINT_DOLLAR        MOVEM.L     ALL_REG,-(SP)
                    LEA         DOLLAR_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS

*___________________________________________________________________________________



*_______________    PRINT FORWARD SLASH   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
        
PRINT_FORWARD_SLASH     MOVEM.L     ALL_REG,-(SP)
                        LEA         FORWARD_SLASH_TAG, A1
                        MOVE.B      #14,D0
                        TRAP        #15
                        MOVEM.L     (SP)+,ALL_REG
                        RTS

*___________________________________________________________________________________


*__________________________________________________________________________________
PRINT_BUFFER    DS.B    10
INPUT_BUFFER    DS.B    15

DATA_TAG            DC.B    'DATA',0
NEWLINE_TAG         DC.B    CR,LF,0
PLUS_TAG            DC.B    '+',0
MINUS_TAG           DC.B    '-',0
OPEN_PAR_TAG        DC.B    '(',0
CLOSED_PAR_TAG      DC.B    ')',0
HASH_SIGN_TAG       DC.B    '#',0
DOLLAR_TAG          DC.B    '$',0
FORWARD_SLASH_TAG   DC.B    '/',0

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
SUBI_TAG        DC.B    'SUBI',0

*________________________________________________________________________________________
***************************     DATA SECTION    *****************************************
*---------------------
WELCOME             DC.B    LF,LF,HT,HT,HT,HT,'WELCOME TO THE DISASSEMBLER',CR,LF,0
PROMPT_START        DC.B    LF,LF,HT,'Enter the START MEMORY address:  ',0
PROMPT_END          DC.B    LF,HT,'Enter the END MEMORY address:    ',0
ADDRESS_ERROR_TAG   DC.B    LF,LF,HT,HT,'INVALID ADDRESS.',CR,LF,CR,LF,0

*----------------------



*******************************************************************************************
    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
