# CSS422_FinalProject
The disassembler program parses the op-code word of the
instruction and then decides how many additional words of
memory need to be read in order to complete the instruction
– If necessary, reads additional instruction words
– The disassembler program prints out the complete instruction
in ASCII-readable format
• Converts binary information to readable Hex

General Program Flow
1. I/O subroutines prompt user (me) for a starting and ending address in memory
2. User enters starting and ending addresses for region of memory to be
disassembled
3. I/O subroutines check for errors and if address are correct, prepare the display
buffer and send address in memory to Op-Code routines
4. Op-Code subroutines can either decode word to legitimate instruction or
cannot.
1. If word in memory cannot be decoded to legitimate instruction, I/O
routines writes to screen: XXXXXXXX DATA YYYY, where
XXXXXXXX is the memory address of the word and YYYY is the hex
value of the word
2. If it can be decoded then it is prepared for display and the EA information
is passed to the EA routines
5. EA subroutines decode EA field(s) and
1. If EA cannot be decoded, signals this back, or
2. Prepares operands for display
6. Once the instruction is displayed, process repeats itself

Required Op-code and EA to be disassembled in this project
NOP
MOVE, MOVEQ, MOVEM, MOVEA
ADD, ADDA,ADDQ
SUB
LEA
AND,OR,NOT
LSL, LSR, ASL, ASR
ROL,ROR
Bcc (BGT, BLE, BEQ)
JSR, RTS
BRA
Effective Addressing Modes:
Data Register Direct
Address Register Direct
Address Register Indirect
Immediate Addressing
Address Register Indirect with Post-incrementing
Address Register Indirect with Pre-decrementing
Absolute Long Address
Absolute Word Address
