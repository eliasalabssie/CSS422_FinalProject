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
        BTST    #8,(A2)                 * Check opmode
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
                BTST    #5,(A2)           * Check whether shift count is immediate
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
        LSR.W   D3,D1                   * Move source data bits right
        MOVE.W  (A2),D5                 * Prepare destination bits
        ANDI.B  #BITS0TO5_MASK,D5       * Isolate destination bits
        JSR     FORMAT_IMMEDIATE_DATA
        
MOVEQ_EA    MOVE.B  (A2),D6                 * Prepare source data bits
            MOVE.W  (A2),D5                 * Prepare destination regiter bits
            ANDI.W  #BITS9TO11_MASK,D5      * Isolate destination register bits
            MOVE.B  #9,D3                   * Prepare shift count
            LSR.W   D3,D1                   * Move destination register bits right
            MOVE.B  #10,D7


MOVEM_EA   MOVE.W (A2),D2
           BTST    #10, D2
           BEQ     Register_to_memory *IF THE DIRCTION BIT IS 0, 
          
           
WRONG_MOVEM     MOVE.B  5,D5 *KEY FOR WRONG INSTRUCTION
                MOVE.W  (A2),D6 *PUT THE OPCODE ON D6
                MOVE.L   A2,A6  *PUT THE ADDRESS OF A2 ON A6
                RTS
                
          *ELSE IT IS  memory-to-register transfers
Memory_to_Register LSR.L #3, D2
                   AND.B #$07, D2
                   CMP.B #$2,D2
                   BEQ   MODE_010
                   
                   CMP.B #$03, D2
                   BEQ   MODE_011
                   CMP.B #$07,D2
                   BEQ   MODE_111
                   JMP   WRONG_MOVEM        
           
MODE_010  MOVE.W (A2),D2
          AND.B   #$37,D2
          BSET    #7,D2 *SET THE DESTINATION INDICATOR
          RTS 
           
       
MODE_011   JMP  MODE_010 
MODE_111   JMP MODE_010 


Register_to_memory MOVE.W (A2),D2
                   LSR.L #3, D2
                   AND.B #$07, D2
                   CMP.B #$2,D2
                   BEQ   MODE_01_0
                   CMP.B #$04, D2
                   BEQ   MODE_100
                   CMP.B #$07,D2
                   BEQ   MODE_11_1
                   JMP   WRONG_MOVEM
                   

MODE_01_0        JMP  MODE_010 

MODE_100        JMP  MODE_010 

MODE_11_1        JMP  MODE_010 




            
            
            
            
            
            
*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~8~
