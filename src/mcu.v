module MCU  (
        input clk,reset,
        input [15:0] data_in,
        input mem_ready,
        output [15:0] addr_bus, // Now driven by assign
        output mem_en,write_en, // Now driven by assign
        output [15:0] data_out, // Now driven by assign
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

    // assign dbg_state = ~state; // Tied off for now
    // assign dbg = {r[REG_PC], ir}; // Tied off for now
    assign dbg_state = 3'b0;
    assign dbg = 32'b0;

    reg [15:0] r[16]; // Register file

    // Pipeline Registers
    // IF/ID Stage
    reg IF_ID_reg_valid;
    reg [15:0] IF_ID_reg_pc;
    reg [15:0] IF_ID_reg_ir;

    // ID/EX Stage
    reg ID_EX_reg_valid;
    reg [15:0] ID_EX_reg_pc;
    reg [15:0] ID_EX_reg_ir;
    reg [15:0] ID_EX_reg_op1_data;
    reg [15:0] ID_EX_reg_op2_data;
    reg [3:0] ID_EX_reg_rd_idx;
    // Control Signals for ID_EX_reg_ctrl_signals bundle
    localparam CTRL_ALUOP_WIDTH = 4;
    localparam CTRL_ALUSRC_BIT = 0;      // 0: Reg-Reg, 1: Reg-Imm
    localparam CTRL_MEMREAD_BIT = 1;
    localparam CTRL_MEMWRITE_BIT = 2;
    localparam CTRL_REGWRITE_BIT = 3;
    localparam CTRL_MEMTOREG_BIT = 4;    // 0: ALU result to WB, 1: Mem data to WB
    localparam CTRL_BRANCHTYPE_WIDTH = 4; // Encodes JCOND types, JAL, JR, or none
    localparam CTRL_ISJAL_BIT = 5;
    localparam CTRL_ISJR_BIT = 6;
    localparam CTRL_LUI_BIT = 7;
    // Total width needs to accommodate these + ALUOp + BranchType.
    // Let's define bit positions:
    // For simplicity, group similar types. This is just one way to organize.
    // Example: RegWrite (1), MemRead (1), MemWrite (1), MemToReg (1), ALUSrc (1), IsJAL (1), IsJR (1), LUI (1) = 8 bits
    // ALUOp (4 bits)
    // BranchType (4 bits)
    // Total = 8 + 4 + 4 = 16 bits. This is an example, actual assignment below.

    localparam CS_RegWrite_B = 0;
    localparam CS_MemRead_B  = 1;
    localparam CS_MemWrite_B = 2;
    localparam CS_MemToReg_B = 3;
    localparam CS_ALUSrc_B   = 4;
    localparam CS_IsJAL_B    = 5;
    localparam CS_IsJR_B     = 6;
    localparam CS_LUI_B      = 7;
    localparam CS_IsALU_B    = 8; // New: Indicates an op that updates flags
    // ALUOp is bits 12:9 (shifted due to CS_IsALU_B)
    localparam CS_ALUOp_S    = 9; // Start bit for ALUOp
    // BranchType is bits 16:13 (shifted)
    localparam CS_BranchType_S = 13; // Start bit for BranchType
    localparam ID_EX_CTRL_WIDTH = 17; // Increased width by 1 for CS_IsALU_B

    reg [ID_EX_CTRL_WIDTH-1:0] ID_EX_reg_ctrl_signals;
    reg [15:0] ID_EX_reg_branch_target; // For JAL, JCOND
    reg [15:0] ID_EX_reg_jr_target;     // For JR

    // EX/MEM Stage
    reg EX_MEM_reg_valid;
    reg [15:0] EX_MEM_reg_pc;
    reg [15:0] EX_MEM_reg_ir;
    reg [15:0] EX_MEM_reg_alu_out;      // ALU result or Effective Address
    reg [15:0] EX_MEM_reg_op2_data_fwd; // Data for store (from ID_EX_reg_op2_data)
    reg [3:0] EX_MEM_reg_rd_idx;
    reg [ID_EX_CTRL_WIDTH-1:0] EX_MEM_reg_ctrl_signals; // Passed through, possibly modified
    reg EX_MEM_reg_branch_taken;
    reg [15:0] EX_MEM_reg_final_branch_target;
    reg [3:0] EX_MEM_reg_alu_flags;     // ALU flags (C,Z,S,O)

    // MEM/WB Stage
    reg MEM_WB_reg_valid;
    reg [15:0] MEM_WB_reg_pc;
    reg [15:0] MEM_WB_reg_ir;
    reg [15:0] MEM_WB_reg_wb_data; // Data to be written back (ALU out or Mem data)
    reg [3:0] MEM_WB_reg_rd_idx;
    reg [ID_EX_CTRL_WIDTH-1:0] MEM_WB_reg_ctrl_signals; // Control signals passed from EX/MEM
    reg [3:0] MEM_WB_reg_alu_flags;                 // ALU flags from EX/MEM

    // Decoded instruction fields - these will be derived from IF_ID_reg_ir or ID_EX_reg_ir as needed
    // For now, let's assume they are derived from IF_ID_reg_ir for the ID stage logic
    wire [3:0] op_family_from_IF_ID = IF_ID_reg_ir[15:12];
    wire [3:0] op_specific_alu_rr_from_IF_ID = IF_ID_reg_ir[11:8];
    
    wire [3:0] rx_dst_s1_alu_rr_from_IF_ID = IF_ID_reg_ir[7:4];
    wire [3:0] ry_s2_alu_rr_from_IF_ID = IF_ID_reg_ir[3:0];

    wire [3:0] rx_dst_s1_alu_ri_from_IF_ID = IF_ID_reg_ir[11:8];
    wire [7:0] imm8_alu_ri_from_IF_ID = IF_ID_reg_ir[7:0];

    wire [3:0] rt_load_store_from_IF_ID = IF_ID_reg_ir[11:8];
    wire [3:0] rs_addr_load_store_from_IF_ID = IF_ID_reg_ir[7:4];
    wire [3:0] imm4_load_store_from_IF_ID = IF_ID_reg_ir[3:0];

    wire [3:0] rt_lui_from_IF_ID = IF_ID_reg_ir[11:8];
    wire [7:0] imm8_lui_from_IF_ID = IF_ID_reg_ir[7:0];

    wire [11:0] imm12_jal_from_IF_ID = IF_ID_reg_ir[11:0];
    wire [3:0] rs_addr_jr_from_IF_ID = IF_ID_reg_ir[11:8];
    
    wire [3:0] cond_jcond_from_IF_ID = IF_ID_reg_ir[11:8];
    wire [7:0] imm8_jcond_from_IF_ID = IF_ID_reg_ir[7:0];

    // ALU signals (will be driven by ID/EX stage logic)
    // reg is_alu_op; // This will be part of control signals
    wire [15:0] alu_op1_from_ID_EX; // Comes from ID_EX_reg_op1_data
    wire [15:0] alu_op2_from_ID_EX; // Comes from ID_EX_reg_op2_data
    wire [3:0] alu_op_internal_from_ID_EX; // Comes from decoded instruction in ID_EX
    wire [15:0] alu_out;
    wire [3:0] alu_flags_out;

    ALU alu(
        .op(alu_op_internal_from_ID_EX), // ALU op determined in ID (from ID_EX_reg_ctrl_signals)
        .in1(ex_stage_alu_operand_A_comb), // Muxed Operand A
        .in2(ex_stage_alu_operand_B_comb), // Muxed Operand B
        .flags(alu_flags_out),           // ALU flags output
        .out(alu_out)                    // ALU result output
    );

    // IF Stage Combinational Logic Outputs (wires to be driven by IF combinational block)
    wire [15:0] if_stage_instruction_data;
    wire [15:0] if_stage_pc_data;
    wire if_stage_valid_output;
    wire if_stage_mem_en_comb;
    wire [15:0] if_stage_addr_bus_comb;

    // Stall Logic
    wire stall_pipeline;

    // Top-level memory and control signal assignments
    // These drive the MCU's output ports.
    // Note: The MCU output ports addr_bus, mem_en, write_en are implicitly wires if driven by 'assign'.
    // data_out is also now an assign, driven by mem_stage_data_out_comb_internal if store is active.
    assign addr_bus = (mem_stage_mem_en_comb_internal && EX_MEM_reg_valid) ? mem_stage_addr_bus_comb_internal : if_stage_addr_bus_comb;
    assign mem_en   = (mem_stage_mem_en_comb_internal && EX_MEM_reg_valid) || if_stage_mem_en_comb; // OR because IF might fetch while MEM does L/S
    assign write_en = (mem_stage_mem_write_comb_internal && EX_MEM_reg_valid) ? 1'b1 : 1'b0;
    assign data_out = (mem_stage_mem_write_comb_internal && EX_MEM_reg_valid) ? mem_stage_data_out_comb_internal : 16'hzzzz; // Output Z if not writing

    // Stall pipeline if IF stage needs memory and it's not ready,
    // OR if MEM stage needs memory (and instruction in MEM is valid) and it's not ready.
    wire stall_pipeline_structural_mem;
    assign stall_pipeline_structural_mem = (if_stage_mem_en_comb && !mem_ready) ||
                                           (mem_stage_mem_en_comb_internal && EX_MEM_reg_valid && !mem_ready);

    // Stall signal for front-end stages (PC, IF/ID) due to IF memory wait or data hazard detected in ID
    wire stall_frontend;
    assign stall_frontend = (if_stage_mem_en_comb && !mem_ready) || id_ex_data_hazard_stall_needed_comb;

    // Final stall signal incorporates structural/memory stalls and data hazard stalls.
    // This signal will gate the progression of EX, MEM, WB stages if earlier stages can't provide data
    // or if MEM stage itself is stalled by memory.
    assign stall_pipeline = stall_pipeline_structural_mem || id_ex_data_hazard_stall_needed_comb;

    // PC Selection Logic
    wire [15:0] pc_next_ সংসদ_comb;
    assign pc_next_ সংসদ_comb = (EX_MEM_reg_branch_taken && EX_MEM_reg_valid) ? EX_MEM_reg_final_branch_target : (r[REG_PC] + 1);

    // Pipeline Flush Signal (due to taken branch/jump resolved in EX/MEM)
    wire pipeline_flush_comb;
    assign pipeline_flush_comb = EX_MEM_reg_branch_taken && EX_MEM_reg_valid;


    // Placeholder structures for stage outputs (combinational logic will define these)
    // These are conceptual structures; in Verilog, you'd assign to the input regs of the next stage.
    // For clarity, we can define intermediate wire groups if complex.

    // ID Stage Combinational Outputs (wires to be driven by ID combinational block)
    wire id_stage_id_ex_valid_output_comb;
    wire [15:0] id_stage_id_ex_pc_data_comb;
    wire [15:0] id_stage_id_ex_ir_data_comb;
    wire [15:0] id_stage_id_ex_op1_data_comb;
    wire [15:0] id_stage_id_ex_op2_data_comb;
    wire [3:0] id_stage_id_ex_rd_idx_data_comb;
    wire [ID_EX_CTRL_WIDTH-1:0] id_stage_id_ex_ctrl_signals_data_comb;
    wire [15:0] id_stage_id_ex_branch_target_data_comb;
    wire [15:0] id_stage_id_ex_jr_target_data_comb;
    wire [1:0] id_stage_id_ex_exception_code_data_comb; // Driven by ID stage
    wire id_ex_data_hazard_stall_needed_comb; // Driven by ID stage if hazard detected

    // EX Stage Combinational Outputs (wires to be driven by EX combinational block)
    wire [1:0] ex_stage_fwd_A_select_comb; // Forwarding select for ALU Op A
    wire [1:0] ex_stage_fwd_B_select_comb; // Forwarding select for ALU Op B
    wire [15:0] ex_stage_alu_operand_A_comb; // Muxed input for ALU A
    wire [15:0] ex_stage_alu_operand_B_comb; // Muxed input for ALU B

    wire ex_stage_ex_mem_valid_output_comb;
    wire [15:0] ex_stage_ex_mem_pc_data_comb;
    wire [15:0] ex_stage_ex_mem_ir_data_comb;
    wire [15:0] ex_stage_ex_mem_alu_out_data_comb;
    wire [15:0] ex_stage_ex_mem_op2_data_fwd_data_comb;
    wire [3:0] ex_stage_ex_mem_rd_idx_data_comb;
    wire [ID_EX_CTRL_WIDTH-1:0] ex_stage_ex_mem_ctrl_signals_data_comb;
    wire ex_stage_ex_mem_branch_taken_data_comb;
    wire [15:0] ex_stage_ex_mem_final_branch_target_data_comb;
    wire [3:0] ex_stage_ex_mem_alu_flags_data_comb;
    wire [1:0] ex_stage_ex_mem_exception_code_data_comb; // Driven by EX stage
    // wire ex_mem_stage_valid_out; // Conceptual comment
    // wire [15:0] ex_mem_stage_pc_out; // Conceptual comment
    // wire [15:0] ex_mem_stage_ir_out; // Conceptual comment
    // wire [15:0] ex_mem_stage_alu_out_val; // Conceptual comment
    // wire [15:0] ex_mem_stage_op2_data_fwd_out;
    // wire [3:0] ex_mem_stage_rd_idx_out;
    // wire [3:0] ex_mem_stage_ctrl_signals_out;

    // MEM/WB Stage Outputs (combinational logic)
    wire mem_stage_mem_wb_valid_output_comb;
    wire [15:0] mem_stage_mem_wb_pc_data_comb;
    wire [15:0] mem_stage_mem_wb_ir_data_comb;
    wire [15:0] mem_stage_mem_wb_wb_data_data_comb;
    wire [3:0] mem_stage_mem_wb_rd_idx_data_comb;
    wire [ID_EX_CTRL_WIDTH-1:0] mem_stage_mem_wb_ctrl_signals_data_comb;
    wire [3:0] mem_stage_mem_wb_alu_flags_data_comb;
    wire [1:0] mem_stage_mem_wb_exception_code_data_comb; // Driven by MEM stage

    // Internal MEM Stage signals for memory control
    wire mem_stage_mem_en_comb_internal;      // Internal signal for memory enable
    wire mem_stage_mem_write_comb_internal;   // Internal signal for write enable
    wire [15:0] mem_stage_addr_bus_comb_internal; // Internal signal for address bus
    wire [15:0] mem_stage_data_out_comb_internal; // Internal signal for data to write to memory
    // wire mem_wb_stage_valid_out; // Conceptual comment
    // wire [15:0] mem_wb_stage_pc_out; // Conceptual comment
    // wire [15:0] mem_wb_stage_ir_out;
    // wire [15:0] mem_wb_stage_wb_data_out;
    // wire [3:0] mem_wb_stage_rd_idx_out;
    // wire [3:0] mem_wb_stage_ctrl_signals_out;


    // Control signals (will be re-evaluated based on pipeline structure)
    // reg mem_read; // Now part of control signals from ID/EX or EX/MEM
    // reg mem_write; // Now part of control signals
    reg [15:0] pc_next_if; // PC for the next fetch

    // Signals for exception handling (simplified for now)
    // reg invalid_instruction_error;
    // reg bad_address_error;
    // reg exception_active;
    // reg [15:0] captured_pc_for_exception;


    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            int i;
            for(i=0; i<16; i=i+1) begin
                r[i] <= 16'b0;
            end
            r[REG_PC] <= 16'h0000; // Initial PC reset

            // Reset pipeline registers
            IF_ID_reg_valid <= 1'b0;
            IF_ID_reg_pc <= 16'b0;
            IF_ID_reg_ir <= 16'b0;

            ID_EX_reg_valid <= 1'b0;
            ID_EX_reg_pc <= 16'b0;
            ID_EX_reg_ir <= 16'b0;
            ID_EX_reg_op1_data <= 16'b0;
            ID_EX_reg_op2_data <= 16'b0;
            ID_EX_reg_rd_idx <= 4'b0;
            ID_EX_reg_ctrl_signals <= {ID_EX_CTRL_WIDTH{1'b0}}; // Initialize to benign (e.g., all zeros)
            ID_EX_reg_branch_target <= 16'b0;
            ID_EX_reg_jr_target <= 16'b0;
            ID_EX_reg_exception_code <= 2'b00;

            EX_MEM_reg_valid <= 1'b0;
            EX_MEM_reg_pc <= 16'b0;
            EX_MEM_reg_ir <= 16'b0;
            EX_MEM_reg_alu_out <= 16'b0;
            EX_MEM_reg_op2_data_fwd <= 16'b0;
            EX_MEM_reg_rd_idx <= 4'b0;
            EX_MEM_reg_ctrl_signals <= {ID_EX_CTRL_WIDTH{1'b0}};
            EX_MEM_reg_branch_taken <= 1'b0;
            EX_MEM_reg_final_branch_target <= 16'b0;
            EX_MEM_reg_alu_flags <= 4'b0;
            EX_MEM_reg_exception_code <= 2'b00;

            MEM_WB_reg_valid <= 1'b0;
            MEM_WB_reg_pc <= 16'b0;
            MEM_WB_reg_ir <= 16'b0;
            MEM_WB_reg_wb_data <= 16'b0;
            MEM_WB_reg_rd_idx <= 4'b0;
            MEM_WB_reg_ctrl_signals <= {ID_EX_CTRL_WIDTH{1'b0}}; // Use defined width
            MEM_WB_reg_alu_flags <= 4'b0;
            MEM_WB_reg_exception_code <= 2'b00;

            // mem_en, write_en are now driven by assign statements.
            // pc_next_if <= 16'h0000; // Not used.

        end else begin
            // Pipeline Register Transfers and PC Update

            // PC Update: Stall if front-end is stalled (IF memory wait or ID data hazard)
            // Selects next PC based on branch/jump resolution from EX/MEM stage.
            if (!stall_frontend) begin
                r[REG_PC] <= pc_next_ সংসদ_comb;
            end
            // else: r[REG_PC] holds

            // IF/ID Stage Update: Flush if branch taken, stall if front-end stalled.
            if (pipeline_flush_comb) begin
                IF_ID_reg_valid <= 1'b0; // Flush
                IF_ID_reg_pc    <= 16'b0; // Optional: clear data on flush
                IF_ID_reg_ir    <= 16'b0; // Optional: clear data on flush
            end else if (!stall_frontend) begin
                IF_ID_reg_valid <= if_stage_valid_output;
                IF_ID_reg_pc    <= if_stage_pc_data;
                IF_ID_reg_ir    <= if_stage_instruction_data;
            end
            // else: IF_ID_reg holds due to stall_frontend

            // ID/EX Stage Update: Flush if branch taken. If not flushing, stall if front-end is stalled OR data hazard.
            // If not stalling for those reasons, load normally or inject NOP for data hazard.
            if (pipeline_flush_comb) begin
                ID_EX_reg_valid <= 1'b0; // Flush
                ID_EX_reg_ctrl_signals <= {ID_EX_CTRL_WIDTH{1'b0}}; // NOP control signals
                ID_EX_reg_exception_code <= 2'b00; // Clear exception on flush
                // Optional: clear other ID_EX fields
                ID_EX_reg_pc <= 16'b0; ID_EX_reg_ir <= 16'b0; ID_EX_reg_op1_data <= 16'b0; ID_EX_reg_op2_data <= 16'b0;
                ID_EX_reg_rd_idx <= 4'b0; ID_EX_reg_branch_target <= 16'b0; ID_EX_reg_jr_target <= 16'b0;
            end else if (!stall_frontend) begin // IF/ID is providing new data (or held valid data)
                if (id_ex_data_hazard_stall_needed_comb) begin // Data hazard specifically for current IF/ID data
                    ID_EX_reg_valid <= 1'b0; // Inject NOP
                    ID_EX_reg_ctrl_signals <= {ID_EX_CTRL_WIDTH{1'b0}}; // NOP control signals
                    ID_EX_reg_exception_code <= 2'b00; // NOP has no exception
                    // Optional: clear other fields
                    ID_EX_reg_pc <= IF_ID_reg_pc; // Pass PC for debug, though invalid
                    ID_EX_reg_ir <= IF_ID_reg_ir; // Pass IR for debug
                end else begin // No data hazard stall, load normally from ID stage outputs
                    ID_EX_reg_valid         <= id_stage_id_ex_valid_output_comb;
                    ID_EX_reg_pc            <= id_stage_id_ex_pc_data_comb;
                    ID_EX_reg_ir            <= id_stage_id_ex_ir_data_comb;
                    ID_EX_reg_op1_data      <= id_stage_id_ex_op1_data_comb;
                    ID_EX_reg_op2_data      <= id_stage_id_ex_op2_data_comb;
                    ID_EX_reg_rd_idx        <= id_stage_id_ex_rd_idx_data_comb;
                    ID_EX_reg_ctrl_signals  <= id_stage_id_ex_ctrl_signals_data_comb;
                    ID_EX_reg_branch_target <= id_stage_id_ex_branch_target_data_comb;
                    ID_EX_reg_jr_target     <= id_stage_id_ex_jr_target_data_comb;
                    ID_EX_reg_exception_code <= id_stage_id_ex_exception_code_data_comb;
                end
            end
            // else: ID_EX_reg holds if stall_frontend is active (and no flush)

            // EX/MEM, MEM/WB, and WB stage updates are conditional on the global 'stall_pipeline'.
            // 'stall_pipeline' includes 'id_ex_data_hazard_stall_needed_comb' and structural stalls.
            // If 'id_ex_data_hazard_stall_needed_comb' is true, 'stall_pipeline' is true, so EX/MEM and MEM/WB will hold.
            // This implements the simpler stall where the entire pipeline behind ID effectively stalls.
            if (!stall_pipeline) begin
                // EX/MEM Stage Update (advances if not stalled globally)
                EX_MEM_reg_valid <= ex_stage_ex_mem_valid_output_comb;
                if (ex_stage_ex_mem_valid_output_comb) begin
                    EX_MEM_reg_pc            <= ex_stage_ex_mem_pc_data_comb;
                    EX_MEM_reg_ir            <= ex_stage_ex_mem_ir_data_comb;
                    EX_MEM_reg_alu_out       <= ex_stage_ex_mem_alu_out_data_comb;
                    EX_MEM_reg_op2_data_fwd  <= ex_stage_ex_mem_op2_data_fwd_data_comb;
                    EX_MEM_reg_rd_idx        <= ex_stage_ex_mem_rd_idx_data_comb;
                    EX_MEM_reg_ctrl_signals  <= ex_stage_ex_mem_ctrl_signals_data_comb;
                    EX_MEM_reg_branch_taken  <= ex_stage_ex_mem_branch_taken_data_comb;
                    EX_MEM_reg_final_branch_target <= ex_stage_ex_mem_final_branch_target_data_comb;
                    EX_MEM_reg_alu_flags     <= ex_stage_ex_mem_alu_flags_data_comb;
                    EX_MEM_reg_exception_code <= ex_stage_ex_mem_exception_code_data_comb;
                end

                // MEM/WB Stage Update (advances if not stalled globally)
                MEM_WB_reg_valid <= mem_stage_mem_wb_valid_output_comb;
                if (mem_stage_mem_wb_valid_output_comb) begin
                    MEM_WB_reg_pc           <= mem_stage_mem_wb_pc_data_comb;
                    MEM_WB_reg_ir           <= mem_stage_mem_wb_ir_data_comb;
                    MEM_WB_reg_wb_data      <= mem_stage_mem_wb_wb_data_data_comb;
                    MEM_WB_reg_rd_idx       <= mem_stage_mem_wb_rd_idx_data_comb;
                    MEM_WB_reg_ctrl_signals <= mem_stage_mem_wb_ctrl_signals_data_comb;
                    MEM_WB_reg_alu_flags    <= mem_stage_mem_wb_alu_flags_data_comb;
                    MEM_WB_reg_exception_code <= mem_stage_mem_wb_exception_code_data_comb;
                end
            end
            // else: EX_MEM and MEM_WB registers hold due to stall_pipeline

            // Register write-back (from MEM_WB_reg) - This is independent of pipeline stall.
            // It occurs if MEM_WB_reg contains a valid instruction that needs to write back.
            if (MEM_WB_reg_valid) begin
                // General Purpose Register Write
                if (MEM_WB_reg_ctrl_signals[CS_RegWrite_B]) begin
                    if (MEM_WB_reg_rd_idx != REG_PC && MEM_WB_reg_rd_idx != REG_FLG) begin // Exclude PC and FLG from general write
                        r[MEM_WB_reg_rd_idx] <= MEM_WB_reg_wb_data;
                    end
                end

                // FLG Update for ALU ops
                if (MEM_WB_reg_ctrl_signals[CS_IsALU_B]) begin
                    r[REG_FLG] <= {12'b0, MEM_WB_reg_alu_flags};
                end

                // LR Update for JAL
                if (MEM_WB_reg_ctrl_signals[CS_IsJAL_B]) begin
                    // For JAL, wb_data should be PC+1 calculated by ALU in EX, passed through MEM
                    r[REG_LR] <= MEM_WB_reg_wb_data;
                end
            end
        end
    end

    // Placeholder Combinational Logic for Stage Outputs
    // These blocks will assign values to be latched by the next stage's registers.

    // IF Stage Combinational Logic
    always_comb begin
        if_stage_pc_data = r[REG_PC];           // Current PC value
        if_stage_addr_bus_comb = r[REG_PC];     // Memory address for fetch is current PC
        if_stage_mem_en_comb = 1'b1;            // Always try to fetch (actual fetch depends on mem_ready via stall_pipeline)

        if (mem_ready) begin
            if_stage_instruction_data = data_in; // Instruction data from memory
            if_stage_valid_output = 1'b1;        // Valid instruction is ready
        end else begin
            if_stage_instruction_data = 16'h0000; // Default to NOP or 0 if no data
            if_stage_valid_output = 1'b0;        // No valid instruction if memory not ready
        end
    end

    // ID Stage Output Logic (feeds ID_EX_reg)
    always_comb begin
        // Default assignments for control signals (benign state)
        id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; // All control bits to 0 initially

        // Default assignments for data outputs
        id_stage_id_ex_op1_data_comb = 16'b0;
        id_stage_id_ex_op2_data_comb = 16'b0;
        id_stage_id_ex_rd_idx_data_comb = 4'b0;
        id_stage_id_ex_branch_target_data_comb = IF_ID_reg_pc; // Default, may not be used
        id_stage_id_ex_jr_target_data_comb = 16'b0;         // Default, may not be used
        // id_stage_id_ex_exception_code_data_comb is initialized at start of block

        // Pass through PC and IR
        id_stage_id_ex_pc_data_comb = IF_ID_reg_pc;
        id_stage_id_ex_ir_data_comb = IF_ID_reg_ir;
        // id_stage_id_ex_valid_output_comb = IF_ID_reg_valid; // This will be determined by hazard detection too

        // Hazard Detection Logic
        id_ex_data_hazard_stall_needed_comb = 1'b0; // Default to no stall
        wire [3:0] current_id_rs1_idx;
        wire [3:0] current_id_rs2_idx;
        wire current_id_reads_rs1;
        wire current_id_reads_rs2;

        // Determine rs1, rs2 based on current instruction in ID (from IF_ID_reg_ir)
        // This logic needs to mirror what the main decode case does for operand fetching
        // For simplicity, we'll extract potential rs1, rs2 and then gate their use.
        // More precise: determine exact rs1/rs2 based on op_family.
        // For now, extract common locations:
        current_id_rs1_idx = op_family_from_IF_ID == OPFAMILY_ALU_RR ? rx_dst_s1_alu_rr_from_IF_ID :
                             (op_family_from_IF_ID == OPFAMILY_ADDI || op_family_from_IF_ID == OPFAMILY_ANDI ||
                              op_family_from_IF_ID == OPFAMILY_ORI  || op_family_from_IF_ID == OPFAMILY_XORI) ? rx_dst_s1_alu_ri_from_IF_ID :
                             (op_family_from_IF_ID == OPFAMILY_LOAD || op_family_from_IF_ID == OPFAMILY_STORE) ? rs_addr_load_store_from_IF_ID :
                             (op_family_from_IF_ID == OPFAMILY_JR) ? rs_addr_jr_from_IF_ID :
                             4'b0; // Default, no rs1

        current_id_rs2_idx = op_family_from_IF_ID == OPFAMILY_ALU_RR ? ry_s2_alu_rr_from_IF_ID :
                             4'b0; // Default, no rs2 (or rs2 is not a GPR for other common ops)

        current_id_reads_rs1 = (op_family_from_IF_ID == OPFAMILY_ALU_RR ||
                               op_family_from_IF_ID == OPFAMILY_ADDI || op_family_from_IF_ID == OPFAMILY_ANDI ||
                               op_family_from_IF_ID == OPFAMILY_ORI  || op_family_from_IF_ID == OPFAMILY_XORI ||
                               op_family_from_IF_ID == OPFAMILY_LOAD || op_family_from_IF_ID == OPFAMILY_STORE ||
                               op_family_from_IF_ID == OPFAMILY_JR);

        current_id_reads_rs2 = (op_family_from_IF_ID == OPFAMILY_ALU_RR);
        // Note: For STORE, rs2 (rt_load_store) is also read. This simplified rs2 detection might miss it.
        // Corrected rs2 usage check for STORE:
        if (op_family_from_IF_ID == OPFAMILY_STORE) begin
            current_id_reads_rs2 = 1'b1; // STORE reads Rt (source of data)
            current_id_rs2_idx = rt_load_store_from_IF_ID; // Rt is effectively a second source reg for STORE
        end


        // Load-Use Hazard Detection Logic
        // Stall if instruction in EX is a LOAD and its destination is used by current instruction in ID.
        id_ex_data_hazard_stall_needed_comb = 1'b0; // Default: no stall
        if (ID_EX_reg_valid &&
            ID_EX_reg_ctrl_signals[CS_MemRead_B] && // If instruction in EX is a LOAD
            ID_EX_reg_rd_idx != 0) begin             // And it writes to a register

            if (current_id_reads_rs1 && (current_id_rs1_idx == ID_EX_reg_rd_idx)) begin
                id_ex_data_hazard_stall_needed_comb = 1'b1; // Stall for rs1
            end
            if (current_id_reads_rs2 && (current_id_rs2_idx == ID_EX_reg_rd_idx) && !id_ex_data_hazard_stall_needed_comb) begin
                // Check if already stalled for rs1 to avoid redundant logic if both rs1 and rs2 match
                id_ex_data_hazard_stall_needed_comb = 1'b1; // Stall for rs2
            end
        end

        // Instruction decoding logic
        id_stage_id_ex_exception_code_data_comb = 2'b00; // Initialize exception code
        if (IF_ID_reg_valid && !id_ex_data_hazard_stall_needed_comb) begin // Only decode if valid and no data hazard stall
            id_stage_id_ex_valid_output_comb = 1'b1; // This instruction can proceed to ID/EX (unless its decode marks it invalid)
            // wire [3:0] rs1_idx_w = IF_ID_reg_ir[7:4]; // Now use current_id_rs1_idx
            // wire [3:0] rs2_idx_w = IF_ID_reg_ir[3:0]; // Now use current_id_rs2_idx
            wire [3:0] rd_idx_w;

            // For R-R ALU: rx_dst_s1_alu_rr (ir[7:4])
            // For R-I ALU: rx_dst_s1_alu_ri (ir[11:8])
            // For LOAD: rt_load_store (ir[11:8])
            // For LUI: rt_lui (ir[11:8])
            // JAL stores to REG_LR implicitly (handled by control signal CS_IsJAL_B)

            // Processed immediate value
            reg [15:0] imm_processed_w;

            // Default operand 1 from register file
            id_stage_id_ex_op1_data_comb = r[current_id_rs1_idx]; // Use determined rs1_idx

            case (op_family_from_IF_ID)
                OPFAMILY_ALU_RR: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b0; // Reg-Reg
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;   // Is an ALU op
                    // Set ALUOp based on op_specific_alu_rr_from_IF_ID
                    case (op_specific_alu_rr_from_IF_ID)
                        ALU_RR_ADD_SPEC: id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT;
                        ALU_RR_SUB_SPEC: id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_SUB_4BIT;
                        ALU_RR_AND_SPEC: id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_AND_4BIT;
                        ALU_RR_OR_SPEC:  id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_OR_4BIT;
                        ALU_RR_XOR_SPEC: id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_XOR_4BIT;
                        ALU_RR_SHL_SPEC: id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_SHL_4BIT;
                        ALU_RR_SHR_SPEC: id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_SHR_4BIT;
                        ALU_RR_MUL_SPEC: id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_MUL_4BIT;
                        default: begin
                            id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; // Benign controls
                            id_stage_id_ex_exception_code_data_comb[0] = 1'b1; // Set Invalid Instruction
                        end
                    endcase
                    // Only proceed with operand/rd assignment if no exception from op_specific
                    if (id_stage_id_ex_exception_code_data_comb[0] == 1'b0) begin
                        id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_rr_from_IF_ID];
                        id_stage_id_ex_op2_data_comb = r[ry_s2_alu_rr_from_IF_ID];
                        if (op_specific_alu_rr_from_IF_ID == ALU_RR_SHL_SPEC || op_specific_alu_rr_from_IF_ID == ALU_RR_SHR_SPEC) begin
                            id_stage_id_ex_op2_data_comb = {12'b0, r[ry_s2_alu_rr_from_IF_ID][3:0]};
                        end
                        id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_rr_from_IF_ID;
                    end
                end
                OPFAMILY_ADDI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT;
                    imm_processed_w = {{8{imm8_alu_ri_from_IF_ID[7]}}, imm8_alu_ri_from_IF_ID};
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_ANDI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_AND_4BIT;
                    imm_processed_w = {8'h00, imm8_alu_ri_from_IF_ID};
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_ORI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_OR_4BIT;
                    imm_processed_w = {8'h00, imm8_alu_ri_from_IF_ID};
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_XORI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_XOR_4BIT;
                    imm_processed_w = {8'h00, imm8_alu_ri_from_IF_ID};
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_LOAD: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_MemRead_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_MemToReg_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT;
                    imm_processed_w = {{12{imm4_load_store_from_IF_ID[3]}}, imm4_load_store_from_IF_ID};
                    id_stage_id_ex_op1_data_comb = r[rs_addr_load_store_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rt_load_store_from_IF_ID;
                end
                OPFAMILY_STORE: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_MemWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b0; // ALU uses r[Rs] and imm from IR (handled in EX)
                                                                             // op2_data here is r[Rt] for forwarding
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT; // For address calculation in EX
                    id_stage_id_ex_op1_data_comb = r[rs_addr_load_store_from_IF_ID]; // Base register r[Rs]
                    id_stage_id_ex_op2_data_comb = r[rt_load_store_from_IF_ID];     // Data to store r[Rt]
                    id_stage_id_ex_rd_idx_data_comb = rt_load_store_from_IF_ID; // Pass Rt index, EX uses it to get imm4 from IR
                end
                OPFAMILY_LUI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_LUI_B] = 1'b1;
                    imm_processed_w = {imm8_lui_from_IF_ID, 8'h00};
                    id_stage_id_ex_op1_data_comb = 16'b0;
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rt_lui_from_IF_ID;
                end
                OPFAMILY_JAL: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsJAL_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH] = 4'b0001;
                    imm_processed_w = {{4{imm12_jal_from_IF_ID[11]}}, imm12_jal_from_IF_ID};
                    id_stage_id_ex_branch_target_data_comb = IF_ID_reg_pc + imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = REG_LR;
                    id_stage_id_ex_op1_data_comb = IF_ID_reg_pc;
                    id_stage_id_ex_op2_data_comb = 16'd1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT;
                end
                OPFAMILY_JR: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsJR_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH] = 4'b0010;
                    id_stage_id_ex_jr_target_data_comb = r[rs_addr_jr_from_IF_ID];
                end
                OPFAMILY_JCOND: begin
                    if (cond_jcond_from_IF_ID > 4'b1000 && cond_jcond_from_IF_ID != 4'b1111) begin // JMPA is 1000. Allow 1111 for future.
                        id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}};
                        id_stage_id_ex_exception_code_data_comb[0] = 1'b1;
                    end else begin
                        id_stage_id_ex_ctrl_signals_data_comb[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH] = {cond_jcond_from_IF_ID};
                        imm_processed_w = {{8{imm8_jcond_from_IF_ID[7]}}, imm8_jcond_from_IF_ID};
                        id_stage_id_ex_branch_target_data_comb = IF_ID_reg_pc + imm_processed_w;
                    end
                end
                OPFAMILY_ALU_RR_EXT: begin
                    id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}};
                    id_stage_id_ex_exception_code_data_comb[0] = 1'b1;
                end
                4'b0110: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; id_stage_id_ex_valid_output_comb = 1'b1; /*Propagate exception*/ end
                4'b0111: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; id_stage_id_ex_valid_output_comb = 1'b1; end
                4'b1010: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; id_stage_id_ex_valid_output_comb = 1'b1; end
                4'b1011: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; id_stage_id_ex_valid_output_comb = 1'b1; end
                default: begin
                    if (op_family_from_IF_ID != OPFAMILY_ALU_RR && op_family_from_IF_ID != OPFAMILY_ADDI && /* ... (all valid families) ...*/
                        op_family_from_IF_ID != OPFAMILY_JCOND && op_family_from_IF_ID != OPFAMILY_ALU_RR_EXT) begin // Check if truly unassigned
                        id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}};
                        id_stage_id_ex_exception_code_data_comb[0] = 1'b1;
                    end
                end
            endcase
            // If an exception was detected during decoding, ensure essential control signals are benign
            if (id_stage_id_ex_exception_code_data_comb != 2'b00) begin
                id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b0;
                id_stage_id_ex_ctrl_signals_data_comb[CS_MemRead_B] = 1'b0;
                id_stage_id_ex_ctrl_signals_data_comb[CS_MemWrite_B] = 1'b0;
                id_stage_id_ex_ctrl_signals_data_comb[CS_IsJAL_B] = 1'b0; // Don't modify LR on exception path via JAL mechanism
                id_stage_id_ex_ctrl_signals_data_comb[CS_IsJR_B] = 1'b0;
                // BranchType might be left as is, but PC update logic will be overridden by exception vector.
            end
        end else begin // Either IF_ID_reg not valid OR data hazard stall detected
            // If IF_ID_reg is not valid, or if there's a data hazard, output of ID stage is effectively a NOP (invalid)
            id_stage_id_ex_valid_output_comb = 1'b0;
            id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; // All control bits to 0 (NOP)
            id_stage_id_ex_exception_code_data_comb = 2'b00; // No exception for a NOP caused by stall/invalid IF/ID
            // Other data fields don't matter if valid is 0
            id_stage_id_ex_op1_data_comb = 16'b0;
            id_stage_id_ex_op2_data_comb = 16'b0;
            id_stage_id_ex_rd_idx_data_comb = 4'b0;
            id_stage_id_ex_branch_target_data_comb = IF_ID_reg_pc;
            id_stage_id_ex_jr_target_data_comb = 16'b0;
        end
    end

    // Connect ALU inputs to ID_EX outputs (conceptually, EX stage uses these)
                    id_stage_id_ex_op2_data_comb = r[ry_s2_alu_rr_from_IF_ID];
                    if (op_specific_alu_rr_from_IF_ID == ALU_RR_SHL_SPEC || op_specific_alu_rr_from_IF_ID == ALU_RR_SHR_SPEC) begin
                        id_stage_id_ex_op2_data_comb = {12'b0, r[ry_s2_alu_rr_from_IF_ID][3:0]}; // Use lower 4 bits of Ry for shift amount
                    end
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_rr_from_IF_ID;
                end
                OPFAMILY_ADDI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1; // Reg-Imm
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;   // Is an ALU op
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT;
                    imm_processed_w = {{8{imm8_alu_ri_from_IF_ID[7]}}, imm8_alu_ri_from_IF_ID}; // Sign-extend
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_ANDI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1; // Reg-Imm
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;   // Is an ALU op
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_AND_4BIT;
                    imm_processed_w = {8'h00, imm8_alu_ri_from_IF_ID}; // Zero-extend
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_ORI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1; // Reg-Imm
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;   // Is an ALU op
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_OR_4BIT;
                    imm_processed_w = {8'h00, imm8_alu_ri_from_IF_ID}; // Zero-extend
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_XORI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1; // Reg-Imm
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1;   // Is an ALU op
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_XOR_4BIT;
                    imm_processed_w = {8'h00, imm8_alu_ri_from_IF_ID}; // Zero-extend
                    id_stage_id_ex_op1_data_comb = r[rx_dst_s1_alu_ri_from_IF_ID];
                    id_stage_id_ex_op2_data_comb = imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = rx_dst_s1_alu_ri_from_IF_ID;
                end
                OPFAMILY_LOAD: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_MemRead_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_MemToReg_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1; // Base address (reg) + offset (imm)
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT; // For address calculation
                    imm_processed_w = {{12{imm4_load_store_from_IF_ID[3]}}, imm4_load_store_from_IF_ID}; // Sign-extend offset
                    id_stage_id_ex_op1_data_comb = r[rs_addr_load_store_from_IF_ID]; // Base register
                    id_stage_id_ex_op2_data_comb = imm_processed_w; // Offset
                    id_stage_id_ex_rd_idx_data_comb = rt_load_store_from_IF_ID; // Destination register
                end
                OPFAMILY_STORE: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_MemWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUSrc_B] = 1'b1; // Base address (reg) + offset (imm)
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT; // For address calculation
                    imm_processed_w = {{12{imm4_load_store_from_IF_ID[3]}}, imm4_load_store_from_IF_ID}; // Sign-extend offset
                    id_stage_id_ex_op1_data_comb = r[rs_addr_load_store_from_IF_ID]; // Base register
                    id_stage_id_ex_op2_data_comb = imm_processed_w; // Offset
                    // For store, rd_idx is not used for writing back to reg file, but op2_data in EX_MEM will hold data to store
                    // The data to be stored (r[Rt]) needs to be read and passed.
                    // Let's use id_stage_id_ex_rd_idx_data_comb to pass Rt index, and EX stage will use it to read r[Rt]
                    // OR, read r[Rt] here and pass it in a dedicated field if op2 is already used for offset.
                    // For now, let's re-purpose op2_data for data to store, and op1 for address in EX.
                    // This is a common simplification, but makes EX stage more complex.
                    // A better way: EX_MEM_reg_op2_data_fwd is already for store data.
                    // So, we pass r[Rt] into what would become EX_MEM_reg_op2_data_fwd.
                    // id_stage_id_ex_op2_data_comb is used for address calculation with op1_data.
                    // We need to ensure that the value of r[rt_load_store_from_IF_ID] is passed to EX stage.
                    // Let's use id_stage_id_ex_op2_data_comb for the offset, and the EX stage will calculate address.
                    // The data r[Rt] will be read and put into ID_EX_reg_op2_data (overwriting immediate for this instruction type if ALUSrc was 1)
                    // This is tricky. Let's stick to:
                    // op1 = base_address_reg_val
                    // op2 = offset_immediate
                    // The actual data to store r[Rt] needs to be passed separately or handled in EX.
                    // The current ID_EX register has ID_EX_reg_op2_data.
                    // Let EX_MEM_reg_op2_data_fwd hold the store data.
                    // So, in ID, we need to read r[Rt] and prepare it for ID_EX_reg_op2_data (which becomes EX_MEM_reg_op2_data_fwd).
                    // And the immediate offset will be used with r[Rs] for ALU address calculation.
                    // This means for STORE, ALUSrc should be 1 (Reg+Imm for address), but op2_data for ID_EX_reg should be r[Rt].
                    // This is a conflict.
                    // Standard approach: ALU calculates address (Rs + imm). Data r[Rt] is passed separately.
                    // We can use ID_EX_reg_op2_data for the immediate (offset).
                    // And pass r[Rt] via another means, or ensure EX stage can get it.
                    // Given EX_MEM_reg_op2_data_fwd exists, ID stage should prepare r[Rt_data_to_store]
                    // and place it into a field that will eventually go into ID_EX_reg_op2_data.
                    // But ID_EX_reg_op2_data is also used for ALU op2.
                    // Let's refine:
                    // For STORE:
                    // id_stage_id_ex_op1_data_comb = r[rs_addr_load_store_from_IF_ID]; // Base Address
                    // id_stage_id_ex_op2_data_comb = {{12{imm4_load_store_from_IF_ID[3]}}, imm4_load_store_from_IF_ID}; // Offset for ALU
                    // The value r[rt_load_store_from_IF_ID] (data to store) needs to be passed to EX/MEM stage.
                    // We can send it through ID_EX_reg_ir and have EX extract it, or add a new field.
                    // For now, let's assume EX stage will re-read r[Rt] using ID_EX_reg_ir. This is simpler for ID.
                    // Or, more directly, pass r[Rt] in ID_EX_reg_op2_data, and ensure ALU uses a different source for offset if needed.
                    // Let's use the existing ID_EX_reg_op2_data to carry the STORE DATA (r[Rt]).
                    // The ALU will use ID_EX_reg_op1_data (base) and a new immediate field from ID_EX_reg_ir for offset.
                    // This requires changing how ALU gets its operands in EX.
                    // Simpler for now: ALU calculates Rs + offset(imm). The data to store r[Rt] is read here and put into ID_EX_reg_op2_data.
                    // This means for STORE, ALUSrc is technically for address calculation (Rs + imm), but op2 for ID_EX is data.
                    id_stage_id_ex_op1_data_comb = r[rs_addr_load_store_from_IF_ID]; // Rs (base address)
                                                                                // The immediate offset is in IF_ID_reg_ir[3:0]
                                                                                // The data to store is r[Rt]
                    id_stage_id_ex_op2_data_comb = r[rt_load_store_from_IF_ID];     // Rt (data to be stored)
                    // rd_idx is not used for writeback for STORE.
                    id_stage_id_ex_rd_idx_data_comb = rt_load_store_from_IF_ID; // Store Rt index, for EX to get offset from IR
                end
                OPFAMILY_LUI: begin
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_LUI_B] = 1'b1;
                    // ALU is not used, data is {imm8, 8'h00}
                    imm_processed_w = {imm8_lui_from_IF_ID, 8'h00};
                    // op1 can be zero, op2 is the immediate value for WB
                    id_stage_id_ex_op1_data_comb = 16'b0;
                    id_stage_id_ex_op2_data_comb = imm_processed_w; // This will go to wb_data via ALU path if MemToReg=0
                    id_stage_id_ex_rd_idx_data_comb = rt_lui_from_IF_ID;
                end
                OPFAMILY_JAL: begin // JAL imm12
                    id_stage_id_ex_ctrl_signals_data_comb[CS_RegWrite_B] = 1'b1; // Writes PC+1 to REG_LR
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsJAL_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH] = 4'b0001; // Example type for JAL
                    imm_processed_w = {{4{imm12_jal_from_IF_ID[11]}}, imm12_jal_from_IF_ID}; // Sign-extend
                    id_stage_id_ex_branch_target_data_comb = IF_ID_reg_pc + imm_processed_w;
                    id_stage_id_ex_rd_idx_data_comb = REG_LR; // Destination is REG_LR
                    // op1 and op2 not directly used by ALU for result, but PC+1 is generated for LR.
                    id_stage_id_ex_op1_data_comb = IF_ID_reg_pc; // For PC+1 calculation
                    id_stage_id_ex_op2_data_comb = 16'd1;        // For PC+1 calculation
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsALU_B] = 1'b1; // PC+1 is an ALU op
                                                                // ALUOp for ADD needs to be set if ALU used for PC+1
                    id_stage_id_ex_ctrl_signals_data_comb[CS_ALUOp_S +: CTRL_ALUOP_WIDTH] = OP_ADD_4BIT;
                end
                OPFAMILY_JR: begin // JR Rs
                    id_stage_id_ex_ctrl_signals_data_comb[CS_IsJR_B] = 1'b1;
                    id_stage_id_ex_ctrl_signals_data_comb[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH] = 4'b0010; // Example type for JR
                    id_stage_id_ex_jr_target_data_comb = r[rs_addr_jr_from_IF_ID];
                end
                OPFAMILY_JCOND: begin // JCOND cond, imm8
                    // Branch decision happens in EX. ID prepares target and control signals.
                    // Actual BranchType will also carry condition.
                    if (cond_jcond_from_IF_ID > 4'b1000 && cond_jcond_from_IF_ID != 4'b1111) begin // JMPA is 1000. Allow 1111 for potential future use if any.
                                                                                                   // For now, >1000 is invalid unless specific cases handled.
                                                                                                   // The prompt implies > 4'b1000 is invalid.
                        id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}};
                        id_stage_id_ex_exception_code_data_comb[0] = 1'b1;
                    end else begin
                        id_stage_id_ex_ctrl_signals_data_comb[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH] = {cond_jcond_from_IF_ID};
                        imm_processed_w = {{8{imm8_jcond_from_IF_ID[7]}}, imm8_jcond_from_IF_ID}; // Sign-extend
                        id_stage_id_ex_branch_target_data_comb = IF_ID_reg_pc + imm_processed_w;
                    end
                end
                OPFAMILY_ALU_RR_EXT: begin // Reserved
                    id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}};
                    id_stage_id_ex_exception_code_data_comb[0] = 1'b1;
                end
                // OpFamilies 0110, 0111 reserved for R-I ALU
                4'b0110: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; end
                4'b0111: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; end
                // OpFamilies 1010, 1011 reserved for Mem Ops
                4'b1010: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; end
                4'b1011: begin id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; id_stage_id_ex_exception_code_data_comb[0] = 1'b1; end
                default: begin // This default should ideally not be hit if all op_families are covered or explicitly reserved
                    // However, if somehow reached, treat as invalid.
                    if (op_family_from_IF_ID != OPFAMILY_ALU_RR && op_family_from_IF_ID != OPFAMILY_ADDI &&
                        op_family_from_IF_ID != OPFAMILY_ANDI && op_family_from_IF_ID != OPFAMILY_ORI &&
                        op_family_from_IF_ID != OPFAMILY_XORI && op_family_from_IF_ID != OPFAMILY_LOAD &&
                        op_family_from_IF_ID != OPFAMILY_STORE && op_family_from_IF_ID != OPFAMILY_LUI &&
                        op_family_from_IF_ID != OPFAMILY_JAL && op_family_from_IF_ID != OPFAMILY_JR &&
                        op_family_from_IF_ID != OPFAMILY_JCOND && op_family_from_IF_ID != OPFAMILY_ALU_RR_EXT) begin
                        id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}};
                        id_stage_id_ex_exception_code_data_comb[0] = 1'b1;
                    end
                end
            endcase
        end else begin // Either IF_ID_reg not valid OR data hazard stall detected
            // If IF_ID_reg is not valid, or if there's a data hazard, output of ID stage is effectively a NOP (invalid)
            id_stage_id_ex_valid_output_comb = 1'b0;
            id_stage_id_ex_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; // All control bits to 0 (NOP)
            id_stage_id_ex_exception_code_data_comb = 2'b00; // No exception for a NOP caused by stall/invalid IF/ID
            // Other data fields don't matter if valid is 0
            id_stage_id_ex_op1_data_comb = 16'b0;
            id_stage_id_ex_op2_data_comb = 16'b0;
            id_stage_id_ex_rd_idx_data_comb = 4'b0;
            id_stage_id_ex_branch_target_data_comb = IF_ID_reg_pc;
            id_stage_id_ex_jr_target_data_comb = 16'b0;
        end
    end

    // Connect ALU inputs to ID_EX outputs (conceptually, EX stage uses these)
    // These are now driven by ID_EX_reg_* not the combinational wires from ID stage.
    // assign alu_op1_from_ID_EX = ID_EX_reg_op1_data; // Replaced by muxed operand
    // assign alu_op2_from_ID_EX = ID_EX_reg_op2_data; // Replaced by muxed operand
    // ALU op needs to be extracted from ID_EX_reg_ctrl_signals
    assign alu_op_internal_from_ID_EX = ID_EX_reg_ctrl_signals[CS_ALUOp_S +: CTRL_ALUOP_WIDTH];


    // EX Stage Output Logic (feeds EX_MEM_reg)
    always_comb begin
        // Default assignments for EX stage combinational outputs
        ex_stage_ex_mem_valid_output_comb = ID_EX_reg_valid; // Pass valid signal by default
        ex_stage_ex_mem_pc_data_comb = ID_EX_reg_pc;
        ex_stage_ex_mem_ir_data_comb = ID_EX_reg_ir;
        ex_stage_ex_mem_rd_idx_data_comb = ID_EX_reg_rd_idx;
        ex_stage_ex_mem_ctrl_signals_data_comb = ID_EX_reg_ctrl_signals; // Pass through control signals
        ex_stage_ex_mem_op2_data_fwd_data_comb = ID_EX_reg_op2_data;   // Forward op2 (used for store data)
        ex_stage_ex_mem_alu_flags_data_comb = alu_flags_out;       // Capture ALU flags output
        ex_stage_ex_mem_exception_code_data_comb = ID_EX_reg_exception_code; // Pass through exception code

        ex_stage_ex_mem_branch_taken_data_comb = 1'b0;             // Default to no branch/jump taken
        ex_stage_ex_mem_final_branch_target_data_comb = 16'bx;     // Default target (don't care)

        // ALU output assignment: Default to alu_out from the ALU module
        ex_stage_ex_mem_alu_out_data_comb = alu_out;

        // Forwarding Logic
        ex_stage_fwd_A_select_comb = 2'b00; // Default: no forwarding for OpA
        ex_stage_fwd_B_select_comb = 2'b00; // Default: no forwarding for OpB

        // Source register indices for the instruction currently IN EX STAGE (from ID_EX_reg_ir)
        wire [3:0] ex_rs1_idx;
        wire [3:0] ex_rs2_idx;
        wire ex_reads_rs1;
        wire ex_reads_rs2;
        wire [3:0] ex_op_family = ID_EX_reg_ir[15:12];

        // Determine rs1, rs2 for the instruction in EX
        ex_rs1_idx = (ex_op_family == OPFAMILY_ALU_RR) ? ID_EX_reg_ir[7:4] :
                     (ex_op_family == OPFAMILY_ADDI || ex_op_family == OPFAMILY_ANDI ||
                      ex_op_family == OPFAMILY_ORI  || ex_op_family == OPFAMILY_XORI) ? ID_EX_reg_ir[11:8] :
                     (ex_op_family == OPFAMILY_LOAD || ex_op_family == OPFAMILY_STORE) ? ID_EX_reg_ir[7:4] :
                     (ex_op_family == OPFAMILY_JR) ? ID_EX_reg_ir[11:8] :
                     4'b0;
        ex_reads_rs1 = (ex_op_family == OPFAMILY_ALU_RR ||
                       ex_op_family == OPFAMILY_ADDI || ex_op_family == OPFAMILY_ANDI ||
                       ex_op_family == OPFAMILY_ORI  || ex_op_family == OPFAMILY_XORI ||
                       ex_op_family == OPFAMILY_LOAD || ex_op_family == OPFAMILY_STORE ||
                       ex_op_family == OPFAMILY_JR);

        ex_rs2_idx = (ex_op_family == OPFAMILY_ALU_RR) ? ID_EX_reg_ir[3:0] :
                     (ex_op_family == OPFAMILY_STORE) ? ID_EX_reg_ir[11:8] : // For STORE, Rt (data source) is like rs2
                     4'b0;
        ex_reads_rs2 = (ex_op_family == OPFAMILY_ALU_RR || ex_op_family == OPFAMILY_STORE);


        // Forwarding for ALU Operand A (ex_stage_alu_operand_A_comb)
        if (ex_reads_rs1 && ex_rs1_idx != 0) begin // Only forward if rs1 is used and not R0
            // Check against instruction in MEM stage (EX_MEM_reg)
            if (EX_MEM_reg_valid && EX_MEM_reg_ctrl_signals[CS_RegWrite_B] && (EX_MEM_reg_rd_idx == ex_rs1_idx)) begin
                ex_stage_fwd_A_select_comb = 2'b01; // Forward from EX/MEM result
            end
            // Check against instruction in WB stage (MEM_WB_reg)
            else if (MEM_WB_reg_valid && MEM_WB_reg_ctrl_signals[CS_RegWrite_B] && (MEM_WB_reg_rd_idx == ex_rs1_idx)) begin
                ex_stage_fwd_A_select_comb = 2'b10; // Forward from MEM/WB result
            end
        end

        // Forwarding for ALU Operand B (ex_stage_alu_operand_B_comb)
        // Only if ALUSrc is Reg-Reg (i.e., op2 is not an immediate)
        if (ex_reads_rs2 && ex_rs2_idx != 0 && ID_EX_reg_ctrl_signals[CS_ALUSrc_B] == 1'b0) begin
            if (EX_MEM_reg_valid && EX_MEM_reg_ctrl_signals[CS_RegWrite_B] && (EX_MEM_reg_rd_idx == ex_rs2_idx)) begin
                ex_stage_fwd_B_select_comb = 2'b01;
            end
            else if (MEM_WB_reg_valid && MEM_WB_reg_ctrl_signals[CS_RegWrite_B] && (MEM_WB_reg_rd_idx == ex_rs2_idx)) begin
                ex_stage_fwd_B_select_comb = 2'b10;
            end
        end

        // ALU Operand Muxing
        case (ex_stage_fwd_A_select_comb)
            2'b00:  ex_stage_alu_operand_A_comb = ID_EX_reg_op1_data;
            2'b01:  ex_stage_alu_operand_A_comb = EX_MEM_reg_alu_out; // Data from EX/MEM alu result
            2'b10:  ex_stage_alu_operand_A_comb = MEM_WB_reg_wb_data; // Data from MEM/WB write-back data
            default: ex_stage_alu_operand_A_comb = ID_EX_reg_op1_data; // Should not happen
        endcase

        if (ID_EX_reg_ctrl_signals[CS_ALUSrc_B] == 1'b1) begin // Operand B is an immediate
            ex_stage_alu_operand_B_comb = ID_EX_reg_op2_data; // op2_data from ID/EX holds the immediate
        end else begin // Operand B is from register file (or forwarded)
            case (ex_stage_fwd_B_select_comb)
                2'b00:  ex_stage_alu_operand_B_comb = ID_EX_reg_op2_data; // op2_data from ID/EX holds r[rs2]
                2'b01:  ex_stage_alu_operand_B_comb = EX_MEM_reg_alu_out;
                2'b10:  ex_stage_alu_operand_B_comb = MEM_WB_reg_wb_data;
                default: ex_stage_alu_operand_B_comb = ID_EX_reg_op2_data;
            endcase
        end


        // Specific handling based on instruction type (via control signals from ID/EX)
        if (ID_EX_reg_valid) begin
            // LUI: output is from ID_EX_reg_op2_data, not ALU. ALU result is not used.
            if (ID_EX_reg_ctrl_signals[CS_LUI_B]) begin
                ex_stage_ex_mem_alu_out_data_comb = ID_EX_reg_op2_data;
            end
            // For other ALU ops, ex_stage_ex_mem_alu_out_data_comb = alu_out (default) is correct.
            // For LOAD/STORE, alu_out is the effective address.

            // Branch and Jump Logic
            if (ID_EX_reg_ctrl_signals[CS_IsJAL_B]) begin
                ex_stage_ex_mem_branch_taken_data_comb = 1'b1;
                ex_stage_ex_mem_final_branch_target_data_comb = ID_EX_reg_branch_target;
                // For JAL, ALU calculates PC+1. This result is in alu_out.
                // This alu_out (PC+1) should be the data written to REG_LR.
                // If MemToReg is 0, alu_out goes to WB. This is correct.
                // Rd for JAL is REG_LR, set in ID stage.
            end
            // JR (Jump Register)
            else if (ID_EX_reg_ctrl_signals[CS_IsJR_B]) begin
                ex_stage_ex_mem_branch_taken_data_comb = 1'b1;
                ex_stage_ex_mem_final_branch_target_data_comb = ID_EX_reg_jr_target;
            end
            // JCOND (Conditional Jump)
            // Check BranchType for JCOND variants. Non-zero BranchType that is not JAL/JR implies JCOND.
            else if (ID_EX_reg_ctrl_signals[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH] != 4'b0000 &&
                     !ID_EX_reg_ctrl_signals[CS_IsJAL_B] &&
                     !ID_EX_reg_ctrl_signals[CS_IsJR_B]) begin

                // For JCOND, op1_data from ID/EX should contain r[REG_FLG] as per simplified plan.
                // This is a significant simplification. A real CPU would use forwarded/latched flags.
                wire [3:0] current_flags = ID_EX_reg_op1_data[3:0]; // Assuming FLG is in lower 4 bits of op1 for JCOND
                wire flag_C = current_flags[0];
                wire flag_Z = current_flags[1];
                wire flag_S = current_flags[2];
                wire flag_O = current_flags[3];
                reg is_true_cond_local; // Use a local reg for intermediate assignment

                // Extract condition code from the BranchType field of control signals
                wire [3:0] cond_code = ID_EX_reg_ctrl_signals[CS_BranchType_S +: CTRL_BRANCHTYPE_WIDTH];

                case (cond_code)
                    // From ISA: JZ=0, JNZ=1, JC=2, JNC=3, JS=4, JNS=5, JO=6, JNO=7, JMPA=8
                    4'b0000: is_true_cond_local = flag_Z;    // JZ (Z=1)
                    4'b0001: is_true_cond_local = ~flag_Z;   // JNZ (Z=0)
                    4'b0010: is_true_cond_local = flag_C;    // JC (C=1)
                    4'b0011: is_true_cond_local = ~flag_C;   // JNC (C=0)
                    4'b0100: is_true_cond_local = flag_S;    // JS (S=1)
                    4'b0101: is_true_cond_local = ~flag_S;   // JNS (S=0)
                    4'b0110: is_true_cond_local = flag_O;    // JO (O=1)
                    4'b0111: is_true_cond_local = ~flag_O;   // JNO (O=0)
                    4'b1000: is_true_cond_local = 1'b1;      // JMPA (Always)
                    default: is_true_cond_local = 1'b0;     // Reserved/Invalid condition - do not branch
                endcase

                if (is_true_cond_local) begin
                    ex_stage_ex_mem_branch_taken_data_comb = 1'b1;
                    ex_stage_ex_mem_final_branch_target_data_comb = ID_EX_reg_branch_target;
                end
            end
        end else begin
            // If ID_EX_reg is not valid, ensure outputs are benign
            ex_stage_ex_mem_valid_output_comb = 1'b0;
            ex_stage_ex_mem_ctrl_signals_data_comb = {ID_EX_CTRL_WIDTH{1'b0}}; // Zero out controls
            ex_stage_ex_mem_branch_taken_data_comb = 1'b0;
            ex_stage_ex_mem_alu_out_data_comb = 16'b0;
            ex_stage_ex_mem_alu_flags_data_comb = 4'b0;
            ex_stage_ex_mem_op2_data_fwd_data_comb = 16'b0;
        end
    end

    // MEM Stage Output Logic (feeds MEM_WB_reg)
    always_comb begin
        // Default assignments for combinational outputs
        mem_stage_mem_wb_pc_data_comb = EX_MEM_reg_pc;
        mem_stage_mem_wb_ir_data_comb = EX_MEM_reg_ir;
        mem_stage_mem_wb_rd_idx_data_comb = EX_MEM_reg_rd_idx;
        mem_stage_mem_wb_ctrl_signals_data_comb = EX_MEM_reg_ctrl_signals; // Pass through
        mem_stage_mem_wb_alu_flags_data_comb = EX_MEM_reg_alu_flags;     // Pass through
        mem_stage_mem_wb_exception_code_data_comb = EX_MEM_reg_exception_code; // Pass through existing exception code

        // Internal memory control signals - default to not accessing memory
        mem_stage_mem_en_comb_internal = 1'b0;
        mem_stage_mem_write_comb_internal = 1'b0;
        mem_stage_addr_bus_comb_internal = EX_MEM_reg_alu_out; // Address is from ALU output (for L/S)
        mem_stage_data_out_comb_internal = EX_MEM_reg_op2_data_fwd; // Data to store is from EX/MEM fwd reg

        // Default data for write-back is ALU result
        mem_stage_mem_wb_wb_data_data_comb = EX_MEM_reg_alu_out;

        // Default valid output
        mem_stage_mem_wb_valid_output_comb = EX_MEM_reg_valid; // Assume valid if EX_MEM was valid, unless stalled by mem_ready

        wire mem_stage_bad_address_comb = 1'b0; // Local wire for bad address detection

        if (EX_MEM_reg_valid) begin
            // Check for bad address if a memory operation is active
            if (EX_MEM_reg_ctrl_signals[CS_MemRead_B] || EX_MEM_reg_ctrl_signals[CS_MemWrite_B]) begin
                mem_stage_mem_en_comb_internal = 1'b1;
                mem_stage_mem_write_comb_internal = EX_MEM_reg_ctrl_signals[CS_MemWrite_B];
                // mem_stage_addr_bus_comb_internal is already EX_MEM_reg_alu_out

                // Address validation (example ranges from original FSM)
                // Valid RAM: 0x0000 - 0x07FF
                // Valid I/O: 0x1000 - 0x13FF
                if (!((mem_stage_addr_bus_comb_internal >= 16'h0000 && mem_stage_addr_bus_comb_internal <= 16'h07FF) ||
                      (mem_stage_addr_bus_comb_internal >= 16'h1000 && mem_stage_addr_bus_comb_internal <= 16'h13FF))) begin
                    mem_stage_bad_address_comb = 1'b1;
                end

                if (mem_stage_bad_address_comb) begin
                    mem_stage_mem_wb_exception_code_data_comb = EX_MEM_reg_exception_code | 2'b10; // Set bad address bit, keep existing ones
                    mem_stage_mem_wb_valid_output_comb = 1'b1; // Propagate exception, don't stall here for bad addr
                    mem_stage_mem_en_comb_internal = 1'b0; // Suppress memory enable if bad address
                    mem_stage_mem_write_comb_internal = 1'b0; // Suppress memory write if bad address
                end else begin
                    // LOAD operation
                    if (EX_MEM_reg_ctrl_signals[CS_MemRead_B]) begin
                        if (mem_ready) begin
                            mem_stage_mem_wb_wb_data_data_comb = data_in; // Data from memory
                            mem_stage_mem_wb_valid_output_comb = 1'b1;    // Valid data is ready
                        end else {
                            mem_stage_mem_wb_valid_output_comb = 1'b0; // Stall, waiting for memory
                        }
                    end
                    // STORE operation
                    else if (EX_MEM_reg_ctrl_signals[CS_MemWrite_B]) begin
                        if (mem_ready) begin
                            mem_stage_mem_wb_valid_output_comb = 1'b1; // Store op considered "done" for pipeline
                        end else {
                            mem_stage_mem_wb_valid_output_comb = 1'b0; // Stall, waiting for memory
                        }
                    end
                end
            end
            // For non-memory ops, wb_data is EX_MEM_reg_alu_out, valid is EX_MEM_reg_valid.
            // Exception code is passed through.
        end else begin // If EX_MEM not valid
            mem_stage_mem_wb_valid_output_comb = 1'b0;
            mem_stage_mem_en_comb_internal = 1'b0;
            mem_stage_mem_write_comb_internal = 1'b0;
        end
    end

    // WB Stage is implicitly handled by the clocked logic writing to r[] from MEM_WB_reg

endmodule
