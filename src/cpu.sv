/*
    Tomasulo OOO RISC-V CPU Core
*/

`include "structs.svh" 
`include "macros.svh"

module cpu (
    input logic clk, 
    input logic reset
);

    // ============================================================================
    // INTER-STAGE SIGNALS
    // ============================================================================
    
    // Fetch -> Decode signals
    logic [31:0] fetch_pc, fetch_instruction;
    
    // Control signals
    logic pipeline_stall, flush_pipeline;
    logic [31:0] correct_pc;
    
    // Issue -> RS/ROB signals
    logic issue_valid;
    reservation_station_s issue_packet;
    logic rs_alu_issue_valid, rs_mult_issue_valid, rs_div_issue_valid, rs_mem_issue_valid;
    logic rs_alu_full, rs_mult_full, rs_div_full, rs_mem_full;
    logic [3:0] issue_opcode;
    logic [4:0] issue_dest_reg;
    logic [31:0] issue_pc;
    logic issue_is_branch;
    
    // RS -> FU signals
    logic rs_alu_execute_valid, rs_mult_execute_valid, rs_div_execute_valid, rs_mem_execute_valid;
    reservation_station_s rs_alu_packet, rs_mult_packet, rs_div_packet, rs_mem_packet;
    logic [3:0] rs_alu_tag, rs_mult_tag, rs_div_tag, rs_mem_tag;
    
    // FU -> CDB signals
    cdb_packet_s alu_result, mult_result, div_result, mem_result;
    logic alu_busy, mult_busy, div_busy, mem_busy;
    
    // CDB signals
    cdb_packet_s cdb_packet;
    logic alu_cdb_grant, mult_cdb_grant, div_cdb_grant, mem_cdb_grant;
    
    // ROB signals
    logic rob_full, rob_empty;
    logic [3:0] rob_tail;
    logic commit_valid;
    logic [4:0] commit_dest_reg;
    logic [31:0] commit_value;
    logic [3:0] commit_rob_entry;
    logic commit_is_store, commit_is_branch, commit_branch_taken;
    logic [31:0] commit_branch_target;
    logic branch_mispredict;
    
    // regfile signals
    logic [4:0] rf_addr1, rf_addr2;
    logic [31:0] rf_data1, rf_data2;
    logic regfile_wr_en;
    logic [4:0] regfile_wr_addr;
    logic [31:0] regfile_wr_data;
    
    // RST signals
    logic [4:0] regstat_addr1, regstat_addr2;
    register_status_s regstat_data1, regstat_data2;
    logic regstat_wr_en, regstat_commit_en;
    logic [4:0] regstat_wr_addr, regstat_commit_addr;
    logic [3:0] regstat_rob_addr, regstat_commit_rob;
    logic same_cycle_commit_rs1, same_cycle_commit_rs2;
    
    // Memory interface
    logic [31:0] mem_addr, mem_wdata, mem_rdata;
    logic mem_wr_en;
    
    // Branch prediction signals
    logic take_branch_prediction;
    logic [31:0] predicted_target;
	
	logic final_predicted_taken;
	logic [31:0] final_predicted_target;
	
	logic [31:0] jal_immediate;
	logic is_jal;

    // ============================================================================
    // STAGE 1: INSTRUCTION FETCH
    // ============================================================================
    
    instruction_fetch_stage 
	fetch_stage (
        .clk_i(clk),
        .reset_i(reset),
        .stall_i(pipeline_stall),
        .flush_i(flush_pipeline),
        .flush_pc_i(correct_pc),
        .take_branch_i(final_predicted_taken),
        .predicted_pc_i(final_predicted_target),
        .pc_o(fetch_pc),
        .instruction_o(fetch_instruction)
    );

    // ============================================================================
    // PIPELINE CONTROL LOGIC
    // ============================================================================
    
    assign pipeline_stall = rob_full || rs_alu_full || rs_mult_full || rs_div_full || rs_mem_full;
    assign flush_pipeline = branch_mispredict;

    // ============================================================================
    // BRANCH PREDICTION
    // ============================================================================
    
    gshare_branch_predictor 
	bp (
        .clk_i(clk),
        .reset_i(reset),
        .pc_i(fetch_pc),
        .prediction_o(take_branch_prediction),
        .target_o(predicted_target),
        .update_en_i(commit_valid && commit_is_branch),
        .update_pc_i(issue_pc), // Use issue PC for update
        .actual_taken_i(commit_branch_taken),
        .actual_target_i(commit_branch_target)
    );
	
	// Special case for JAL:
	// Override the branch predictor's outcome for JAL branch type to consider this branch outcome as always taken.
	// The branch target is computed by extracting the "immediate" value from the instruction.
	assign jal_immediate = {{11{fetch_instruction[31]}}, fetch_instruction[31], 
						   fetch_instruction[19:12], fetch_instruction[20], 
						   fetch_instruction[30:21], 1'b0};
	assign is_jal = (fetch_instruction[6:0] == 7'b1101111);
	assign final_predicted_taken  = is_jal ? 1'b1 : take_branch_prediction;
	assign final_predicted_target = is_jal ? (fetch_pc + jal_immediate) : predicted_target;
    
    // ============================================================================
    // STAGE 2: INSTRUCTION DECODE & ISSUE
    // ============================================================================
    
    instruction_decode_issue_stage 
	decode_issue_stage (
        .clk_i(clk),
        .reset_i(reset),
        .pc_i(fetch_pc),
        .instruction_i(fetch_instruction),
        .flush_i(flush_pipeline),
        .stall_i(pipeline_stall),
        
        // ROB interface
        .rob_full_i(rob_full),
        .rob_tail_i(rob_tail),
        .rob_alloc_valid_o(issue_valid),
        .rob_opcode_o(issue_opcode),
        .rob_dest_reg_o(issue_dest_reg),
        .rob_pc_o(issue_pc),
        .rob_is_branch_o(issue_is_branch),
        
        // regfile interface
        .rf_addr1_o(rf_addr1),
        .rf_addr2_o(rf_addr2),
        .rf_data1_i(rf_data1),
        .rf_data2_i(rf_data2),
        
        // RST interface
        .regstat_addr1_o(regstat_addr1),
        .regstat_addr2_o(regstat_addr2),
        .regstat_data1_i(regstat_data1),
        .regstat_data2_i(regstat_data2),
        .regstat_wr_en_o(regstat_wr_en),
        .regstat_wr_addr_o(regstat_wr_addr),
        .regstat_rob_addr_o(regstat_rob_addr),
        .same_cycle_commit_rs1_i(same_cycle_commit_rs1),
        .same_cycle_commit_rs2_i(same_cycle_commit_rs2),
        
		// Commit stage interface
        .commit_valid_i(commit_valid),
        .commit_dest_reg_i(commit_dest_reg),
        .commit_value_i(commit_value),
        .commit_is_store_i(commit_is_store),
        .commit_rob_entry_i(commit_rob_entry),
        
        // CDB forwarding for same-cycle execution results
        .cdb_packet_i(cdb_packet),
        
        // Direct functional unit results for immediate forwarding
        .alu_result_i(alu_result),
        .mult_result_i(mult_result),
        .div_result_i(div_result),
        .mem_result_i(mem_result),
        
        // Reservation station outputs
        .rs_alu_issue_valid_o(rs_alu_issue_valid),
        .rs_mult_issue_valid_o(rs_mult_issue_valid),
        .rs_div_issue_valid_o(rs_div_issue_valid),
        .rs_mem_issue_valid_o(rs_mem_issue_valid),
        .issue_packet_o(issue_packet),
        
        // RS status inputs
        .rs_alu_full_i(rs_alu_full),
        .rs_mult_full_i(rs_mult_full),
        .rs_div_full_i(rs_div_full),
        .rs_mem_full_i(rs_mem_full)
    );

    // ============================================================================
    // REGISTER FILE
    // ============================================================================
    
    regfile 
	regfile_inst (
        .clk(clk),
        .reset(reset),
        .wr_en(regfile_wr_en),
        .wr_addr(regfile_wr_addr),
        .wr_data(regfile_wr_data),
        .rd_addr1(rf_addr1),
        .rd_addr2(rf_addr2),
        .rd_data1(rf_data1),
        .rd_data2(rf_data2)
    );
    
    assign regfile_wr_en   = commit_valid && !commit_is_store && commit_dest_reg != 5'b0;
    assign regfile_wr_addr = commit_dest_reg;
    assign regfile_wr_data = commit_value;

    // ============================================================================
    // REGISTER STATUS
    // ============================================================================
    
    register_status 
	regstat_mod (
        .clk_i(clk),
        .reset_i(reset || flush_pipeline),
        .issue_rd_addr1_i(regstat_addr1),
        .issue_rd_addr2_i(regstat_addr2),
        .issue_wr_en_i(regstat_wr_en),
        .issue_wr_addr_i(regstat_wr_addr),
        .issue_reorder_addr_i(regstat_rob_addr),
        .commit_wr_en_i(regstat_commit_en),
        .commit_wr_addr_i(regstat_commit_addr),
        .commit_reorder_addr_i(regstat_commit_rob),
        .issue_rd_data1_o(regstat_data1),
        .issue_rd_data2_o(regstat_data2),
        .same_cycle_commit_rs1_o(same_cycle_commit_rs1),
        .same_cycle_commit_rs2_o(same_cycle_commit_rs2)
    );
    
    assign regstat_commit_en   = commit_valid && !commit_is_store;
    assign regstat_commit_addr = commit_dest_reg;
    assign regstat_commit_rob  = commit_rob_entry;

    // ============================================================================
    // STAGE 3: RESERVATION STATIONS
    // ============================================================================
    
    // ALU Reservation Stations
    reservation_station_manager 
    #(
        .RS_SIZE(4), 
        .RS_TAG_OFFSET(0)
    ) rs_alu_mgr (
        .clk_i(clk), 
        .reset_i(reset), 
        .flush_i(flush_pipeline),
        .issue_valid_i(rs_alu_issue_valid),
        .issue_packet_i(issue_packet),
        .cdb_packet_i(cdb_packet),
        .fu_ready_i(!alu_busy),
        .execute_valid_o(rs_alu_execute_valid),
        .execute_packet_o(rs_alu_packet),
        .execute_tag_o(rs_alu_tag),
        .rs_full_o(rs_alu_full)
    );
    
    // Multiplier Reservation Stations
    reservation_station_manager 
    #(
        .RS_SIZE(2), 
        .RS_TAG_OFFSET(4)
    ) rs_mult_mgr (
        .clk_i(clk), 
        .reset_i(reset), 
        .flush_i(flush_pipeline),
        .issue_valid_i(rs_mult_issue_valid),
        .issue_packet_i(issue_packet),
        .cdb_packet_i(cdb_packet),
        .fu_ready_i(!mult_busy),
        .execute_valid_o(rs_mult_execute_valid),
        .execute_packet_o(rs_mult_packet),
        .execute_tag_o(rs_mult_tag),
        .rs_full_o(rs_mult_full)
    );
    
    // Divider Reservation Stations
    reservation_station_manager 
    #(
        .RS_SIZE(2), 
        .RS_TAG_OFFSET(6)
    ) rs_div_mgr (
        .clk_i(clk), 
        .reset_i(reset), 
        .flush_i(flush_pipeline),
        .issue_valid_i(rs_div_issue_valid),
        .issue_packet_i(issue_packet),
        .cdb_packet_i(cdb_packet),
        .fu_ready_i(!div_busy),
        .execute_valid_o(rs_div_execute_valid),
        .execute_packet_o(rs_div_packet),
        .execute_tag_o(rs_div_tag),
        .rs_full_o(rs_div_full)
    );
    
    // Memory Reservation Stations
    reservation_station_manager 
    #(
        .RS_SIZE(4), 
        .RS_TAG_OFFSET(8)
    ) rs_mem_mgr (
        .clk_i(clk), 
        .reset_i(reset), 
        .flush_i(flush_pipeline),
        .issue_valid_i(rs_mem_issue_valid),
        .issue_packet_i(issue_packet),
        .cdb_packet_i(cdb_packet),
        .fu_ready_i(!mem_busy),
        .execute_valid_o(rs_mem_execute_valid),
        .execute_packet_o(rs_mem_packet),
        .execute_tag_o(rs_mem_tag),
        .rs_full_o(rs_mem_full)
    );

    // ============================================================================
    // STAGE 4: FUNCTIONAL UNITS
    // ============================================================================
    
    // ALU Unit
    alu_functional_unit 
	alu_unit (
        .clk_i(clk), 
        .reset_i(reset),
        .execute_valid_i(rs_alu_execute_valid),
        .execute_packet_i(rs_alu_packet),
        .rs_tag_i(rs_alu_tag),
        .cdb_grant_i(alu_cdb_grant),
        .result_o(alu_result),
        .busy_o(alu_busy)
    );
    
    // Multiplier Unit
    multiplier_functional_unit 
	mult_unit (
        .clk_i(clk), 
        .reset_i(reset),
        .execute_valid_i(rs_mult_execute_valid),
        .execute_packet_i(rs_mult_packet),
        .rs_tag_i(rs_mult_tag),
        .cdb_grant_i(mult_cdb_grant),
        .result_o(mult_result),
        .busy_o(mult_busy)
    );
    
    // Divider Unit
    divider_functional_unit 
	div_unit (
        .clk_i(clk), 
        .reset_i(reset),
        .execute_valid_i(rs_div_execute_valid),
        .execute_packet_i(rs_div_packet),
        .rs_tag_i(rs_div_tag),
        .cdb_grant_i(div_cdb_grant),
        .result_o(div_result),
        .busy_o(div_busy)
    );
    
    // Memory Unit
    memory_functional_unit 
	mem_unit (
        .clk_i(clk), 
        .reset_i(reset),
        .execute_valid_i(rs_mem_execute_valid),
        .execute_packet_i(rs_mem_packet),
        .rs_tag_i(rs_mem_tag),
        .cdb_grant_i(mem_cdb_grant),
        .mem_addr_o(mem_addr),
        .mem_wdata_o(mem_wdata),
        .mem_wr_en_o(mem_wr_en),
        .mem_rdata_i(mem_rdata),
        .result_o(mem_result),
        .busy_o(mem_busy)
    );
    
    // Data Memory
    datamem 
	dmem (
        .clk_i(clk),
        .wr_en_i(mem_wr_en),
        .addr_i(mem_addr),
        .data_i(mem_wdata),
        .data_o(mem_rdata)
    );

    // ============================================================================
    // STAGE 5: COMMON DATA BUS
    // ============================================================================
    
    cdb_controller 
	cdb_ctrl (
        .clk_i(clk),
        .reset_i(reset),
        .alu_result_i(alu_result),
        .mult_result_i(mult_result),
        .div_result_i(div_result),
        .mem_result_i(mem_result),
        .cdb_packet_o(cdb_packet),
        .alu_grant_o(alu_cdb_grant),
        .mult_grant_o(mult_cdb_grant),
        .div_grant_o(div_cdb_grant),
        .mem_grant_o(mem_cdb_grant)
    );

    // ============================================================================
    // STAGE 6: COMMIT (Reorder Buffer)
    // ============================================================================
    
    commit_stage 
    #(
        .ROB_SIZE(16)
    ) commit_stage_inst (
        .clk_i(clk), 
        .reset_i(reset), 
        .flush_i(flush_pipeline),
        
        // Issue interface
        .issue_valid_i(issue_valid),
        .issue_opcode_i(issue_opcode),
        .issue_dest_reg_i(issue_dest_reg),
        .issue_pc_i(issue_pc),
        .issue_is_branch_i(issue_is_branch),
        
        // Connect branch prediction for misprediction detection
        .issue_predicted_taken_i(final_predicted_taken),
        .issue_predicted_target_i(final_predicted_target),
        
        // CDB interface
        .cdb_packet_i(cdb_packet),
        
        // Commit interface
        .commit_valid_o(commit_valid),
        .commit_dest_reg_o(commit_dest_reg),
        .commit_value_o(commit_value),
        .commit_rob_entry_o(commit_rob_entry),
        .commit_is_store_o(commit_is_store),
        .commit_is_branch_o(commit_is_branch),
        .commit_branch_taken_o(commit_branch_taken),
        .commit_branch_target_o(commit_branch_target),
        
        // Status
        .rob_full_o(rob_full),
        .rob_empty_o(rob_empty),
        .rob_tail_o(rob_tail),
        
        // Branch misprediction
        .branch_mispredict_o(branch_mispredict),
        .correct_pc_o(correct_pc)
    );

endmodule