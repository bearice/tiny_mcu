module top (
        output LED_R,
        output LED_G,
        output LED_B,

        output LCD_CLK,
        output LCD_HYNC,
        output LCD_SYNC,
        output LCD_DEN,
        output [4:0] LCD_R,
        output [5:0] LCD_G,
        output [4:0] LCD_B,

        output uart_tx,
        input uart_rx,

        input clk_27m,
        input reset
    );

    wire clk_144m;
    wire clk_36m;
    Gowin_rPLL pll (
                   .clkout(clk_144m),
                   .clkoutd(clk_36m),
                   .clkin(clk_27m)
               );

    reg [31:0] counter;
    reg [9:0] h;
    always @(posedge clk_27m or negedge reset) begin
        if (!reset) begin
            counter <= 0;
            h <= 0;
        end
        else if (counter < 27000000/200 )
            counter <= counter + 1;
        else begin
            counter <= 0;
            if (h < 800 )h <= h+1;
            else h<=0;
        end
    end

    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    hsv2rgb hsv(
                .r(r), .g(g), .b(b),
                .h(h), .s(255), .v(255)
            );

    led led(
            .clk(clk_27m),
            .rst(reset),

            .r(r),
            .g(g),
            .b(b),

            .LED_R(LED_R),
            .LED_G(LED_G),
            .LED_B(LED_B)
        );

    wire frame_int;
    reg signed [15:0] offset_x;
    reg signed [15:0] offset_y;
    reg signed [15:0] dir_x;
    reg signed [15:0] dir_y;
    LcdVga vga (
               .clk_sys(clk_144m),
               .clk_pix(clk_36m),
               .reset(reset),

               .LCD_DEN(LCD_DEN),
               .LCD_CLK(LCD_CLK),
               .LCD_HSYNC(LCD_HYNC),
               .LCD_VSYNC(LCD_SYNC),
               .LCD_DATA({LCD_R,LCD_G,LCD_B}),
               .frame_int(frame_int),
               .ram_clk(clk_36m),
               .ram_reset(reset),
               .ram_ce(0)
           );

    // always @(posedge frame_int or negedge reset) begin
    //     if (!reset) begin
    //         offset_x <= 123;
    //         offset_y <= 234;
    //         dir_x <= 1;
    //         dir_y <= 1;
    //     end else begin
    //         if (offset_x < 0) dir_x <= 3;
    //         else if (offset_x >= 800-64) dir_x <= -1;

    //         offset_x <= offset_x+dir_x;

    //         if (offset_y < 0) dir_y <= 2;
    //         else if (offset_y > 480-64) dir_y <= -1;

    //         offset_y <= offset_y+dir_y;
    //     end
    // end
    //reg [7:0] tx_buf;
    //wire [7:0] rx_buf;

    //uart(
    //    .clk(clk_144m),
    //    .reset(reset),
    //    .tx(uart_tx),
    //    .rx(uart_rx),
    //    .tx_data(tx_buf),
    //    .rx_data(rx_buf)
    //);

endmodule
