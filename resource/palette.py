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
    0xffffff,
    0xfbf305,
    0xff6403,
    0xdd0907,
    0xf20884,
    0x4700a5,
    0x0000d3,
    0x02abea,
    0x1fb714,
    0x006412,
    0x562c05,
    0x90713a,
    0xc0c0c0,
    0x808080,
    0x404040,
    0x000000,
]

print("#File_format=Hex")
print("#Address_depth={}".format(16))
print("#Data_width={}".format(16))
for c in colors:
    print("{:04X}".format(rgb888_to_rgb565(c)))
