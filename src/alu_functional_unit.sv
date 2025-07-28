// ALU Functional Unit
`include "structs.svh"

module alu_functional_unit (
    input logic clk_i, 
    input logic reset_i,
    
    input logic execute_valid_i,
    input wire reservation_station_s execute_packet_i,
    input logic [3:0] rs_tag_i,
    input logic cdb_grant_i,
    
    output cdb_packet_s result_o,
    output logic busy_o
);

    // ALU is single cycle
    logic [31:0] alu_operand_a, alu_operand_b, alu_result_data;
    reservation_station_s packet_r;
    logic [3:0] tag_r;
    logic valid_r;
    
    always_ff @(posedge clk_i) 
	begin
        if (reset_i) 
		begin
            valid_r <= 1'b0;
            packet_r <= '0;
            tag_r <= 4'b0;
        end 
        else 
		begin
            if (cdb_grant_i) 
			begin
                valid_r <= 1'b0;
            end
            if (execute_valid_i && !busy_o) 
			begin
                valid_r <= 1'b1;
                packet_r <= execute_packet_i;
                tag_r <= rs_tag_i;
            end
        end
    end
    
    assign alu_operand_a = packet_r.vj;
    assign alu_operand_b = (packet_r.op == 4'b0010) ? packet_r.address : packet_r.vk;
    
    // ALU computation
    always_comb 
	begin
        case (packet_r.op)
            4'b0000, 4'b0010: alu_result_data = alu_operand_a + alu_operand_b; // ADD, ADDI
            4'b0001: alu_result_data = alu_operand_a - alu_operand_b; // SUB
            4'b1001: alu_result_data = {31'b0, (alu_operand_a == alu_operand_b)}; // BEQ
            4'b1010: alu_result_data = {31'b0, (alu_operand_a != alu_operand_b)}; // BNE
            4'b1011: alu_result_data = {31'b0, ($signed(alu_operand_a) < $signed(alu_operand_b))}; // BLT
            4'b1100: alu_result_data = packet_r.pc + 4; // JAL (return address)
            default: alu_result_data = 32'b0;
        endcase
    end
    
    // busy when waiting for CDB (allows back-to-back operations)
    assign busy_o = valid_r && !cdb_grant_i;
    
    always_comb 
	begin
        result_o.valid = valid_r;
        result_o.tag = tag_r;
        result_o.data = alu_result_data;
        result_o.rob_entry = packet_r.dest;
        result_o.is_branch = (packet_r.op >= 4'b1001 && packet_r.op <= 4'b1100);
        result_o.branch_taken = (alu_result_data != 32'b0) || (packet_r.op == 4'b1100);
        result_o.branch_target = packet_r.pc + packet_r.address;
        result_o.exception = 1'b0;
    end

endmodule