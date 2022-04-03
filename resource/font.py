from PIL import Image, ImageDraw, ImageFont

width = 8
height = 16
image = Image.new('1', (width, height*128))
draw = ImageDraw.Draw(image)
font = ImageFont.truetype("resource/Px437_DOS-V_TWN16.ttf", size=16)

for i in range(128):
    draw.text((0, i*height), chr(i), fill=1, font=font)

# image.save('resource/font.bmp', 'bmp')
pixels = list(image.getdata())

print("#File_format=Bin")
print("#Address_depth={}".format(height*128*8))
print("#Data_width={}".format(1))
for p in pixels:
    print("{}".format(p))
