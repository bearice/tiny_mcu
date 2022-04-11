module MCU  (
        input clk,reset,
        input [15:0] data_in,
        input mem_ready,
        output reg [15:0] addr_bus,
        output reg mem_en,write_en,
        output reg [15:0] data_out,
        output [2:0] dbg_state,
        output [31:0] dbg
    );
    localparam ST_FETCH = 3'b000;
    localparam ST_DECODE = 3'b001;
    localparam ST_EXECUTE = 3'b010;
    localparam ST_WRITEBACK = 3'b100;
    localparam ST_DONE = 3'b111;

    localparam REG_PC = 4'b0100;
    localparam REG_SP = 4'b0101;
    localparam REG_FLG = 4'b0110;
    localparam REG_CTL = 4'b0111;

    localparam OP_JUMP = 4'b1000;
    localparam OP_LOAD = 4'b1001;
    localparam OP_MOVE = 4'b1010;

    assign dbg_state = ~state;
    assign dbg = {r[REG_PC],ir};

    reg [2:0] state;
    reg [15:0] ir;
    reg [15:0] r[8];
    wire [3:0] op = ir[3:0];
    wire is_alu = !op[3];
    wire [3:0] x = ir[7:4];
    wire [3:0] y = ir[11:8];
    wire [3:0] z = ir[15:12];

    wire [3:0] flags = r[REG_FLG][3:0];

    reg [15:0] alu_op1 = x[3] ? x[2:0] : r[x[2:0]];
    reg [15:0] alu_op2 = y[3] ? y[2:0] : r[y[2:0]];
    wire [15:0] alu_out;
    wire [3:0] alu_flags;
    ALU alu(
            .op(op),
            .in1(alu_op1),
            .in2(alu_op2),
            .flags(alu_flags),
            .out(alu_out)
        );

    reg mem_read,mem_write,jmp_en,decr_y,incr_z;
    reg [15:0] out; // instruction result for writeback
    reg [15:0] new_pc;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            int i;
            for(i=0;i<8;i=i+1) begin
                r[i] <= 0;
            end
            // for(i=0;i<8;i=i+1) begin
            //     r[i+8] <= i;
            // end
            state <= 0;
            ir <= 0;
            mem_read <= 0;
            mem_en <= 0;
            write_en <= 0;
        end else begin
            case(state)
                ST_FETCH: begin
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    incr_z <= 1'b0;
                    decr_y <= 1'b0;
                    jmp_en <= 1'b0;
                    if (mem_ready) begin
                        ir <= data_in;
                        mem_en <= 1'b0;
                        state <= ST_DECODE;
                    end else begin
                        addr_bus <= r[REG_PC];
                        mem_en <= 1'b1;
                        write_en <= 1'b0;
                        state <= ST_FETCH;
                    end
                end
                ST_DECODE:begin
                    if (op == OP_MOVE) begin //MOVE
                        mem_read <= x[0];
                        mem_write <= x[1];
                        incr_z <= x[2];
                        decr_y <= x[3];
                    end else if (op == OP_JUMP) begin //JUMP
                        jmp_en <= ((x&flags)==y)?1'b1:1'b0;
                        out <= z[3] ? z[2:0] : r[z[2:0]];
                    end else if (op == OP_LOAD) begin //LOAD
                        out <= z[3] ? {z[15:8],x,y} : {x,y,z[7:0]};
                    end
                    state <= ST_EXECUTE;
                end
                ST_EXECUTE:begin
                    if (is_alu) begin
                        out <= alu_out;
                        new_pc <= r[REG_PC] + 1;
                        r[REG_FLG][3:0] <= {alu_flags};
                        state <= ST_WRITEBACK;
                    end else if(mem_read) begin
                        if (mem_ready) begin
                            out <= data_in;
                            mem_en <= 1'b0;
                            write_en <= 1'b0;
                            new_pc <= r[REG_PC] + 1;
                            state <= ST_WRITEBACK;
                        end else begin
                            addr_bus <= y[3]?r[y[2:0]]:y[2:0];
                            mem_en <= 1'b1;
                            write_en <= 1'b0;
                            state <= ST_EXECUTE;
                        end
                    end else if (jmp_en) begin
                        new_pc <= out;
                        state <= ST_WRITEBACK;
                    end else begin
                        new_pc <= r[REG_PC] + 1;
                        state <= ST_WRITEBACK;
                    end
                end
                ST_WRITEBACK:begin
                    if(mem_write) begin
                        if (mem_ready) begin
                            mem_en <= 1'b0;
                            state <= ST_DONE;
                        end else begin
                            addr_bus <= r[z[2:0]];
                            data_out <= out;
                            mem_en <= 1'b1;
                            write_en <= 1'b1;
                            state <= ST_WRITEBACK;
                        end
                    end else begin
                        if (z < 4'b0111) r[z[2:0]] <= out;
                        state <= ST_DONE;
                    end
                end
                ST_DONE: begin
                    r[REG_PC] <= new_pc;
                    if(incr_z) r[z] <= r[z] + 1;
                    if(decr_y) r[y] <= r[y] - 1;
                    state <= ST_FETCH;
                end
            endcase
        end
    end
endmodule
