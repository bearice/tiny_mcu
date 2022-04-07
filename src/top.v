module top (
        output LCD_CLK,
        output LCD_HSYNC,
        output LCD_VSYNC,
        output LCD_DEN,
        output [4:0] LCD_R,
        output [5:0] LCD_G,
        output [4:0] LCD_B,
        output [5:0] LED,
        output LED_DATA,LED_SCK,LED_RCK,

        output uart_tx,
        input uart_rx,
        input KEY,
        input clk_27m,
        input reset
    );

    wire clk_72m;
    wire clk_36m;
    Gowin_rPLL pll (
                   .clkout(clk_72m),
                   .clkoutd(clk_36m),
                   .clkin(clk_27m)
               );

    reg slow_clk;
    reg [31:0] counter;
    always @(posedge clk_27m) begin
        if (counter == 27_000_000/400) begin
            slow_clk <= !slow_clk;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    wire [31:0] debug;
    wire [15:0] write_bus;
    wire [15:0] read_bus = vram_ce ? vram_out : ram_out;
    wire [15:0] addr_bus;
    wire mem_en;
    wire write_en;
    reg mem_ready;

    MCU mcu(
            .clk(slow_clk),
            .reset(reset),
            .data_in(read_bus),
            .data_out(write_bus),
            .mem_ready(mem_ready),
            .addr_bus(addr_bus),
            .mem_en(mem_en),
            .write_en(write_en),
            .dbg_state(LED[2:0]),
            .dbg(debug)
        );

    assign LED[3] = ~slow_clk;
    assign LED[4] = ~mem_en;
    assign LED[5] = ~write_en;
    // assign debug = {addr_bus,read_bus};

    wire ram_ce = addr_bus[15:12] == 4'b0000 & mem_en;
    wire ram_oce = ram_ce & ~write_en;
    wire ram_we = ram_ce & write_en;
    wire [15:0] ram_out;
    MCU_RAM ram(
                .clk(~slow_clk),
                .reset(~reset),
                .ce(ram_ce),
                .oce(ram_oce),
                .wre(ram_we),
                .ad(addr_bus[11:0]),
                .din(write_bus),
                .dout(ram_out)
            );

    always @(negedge slow_clk) begin
        mem_ready <= mem_en;
    end

    wire vram_ce = addr_bus[15:12] == 4'b0001 & mem_en;
    wire vram_oce = vram_ce & ~write_en;
    wire vram_we = vram_ce & write_en;
    wire [15:0] vram_out;
    LcdVga vga (
               .clk_pix(clk_36m),
               .reset(reset),
               .LCD_DEN(LCD_DEN),
               .LCD_CLK(LCD_CLK),
               .LCD_HSYNC(LCD_HSYNC),
               .LCD_VSYNC(LCD_VSYNC),
               .LCD_DATA({LCD_R,LCD_G,LCD_B}),
               .direction(2'b0),
               .frame_int(),
               .vram_clk(~slow_clk),
               .vram_reset(reset),
               .vram_ce(vram_ce),
               .vram_oce(vram_oce),
               .vram_we(vram_we),
               .vram_addr(addr_bus[11:0]),
               .vram_data_in(write_bus),
               .vram_data_out(vram_out)
           );


    SevenSegLed debug_led(
                    .clk(clk_72m),
                    .data(debug),
                    .LED_DATA(LED_DATA),
                    .LED_SCK(LED_SCK),
                    .LED_RCK(LED_RCK)
                );
endmodule
