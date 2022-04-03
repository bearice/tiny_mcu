add_file -type verilog "src/gowin_prom/font.v"
add_file -type verilog "src/gowin_prom/pixels.v"
add_file -type verilog "src/gowin_prom/pixels_argb.v"
add_file -type verilog "src/gowin_rom16/color_palette.v"
add_file -type verilog "src/gowin_rom16/gowin_rom16.v"
add_file -type verilog "src/gowin_rpll/gowin_rpll.v"
add_file -type verilog "src/gowin_sdpb/text_ram.v"
add_file -type verilog "src/lib/hsv2rgb.v"
add_file -type verilog "src/lib/lcd_vga.v"
add_file -type verilog "src/lib/led.v"
add_file -type verilog "src/lib/pwm.v"
add_file -type verilog "src/lib/uart.v"
add_file -type verilog "src/top.v"
add_file -type cst "src/tang_nano_1k.cst"
set_device GW1NZ-LV1QN48C6/I5 -name GW1NZ-1
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name tiny_mcu
set_option -top_module top
set_option -verilog_std sysv2017
set_option -vhdl_std vhd2008
set_option -use_sspi_as_gpio 1
set_option -use_mspi_as_gpio 1
run all