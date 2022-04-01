//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NZ-LV1QN48C6/I5
//Device: GW1NZ-1
//Created Time: Fri Apr 01 13:12:05 2022

module PixelsROM (dout, clk, oce, ce, reset, ad);

output [15:0] dout;
input clk;
input oce;
input ce;
input reset;
input [11:0] ad;

wire [27:0] prom_inst_0_dout_w;
wire [27:0] prom_inst_1_dout_w;
wire [27:0] prom_inst_2_dout_w;
wire [27:0] prom_inst_3_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[27:0],dout[3:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[11:0],gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 4;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'h8888888A3555560977777777777777766666666666677779D02210C777777777;
defparam prom_inst_0.INIT_RAM_01 = 256'h8888888B3543346187777777777777766666666666777790211111D877777777;
defparam prom_inst_0.INIT_RAM_02 = 256'h8888888C54333356E87777777777777666666666677777F21000000877777777;
defparam prom_inst_0.INIT_RAM_03 = 256'h8888888E543334456A777777777777766766666677777E210000001B87777777;
defparam prom_inst_0.INIT_RAM_04 = 256'h8888888F544444445497777777777777766666667777B2110000000C77777777;
defparam prom_inst_0.INIT_RAM_05 = 256'h8888888145433444461887777777777776776666777821111100000D77887777;
defparam prom_inst_0.INIT_RAM_06 = 256'h8888889155544345547B87777777777777777677777F21110000000F78888877;
defparam prom_inst_0.INIT_RAM_07 = 256'h988888925554455445539887777777777777768667D211111110000F87888877;
defparam prom_inst_0.INIT_RAM_08 = 256'h999888A2555445555456E888888877777777777778221111111000FF87888887;
defparam prom_inst_0.INIT_RAM_09 = 256'h9999999345544456554559888888777777777877703111111111110F87888888;
defparam prom_inst_0.INIT_RAM_0A = 256'h9999999355534334665560988888888877777878C43211222110110E87778887;
defparam prom_inst_0.INIT_RAM_0B = 256'h999999A155445556565556C88889888888888879333222211110110F77777778;
defparam prom_inst_0.INIT_RAM_0C = 256'h9999999E565445556545563A99AB888888988990433221112111110E87777878;
defparam prom_inst_0.INIT_RAM_0D = 256'hA999999B3565443344445570CBEA88989CD9ABE6432211211111110D87787778;
defparam prom_inst_0.INIT_RAM_0E = 256'hAAA9999A3455544544444357213CA9999F2EE16643222232222110FB88887778;
defparam prom_inst_0.INIT_RAM_0F = 256'hAAAAA99A344544555543456977810ABC15864675422221112211100988887787;
defparam prom_inst_0.INIT_RAM_10 = 256'hAAAAAAAA354442224466688999A8736679998886433233332211100988778888;
defparam prom_inst_0.INIT_RAM_11 = 256'hBBAAAA9A15544454566779999AAA999AAAAA9987654432322101000888787888;
defparam prom_inst_0.INIT_RAM_12 = 256'hBBBAAAAAE55444444688889AAABBBBACCBBBAA9887552211111000E888887888;
defparam prom_inst_0.INIT_RAM_13 = 256'hCCCBBAAAC4664355678989AAABCCDBCDDCCCAA9988755443211100B777888888;
defparam prom_inst_0.INIT_RAM_14 = 256'hCCCCBBBAB265666767898ABBBBCDDDDDEDCCBBA99876654432211E9778888888;
defparam prom_inst_0.INIT_RAM_15 = 256'hDDCCCBBBC455566767999AACCBCDDEEEEDDDBBAAA987755431111CA888888888;
defparam prom_inst_0.INIT_RAM_16 = 256'hDDDDCCCBD6667778888A99ACCBCEEEEEDDDCCBAAA989877544001E9888888888;
defparam prom_inst_0.INIT_RAM_17 = 256'hEEDDDCCCF66678889999899BCBDEFDEEDDDCCBAAAA988886641010A887888888;
defparam prom_inst_0.INIT_RAM_18 = 256'hEEEEDDCD146688799999AA9ABADEECEDDDDDCAAAAA9888886521109888888888;
defparam prom_inst_0.INIT_RAM_19 = 256'hFFFEEDDE36778988AA9AA99ABBCEEDDDDCDDCAAAAA998888763111B988888888;
defparam prom_inst_0.INIT_RAM_1A = 256'hFFFFEEF356888887999A989AABDEDDCCCBCCBAAAAAA98888865221A888888888;
defparam prom_inst_0.INIT_RAM_1B = 256'h0FFFFF048888989988998889ACEECCDCCBBBBAAAAAA98787876531CA88888888;
defparam prom_inst_0.INIT_RAM_1C = 256'h0FFF02577778877789867778ACEECCCCCBBAAAAAA9999877777753F988888888;
defparam prom_inst_0.INIT_RAM_1D = 256'hF000048987776775568656779BDECBCBCAAAAAA9999888777877651C99888888;
defparam prom_inst_0.INIT_RAM_1E = 256'hE0002589875321F0146433568ACDCCCBBAAAA9999877677788877640BA888888;
defparam prom_inst_0.INIT_RAM_1F = 256'hAF0146789861BCDCBAF2422479BDCCBBA999998740EF247888877653DB888888;
defparam prom_inst_0.INIT_RAM_20 = 256'h6BF023689873FEDD99AC241369BCDCBBA98886086677926888886553FA988888;
defparam prom_inst_0.INIT_RAM_21 = 256'h57CF267899A844427929D53369BCCCBBA9995B56A866B079988876552D988888;
defparam prom_inst_0.INIT_RAM_22 = 256'h458F3689AAA866317E1AA55479ACCBBABAA6B65597559089998876542C988888;
defparam prom_inst_0.INIT_RAM_23 = 256'h458D25789AA87742957BA35569BCCBAABB81995676459399998876542FC98888;
defparam prom_inst_0.INIT_RAM_24 = 256'h468C047899A98754465CA35579BCCBAABB10BB8D8347F7A9998866542E988888;
defparam prom_inst_0.INIT_RAM_25 = 256'h4569E15899AAA976766FF26689ACCBAAB923EAAC75808AAAA98775432D988888;
defparam prom_inst_0.INIT_RAM_26 = 256'h557AE036889ABBA88777326689ABCCBAB71461ECC07AAAA9988765442C998888;
defparam prom_inst_0.INIT_RAM_27 = 256'h5557CF2457899AABBB98745799BCBBBAA6348A99AAAAA999988765431D888888;
defparam prom_inst_0.INIT_RAM_28 = 256'h4556AD035578899ABB9976689ACCCCBBA987ABAAAAAAA999877665441C988888;
defparam prom_inst_0.INIT_RAM_29 = 256'h4557ACE26676899AAABA86599ACCCCBBAAAABAAAAAAABAA987666542FA888888;
defparam prom_inst_0.INIT_RAM_2A = 256'h45568ABD046778999ABA85699ABBBBBAAABBBBBAAAAAAA9876776430BA888888;
defparam prom_inst_0.INIT_RAM_2B = 256'h555568ACF34577889AA974578AAAAAAAABBBBBBAA999987667765432C9888888;
defparam prom_inst_0.INIT_RAM_2C = 256'h454567BCF1457778899862467899989AACCBBBAAA998889887654321CA888777;
defparam prom_inst_0.INIT_RAM_2D = 256'h4455568AC01346677787413577887679BCBBBBBA998877777654232FC9877777;
defparam prom_inst_0.INIT_RAM_2E = 256'h44445579AACF356567761E3677788669BBBBBAAA988776654333330CA9877777;
defparam prom_inst_0.INIT_RAM_2F = 256'h44444568889B03555677BC25666776669BBBAA9987654322222211FC98777777;
defparam prom_inst_0.INIT_RAM_30 = 256'h44444568889AC1455567E8C144454435ABBAA9987654FDCCDF00EFFB98777777;
defparam prom_inst_0.INIT_RAM_31 = 256'h44445658BBCD224675670657F11F995ABBAA9998751FDCBCCDCCCEEC88777777;
defparam prom_inst_0.INIT_RAM_32 = 256'h444557A9877ADE2345673965ADDFC39BBAAA9988863DBBBDEFEEF0DA98777777;
defparam prom_inst_0.INIT_RAM_33 = 256'h44567566678EFCD0F15554F98BB37AAAABA9AA999860EEDCE1210FEB87777777;
defparam prom_inst_0.INIT_RAM_34 = 256'h45655666777BFD1443565664ACC289999888877765520FF11221FFCA98777777;
defparam prom_inst_0.INIT_RAM_35 = 256'h5554567667898AB1456655672DC47889999988865650FF0F02320DB998777777;
defparam prom_inst_0.INIT_RAM_36 = 256'h44456666779A989AC025533552F3457999A98877764FCCDFDEFF0DA877777777;
defparam prom_inst_0.INIT_RAM_37 = 256'h4456666877676799AAC0023230D123455877555323211000EEEDCCA877777777;
defparam prom_inst_0.INIT_RAM_38 = 256'h45556697556688778BFF11222EDF23466766564443E002231BBCCBA977777777;
defparam prom_inst_0.INIT_RAM_39 = 256'h444667655558766788ABEDDEEBAC01446566623FE210001110BCCCA987777777;
defparam prom_inst_0.INIT_RAM_3A = 256'h33467655557755686798B9BD10CCCCF233310FDFDDF2100ECBEDDCB987777777;
defparam prom_inst_0.INIT_RAM_3B = 256'h33566665577656775687AAF33310FCBDCDDCECDBFFE0110DAABDCCBA87777777;
defparam prom_inst_0.INIT_RAM_3C = 256'h345666656665758556989A03444420EDACC9ABACD0EE0DECBCDECCBA87777777;
defparam prom_inst_0.INIT_RAM_3D = 256'h335666558756676556889BC1343343FEDDBB899CCBDEEDEECDDEEDBA87767777;
defparam prom_inst_0.INIT_RAM_3E = 256'h33566656665758555667A8A0001343FBAB99899ACBCEFFFFFEFEDDBA97666667;
defparam prom_inst_0.INIT_RAM_3F = 256'h33566655657666555555879CCCBF21EA888989ACDDDF00101FFFECCA97666667;

pROM prom_inst_1 (
    .DO({prom_inst_1_dout_w[27:0],dout[7:4]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[11:0],gw_gnd,gw_gnd})
);

defparam prom_inst_1.READ_MODE = 1'b0;
defparam prom_inst_1.BIT_WIDTH = 4;
defparam prom_inst_1.RESET_MODE = "SYNC";
defparam prom_inst_1.INIT_RAM_00 = 256'h222002285FFF11540EEEEECCCCCAAAAAA88888888AACCEE6AB13FB4EEEEEEEEC;
defparam prom_inst_1.INIT_RAM_01 = 256'h2222222C3FB99D3B20EEECCCCCCCAAAAAA888888AAACCE6931F111A2EE000EEE;
defparam prom_inst_1.INIT_RAM_02 = 256'h22222222DB7777D3C0EEEECCCCCCCCAAAA888888AACCE043FDDDDDB40EE00EEE;
defparam prom_inst_1.INIT_RAM_03 = 256'h2222222AF995797D1C0EEEECCCCCCCCAAAAA888AACAEE03FFDDDDDFE0000EEEE;
defparam prom_inst_1.INIT_RAM_04 = 256'h2222222EFB977799D960ECECCCCCCCCAAAAAA8AAACCE25FFFDBDDDF600000000;
defparam prom_inst_1.INIT_RAM_05 = 256'h22222247DB955799B190EEEECCCCCCCAAAAAAAAAACC4511F1FDDDDDC00000000;
defparam prom_inst_1.INIT_RAM_06 = 256'h4422224BDDB7737BBB500EEECCCCCCCCAAAAAAACACE8511FFFDDDDD200000000;
defparam prom_inst_1.INIT_RAM_07 = 256'h4442226DBBB77B97BDF540EEECCCCCCCAAAAAAEACC87311111FFFDD620020002;
defparam prom_inst_1.INIT_RAM_08 = 256'h4442228FBD9799BDBBB3C0EEEEEEECCCCCCAAAEAC67753311FFDFDA600000022;
defparam prom_inst_1.INIT_RAM_09 = 256'h664444439DB779BDDDBFD80EEEEEEEECCCCCAECCEBB5531331FFFFD420000222;
defparam prom_inst_1.INIT_RAM_0A = 256'h666444619D955557FFDD17400EE0EEEECEEEC0CE4DB7555531FDFFD420002222;
defparam prom_inst_1.INIT_RAM_0B = 256'h66666689BD979DDDBFFDF1220002E0EEEE0EE2E69D9757511FFFFFB600222222;
defparam prom_inst_1.INIT_RAM_0C = 256'h6666666CBFD779BBDBBDD35A468C0000024E2469FB977311331FF1BE20222222;
defparam prom_inst_1.INIT_RAM_0D = 256'h888666607DFB7755799BBD592CEA00002266AE03FB973553331111BA00222222;
defparam prom_inst_1.INIT_RAM_0E = 256'h8888866C79DB99799977B7F3F932624262DCCB13D9755795553111A200022222;
defparam prom_inst_1.INIT_RAM_0F = 256'hCAA88888779B7599BD979D19537938E2995F9351D977311133111FDA00222222;
defparam prom_inst_1.INIT_RAM_10 = 256'hEECCAA881B7971DF79DFD59BBDD713FF1BDD9773F9779B9953111FF600222222;
defparam prom_inst_1.INIT_RAM_11 = 256'h0EEECCAABD957797BFF139BDDFFDDDDFF1F1DD971FDB957531F1FFB222222222;
defparam prom_inst_1.INIT_RAM_12 = 256'h4220ECCAEDB777977F5557BFFF1333F55531FFD975FF53F1FF1FFF2022222222;
defparam prom_inst_1.INIT_RAM_13 = 256'h664200EC89FF95B9F1575BDFF1579359995511DB997DFB975311FF4022222244;
defparam prom_inst_1.INIT_RAM_14 = 256'hA886420E23DBFBD1D1797DF13159979BDB7753FDD9531FBB735338A222222244;
defparam prom_inst_1.INIT_RAM_15 = 256'hCCAA664249BBBDFFF39B9DF5513B9BBDDB7731FDFB775FFD935550C022222222;
defparam prom_inst_1.INIT_RAM_16 = 256'h0EECA864CFFD3113555B9BB3515BDBDDB99753FFFB9B955FDD33388222222222;
defparam prom_inst_1.INIT_RAM_17 = 256'h200ECCA82DDD153399797991517BDBBD999751FFFD9999953D535FA222222222;
defparam prom_inst_1.INIT_RAM_18 = 256'h42200ECC97DD55177999DB9F317DB7B997995FFFDDBB99995F7371A422222222;
defparam prom_inst_1.INIT_RAM_19 = 256'h444420EEFF113737BD7BD99F317DD99975995FFDFFBB99997395734622222222;
defparam prom_inst_1.INIT_RAM_1A = 256'h6644424F9D555553999BB59F13BD9B9753793FDDFFDB77999519930422222422;
defparam prom_inst_1.INIT_RAM_1B = 256'h76644495333577795577559DF5DD779775331FDDFFDB77777951D7CA22222422;
defparam prom_inst_1.INIT_RAM_1C = 256'h76667F9F1113311157311359D7BD75557311FFDDFBBB97577775198822222222;
defparam prom_inst_1.INIT_RAM_1D = 256'h4777733533FFDF19BF3D9F33B59B7555711FFFDBBB997755797751F8A4422222;
defparam prom_inst_1.INIT_RAM_1E = 256'hC579D7395F93D9E395D735BF717B77553FFFFDBBB7533557999773FD28222222;
defparam prom_inst_1.INIT_RAM_1F = 256'h807B3B1575DD400EA80F5FF73B3B75331FDBDB95BD6A5B59999773F9EE222222;
defparam prom_inst_1.INIT_RAM_20 = 256'h8C27D1B39713060ECE62D593FB179531FB9B91F08C24853BBB9953F9AE622222;
defparam prom_inst_1.INIT_RAM_21 = 256'h4C00BB1579B31FDD4A128B31F9355511FDDBDC6E8EE2837DDDB9753F5C842222;
defparam prom_inst_1.INIT_RAM_22 = 256'h260CFB39BDD597990CD68793191553111FF1AE4E0648E39DDDBB751F36842222;
defparam prom_inst_1.INIT_RAM_23 = 256'h46E4D7157BD9BDBF899841B9F91573FF3371AA8444682DDFFDB9751D56262224;
defparam prom_inst_1.INIT_RAM_24 = 256'h48EE11179BDD5D5B935C8FB9193551FF11396E64802E691FFDB9551D5E644224;
defparam prom_inst_1.INIT_RAM_25 = 256'h4484A9939BDDF7B77778EDDD5BF5531F1B536EA60089B3311DB951FB5CA42224;
defparam prom_inst_1.INIT_RAM_26 = 256'h48EA831D579D11F71DD31DD19BD35511171D372CC973331FDB9731FB58864424;
defparam prom_inst_1.INIT_RAM_27 = 256'h466E20F7B379BDF11F9737B39D353331F3BF7FDD11331FFDDB9531F91A424444;
defparam prom_inst_1.INIT_RAM_28 = 256'h446AA67F9D157BDF1FB93DF7DF577531FB97133111111FDDB95331DB18842244;
defparam prom_inst_1.INIT_RAM_29 = 256'h446CA2ADBF1159BF1D1D5DDBD15777311D11133111F153FDB51351B34C422224;
defparam prom_inst_1.INIT_RAM_2A = 256'h44480A0873B137BBDF1D5BF9D133531F1F3333311FF1FFDB75551D7D4A422244;
defparam prom_inst_1.INIT_RAM_2B = 256'h4646A2A62F7B35999DD917D5BF111F1FF35333311DFDDB535771FB5188442222;
defparam prom_inst_1.INIT_RAM_2C = 256'h444680E2095B33377997F1B179DDB9BF15735531FDD999DB751DB95F8A642222;
defparam prom_inst_1.INIT_RAM_2D = 256'h44444A2843717DF333537B7F3579755B15333351FDB9755553D9573668422222;
defparam prom_inst_1.INIT_RAM_2E = 256'h444448E8AC22F9DBD11FB03D1337731B55331111D995531DB75777DAC6220222;
defparam prom_inst_1.INIT_RAM_2F = 256'h24444682446E7F9B9D1148FBFFF311F1B331FFFD951FB711F1331F6884222222;
defparam prom_inst_1.INIT_RAM_30 = 256'h244444C4468A497BB9D5E6AD579B975D1311DDBB73F74E8AE499464482222022;
defparam prom_inst_1.INIT_RAM_31 = 256'h22446A82E048DF5DFBD35E606BB60ADF53FFB9B97DD2C66AACA8824462222222;
defparam prom_inst_1.INIT_RAM_32 = 256'h224660A4022A6CD159D15EE80CE209F31FFDDB797F5E426A02426BEE84200022;
defparam prom_inst_1.INIT_RAM_33 = 256'h2468E8ACCE4A2487277B976A82613F1FF1DBFDDB9719EEA82D1FD62042002002;
defparam prom_inst_1.INIT_RAM_34 = 256'h46886ACEE00EE873519DBDF724617BBBB7755353FDD1704DF13F648C84222202;
defparam prom_inst_1.INIT_RAM_35 = 256'h66448E0CCE2648E519DFBBD13A87379BBDDB7771DFB9449673739E0884202202;
defparam prom_inst_1.INIT_RAM_36 = 256'h4226CECCEE48844A03B99319BD237D3BDDDD97135D7468C40464BC0622220002;
defparam prom_inst_1.INIT_RAM_37 = 256'h226ACCC200AEE086AC235D1F33A9D35BD531DBB511F997B7204E880620000222;
defparam prom_inst_1.INIT_RAM_38 = 256'h2448CE6E8ACA22E02ECE7BDFFC84D17D111DDD9971E99F15D668A40820000002;
defparam prom_inst_1.INIT_RAM_39 = 256'h422AE0C888A20CC040A0A68AAEA25B77FBFDDF54EDBB99DDB94CA60842000022;
defparam prom_inst_1.INIT_RAM_3A = 256'h004C0CAA8800A8C2E062C62C9564460D131972A4AC2FDD70660CC80A42000022;
defparam prom_inst_1.INIT_RAM_3B = 256'h006CCCCA6EEC8C00AE408A0111B728080A86C2802007DD7C226CA80C42022222;
defparam prom_inst_1.INIT_RAM_3C = 256'h026CCCC8CCC80A488A426C315555F9CAC406A2C487E27C086A02CA2C60002022;
defparam prom_inst_1.INIT_RAM_3D = 256'h008EEEA82E8CC0C68A22602B1753732E662E488482CE2C22C0022C4C60000000;
defparam prom_inst_1.INIT_RAM_3E = 256'hE08EECAACA8EA4668CCEA4C355735320A0AA68AE828E444864642E6E80000000;
defparam prom_inst_1.INIT_RAM_3F = 256'hE08EECA8CAEACC6886682E626222BBEE644848C6CCC49BFBFA664C6E80000000;

pROM prom_inst_2 (
    .DO({prom_inst_2_dout_w[27:0],dout[11:8]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[11:0],gw_gnd,gw_gnd})
);

defparam prom_inst_2.READ_MODE = 1'b0;
defparam prom_inst_2.BIT_WIDTH = 4;
defparam prom_inst_2.RESET_MODE = "SYNC";
defparam prom_inst_2.INIT_RAM_00 = 256'h2222222A5DDD6E42A999911111111111199999999111111A345D44B999999111;
defparam prom_inst_2.INIT_RAM_01 = 256'h222222225DD55D642A9991111111111199999991111111A4D54555B299AAA999;
defparam prom_inst_2.INIT_RAM_02 = 256'h2222AA23DD555DD63A999911111111119999999911111ACD444444CAA99AA999;
defparam prom_inst_2.INIT_RAM_03 = 256'h2222AA23D55DDDDDEAA99111111111199999999911111CD444444442AAAA9999;
defparam prom_inst_2.INIT_RAM_04 = 256'h2222AA2BDD5DDD55DDAA9111111111119999999911113DC44444444BAAAAAAAA;
defparam prom_inst_2.INIT_RAM_05 = 256'h2222222CDD5DDD5D56C299911111111119999999111ADDD454444443AA2AAAAA;
defparam prom_inst_2.INIT_RAM_06 = 256'h222222A4DD55DDD5556BA99911111111119199111194DDD44444444CAAAA2AAA;
defparam prom_inst_2.INIT_RAM_07 = 256'h222222ACDD55D55D5DD52A9911111111111119911135DDDDD54444442AA222AA;
defparam prom_inst_2.INIT_RAM_08 = 256'hAA2222ACDD5DDD5555D63A9999111111111111111AD55DDD544444442A222222;
defparam prom_inst_2.INIT_RAM_09 = 256'h222222A5DD55DD555D5D5AA9999111111111111194D55DDDDDCCCC442A222222;
defparam prom_inst_2.INIT_RAM_0A = 256'hA22222A5DD5DDDDDDDDD6C2AA99A111111111A19BDD55555DDCCCC4422222222;
defparam prom_inst_2.INIT_RAM_0B = 256'hAAA222A4DD5D555D5DDDD63AAAA2129991211A9A5DD5555DDCCCCC442AAA2222;
defparam prom_inst_2.INIT_RAM_0C = 256'hAAAAAAABDDDDDD55D55DD6522AA2AAA2AA29A2A45DD55DDD5DDCCD4B2AAA2222;
defparam prom_inst_2.INIT_RAM_0D = 256'hAAAAAAA35DD5DDDDD555DD6C323AAAAAABB2AA465DD5555DDDDDDD4BAAA22222;
defparam prom_inst_2.INIT_RAM_0E = 256'hAAAAAAAA55D55DD5D55555564CD3A222AC43346E5DD555D555DDDD4B22222222;
defparam prom_inst_2.INIT_RAM_0F = 256'h222AAAAAD5DD5D55555D5D6E6E6CCA2BCD65D6EE5DD55D5D5DDD5CCA22222222;
defparam prom_inst_2.INIT_RAM_10 = 256'hA22222AA5D5D5D44D5DDD6EEE666EDDDEE66EEEE5DD5DDD555555CCA22222222;
defparam prom_inst_2.INIT_RAM_11 = 256'hBAA222A24DD5555D5DDE6EE666E666666F6F66EE65DDD55555454C4222222222;
defparam prom_inst_2.INIT_RAM_12 = 256'h333BA222BDD5555DDD6666666EFFFFE777FFEE6EE6DD55C5C4544C422A222222;
defparam prom_inst_2.INIT_RAM_13 = 256'hBB33BBA2B5DD5D55DE6E6E6E6F77F777F777FF66EEED5DD555554CB222222222;
defparam prom_inst_2.INIT_RAM_14 = 256'h33BB33BABDD5DD5E5E6EE6EF7F7FF77FFF777F6666E66DDDD55554A222222222;
defparam prom_inst_2.INIT_RAM_15 = 256'hB333BB33B5555DDD5EEEE6677FFFFFFFFF77FF66E6EEED5DD5555CA222222222;
defparam prom_inst_2.INIT_RAM_16 = 256'hCBB33BBBBDD5EEEE666EEE6F7F7FFFFFFFF7776EE666EEE55D55542222222222;
defparam prom_inst_2.INIT_RAM_17 = 256'h44CB333345DDE6E6EEEEEEEF7F7FFFFF7FF77FEEE666EEE66DD55CA222222222;
defparam prom_inst_2.INIT_RAM_18 = 256'h44CCCB334D5566E6EEEE6EE6FF7FF7FF77FF7EEE6666EEEE65D5DDA222222222;
defparam prom_inst_2.INIT_RAM_19 = 256'h4444CCBBC5EEE666E6EE6EE6FF7FFFFFF7FF7EE6EE66EEEEE6DDDD3A22222222;
defparam prom_inst_2.INIT_RAM_1A = 256'h44444C4CD566666EEEEEE6E6FFFFFFF7777F7EE6EEE6EEEEE66DDD3222222222;
defparam prom_inst_2.INIT_RAM_1B = 256'h444444C5EEE6E6EE666E66E667FFF7F777777EE6EE66EEEEEE66D5B222222222;
defparam prom_inst_2.INIT_RAM_1C = 256'h444444D5EEE6EEEE666EEE6E67FFF77777FFEEEEE6666EEEEEEE654222222222;
defparam prom_inst_2.INIT_RAM_1D = 256'h444CC5E66EDD5DE55D65D56667FFF77777FEEEE6666EEEEEEEEE6E432A222222;
defparam prom_inst_2.INIT_RAM_1E = 256'h344C45EE6D5D4C3C4D5D5D5DEF7FFF777EEEEE6E6EEEEEE66EEEE6DC32A222A2;
defparam prom_inst_2.INIT_RAM_1F = 256'hAC44DDE666D4333AA24CDC4D667F77777EEEE66E54CCDD6666EEE6DDBAAAA2AA;
defparam prom_inst_2.INIT_RAM_20 = 256'h92C44DDEEEE54BB21923CD45D67FF777E6666ECBAAB3BDEE666EE6D54AAAAAAA;
defparam prom_inst_2.INIT_RAM_21 = 256'h11BC4DE66E66DCC39142BD5DDE77777FEEE6532AAB3C45EEEE66E66DDB2AAAAA;
defparam prom_inst_2.INIT_RAM_22 = 256'h11234DEE66EEDD4B12B2ADD5EEFF77FFFEEEBAC324C445EEEE66EE6DDB2AAA2A;
defparam prom_inst_2.INIT_RAM_23 = 256'h19934DE6E6E65543145A255DD677F7EE776D344C14445D66EE66EE6DDC3AAA2A;
defparam prom_inst_2.INIT_RAM_24 = 256'h199ACDE6EE66ED5445D2A4556E7777EE77DCCC4C2CCC5E76E666E66DDBAAAAAA;
defparam prom_inst_2.INIT_RAM_25 = 256'h11923CD6E666EEDD5553B45566E7F7FEF65DCC4C44CDE7777E6EE6D5DB2AA2AA;
defparam prom_inst_2.INIT_RAM_26 = 256'h1912B4D566E6FFEE6556D45EE6E7F77F765D65DCCDE7777E666E6ED5532AAAAA;
defparam prom_inst_2.INIT_RAM_27 = 256'h119934CD5E6E66EFFEE66D566E7F777FEED566EE77777EE666E666D553AAAAAA;
defparam prom_inst_2.INIT_RAM_28 = 256'h11112BCCD5E6EE6EFE6E65DEEEFFFF7FEEE677777777FEE66E6666D5532AAAAA;
defparam prom_inst_2.INIT_RAM_29 = 256'h11912334D5EE6E6EF6F665D6E7FFFF7FFE77777777E777E66E666E55CAAAAAAA;
defparam prom_inst_2.INIT_RAM_2A = 256'h1119A2B3C55EEEEE66F66556E7FFF77EFE7777777EE7EE66E66665D4B2AAAAAA;
defparam prom_inst_2.INIT_RAM_2B = 256'h1111122B4CD5E6EEE66EE556E67F767EE7777777FEE666E66EE6D5D532AAAAAA;
defparam prom_inst_2.INIT_RAM_2C = 256'h11119A23CC55E6EE6EE65D56E6666EEEF7F77777EE66EE66E6E55DDC3AAAAAAA;
defparam prom_inst_2.INIT_RAM_2D = 256'h1111192A34CD55DEEE6EDC55EE666EEE77777777E66EE6666E5DDD5CB2A2222A;
defparam prom_inst_2.INIT_RAM_2E = 256'h9911199A2234CD555EE5C4DDEEEEEE6E77777FFF6EE66EE55DDDDDC3AAA2222A;
defparam prom_inst_2.INIT_RAM_2F = 256'h99911192A2AACCDDD5EEBBCD5DDEE656E77FEEE6EE6D5D55C555DCC32A22222A;
defparam prom_inst_2.INIT_RAM_30 = 256'h999111122AA23C5DDD5E3A34D55555DD77FF6666E6DDCB3BBCC44CCB2222222A;
defparam prom_inst_2.INIT_RAM_31 = 256'h99991992AB3B44555D5E499A4444BB5677EE6E66E5C4BBB33B3334CBA222222A;
defparam prom_inst_2.INIT_RAM_32 = 256'h99911AA2A222B34D5D565A19B3BCCD677EE666EEED5BB3B3C444C4BA2A222222;
defparam prom_inst_2.INIT_RAM_33 = 256'h991919111923C3B44C5DDDCAA33DEE7EEF66666EEEECBB3344DC4C43A2222222;
defparam prom_inst_2.INIT_RAM_34 = 256'h999991119AA23B4D5DD5D55533BDE666EEE6E666D55DC444C55CCC3A2A222222;
defparam prom_inst_2.INIT_RAM_35 = 256'h991191A1192A2AA4D555DD5EDB3D6EE66666EE6E5DDCC44CC5D54B322A222222;
defparam prom_inst_2.INIT_RAM_36 = 256'h11111111992AA2A2B44DD55D54CDDD6E6666EEE665D4B3BC4CCC4B3A22222222;
defparam prom_inst_2.INIT_RAM_37 = 256'h99191112AA199AAA223444DC543C4DD5566E555DDDC44C4C444B333A22222222;
defparam prom_inst_2.INIT_RAM_38 = 256'h111919219911A29A2A3BC44CC33CC5D5EEE555DDDDBC4CD54BB33B3222222222;
defparam prom_inst_2.INIT_RAM_39 = 256'h19919A19999AA11A222BBB3BBA23C4DDD5555C54B4444C4444BB3332A2222222;
defparam prom_inst_2.INIT_RAM_3A = 256'h9911A19999AA991292A2A23B4CBB334C5554C4343B4C44C43B4BB33AA2222222;
defparam prom_inst_2.INIT_RAM_3B = 256'h99991119111191AA19A2A24D55C4CBB3333B333B4C4C44CB333BB33AA2222222;
defparam prom_inst_2.INIT_RAM_3C = 256'h999911191119292991A2A24DDDDDC4B3AB3A23A3BCB4CBC3BB4CB33AA2222222;
defparam prom_inst_2.INIT_RAM_3D = 256'h99919999A1911A199122A33CDD55D54BBB3A222333BB4B44B44C4BBAA2222222;
defparam prom_inst_2.INIT_RAM_3E = 256'h899991991191921919192A2444C55D432B22A22A333BCCC4CC4C4B3222222222;
defparam prom_inst_2.INIT_RAM_3F = 256'h8991919919191119991929A3B3344CBAA222A2A3BBBC44C4C444CB3222222222;

pROM prom_inst_3 (
    .DO({prom_inst_3_dout_w[27:0],dout[15:12]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[11:0],gw_gnd,gw_gnd})
);

defparam prom_inst_3.READ_MODE = 1'b0;
defparam prom_inst_3.BIT_WIDTH = 4;
defparam prom_inst_3.RESET_MODE = "SYNC";
defparam prom_inst_3.INIT_RAM_00 = 256'h55555555BCCCDC95444444444444444443333333344444458ABBBA7444444444;
defparam prom_inst_3.INIT_RAM_01 = 256'h55555556BCCCCCDA5444444444444444333333344444445ABBBBBB8544444444;
defparam prom_inst_3.INIT_RAM_02 = 256'h55554457CCCCCBCD8444444444444444333333334444449BBBBBBBA544444444;
defparam prom_inst_3.INIT_RAM_03 = 256'h55554458CCCBBBBCC64444444444444333333333444448BBBBBBBBB744444444;
defparam prom_inst_3.INIT_RAM_04 = 256'h55554458CCCBBBCCCB544444444444443333333344447BBBBBBBBBB744444444;
defparam prom_inst_3.INIT_RAM_05 = 256'h55555559CCCBBBCBCD95444444444444433333334445BBBBBBBBBBB944544444;
defparam prom_inst_3.INIT_RAM_06 = 256'h5555555ACCCCBBBCCCD644444444444444343344444ABBBBBBBBBBB944445444;
defparam prom_inst_3.INIT_RAM_07 = 256'h5555555ACCCCBCCBCCCB54444444444444444344448CBBBBBBBBBBBA54455544;
defparam prom_inst_3.INIT_RAM_08 = 256'h5555555ACCCBBBCCCCCD8444444444444444444445BCCBBBBBBBBBBA54555555;
defparam prom_inst_3.INIT_RAM_09 = 256'h5555555BCCCCBBCCCCCCC54444444444444444444ACCCBBBBBBBBBBA54555555;
defparam prom_inst_3.INIT_RAM_0A = 256'h5555555BCCCBBBBBCCCCD95444444444444444447CCCCCCCBBBBBBBA55555555;
defparam prom_inst_3.INIT_RAM_0B = 256'h5555555ACCCBCCCCCCCCCD744445444444444445CCCCCCCBBBBBBBBA54445555;
defparam prom_inst_3.INIT_RAM_0C = 256'h55555558CCCBBBCCCCCCCDB6555644444454455ADCCCCBBBCBBBBBB954445555;
defparam prom_inst_3.INIT_RAM_0D = 256'h55555557CCCCBBBBBCCCCCD9768544444675569DDCCCCCCBBBBBBBB844455555;
defparam prom_inst_3.INIT_RAM_0E = 256'h55555556CCCCCBBCBCCCCCDDA9A7555558A88ADDDCCCCCCCCCBBBBB755555555;
defparam prom_inst_3.INIT_RAM_0F = 256'h66655555BCCCCBCCCCCBCCDDDCD985669BDCBDDDDCCCCBCBCBBBCBB655555555;
defparam prom_inst_3.INIT_RAM_10 = 256'h66666655BCCCCBBBBCCCCDDDDEEDCACCCDEEDDDDDCCCCCCCCCCCCBB555555555;
defparam prom_inst_3.INIT_RAM_11 = 256'h66666656ACCCCCCBCCCCDDDEEEEEEEEEEEEEEEDDDDCCCCCCCCCCCBB555555555;
defparam prom_inst_3.INIT_RAM_12 = 256'h777666668CCCCCCBBCDDDDEEEEEEEEEFFFEEEEEDDDCCCCBCBCCCCBA554555555;
defparam prom_inst_3.INIT_RAM_13 = 256'h777766667CCCCBCCCCDDDDEEEEFFFFFFFFFFEEEEDDDCDCCCCCCCCB7555555555;
defparam prom_inst_3.INIT_RAM_14 = 256'h887777667BCCCCCCCCDDDEEEFEFFFFFFFFFFFEEEEEDDDCCCCCCCCB6555555555;
defparam prom_inst_3.INIT_RAM_15 = 256'h888877777CCCCCCCCCDDDEEFFEEFFFFFFFFFEEEEEEDDDCDCCCCCCA6555555555;
defparam prom_inst_3.INIT_RAM_16 = 256'h888887778CCCCCCCDDDDDDEEFEFFFFFFFFFFFFEEEEEEDDDDDCCCCB6555555555;
defparam prom_inst_3.INIT_RAM_17 = 256'h998888889CCCCDCDDDDDDDDEFEFFFFFFFFFFFEEEEEEEDDDDDCCCCB6555555555;
defparam prom_inst_3.INIT_RAM_18 = 256'h99888888ABCCDDCDDDDDEDDEEEFFFFFFFFFFFEEEEEEEDDDDDDCCCB6555555555;
defparam prom_inst_3.INIT_RAM_19 = 256'h99998888ACCCCDDDDEDDEDDEEEFFFFFFFFFFFEEEEEEEDDDDDDCCCB8555555555;
defparam prom_inst_3.INIT_RAM_1A = 256'h9999989ABCDDDDDCDDDDDDDEEEFFFFFFFFFFFEEEEEEEDDDDDDDCCB7555555555;
defparam prom_inst_3.INIT_RAM_1B = 256'h9999999BCCCDDDDDDDDDDDDEEFFFFFFFFFFFFEEEEEEEDDDDDDDDCC8655555555;
defparam prom_inst_3.INIT_RAM_1C = 256'h99999ABCCCCDCCCCDDDCCCDDEFFFFFFFFFEEEEEEEEEEEDDDDDDDDCA655555555;
defparam prom_inst_3.INIT_RAM_1D = 256'h99999BCDDCCCCCCCCCDCBCDDEFFFFFFFFFEEEEEEEEEDDDDDDDDDDCB865555555;
defparam prom_inst_3.INIT_RAM_1E = 256'h8999ABCDDCCBBA99ABCBBBCCDEFFFFFFFEEEEEEEEDDDDDDEEDDDDDCA76555555;
defparam prom_inst_3.INIT_RAM_1F = 256'h589AABCDDDCBA87667AABABBDEFFFFFFFEEEEEEDDCBBCDEEEEDDDDCB86555555;
defparam prom_inst_3.INIT_RAM_20 = 256'h3689AABCDDCCA7664468ABABCEFFFFFFEEEEEDCA999AADEEEEEDDDCCA6555555;
defparam prom_inst_3.INIT_RAM_21 = 256'h3468ABCDDDEDA99723858BBACDFFFFFEEEEEDB995ABBCDEEEEEEDDDCB8655555;
defparam prom_inst_3.INIT_RAM_22 = 256'h3358ABCDEEEDBA9625656BBBCDEFFFEEEEEDA9BA5BBCDDEEEEEEDDDCB7655555;
defparam prom_inst_3.INIT_RAM_23 = 256'h3347ABCDDEEECB9738A56BCBCEFFFFEEFFECBCCA3BCCDDFFEEEEDDDCB9755555;
defparam prom_inst_3.INIT_RAM_24 = 256'h33468ACDDDEEDBA989966BCCDDFFFFEEFFCBBCB96BBCDEFFEEEEDDDCB8555555;
defparam prom_inst_3.INIT_RAM_25 = 256'h333589BDDEEEEDBAAAA89BCCDEEFFFEEEEDCBCCABCCDEFFFFEEDDDCCB8655555;
defparam prom_inst_3.INIT_RAM_26 = 256'h334679ACDDDEEEEDCCCDBBCCDEEFFFFEFEDDEDCCCDEFFFFEEEEDDCCCB8655555;
defparam prom_inst_3.INIT_RAM_27 = 256'h333479ABCCDDEEEEEEDDDBCDEEFFFFFEEDDEEFEEFFFFFEEEEEDDDDCCB8555555;
defparam prom_inst_3.INIT_RAM_28 = 256'h3334679ABCCDDDEEEEEDDCCDEEFFFFFEEEEEFFFFFFFFEEEEEDDDDDCCB8655555;
defparam prom_inst_3.INIT_RAM_29 = 256'h3334678ABCCCDDEEEEEEDCCEEFFFFFFEEEFFFFFFFFEFFFEEEDDDDCCB96555555;
defparam prom_inst_3.INIT_RAM_2A = 256'h333346689BCCCDDDEEEEDCDEEFFFFFFEEEFFFFFFFEEFEEEEDDDDDCBA76555555;
defparam prom_inst_3.INIT_RAM_2B = 256'h333345679ABCCDDDDEEDCCDEEFFFFFFEEFFFFFFFEEEEEEDDDDDDCCBB86555555;
defparam prom_inst_3.INIT_RAM_2C = 256'h3333346789BCCDCDDDDDCBDEEFFFFEEEEFFFFFFFEEEEDDEEDDCCCBBA86555555;
defparam prom_inst_3.INIT_RAM_2D = 256'h33333355799ABCCCCCDCBBDEEEFFFEEEFFFFFFFFEEEDDDDDDCCBBBB976555555;
defparam prom_inst_3.INIT_RAM_2E = 256'h223333456679ABCCCCCCABCDEEEEEEEEFFFFFEEEEDDDDCCCCBBBBBA865555555;
defparam prom_inst_3.INIT_RAM_2F = 256'h2223333555569ABBBCCC9ACDEEEEEEEEEFFEEEEEDDDCCBBBABBBAA9865555555;
defparam prom_inst_3.INIT_RAM_30 = 256'h22233345555679BBBBCCA9CDDEEEEEDDFFEEEEEEDDCB9888899A999765555555;
defparam prom_inst_3.INIT_RAM_31 = 256'h222233356677AABCCBCCA89ADDDDCCEFFFEEEDEEDCA987788888899755555555;
defparam prom_inst_3.INIT_RAM_32 = 256'h22233455455678AABBCCB899BCCCCDFFFEEEEEDDDCB8777889999A8665555555;
defparam prom_inst_3.INIT_RAM_33 = 256'h223343444458877999BBBBA9ABCCDEFEEEEEEEEDDDC988889AAAA99755555555;
defparam prom_inst_3.INIT_RAM_34 = 256'h233334444446879ABABCBCCCABBCDEEEDDDDDDDDCCCA999AABBA998665555555;
defparam prom_inst_3.INIT_RAM_35 = 256'h3333344444555569ABCCBBCCBABCDDDEEEEEDDDCCCB999A99BBBA87665555555;
defparam prom_inst_3.INIT_RAM_36 = 256'h333344444455555669ABBBBBCBABBCDDEEEEDDCDDCB978899999A87555555555;
defparam prom_inst_3.INIT_RAM_37 = 256'h223344454444445566799AAABA9ABBBCCDDCCCCBAAAAA9A99998887555555555;
defparam prom_inst_3.INIT_RAM_38 = 256'h333344543344454456889AAAA999ABBCCCCCCCBBBA89AAABA778877655555555;
defparam prom_inst_3.INIT_RAM_39 = 256'h32244443333444445566878887789ABBCCCCCAB98AAAA9AAAA78887655555555;
defparam prom_inst_3.INIT_RAM_3A = 256'h223444333344334545556678A988889ABBBA9989889AAA998798887655555555;
defparam prom_inst_3.INIT_RAM_3B = 256'h22344443344434444455569ABBAA9878788787869899AA987788887655555555;
defparam prom_inst_3.INIT_RAM_3C = 256'h22344443444343533455569ABBBBAA8867756767798998887899887655555555;
defparam prom_inst_3.INIT_RAM_3D = 256'h223444334434444334555779ABBBBB9877765667878898998999987655555555;
defparam prom_inst_3.INIT_RAM_3E = 256'h223444334434353344446569999BBA97666656668788999A99A9988765555555;
defparam prom_inst_3.INIT_RAM_3F = 256'h2234443343434433333354577779A986555656688889AAAAAAAA988765555555;

endmodule //PixelsROM
