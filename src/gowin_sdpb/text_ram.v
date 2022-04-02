//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NZ-LV1QN48C6/I5
//Device: GW1NZ-1
//Created Time: Sat Apr 02 18:40:06 2022

module TextRam (dout, clka, cea, reseta, clkb, ceb, resetb, oce, ada, din, adb);

output [15:0] dout;
input clka;
input cea;
input reseta;
input clkb;
input ceb;
input resetb;
input oce;
input [11:0] ada;
input [15:0] din;
input [11:0] adb;

wire [23:0] sdpb_inst_0_dout_w;
wire [7:0] sdpb_inst_0_dout;
wire [23:0] sdpb_inst_1_dout_w;
wire [15:8] sdpb_inst_1_dout;
wire [15:0] sdpb_inst_2_dout_w;
wire [15:0] sdpb_inst_2_dout;
wire dff_q_0;
wire gw_vcc;
wire gw_gnd;

assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

SDPB sdpb_inst_0 (
    .DO({sdpb_inst_0_dout_w[23:0],sdpb_inst_0_dout[7:0]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[11]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[11]}),
    .ADA({ada[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[7:0]}),
    .ADB({adb[10:0],gw_gnd,gw_gnd,gw_gnd})
);

defparam sdpb_inst_0.READ_MODE = 1'b0;
defparam sdpb_inst_0.BIT_WIDTH_0 = 8;
defparam sdpb_inst_0.BIT_WIDTH_1 = 8;
defparam sdpb_inst_0.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_0.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_0.RESET_MODE = "SYNC";
defparam sdpb_inst_0.INIT_RAM_00 = 256'h000000000000000000000000000000000002264021646C726F77204F4C4C4548;

SDPB sdpb_inst_1 (
    .DO({sdpb_inst_1_dout_w[23:0],sdpb_inst_1_dout[15:8]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[11]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[11]}),
    .ADA({ada[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[15:8]}),
    .ADB({adb[10:0],gw_gnd,gw_gnd,gw_gnd})
);

defparam sdpb_inst_1.READ_MODE = 1'b0;
defparam sdpb_inst_1.BIT_WIDTH_0 = 8;
defparam sdpb_inst_1.BIT_WIDTH_1 = 8;
defparam sdpb_inst_1.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_1.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_1.RESET_MODE = "SYNC";
defparam sdpb_inst_1.INIT_RAM_00 = 256'h00000000000000000000000000000000000F0E0D0C0B0A090807060504030201;

SDPB sdpb_inst_2 (
    .DO({sdpb_inst_2_dout_w[15:0],sdpb_inst_2_dout[15:0]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,ada[11],ada[10]}),
    .BLKSELB({gw_gnd,adb[11],adb[10]}),
    .ADA({ada[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[15:0]}),
    .ADB({adb[9:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam sdpb_inst_2.READ_MODE = 1'b0;
defparam sdpb_inst_2.BIT_WIDTH_0 = 16;
defparam sdpb_inst_2.BIT_WIDTH_1 = 16;
defparam sdpb_inst_2.BLK_SEL_0 = 3'b010;
defparam sdpb_inst_2.BLK_SEL_1 = 3'b010;
defparam sdpb_inst_2.RESET_MODE = "SYNC";

DFFE dff_inst_0 (
  .Q(dff_q_0),
  .D(adb[11]),
  .CLK(clkb),
  .CE(ceb)
);
MUX2 mux_inst_2 (
  .O(dout[0]),
  .I0(sdpb_inst_0_dout[0]),
  .I1(sdpb_inst_2_dout[0]),
  .S0(dff_q_0)
);
MUX2 mux_inst_5 (
  .O(dout[1]),
  .I0(sdpb_inst_0_dout[1]),
  .I1(sdpb_inst_2_dout[1]),
  .S0(dff_q_0)
);
MUX2 mux_inst_8 (
  .O(dout[2]),
  .I0(sdpb_inst_0_dout[2]),
  .I1(sdpb_inst_2_dout[2]),
  .S0(dff_q_0)
);
MUX2 mux_inst_11 (
  .O(dout[3]),
  .I0(sdpb_inst_0_dout[3]),
  .I1(sdpb_inst_2_dout[3]),
  .S0(dff_q_0)
);
MUX2 mux_inst_14 (
  .O(dout[4]),
  .I0(sdpb_inst_0_dout[4]),
  .I1(sdpb_inst_2_dout[4]),
  .S0(dff_q_0)
);
MUX2 mux_inst_17 (
  .O(dout[5]),
  .I0(sdpb_inst_0_dout[5]),
  .I1(sdpb_inst_2_dout[5]),
  .S0(dff_q_0)
);
MUX2 mux_inst_20 (
  .O(dout[6]),
  .I0(sdpb_inst_0_dout[6]),
  .I1(sdpb_inst_2_dout[6]),
  .S0(dff_q_0)
);
MUX2 mux_inst_23 (
  .O(dout[7]),
  .I0(sdpb_inst_0_dout[7]),
  .I1(sdpb_inst_2_dout[7]),
  .S0(dff_q_0)
);
MUX2 mux_inst_26 (
  .O(dout[8]),
  .I0(sdpb_inst_1_dout[8]),
  .I1(sdpb_inst_2_dout[8]),
  .S0(dff_q_0)
);
MUX2 mux_inst_29 (
  .O(dout[9]),
  .I0(sdpb_inst_1_dout[9]),
  .I1(sdpb_inst_2_dout[9]),
  .S0(dff_q_0)
);
MUX2 mux_inst_32 (
  .O(dout[10]),
  .I0(sdpb_inst_1_dout[10]),
  .I1(sdpb_inst_2_dout[10]),
  .S0(dff_q_0)
);
MUX2 mux_inst_35 (
  .O(dout[11]),
  .I0(sdpb_inst_1_dout[11]),
  .I1(sdpb_inst_2_dout[11]),
  .S0(dff_q_0)
);
MUX2 mux_inst_38 (
  .O(dout[12]),
  .I0(sdpb_inst_1_dout[12]),
  .I1(sdpb_inst_2_dout[12]),
  .S0(dff_q_0)
);
MUX2 mux_inst_41 (
  .O(dout[13]),
  .I0(sdpb_inst_1_dout[13]),
  .I1(sdpb_inst_2_dout[13]),
  .S0(dff_q_0)
);
MUX2 mux_inst_44 (
  .O(dout[14]),
  .I0(sdpb_inst_1_dout[14]),
  .I1(sdpb_inst_2_dout[14]),
  .S0(dff_q_0)
);
MUX2 mux_inst_47 (
  .O(dout[15]),
  .I0(sdpb_inst_1_dout[15]),
  .I1(sdpb_inst_2_dout[15]),
  .S0(dff_q_0)
);
endmodule //TextRam
