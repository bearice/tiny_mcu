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
    localparam OP_LUI  = 4'b1100;
    localparam OP_JAL  = 4'b1101;
    localparam OP_JR   = 4'b1110;

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

    // Registers for new instructions
    reg [15:0] direct_jump_target;
    reg save_link_address_for_jal;
    reg [15:0] link_address_content;
    reg pc_override_en;

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
                    jmp_en <= 1'b0; // Default for conditional JMP
                    pc_override_en <= 1'b0; // Default for JAL/JR/unconditional JMP
                    save_link_address_for_jal <= 1'b0; // Default for JAL
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
                    // Default settings for control signals, overridden by instruction types
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    // jmp_en is already reset to 0 in ST_FETCH or beginning of ST_DECODE if needed
                    // pc_override_en is already reset to 0 in ST_FETCH or beginning of ST_DECODE
                    // save_link_address_for_jal is already reset to 0 in ST_FETCH or beginning of ST_DECODE

                    if (op == OP_MOVE) begin //MOVE
                        mem_read <= x[0]; // x[0] is mem_read flag
                        mem_write <= x[1]; // x[1] is mem_write flag
                        incr_z <= x[2]; // x[2] is incr_z flag
                        decr_y <= x[3]; // x[3] is decr_y flag
                    end else if (op == OP_JUMP) begin // Conditional JMP
                        if (((x&flags)==y)) begin
                            jmp_en <= 1'b1;
                            // 'out' register will store the jump target address
                            // If Z[3] is 1, use Z[2:0] as immediate, otherwise use content of R[Z[2:0]]
                            out <= z[3] ? {13'b0, z[2:0]} : r[z[2:0]];
                        end else begin
                            jmp_en <= 1'b0;
                        end
                    end else if (op == OP_LOAD) begin //LOADl/LOADh
                        // imm8 is {Y field, X field} from instruction word
                        // ir is {ZZZZ YYYY XXXX AAAA}
                        // AAAA = op (ir[3:0])
                        // XXXX = x (ir[7:4])
                        // YYYY = y (ir[11:8])
                        // ZZZZ = z (ir[15:12])
                        // z[3] is the high/low selector, z[2:0] is the register index
                        reg [7:0] imm8_val_load; // Renamed to avoid conflict if imm8_val was a module reg
                        imm8_val_load = {ir[11:8], ir[7:4]}; // {Y, X}
                        if (z[3]) begin // LOADh - load into high byte
                            out <= {imm8_val_load, r[z[2:0]][7:0]};
                        end else begin // LOADl - load into low byte
                            out <= {r[z[2:0]][15:8], imm8_val_load};
                        end
                    end else if (op == OP_LUI) begin // LUI Rz, imm8
                        reg [7:0] imm8_val_lui;
                        imm8_val_lui = {ir[11:8], ir[7:4]}; // imm8 = {Y,X}
                        out <= {imm8_val_lui, 8'h00};
                        // is_alu, mem_read, mem_write, jmp_en, pc_override_en should be false
                    end else if (op == OP_JAL) begin // JAL imm8_offset
                        save_link_address_for_jal <= 1'b1;
                        link_address_content <= r[REG_PC] + 1; // PC of JAL + 1

                        reg [7:0] imm8_offset_jal;
                        reg [15:0] signed_offset_jal;
                        imm8_offset_jal = {ir[11:8], ir[7:4]}; // {Y,X}
                        signed_offset_jal = {{8{imm8_offset_jal[7]}}, imm8_offset_jal}; // Sign-extend

                        direct_jump_target <= r[REG_PC] + signed_offset_jal;
                        pc_override_en <= 1'b1;
                        jmp_en <= 1'b0; // Ensure conditional jump is not active
                    end else if (op == OP_JR) begin // JR Rx
                        // Rx is specified by X field (ir[7:4])
                        // Assuming ir[7] (X[3]) is 0 for register mode
                        direct_jump_target <= r[ir[7:4]]; // Target is content of Rx (r[x[2:0]])
                        pc_override_en <= 1'b1;
                        jmp_en <= 1'b0; // Ensure conditional jump is not active
                    end
                    // For ALU ops, is_alu is true, they set 'out' and go to WRITEBACK
                    // For other ops, they set 'out' if needed, and go to EXECUTE then WRITEBACK
                    state <= ST_EXECUTE;
                end
                ST_EXECUTE:begin
                    if (is_alu) begin
                        out <= alu_out; // ALU result
                        r[REG_FLG][3:0] <= alu_flags; // Update flags
                        new_pc <= r[REG_PC] + 1; // Increment PC
                        state <= ST_WRITEBACK;
                    end else if (mem_read) begin // For MOVE [Ry], Rz or POP
                        if (mem_ready) begin
                            out <= data_in; // Data from memory
                            mem_en <= 1'b0;
                            write_en <= 1'b0;
                            new_pc <= r[REG_PC] + 1;
                            state <= ST_WRITEBACK;
                        end else begin
                            // y[3] determines if y is immediate or reg for address
                            addr_bus <= y[3] ? {13'b0, y[2:0]} : r[y[2:0]];
                            mem_en <= 1'b1;
                            write_en <= 1'b0; // Read operation
                            state <= ST_EXECUTE; // Wait for mem_ready
                        end
                    end else if (jmp_en) begin // Conditional JMP (OP_JUMP)
                        new_pc <= out; // Target address was placed in 'out' during DECODE
                        state <= ST_WRITEBACK; // JMP does not write to general regs other than PC
                                             // If it needs to write R7 (like JAL), it would need a different path
                    end else if (pc_override_en) begin // JAL, JR
                        new_pc <= direct_jump_target; // Target address from DECODE
                        state <= ST_WRITEBACK; // JAL needs to write R7, JR does not write regs other than PC
                    end else begin // Default: instruction that don't branch or access memory (e.g. LUI, MOVE R,R)
                        new_pc <= r[REG_PC] + 1;
                        state <= ST_WRITEBACK;
                    end
                end
                ST_WRITEBACK:begin
                    if (mem_write) begin // For MOVE Ry, [Rz] or PUSH
                        if (mem_ready) begin
                            mem_en <= 1'b0; // Disable memory after write
                            state <= ST_DONE;
                        end else begin
                            // z[3] determines if z is immediate or reg for address
                            addr_bus <= z[3] ? {13'b0, z[2:0]} : r[z[2:0]];
                            data_out <= out; // Data to write to memory ('out' was set in DECODE or EXECUTE for MOVE)
                            mem_en <= 1'b1;
                            write_en <= 1'b1; // Write operation
                            state <= ST_WRITEBACK; // Wait for mem_ready
                        end
                    end else begin // Not a memory write, could be ALU op, LOAD, LUI, JAL (for R7)
                        // Write result to register Z if Z is not R4,R5,R6,R7 (PC,SP,FLG,CTL)
                        // For LUI, 'out' has the value, z is ir[15:12]. z[2:0] is reg index.
                        // z[3] must be 0 for LUI to target R0-R6.
                        // This condition allows writing to R0-R3 (A,B,C,D).
                        // To allow R0-R6 (excluding R7/CTL): z < REG_CTL (4'b0111)
                        if (z[3] == 1'b0 && z[2:0] < REG_CTL[2:0]) begin // Check if Z is R0-R6
                           // For LUI, op is OP_LUI. For LOAD, op is OP_LOAD. For ALU, is_alu is true.
                           // These instructions already set 'out'.
                           // Conditional JMP (jmp_en) does not write to Rz.
                           // JAL (pc_override_en) writes R7/CTL below.
                           // JR (pc_override_en) does not write to Rz.
                           // MOVE R,R sets 'out' in decode (not yet implemented fully, but 'out' would be Ry)
                           // This check is primarily for ALU, LOAD, LUI, and MOVE R,R
                           // For LUI, Z field is ir[15:12]. Z[3] needs to be 0.
                           // For ALU, Z field is ir[15:12].
                           // For LOAD, Z field is ir[15:12].
                           if (is_alu || op == OP_LOAD || op == OP_LUI || (op == OP_MOVE && !mem_read && !mem_write)) begin
                               r[z[2:0]] <= out;
                           end
                        end

                        if (save_link_address_for_jal) begin // Specifically for JAL
                            r[REG_CTL] <= link_address_content;
                        end
                        state <= ST_DONE;
                    end
                end
                ST_DONE: begin
                    r[REG_PC] <= new_pc; // Update PC
                    // Handle post-increment/decrement for PUSH/POP (from MOVE instruction)
                    if(incr_z) r[z[2:0]] <= r[z[2:0]] + 1; // z field for PUSH's stack pointer
                    if(decr_y) r[y[2:0]] <= r[y[2:0]] - 1; // y field for POP's stack pointer
                    state <= ST_FETCH;
                end
            endcase
        end
    end
endmodule
