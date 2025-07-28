/*
    Reservation Station Manager
	-> Implements the reservation stations component for the functional units as described by the Tomasulo's algorithm.
	-> These form the crux of the algorithm which enables OOO execution on the CPU core.
*/

`include "structs.svh"

module reservation_station_manager #(
    parameter RS_SIZE = 4,              
    parameter RS_TAG_OFFSET = 0         
)(
    input logic clk_i, reset_i, flush_i,
    
    // Issue interface
    input logic issue_valid_i,
    input wire reservation_station_s issue_packet_i,
    
    // CDB interface
    input wire cdb_packet_s cdb_packet_i,
    
    // Execute interface  
    input logic fu_ready_i,             
    output logic execute_valid_o,       
    output reservation_station_s execute_packet_o,
    output logic [3:0] execute_tag_o,   
    
    // Status
    output logic rs_full_o              
);

    // Parameter validation
    initial 
	begin
        assert (RS_SIZE > 0 && RS_SIZE <= 8) 
            else $fatal("RS_SIZE must be between 1 and 8");
        assert (RS_TAG_OFFSET >= 0 && RS_TAG_OFFSET <= 15) 
            else $fatal("RS_TAG_OFFSET must be between 0 and 15");
        assert ((RS_TAG_OFFSET + RS_SIZE) <= 16) 
            else $fatal("Tag range exceeds maximum");
    end

    // Storage and signals
    reservation_station_s rs [RS_SIZE-1:0];
    logic [RS_SIZE-1:0] rs_empty, rs_ready;
    logic [$clog2(RS_SIZE)-1:0] issue_idx, execute_idx;
    logic issue_en, execute_en;
    
    // Check if issued instruction can execute immediately (bypass)
    logic same_slot_bypass;
    logic issue_ready_immediate;

    // Status generation
    always_comb 
	begin
        for (int i = 0; i < RS_SIZE; i++) 
		begin
            rs_empty[i] = !rs[i].busy;
            rs_ready[i] = rs[i].busy && (rs[i].qj == 4'b0) && (rs[i].qk == 4'b0);
        end
        rs_full_o = ~|rs_empty;
    end

    // Issue slot allocation (FIFO: prefer lower indices)
    always_comb 
	begin
        issue_idx = '0;
        for (int i = RS_SIZE-1; i >= 0; i--) 
		begin
            if (rs_empty[i]) 
			begin
                issue_idx = i[$clog2(RS_SIZE)-1:0];
            end
        end
    end

    // Check if issued instruction is immediately ready
    always_comb 
	begin
        issue_ready_immediate = issue_valid_i && !rs_full_o && (issue_packet_i.qj == 4'b0) && (issue_packet_i.qk == 4'b0);
    end

    // Only for single-cycle units (ALU=tag 0-3, MEM=tag 8-11)
    logic is_single_cycle_unit;
    assign is_single_cycle_unit = (RS_TAG_OFFSET == 0) || (RS_TAG_OFFSET == 8);

    //  Check if we can issue and execute on same slot (single-cycle only)
    always_comb 
	begin
        same_slot_bypass = issue_ready_immediate && fu_ready_i && (execute_idx == issue_idx) && !rs_ready[issue_idx] && is_single_cycle_unit;
    end

    // Execute selection with bypass (priority: prefer lower indices, in other words: older instructions!)
    always_comb 
	begin
        execute_valid_o = 1'b0;
        execute_idx = '0;
        
        // First check for bypass case
        if (same_slot_bypass) 
		begin
            execute_valid_o = 1'b1;
            execute_idx = issue_idx;
        end
        else 
		begin
            // Normal execute selection
            for (int i = RS_SIZE-1; i >= 0; i--) 
			begin
                if (rs_ready[i] && fu_ready_i) 
				begin
                    execute_valid_o = 1'b1;
                    execute_idx = i[$clog2(RS_SIZE)-1:0];
                end
            end
        end
    end

    // Control signals
    assign issue_en = issue_valid_i && !rs_full_o;
    assign execute_en = execute_valid_o && fu_ready_i;
    
    // Output packet selection
    always_comb 
	begin
        if (same_slot_bypass) 
		begin
            // use issue packet directly (bypass case)
            execute_packet_o = issue_packet_i;
        end 
		else 
		begin
            // use RS packet (regular case)
            execute_packet_o = rs[execute_idx];
        end
    end
    
    assign execute_tag_o = RS_TAG_OFFSET + execute_idx;

    // RS updates with immediate clearing
    always_ff @(posedge clk_i) 
	begin
        if (reset_i || flush_i) 
		begin
            for (int i = 0; i < RS_SIZE; i++) 
                rs[i] <= '0;
        end 
        else 
		begin
            // CDB monitoring for operand forwarding
            if (cdb_packet_i.valid) 
			begin
                for (int i = 0; i < RS_SIZE; i++) 
				begin
                    if (rs[i].busy) 
					begin
                        // Update source operand J
                        if (rs[i].qj == cdb_packet_i.rob_entry && rs[i].qj != 4'b0) 
						begin
                            rs[i].vj <= cdb_packet_i.data;
                            rs[i].qj <= 4'b0;
                        end
                        
                        // Update source operand K  
                        if (rs[i].qk == cdb_packet_i.rob_entry && rs[i].qk != 4'b0) 
						begin
                            rs[i].vk <= cdb_packet_i.data;
                            rs[i].qk <= 4'b0;
                        end
                    end
                end
            end
            
            // Issue new instruction (unless bypassed)
            if (issue_en && !same_slot_bypass) 
			begin
                rs[issue_idx] <= issue_packet_i;
                rs[issue_idx].busy <= 1'b1;
            end
            
            // Clear immediately when instruction sent to FU
            if (execute_en && !same_slot_bypass) 
			begin
                rs[execute_idx].busy <= 1'b0;
            end
        end
    end

endmodule