module LcdVga
(
    input clk_sys,   
    input clk_pix,
    input reset,

    output LCD_DEN,
    output LCD_CLK,
    output LCD_HSYNC,
    output LCD_VSYNC,
    output [4:0] LCD_R,
    output [5:0] LCD_G,
    output [4:0] LCD_B,

    input signed [15:0] offset_x_in,
    input signed [15:0] offset_y_in,
    output reg frame_int
);
    localparam H_BackPorch = 46;
    localparam H_Pluse = 1; 
    localparam H_Data = 800;
    localparam H_FrontPorch= 294; //was 210, use 294 to make 60Hz frame rate @clk 36Mhz

    localparam V_BackPorch = 23;
    localparam V_Pluse = 5; 
    localparam V_Data = 480;
    localparam V_FrontPorch= 23;

    localparam H_Max = H_Data + H_BackPorch + H_FrontPorch;
    localparam V_Max = V_Data + V_BackPorch + V_FrontPorch;


    reg signed [15:0] offset_x;
    reg signed [15:0] offset_y;
    reg [15:0] scan_x;
    reg [15:0] scan_y;

    wire signed [15:0] x;
    wire signed [15:0] y;

    wire x_en;
    wire y_en;

    assign x_en = scan_x >= H_BackPorch && scan_x < H_Max-H_FrontPorch;
    assign y_en = scan_y >= V_BackPorch && scan_y < V_Max-V_FrontPorch;

    assign x = x_en ? scan_x - H_BackPorch : 0;
    assign y = y_en ? scan_y - V_BackPorch : 0;

    assign LCD_HSYNC = scan_x > H_Pluse;
    assign LCD_VSYNC = scan_y > V_Pluse;
    assign LCD_DEN = x_en && y_en;
    assign LCD_CLK = ~clk_pix; //clk_pix is inverted to avoid setup time issue

    reg [4:0] r;
    reg [5:0] g;
    reg [4:0] b;

    wire [7:0] hue = y;
    wire [15:0] hue_out;
    Gowin_ROM16 hue2rbg(.ad(hue),.dout(hue_out)); // hsv2rgb is just not fast enough.

    wire is_bmp = (x >= offset_x) && (y >= offset_y) && (x < offset_x+64) && (y < offset_y+64);

//    wire [15:0] bmp_out;
    wire bmp_alpha;
    wire [4:0] bmp_r;
    wire [4:0] bmp_g;
    wire [4:0] bmp_b;
    wire [5:0] oy = is_bmp?y-offset_y:0;
    wire [5:0] ox = is_bmp?x-offset_x:0;
    wire [11:0] bmp_addr = {oy,ox};
    ARGB_Rom pixels(
        .clk(clk_pix), 
        .reset(~reset),
        .ce(1'b1),
        .oce(1'b1),
        .ad(bmp_addr),
        .dout({bmp_alpha,bmp_r,bmp_g,bmp_b})
    );

    always @( posedge clk_pix or negedge reset )begin
        if( !reset ) begin
            scan_y <= 0;
            scan_x <= 0;
            frame_int <=0;
        end else begin 
            offset_x <= offset_x_in;
            offset_y <= offset_y_in;
            if( scan_y == V_Max ) begin
            scan_y <= 0;
                scan_x <= 0;
                frame_int <=1;
            end else if( scan_x == H_Max ) begin
                scan_x <= 0;
                scan_y <= scan_y + 1;
            end else begin
                frame_int <=0;
                scan_x <= scan_x + 1;
                if ( x == 0 || y == 0 || x == H_Data-1 || y == V_Data-1 ) begin // draw a border line at the edge of the screen, to test if any pixel is out of the screen
                    {r,g,b} = 16'hffff;
                end else begin
                    {r,g,b} = is_bmp & bmp_alpha ? {bmp_r,bmp_g,1'b0,bmp_b} : hue_out ;
                end
            end
        end
    end

    assign LCD_R = r;
    assign LCD_G = g;
    assign LCD_B = b;

endmodule
