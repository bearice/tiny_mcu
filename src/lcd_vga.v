module LcdVga (
        input clk_pix,
        input reset,

        output LCD_CLK,
        output reg LCD_DEN,
        output reg LCD_HSYNC,
        output reg LCD_VSYNC,
        output reg [15:0] LCD_DATA,
        output reg frame_int,

        input [1:0] direction,
        input vram_clk,
        input vram_reset,
        input vram_ce,
        input vram_oce,
        input vram_we,
        input [11:0] vram_addr,
        input [15:0] vram_data_in,
        output [15:0] vram_data_out
    );
    localparam H_BackPorch = 16'd46;
    localparam H_Pluse = 16'd1;
    localparam H_Data = 16'd800;
    localparam H_FrontPorch= 16'd294; //was 210, use 294 to make 60Hz frame rate @clk 36Mhz

    localparam V_BackPorch = 16'd23;
    localparam V_Pluse = 16'd5;
    localparam V_Data = 16'd480;
    localparam V_FrontPorch= 16'd23;

    localparam H_Max = H_Data + H_BackPorch + H_FrontPorch;
    localparam V_Max = V_Data + V_BackPorch + V_FrontPorch;

    localparam pipeline_length = 6;

    reg [15:0] p0_x;
    reg [15:0] p0_y;

    wire x_en = p0_x >= H_BackPorch && p0_x < H_Max-H_FrontPorch;
    wire y_en = p0_y >= V_BackPorch && p0_y < V_Max-V_FrontPorch;

    assign LCD_CLK = ~clk_pix; //clk_pix is inverted to avoid setup time issue

    // phase 0: clock generation
    always @( posedge clk_pix or negedge reset ) begin
        if( !reset ) begin
            p0_y <= 0;
            p0_x <= 0;
            frame_int <=0;
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
            LCD_HSYNC <= p0_x > H_Pluse;
            LCD_VSYNC <= p0_y > V_Pluse;
            LCD_DEN <= x_en & y_en;
            frame_int <= p0_y == V_Data + V_BackPorch;

            p00_x <= p0_x-H_BackPorch + pipeline_length - 1; // if we have a N stage pipeline for each pixel, we need to add N-1 to x in advance.
            p00_y <= p0_y-V_BackPorch; // line number doesnt need to mangle because pipeline_length is smaller than V_FrontPorch
        end
    end

    // phase 0.5: map cordinates
    localparam FontWidth = 8;
    localparam FontHeight = 16;

    reg [15:0] p00_x;
    reg [15:0] p00_y;
    always @(posedge clk_pix) begin
        p1_en <= p00_x<H_Data && p00_y<V_Data;
        //rotate to direction
        case (direction)
            0: begin
                p1_x <= p00_x;
                p1_y <= p00_y;
                p1_cpl <= H_Data/FontWidth;
            end
            1: begin
                p1_x <= (V_Data-1)-(p00_y);
                p1_y <= p00_x;
                p1_cpl <= V_Data/FontWidth;
            end
            2: begin
                p1_x <= (H_Data-1)-(p00_x);
                p1_y <= (V_Data-1)-(p00_y);
                p1_cpl <= H_Data/FontWidth;
            end
            3: begin
                p1_x <= (p00_y);
                p1_y <= (H_Data-1)-(p00_x);
                p1_cpl <= V_Data/FontWidth;
            end
        endcase
    end



    // phase1: map pixel to text address
    reg [15:0] p1_x;
    reg [15:0] p1_y;
    reg [15:0] p1_cpl; // char per line
    reg p1_en;
    always @(posedge clk_pix) begin
        if (p1_en) begin
            p2_en <= 1;
            p2_x <= p1_x;
            p2_y <= p1_y;
            p2_addr <= (p1_x >> 3) + ((p1_y >> 4) * p1_cpl);
        end else
            p2_en <= 0;
    end

    // phase2: read text address, map to pixel address
    reg p2_en;
    reg [15:0] p2_x;
    reg [15:0] p2_y;
    reg [11:0] p2_addr; //Address of the text ram
    wire [15:0] p2_data; //Data from the text ram
    VRam ram (
             //read on port b
             .clkb(~clk_pix), // ram & rom need half clock to read from memory, so invert the clock.
             .resetb(~reset), // reset is high active, input is low active, so invert the reset.
             .adb(p2_addr),
             .doutb(p2_data),
             .dinb(16'b0),
             .ceb(p2_en),
             .oceb(p2_en),
             .wreb(1'b0),
             //write on port a
             .clka(vram_clk),
             .reseta(~vram_reset),
             .cea(vram_ce),
             .ocea(vram_oce),
             .wrea(vram_we),
             .dina(vram_data_in),
             .douta(vram_data_out),
             .ada(vram_addr)
         );
    always @(posedge clk_pix) begin
        if (p2_en) begin
            p3_en <= 1;
            p3_addr <= {p2_data[6:0], p2_y[3:0], p2_x[2:0]};
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
    FontRom font (
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
    ColorPalette color_palette (
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
