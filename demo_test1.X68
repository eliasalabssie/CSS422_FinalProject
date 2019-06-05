*****************************
*
* demo_test.X68
*
* Created 12/05/2018
*
* Test program for CSS 422 Disassembler Project Demo
*
*****************************

start		EQU	$00009000	* ORG and END address

* ORG the program so that it straddles the address boundary $00007FFF to $00008000

		ORG	start

        NOP
        MOVEM.W  D1-D5,(A0)
        divu    d0,d0
        MOVEM.L  D0-D7,-(A0)
        divu    #$ABCD,d0
        MOVEM.L  D4-D5/A0-A7,$1234
        MOVEM.W  D4-D5/A1-A7,$ABC47829
                
        MOVEM.W  (A0),D4-D5/A0-A6
        MOVEM.L  (A0)+,D4-D5/A1-A7
        MOVEM.L  $1234,D4-D5/A0-A7
        MOVEM.W  $ABC47829,D0-D7
        
        MOVE.W  D1,$08A3
        MOVE.W  D0,$1432A87C
        MOVE.L  (A4),D0
        MOVE.W  #123,(A5)+
        MOVE.W  (A1)+,(A5)+
        MOVE.W  -(A6),(A5)+
        MOVE.B  -(A0),-(A0)
        MOVE.L  $08A3,D0
        MOVE.B  $08A3,(A4)
        MOVE.W  $08A3,$1432A87C       
        
        MOVEQ.L  #1,D0
        MOVEQ.L  #3,D2
        MOVEQ.L  #$FF,D3
        
        
        MOVEA.W  D1,A2
        MOVEA.W  A3,A2
        MOVEA.L  (A4),A5
        MOVEA.W  (A1)+,A6
        MOVEA.W  -(A1),A4
        MOVEA.W  $08A3,A3
        MOVEA.L  $08A3EF14,A7
        MOVEA.L  #$531 ,A1   
        
        ADD.W  D1,D1
        ADD.W  D0,D3
        ADD.W  A3,D1
        ADD.L  (A4),D1
        ADD.W  (A5)+,D1
        ADD.W  -(A1),D1
        ADD.B  $08A3,D1
        ADD.W  $1432A87C,D1
        
        ADD.L  D1,(A4)
        ADD.W  D1,(A5)+
        ADD.W  D1,-(A1)
        ADD.B  D1,$08A3
        ADD.W  D1,$1432A87C
        
        ADDA.W  D1,A1
        ADDA.W  D0,A3
        ADDA.W  A3,A2
        ADDA.L  (A4),A1
        ADDA.W  (A5)+,A3
        ADDA.W  -(A1),A1
        ADDA.L  $08A3,A2
        ADDA.W  $1432A87C,A1
        
        ADDQ.W  #1,D0
        ADDQ.W  #2,A3
        ADDQ.L  #3,(A6)
        ADDQ.W  #4,(A5)+
        ADDQ.W  #5,-(A4)
        ADDQ.W  #6,(A5)+
        ADDQ.B  #7,$1432
        ADDQ.L  #8,$EFBC4321   
        
        SUB.W  D1,D1
        SUB.W  D0,D3
        SUB.W  A3,D1
        SUB.L  (A4),D1
        SUB.W  (A5)+,D1
        SUB.W  -(A1),D1
        SUB.B  $08A3,D1
        SUB.W  $1432A87C,D1
        
        SUB.L  D1,(A4)
        SUB.W  D1,(A5)+
        SUB.W  D1,-(A1)
        SUB.B  D1,$08A3
        SUB.W  D1,$1432A87C
        
        LEA  (A4),A1
        LEA  $08A3,A2
        LEA  $1432A87C,A3

        AND.W  D1,D1
        AND.W  D0,D3
        AND.L  (A4),D1
        AND.W  (A5)+,D1
        AND.W  -(A1),D1
        AND.B  $08A3,D1
        AND.W  $1432A87C,D1
        
        AND.L  D1,(A4)
        AND.W  D1,(A5)+
        AND.W  D1,-(A1)
        AND.B  D1,$08A3
        AND.W  D1,$1432A87C
        
        OR.W  D1,D1
        OR.W  D0,D3
        OR.L  (A4),D1
        OR.W  (A5)+,D1
        OR.W  -(A1),D1
        OR.B  $08A3,D1
        OR.W  $1432A87C,D1
        
        OR.L  D1,(A4)
        OR.W  D1,(A5)+
        OR.W  D1,-(A1)
        OR.B  D1,$08A3
        OR.W  D1,$1432A87C
        
        NOT.W  $08A3
        NOT.W  $1432A87C
        NOT.L  D0
        NOT.W  (A5)+
        NOT.W  (A5)+
        NOT.B  -(A0)
        NOT.L  D0
        NOT.B  (A4)
        NOT.W  $1432A87C 
        
        ASL.W   D1,D5
        ASL.B   #5,D1
        ASL.W   (A6)
        ASL.W   (A3)+
        ASL.W   -(A7)
        ASL.W   $1234
        ASL.W   $FEDC4321
        ASR.W   D1,D5
        ASR.B   #5,D1
        ASR.W   (A6)
        ASR.W   (A3)+
        ASR.W   -(A7)
        ASR.W   $1234
        ASR.W   $FEDC4321   

        LSL.W   D1,D5
        LSL.B   #5,D1
        LSL.W   (A6)
        LSL.W   (A3)+
        LSL.W   -(A7)
        LSL.W   $1234
        LSL.W   $FEDC4321
        LSR.W   D1,D5
        LSR.B   #5,D1
        LSR.W   (A6)
        LSR.W   (A3)+
        LSR.W   -(A7)
        LSR.W   $1234
        LSR.W   $FEDC4321
        
        ROL.W   D1,D5
        ROL.B   #5,D1
        ROL.W   (A6)
        ROL.W   (A3)+
        ROL.W   -(A7)
        ROL.W   $1234
        ROL.W   $FEDC4321
        ROR.W   D1,D5
        ROR.B   #5,D1
        ROR.W   (A6)
        ROR.W   (A3)+
        ROR.W   -(A7)
        ROR.W   $1234
        ROR.W   $FEDC4321
        

    END    START        ; last line of source





















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
