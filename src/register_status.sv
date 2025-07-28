/*
    Register file status registers - FIXED for same-cycle commit/issue race
*/

`include "structs.svh"

module register_status (
    input logic clk_i, reset_i, issue_wr_en_i, commit_wr_en_i,
    input logic [4:0] issue_rd_addr1_i, issue_rd_addr2_i, issue_wr_addr_i, commit_wr_addr_i,
    input logic [3:0] issue_reorder_addr_i, commit_reorder_addr_i,
    output register_status_s issue_rd_data1_o, issue_rd_data2_o,
    output logic same_cycle_commit_rs1_o, same_cycle_commit_rs2_o
);

    // Register status table - one entry per architectural register
    register_status_s regstat_r [31:0];
    register_status_s regstat_n [31:0];

    // Sequential logic
    always_ff @(posedge clk_i) 
    begin
        if (reset_i) 
        begin
            // Clear all register status entries on reset
            for (int i = 0; i < 32; i++) 
            begin
                regstat_r[i].busy <= 1'b0;
                regstat_r[i].reorder_addr <= 4'b0;
            end
        end 
        else 
        begin
            regstat_r <= regstat_n;
        end
    end

    // Combinational logic
    always_comb 
    begin
        // Default: maintain current state
        regstat_n = regstat_r;
        
        // Handle commit first (free up registers)
        if (commit_wr_en_i && commit_wr_addr_i != 5'b0) 
        begin // x0 is always 0
            if (regstat_r[commit_wr_addr_i].busy && 
                regstat_r[commit_wr_addr_i].reorder_addr == commit_reorder_addr_i) 
            begin
                regstat_n[commit_wr_addr_i].busy = 1'b0;
                regstat_n[commit_wr_addr_i].reorder_addr = 4'b0;
            end
        end
        
        // Handle new issue (mark registers as busy)
        if (issue_wr_en_i && issue_wr_addr_i != 5'b0) 
        begin // x0 is always 0
            regstat_n[issue_wr_addr_i].busy = 1'b1;
            regstat_n[issue_wr_addr_i].reorder_addr = issue_reorder_addr_i;
        end
    end

    // ✅ CRITICAL FIX: Output assignments that handle same-cycle commit
    // If a register is being committed in the same cycle, use the cleared status
    logic commit_clears_reg1, commit_clears_reg2;
    
    assign commit_clears_reg1 = commit_wr_en_i && 
                               (commit_wr_addr_i == issue_rd_addr1_i) &&
                               regstat_r[issue_rd_addr1_i].busy &&
                               (regstat_r[issue_rd_addr1_i].reorder_addr == commit_reorder_addr_i);
    
    assign commit_clears_reg2 = commit_wr_en_i && 
                               (commit_wr_addr_i == issue_rd_addr2_i) &&
                               regstat_r[issue_rd_addr2_i].busy &&
                               (regstat_r[issue_rd_addr2_i].reorder_addr == commit_reorder_addr_i);

    // Output the correct status considering same-cycle commits
    always_comb begin
        if (commit_clears_reg1) begin
            issue_rd_data1_o.busy = 1'b0;
            issue_rd_data1_o.reorder_addr = 4'b0;
        end else begin
            issue_rd_data1_o = regstat_r[issue_rd_addr1_i];
        end
        
        if (commit_clears_reg2) begin
            issue_rd_data2_o.busy = 1'b0;
            issue_rd_data2_o.reorder_addr = 4'b0;
        end else begin
            issue_rd_data2_o = regstat_r[issue_rd_addr2_i];
        end
    end

    // Export same-cycle commit detection for instruction decode stage
    assign same_cycle_commit_rs1_o = commit_clears_reg1;
    assign same_cycle_commit_rs2_o = commit_clears_reg2;

    // DEBUG: Print register status updates
    always @(posedge clk_i) begin
        if (!reset_i) begin
            // Print commits
            if (commit_wr_en_i && commit_wr_addr_i != 5'b0) begin
                $display("[REGSTAT] COMMIT: x%0d ROB=%0d (was_busy=%b)", 
                         commit_wr_addr_i, commit_reorder_addr_i, 
                         regstat_r[commit_wr_addr_i].busy);
            end
            
            // Print new issues
            if (issue_wr_en_i && issue_wr_addr_i != 5'b0) begin
                $display("[REGSTAT] ISSUE: x%0d ROB=%0d (was_busy=%b)", 
                         issue_wr_addr_i, issue_reorder_addr_i, 
                         regstat_r[issue_wr_addr_i].busy);
            end
            
            // Print same-cycle forwarding
            if (commit_clears_reg1) begin
                $display("[REGSTAT] SAME_CYCLE_FWD: x%0d cleared for issue", issue_rd_addr1_i);
            end
            if (commit_clears_reg2) begin
                $display("[REGSTAT] SAME_CYCLE_FWD: x%0d cleared for issue", issue_rd_addr2_i);
            end
        end
    end

endmodule