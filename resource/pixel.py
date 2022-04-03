from PIL import Image


def rgb888_to_rgb565(r, g, b):
    r = (r & 0xF8) << 8
    g = (g & 0xFC) << 3
    b = (b & 0xF8) >> 3
    return r | g | b


def rgba8888_to_argb1555(r, g, b, a):
    a = (a > 0 and 1 or 0) << 15
    r = (r & 0xF8) << 7
    g = (g & 0xF8) << 2
    b = (b & 0xF8) >> 3
    return a | r | g | b


img = Image.open('../64x64.png')
pixels = img.getdata()
# print(pixels[100])
pixels = [rgba8888_to_argb1555(*p) for p in pixels]
print("#File_format=Hex")
print("#Address_depth={}".format(len(pixels)))
print("#Data_width={}".format(16))
for x in pixels:
    print("{:04X}".format(x))
