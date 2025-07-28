/*
    Gshare Branch Predictor
    -> Implements a global-history-based branch predictor using XOR of PC and global history.
    -> Gaol is to reduce the branch misprediction penalties for an OOO processor.
*/

`include "structs.svh"

module gshare_branch_predictor #(
    parameter PHT_SIZE = 1024,          // Prediction History Table size (2^10)
    parameter GHR_WIDTH = 10,           // Global History Register width
    parameter BTB_SIZE = 256            // Branch Target Buffer size
)(
    input logic clk_i, reset_i,
    
    // Prediction interface
    input logic [31:0] pc_i,                    // Current PC for prediction
    output logic prediction_o,                  // Taken/Not-taken prediction
    output logic [31:0] target_o,               // Predicted branch target
    
    // Update interface
    input logic update_en_i,                    // Update predictor with outcome
    input logic [31:0] update_pc_i,             // PC of resolved branch
    input logic actual_taken_i,                 // Actual branch outcome
    input logic [31:0] actual_target_i          // Actual branch target
);

    // Local parameters
    localparam PHT_ADDR_WIDTH = $clog2(PHT_SIZE);
    localparam BTB_ADDR_WIDTH = $clog2(BTB_SIZE);
    
    // Prediction History Table (PHT) - 2-bit saturating counters
    logic [1:0] pht [PHT_SIZE-1:0];
    
    // Global History Register (GHR)
    logic [GHR_WIDTH-1:0] ghr;
    
    // Branch Target Buffer (BTB) - using struct from structs.svh
    btb_entry_s btb [BTB_SIZE-1:0];
    
    // Address generation for prediction
    logic [PHT_ADDR_WIDTH-1:0] pred_pht_addr;
    logic [BTB_ADDR_WIDTH-1:0] pred_btb_addr;
    
    // Address generation for update
    logic [PHT_ADDR_WIDTH-1:0] update_pht_addr;
    logic [BTB_ADDR_WIDTH-1:0] update_btb_addr;
    
    // PHT addressing: XOR of PC and GHR
    assign pred_pht_addr = pc_i[PHT_ADDR_WIDTH+1:2] ^ ghr[PHT_ADDR_WIDTH-1:0];
    assign update_pht_addr = update_pc_i[PHT_ADDR_WIDTH+1:2] ^ ghr[PHT_ADDR_WIDTH-1:0];
    
    // BTB addressing: Simple PC indexing
    assign pred_btb_addr = pc_i[BTB_ADDR_WIDTH+1:2];
    assign update_btb_addr = update_pc_i[BTB_ADDR_WIDTH+1:2];
    
    // Prediction logic
    logic pht_prediction;
    logic btb_hit;
    logic [31:0] btb_target;
    
    assign pht_prediction = pht[pred_pht_addr][1]; // MSB of 2-bit counter
    assign btb_hit = btb[pred_btb_addr].valid && 
                     (btb[pred_btb_addr].pc == pc_i);
    assign btb_target = btb[pred_btb_addr].target;
    
    // Output assignments
    assign prediction_o = pht_prediction && btb_hit;
    assign target_o = btb_hit ? btb_target : (pc_i + 4); // Default to PC+4 if no BTB hit
    
    // Sequential logic for updates
    always_ff @(posedge clk_i) 
	begin
        if (reset_i) 
		begin
            // Initialize PHT to weakly not-taken (2'b01)
            for (int i = 0; i < PHT_SIZE; i++) 
			begin
                pht[i] <= 2'b01;
            end
            
            // Initialize BTB to invalid
            for (int i = 0; i < BTB_SIZE; i++) 
			begin
                btb[i].valid <= 1'b0;
                btb[i].pc <= 32'b0;
                btb[i].target <= 32'b0;
            end
            
            // Initialize GHR to not-taken
            ghr <= {GHR_WIDTH{1'b0}};
            
        end 
		else if (update_en_i) 
		begin
            
            // Update PHT with 2-bit saturating counter
            case (pht[update_pht_addr])
                2'b00: pht[update_pht_addr] <= actual_taken_i ? 2'b01 : 2'b00; // Strongly not-taken
                2'b01: pht[update_pht_addr] <= actual_taken_i ? 2'b10 : 2'b00; // Weakly not-taken
                2'b10: pht[update_pht_addr] <= actual_taken_i ? 2'b11 : 2'b01; // Weakly taken
                2'b11: pht[update_pht_addr] <= actual_taken_i ? 2'b11 : 2'b10; // Strongly taken
            endcase
            
            // Update BTB for taken branches
            if (actual_taken_i) 
			begin
                btb[update_btb_addr].valid <= 1'b1;
                btb[update_btb_addr].pc <= update_pc_i;
                btb[update_btb_addr].target <= actual_target_i;
            end
            
            // Update Global History Register
            ghr <= {ghr[GHR_WIDTH-2:0], actual_taken_i};
        end
    end
    
    // Performance counters (optional)
    `ifdef PERFORMANCE_COUNTERS
		logic [31:0] total_predictions, correct_predictions;
		logic [31:0] total_branches, taken_branches;
		
		always_ff @(posedge clk_i) 
		begin
			if (reset_i) 
			begin
				total_predictions <= 32'b0;
				correct_predictions <= 32'b0;
				total_branches <= 32'b0;
				taken_branches <= 32'b0;
			end 
			else
			begin
				// Count predictions
				total_predictions <= total_predictions + 1;
				
				// Count branch updates
				if (update_en_i) 
				begin
					total_branches <= total_branches + 1;
					if (actual_taken_i) 
						taken_branches <= taken_branches + 1;
					
					// Check prediction accuracy
					if ((pht_prediction && actual_taken_i) || (!pht_prediction && !actual_taken_i)) 
					begin
						correct_predictions <= correct_predictions + 1;
					end
				end
			end
		end
    `endif
    
    // Assertions for verification
    `ifdef ASSERTIONS
		// GHR should be updated only on branch updates
		assert property (@(posedge clk_i) disable iff (reset_i)
			$changed(ghr) -> update_en_i)
			else $error("GHR changed without update");
		
		// BTB entries should have valid targets for taken branches
		assert property (@(posedge clk_i) disable iff (reset_i)
			(update_en_i && actual_taken_i) -> (actual_target_i != update_pc_i))
			else $warning("Branch target same as PC - might be incorrect");
    `endif

endmodule