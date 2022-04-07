//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NZ-LV1QN48C6/I5
//Device: GW1NZ-1
//Created Time: Wed Apr 13 18:20:43 2022

module MCU_RAM (dout, clk, oce, ce, reset, wre, ad, din);

output [15:0] dout;
input clk;
input oce;
input ce;
input reset;
input wre;
input [11:0] ad;
input [15:0] din;

wire [27:0] sp_inst_0_dout_w;
wire [27:0] sp_inst_1_dout_w;
wire [27:0] sp_inst_2_dout_w;
wire [27:0] sp_inst_3_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

SP sp_inst_0 (
    .DO({sp_inst_0_dout_w[27:0],dout[3:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[11:0],gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[3:0]})
);

defparam sp_inst_0.READ_MODE = 1'b0;
defparam sp_inst_0.WRITE_MODE = 2'b00;
defparam sp_inst_0.BIT_WIDTH = 4;
defparam sp_inst_0.BLK_SEL = 3'b000;
defparam sp_inst_0.RESET_MODE = "SYNC";
defparam sp_inst_0.INIT_RAM_00 = 256'h0000000000000000000000000000000000000000000088199819900A00999900;
defparam sp_inst_0.INIT_RAM_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_0.INIT_RAM_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_0.INIT_RAM_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_0.INIT_RAM_04 = 256'h0000000000000000000000000000000000000000000153D0DF2604C2F70FCC58;

SP sp_inst_1 (
    .DO({sp_inst_1_dout_w[27:0],dout[7:4]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[11:0],gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[7:4]})
);

defparam sp_inst_1.READ_MODE = 1'b0;
defparam sp_inst_1.WRITE_MODE = 2'b00;
defparam sp_inst_1.BIT_WIDTH = 4;
defparam sp_inst_1.BLK_SEL = 3'b000;
defparam sp_inst_1.RESET_MODE = "SYNC";
defparam sp_inst_1.INIT_RAM_00 = 256'h000000000000000000000000000000000000000000000400B400132310100088;
defparam sp_inst_1.INIT_RAM_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_1.INIT_RAM_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_1.INIT_RAM_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_1.INIT_RAM_04 = 256'h0000000000000000000000000000000000000000002254426676266765266664;

SP sp_inst_2 (
    .DO({sp_inst_2_dout_w[27:0],dout[11:8]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[11:0],gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[11:8]})
);

defparam sp_inst_2.READ_MODE = 1'b0;
defparam sp_inst_2.WRITE_MODE = 2'b00;
defparam sp_inst_2.BIT_WIDTH = 4;
defparam sp_inst_2.BLK_SEL = 3'b000;
defparam sp_inst_2.RESET_MODE = "SYNC";
defparam sp_inst_2.INIT_RAM_00 = 256'h00000000000000000000000000000000000000000000043B8420699032001088;
defparam sp_inst_2.INIT_RAM_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_2.INIT_RAM_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_2.INIT_RAM_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_2.INIT_RAM_04 = 256'h000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF;

SP sp_inst_3 (
    .DO({sp_inst_3_dout_w[27:0],dout[15:12]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[11:0],gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[15:12]})
);

defparam sp_inst_3.READ_MODE = 1'b0;
defparam sp_inst_3.WRITE_MODE = 2'b00;
defparam sp_inst_3.BIT_WIDTH = 4;
defparam sp_inst_3.BLK_SEL = 3'b000;
defparam sp_inst_3.RESET_MODE = "SYNC";
defparam sp_inst_3.INIT_RAM_00 = 256'h00000000000000000000000000000000000000000000A8080908032110918023;
defparam sp_inst_3.INIT_RAM_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_3.INIT_RAM_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_3.INIT_RAM_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam sp_inst_3.INIT_RAM_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

endmodule //MCU_RAM
