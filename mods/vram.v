//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Tue Apr 12 15:25:52 2022

module VRam (douta, doutb, clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb, ada, dina, adb, dinb);

output [15:0] douta;
output [15:0] doutb;
input clka;
input ocea;
input cea;
input reseta;
input wrea;
input clkb;
input oceb;
input ceb;
input resetb;
input wreb;
input [11:0] ada;
input [15:0] dina;
input [11:0] adb;
input [15:0] dinb;

wire [11:0] dpb_inst_0_douta_w;
wire [11:0] dpb_inst_0_doutb_w;
wire [11:0] dpb_inst_1_douta_w;
wire [11:0] dpb_inst_1_doutb_w;
wire [11:0] dpb_inst_2_douta_w;
wire [11:0] dpb_inst_2_doutb_w;
wire [11:0] dpb_inst_3_douta_w;
wire [11:0] dpb_inst_3_doutb_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

DPB dpb_inst_0 (
    .DOA({dpb_inst_0_douta_w[11:0],douta[3:0]}),
    .DOB({dpb_inst_0_doutb_w[11:0],doutb[3:0]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({ada[11:0],gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[3:0]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[3:0]})
);

defparam dpb_inst_0.READ_MODE0 = 1'b0;
defparam dpb_inst_0.READ_MODE1 = 1'b0;
defparam dpb_inst_0.WRITE_MODE0 = 2'b00;
defparam dpb_inst_0.WRITE_MODE1 = 2'b00;
defparam dpb_inst_0.BIT_WIDTH_0 = 4;
defparam dpb_inst_0.BIT_WIDTH_1 = 4;
defparam dpb_inst_0.BLK_SEL_0 = 3'b000;
defparam dpb_inst_0.BLK_SEL_1 = 3'b000;
defparam dpb_inst_0.RESET_MODE = "SYNC";
defparam dpb_inst_0.INIT_RAM_00 = 256'hCC5814C2F70FCC5814C2F70FCC5814C2F70FCC5814C2F70FCC5814C2F70FCC58;
defparam dpb_inst_0.INIT_RAM_01 = 256'h0000000000000000000000000000CC5814C2F70FCC5814C2F70FCC5814C2F70F;

DPB dpb_inst_1 (
    .DOA({dpb_inst_1_douta_w[11:0],douta[7:4]}),
    .DOB({dpb_inst_1_doutb_w[11:0],doutb[7:4]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({ada[11:0],gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[7:4]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[7:4]})
);

defparam dpb_inst_1.READ_MODE0 = 1'b0;
defparam dpb_inst_1.READ_MODE1 = 1'b0;
defparam dpb_inst_1.WRITE_MODE0 = 2'b00;
defparam dpb_inst_1.WRITE_MODE1 = 2'b00;
defparam dpb_inst_1.BIT_WIDTH_0 = 4;
defparam dpb_inst_1.BIT_WIDTH_1 = 4;
defparam dpb_inst_1.BLK_SEL_0 = 3'b000;
defparam dpb_inst_1.BLK_SEL_1 = 3'b000;
defparam dpb_inst_1.RESET_MODE = "SYNC";
defparam dpb_inst_1.INIT_RAM_00 = 256'h6664266765266664266765266664266765266664266765266664266765266664;
defparam dpb_inst_1.INIT_RAM_01 = 256'h0000000000000000000000000000666426676526666426676526666426676526;

DPB dpb_inst_2 (
    .DOA({dpb_inst_2_douta_w[11:0],douta[11:8]}),
    .DOB({dpb_inst_2_doutb_w[11:0],doutb[11:8]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({ada[11:0],gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[11:8]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[11:8]})
);

defparam dpb_inst_2.READ_MODE0 = 1'b0;
defparam dpb_inst_2.READ_MODE1 = 1'b0;
defparam dpb_inst_2.WRITE_MODE0 = 2'b00;
defparam dpb_inst_2.WRITE_MODE1 = 2'b00;
defparam dpb_inst_2.BIT_WIDTH_0 = 4;
defparam dpb_inst_2.BIT_WIDTH_1 = 4;
defparam dpb_inst_2.BLK_SEL_0 = 3'b000;
defparam dpb_inst_2.BLK_SEL_1 = 3'b000;
defparam dpb_inst_2.RESET_MODE = "SYNC";
defparam dpb_inst_2.INIT_RAM_00 = 256'h210FEDCBA987654210FEDCBA987654320FEDCBA987654321FEDCBA9876543210;
defparam dpb_inst_2.INIT_RAM_01 = 256'h0000000000000000000000000000986543210FEDCBA987643210FEDCBA987653;

DPB dpb_inst_3 (
    .DOA({dpb_inst_3_douta_w[11:0],douta[15:12]}),
    .DOB({dpb_inst_3_doutb_w[11:0],doutb[15:12]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({ada[11:0],gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[15:12]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[15:12]})
);

defparam dpb_inst_3.READ_MODE0 = 1'b0;
defparam dpb_inst_3.READ_MODE1 = 1'b0;
defparam dpb_inst_3.WRITE_MODE0 = 2'b00;
defparam dpb_inst_3.WRITE_MODE1 = 2'b00;
defparam dpb_inst_3.BIT_WIDTH_0 = 4;
defparam dpb_inst_3.BIT_WIDTH_1 = 4;
defparam dpb_inst_3.BLK_SEL_0 = 3'b000;
defparam dpb_inst_3.BLK_SEL_1 = 3'b000;
defparam dpb_inst_3.RESET_MODE = "SYNC";
defparam dpb_inst_3.INIT_RAM_00 = 256'h4444333333333333222222222222111111111111000000000000FFFFFFFFFFFF;
defparam dpb_inst_3.INIT_RAM_01 = 256'h0000000000000000000000000000777766666666666655555555555544444444;

endmodule //VRam
