module LcdVga
(
    input clk_sys,   
    input clk_pix,
    input reset,

    output LCD_DEN,
    output LCD_CLK,
    output LCD_HSYNC,
    output LCD_VSYNC,
    output reg [15:0] LCD_DATA,
    output reg frame_int,

    input ram_clk,
    input ram_reset,
    input ram_ce,
    input [15:0] ram_data,
    input [11:0] ram_addr

);
    localparam H_BackPorch = 16'sd46;
    localparam H_Pluse = 16'd1; 
    localparam H_Data = 16'sd800;
    localparam H_FrontPorch= 16'sd294; //was 210, use 294 to make 60Hz frame rate @clk 36Mhz

    localparam V_BackPorch = 16'sd23;
    localparam V_Pluse = 16'd5; 
    localparam V_Data = 16'sd480;
    localparam V_FrontPorch= 16'sd23;

    localparam H_Max = H_Data + H_BackPorch + H_FrontPorch;
    localparam V_Max = V_Data + V_BackPorch + V_FrontPorch;

    localparam FontWidth = 8*2; // resolution reduced by 2x, so multiply by 2
    localparam FontHeight = 16*2;

    localparam CharPerLine = H_Data / FontWidth;
    localparam LinePerPage = V_Data / FontHeight;

    reg signed [15:0] p0_x;
    reg signed [15:0] p0_y;

    wire x_en = p0_x >= H_BackPorch && p0_x < H_Max-H_FrontPorch;
    wire y_en = p0_y >= V_BackPorch && p0_y < V_Max-V_FrontPorch;

    assign LCD_HSYNC = p0_x[14:0] > H_Pluse;
    assign LCD_VSYNC = p0_y[14:0] > V_Pluse;
    assign LCD_DEN = x_en & y_en;
    assign LCD_CLK = ~clk_pix; //clk_pix is inverted to avoid setup time issue

    // phase 0: clock generation
    always @( posedge clk_pix or negedge reset ) begin
        if( !reset ) begin
            p0_y <= 0;
            p0_x <= 0;
            frame_int <=0;
            p1_x <= 0;
            p1_y <= 0;
        end else begin 
            if( p0_y == V_Max ) begin
                p0_y <= 0;
                p0_x <= 0;
            end else if( p0_x == H_Max ) begin
                p0_x <= 0;
                p0_y <= p0_y + 1;
            end else begin
                p0_x <= p0_x + 1;
            end
            frame_int <= p0_y == V_Data + V_BackPorch;
            p1_x <= p0_x-H_BackPorch + 5; // we have 5 stage pipeline for each pixel, so add 5.
            p1_y <= p0_y-V_BackPorch;
        end
    end

    // phase1: map pixel to text address
    reg signed [15:0] p1_x;
    reg signed [15:0] p1_y;
    always @(posedge clk_pix) begin
        if (p1_x>=0 && p1_y>=0 && p1_x<H_Data && p1_y<V_Data) begin
            p2_en <= 1;
            p2_x <= p1_x;
            p2_y <= p1_y;
            p2_addr <= (p1_x / FontWidth) + ((p1_y / FontHeight) * CharPerLine);
        end else 
            p2_en <= 0;
    end

    // phase2: read text address, map to pixel address
    reg p2_en;
    reg signed [15:0] p2_x;
    reg signed [15:0] p2_y;
    reg [9:0] p2_addr; //Address of the text ram
    wire [15:0] p2_data; //Data from the text ram
    TextRam ram(
        //read on port b
        .clkb(~clk_pix), // ram & rom need half clock to read from memory, so invert the clock.
        .resetb(~reset), // reset is high active, input is low active, so invert the reset.
        .adb(p2_addr),
        .dout(p2_data),
        .ceb(p2_en),
        .oce(p2_en),
        //write on port a
        .clka(ram_clk),
        .reseta(~ram_reset),
        .cea(ram_ce),
        .din(ram_data),
        .ada(ram_addr)
    );
    always @(posedge clk_pix) begin
        if (p2_en) begin
            p3_en <= 1;
            p3_addr <= {p2_data[6:0], p2_y[4:1], p2_x[3:1]}; // Since we are reducing resolution by 2, both x and y need to be shifted by 1.
            {p3_bg,p3_fg} <= p2_data[15:8];
        end else begin
            p3_en <= 0;
        end
    end

    // phase3: read font data
    reg p3_en;
    reg [3:0] p3_fg;
    reg [3:0] p3_bg;
    reg [13:0] p3_addr;
    reg p3_data;
    FontRom font(
        .clk(~clk_pix),
        .reset(~reset),
        .ad(p3_addr),
        .dout(p3_data),
        .ce(p3_en),
        .oce(p3_en)
    );
    always @(posedge clk_pix) begin
        if (p3_en) begin
            p4_en = 1;
            p4_color <= p3_data ? p3_fg : p3_bg ;
        end else begin
            p4_en = 0;
        end
    end

    // phase4: write pixel
    reg p4_en;
    reg [3:0] p4_color;
    wire [15:0] p4_rgb;
    ColorPalette(
        .dout(p4_rgb),
        .ad(p4_color)
    );
    always @(posedge clk_pix) begin
        if (p4_en) begin
            LCD_DATA <= p4_rgb;
        end else begin
            LCD_DATA <= p0_y;
        end
    end

endmodule
