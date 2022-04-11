module top (
        output LED_R,
        output LED_G,
        output LED_B,
        output LED_DATA,LED_SCK,LED_RCK,

        output LCD_CLK,
        output LCD_HSYNC,
        output LCD_VSYNC,
        output LCD_DEN,
        output [4:0] LCD_R,
        output [5:0] LCD_G,
        output [4:0] LCD_B,

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


    wire frame_int;
    reg [1:0] dir;
    reg [1:0] next_dir;
    reg [11:0] vram_addr;
    reg [7:0] vram_data;
    reg vram_ce;
    LcdVga vga (
               .clk_pix(clk_36m),
               .reset(reset),
               .LCD_DEN(LCD_DEN),
               .LCD_CLK(LCD_CLK),
               .LCD_HSYNC(LCD_HSYNC),
               .LCD_VSYNC(LCD_VSYNC),
               .LCD_DATA({LCD_R,LCD_G,LCD_B}),
               .direction(dir),
               .frame_int(frame_int),
               .ram_clk(clk_72m),
               .ram_reset(reset),
               .ram_ce(vram_ce),
               .ram_addr(vram_addr),
               .ram_data({8'hf0,vram_data})
           );

    wire key_pressed;
    Debouncer d(.clk(clk_27m),.btn(KEY),.out(key_pressed));
    // defparam d.FREQ = 72000000;

    always @(posedge key_pressed) begin
        next_dir <= next_dir + 1;
    end

    always @(posedge frame_int or negedge reset) begin
        if (!reset) begin
            dir <= 0;
        end
        else if (!KEY) dir <= next_dir;
    end


    reg [7:0] tx_buf;
    wire [7:0] rx_buf;
    wire rx_ready;
    wire rx_error;
    wire rx_busy;
    wire tx_busy;
    reg tx_ready;
    uart_rx urx(
                .clk(clk_72m),
                .reset(reset),
                .prescale(72*1000*1000/115200),
                .rx(uart_rx),
                .rx_data(rx_buf),
                .rx_ready(rx_ready),
                .rx_error(rx_error),
                .rx_busy(rx_busy)
            );
    uart_tx utx(
                .clk(clk_72m),
                .reset(reset),
                .prescale(72*1000*1000/115200),
                .tx(uart_tx),
                .tx_data(tx_buf),
                .tx_ready(tx_ready),
                .tx_busy(tx_busy)
            );
    always @(posedge clk_72m ) begin
        tx_ready <= rx_ready;
        tx_buf <= rx_buf;
        char_ready <= rx_ready;
        char_buf <= rx_buf;
    end

    reg [7:0] char_buf;
    reg char_ready;

    always @(posedge clk_72m) begin
        if (!reset) begin
            vram_addr <= 0;
        end else begin
            if (char_ready) begin
                vram_addr <= vram_addr < 750 ? vram_addr + 1 : 0;
                vram_data <= char_buf;
                vram_ce <= 1;
            end else begin
                vram_ce <= 0;
            end
        end
    end

    // assign LED_R=~tx_ready;
    // assign LED_G=~tx_busy;
    // assign LED_B=~rx_error;

    reg slow_clk;
    reg [31:0] counter;
    always @(posedge clk_27m) begin
        if (counter == 27_000_000/4) begin
            slow_clk <= !slow_clk;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    wire [15:0] write_bus;
    wire [15:0] read_bus;
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
            .dbg_state({LED_B,LED_G,LED_R}),
            .dbg(debug)
        );

    MCU_RAM ram(
                .clk(slow_clk),
                .reset(~reset),
                .ce(mem_en),
                .oce(!write_en),
                .wre(write_en),
                .ad(addr_bus),
                .din(write_bus),
                .dout(read_bus)
            );

    always @(posedge slow_clk) begin
        mem_ready <= mem_en;
    end

    wire [15:0] pc,ir;
    wire [31:0] debug;

    SevenSegLed debug_led(
                    .clk(clk_72m),
                    .data(debug),
                    .LED_DATA(LED_DATA),
                    .LED_SCK(LED_SCK),
                    .LED_RCK(LED_RCK)
                );
endmodule
