module uart_tx (
        input clk,
        input reset,
        input [31:0] prescale,

        input tx_ready,
        input [7:0] tx_data,
        output reg tx,
        output reg tx_busy
    );

    localparam TX_IDLE = 0;
    localparam TX_START = 1;
    localparam TX_DATA = 2;
    localparam TX_STOP = 3;
    localparam TX_CLEAN = 4;

    reg [7:0] data;
    reg [2:0] state;
    reg [2:0] bit_count;
    reg [31:0] counter;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= TX_IDLE;
            bit_count <= 0;
            counter <= 0;
            data <= 0;
            tx_busy <= 1'b0;
        end else begin
            case(state)
                TX_IDLE: begin
                    tx <= 1'b1;
                    counter <= 0;
                    if(tx_ready) begin
                        data <= tx_data;
                        tx_busy <= 1'b1;
                        state <= TX_START;
                    end else begin
                        state <= TX_IDLE;
                    end
                end
                TX_START: begin
                    tx <= 1'b0;
                    if (counter < prescale-1) begin
                        counter <= counter + 1;
                        state <= TX_START;
                    end else begin
                        bit_count <= 0;
                        counter <= 0;
                        state <= TX_DATA;
                    end
                end
                TX_DATA: begin
                    tx <= data[bit_count];
                    if (counter < prescale-1) begin
                        counter <= counter + 1;
                        state <= TX_DATA;
                    end else begin
                        counter <= 0;
                        if (bit_count<7) begin
                            bit_count <= bit_count + 1;
                            state <= TX_DATA;
                        end else begin
                            state <= TX_STOP;
                        end
                    end
                end
                TX_STOP: begin
                    tx <= 1'b1;
                    if (counter < prescale-1) begin
                        counter <= counter + 1;
                        state <= TX_STOP;
                    end else begin
                        counter <= 0;
                        state <= TX_CLEAN;
                    end
                end
                TX_CLEAN: begin
                    tx_busy <= 1'b0;
                    state <= TX_IDLE;
                end
                default: begin
                    state <= TX_IDLE;
                end
            endcase
        end
    end
endmodule

module uart_rx (
        input clk,
        input reset,
        input [31:0] prescale,

        input rx,
        output reg [7:0] rx_data,
        output reg rx_busy,
        output reg rx_error,
        output reg rx_ready
    );

    localparam RX_IDLE = 0;
    localparam RX_START = 1;
    localparam RX_DATA = 2;
    localparam RX_STOP = 3;
    localparam RX_CLEAN = 4;

    reg sync;
    reg rxd;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            sync<=1;
            rxd<=1;
        end else begin
            sync <= rx;
            rxd <= sync;
        end
    end

    reg [7:0] data;
    reg [2:0] state;
    reg [2:0] bit_count;
    reg [31:0] counter;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= RX_IDLE;
            bit_count <= 0;
            counter <= 0;
            data <= 0;
            rx_busy <= 0;
            rx_error <= 3'b000;
            rx_ready <= 0;
            rx_data <= 0;
        end else begin
            case(state)
                RX_IDLE: begin
                    if(rxd == 1'b0) begin
                        counter <= 0;
                        rx_busy <= 1'b1;
                        state <= RX_START;
                    end else begin
                        rx_busy <= 1'b0;
                    end
                end
                RX_START: begin
                    if (counter < (prescale-1>>1)) begin
                        counter <= counter + 1;
                        state <= RX_START;
                    end else begin
                        if (rxd == 1'b0) begin
                            counter <= 0;
                            bit_count <= 0;
                            data <= 0;
                            state <= RX_DATA;
                        end else begin
                            state <= RX_IDLE;
                            rx_error <= 1'b1;
                        end
                    end
                end
                RX_DATA: begin
                    if (counter < prescale-1) begin
                        counter <= counter + 1;
                        state <= RX_DATA;
                    end else begin
                        data[bit_count] <= rxd;
                        counter <= 0;
                        if (bit_count < 7) begin
                            bit_count <= bit_count + 1;
                            state <= RX_DATA;
                        end else begin
                            bit_count <= 0;
                            state <= RX_STOP;
                        end
                    end
                end
                RX_STOP: begin
                    if (counter < prescale-1) begin
                        counter <= counter + 1;
                        state <= RX_STOP;
                    end else begin
                        rx_data <= data;
                        rx_ready <= 1'b1;
                        counter <= 0;
                        state <= RX_CLEAN;
                    end
                end
                RX_CLEAN: begin
                    rx_busy <= 1'b0;
                    rx_ready <= 1'b0;
                    rx_error <= 1'b0;
                    state <= RX_IDLE;
                end
                default: begin
                    state <= RX_IDLE;
                end
            endcase
        end
    end
endmodule
