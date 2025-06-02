`timescale 1ns / 1ps

module tb_mcu_pipeline_basic;

    // MCU Interface
    reg clk;
    reg reset;
    reg [15:0] data_in;
    reg mem_ready;

    wire [15:0] addr_bus;
    wire mem_en;
    wire write_en;
    wire [15:0] data_out;
    // Note: dbg_state and dbg signals from MCU are currently tied off in pipelined MCU
    // wire [2:0] dbg_state;
    // wire [31:0] dbg_signals;

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
        .dbg_state(/*dbg_state*/), // Connect to dummy if needed, or remove from MCU if truly unused
        .dbg(/*dbg_signals*/)      // Connect to dummy if needed
    );

    // Clock Generation
    localparam CLK_PERIOD = 10; // 10ns period for a 100MHz clock
    always # (CLK_PERIOD / 2) clk = ~clk;

    // Testbench Memory Model
    reg [15:0] instruction_memory [0:255];
    reg [15:0] data_memory [0:15];
    localparam DATA_MEM_BASE_ADDR = 16'h0200; // Base address for data_memory
    localparam DATA_MEM_SIZE = 16;

    // Task to load instructions into memory
    task load_instruction;
        input [15:0] address;
        input [15:0] instruction;
        begin
            if (address < 256) begin
                instruction_memory[address] = instruction;
                $display("TB: Loaded instruction %h at address %h", instruction, address);
            end else begin
                $display("%0t: TB ERROR: Attempt to load instruction out of instruction_memory bounds: %h", $time, address);
            end
        end
    endtask

    // Memory Interaction Logic
    always @(posedge clk) begin
        if (!reset) begin
            if (mem_en) begin
                mem_ready <= 1'b0; // Default to not ready for this cycle if mem_en just went high
                #(CLK_PERIOD/4); // Simulate memory access delay before ready (can be 0 for faster memory)
                                 // Or make mem_ready asserted one full cycle later for simplicity
                                 // For this simple TB, let's make it ready in the same cycle if address is valid.
                                 // This is simpler than the previous tb_mcu_exceptions

                if (!write_en) begin // Read operation
                    if (addr_bus < 256) begin
                        data_in <= instruction_memory[addr_bus];
                        mem_ready <= 1'b1;
                        $display("TB: Read Instr Mem Addr: %h, Data: %h", addr_bus, instruction_memory[addr_bus]);
                    end else if (addr_bus >= DATA_MEM_BASE_ADDR && addr_bus < (DATA_MEM_BASE_ADDR + DATA_MEM_SIZE)) begin
                        data_in <= data_memory[addr_bus - DATA_MEM_BASE_ADDR];
                        mem_ready <= 1'b1;
                        $display("TB: Read Data Mem Addr: %h, Data: %h", addr_bus, data_memory[addr_bus - DATA_MEM_BASE_ADDR]);
                    end else begin
                        data_in <= 16'hDEAD;
                        mem_ready <= 1'b1; // Still signal ready, but with potentially junk data for bad read addr
                        $display("TB: Read Out-of-Bounds Addr: %h", addr_bus);
                    end
                end else begin // Write operation
                    if (addr_bus >= DATA_MEM_BASE_ADDR && addr_bus < (DATA_MEM_BASE_ADDR + DATA_MEM_SIZE)) begin
                        data_memory[addr_bus - DATA_MEM_BASE_ADDR] <= data_out;
                        mem_ready <= 1'b1;
                        $display("TB: Write Data Mem Addr: %h, Data: %h", addr_bus, data_out);
                    end else begin
                        mem_ready <= 1'b1; // Signal ready even for bad write addr, MCU should handle error
                        $display("TB: Write Out-of-Bounds Addr: %h, Data: %h", addr_bus, data_out);
                    end
                end
            end else begin
                mem_ready <= 1'b0;
            end
        end else begin
            mem_ready <= 1'b0;
        end
    end

    // Test Sequences
    initial begin
        $dumpfile("tb_mcu_pipeline_basic.vcd");
        $dumpvars(0, tb_mcu_pipeline_basic);

        clk = 0;
        reset = 1;
        mem_ready = 0;
        data_in = 0;

        integer i;
        for (i = 0; i < DATA_MEM_SIZE; i = i + 1) begin
            data_memory[i] = 16'h0000;
        end
        for (i = 0; i < 256; i = i + 1) begin
            instruction_memory[i] = 16'h0000; // NOP
        end

        // Preload data memory
        data_memory[0] = 16'hBEEF; // For the LOAD instruction test
        $display("TB: Preloaded data_memory[0] with %h", data_memory[0]);

        // Load the simple program
        load_instruction(16'h0000, 16'hC1AA); // LUI R1, 0xAA
        load_instruction(16'h0001, 16'h2155); // ADDI R1, R1, 0x55
        load_instruction(16'h0002, 16'hC2BB); // LUI R2, 0xBB
        load_instruction(16'h0003, 16'h2211); // ADDI R2, R2, 0x11
        load_instruction(16'h0004, 16'h0112); // ADD R1, R2 (R1 = R1+R2)
        load_instruction(16'h0005, 16'h2311); // ADDI R3, R1, 1
        load_instruction(16'h0006, 16'hC502); // LUI R5, 0x02 (for DATA_MEM_BASE_ADDR=0x0200)
        load_instruction(16'h0007, 16'h8650); // LOAD R6, 0(R5) (from data_memory[0])
        load_instruction(16'h0008, 16'h2761); // ADDI R7, R6, 1
        load_instruction(16'h0009, 16'hF801); // JMPA +1 (PC = PC + 1 + 1 = PC+2 effectively)
        load_instruction(16'h000A, 16'hC9FF); // LUI R9, 0xFF (skipped)
        load_instruction(16'h000B, 16'h0000); // NOP (target of JMPA)
        load_instruction(16'h000C, 16'hE000); // JR R0 (Halt if R0 is 0)
        load_instruction(16'h000D, 16'h0000); // NOP
        load_instruction(16'h000E, 16'h0000); // NOP
        load_instruction(16'h000F, 16'h0000); // NOP


        // Apply reset
        #(CLK_PERIOD * 2) reset = 0;
        #(CLK_PERIOD * 2) reset = 1;
        #(CLK_PERIOD * 2) reset = 0;

        // Run for a fixed number of cycles
        // Program has ~13 instructions. Pipelined: 13+5-1 = 17 cycles ideal.
        // Add some for stalls (load-use + JMPA)
        // Let's run for 40 cycles.
        #(CLK_PERIOD * 60);

        // Display final register values (example)
        $display("\n%0t: --- Simulation Finished ---", $time);
        $display("TB: Final PC = %h", dut.r[dut.REG_PC]);
        $display("TB: R1 = %h (expected 0x6566 after ADD)", dut.r[1]);
        $display("TB: R2 = %h (expected 0xBB11)", dut.r[2]);
        $display("TB: R3 = %h (expected 0x6567 after ADDI R3,R1,1)", dut.r[3]);
        $display("TB: R5 = %h (expected 0x0200)", dut.r[5]);
        $display("TB: R6 = %h (expected 0xBEEF from LOAD)", dut.r[6]);
        $display("TB: R7 = %h (expected 0xBEF0 after ADDI R7,R6,1)", dut.r[7]);
        $display("TB: R9 = %h (should be initial value, e.g. 0, if JMPA worked)", dut.r[9]);


        $finish;
    end

endmodule
