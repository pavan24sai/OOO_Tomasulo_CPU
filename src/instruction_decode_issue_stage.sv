// ============================================================================
// STAGE 2: INSTRUCTION DECODE & ISSUE
// ============================================================================

`include "structs.svh"

module instruction_decode_issue_stage (
    input logic clk_i, 
	input logic reset_i,
    
    // Fetch stage inputs
    input logic [31:0] pc_i,
    input logic [31:0] instruction_i,
    
    // Control inputs
    input logic flush_i,
    input logic stall_i,
    
    // ROB interface
    input logic rob_full_i,
    input logic [3:0] rob_tail_i,
    output logic rob_alloc_valid_o,
    output logic [3:0] rob_opcode_o,
    output logic [4:0] rob_dest_reg_o,
    output logic [31:0] rob_pc_o,
    output logic rob_is_branch_o,
    
    // regfile interface
    output logic [4:0] rf_addr1_o, rf_addr2_o,
    input logic [31:0] rf_data1_i, rf_data2_i,
    
    // RST interface
    output logic [4:0] regstat_addr1_o, regstat_addr2_o,
    input wire register_status_s regstat_data1_i, regstat_data2_i,
    output logic regstat_wr_en_o,
    output logic [4:0] regstat_wr_addr_o,
    output logic [3:0] regstat_rob_addr_o,
    input logic same_cycle_commit_rs1_i, same_cycle_commit_rs2_i,
    
    // commit forwarding interface
    input logic commit_valid_i,
    input logic [4:0] commit_dest_reg_i,
    input logic [31:0] commit_value_i,
    input logic commit_is_store_i,
    input logic [3:0] commit_rob_entry_i,
    
    // CDB forwarding interface for same-cycle execution results
    input wire cdb_packet_s cdb_packet_i,
    
    // Direct functional unit results for immediate forwarding
    input wire cdb_packet_s alu_result_i,
    input wire cdb_packet_s mult_result_i,
    input wire cdb_packet_s div_result_i,
    input wire cdb_packet_s mem_result_i,
    
    // Reservation station outputs
    output logic rs_alu_issue_valid_o,
    output logic rs_mult_issue_valid_o,
    output logic rs_div_issue_valid_o,
    output logic rs_mem_issue_valid_o,
    output reservation_station_s issue_packet_o,
    
    // RS full status inputs
    input logic rs_alu_full_i,
    input logic rs_mult_full_i,
    input logic rs_div_full_i,
    input logic rs_mem_full_i
);

    // Decoded instruction fields
    logic [4:0] rs1, rs2, rd;
    logic [31:0] immediate;
    logic [3:0] opcode_decoded;
    logic [1:0] fu_type_decoded;
    logic is_branch_decoded, is_store_decoded, is_load_decoded;
    logic issue_valid;
    logic pipeline_stall;
    
    // Functional unit forwarding helper signals
    logic fu_fwd_rs1_valid, fu_fwd_rs2_valid;
    logic [31:0] fu_fwd_rs1_data, fu_fwd_rs2_data;
	
	// Override predictor for unconditional jumps
	logic override_prediction;
	logic override_taken;
	logic [31:0] override_target;
    
    // Decode logic
    always_comb 
	begin
        rs1 = instruction_i[19:15];
        rs2 = instruction_i[24:20];
        rd  = instruction_i[11:7];
        
        case (instruction_i[6:0])
            7'b0110011: begin // R-type
							case ({instruction_i[31:25], instruction_i[14:12]})
								{7'b0000000, 3'b000}: opcode_decoded = 4'b0000; // ADD
								{7'b0100000, 3'b000}: opcode_decoded = 4'b0001; // SUB
								{7'b0000001, 3'b000}: opcode_decoded = 4'b0011; // MUL
								{7'b0000001, 3'b001}: opcode_decoded = 4'b0100; // MULH
								{7'b0000001, 3'b100}: opcode_decoded = 4'b0101; // DIV
								{7'b0000001, 3'b111}: opcode_decoded = 4'b0110; // REMU
								default: opcode_decoded = 4'b1111; // NOP
							endcase
							immediate = 32'b0;
							fu_type_decoded = (opcode_decoded == 4'b0011 || opcode_decoded == 4'b0100) ? 2'b01 :
											  (opcode_decoded == 4'b0101 || opcode_decoded == 4'b0110) ? 2'b10 : 2'b00;
							{is_branch_decoded, is_store_decoded, is_load_decoded} = 3'b000;
						end
            
            7'b0010011: begin // ADDI
							opcode_decoded = 4'b0010;
							immediate = {{20{instruction_i[31]}}, instruction_i[31:20]};
							fu_type_decoded = 2'b00;
							{is_branch_decoded, is_store_decoded, is_load_decoded} = 3'b000;
						end
            
            7'b0000011: begin // LW
							opcode_decoded = 4'b0111;
							immediate = {{20{instruction_i[31]}}, instruction_i[31:20]};
							fu_type_decoded = 2'b11;
							{is_branch_decoded, is_store_decoded, is_load_decoded} = 3'b001;
						end
            
            7'b0100011: begin // SW
							opcode_decoded = 4'b1000;
							immediate = {{20{instruction_i[31]}}, instruction_i[31:25], instruction_i[11:7]};
							fu_type_decoded = 2'b11;
							{is_branch_decoded, is_store_decoded, is_load_decoded} = 3'b010;
						end
            
            7'b1100011: begin // Branch
							case (instruction_i[14:12])
								3'b000: opcode_decoded = 4'b1001; // BEQ
								3'b001: opcode_decoded = 4'b1010; // BNE
								3'b100: opcode_decoded = 4'b1011; // BLT
								default: opcode_decoded = 4'b1111;
							endcase
							immediate = {{19{instruction_i[31]}}, instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0};
							fu_type_decoded = 2'b00;
							{is_branch_decoded, is_store_decoded, is_load_decoded} = 3'b100;
						end
            
            7'b1101111: begin // JAL
							opcode_decoded = 4'b1100;
							immediate = {{11{instruction_i[31]}}, instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
							fu_type_decoded = 2'b00;
							{is_branch_decoded, is_store_decoded, is_load_decoded} = 3'b100;
						end
            
            default: 	begin
							opcode_decoded = 4'b1111;
							immediate = 32'b0;
							fu_type_decoded = 2'b00;
							{is_branch_decoded, is_store_decoded, is_load_decoded} = 3'b000;
						end
        endcase
    end
    
    // Pipeline control
    assign pipeline_stall = rob_full_i || rs_alu_full_i || rs_mult_full_i || rs_div_full_i || rs_mem_full_i;
    assign issue_valid    = !flush_i && !stall_i && !pipeline_stall && (opcode_decoded != 4'b1111);
	
	// Register file interface
    assign rf_addr1_o 		= rs1;
    assign rf_addr2_o 		= (opcode_decoded == 4'b0010 || opcode_decoded == 4'b0111) ? 5'b0 : rs2; // ADDI and LW don't use rs2
    assign regstat_addr1_o 	= rs1;
    assign regstat_addr2_o 	= (opcode_decoded == 4'b0010 || opcode_decoded == 4'b0111) ? 5'b0 : rs2; // ADDI and LW don't use rs2
    
    // Issue packet creation
    always_comb 
	begin
		issue_packet_o.busy 	= 1'b1;
		issue_packet_o.op 		= opcode_decoded;
		issue_packet_o.dest 	= rob_tail_i;
		issue_packet_o.address 	= immediate;
		issue_packet_o.fu_type 	= fu_type_decoded;
		issue_packet_o.pc 		= pc_i;
		
		// Operand resolution with direct FU results, CDB, and commit forwarding
		// PRIORITY ORDER: 
		// 1) Direct FU results, 
		// 2) CDB forwarding, 
		// 3) Commit forwarding, 
		// 4) ROB dependency, 
		// 5) Register file
		
		// Check all functional unit results for operand forwarding & rs1 forwarding
		fu_fwd_rs1_valid = 1'b0;
		fu_fwd_rs1_data = 32'b0;
		if (alu_result_i.valid && !alu_result_i.exception && regstat_data1_i.busy && alu_result_i.rob_entry == regstat_data1_i.reorder_addr) 
		begin
			fu_fwd_rs1_valid = 1'b1;
			fu_fwd_rs1_data = alu_result_i.data;
		end 
		else if (mult_result_i.valid && !mult_result_i.exception && regstat_data1_i.busy && mult_result_i.rob_entry == regstat_data1_i.reorder_addr) 
		begin
			fu_fwd_rs1_valid = 1'b1;
			fu_fwd_rs1_data = mult_result_i.data;
		end 
		else if (div_result_i.valid && !div_result_i.exception && regstat_data1_i.busy && div_result_i.rob_entry == regstat_data1_i.reorder_addr) 
		begin
			fu_fwd_rs1_valid = 1'b1;
			fu_fwd_rs1_data = div_result_i.data;
		end 
		else if (mem_result_i.valid && !mem_result_i.exception && regstat_data1_i.busy && mem_result_i.rob_entry == regstat_data1_i.reorder_addr) 
		begin
			fu_fwd_rs1_valid = 1'b1;
			fu_fwd_rs1_data = mem_result_i.data;
		end
		
		// Check all functional unit results for rs2 forwarding  
		fu_fwd_rs2_valid = 1'b0;
		fu_fwd_rs2_data = 32'b0;
		if (alu_result_i.valid && !alu_result_i.exception && regstat_data2_i.busy && alu_result_i.rob_entry == regstat_data2_i.reorder_addr) 
		begin
			fu_fwd_rs2_valid = 1'b1;
			fu_fwd_rs2_data = alu_result_i.data;
		end 
		else if (mult_result_i.valid && !mult_result_i.exception && regstat_data2_i.busy && mult_result_i.rob_entry == regstat_data2_i.reorder_addr) 
		begin
			fu_fwd_rs2_valid = 1'b1;
			fu_fwd_rs2_data = mult_result_i.data;
		end 
		else if (div_result_i.valid && !div_result_i.exception && regstat_data2_i.busy && div_result_i.rob_entry == regstat_data2_i.reorder_addr) 
		begin
			fu_fwd_rs2_valid = 1'b1;
			fu_fwd_rs2_data = div_result_i.data;
		end 
		else if (mem_result_i.valid && !mem_result_i.exception && regstat_data2_i.busy && mem_result_i.rob_entry == regstat_data2_i.reorder_addr) 
		begin
			fu_fwd_rs2_valid = 1'b1;
			fu_fwd_rs2_data = mem_result_i.data;
		end
		
		// Operand 1 (rs1) - Always a register for all instruction types
		if (fu_fwd_rs1_valid) 
		begin
			// Use direct FU result - highest priority
			issue_packet_o.qj = 4'b0;
			issue_packet_o.vj = fu_fwd_rs1_data;
		end
		else if (cdb_packet_i.valid && !cdb_packet_i.exception && regstat_data1_i.busy && cdb_packet_i.rob_entry == regstat_data1_i.reorder_addr) 
		begin
			// Use CDB result directly - this is the ROB entry we're waiting for
			issue_packet_o.qj = 4'b0;
			issue_packet_o.vj = cdb_packet_i.data;
		end
		else if (commit_valid_i && 
				!commit_is_store_i && 
				commit_dest_reg_i == rs1 && 
				rs1 != 5'b0 && 
				((regstat_data1_i.busy && commit_rob_entry_i == regstat_data1_i.reorder_addr) || same_cycle_commit_rs1_i)) 
		begin
			// Use committed value: either waiting for this ROB entry OR same-cycle commit
			issue_packet_o.qj = 4'b0;
			issue_packet_o.vj = commit_value_i;
		end
		else if (regstat_data1_i.busy) 
		begin
			// Register is busy - wait for ROB entry
			issue_packet_o.qj = regstat_data1_i.reorder_addr;
			issue_packet_o.vj = 32'b0;
		end 
		else 
		begin
			// Register is available - use register file value
			issue_packet_o.qj = 4'b0;
			issue_packet_o.vj = rf_data1_i;
		end
		
		// Operand 2 - Depends on instruction type
		// For I-type instructions (ADDI, LW), use immediate value directly
		// For R-type, S-type, B-type instructions, use register rs2
		if (opcode_decoded == 4'b0010 || opcode_decoded == 4'b0111) 
		begin // ADDI or LW
			// I-type: Second operand is immediate value (stored in address field)
			issue_packet_o.qk = 4'b0;
			issue_packet_o.vk = immediate;
		end
		else 
		begin
			// R-type, S-type, B-type: Second operand is register rs2
			if (fu_fwd_rs2_valid) 
			begin
				// Use direct FU result - highest priority
				issue_packet_o.qk = 4'b0;
				issue_packet_o.vk = fu_fwd_rs2_data;
			end
			else if (cdb_packet_i.valid && !cdb_packet_i.exception && regstat_data2_i.busy && cdb_packet_i.rob_entry == regstat_data2_i.reorder_addr) 
			begin
				// Use CDB result directly - this is the ROB entry it is waiting for
				issue_packet_o.qk = 4'b0;
				issue_packet_o.vk = cdb_packet_i.data;
			end
			else if (commit_valid_i && 
					 !commit_is_store_i && 
					 commit_dest_reg_i == rs2 && 
					 rs2 != 5'b0 &&
					 ((regstat_data2_i.busy && commit_rob_entry_i == regstat_data2_i.reorder_addr) ||
					 same_cycle_commit_rs2_i))
			begin
				// Use committed value: either waiting for this ROB entry OR same-cycle commit
				issue_packet_o.qk = 4'b0;
				issue_packet_o.vk = commit_value_i;
			end
			else if (regstat_data2_i.busy) 
			begin
				// Register is busy - wait for ROB entry
				issue_packet_o.qk = regstat_data2_i.reorder_addr;
				issue_packet_o.vk = 32'b0;
			end 
			else 
			begin
				// Register is available - use register file value
				issue_packet_o.qk = 4'b0;
				issue_packet_o.vk = rf_data2_i;
			end
		end
	end
    
    // Output assignments
    assign rs_alu_issue_valid_o  = issue_valid && (fu_type_decoded == 2'b00);
    assign rs_mult_issue_valid_o = issue_valid && (fu_type_decoded == 2'b01);
    assign rs_div_issue_valid_o  = issue_valid && (fu_type_decoded == 2'b10);
    assign rs_mem_issue_valid_o  = issue_valid && (fu_type_decoded == 2'b11);
    
    assign rob_alloc_valid_o = issue_valid;
    assign rob_opcode_o 	 = opcode_decoded;
    assign rob_dest_reg_o 	 = rd;
    assign rob_pc_o 		 = pc_i;
    assign rob_is_branch_o 	 = is_branch_decoded;
    
    assign regstat_wr_en_o 	  = issue_valid && rd != 5'b0;
    assign regstat_wr_addr_o  = rd;
    assign regstat_rob_addr_o = rob_tail_i;
endmodule