// ============================================================================
// STAGE 1: INSTRUCTION FETCH
// ============================================================================

`include "structs.svh"

module instruction_fetch_stage (
    input logic clk_i, 
	input logic reset_i,
    
    // Control inputs
    input logic stall_i,
    input logic flush_i,
    input logic [31:0] flush_pc_i,
    
    // Branch prediction inputs
    input logic take_branch_i,
    input logic [31:0] predicted_pc_i,
    
    // Outputs
    output logic [31:0] pc_o,
    output logic [31:0] instruction_o
);

    logic [31:0] pc_r, pc_n;
    
    always_ff @(posedge clk_i) 
	begin
        if (reset_i) 
			pc_r <= 32'h0;
        else 
			pc_r <= pc_n;
    end
    
    always_comb 
	begin
        if (flush_i) 
			pc_n = flush_pc_i;
        else if (stall_i) 
			pc_n = pc_r;
        else if (take_branch_i) 
			pc_n = predicted_pc_i;
        else 
			pc_n = pc_r + 4;
    end
    
    assign pc_o = pc_r;
    
    // Instruction Memory
    instructmem imem (
        .address(pc_r),
        .instruction(instruction_o),
        .clk(clk_i)
    );

endmodule