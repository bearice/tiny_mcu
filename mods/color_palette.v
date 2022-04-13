//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Tue Apr 12 15:23:23 2022

module ColorPalette (dout, ad);

output [15:0] dout;
input [3:0] ad;

ROM16 rom16_inst_0 (
    .DO(dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_0.INIT_0 = 16'hAAAA;

ROM16 rom16_inst_1 (
    .DO(dout[1]),
    .AD(ad[3:0])
);

defparam rom16_inst_1.INIT_0 = 16'hFF00;

ROM16 rom16_inst_2 (
    .DO(dout[2]),
    .AD(ad[3:0])
);

defparam rom16_inst_2.INIT_0 = 16'hAAAA;

ROM16 rom16_inst_3 (
    .DO(dout[3]),
    .AD(ad[3:0])
);

defparam rom16_inst_3.INIT_0 = 16'hFF00;

ROM16 rom16_inst_4 (
    .DO(dout[4]),
    .AD(ad[3:0])
);

defparam rom16_inst_4.INIT_0 = 16'hAAAA;

ROM16 rom16_inst_5 (
    .DO(dout[5]),
    .AD(ad[3:0])
);

defparam rom16_inst_5.INIT_0 = 16'hFF40;

ROM16 rom16_inst_6 (
    .DO(dout[6]),
    .AD(ad[3:0])
);

defparam rom16_inst_6.INIT_0 = 16'hCC8C;

ROM16 rom16_inst_7 (
    .DO(dout[7]),
    .AD(ad[3:0])
);

defparam rom16_inst_7.INIT_0 = 16'hFF40;

ROM16 rom16_inst_8 (
    .DO(dout[8]),
    .AD(ad[3:0])
);

defparam rom16_inst_8.INIT_0 = 16'hCC8C;

ROM16 rom16_inst_9 (
    .DO(dout[9]),
    .AD(ad[3:0])
);

defparam rom16_inst_9.INIT_0 = 16'hFF40;

ROM16 rom16_inst_10 (
    .DO(dout[10]),
    .AD(ad[3:0])
);

defparam rom16_inst_10.INIT_0 = 16'hCC8C;

ROM16 rom16_inst_11 (
    .DO(dout[11]),
    .AD(ad[3:0])
);

defparam rom16_inst_11.INIT_0 = 16'hF0F0;

ROM16 rom16_inst_12 (
    .DO(dout[12]),
    .AD(ad[3:0])
);

defparam rom16_inst_12.INIT_0 = 16'hFF00;

ROM16 rom16_inst_13 (
    .DO(dout[13]),
    .AD(ad[3:0])
);

defparam rom16_inst_13.INIT_0 = 16'hF0F0;

ROM16 rom16_inst_14 (
    .DO(dout[14]),
    .AD(ad[3:0])
);

defparam rom16_inst_14.INIT_0 = 16'hFF00;

ROM16 rom16_inst_15 (
    .DO(dout[15]),
    .AD(ad[3:0])
);

defparam rom16_inst_15.INIT_0 = 16'hF0F0;

endmodule //ColorPalette
