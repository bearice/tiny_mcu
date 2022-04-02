l = 3072
s = "  Hello World!  "
print("#File_format=Hex")
print("#Address_depth={}".format(l))
print("#Data_width={}".format(16))
for i in range(l):
    ch = ord(s[i % len(s)])
    color = i % 256
    print("{:02X}{:02X}".format(color, ch))
