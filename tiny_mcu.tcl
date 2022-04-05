add_file -type verilog "mods/font.v"
add_file -type verilog "mods/color_palette.v"
add_file -type verilog "mods/rpll.v"
add_file -type verilog "mods/vram.v"
add_file -type verilog "src/hsv2rgb.v"
add_file -type verilog "src/lcd_vga.v"
add_file -type verilog "src/led.v"
add_file -type verilog "src/pwm.v"
add_file -type verilog "src/uart.v"
add_file -type verilog "src/debouncer.v"
add_file -type verilog "src/top.v"
add_file -type cst "src/tang_nano_1k.cst"
add_file -type sdc "src/tang_nano_1k.sdc"
set_device GW1NZ-LV1QN48C6/I5 -name GW1NZ-1
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name tiny_mcu
set_option -top_module top
set_option -verilog_std sysv2017
set_option -vhdl_std vhd2008
set_option -use_sspi_as_gpio 1
set_option -use_mspi_as_gpio 1
run all