from PIL import Image


def rgb888_to_rgb565(r, g, b):
    r = (r & 0xF8) << 8
    g = (g & 0xFC) << 3
    b = (b & 0xF8) >> 3
    return r | g | b


img = Image.open('../64x64.bmp')
pixels = img.getdata()
pixels = [rgb888_to_rgb565(*p) for p in pixels]
print("#File_format=Hex")
print("#Address_depth={}".format(len(pixels)))
print("#Data_width={}".format(16))
for x in pixels:
    print("{:04X}".format(x))
