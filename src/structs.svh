`ifndef STRUCTS_SVH
`define STRUCTS_SVH

// Register Status Table Entries
typedef struct packed {
    logic        busy;           // Is register waiting for a result?
    logic [3:0]  reorder_addr;   // ROB entry that will write to this register
} register_status_s;

// Re-Order Buffer Entries
typedef struct packed {
    logic        busy;           	// Is this ROB entry occupied?
    logic        ready;          	// Is instruction complete and ready to commit?
    logic [3:0]  instruction;    	// What type of instruction (ADD=0, SUB=1, etc)
    logic [4:0]  dest_reg;       	// Destination register (0 = no dest)
    logic [31:0] value;          	// Result value (for non-store instructions)
    logic [31:0] store_addr;     	// Store address (for store instructions)
    logic [31:0] store_data;     	// Store data (for store instructions)
    logic        is_branch;      	// Is this a branch instruction?
    logic        branch_taken;   	// Was branch taken? (valid when ready)
    logic [31:0] branch_target;  	// Branch target address
    logic        predicted_taken; 	// Was branch predicted taken?
    logic [31:0] predicted_target; 	// Predicted branch target
    logic        exception;      	// Did instruction cause an exception?
    logic [31:0] pc;             	// PC of this instruction
} rob_s;

// Reservation Station Entries
typedef struct packed {
    logic        busy;           // Is this reservation station occupied?
    logic [3:0]  op;             // Operation to perform (same as rob_s.instruction)
    logic [31:0] vj, vk;         // Values of source operands
    logic [3:0]  qj, qk;         // Tags of reservation stations producing operands (0 = ready)
    logic [3:0]  dest;           // ROB entry that will receive result
    logic [31:0] address;        // For memory operations: immediate/offset value
    logic [1:0]  fu_type;        // Which functional unit type needed (ALU=0, MUL=1, DIV=2, MEM=3)
    logic [31:0] pc;             // PC for branch target calculation
} reservation_station_s;

// Common Data Bus Entries
typedef struct packed {
    logic        valid;          // Is this broadcast valid?
    logic [3:0]  tag;            // Which reservation station is broadcasting
    logic [31:0] data;           // Result data
    logic [3:0]  rob_entry;      // ROB entry to update
    logic        is_branch;      // Is this a branch result?
    logic        branch_taken;   // Branch outcome
    logic [31:0] branch_target;  // Branch target address
    logic        exception;      // Did instruction cause exception?
} cdb_packet_s;

// Branch Target Buffer entries (for gshare branch predictor)
typedef struct packed {
    logic        valid;          // Is this BTB entry valid?
    logic [31:0] pc;             // PC of the branch instruction
    logic [31:0] target;         // Target address of the branch
} btb_entry_s;

`endif  // STRUCTS_SVH