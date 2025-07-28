/*
    RISC-V Register File
    
    32 registers (x0-x31) where x0 is hardwired to zero.
    Supports dual-port read and single-port write.
    Named mem_array for compatibility with testing framework.
*/

`include "macros.svh"

module regfile(
    input logic clk,
    input logic reset,              // Added reset for proper initialization
    input logic [4:0] rd_addr1,     // Read address 1 (rs1)
    input logic [4:0] rd_addr2,     // Read address 2 (rs2)  
    input logic [4:0] wr_addr,      // Write address (rd)
    input logic [31:0] wr_data,     // Write data
    input logic wr_en,              // Write enable
    output logic [31:0] rd_data1,   // Read data 1
    output logic [31:0] rd_data2    // Read data 2
);

    // 32 registers, each 32 bits wide (named mem_array for testing framework)
    logic [31:0] mem_array [31:0];
    
    // ============================================================================
    // ASYNCHRONOUS READ PORTS
    // ============================================================================
    // Register x0 is hardwired to 0 in RISC-V
    assign rd_data1 = (rd_addr1 == 5'b0) ? 32'b0 : mem_array[rd_addr1];
    assign rd_data2 = (rd_addr2 == 5'b0) ? 32'b0 : mem_array[rd_addr2];
    
    // ============================================================================
    // SYNCHRONOUS WRITE PORT WITH RESET
    // ============================================================================
    always_ff @(posedge clk) 
	begin
        if (reset) 
		begin
            // Initialize all registers to 0 for deterministic behavior
            for (int i = 0; i < 32; i++) 
			begin
                mem_array[i] <= 32'b0;
            end
        end 
		else if (wr_en && wr_addr != 5'b0) 
		begin
            // Write to register only if:
            // 1. Write enable is asserted
            // 2. Target register is not x0 (x0 is always 0)
            mem_array[wr_addr] <= wr_data;
        end
        // Note: x0 remains 0 always (no explicit assignment needed due to reset and write condition)
    end
    
    // ============================================================================
    // TESTING FRAMEWORK (Non-synthesizable)
    // ============================================================================
    `ifdef TESTING_NON_SYNTH
        // Expected memory contents from file
        logic [31:0] expected_regs [255:0];
        
        // Counter to track clock cycles
        int cycle_count = 0;
        
        // Read expected results from a macro-defined file  
        initial 
		begin
            $readmemh({"../tests/benchmarks/results/", `BENCHMARK, "_results.txt"}, expected_regs);
        end

        // Track simulation cycles
        always_ff @(posedge clk) 
		begin
            if (reset) 
			begin
                cycle_count <= 0;
            end 
			else 
			begin
                cycle_count <= cycle_count + 1;
            end
        end
    
        // Assertion to check memory contents after SIM_CYCLES cycles
        always_ff @(posedge clk) 
		begin
            if (cycle_count == `SIM_CYCLES && expected_regs[0] == 32'hffff_ffff) 
			begin
                $display("Beginning register file testing after %0d cycles", `SIM_CYCLES);
                for (int i = 0; i < 32; i++) 
				begin
                    if (expected_regs[i+1] !== 32'hXXXX_XXXX) 
					begin
                        assert (expected_regs[i+1] == mem_array[i]) else
                            $error("Incorrect register contents at x%0d\nExpected: 0x%08h. Found: 0x%08h",
                                   i, expected_regs[i+1], mem_array[i]);
                    end
                end
                $display("Register file verification complete");
            end
        end
    `endif
    
    // ============================================================================
    // VERIFICATION ASSERTIONS (Synthesizable)
    // ============================================================================
    `ifdef ASSERTIONS
        // x0 should always read as 0
        always @(posedge clk) 
		begin
            assert (mem_array[0] == 32'b0) 
                else $error("Register x0 is not zero: 0x%08h", mem_array[0]);
        end
        
        // Read data should be 0 when reading x0
        assert property (@(posedge clk) disable iff (reset)
            (rd_addr1 == 5'b0) |-> (rd_data1 == 32'b0))
            else $error("Read port 1 not returning 0 for x0");
            
        assert property (@(posedge clk) disable iff (reset)
            (rd_addr2 == 5'b0) |-> (rd_data2 == 32'b0))
            else $error("Read port 2 not returning 0 for x0");
    `endif

endmodule