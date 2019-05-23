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
OPTCREE

        ORG $1000
INSTRUCTION_Decifer:           *SUBROUTINE STARTS HERE 
            
        CLR.L      D0 ; CLEAR OUT D0
        MOVE.W     (A2),D2  ;
        SWAP       D2
        ROL        #2, D2 ;GETTING THE 2 MSB TO THE FRONT 
        AND.B      #%00000011,D2 ;MASK THE BITS FROM POSITION 2 AND UP
        CMP.B      #0, D2
        BEQ        MOVE_MOVEA ;THE TWO MOST LEFT BITS ARE 00, then it's MOVE || MOVEA

  *AT THIS POINT MOVE AND MOVEA ARE FILTERED OUT INTO THIER RESPECTIVE SUBROUTINE
        CLR.L       D2
        MOVE.W      (A2),D2 ; READ THE WORD INSTRUCTION FROM A1
        SWAP        D2 ; BRING THE LM
        ROL.W       #4, D0 ;BRING THE FIRST 4 MSB OF THE INSTRUCTION TO THE FRONT
        AND.B       #$0F,D0 ; MASK OTHER BITS
        
        CMP.B       #%0101, D0  ;A CODE FOR ADDQ 
        BEQ         ADDQ_INSTRUCTION ;THE INSTRUCTION IS ADDQ 
 
  *ADDQ FILTERED OUT AT THIS POINT
        CMP.B       #%0111, D0
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
        MOVE.B   #5, D7 ; A WRONG INSTRUCTION 'KEY'
        MOVEA.L  A2, A6 ;MOVING THE MEMORY ADDRESS INTO A6 DURING WRING INSTRUCTION
        MOVE.W  (A2)+,D6 ;THE VALUE AT THE MEMORY ADDRESS IS MOVED INTO D6 
        RTS
*****************************************************************************************************************
        
      
      
                    
MOVE_MOVEA      CLR.L   D2
                MOVE.W  (A2),D2
                LSR.W   #6, D2 ;MOVE THE 9,8,7TH BITS TO THE FRONT 
                AND.B   #$07, D2 ;MASK THE OHTER BITS EXCEPT 9,8,7
                CMP.B   #%001, D2 ;IF EQUAL, ITS MOVEA
                BEQ     MOVEA_INST
                LEA     MOVE_TAG, A6 ;MOVING THE INSTRUCTION INTO  A6
                
******************************************************************************************
                ;MOVE
********************************************************************************************
                
MOVEA_INST    LEA MOVEA_TAG, A6 ;,  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MOVEA


*------------- MOVEA AND MOVE ARE DONE                 
                
 
WRONG_INSTRUCTION
                
                                          
ADDQ_INSTRUCTION  
MOVEQ_INSTRUCTION
OR_INSTRUCTION
SUB_INSTRUCTION
AND_INSTRUCTION

*---------------------------------------
ADD_ADDA        CLR.L     D2
                MOVE.W   (A2),D2
                LSR      #6, D2
                AND.B    #$07, D2 ;MASK THE BITS BEFORE BIT 8TH
                CMP.B    #$03, D2 ;IF THE 8, 7,6TH BIT ARE EITHER 011 OR 111, ITS ADDA
                BRA      ADDA_INST
                CMP.B    #$07, D2 ;IF 8,7,6 BITS ARE 111, THEN ITS ADDA AGAIN 
                BRA      ADDA_INST
                
                ; IT IS MOVE

ADDA_INST  ;TANSFER THE INSTRUCTION TO SIZE
                       
SHIFT        CLR.L     D2
             MOVE.W    (A2),D2 ;
             LSR       #6, D2 ;MOVE THE 6,AND 7 BITS TO THR FRONT
             AND.B     #$03, D2  ;MASK THE OTHER BITS
             CMP.B     #$03, D2 ;IF THE LSB ARE 011
             BEQ       MEMORY_SHIFT ;IF THE 6,7TH BITS ARE 11, IT'S MEMORY SHIFT 
             BRA       REGISTER_SHIFT ;ELESE REGISTER SHIFT
             


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
                BEQ       MEMEORY_ROTATE 
                 ; PUT CODE FOR ELSE WRONG INSTRUCTION
                
     
MEMORY_ARTIMETIC   CLR.L      D2
                   MOVE.W     (A2),D2
                   LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                   CMP.B      #1, D2
                   BEQ        MEMEORY_ARTIMETIC_LEFT     
                   ;PUT CODE FOR MEMEORY_ARTIMETIC_RIGHT       



MEMEORY_ARTIMETIC_LEFT        ;PUT CODE FOR LEFT SHFT
  
MEMORY_LOGICAL     CLR.L      D2
                   MOVE.W     (A2),D2
                   LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                   CMP.B      #1, D2
                   BEQ        MEMEORY_LOGICAL_LEFT     
                   ;PUT CODE FOR MEMEORY_LOGICAL_RIGHT

MEMEORY_LOGICAL_LEFT ;PUT CODE FOR THIS


MEMEORY_ROTATE     CLR.L      D2
                   MOVE.W     (A2),D2
                   LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                   CMP.B      #1, D2
                   BEQ        MEMEORY_ROTATE_LEFT 
                   ;PUT CODE FOR MEMEORY_ROTATE_RIGHT
                




MEMEORY_ROTATE_LEFT ;PUT CODE FOR THIS 


REGISTER_SHIFT  CLR.L   D2
                MOVE.W  (A2),D2
                LSR     #3, D2 ;BRING THE 4TH AND 3RD BITS TO FRONT 
                AND.B   #$03, D2 ;MASK BITS OTHR THAN 2 LSM 
                CMP.B   #$00, D2
                BEQ     ARTIMETIC_REGISRER
                CMP.B   #$01,D2
                BEQ     LOGICAL_REGISTER
                CMP.B   #$03, D2
                BEQ     ROTATE_REGISTER
                ;PUT CODE FOR WRONG INSTR (if %10)
                
                
                
                
ARTIMETIC_REGISRER      CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                        CMP.B      #1, D2
                        BEQ        REGISTER_ARTIMETIC_LEFT     
                         ;PUT CODE FOR REG_ARTIMETIC_RIGHT  
REGISTER_ARTIMETIC_LEFT ;PUT THE CODE HERE              
         
LOGICAL_REGISTER        CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                        CMP.B      #1, D2
                        BEQ        REGISTER_LOGICAL_LEFT     
                         ;PUT CODE FOR REG_LOGICAL_RIGHT
REGISTER_LOGICAL_LEFT  ;PUT CODE
ROTATE_REGISTER         CLR.L      D2
                        MOVE.W     (A2),D2
                        LSR        #8,D2 ;GET THE 8TH BIT TOTHE FRONT 
                        CMP.B      #1, D2
                        BEQ        REGISTER_ROTATE_LEFT
                        ;PUT CODE FOR REGISTER_ROTATE RIGHT
                        


REGISTER_ROTATE_LEFT ;PUT CODE HERE

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


MOVEA_TAG
    END    INSTRUCTION_Decifer        ; last line of source
*********SOURCE FILE ENDS HERE **************************************************








*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~8~
