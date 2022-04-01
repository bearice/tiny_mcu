import colorsys


def hsv2rgb(h, s, v):
    (h, s, v) = (h/255.0, s/100.0, v/100.0)
    return tuple(round(i * 255) for i in colorsys.hsv_to_rgb(h, s, v))


def rgb888_to_rgb565(r, g, b):
    r = (r & 0xF8) << 8
    g = (g & 0xFC) << 3
    b = (b & 0xF8) >> 3
    return r | g | b


print("#File_format=Hex")
print("#Address_depth={}".format(256))
print("#Data_width={}".format(16))

for x in range(256):
    (r, g, b) = hsv2rgb(x, 100, 100)
    print("{:04X}".format(rgb888_to_rgb565(r, g, b)))
