import itertools
from sre_parse import FLAGS

opcodefs = {
    'ADD': 0, 'SUB': 1, 'MUL': 2, 'SHL': 3,
    'AND': 4, 'OR': 5, 'XOR': 6, 'SHR': 7,
    'JMP': 8, 'LOAD': 9, 'MOVE': 10
}

regdefs = {
    'A': 0, 'B': 1, 'C': 2, 'D': 3,
    'PC': 4, 'SP': 5, 'CTL': 6, 'FLG': 7,
    'AH': 8, 'BH': 9, 'CH': 10, 'DH': 11,
}

FLG_O = 1 << 0
FLG_S = 1 << 1
FLG_Z = 1 << 2
FLG_C = 1 << 3

MV_R2R = 0
MV_M2R = 1
MV_R2M = 2
MV_M2M = 3


def reg_or_imm(reg):
    if reg in regdefs:
        return regdefs[reg]
    else:
        if reg < 8:
            return 8 | (reg & 7)
        else:
            raise Exception('Imm too big: {}, use LOAD instead.'.format(reg))


def codegen(op, x, y, z=None):
    if op == 'LOAD':
        z = reg_or_imm(y)
        y = x & 0x0f
        x = x >> 4
    elif op == 'JMP':
        x = x & 0x0f
        y = y & 0x0f
        z = reg_or_imm(z)
    elif op == 'MOVE':
        x = x & 0x0f
        y = reg_or_imm(y)
        z = reg_or_imm(z)
    else:
        x = reg_or_imm(x)
        y = reg_or_imm(y)
        z = reg_or_imm(z)
    return [opcodefs[op] | (x << 4) | (y << 8) | (z << 12)]


def data_string(s):
    return list(map(lambda x: 0x0f00+ord(x), s))


code = [
    codegen('ADD', 0, 0, 'D'),          # 00 D=0
    codegen('ADD', 0, 0, 'C'),          # 01 C=0
    codegen('LOAD', 0, 'A'),            # 02
    codegen('LOAD', 0x01, 'AH'),        # 03 A=0x100
    codegen('LOAD', 0x00, 'B'),         # 04
    codegen('LOAD', 0x10, 'BH'),        # 05 B=0x1000
    codegen('ADD', 'A', 'C', 'A'),      # 06 A=A+C
    codegen('ADD', 'B', 'D', 'B'),      # 07 B=B+D
    codegen('MOVE', MV_M2M, 'A', 'B'),  # 08 write mem[A] to mem[D]
    codegen('ADD', 'C', 1, 'C'),        # 09 C++
    codegen('ADD', 'D', 1, 'D'),        # 0a D++
    codegen('LOAD', 0x16, 'A'),         # 0b
    codegen('LOAD', 0, 'AH'),           # 0c A=0x15
    codegen('SUB', 'A', 'C', 'A'),      # 0d A=A-C
    codegen('JMP', FLG_Z, FLG_Z, 1),    # 0e JMP 1 if A==0 (FLG_Z is set)
    codegen('LOAD', 0xb8, 'A'),         # 0b
    codegen('LOAD', 0x0b, 'AH'),        # 0c A=3000
    codegen('SUB', 'A', 'D', 'A'),      # 0d A=A-D
    codegen('JMP', FLG_Z, FLG_Z, 0),    # 0e JMP 1 if A==0 (FLG_Z is set)
    codegen('JMP', 0, 0, 2),            # 0f JMP 2
]
code = list(itertools.chain(*code))
data = [
    data_string("Hello World from MCU! "),
]
data = list(itertools.chain(*data))
print("#File_format=AddrHex")
print("#Address_depth={}".format(4096))
print("#Data_width={}".format(16))
addr = 0
for c in code:
    print("{:X}:{:04X}".format(addr, c))
    addr += 1

addr = 0x100
for c in data:
    print("{:X}:{:04X}".format(addr, c))
    addr += 1
