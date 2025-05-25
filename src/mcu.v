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

    localparam EXCEPTION_VECTOR = 16'h0002; // Exception Handler Address

    // Special Register Parameters
    localparam REG_PC  = 4'd15;
    localparam REG_SP  = 4'd14;
    localparam REG_LR  = 4'd13;
    localparam REG_FLG = 4'd12;

    // OpFamily Codes (ir[15:12])
    localparam OPFAMILY_ALU_RR   = 4'b0000; // Cat 1: ALU Reg-Reg
    localparam OPFAMILY_ALU_RR_EXT=4'b0001; // Cat 1: ALU Reg-Reg (Reserved Extension)
    localparam OPFAMILY_ADDI     = 4'b0010; // Cat 2: ADDI Rx, imm8
    localparam OPFAMILY_ANDI     = 4'b0011; // Cat 2: ANDI Rx, imm8
    localparam OPFAMILY_ORI      = 4'b0100; // Cat 2: ORI  Rx, imm8
    localparam OPFAMILY_XORI     = 4'b0101; // Cat 2: XORI Rx, imm8
    // OpFamilies 0110, 0111 reserved for R-I ALU
    localparam OPFAMILY_LOAD     = 4'b1000; // Cat 3: LOAD Rt, imm4(Rs)
    localparam OPFAMILY_STORE    = 4'b1001; // Cat 3: STORE Rt, imm4(Rs)
    // OpFamilies 1010, 1011 reserved for Mem Ops
    localparam OPFAMILY_LUI      = 4'b1100; // Cat 4: LUI Rt, imm8
    localparam OPFAMILY_JAL      = 4'b1101; // Cat 4: JAL imm12
    localparam OPFAMILY_JR       = 4'b1110; // Cat 4: JR Rs
    localparam OPFAMILY_JCOND    = 4'b1111; // Cat 4: JCOND cond, imm8

    // ALU OpSpecific Codes for OpFamily 0000 (ir[11:8])
    localparam ALU_RR_ADD_SPEC = 4'b0001;
    localparam ALU_RR_SUB_SPEC = 4'b0010;
    localparam ALU_RR_AND_SPEC = 4'b0011;
    localparam ALU_RR_OR_SPEC  = 4'b0100;
    localparam ALU_RR_XOR_SPEC = 4'b0101;
    localparam ALU_RR_SHL_SPEC = 4'b0110;
    localparam ALU_RR_SHR_SPEC = 4'b0111;
    localparam ALU_RR_MUL_SPEC = 4'b1000;

    // Internal 4-bit ALU Operation Codes (for ALU module)
    localparam OP_ADD_4BIT = 4'b0000;
    localparam OP_SUB_4BIT = 4'b0001;
    localparam OP_MUL_4BIT = 4'b0010;
    localparam OP_SHL_4BIT = 4'b0011;
    localparam OP_AND_4BIT = 4'b0100;
    localparam OP_OR_4BIT  = 4'b0101;
    localparam OP_XOR_4BIT = 4'b0110;
    localparam OP_SHR_4BIT = 4'b0111; // Logical shift right

    assign dbg_state = ~state;
    assign dbg = {r[REG_PC], ir};

    reg [2:0] state;
    reg [15:0] ir;
    reg [15:0] r[16];

    // Decoded instruction fields
    wire [3:0] op_family = ir[15:12];
    wire [3:0] op_specific_alu_rr = ir[11:8]; // For OpFamily 0000
    
    wire [3:0] rx_dst_s1_alu_rr = ir[7:4];   // For OpFamily 0000 Rx_dst_s1
    wire [3:0] ry_s2_alu_rr = ir[3:0];     // For OpFamily 0000 Ry_s2

    wire [3:0] rx_dst_s1_alu_ri = ir[11:8];  // For OpFamily 0010-0101 Rx_dst_s1
    wire [7:0] imm8_alu_ri = ir[7:0];      // For OpFamily 0010-0101 Imm8

    wire [3:0] rt_load_store = ir[11:8];   // For LOAD Rt, STORE Rt_data
    wire [3:0] rs_addr_load_store = ir[7:4]; // For LOAD Rs_addr, STORE Rs_addr
    wire [3:0] imm4_load_store = ir[3:0];  // For LOAD/STORE Imm4 offset

    wire [3:0] rt_lui = ir[11:8];          // For LUI Rt
    wire [7:0] imm8_lui = ir[7:0];         // For LUI Imm8

    wire [11:0] imm12_jal = ir[11:0];       // For JAL Offset12
    wire [3:0] rs_addr_jr = ir[11:8];      // For JR Rs_addr
    
    wire [3:0] cond_jcond = ir[11:8];      // For JCOND Cond
    wire [7:0] imm8_jcond = ir[7:0];       // For JCOND Imm8

    // ALU signals
    reg is_alu_op;
    reg [3:0] alu_op_internal;
    reg [15:0] alu_op1;
    reg [15:0] alu_op2;
    wire [15:0] alu_out;
    wire [3:0] alu_flags_out;
    ALU alu(
        .op(alu_op_internal),
        .in1(alu_op1),
        .in2(alu_op2),
        .flags(alu_flags_out),
        .out(alu_out)
    );

    // Control signals
    reg mem_read;
    reg mem_write;
    reg [15:0] new_pc;
    reg pc_override_en;
    reg [15:0] direct_jump_target;
    
    reg needs_reg_writeback;
    reg [3:0] wb_reg_idx;
    reg [15:0] wb_val;

    reg save_link_address; // For JAL
    reg [15:0] link_address_content; // For JAL (PC+1)
    
    reg perform_conditional_jump; // For JCOND
    reg is_true_cond; // Result of condition check for JCOND

    reg invalid_instruction_error;
    reg bad_address_error;

    reg exception_active; // Flag to indicate an exception is being processed
    reg [15:0] captured_pc_for_exception; // Stores PC of the faulting instruction

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            int i;
            for(i=0; i<16; i=i+1) begin
                r[i] <= 0;
            end
            state <= ST_FETCH;
            ir <= 0;
            mem_read <= 1'b0;
            mem_en <= 1'b0;
            write_en <= 1'b0;
            pc_override_en <= 1'b0;
            needs_reg_writeback <= 1'b0;
            is_alu_op <= 1'b0;
            save_link_address <= 1'b0;
            perform_conditional_jump <= 1'b0;
            invalid_instruction_error <= 1'b0;
            bad_address_error <= 1'b0;
            exception_active <= 1'b0;
            captured_pc_for_exception <= 16'b0;
        end else begin
            // Default values for control signals at the start of each cycle
            // invalid_instruction_error and bad_address_error are reset here,
            // before ST_DECODE uses them. Exception_active is managed by state transitions.
            invalid_instruction_error <= 1'b0;
            bad_address_error <= 1'b0;
            is_alu_op <= 1'b0;
            mem_read <= 1'b0;
            mem_write <= 1'b0;
            pc_override_en <= 1'b0;
            needs_reg_writeback <= 1'b0;
            save_link_address <= 1'b0;
            perform_conditional_jump <= 1'b0;
            is_true_cond <= 1'b0; // Default to false

            case(state)
                ST_FETCH: begin
                    if (mem_ready) begin
                        ir <= data_in;
                        mem_en <= 1'b0;
                        write_en <= 1'b0;
                        state <= ST_DECODE;
                    end else begin
                        addr_bus <= pc;
                        mem_en <= 1'b1;
                        write_en <= 1'b0;
                        state <= ST_FETCH;
                    end
                end
                ST_DECODE: begin
                    case (op_family)
                        OPFAMILY_ALU_RR: begin
                            is_alu_op <= 1'b1;
                            needs_reg_writeback <= 1'b1;
                            wb_reg_idx <= rx_dst_s1_alu_rr;
                            alu_op1 <= r[rx_dst_s1_alu_rr];
                            
                            case (op_specific_alu_rr)
                                ALU_RR_ADD_SPEC: alu_op_internal <= OP_ADD_4BIT;
                                ALU_RR_SUB_SPEC: alu_op_internal <= OP_SUB_4BIT;
                                ALU_RR_AND_SPEC: alu_op_internal <= OP_AND_4BIT;
                                ALU_RR_OR_SPEC:  alu_op_internal <= OP_OR_4BIT;
                                ALU_RR_XOR_SPEC: alu_op_internal <= OP_XOR_4BIT;
                                ALU_RR_SHL_SPEC: alu_op_internal <= OP_SHL_4BIT;
                                ALU_RR_SHR_SPEC: alu_op_internal <= OP_SHR_4BIT;
                                ALU_RR_MUL_SPEC: alu_op_internal <= OP_MUL_4BIT;
                                default: begin 
                                    is_alu_op <= 1'b0; 
                                    needs_reg_writeback <= 1'b0; 
                                    invalid_instruction_error <= 1'b1; 
                                end // Invalid OpSpecific
                            endcase
                            
                            if (op_specific_alu_rr == ALU_RR_SHL_SPEC || op_specific_alu_rr == ALU_RR_SHR_SPEC) begin
                                alu_op2 <= {12'b0, r[ry_s2_alu_rr][3:0]}; // Use lower 4 bits of Ry for shift amount
                            end else begin
                                alu_op2 <= r[ry_s2_alu_rr];
                            end
                        end
                        OPFAMILY_ALU_RR_EXT: begin 
                            /* Reserved for future */ 
                            is_alu_op <= 1'b0; 
                            needs_reg_writeback <= 1'b0; 
                            invalid_instruction_error <= 1'b1; 
                        end
                        OPFAMILY_ADDI: begin
                            is_alu_op <= 1'b1;
                            needs_reg_writeback <= 1'b1;
                            wb_reg_idx <= rx_dst_s1_alu_ri;
                            alu_op_internal <= OP_ADD_4BIT;
                            alu_op1 <= r[rx_dst_s1_alu_ri];
                            alu_op2 <= {{8{imm8_alu_ri[7]}}, imm8_alu_ri}; // Sign-extend imm8
                        end
                        OPFAMILY_ANDI: begin
                            is_alu_op <= 1'b1;
                            needs_reg_writeback <= 1'b1;
                            wb_reg_idx <= rx_dst_s1_alu_ri;
                            alu_op_internal <= OP_AND_4BIT;
                            alu_op1 <= r[rx_dst_s1_alu_ri];
                            alu_op2 <= {8'h00, imm8_alu_ri}; // Zero-extend imm8
                        end
                        OPFAMILY_ORI: begin
                            is_alu_op <= 1'b1;
                            needs_reg_writeback <= 1'b1;
                            wb_reg_idx <= rx_dst_s1_alu_ri;
                            alu_op_internal <= OP_OR_4BIT;
                            alu_op1 <= r[rx_dst_s1_alu_ri];
                            alu_op2 <= {8'h00, imm8_alu_ri}; // Zero-extend imm8
                        end
                        OPFAMILY_XORI: begin
                            is_alu_op <= 1'b1;
                            needs_reg_writeback <= 1'b1;
                            wb_reg_idx <= rx_dst_s1_alu_ri;
                            alu_op_internal <= OP_XOR_4BIT;
                            alu_op1 <= r[rx_dst_s1_alu_ri];
                            alu_op2 <= {8'h00, imm8_alu_ri}; // Zero-extend imm8
                        end
                        OPFAMILY_LOAD: begin // LOAD Rt, imm4(Rs_addr)
                            reg [15:0] potential_addr_bus_load; // Use specific name for clarity
                            potential_addr_bus_load = r[rs_addr_load_store] + {{12{1'b0}}, imm4_load_store};
                            addr_bus <= potential_addr_bus_load;
                            
                            if (!((potential_addr_bus_load >= 16'h0000 && potential_addr_bus_load <= 16'h07FF) || 
                                  (potential_addr_bus_load >= 16'h1000 && potential_addr_bus_load <= 16'h13FF))) begin
                                bad_address_error <= 1'b1;
                                needs_reg_writeback <= 1'b0; // No valid data to load
                                mem_read <= 1'b0; // Do not assert mem_read
                            end else begin
                                mem_read <= 1'b1;
                                needs_reg_writeback <= 1'b1;
                                wb_reg_idx <= rt_load_store;
                                // wb_val will be set from data_in in ST_EXECUTE
                            end
                        end
                        OPFAMILY_STORE: begin // STORE Rt_data, imm4(Rs_addr)
                            reg [15:0] potential_addr_bus_store; // Use specific name for clarity
                            potential_addr_bus_store = r[rs_addr_load_store] + {{12{1'b0}}, imm4_load_store};
                            addr_bus <= potential_addr_bus_store;
                            data_out <= r[rt_load_store];
                            needs_reg_writeback <= 1'b0; // Store does not write back to registers

                            if (!((potential_addr_bus_store >= 16'h0000 && potential_addr_bus_store <= 16'h07FF) || 
                                  (potential_addr_bus_store >= 16'h1000 && potential_addr_bus_store <= 16'h13FF))) begin
                                bad_address_error <= 1'b1;
                                mem_write <= 1'b0; // Do not assert mem_write
                            end else begin
                                mem_write <= 1'b1;
                            end
                        end
                        OPFAMILY_LUI: begin // LUI Rt, imm8
                            needs_reg_writeback <= 1'b1;
                            wb_reg_idx <= rt_lui;
                            wb_val <= {imm8_lui, 8'h00};
                        end
                        OPFAMILY_JAL: begin // JAL imm12_offset
                            save_link_address <= 1'b1;
                            link_address_content <= r[REG_PC] + 1;
                            direct_jump_target <= r[REG_PC] + {{4{imm12_jal[11]}}, imm12_jal}; // Sign-extend
                            pc_override_en <= 1'b1;
                        end
                        OPFAMILY_JR: begin // JR Rs_addr
                            direct_jump_target <= r[rs_addr_jr];
                            pc_override_en <= 1'b1;
                        end
                        OPFAMILY_JCOND: begin // JCOND cond, imm8
                            perform_conditional_jump <= 1'b1;
                            if (cond_jcond > 4'b1000) begin // Valid conditions are 0000 to 1000
                                invalid_instruction_error <= 1'b1;
                                perform_conditional_jump <= 1'b0; // Don't attempt jump for invalid condition
                                needs_reg_writeback <= 1'b0; 
                            end
                            // direct_jump_target and pc_override_en set in ST_EXECUTE
                        end
                        default: begin 
                            /* Reserved OpFamily - NOP */ 
                            is_alu_op <= 1'b0; 
                            needs_reg_writeback <= 1'b0; 
                            invalid_instruction_error <= 1'b1; 
                        end
                    endcase

                    // Exception check at the end of DECODE
                    if (invalid_instruction_error || bad_address_error) begin
                        exception_active <= 1'b1;
                        captured_pc_for_exception <= r[REG_PC]; // Capture current PC
                    end
                    // Transition to EXECUTE; EXECUTE will check exception_active
                    state <= ST_EXECUTE;
                end
                ST_EXECUTE: begin
                    if (exception_active) begin
                        // Exception Handling: Override normal execution
                        needs_reg_writeback <= 1'b0;    // Suppress writeback for faulting instruction
                        is_alu_op <= 1'b0;            // Suppress ALU flag updates
                        mem_read <= 1'b0;             // Suppress memory read
                        mem_write <= 1'b0;            // Suppress memory write
                        perform_conditional_jump <= 1'b0; // Suppress conditional jump logic

                        save_link_address <= 1'b1;    // Save faulting PC to LR
                        link_address_content <= captured_pc_for_exception;
                        
                        direct_jump_target <= EXCEPTION_VECTOR; // Jump to handler
                        pc_override_en <= 1'b1;
                        new_pc <= EXCEPTION_VECTOR; // Ensure new_pc is set for ST_DONE

                        state <= ST_WRITEBACK; // Go to WRITEBACK to save LR, then DONE to jump
                    end else begin
                        // Normal Execution Path
                        if (is_alu_op) begin
                            wb_val <= alu_out; // ALU result for writeback
                        end
                        if (mem_read && mem_ready) begin // LOAD
                            wb_val <= data_in; // LOAD data for writeback
                            mem_en <= 1'b0;
                        end else if (mem_read && !mem_ready) { // LOAD - stall
                            state <= ST_EXECUTE; // Re-evaluate in next cycle
                            mem_en <= 1'b1;      // Keep mem_en asserted
                            new_pc <= r[REG_PC]; // Hold PC
                            pc_override_en <= 1'b1; // Force PC to hold
                            direct_jump_target <= r[REG_PC]; // Force PC to hold
                            needs_reg_writeback <= 1'b0; 
                            perform_conditional_jump <= 1'b0; 
                            is_alu_op <= 1'b0; 
                        }
                        
                        if (mem_write && mem_ready) { // STORE
                            mem_en <= 1'b0; 
                        } else if (mem_write && !mem_ready) { // STORE - stall
                            state <= ST_EXECUTE; 
                            mem_en <= 1'b1;      
                            write_en <= 1'b1;    
                            new_pc <= r[REG_PC]; 
                            pc_override_en <= 1'b1; 
                            direct_jump_target <= r[REG_PC]; 
                            needs_reg_writeback <= 1'b0; 
                            perform_conditional_jump <= 1'b0; 
                            is_alu_op <= 1'b0; 
                        }

                        if (perform_conditional_jump) begin
                            case (cond_jcond)
                                4'b0000: is_true_cond <= r[REG_FLG][1];  // JZ (Z=1)
                                4'b0001: is_true_cond <= ~r[REG_FLG][1]; // JNZ (Z=0)
                                4'b0010: is_true_cond <= r[REG_FLG][0];  // JC (C=1)
                                4'b0011: is_true_cond <= ~r[REG_FLG][0]; // JNC (C=0)
                                4'b0100: is_true_cond <= r[REG_FLG][2];  // JS (S=1)
                                4'b0101: is_true_cond <= ~r[REG_FLG][2]; // JNS (S=0)
                                4'b0110: is_true_cond <= r[REG_FLG][3];  // JO (O=1)
                                4'b0111: is_true_cond <= ~r[REG_FLG][3]; // JNO (O=0)
                                4'b1000: is_true_cond <= 1'b1;           // JMPA (Always)
                                default: is_true_cond <= 1'b0;          // Reserved conditions
                            endcase
                            if (is_true_cond) begin
                                direct_jump_target <= r[REG_PC] + {{8{imm8_jcond[7]}}, imm8_jcond}; // Sign-extend
                                pc_override_en <= 1'b1;
                            end else begin
                                pc_override_en <= 1'b0; 
                            end
                        end
                        
                        if (!( (mem_read && !mem_ready) || (mem_write && !mem_ready) )) begin
                            if (pc_override_en) begin
                                new_pc <= direct_jump_target;
                            end else begin
                                new_pc <= r[REG_PC] + 1;
                            end
                            state <= ST_WRITEBACK;
                        end
                    end // End of normal execution vs exception handling
                end
                ST_WRITEBACK: begin
                    if (needs_reg_writeback && wb_reg_idx != REG_PC && wb_reg_idx != REG_FLG) begin
                        // FLG update will happen in ST_WRITEBACK
                    end
                    if (mem_read && mem_ready) begin // LOAD
                        wb_val <= data_in; // LOAD data for writeback
                        mem_en <= 1'b0;
                    end else if (mem_read && !mem_ready) { // LOAD - stall
                        state <= ST_EXECUTE; // Re-evaluate in next cycle
                        mem_en <= 1'b1;      // Keep mem_en asserted
                        // All other signals (wb_val, pc_override_en etc.) should hold or be re-evaluated
                        // To prevent partial updates, ensure PC logic below doesn't run yet
                        new_pc <= r[REG_PC]; // Hold PC
                        pc_override_en <= 1'b1; // Force PC to hold
                        direct_jump_target <= r[REG_PC]; // Force PC to hold
                        // And skip other logic in this state for this cycle
                        needs_reg_writeback <= 1'b0; // Avoid writeback if stalling
                        perform_conditional_jump <= 1'b0; // Avoid jump logic if stalling
                        is_alu_op <= 1'b0; // Avoid ALU flag write if stalling
                    }
                    
                    if (mem_write && mem_ready) { // STORE
                        mem_en <= 1'b0; // Done with memory for this instruction
                    } else if (mem_write && !mem_ready) { // STORE - stall
                        state <= ST_EXECUTE; // Re-evaluate in next cycle
                        mem_en <= 1'b1;      // Keep mem_en asserted
                        write_en <= 1'b1;    // Keep write_en asserted
                        new_pc <= r[REG_PC]; // Hold PC
                        pc_override_en <= 1'b1; // Force PC to hold
                        direct_jump_target <= r[REG_PC]; // Force PC to hold
                        needs_reg_writeback <= 1'b0; // Avoid writeback if stalling
                        perform_conditional_jump <= 1'b0; // Avoid jump logic if stalling
                        is_alu_op <= 1'b0; // Avoid ALU flag write if stalling
                    }

                    if (perform_conditional_jump) begin
                        // Check JCOND conditions
                        // FLG Format: {C, Z, S, O, 0,0,0,0} C=bit0, Z=bit1, S=bit2, O=bit3
                        case (cond_jcond)
                            4'b0000: is_true_cond <= r[REG_FLG][1];  // JZ (Z=1)
                            4'b0001: is_true_cond <= ~r[REG_FLG][1]; // JNZ (Z=0)
                            4'b0010: is_true_cond <= r[REG_FLG][0];  // JC (C=1)
                            4'b0011: is_true_cond <= ~r[REG_FLG][0]; // JNC (C=0)
                            4'b0100: is_true_cond <= r[REG_FLG][2];  // JS (S=1)
                            4'b0101: is_true_cond <= ~r[REG_FLG][2]; // JNS (S=0)
                            4'b0110: is_true_cond <= r[REG_FLG][3];  // JO (O=1)
                            4'b0111: is_true_cond <= ~r[REG_FLG][3]; // JNO (O=0)
                            4'b1000: is_true_cond <= 1'b1;           // JMPA (Always)
                            default: is_true_cond <= 1'b0;          // Reserved conditions
                        endcase
                        if (is_true_cond) begin
                            direct_jump_target <= r[REG_PC] + {{8{imm8_jcond[7]}}, imm8_jcond}; // Sign-extend
                            pc_override_en <= 1'b1;
                        end else begin
                            pc_override_en <= 1'b0; // Condition false, PC increments normally
                        end
                    end
                    
                    // PC update logic: only if not stalled by memory
                    if (!( (mem_read && !mem_ready) || (mem_write && !mem_ready) )) begin
                        if (pc_override_en) begin
                            new_pc <= direct_jump_target;
                        end else begin
                            new_pc <= r[REG_PC] + 1;
                        end
                        state <= ST_WRITEBACK;
                    end
                end
                ST_WRITEBACK: begin
                    if (needs_reg_writeback && wb_reg_idx != REG_PC && wb_reg_idx != REG_FLG) begin
                        r[wb_reg_idx] <= wb_val;
                    end
                    if (is_alu_op) begin // Update FLG for any ALU operation
                        r[REG_FLG] <= {12'b0, alu_flags_out}; // Store C,Z,S,O in lower 4 bits
                    end
                    if (save_link_address) begin // For JAL
                        r[REG_LR] <= link_address_content;
                    end
                    state <= ST_DONE;
                end
                ST_DONE: begin
                    r[REG_PC] <= new_pc; // new_pc is EXCEPTION_VECTOR if exception_active was true in ST_EXECUTE
                    if (exception_active) begin
                        exception_active <= 1'b0; // Clear exception flag after PC is set for handler
                    end
                    state <= ST_FETCH;
                end
            endcase
        end
    end
endmodule
