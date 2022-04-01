module pwm(
    input clk,
    input rst,
    input [WIDTH-1:0] threshold,
    input [WIDTH-1:0] max,
    output pwm
);
parameter WIDTH = 16;
reg [WIDTH-1:0] counter;

assign pwm = counter > threshold;

always @ (posedge clk or negedge rst )
begin
    if (!rst)
        counter <= 0;
    else if (counter >= max )
        counter <= 0;
    else
        counter <= counter+1;
end

endmodule