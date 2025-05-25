module ALU(
        input [15:0] in1,in2,
        input [3:0] op,
        output [15:0] out,
        output [3:0] flags
    );

    wire z,s; // o is now a reg
    reg c, o; // c was already reg, o is now reg
    reg [15:0] val;

    always @(*) begin
        // Default values for c and o for operations that don't set them
        c = 1'b0;
        o = 1'b0;
        val = 16'b0; // Initialize val to prevent latches in all paths

        case (op)
            4'b000: begin // ADD
                {c,val} = {1'b0,in1} + {1'b0,in2}; // c is carry-out
                o = (in1[15] == in2[15]) && (val[15] != in1[15]);
            end
            4'b001: begin // SUB
                // val = in1 - in2; 
                // c is borrow flag (1 if borrow occurred, i.e. in1 < in2 unsigned)
                // o is (in1[15] == in2[15]) && (val[15] != in1[15])
                reg no_borrow_temp;
                {no_borrow_temp, val} = {1'b0,in1} + {1'b0,~in2} + 17'b1; 
                c = ~no_borrow_temp; // c is borrow
                o = (in1[15] == in2[15]) && (val[15] != in1[15]); // Specified overflow for SUB
            end
            4'b010: begin // MUL
                val = in1 * in2;
                c = 1'b0; 
                o = 1'b0; 
            end
            4'b011: begin // SHL
                val = in1 << in2;
                c = 1'b0; 
                o = 1'b0;
            end
            4'b100: begin // AND
                val = in1 & in2;
                c = 1'b0;
                o = 1'b0;
            end
            4'b101: begin // OR
                val = in1 | in2;
                c = 1'b0;
                o = 1'b0;
            end
            4'b110: begin // XOR
                val = in1 ^ in2;
                c = 1'b0;
                o = 1'b0;
            end
            4'b111: begin // SHR
                val = in1 >> in2;
                c = 1'b0; 
                o = 1'b0;
            end
            default: begin // Default case to prevent latches for undefined op codes
                val = 16'hXXXX; // Undefined value
                c = 1'bX;       // Undefined flag
                o = 1'bX;       // Undefined flag
            end
        endcase
    end

    assign z = (out == 0)? 1'b1 : 1'b0;
    assign s = out[15];
    // assign o = out[15] ^ out[14]; // This line is removed as o is calculated in always block
    assign flags = {c,z,s,o};
    assign out = val;
endmodule
