//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NZ-LV1QN48C6/I5
//Device: GW1NZ-1
//Created Time: Sat Apr 02 22:43:16 2022

module TextRam (dout, clka, cea, reseta, clkb, ceb, resetb, oce, ada, din, adb);

output [15:0] dout;
input clka;
input cea;
input reseta;
input clkb;
input ceb;
input resetb;
input oce;
input [9:0] ada;
input [15:0] din;
input [9:0] adb;

wire [15:0] sdpb_inst_0_dout_w;
wire gw_vcc;
wire gw_gnd;

assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

SDPB sdpb_inst_0 (
    .DO({sdpb_inst_0_dout_w[15:0],dout[15:0]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({ada[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[15:0]}),
    .ADB({adb[9:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam sdpb_inst_0.READ_MODE = 1'b0;
defparam sdpb_inst_0.BIT_WIDTH_0 = 16;
defparam sdpb_inst_0.BIT_WIDTH_1 = 16;
defparam sdpb_inst_0.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_0.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_0.RESET_MODE = "SYNC";
defparam sdpb_inst_0.INIT_RAM_00 = 256'h0F6C0E6C0D650C48FB21FA64F96CF872F76FF657F520F46FF36CF26CF165F048;
defparam sdpb_inst_0.INIT_RAM_01 = 256'h106F1F571E201D6F1C6C1B6C1A65194808210764066C0572046F03570220016F;
defparam sdpb_inst_0.INIT_RAM_02 = 256'h212120642F6C2E722D6F2C572B202A6F296C286C2765264815211464136C1272;
defparam sdpb_inst_0.INIT_RAM_03 = 256'h426C416C40654F483E213D643C6C3B723A6F39573820376F366C356C34653248;
defparam sdpb_inst_0.INIT_RAM_04 = 256'h536F52575120506F5F6C5E6C5D655C484B214A64496C4872476F46574520436F;
defparam sdpb_inst_0.INIT_RAM_05 = 256'h64216364626C6172606F6F576E206D6F6C6C6B6C6A65694858215764566C5472;
defparam sdpb_inst_0.INIT_RAM_06 = 256'h856C846C83658248712170647F6C7E727D6F7C577B207A6F796C786C76657548;
defparam sdpb_inst_0.INIT_RAM_07 = 256'h966F95579420936F926C916C90659F488E218D648C6C8B728A6F89578720866F;
defparam sdpb_inst_0.INIT_RAM_08 = 256'hA721A664A56CA472A36FA257A120A06FAF6CAE6CAD65AC489B219A64986C9772;
defparam sdpb_inst_0.INIT_RAM_09 = 256'hC86CC76CC665C548B421B364B26CB172B06FBF57BE20BD6FBC6CBA6CB965B848;
defparam sdpb_inst_0.INIT_RAM_0A = 256'hD96FD857D720D66FD56CD46CD365D248C121C064CF6CCE72CD6FCB57CA20C96F;
defparam sdpb_inst_0.INIT_RAM_0B = 256'hEA21E964E86CE772E66FE557E420E36FE26CE16CE065EF48DE21DC64DB6CDA72;
defparam sdpb_inst_0.INIT_RAM_0C = 256'h0B6C0A6C09650848F721F664F56CF472F36FF257F120F06FFE6CFD6CFC65FB48;
defparam sdpb_inst_0.INIT_RAM_0D = 256'h1C6F1B571A20196F186C176C1665154804210364026C01720F6F0E570D200C6F;
defparam sdpb_inst_0.INIT_RAM_0E = 256'h2D212C642B6C2A72296F28572720266F256C246C2365214810211F641E6C1D72;
defparam sdpb_inst_0.INIT_RAM_0F = 256'h4E6C4D6C4C654B483A213964386C3772366F35573420326F316C306C3F653E48;
defparam sdpb_inst_0.INIT_RAM_10 = 256'h5F6F5E575D205C6F5B6C5A6C5965584847214664456C4372426F415740204F6F;
defparam sdpb_inst_0.INIT_RAM_11 = 256'h60216F646E6C6D726C6F6B576A20696F686C676C6565644853215264516C5072;
defparam sdpb_inst_0.INIT_RAM_12 = 256'h816C806C8F658E487D217C647B6C7A72796F78577620756F746C736C72657148;
defparam sdpb_inst_0.INIT_RAM_13 = 256'h926F915790209F6F9E6C9D6C9C659B488A218964876C8672856F84578320826F;
defparam sdpb_inst_0.INIT_RAM_14 = 256'hA321A264A16CA072AF6FAE57AD20AC6FAB6CA96CA865A74896219564946C9372;
defparam sdpb_inst_0.INIT_RAM_15 = 256'hC46CC36CC265C148B021BF64BE6CBD72BC6FBA57B920B86FB76CB66CB565B448;
defparam sdpb_inst_0.INIT_RAM_16 = 256'hD56FD457D320D26FD16CD06CDF65DE48CD21CB64CA6CC972C86FC757C620C56F;
defparam sdpb_inst_0.INIT_RAM_17 = 256'hE621E564E46CE372E26FE157E020EF6FED6CEC6CEB65EA48D921D864D76CD672;
defparam sdpb_inst_0.INIT_RAM_18 = 256'h076C066C05650448F321F264F16CF072FE6FFD57FC20FB6FFA6CF96CF865F748;
defparam sdpb_inst_0.INIT_RAM_19 = 256'h186F17571620156F146C136C126510480F210E640D6C0C720B6F0A570920086F;
defparam sdpb_inst_0.INIT_RAM_1A = 256'h29212864276C2672256F24572320216F206C2F6C2E652D481C211B641A6C1972;
defparam sdpb_inst_0.INIT_RAM_1B = 256'h4A6C496C4865474836213564346C3272316F30573F203E6F3D6C3C6C3B653A48;
defparam sdpb_inst_0.INIT_RAM_1C = 256'h5B6F5A575920586F576C566C5465534842214164406C4F724E6F4D574C204B6F;
defparam sdpb_inst_0.INIT_RAM_1D = 256'h6C216B646A6C6972686F67576520646F636C626C616560485F215E645D6C5C72;
defparam sdpb_inst_0.INIT_RAM_1E = 256'h8D6C8C6C8B658A4879217864766C7572746F73577220716F706C7F6C7E657D48;
defparam sdpb_inst_0.INIT_RAM_1F = 256'h9E6F9D579C209B6F9A6C986C9765964885218464836C8272816F80578F208E6F;
defparam sdpb_inst_0.INIT_RAM_20 = 256'hAF21AE64AD6CAC72AB6FA957A820A76FA66CA56CA465A34892219164906C9F72;
defparam sdpb_inst_0.INIT_RAM_21 = 256'hC06CCF6CCE65CD48BC21BA64B96CB872B76FB657B520B46FB36CB26CB165B048;
defparam sdpb_inst_0.INIT_RAM_22 = 256'hD16FD057DF20DE6FDC6CDB6CDA65D948C821C764C66CC572C46FC357C220C16F;
defparam sdpb_inst_0.INIT_RAM_23 = 256'hE221E164E06CEF72ED6FEC57EB20EA6FE96CE86CE765E648D521D464D36CD272;
defparam sdpb_inst_0.INIT_RAM_24 = 256'h036C026C01650F48FE21FD64FC6CFB72FA6FF957F820F76FF66CF56CF465F348;
defparam sdpb_inst_0.INIT_RAM_25 = 256'h146F13571220106F1F6C1E6C1D651C480B210A64096C0872076F06570520046F;
defparam sdpb_inst_0.INIT_RAM_26 = 256'h25212464236C2172206F2F572E202D6F2C6C2B6C2A65294818211764166C1572;
defparam sdpb_inst_0.INIT_RAM_27 = 256'h466C456C43654248312130643F6C3E723D6F3C573B203A6F396C386C37653648;
defparam sdpb_inst_0.INIT_RAM_28 = 256'h576F56575420536F526C516C50655F484E214D644C6C4B724A6F49574820476F;
defparam sdpb_inst_0.INIT_RAM_29 = 256'h68216764656C6472636F62576120606F6F6C6E6C6D656C485B215A64596C5872;
defparam sdpb_inst_0.INIT_RAM_2A = 256'h896C876C8665854874217364726C7172706F7F577E207D6F7C6C7B6C7A657948;
defparam sdpb_inst_0.INIT_RAM_2B = 256'h9A6F98579720966F956C946C93659248812180648F6C8E728D6F8C578B208A6F;
defparam sdpb_inst_0.INIT_RAM_2C = 256'hAB21A964A86CA772A66FA557A420A36FA26CA16CA065AF489E219D649C6C9B72;
defparam sdpb_inst_0.INIT_RAM_2D = 256'hCB6CCA6CC965C848B721B664B56CB472B36FB257B120B06FBF6CBE6CBD65BC48;
defparam sdpb_inst_0.INIT_RAM_2E = 256'h00000000DA20D96FD86CD76CD665D548C421C364C26CC172C06FCF57CE20CD6F;

endmodule //TextRam
