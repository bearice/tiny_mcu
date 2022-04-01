module uart(
    input clk,
    input reset,
    input [15:0] prescale,

    input we,
    input [7:0] tx_data,
    output tx,
    output tx_busy,
    
    input rx,
    output [7:0] rx_data,
    output rx_busy,
    output rx_error
);

uart_tx(
    .clk(clk),
    .reset(reset),
    .prescale(prescale),

    .we(we),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

uart_rx(
    .clk(clk),
    .reset(reset),
    .prescale(prescale),

    .rx(rx),
    .rx_data(rx_data),
    .rx_busy(rx_busy),
    .rx_error(rx_error)
);

endmodule

module uart_tx(
    input clk,
    input reset,
    input [15:0] prescale,

    input we,
    input [7:0] tx_data,
    output tx,
    output tx_busy
);

reg out;
assign tx = out;

integer i;
always @(posedge clk) begin
    out <= ^tx_data;
end

endmodule

module uart_rx(
    input clk,
    input reset,
    input [15:0] prescale,

    input rx,
    output [7:0] rx_data,
    output rx_busy,
    output rx_error
);

assign rx_busy=rx;
endmodule