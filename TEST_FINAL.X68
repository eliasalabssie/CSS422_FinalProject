*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  
NOP             NOP
        
MOVE            MOVE.B  $1234,D7
                MOVE.W  (A1),D5
                MOVE.L  D6,D0
                MOVE.W  #$12EF,D3
        
MOVEA        MOVEA.W     A1,A2
        
MOVEQ           MOVEQ      #$23,D6
                MOVEQ      #123,D7
                
MOVEM       MOVEM.L     A0-A6,-(SP)
            MOVEM.L     (SP)+,D0-D7
            MOVEM.W     D0/D5/A2-A6,-(A1)
            MOVEM.W     (A2),D4/D6-D7/A5
            
ADD             ADD.W   D6,D7
                ADD.L   $1234,D0
                ADD.B   (A1),D7

 
ADDA            ADDA.W  A1,A2
                ADDA.L  A5,A6
                
                
ADDQ            ADDQ.B      #5,D5
                ADDQ.L      #5,D7
                
SUB             SUB.W   D6,D7
                SUB.L   $1234,D0
                SUB.B   $123F,D7
                
                
LEA             LEA     $1234,A0

AND             AND.L   #$0000FFFF,D5
                AND.B   D5,D6
                AND.W   D7,(A5)
                
OR              OR.L    D7,D4
                OR.B    D5,(A5)
                OR.W    #$00FF,D6
                
NOT         NOT.L   (A1)
            NOT.W   D7

LSL         LSL.L   #4,D7
            LSL.B   D7,D5
            LSL.W   $1234
            
LSR             LSR.B   #6,D3
                LSR.W   D7,D7
                LSR.W   $1234
                
                
ASL         ASL.L   #2,D7
            ASL.W   D7,D5
            ASL     $1234
            
            
ASR         ASR.L       #3,D5
            ASR.W       D5,D3
            ASR         $1234
            
ROL         ROL.L   #6,D6
            ROL.W   D4,D6
            ROL.W   $1234
            
ROR             ROR.L   #2,D2
                ROR.L   D7,D0
                ROR     $1234
                
BGT         BGT     $1070
            BGT     $1090
            
BLE         BLE     $109D

BEQ         BEQ     $10A0

BRA         BRA     $1088

JSR         JSR     $ABCD

RTS         RTS




    SIMHALT             ; halt simulator
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
