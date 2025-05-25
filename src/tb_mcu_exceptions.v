`timescale 1ns / 1ps

module tb_mcu_exceptions;

    // MCU Interface
    reg clk;
    reg reset;
    reg [15:0] data_in;
    reg mem_ready;

    wire [15:0] addr_bus;
    wire mem_en;
    wire write_en;
    wire [15:0] data_out;
    wire [2:0] dbg_state;    // MCU internal state
    wire [31:0] dbg_signals;  // MCU debug signals {PC, IR}

    // Instantiate the MCU
    MCU dut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .mem_ready(mem_ready),
        .addr_bus(addr_bus),
        .mem_en(mem_en),
        .write_en(write_en),
        .data_out(data_out),
        .dbg_state(dbg_state),
        .dbg(dbg_signals)
    );

    // Clock Generation
    localparam CLK_PERIOD = 10; // 10ns period for a 100MHz clock
    always # (CLK_PERIOD / 2) clk = ~clk;

    // Testbench Memory Model
    reg [15:0] instruction_memory [0:255];
    reg [15:0] data_memory [0:15]; // For addresses 0x2000-0x200F
    localparam DATA_MEM_BASE_ADDR = 16'h2000;
    localparam DATA_MEM_SIZE = 16;

    // Task to load instructions into memory
    task load_instruction;
        input [15:0] address;
        input [15:0] instruction;
        begin
            if (address < 256) begin
                instruction_memory[address] = instruction;
            end else begin
                $display("%0t: TB ERROR: Attempt to load instruction out of instruction_memory bounds: %h", $time, address);
            end
        end
    endtask
    
    // Memory Interaction Logic
    always @(posedge clk) begin
        if (!reset) begin // Only respond if not in reset
            if (mem_en) begin
                mem_ready <= 1'b1; // Assert mem_ready one cycle after mem_en
                if (!write_en) begin // Read operation
                    if (addr_bus < 256) begin // Assuming instruction fetches are from this range
                        data_in <= instruction_memory[addr_bus];
                    end else if (addr_bus >= DATA_MEM_BASE_ADDR && addr_bus < (DATA_MEM_BASE_ADDR + DATA_MEM_SIZE)) begin
                        // This part of memory model is for data, not typically instruction fetch
                        // but MCU might try to read data from here if LOAD uses these addresses
                        data_in <= data_memory[addr_bus - DATA_MEM_BASE_ADDR];
                    end else begin
                        data_in <= 16'hDEAD; // Default for out-of-bounds read
                    end
                end else begin // Write operation
                    // Check if write is to the modeled data_memory region
                    if (addr_bus >= DATA_MEM_BASE_ADDR && addr_bus < (DATA_MEM_BASE_ADDR + DATA_MEM_SIZE)) begin
                         // The actual write happens only if mem_ready was high in the previous cycle of mem_en
                         // This logic is slightly simplified: if MCU asserts write_en, and it's a valid cycle, we'd write.
                         // The MCU's bad_address_error should prevent write_en for bad addresses.
                         // This TB memory model will reflect a write if MCU *actually* drives write_en high.
                        data_memory[addr_bus - DATA_MEM_BASE_ADDR] <= data_out;
                        $display("%0t: TB: Memory Write to data_memory[%h] with %h", $time, addr_bus - DATA_MEM_BASE_ADDR, data_out);
                    end
                end
            end else begin
                mem_ready <= 1'b0;
            end
        end else begin // In reset
            mem_ready <= 1'b0;
        end
    end

    // Test Sequences
    initial begin
        clk = 0;
        reset = 1;
        mem_ready = 0;
        data_in = 0;

        integer i;
        for (i = 0; i < DATA_MEM_SIZE; i = i + 1) begin
            data_memory[i] = 16'h0000; // Clear data memory
        end
        for (i = 0; i < 256; i = i + 1) begin
            instruction_memory[i] = 16'h0000; // Clear instruction memory (NOP)
        end

        // Apply reset
        #(CLK_PERIOD * 2) reset = 0; // De-assert reset
        #(CLK_PERIOD * 2) reset = 1; // Assert reset to ensure PC is 0
        #(CLK_PERIOD * 2) reset = 0; // De-assert reset
        
        #(CLK_PERIOD * 5); // Wait for MCU to stabilize

        // --- Scenario 1: Invalid Instruction ---
        $display("\n%0t: --- Scenario 1: Invalid Instruction ---", $time);
        load_instruction(16'h0000, 16'h2001); // ADDI R0, 1 (valid, R0=1, to see PC increment once)
        load_instruction(16'h0001, 16'hA000); // Invalid OpFamily 1010 (should cause exception)
        load_instruction(dut.EXCEPTION_VECTOR, 16'h0000); // Exception Handler (NOP)

        #(CLK_PERIOD * 35); // Time for: fetch, decode, exec (addi) -> fetch, decode (invalid) -> exception handling

        $display("%0t: TB: Scenario 1 Verification: PC=%h, LR=%h, R0=%h", $time, dut.r[dut.REG_PC], dut.r[dut.REG_LR], dut.r[0]);
        $display("%0t: TB: MCU Signals: invalid_instr_err_sig=%b, bad_addr_err_sig=%b, exc_active_sig=%b, captured_pc_sig=%h",
                 $time, dut.invalid_instruction_error, dut.bad_address_error, dut.exception_active, dut.captured_pc_for_exception);

        if (dut.r[dut.REG_LR] == 16'h0001 && dut.r[dut.REG_PC] == dut.EXCEPTION_VECTOR) begin
            $display("%0t: TB: Scenario 1 PASSED!", $time);
        end else begin
            $display("%0t: TB: Scenario 1 FAILED! PC=%h (expected %h), LR=%h (expected %h)",
                     $time, dut.r[dut.REG_PC], dut.EXCEPTION_VECTOR, dut.r[dut.REG_LR], 16'h0001);
        end

        // Reset for next scenario
        reset = 1; #(CLK_PERIOD * 5); reset = 0; #(CLK_PERIOD * 5);
        for (i = 0; i < DATA_MEM_SIZE; i = i + 1) data_memory[i] = 16'h0000; // Clear data memory

        // --- Scenario 2: Bad Address (LOAD) ---
        $display("\n%0t: --- Scenario 2: Bad Address (LOAD) ---", $time);
        // Setup: R0 = 16'h2000 (bad address for data load as per MCU ranges)
        // Instruction sequence:
        // 0x0000: LUI R0, 0x20 (1100 0000 00100000 -> 0xC020)  ; R0 = 0x2000
        // 0x0001: LOAD R1, 0(R0) (1000 0001 0000 0000 -> 0x8100) ; Load from 0x2000 (bad)
        load_instruction(16'h0000, 16'hC020);
        load_instruction(16'h0001, 16'h8100);
        load_instruction(dut.EXCEPTION_VECTOR, 16'h0000); // Exception Handler (NOP)
        
        #(CLK_PERIOD * 40);

        $display("%0t: TB: Scenario 2 Verification: PC=%h, LR=%h, R0=%h, R1=%h", $time, dut.r[dut.REG_PC], dut.r[dut.REG_LR], dut.r[0], dut.r[1]);
        $display("%0t: TB: MCU Signals: invalid_instr_err_sig=%b, bad_addr_err_sig=%b, exc_active_sig=%b, captured_pc_sig=%h",
                 $time, dut.invalid_instruction_error, dut.bad_address_error, dut.exception_active, dut.captured_pc_for_exception);

        if (dut.r[dut.REG_LR] == 16'h0001 && dut.r[dut.REG_PC] == dut.EXCEPTION_VECTOR && dut.r[1] == 16'h0000) begin
            $display("%0t: TB: Scenario 2 PASSED!", $time);
        end else begin
            $display("%0t: TB: Scenario 2 FAILED! PC=%h (exp %h), LR=%h (exp %h), R1=%h (exp 0)",
                     $time, dut.r[dut.REG_PC], dut.EXCEPTION_VECTOR, dut.r[dut.REG_LR], 16'h0001, dut.r[1]);
        end
        
        // Reset for next scenario
        reset = 1; #(CLK_PERIOD * 5); reset = 0; #(CLK_PERIOD * 5);
        for (i = 0; i < DATA_MEM_SIZE; i = i + 1) data_memory[i] = 16'h0000;

        // --- Scenario 3: Bad Address (STORE) ---
        $display("\n%0t: --- Scenario 3: Bad Address (STORE) ---", $time);
        // Setup: R0 = 16'h2004 (bad address), R1 = 16'hBEEF (data)
        // Instruction sequence:
        // 0x0000: LUI R0, 0x20   (0xC020)         ; R0 = 0x2000
        // 0x0001: ADDI R0, R0, 4 (0x2004)         ; R0 = 0x2004
        // 0x0002: LUI R1, 0xBE   (0xC1BE)         ; R1 = 0xBE00
        // 0x0003: ORI R1, R1, 0xEF (0x41EF)       ; R1 = 0xBEEF (R1 = R1 | 0x00EF)
        // 0x0004: STORE R1, 0(R0) (0x9100)        ; Store R1 to addr R0 (0x2004)
        load_instruction(16'h0000, 16'hC020);
        load_instruction(16'h0001, 16'h2004); // ADDI R0, R0, 4 (OpFamily 0010)
        load_instruction(16'h0002, 16'hC1BE);
        load_instruction(16'h0003, 16'h41EF); // ORI R1, R1, 0xEF (OpFamily 0100)
        load_instruction(16'h0004, 16'h9100);
        load_instruction(dut.EXCEPTION_VECTOR, 16'h0000); // Exception Handler (NOP)

        #(CLK_PERIOD * 60); // Increased time for more setup instructions

        $display("%0t: TB: Scenario 3 Verification: PC=%h, LR=%h, R0=%h, R1=%h", $time, dut.r[dut.REG_PC], dut.r[dut.REG_LR], dut.r[0], dut.r[1]);
        $display("%0t: TB: Data memory at 0x2004 (data_memory[4]): %h", $time, data_memory[4]);
        $display("%0t: TB: MCU Signals: invalid_instr_err_sig=%b, bad_addr_err_sig=%b, exc_active_sig=%b, captured_pc_sig=%h",
                 $time, dut.invalid_instruction_error, dut.bad_address_error, dut.exception_active, dut.captured_pc_for_exception);
        
        if (dut.r[dut.REG_LR] == 16'h0004 && dut.r[dut.REG_PC] == dut.EXCEPTION_VECTOR && data_memory[4] == 16'h0000) begin
            $display("%0t: TB: Scenario 3 PASSED!", $time);
        end else begin
            $display("%0t: TB: Scenario 3 FAILED! PC=%h (exp %h), LR=%h (exp %h), Mem[0x2004]=%h (exp 0000)",
                     $time, dut.r[dut.REG_PC], dut.EXCEPTION_VECTOR, dut.r[dut.REG_LR], 16'h0004, data_memory[4]);
        end

        $display("\n%0t: --- Testbench All Scenarios Finished ---", $time);
        $finish;
    end

    // Optional: Monitor signals for debugging
    /*
    initial begin
        $monitor("%0t: CLK=%b RST=%b PC=%h IR=%h LR=%h FLG=%h R0=%h R1=%h | MEM: en=%b wr=%b addr=%h dout=%h din=%h rdy=%b | DBG: state=%b inv_err=%b bad_err=%b exc_act=%b cap_pc=%h",
                 $time, clk, reset, dut.r[dut.REG_PC], dut.ir, dut.r[dut.REG_LR], dut.r[dut.REG_FLG], dut.r[0], dut.r[1],
                 mem_en, write_en, addr_bus, data_out, data_in, mem_ready,
                 dbg_state, dut.invalid_instruction_error, dut.bad_address_error, dut.exception_active, dut.captured_pc_for_exception);
    end
    */

endmodule
