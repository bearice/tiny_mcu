Registers:
There are 8 general-purpose 16-bit registers, referred to as R0 through R7.
- R0 (A): General purpose register A
- R1 (B): General purpose register B
- R2 (C): General purpose register C
- R3 (D): General purpose register D
- R4 (PC): Program Counter, 16-bit
- R5 (SP): Stack Pointer, 16-bit
- R6 (FLG): Flag Register, 16-bit (lower 8 bits used: {C,Z,S,O,0,0,0,0}, C is bit 0)
- R7 (CTL): Control Register / Link Register. Used by JAL to store the return address (PC+1).

When a 4-bit field in an instruction (X, Y, or Z) refers to a register:
- If the field's MSB (e.g., X[3]) is 0, the lower 3 bits (e.g., X[2:0]) select one of R0-R7.
- If the field's MSB is 1, this often indicates an immediate value. See specific instruction descriptions.

Instruction Format:
General format: AAAA XXXX YYYY ZZZZ (16-bit instructions)
- AAAA: Opcode
- XXXX: X field (source operand, address, or mode)
- YYYY: Y field (source operand, address, or mode)
- ZZZZ: Z field (destination operand, address, or mode)

Opcodes (AAAA):

ALU Operations:
For all ALU operations (ADD, SUB, MUL, SHL, AND, OR, XOR, SHR), the result is stored in Rz (where z = ZZZZ[2:0]).
X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used. Flags in FLG may be affected.

0000 ADD Rx, Ry -> Rz  (or ADD immX, Ry -> Rz, ADD Rx, immY -> Rz, ADD immX, immY -> Rz)
     Action: Rz <= Rx + Ry.
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.
0001 SUB Rx, Ry -> Rz (or SUB immX, Ry -> Rz, etc.)
     Action: Rz <= Rx - Ry.
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.
0010 MUL Rx, Ry -> Rz (or MUL immX, Ry -> Rz, etc.)
     Action: Rz <= Rx * Ry.
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.
0011 SHL Rx, Ry -> Rz (or SHL immX, Ry -> Rz, etc.)
     Action: Rz <= Rx << Ry (logical shift left). Ry specifies shift amount (0-15).
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.
0100 AND Rx, Ry -> Rz (or AND immX, Ry -> Rz, etc.)
     Action: Rz <= Rx & Ry.
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.
0101 OR Rx, Ry -> Rz (or OR immX, Ry -> Rz, etc.)
     Action: Rz <= Rx | Ry.
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.
0110 XOR Rx, Ry -> Rz (or XOR immX, Ry -> Rz, etc.)
     Action: Rz <= Rx ^ Ry.
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.
0111 SHR Rx, Ry -> Rz (or SHR immX, Ry -> Rz, etc.)
     Action: Rz <= Rx >> Ry (logical shift right). Ry specifies shift amount (0-15).
     X and Y can be registers or 3-bit immediate values. If the MSB of the X (or Y) field in the instruction is 1, the lower 3 bits of that field (X[2:0] or Y[2:0]) are used as an immediate value, zero-extended to 16 bits. Otherwise, the register specified by X[2:0] (or Y[2:0]) is used.

Control Flow Instructions:

1000 JMP cond, value
     Instruction: 1000 ZZZZ YYYY XXXX
     Action: If (FLG[3:0] & XXXX[3:0]) == YYYY[3:0], then PC <= Rz (or PC <= immZ if ZZZZ[3]=1).
     Rz is specified by ZZZZ[2:0]. If ZZZZ[3] is 1, ZZZZ[2:0] is an immediate value (zero-extended).
     XXXX is a 4-bit mask. YYYY is the 4-bit expected value after masking.

Load/Store and Move Instructions:

1001 LOAD imm8 (LOADl/LOADh)
     Instruction: 1001 ZZZZ YYYY XXXX
     This instruction loads an 8-bit immediate value into either the lower or upper byte of register Rz (where z = ZZZZ[2:0]).
     The 8-bit immediate is formed by concatenating the YYYY and XXXX fields: imm8 = {YYYY, XXXX}.
     - If ZZZZ[3] is 0 (LOADl): Rz[7:0] <= imm8. Rz[15:8] remains unchanged.
     - If ZZZZ[3] is 1 (LOADh): Rz[15:8] <= imm8. Rz[7:0] remains unchanged.
     Note: ZZZZ[2:0] must specify a valid register index (0-7). FLG (R6) and CTL (R7) cannot be destinations for this instruction.

1010 MOVE Operations:
     Instruction format: 1010 ZZZZ YYYY XXXX
     Ry is specified by YYYY[2:0] (YYYY[3] must be 0).
     Rz is specified by ZZZZ[2:0] (ZZZZ[3] must be 0).

     Sub-opcodes via XXXX field:
     - XXXX = 0000: MOVE Ry, Rz
       Action: Rz <= Ry.
     - XXXX = 0001: MOVE [Ry], Rz (Load from memory)
       Action: Rz <= MEM[Ry].
     - XXXX = 0010: MOVE Ry, [Rz] (Store to memory)
       Action: MEM[Rz] <= Ry.
     - XXXX = 0011: MOVE [Ry], [Rz] (Memory to memory)
       Action: MEM[Rz] <= MEM[Ry]. (This would typically require a temporary internal register or multiple cycles not explicitly shown here).

     - XXXX = 0110: PUSH Ry, [Rz] (PUSH Ry onto stack pointed by Rz)
       Instruction: 1010 ZZZZ YYYY 0110
       Action: MEM[Rz] <= Ry, then Rz <= Rz + 1.
       (Ry is specified by YYYY[2:0], Rz by ZZZZ[2:0]. YYYY[3] and ZZZZ[3] should be 0 to select registers).
       Commonly, Rz would be SP (R5).

     - XXXX = 1001: POP [Ry], Rz (POP from stack pointed by Ry to Rz)
       Instruction: 1010 ZZZZ YYYY 1001
       Action: Rz <= MEM[Ry], then Ry <= Ry - 1.
       (Ry is specified by YYYY[2:0], Rz by ZZZZ[2:0]. YYYY[3] and ZZZZ[3] should be 0 to select registers).
       Commonly, Ry would be SP (R5).

RISC-style Instructions:

1100 LUI Rz, imm8 (Load Upper Immediate)
     Instruction: 1100 ZZZZ YYYY XXXX
     Action: Rz[15:8] <= {YYYY,XXXX}; Rz[7:0] <= 8'b00000000.
     Description: Loads the 8-bit immediate value, formed by concatenating YYYY and XXXX fields (imm8 = {YYYY, XXXX}),
     into the upper 8 bits of register Rz (specified by ZZZZ[2:0]). The lower 8 bits of Rz are set to zero.
     ZZZZ[3] must be 0 (selecting R0-R7 as potential targets).
     Note: The actual hardware implementation restricts Rz to R0-R6; Rz cannot be CTL (R7).

1101 JAL imm8_offset (Jump and Link)
     Instruction: 1101 ---- YYYY XXXX 
     Action: R7 <= PC + 1; PC <= PC + sign_extend({YYYY,XXXX}).
     Description: Stores the address of the next instruction (PC+1) into the Link Register (R7/CTL).
     Then, jumps to a new address calculated by adding the sign-extended 8-bit immediate offset (imm8_offset = {YYYY, XXXX})
     to the current PC. The ZZZZ field is not used for register selection.
     Note: imm8_offset is an 8-bit value. sign_extend means if imm8_offset[7] (MSB of the 8-bit immediate)
     is 1, it's extended as a negative number (2's complement) for the 16-bit addition to PC.

1110 JR Rx (Jump Register)
     Instruction: 1110 ---- ---- XXXX
     Action: PC <= Rx.
     Description: Jumps to the address contained in register Rx (specified by XXXX[2:0]).
     XXXX[3] must be 0. The YYYY and ZZZZ fields are not used.

Memory Mapping:
0000-07ff mcu_ram
8000-83ff vram