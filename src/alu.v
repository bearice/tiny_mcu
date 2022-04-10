module ALU(
        input [15:0] in1,in2,
        input [2:0] op,
        output [15:0] out,
        output [3:0] flags
    );

    wire z,s,o;
    reg c;
    reg [15:0] val;
    always @(*) begin
        case (op)
            4'b000: {c,val} = in1 + in2;
            4'b001: begin
                val = in1 - in2;
                c = !val[15];
            end
            4'b010: val = in1 * in2;
            4'b011: val = in1 >> in2;
            4'b100: val = in1 & in2;
            4'b101: val = in1 | in2;
            4'b110: val = in1 ^ in2;
            4'b111: val = in1 << in2;
        endcase
    end
    assign o = out[15] ^ out[14];
    assign z = (out == 0)? 1'b1 : 1'b0;
    assign s = out[15];
    assign flags = {c,z,s,o};
    assign out = val;
endmodule
