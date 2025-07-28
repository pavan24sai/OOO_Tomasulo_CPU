/*
    Author: Adam Friesz

    Description: Iterative integer dividor, optimized for area, implementing non-restoring
    division algorithm. Input data is registered from s_idle upon v_i, output data is held
    until yumi_i is asserted.

    a_i, b_i, div_o, rem_o all of size data_width_p.
    
    Inputs:
        - clk_i: clock signal
        - reset_i: reset signal
        - signed_i: whether to perform signed or unsigned division
        - v_i: whether the input data is valid, and thus computation should begin
        - yumi_i: whether the output data has been read (consumer says yummy, I ate the data)
        - a_i: the dividend
        - b_i: the divisor

    Outputs:
        - v_o: whether the output data is valid, computation is finished
        - div_o: the quotient
        - rem_o: the remainder

*/
module nrd_div #(data_width_p) (
    input logic clk_i, reset_i, signed_i, v_i, yumi_i,
    input logic [data_width_p-1:0] a_i, b_i,
    output logic ready_o, v_o,
    output logic [data_width_p-1:0] div_o, rem_o
);

    enum logic [1:0] {s_idle, s_compute, s_correct, s_hold} ps, ns;
    logic [4:0] count_r, count_n;
    logic [data_width_p*2-1:0] AQ_r, AQ_shifted, AQ_n;
    logic [data_width_p-1:0] M_r, A_shifted_lo, Q_shifted_lo, b_input, a_input,
        Q_comp_n, A_correct_n, A_n, Q_n, A_r, Q_r, A_adder_lo, A_adder_li1,
        A_adder_li2, A_out, Q_out, A_inv_li, Q_inv_li;

    logic count_eq_zero, A_shifted_ge_zero, A_n_ge_zero, A_r_ge_zero, retain_A_val,
        retain_Q_val, a_lt_b, a_lt_b_r, negate_quot_out_r, negate_rem_out_r, a_neg, b_neg;
    
    // update present state
    always_ff @(posedge clk_i) begin
        if (reset_i)
            ps <= s_idle;
        else
            ps <= ns;
    end

    // determine next state
    always_comb begin
        case (ps)
            s_idle: ns = ~v_i? s_idle: ~a_lt_b? s_compute: s_hold;
            s_compute: ns = count_eq_zero? s_correct: s_compute;
            s_correct: ns = s_hold;
            s_hold: ns = yumi_i? s_idle: s_hold;
        endcase
    end

    // update registers
    always_ff @(posedge clk_i) begin
        AQ_r <= AQ_n;
        count_r <= count_n;
        M_r <= (ps == s_idle)? b_input: M_r;

        // control flags
        a_lt_b_r <= (ps == s_idle)? a_lt_b: a_lt_b_r;

        // negate quotient if an odd number of inputs were negative
        negate_quot_out_r <= (ps == s_idle)? a_neg ^ b_neg: negate_quot_out_r;

        // negate remainder
        negate_rem_out_r <= (ps == s_idle)? (a_neg & b_neg) | (a_neg & ~b_neg): negate_rem_out_r;
    end

    // netnames
    assign A_r = AQ_r[2*data_width_p-1: data_width_p];
    assign Q_r = AQ_r[data_width_p-1: 0];

    assign AQ_shifted = AQ_r << 1;

    assign A_shifted_lo = AQ_shifted[2*data_width_p-1: data_width_p];
    assign Q_shifted_lo = AQ_shifted[data_width_p-1:0];

    // either take value from before or after shift depending whether used during
    // compute or correct stage
    assign A_adder_li1 = (ps == s_compute)? A_shifted_lo: A_r;
    assign A_adder_li2 = A_shifted_ge_zero? -M_r: M_r; //(M_r ^ A_shifted_ge_zero) + A_shifted_ge_zero;
    assign A_adder_lo = A_adder_li1 + A_adder_li2;
    
    assign Q_comp_n[data_width_p-1:1] = Q_shifted_lo[data_width_p-1:1];  // only shift into LSB of Q
    assign Q_comp_n[0] = A_n_ge_zero;

    assign Q_n = retain_Q_val? Q_r: (ps == s_idle)? a_input: Q_comp_n;
    assign A_n = retain_A_val? A_r: (ps == s_idle)? '0: A_adder_lo;

    assign AQ_n = {A_n, Q_n};
    
    assign count_n = (ps == s_idle)? 5'd31: count_r - (ps == s_compute);

    // control signals
    assign count_eq_zero = (count_r == '0);
    assign A_shifted_ge_zero = (ps == s_compute) & ~A_shifted_lo[data_width_p-1];  // sign bit of shifted data
    assign A_n_ge_zero = ~A_adder_lo[data_width_p-1];  // sign bit of A_n
    assign A_r_ge_zero = ~AQ_r[2*data_width_p-1];
    assign a_lt_b = a_input < b_input;
    
    assign retain_A_val = (ps == s_correct & A_r_ge_zero) | ps == s_hold; // (count_eq_zero & ps == s_compute) | 
    assign retain_Q_val = (ps == s_hold) | (ps == s_correct);

    assign a_neg = signed_i & a_i[data_width_p-1];
    assign b_neg = signed_i & b_i[data_width_p-1];

    // take 2s complement of inputs if they are negative
    assign a_input = (a_i ^ {data_width_p{a_neg}}) + a_neg;  // bitwise xor performs selective negation
    assign b_input = (b_i ^ {data_width_p{b_neg}}) + b_neg;

    // output signals
    assign v_o = (ps == s_hold);
    assign ready_o = (ps == s_idle);

    // to account for inputs where a_lt_b
    // since A starts at 0 and Q starts at a_i which is what we want to output
    
    assign A_inv_li = a_lt_b_r? A_r: Q_r;
    assign Q_inv_li = a_lt_b_r? Q_r: A_r;

    assign div_o = (A_inv_li ^ {data_width_p{negate_quot_out_r}}) + negate_quot_out_r;
    assign rem_o = (Q_inv_li ^ {data_width_p{negate_rem_out_r}}) + negate_rem_out_r;

endmodule
