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
                JSR     CHECK_EA_MODE              * Check whether EA modes are valid
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
                JSR     CHECK_EA_MODE              * Check whether EA modes are valid
                RTS
   
EA3     MOVE.W  (A2),D6
        ANDI.B  #BITS0TO5_MASK,D6       * Isolate the source EA bits
        ORI.B   #%10000000,D6
        JSR     CHECK_EA_MODE              * Check whether EA modes are valid
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
        JSR     CHECK_EA_MODE              * Check whether EA modes are valid
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
                JSR     CHECK_EA_MODE              * Check whether EA modes are valid
                RTS
   
ADDQ_EA MOVE.W  (A2),D6                 * Prepare source data bits
        ANDI.W  #BITS9TO11_MASK,D6      * Isolate source data bits
        MOVE.B  #9,D3                   * Prepare shift count
        LSR.W   D3,D6                  * Move source data bits right            !---
        MOVE.W  (A2),D5                 * Prepare destination bits
        ANDI.B  #BITS0TO5_MASK,D5       * Isolate destination bits
        JSR     FORMAT_IMMEDIATE_DATA
        JSR     CHECK_EA_MODE              * Check whether EA modes are valid
        RTS                                    !---
        
MOVEQ_EA    MOVE.W  (A2),D6                 * Prepare source data bits          !---
            AND.W   #$00FF,D6                                                   !---
            MOVE.W  (A2),D5                 * Prepare destination regiter bits
            ANDI.W  #BITS9TO11_MASK,D5      * Isolate destination register bits
            MOVE.B  #9,D3                   * Prepare shift count
            LSR.W   D3,D5                   * Move destination register bits right
            MOVE.B  #10,D7
            JSR     CHECK_EA_MODE              * Check whether EA modes are valid
            RTS                                 !---

MOVEM_EA        MOVE.W  (A2),D6
                ANDI.W  #BITS0TO5_MASK,D6   * Isolate EA bits
                MOVE.W  (A2),D0             * Prepare to test direction bit
                BTST    #10,D0              * Test direction bit
                BEQ     MOVEM_EA_DST

MOVEM_EA_SRC    BSET    #7,D6               * Set source bit
                BRA     MOVEM_EA_END
            
MOVEM_EA_DST    BSET    #6,D6               * Set destination bit
                
MOVEM_EA_END    JSR     CHECK_EA_MODE_1
                RTS

CHECK_EA_MODE   MOVE.W  #0,A5               * Reset invalid flag
                MOVE.B  D6,D1               * Pass source into subroutine
                JSR     CHECK_VALID_EA
                MOVE.B  D5,D1               * Pass destination into subroutine
                JSR     CHECK_VALID_EA
                RTS
                
CHECK_EA_MODE_1 MOVE.W  #0,A5               * Reset invalid flag
                MOVE.B  D6,D1               * Pass source into subroutine
                JSR     CHECK_VALID_EA
                RTS
         
CHECK_VALID_EA  MOVE.B  D1,D0
                LSR     #3,D0
                ANDI.B  #%00000111,D0
                CMP.B   #%00000101,D0
                BEQ     INVALID_EA
                CMP.B   #%00000110,D0
                BEQ     INVALID_EA
                CMP.B   #%00000111,D0
                BEQ     VALID_EA_PC
                RTS
                
                
VALID_EA_PC     MOVE.B  D1,D0
                ANDI.B  #%00000111,D0
                CMP.B   #%00000010,D0
                BEQ     INVALID_EA
                CMP.B   #%00000011,D0
                BEQ     INVALID_EA
                RTS
                
INVALID_EA      JSR     WRONG_INSTRUCTION
                RTS

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
