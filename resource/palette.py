import colorsys


def rgb888_to_rgb565(color):
    r = color >> 16
    g = (color >> 8) & 0xFF
    b = color & 0xFF
    r = (r & 0xF8) << 8
    g = (g & 0xFC) << 3
    b = (b & 0xF8) >> 3
    return r | g | b


colors = [
    0x000000, 0x0000aa, 0x00aa00, 0x00aaaa, 0xaa0000, 0xaa00aa, 0xaa5500, 0xaaaaaa,
    0x555555, 0x5555ff, 0x55ff55, 0x55ffff, 0xff5555, 0xff55ff, 0xffff55, 0xffffff,
]

print("#File_format=Hex")
print("#Address_depth={}".format(16))
print("#Data_width={}".format(16))
for c in colors:
    print("{:04X}".format(rgb888_to_rgb565(c)))
