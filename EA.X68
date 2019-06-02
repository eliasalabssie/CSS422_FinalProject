BITS0TO5_MASK   EQU %00111111
BITS7TO8_MASK   EQU %11000000
BITS9TO11_MASK  EQU %00000111000000000
 
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

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
