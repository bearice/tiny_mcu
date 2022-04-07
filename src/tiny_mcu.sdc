//Copyright (C)2014-2022 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.05 
//Created Time: 2022-04-04 22:14:42
create_clock -name XTAL -period 37.037 -waveform {0 18.518} [get_ports {clk_27m}] -add
create_clock -name PIX_CLK -period 27.778 -waveform {0 13.889} [get_nets {clk_36m}] -add
create_generated_clock -name PIX_CLK_d -source [get_nets {clk_36m}] -master_clock PIX_CLK -invert [get_nets {LCD_CLK_d_4}]
