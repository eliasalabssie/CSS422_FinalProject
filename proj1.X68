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
    ORG    $6000
START:
                    * Display WELCOME message
WELCOME_LABEL       LEA     WELCOME,A1
                    MOVE.B  #14,D0
                    TRAP    #15

*PROMPT THE USER FOR START AND END MEMORY ADDRESS
              * Display the prompt for START MEMORY input
GET_START           LEA         PROMPT_START,A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    JSR         GET_LONG_HEX_INPUT
                    MOVEA.L     D0,A2               * START address in A2
                   
              * Display the prompt for END MEMORY input
GET_END             LEA         PROMPT_END,A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    JSR         GET_LONG_HEX_INPUT
                    MOVE.L      D0,A3               * END address in A3
                    
               * VALIDATING USER INPUT
                    MOVE.L  A2,D1
                    CMP.L   D0,D1
                    BLT     GET_START
                    JSR     DISPLAY_INVALID_ADDRESS
                    BRA     GET_START

                * OP-CODE READING STARTS HERE
START_READING
                    
                    
                    
END_MAIN        SIMHALT
*****************************************************************************************



*________________________________________________________________________________________
*****************************   INPUT/OUTPUT SUBROUTINES    *****************************

*   ____________GET LONG HEX FROM USER__________
    *PARAMETER              NO PARAMETER
    *RETURN                 D0

GET_LONG_HEX_INPUT      MOVEM.L     D1-D7/A0-A6,-(SP)
                        MOVE.B      #2,D0
                        TRAP        #15
                        BRA         INPUT_FORMAT
                        
GET_LONG_HEX_INPUT_RETURN       MOVEM.L     (SP)+,D1-D7/A0-A6
                                RTS
                        
* PREPARE REGISTERS FOR THE FORMATING PROCESS
INPUT_FORMAT            CLR.L       D0
                        MOVE.B      #6,D1          ; the loop index

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
                BRA     GET_LONG_HEX_INPUT_RETURN

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
*           PARAMETER       NO REGISTER PARAMETER

DISPLAY_INVALID_ADDRESS     MOVEM.L     ALL_REG, -(SP)
                            LEA         ADDRESS_ERROR_TAG, A1
                            MOVE.B      #14,D0
                            TRAP        #15
                            MOVEM.L    (SP)+,ALL_REG
                            RTS
*_________________________________________________________________________________________



*****************************************************************************************


*________________________________________________________________________________________
***************************     DATA SECTION    *****************************************
*---------------------
WELCOME             DC.B    LF,LF,HT,HT,HT,HT,'WELCOME TO THE DISASSEMBLER',CR,LF,0
PROMPT_START        DC.B    LF,LF,HT,'Enter the START MEMORY address:  ',0
PROMPT_END          DC.B    LF,HT,'Enter the END MEMORY address:    ',0
ADDRESS_ERROR_TAG   DC.B    LF,LF,HT,HT,'INVALID ADDRESS.',CR,LF,CR,LF,0

*----------------------
FOR_PRINT       DS.L    1




*******************************************************************************************
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
