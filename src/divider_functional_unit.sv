// Divider Functional Unit
`include "structs.svh"

module divider_functional_unit (
    input logic clk_i, 
    input logic reset_i,
    
    input logic execute_valid_i,
    input wire reservation_station_s execute_packet_i,
    input logic [3:0] rs_tag_i,
    input logic cdb_grant_i,
    
    output cdb_packet_s result_o,
    output logic busy_o
);

    // Interface to NRD divider
    logic div_v_i, div_yumi_i, div_ready_o, div_v_o;
    logic div_signed_i;
    logic [31:0] div_a_i, div_b_i, div_div_o, div_rem_o;
    
    // Control registers
    reservation_station_s packet_r;
    logic [3:0] tag_r;
    logic operation_r; // 0=DIV, 1=REMU
    
    // States - to track the multi-cycle division computation.
    enum logic [1:0] {IDLE, COMPUTING, HOLDING} state_r, state_n;
    
    always_ff @(posedge clk_i) 
	begin
        if (reset_i) 
		begin
            state_r 	<= IDLE;
            packet_r 	<= '0;
            tag_r 		<= 4'b0;
            operation_r <= 1'b0;
        end 
        else 
		begin
            state_r <= state_n;
            if (execute_valid_i && div_ready_o && (state_r == IDLE)) 
			begin
                packet_r <= execute_packet_i;
                tag_r <= rs_tag_i;
                operation_r <= (execute_packet_i.op == 4'b0110); // REMU
            end
        end
    end
    
    // State machine
    always_comb 
	begin
        case (state_r)
            IDLE: state_n = (execute_valid_i && div_ready_o) ? COMPUTING : IDLE;
            COMPUTING: state_n = div_v_o ? HOLDING : COMPUTING;
            HOLDING: state_n = cdb_grant_i ? IDLE : HOLDING;
            default: state_n = IDLE;
        endcase
    end
    
    // NRD divider instantiation
    nrd_div #(.data_width_p(32)) nrd_div_inst (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .signed_i(div_signed_i),
        .v_i(div_v_i),
        .yumi_i(div_yumi_i),
        .a_i(div_a_i),
        .b_i(div_b_i),
        .ready_o(div_ready_o),
        .v_o(div_v_o),
        .div_o(div_div_o),
        .rem_o(div_rem_o)
    );
    
    // Make start signal combo logic
    assign div_v_i      = execute_valid_i && div_ready_o && (state_r == IDLE);
    assign div_yumi_i   = cdb_grant_i && (state_r == HOLDING);
    assign div_signed_i = (packet_r.op == 4'b0101);
    
    // Use live inputs when starting & reg value when compute in progress
    assign div_a_i = (execute_valid_i && div_ready_o && (state_r == IDLE)) ? execute_packet_i.vj : packet_r.vj;
    assign div_b_i = (execute_valid_i && div_ready_o && (state_r == IDLE)) ? execute_packet_i.vk : packet_r.vk;
    
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
        
        // Select DIV (quotient) or REMU (remainder)
        result_o.data = operation_r ? div_rem_o : div_div_o;
    end
    
endmodule