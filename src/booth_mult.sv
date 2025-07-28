/*
	Author: Adam Friesz
    Description: Booth multiplier with handshake. This module performs signed multiplication 
	             using the Booth algorithm and includes handshake signals for data transfer.

	Inputs:
		clk_i       - Clock signal
		reset_i     - Active-high synchronous reset
		v_i         - Input valid signal (indicates new operands are available)
		yumi_i      - Output handshake signal (indicates result has been consumed)
		a_i         - Multiplicand
		b_i         - Multiplier

	Outputs:
		ready_o     - Ready signal (indicates module can accept new input)
		v_o         - Output valid signal (indicates result is available)
		data_o      - Computed product (2 * data_width_p bits)
*/

module booth_mult #(data_width_p) (clk_i, reset_i, v_i, yumi_i, a_i, b_i, ready_o, v_o, data_o);
    input logic clk_i, reset_i, v_i, yumi_i;
    input logic [data_width_p-1:0] a_i, b_i;
    output logic ready_o, v_o;
    output logic [2*data_width_p-1:0] data_o;

    logic [2*data_width_p:0] A_r, P_r, S_r, A_n, P_n, S_n, P_adder_lo, P_idle_hold_lo, P_lsr_lo;
    logic [$clog2(data_width_p)-1:0] step_count_r, step_count_n;
    logic [data_width_p:0] lsb_zeros;

    logic mult_done;

    enum logic [1:0] {s_idle, s_compute, s_hold} ps, ns;

    // update registers
    always_ff @(posedge clk_i) begin
        ps <= reset_i? s_idle: ns;

        A_r <= A_n;
        P_r <= P_n;
        S_r <= S_n;

        step_count_r <= step_count_n;
    end

    // determine next state
    always_comb begin
        case (ps)
            s_idle: ns = v_i? s_compute: s_idle;
            s_compute: ns = mult_done? s_hold: s_compute;
            s_hold: ns = yumi_i? s_idle: s_hold;
        endcase
    end

    always_comb begin
        step_count_n = (ps == s_idle)? '0: step_count_r + 1; //reset_i? '0: step_count_r + (ps==s_compute);
        A_n = (ps==s_idle)? {a_i, lsb_zeros}: A_r;  // MSB = m, LSB = 0
        S_n = (ps==s_idle)? {(~a_i+1), lsb_zeros}: S_r;  // MSB = -a, LSB = 0s 
        
        unique case (P_r[1:0])
            2'b01: P_adder_lo = P_r + A_r;
            2'b10: P_adder_lo = P_r + S_r;
            default: P_adder_lo = P_r;  // 2'b00, 2'b11
        endcase

        P_idle_hold_lo = (ps==s_idle)? {'0, b_i, 1'b0}: P_r;
        P_lsr_lo = {P_adder_lo[2*data_width_p], P_adder_lo[2*data_width_p:1]}; //$signed(P_adder_lo) >>> 1;
        P_n = (ps==s_compute)? P_lsr_lo: P_idle_hold_lo;
    end

    assign v_o = (ps==s_hold);
    assign ready_o = (ps==s_idle);
    assign lsb_zeros = '0;
    assign data_o = P_r[2*data_width_p:1];
    assign mult_done = (step_count_r==data_width_p-1);

endmodule
