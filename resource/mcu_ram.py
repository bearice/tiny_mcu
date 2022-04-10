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
        y = x & 0x0f
        x = x >> 4
        z = reg_or_imm(y)
    elif op == 'JMP':
        x = x & 0x0f
        y = y & 0x0f
        z = reg_or_imm(z)
    else:
        x = reg_or_imm(x)
        y = reg_or_imm(y)
        z = reg_or_imm(z)
    return opcodefs[op] | (x << 4) | (y << 8) | (z << 12)


code = [
    codegen('JMP', 0, 0, 4),
    codegen('LOAD', 1, 'A'),
    codegen('LOAD', 0, 'B'),
    codegen('ADD', 'A', 1, 'B'),
    codegen('JMP', 0, 0, 2),
]

print("#File_format=Hex")
print("#Address_depth={}".format(2048))
print("#Data_width={}".format(16))
for c in code:
    print("{:04X}".format(c))
