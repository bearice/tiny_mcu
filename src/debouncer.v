module Debouncer(
        input clk,
        input btn,
        output reg out
    );
    parameter FREQ = 27*000*000; //27MHz
    parameter TIME = 3; //ms
    localparam MAX = FREQ/1000*TIME;
    localparam WIDTH = $clog2(MAX);

    reg [WIDTH-1:0] counter;
    reg sync;
    reg status;
    wire idle = sync == status;

    always @(posedge clk) begin
        sync <= btn;
        out <= status;
        if (idle) begin
            counter <= 0;
        end else if (counter == MAX) begin
            status <= ~status;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
