add_file -type verilog "mods/font.v"
add_file -type verilog "mods/color_palette.v"
add_file -type verilog "mods/rpll.v"
add_file -type verilog "mods/vram.v"
add_file -type verilog "mods/mcu_ram.v"
add_file -type verilog "src/alu.v"
add_file -type verilog "src/mcu.v"
add_file -type verilog "src/7seg_led.v"
add_file -type verilog "src/hsv2rgb.v"
add_file -type verilog "src/lcd_vga.v"
add_file -type verilog "src/led.v"
add_file -type verilog "src/pwm.v"
add_file -type verilog "src/uart.v"
add_file -type verilog "src/debouncer.v"
add_file -type verilog "src/top.v"
add_file -type cst "src/tang_nano_9k.cst"
add_file -type sdc "src/tiny_mcu.sdc"
set_device GW1NR-LV9QN88C6/I5 -name GW1NR-9C
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name tiny_mcu
set_option -top_module top
set_option -verilog_std sysv2017
set_option -vhdl_std vhd2008
set_option -use_sspi_as_gpio 1
set_option -use_mspi_as_gpio 1
set_option -use_done_as_gpio 1
run all