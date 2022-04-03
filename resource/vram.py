l = 750
s = "Hello World!"
print("#File_format=Hex")
print("#Address_depth={}".format(l))
print("#Data_width={}".format(16))
fg = 0
bg = 15
i = 0
while i < l:
    ch = ord(s[i % len(s)])
    if bg == fg:
        fg = (fg + 1) % 16
    print("{:01X}{:01X}{:02X}".format(bg, fg, ch))
    i += 1
    fg = (fg + 1) % 16
    if i % len(s) == 0:
        bg = (bg + 1) % 16
