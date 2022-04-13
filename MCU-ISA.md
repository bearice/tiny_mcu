Register:
ABCD rw  0000-1011
PC   rw  0100
SP   rw  0101
CTL  rw  0110 
FLG  ro  0111 {12'b0,c,z,s,o}
IMMx ro  1xxx

Inst:
1234567890ABCDEF
AAAAXXXXYYYYZZZZ

AAAA:
0000 ADD X+Y->Z
0001 SUB X-Y->Z
0010 MUL X*Y->Z
0011 SHL X<<Y->Z
0100 AND X&Y->Z 
0101 OR  X|Y->Z 
0110 XOR X^Y->Z 
0111 SHR X>>Y->Z
1000 JMP Z -> PC if FLG[3:0] & X == Y
1001 LOADl {XY} -> Z[7:0]  if Z[3]=0
1001 LOADh {XY} -> Z[15:8] if Z[3]=1
1010 MOVE {Y} -> {Z} (X=0000) //reg to reg
1010 MOVE [Y] -> {Z} (X=0001) //mem to reg
1010 MOVE {Y} -> [Z] (X=0010) //reg to mem
1010 MOVE [Y] -> [Z] (X=0011) //mem to mem
1010 PUSH {Y} -> [Z] (X=0110) //reg to mem, Z++
1010 POP  [Y] -> {Z} (X=1001) //mem to reg, Y--

Memory Mapping:
0000-0fff mcu_ram
1000-1fff vram