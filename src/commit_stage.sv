/*
    STAGE 5: COMMIT (Reorder Buffer)
    
    -> Used to ensure in-order commit in an OOO processor for ensuring that the CPU adheres to precise exceptions.
	-> Leverages a structure called as Re-Order Buffer which is basically a circular queue with head and tail pointers to parse through the queue 
	and ensure that the instructions exit the OOO pipeline in the same order as it entered the pipeline.
*/

`include "structs.svh"

module commit_stage #(
    parameter ROB_SIZE = 16
)(
    input logic clk_i, reset_i, flush_i,
    
    // Issue interface
    input logic issue_valid_i,
    input logic [3:0] issue_opcode_i,
    input logic [4:0] issue_dest_reg_i,
    input logic [31:0] issue_pc_i,
    input logic issue_is_branch_i,
    
    // branch prediction inputs for issue stage
    input logic issue_predicted_taken_i,
    input logic [31:0] issue_predicted_target_i,
    
    // CDB interface
    input wire cdb_packet_s cdb_packet_i,
    
    // Commit interface
    output logic commit_valid_o,
    output logic [4:0] commit_dest_reg_o,
    output logic [31:0] commit_value_o,
    output logic [3:0] commit_rob_entry_o,
    output logic commit_is_store_o,
    output logic commit_is_branch_o,
    output logic commit_branch_taken_o,
    output logic [31:0] commit_branch_target_o,
    
    // Status
    output logic rob_full_o,
    output logic rob_empty_o,
    output logic [3:0] rob_tail_o,
    
    // Branch misprediction
    output logic branch_mispredict_o,
    output logic [31:0] correct_pc_o
);
    
    // ROB signals
	rob_s rob [ROB_SIZE-1:0];
    logic [3:0] rob_head, rob_tail, rob_count;
	
	// Helper signals
	logic actual_branch_taken;
	logic prediction_mismatch;
    logic [31:0] actual_branch_target;
    logic can_commit_this_cycle;
    logic cdb_makes_head_ready;
    logic rob_advance;
	logic target_mismatch;
    logic safe_register_write;
    
    // commit outputs
    assign cdb_makes_head_ready  = cdb_packet_i.valid && (cdb_packet_i.rob_entry == rob_head);
    assign can_commit_this_cycle = !rob_empty_o && rob[rob_head].busy && (rob[rob_head].ready || cdb_makes_head_ready);
    
    // ============================================================================
    // BRANCH MISPREDICTION DETECTION
    // ============================================================================
    
    // Get actual branch outcome (considering CDB same-cycle completion)
    assign actual_branch_taken = can_commit_this_cycle && rob[rob_head].is_branch ? 
                                (cdb_makes_head_ready && cdb_packet_i.is_branch ? 
                                 cdb_packet_i.branch_taken : rob[rob_head].branch_taken) : 1'b0;
    
    assign actual_branch_target = can_commit_this_cycle && rob[rob_head].is_branch ? 
                                 (cdb_makes_head_ready && cdb_packet_i.is_branch ? 
                                  cdb_packet_i.branch_target : rob[rob_head].branch_target) : 32'b0;
    
    // Detect misprediction: predicted != actual outcome
    assign prediction_mismatch = can_commit_this_cycle && rob[rob_head].is_branch && (rob[rob_head].predicted_taken != actual_branch_taken);
    
	// Target mismatch (only matters if both predicted and actual are taken)
    assign target_mismatch = can_commit_this_cycle && rob[rob_head].is_branch && 
                            rob[rob_head].predicted_taken && actual_branch_taken &&
                            (rob[rob_head].predicted_target != actual_branch_target);
    assign branch_mispredict_o = prediction_mismatch || target_mismatch;
    
    // Correct PC calculation for misprediction recovery
    assign correct_pc_o = actual_branch_taken ? actual_branch_target : (rob[rob_head].pc + 4);
    
    // ROB always advances when instruction is ready
    assign rob_advance = can_commit_this_cycle;
    
    // write to regfile only when not mispredicted
    assign safe_register_write = can_commit_this_cycle && !branch_mispredict_o;
    
    // ALL commit outputs use safe_register_write for register file interface
    assign commit_valid_o 			= safe_register_write;
    assign commit_dest_reg_o 		= safe_register_write ? rob[rob_head].dest_reg : 5'b0;
    assign commit_rob_entry_o 		= safe_register_write ? rob_head : 4'b0;
    assign commit_is_store_o 		= safe_register_write ? (rob[rob_head].instruction == 4'b1000) : 1'b0;
    assign commit_is_branch_o		= safe_register_write ? rob[rob_head].is_branch : 1'b0;
    assign commit_value_o 			= safe_register_write ? (cdb_makes_head_ready ? cdb_packet_i.data : rob[rob_head].value) : 32'b0;
    assign commit_branch_taken_o 	= safe_register_write ? (cdb_makes_head_ready && cdb_packet_i.is_branch ? cdb_packet_i.branch_taken : rob[rob_head].branch_taken) : 1'b0;
    assign commit_branch_target_o 	= safe_register_write ? (cdb_makes_head_ready && cdb_packet_i.is_branch ? cdb_packet_i.branch_target : rob[rob_head].branch_target) : 32'b0;
    
    // Logic for ROB updates
    always_ff @(posedge clk_i) 
	begin
        if (reset_i || flush_i) 
		begin
            for (int i = 0; i < ROB_SIZE; i++) 
                rob[i] <= '0;
            rob_head <= 4'b0;
            rob_tail <= 4'b0;
            rob_count <= 4'b0;
        end 
		else 
		begin
            // Update from CDB
            if (cdb_packet_i.valid) 
			begin
                rob[cdb_packet_i.rob_entry].ready <= 1'b1;
                rob[cdb_packet_i.rob_entry].value <= cdb_packet_i.data;
                if (cdb_packet_i.is_branch) 
				begin
                    rob[cdb_packet_i.rob_entry].branch_taken <= cdb_packet_i.branch_taken;
                    rob[cdb_packet_i.rob_entry].branch_target <= cdb_packet_i.branch_target;
                end
            end
            
            // Issue new instruction
            if (issue_valid_i && !rob_full_o) 
			begin
                rob[rob_tail].busy <= 1'b1;
                rob[rob_tail].ready <= 1'b0;
                rob[rob_tail].instruction <= issue_opcode_i;
                rob[rob_tail].dest_reg <= issue_dest_reg_i;
                rob[rob_tail].pc <= issue_pc_i;
                rob[rob_tail].is_branch <= issue_is_branch_i;
                rob[rob_tail].exception <= 1'b0;
                
                // Store branch prediction in ROB for later comparison
                if (issue_is_branch_i) 
				begin
                    rob[rob_tail].predicted_taken <= issue_predicted_taken_i;
                    rob[rob_tail].predicted_target <= issue_predicted_target_i;
                end 
				else 
				begin
                    rob[rob_tail].predicted_taken <= 1'b0;
                    rob[rob_tail].predicted_target <= 32'b0;
                end
                
                rob_tail <= (rob_tail + 1) % ROB_SIZE;
            end
            
            // ROB always advances when instruction ready
            if (rob_advance) 
			begin
                rob[rob_head].busy <= 1'b0;
                rob_head <= (rob_head + 1) % ROB_SIZE;
            end
            
            // ROB count update
            if (issue_valid_i && !rob_full_o && rob_advance) 
			begin
                // Both issue and advance: count unchanged  
                rob_count <= rob_count;
            end 
			else if (issue_valid_i && !rob_full_o) 
			begin
                // Only issue: count increases
                rob_count <= rob_count + 1;
            end 
			else if (rob_advance) 
			begin
                // Only advance: count decreases  
                rob_count <= rob_count - 1;
            end
        end
    end
    
    // Status signals
    assign rob_full_o 	= (rob_count == ROB_SIZE - 1);
    assign rob_empty_o 	= (rob_count == 4'b0);
    assign rob_tail_o 	= rob_tail;
endmodule