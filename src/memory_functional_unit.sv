// Memory Functional Unit
`include "structs.svh"

module memory_functional_unit (
    input logic clk_i, 
    input logic reset_i,
    
    input logic execute_valid_i,
    input wire reservation_station_s execute_packet_i,
    input logic [3:0] rs_tag_i,
    input logic cdb_grant_i,
    
    // Memory interface
    output logic [31:0] mem_addr_o,
    output logic [31:0] mem_wdata_o,
    output logic mem_wr_en_o,
    input logic [31:0] mem_rdata_i,
    
    output cdb_packet_s result_o,
    output logic busy_o
);

    // Memory operations are single cycle
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
    
    // Memory interface
    assign mem_addr_o = packet_r.vj + packet_r.address;
    assign mem_wdata_o = packet_r.vk;
    assign mem_wr_en_o = valid_r && (packet_r.op == 4'b1000); // SW
    
    // busy when waiting for CDB (allows back-to-back operations)
    assign busy_o = valid_r && !cdb_grant_i;
    
    always_comb 
	begin
        result_o.valid = valid_r;
        result_o.tag = tag_r;
        result_o.data = (packet_r.op == 4'b0111) ? mem_rdata_i : 32'b0; // LW
        result_o.rob_entry = packet_r.dest;
        result_o.is_branch = 1'b0;
        result_o.branch_taken = 1'b0;
        result_o.branch_target = 32'b0;
        result_o.exception = 1'b0;
    end

endmodule