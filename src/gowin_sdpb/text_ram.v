//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NZ-LV1QN48C6/I5
//Device: GW1NZ-1
//Created Time: Sat Apr 02 19:26:58 2022

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
defparam sdpb_inst_0.INIT_RAM_00 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_01 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_02 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_03 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_04 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_05 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_06 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_07 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_08 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_09 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_0A = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_0B = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_0C = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_0D = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_0E = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_0F = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_10 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_11 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_12 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_13 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_14 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_15 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_16 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_17 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_18 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_19 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_1A = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_1B = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_1C = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_1D = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_1E = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_1F = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_20 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_21 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_22 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_23 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_24 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_25 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_26 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_27 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_28 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_29 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_2A = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_2B = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_2C = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_2D = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_2E = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_2F = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_30 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_31 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_32 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_33 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_34 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_35 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_36 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_37 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_38 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_39 = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_3A = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_3B = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_3C = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_3D = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_3E = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;
defparam sdpb_inst_0.INIT_RAM_3F = 256'h202021646C726F57206F6C6C65482020202021646C726F57206F6C6C65482020;

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
defparam sdpb_inst_1.INIT_RAM_00 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_01 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_02 = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_03 = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_04 = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_05 = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_06 = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_07 = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;
defparam sdpb_inst_1.INIT_RAM_08 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_09 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_0A = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_0B = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_0C = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_0D = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_0E = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_0F = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;
defparam sdpb_inst_1.INIT_RAM_10 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_11 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_12 = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_13 = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_14 = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_15 = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_16 = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_17 = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;
defparam sdpb_inst_1.INIT_RAM_18 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_19 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_1A = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_1B = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_1C = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_1D = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_1E = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_1F = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;
defparam sdpb_inst_1.INIT_RAM_20 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_21 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_22 = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_23 = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_24 = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_25 = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_26 = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_27 = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;
defparam sdpb_inst_1.INIT_RAM_28 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_29 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_2A = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_2B = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_2C = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_2D = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_2E = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_2F = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;
defparam sdpb_inst_1.INIT_RAM_30 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_31 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_32 = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_33 = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_34 = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_35 = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_36 = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_37 = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;
defparam sdpb_inst_1.INIT_RAM_38 = 256'h1F1E1D1C1B1A191817161514131211100F0E0D0C0B0A09080706050403020100;
defparam sdpb_inst_1.INIT_RAM_39 = 256'h3F3E3D3C3B3A393837363534333231302F2E2D2C2B2A29282726252423222120;
defparam sdpb_inst_1.INIT_RAM_3A = 256'h5F5E5D5C5B5A595857565554535251504F4E4D4C4B4A49484746454443424140;
defparam sdpb_inst_1.INIT_RAM_3B = 256'h7F7E7D7C7B7A797877767574737271706F6E6D6C6B6A69686766656463626160;
defparam sdpb_inst_1.INIT_RAM_3C = 256'h9F9E9D9C9B9A999897969594939291908F8E8D8C8B8A89888786858483828180;
defparam sdpb_inst_1.INIT_RAM_3D = 256'hBFBEBDBCBBBAB9B8B7B6B5B4B3B2B1B0AFAEADACABAAA9A8A7A6A5A4A3A2A1A0;
defparam sdpb_inst_1.INIT_RAM_3E = 256'hDFDEDDDCDBDAD9D8D7D6D5D4D3D2D1D0CFCECDCCCBCAC9C8C7C6C5C4C3C2C1C0;
defparam sdpb_inst_1.INIT_RAM_3F = 256'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0EFEEEDECEBEAE9E8E7E6E5E4E3E2E1E0;

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
defparam sdpb_inst_2.INIT_RAM_00 = 256'h0F200E200D210C640B6C0A72096F08570720066F056C046C0365024801200020;
defparam sdpb_inst_2.INIT_RAM_01 = 256'h1F201E201D211C641B6C1A72196F18571720166F156C146C1365124811201020;
defparam sdpb_inst_2.INIT_RAM_02 = 256'h2F202E202D212C642B6C2A72296F28572720266F256C246C2365224821202020;
defparam sdpb_inst_2.INIT_RAM_03 = 256'h3F203E203D213C643B6C3A72396F38573720366F356C346C3365324831203020;
defparam sdpb_inst_2.INIT_RAM_04 = 256'h4F204E204D214C644B6C4A72496F48574720466F456C446C4365424841204020;
defparam sdpb_inst_2.INIT_RAM_05 = 256'h5F205E205D215C645B6C5A72596F58575720566F556C546C5365524851205020;
defparam sdpb_inst_2.INIT_RAM_06 = 256'h6F206E206D216C646B6C6A72696F68576720666F656C646C6365624861206020;
defparam sdpb_inst_2.INIT_RAM_07 = 256'h7F207E207D217C647B6C7A72796F78577720766F756C746C7365724871207020;
defparam sdpb_inst_2.INIT_RAM_08 = 256'h8F208E208D218C648B6C8A72896F88578720866F856C846C8365824881208020;
defparam sdpb_inst_2.INIT_RAM_09 = 256'h9F209E209D219C649B6C9A72996F98579720966F956C946C9365924891209020;
defparam sdpb_inst_2.INIT_RAM_0A = 256'hAF20AE20AD21AC64AB6CAA72A96FA857A720A66FA56CA46CA365A248A120A020;
defparam sdpb_inst_2.INIT_RAM_0B = 256'hBF20BE20BD21BC64BB6CBA72B96FB857B720B66FB56CB46CB365B248B120B020;
defparam sdpb_inst_2.INIT_RAM_0C = 256'hCF20CE20CD21CC64CB6CCA72C96FC857C720C66FC56CC46CC365C248C120C020;
defparam sdpb_inst_2.INIT_RAM_0D = 256'hDF20DE20DD21DC64DB6CDA72D96FD857D720D66FD56CD46CD365D248D120D020;
defparam sdpb_inst_2.INIT_RAM_0E = 256'hEF20EE20ED21EC64EB6CEA72E96FE857E720E66FE56CE46CE365E248E120E020;
defparam sdpb_inst_2.INIT_RAM_0F = 256'hFF20FE20FD21FC64FB6CFA72F96FF857F720F66FF56CF46CF365F248F120F020;
defparam sdpb_inst_2.INIT_RAM_10 = 256'h0F200E200D210C640B6C0A72096F08570720066F056C046C0365024801200020;
defparam sdpb_inst_2.INIT_RAM_11 = 256'h1F201E201D211C641B6C1A72196F18571720166F156C146C1365124811201020;
defparam sdpb_inst_2.INIT_RAM_12 = 256'h2F202E202D212C642B6C2A72296F28572720266F256C246C2365224821202020;
defparam sdpb_inst_2.INIT_RAM_13 = 256'h3F203E203D213C643B6C3A72396F38573720366F356C346C3365324831203020;
defparam sdpb_inst_2.INIT_RAM_14 = 256'h4F204E204D214C644B6C4A72496F48574720466F456C446C4365424841204020;
defparam sdpb_inst_2.INIT_RAM_15 = 256'h5F205E205D215C645B6C5A72596F58575720566F556C546C5365524851205020;
defparam sdpb_inst_2.INIT_RAM_16 = 256'h6F206E206D216C646B6C6A72696F68576720666F656C646C6365624861206020;
defparam sdpb_inst_2.INIT_RAM_17 = 256'h7F207E207D217C647B6C7A72796F78577720766F756C746C7365724871207020;
defparam sdpb_inst_2.INIT_RAM_18 = 256'h8F208E208D218C648B6C8A72896F88578720866F856C846C8365824881208020;
defparam sdpb_inst_2.INIT_RAM_19 = 256'h9F209E209D219C649B6C9A72996F98579720966F956C946C9365924891209020;
defparam sdpb_inst_2.INIT_RAM_1A = 256'hAF20AE20AD21AC64AB6CAA72A96FA857A720A66FA56CA46CA365A248A120A020;
defparam sdpb_inst_2.INIT_RAM_1B = 256'hBF20BE20BD21BC64BB6CBA72B96FB857B720B66FB56CB46CB365B248B120B020;
defparam sdpb_inst_2.INIT_RAM_1C = 256'hCF20CE20CD21CC64CB6CCA72C96FC857C720C66FC56CC46CC365C248C120C020;
defparam sdpb_inst_2.INIT_RAM_1D = 256'hDF20DE20DD21DC64DB6CDA72D96FD857D720D66FD56CD46CD365D248D120D020;
defparam sdpb_inst_2.INIT_RAM_1E = 256'hEF20EE20ED21EC64EB6CEA72E96FE857E720E66FE56CE46CE365E248E120E020;
defparam sdpb_inst_2.INIT_RAM_1F = 256'hFF20FE20FD21FC64FB6CFA72F96FF857F720F66FF56CF46CF365F248F120F020;
defparam sdpb_inst_2.INIT_RAM_20 = 256'h0F200E200D210C640B6C0A72096F08570720066F056C046C0365024801200020;
defparam sdpb_inst_2.INIT_RAM_21 = 256'h1F201E201D211C641B6C1A72196F18571720166F156C146C1365124811201020;
defparam sdpb_inst_2.INIT_RAM_22 = 256'h2F202E202D212C642B6C2A72296F28572720266F256C246C2365224821202020;
defparam sdpb_inst_2.INIT_RAM_23 = 256'h3F203E203D213C643B6C3A72396F38573720366F356C346C3365324831203020;
defparam sdpb_inst_2.INIT_RAM_24 = 256'h4F204E204D214C644B6C4A72496F48574720466F456C446C4365424841204020;
defparam sdpb_inst_2.INIT_RAM_25 = 256'h5F205E205D215C645B6C5A72596F58575720566F556C546C5365524851205020;
defparam sdpb_inst_2.INIT_RAM_26 = 256'h6F206E206D216C646B6C6A72696F68576720666F656C646C6365624861206020;
defparam sdpb_inst_2.INIT_RAM_27 = 256'h7F207E207D217C647B6C7A72796F78577720766F756C746C7365724871207020;
defparam sdpb_inst_2.INIT_RAM_28 = 256'h8F208E208D218C648B6C8A72896F88578720866F856C846C8365824881208020;
defparam sdpb_inst_2.INIT_RAM_29 = 256'h9F209E209D219C649B6C9A72996F98579720966F956C946C9365924891209020;
defparam sdpb_inst_2.INIT_RAM_2A = 256'hAF20AE20AD21AC64AB6CAA72A96FA857A720A66FA56CA46CA365A248A120A020;
defparam sdpb_inst_2.INIT_RAM_2B = 256'hBF20BE20BD21BC64BB6CBA72B96FB857B720B66FB56CB46CB365B248B120B020;
defparam sdpb_inst_2.INIT_RAM_2C = 256'hCF20CE20CD21CC64CB6CCA72C96FC857C720C66FC56CC46CC365C248C120C020;
defparam sdpb_inst_2.INIT_RAM_2D = 256'hDF20DE20DD21DC64DB6CDA72D96FD857D720D66FD56CD46CD365D248D120D020;
defparam sdpb_inst_2.INIT_RAM_2E = 256'hEF20EE20ED21EC64EB6CEA72E96FE857E720E66FE56CE46CE365E248E120E020;
defparam sdpb_inst_2.INIT_RAM_2F = 256'hFF20FE20FD21FC64FB6CFA72F96FF857F720F66FF56CF46CF365F248F120F020;
defparam sdpb_inst_2.INIT_RAM_30 = 256'h0F200E200D210C640B6C0A72096F08570720066F056C046C0365024801200020;
defparam sdpb_inst_2.INIT_RAM_31 = 256'h1F201E201D211C641B6C1A72196F18571720166F156C146C1365124811201020;
defparam sdpb_inst_2.INIT_RAM_32 = 256'h2F202E202D212C642B6C2A72296F28572720266F256C246C2365224821202020;
defparam sdpb_inst_2.INIT_RAM_33 = 256'h3F203E203D213C643B6C3A72396F38573720366F356C346C3365324831203020;
defparam sdpb_inst_2.INIT_RAM_34 = 256'h4F204E204D214C644B6C4A72496F48574720466F456C446C4365424841204020;
defparam sdpb_inst_2.INIT_RAM_35 = 256'h5F205E205D215C645B6C5A72596F58575720566F556C546C5365524851205020;
defparam sdpb_inst_2.INIT_RAM_36 = 256'h6F206E206D216C646B6C6A72696F68576720666F656C646C6365624861206020;
defparam sdpb_inst_2.INIT_RAM_37 = 256'h7F207E207D217C647B6C7A72796F78577720766F756C746C7365724871207020;
defparam sdpb_inst_2.INIT_RAM_38 = 256'h8F208E208D218C648B6C8A72896F88578720866F856C846C8365824881208020;
defparam sdpb_inst_2.INIT_RAM_39 = 256'h9F209E209D219C649B6C9A72996F98579720966F956C946C9365924891209020;
defparam sdpb_inst_2.INIT_RAM_3A = 256'hAF20AE20AD21AC64AB6CAA72A96FA857A720A66FA56CA46CA365A248A120A020;
defparam sdpb_inst_2.INIT_RAM_3B = 256'hBF20BE20BD21BC64BB6CBA72B96FB857B720B66FB56CB46CB365B248B120B020;
defparam sdpb_inst_2.INIT_RAM_3C = 256'hCF20CE20CD21CC64CB6CCA72C96FC857C720C66FC56CC46CC365C248C120C020;
defparam sdpb_inst_2.INIT_RAM_3D = 256'hDF20DE20DD21DC64DB6CDA72D96FD857D720D66FD56CD46CD365D248D120D020;
defparam sdpb_inst_2.INIT_RAM_3E = 256'hEF20EE20ED21EC64EB6CEA72E96FE857E720E66FE56CE46CE365E248E120E020;
defparam sdpb_inst_2.INIT_RAM_3F = 256'hFF20FE20FD21FC64FB6CFA72F96FF857F720F66FF56CF46CF365F248F120F020;

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
