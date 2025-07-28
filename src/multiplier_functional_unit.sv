// Multiplier Functional Unit
`include "structs.svh"

module multiplier_functional_unit (
    input logic clk_i, 
    input logic reset_i,
    
    input logic execute_valid_i,
    input wire reservation_station_s execute_packet_i,
    input logic [3:0] rs_tag_i,
    input logic cdb_grant_i,
    
    output cdb_packet_s result_o,
    output logic busy_o
);

    // Interface to booth multiplier
    logic mult_v_i, mult_yumi_i, mult_ready_o, mult_v_o;
    logic [31:0] mult_a_i, mult_b_i;
    logic [63:0] mult_data_o;
    
    // Control registers
    reservation_station_s packet_r;
    logic [3:0] tag_r;
    logic operation_r; // 0=MUL, 1=MULH
    
    // States - to track the multi-cycle multiplication computation.
    enum logic [1:0] {IDLE, COMPUTING, HOLDING} state_r, state_n;
    
    always_ff @(posedge clk_i) 
	begin
        if (reset_i) 
		begin
            state_r <= IDLE;
            packet_r <= '0;
            tag_r <= 4'b0;
            operation_r <= 1'b0;
        end 
        else 
		begin
            state_r <= state_n;
            if (execute_valid_i && mult_ready_o && (state_r == IDLE)) 
			begin
                packet_r <= execute_packet_i;
                tag_r <= rs_tag_i;
                operation_r <= (execute_packet_i.op == 4'b0100); // MULH
            end
        end
    end
    
    // State machine
    always_comb
	begin
        case (state_r)
            IDLE: state_n = (execute_valid_i && mult_ready_o) ? COMPUTING : IDLE;
            COMPUTING: state_n = mult_v_o ? HOLDING : COMPUTING;
            HOLDING: state_n = cdb_grant_i ? IDLE : HOLDING;
            default: state_n = IDLE;
        endcase
    end
    
    // Booth multiplier instantiation
    booth_mult #(.data_width_p(32)) booth_mult_inst (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .v_i(mult_v_i),
        .yumi_i(mult_yumi_i),
        .a_i(mult_a_i),
        .b_i(mult_b_i),
        .ready_o(mult_ready_o),
        .v_o(mult_v_o),
        .data_o(mult_data_o)
    );

    // Make start signal combinational, not registered
    assign mult_v_i    = execute_valid_i && mult_ready_o && (state_r == IDLE);
    assign mult_yumi_i = cdb_grant_i && (state_r == HOLDING);
    
    // Use live inputs when starting, registered when computing
    assign mult_a_i    = (execute_valid_i && mult_ready_o && (state_r == IDLE)) ? execute_packet_i.vj : packet_r.vj;
    assign mult_b_i    = (execute_valid_i && mult_ready_o && (state_r == IDLE)) ? execute_packet_i.vk : packet_r.vk;
    
    // Output assignments
    assign busy_o = (state_r != IDLE);
    
    always_comb 
	begin
        result_o.valid = (state_r == HOLDING);
        result_o.tag = tag_r;
        result_o.rob_entry = packet_r.dest;
        result_o.is_branch = 1'b0;
        result_o.branch_taken = 1'b0;
        result_o.branch_target = 32'b0;
        result_o.exception = 1'b0;
        
        // Select MUL (lower 32 bits) or MULH (upper 32 bits)
        result_o.data = operation_r ? mult_data_o[63:32] : mult_data_o[31:0];
    end

endmodule