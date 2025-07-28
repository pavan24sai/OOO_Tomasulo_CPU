/*
    Common Data Bus (CDB) Controller
    
    -> Arbitrates between multiple functional units competing for CDB access as per the Tomasulo's algorithm.
    -> Implements priority-based arbitration to ensure fairness and prevent deadlock.
    
    Priority Order: ALU > MEM > MULT > DIV  (ALU and MEM are single-cycle, so they get priority over multi-cycle units)
*/

`include "structs.svh"

module cdb_controller (
    input logic clk_i, 
	input logic reset_i,
    
    // Results from functional units
    input wire cdb_packet_s alu_result_i,
    input wire cdb_packet_s mult_result_i,
    input wire cdb_packet_s div_result_i,
    input wire cdb_packet_s mem_result_i,
    
    // CDB output (broadcast to all monitoring units)
    output cdb_packet_s cdb_packet_o,
    
    // Grant signals back to functional units
    output logic alu_grant_o,
    output logic mult_grant_o,
    output logic div_grant_o,
    output logic mem_grant_o
);

    // Internal arbitration logic
    logic [3:0] request_vector;
    logic [3:0] grant_vector;
    
    // Build request vector
    assign request_vector = {
        div_result_i.valid,   // [3]
        mult_result_i.valid,  // [2]
        mem_result_i.valid,   // [1]
        alu_result_i.valid    // [0]
    };
    
    // Priority-based arbitration
    // ALU has highest priority (single cycle), then MEM, then MULT, then DIV
    always_comb 
	begin
        grant_vector = 4'b0000;
        cdb_packet_o = '0;
        
        casez (request_vector)
            4'b???1: 	begin  // ALU request (highest priority)
							grant_vector = 4'b0001;
							cdb_packet_o = alu_result_i;
						end
            4'b??10: 	begin  // MEM request (second priority)
							grant_vector = 4'b0010;
							cdb_packet_o = mem_result_i;
						end
            4'b?100: 	begin  // MULT request (third priority)
							grant_vector = 4'b0100;
							cdb_packet_o = mult_result_i;
						end
            4'b1000: 	begin  // DIV request (lowest priority)
							grant_vector = 4'b1000;
							cdb_packet_o = div_result_i;
						end
            default: 	begin  // No requests
							grant_vector = 4'b0000;
							cdb_packet_o = '0;
						end
        endcase
    end
    
    // Assign individual grant signals
    assign alu_grant_o  = grant_vector[0];
    assign mem_grant_o  = grant_vector[1];
    assign mult_grant_o = grant_vector[2];
    assign div_grant_o  = grant_vector[3];

endmodule