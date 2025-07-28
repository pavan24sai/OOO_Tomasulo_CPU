// 1RW memory w/ synchronous reads

`include "macros.svh"
`define DATA_MEM_SIZE 256

module datamem (
    input logic clk_i, wr_en_i,
    input logic [31:0] addr_i, data_i,
    output logic [31:0] data_o
);
	// The data storage itself.
	logic [7:0] mem_r [`DATA_MEM_SIZE-1:0];
    logic [7:0] mem_n [`DATA_MEM_SIZE-1:0];

    always_ff @(posedge clk_i) 
	begin
        mem_r <= mem_n;
    end

    always_comb 
	begin
        mem_n = mem_r;
        if (wr_en_i)
            {mem_n[addr_i+3], mem_n[addr_i+2], mem_n[addr_i+1], mem_n[addr_i]} = data_i;
    end

    assign data_o = {mem_r[addr_i+3], mem_r[addr_i+2], mem_r[addr_i+1], mem_r[addr_i]};


    `ifdef TESTING_NON_SYNTH  // Only included if automated testing is enabled
		// Non-synth assertion, making sure given address is in bounds
		always_ff @(posedge clk_i) 
		begin
			if (addr_i != 'x)
				assert(addr_i + 3 < `DATA_MEM_SIZE);
		end

		// Expected memory contents, loaded from file (supports both 8-bit and 32-bit formats)
		logic [31:0] expected_mem_words [64:0];
		logic [31:0] actual_word;
		
		// Counter to track clock cycles
		int cycle_count = 0;
		
		// Read expected results from a macro-defined file  
		initial 
		begin
			$readmemh({"../tests/benchmarks/results/", `BENCHMARK, "_results.txt"}, expected_mem_words);
		end
		
		// Assertion to check memory contents after `SIM_CYCLES cycles
		always_ff @(posedge clk_i) 
		begin
			if (cycle_count == `SIM_CYCLES && expected_mem_words[0] == '0) 
			begin
				$display("Beginning testing after %0d cycles", `SIM_CYCLES);
				
				// Compare word-by-word (4 bytes at a time)
				for (int i = 0; i < `DATA_MEM_SIZE/4; i++) 
				begin
					if (expected_mem_words[i+1] !== 32'hXXXXXXXX) begin // XXXXXXXX corresponds to unused memory
						actual_word = {mem_r[i*4+3], mem_r[i*4+2], mem_r[i*4+1], mem_r[i*4]};
						assert (expected_mem_words[i+1] == actual_word) else
							$error("Incorrect memory contents at word address %0d (byte addr %0d)\n Expected: %08h. Found: %08h",
								i, i*4, expected_mem_words[i+1], actual_word);
					end
				end
			end // if
		end     // always_ff
	`endif      // TESTING_NON_SYNTH

endmodule