# Files Overview

#### `cpu.sv`
- **Main CPU top-level module** that connects all components.
- **Controls pipeline stalls and flushes** on branch mispredictions.

#### `instruction_fetch_stage.sv`
- **Fetches instructions** from instruction memory.
- **Implements program counter logic** with branch prediction support.
- **Handles pipeline stalls and flush recovery**.

#### `instruction_decode_issue_stage.sv`
- **Decodes RISC-V instructions**.
- **Issues instructions to appropriate reservation stations** based on operation type.
- **Tracks instruction dependencies**.

#### `reservation_station_manager.sv`
- **Manages groups of reservation stations** for each functional unit type.
- **Implements register renaming through tag system** (qj/qk fields reference other reservation stations or ROB entries).
- **Handles instruction dispatch** when operands become ready.

#### `alu_functional_unit.sv`
- **Single-cycle arithmetic logic unit** for basic operations (ADD, SUB, AND, OR, XOR).

#### `multiplier_functional_unit.sv`
- **Multi-cycle multiplier** using Booth's algorithm for signed multiplication.
- **Implements state machine** for iterative computation over multiple cycles.
- **Handles both signed and unsigned** multiplication operations.

#### `divider_functional_unit.sv`
- **Multi-cycle divider** using non-restoring division algorithm.
- **Supports both division and remainder** operations.

#### `memory_functional_unit.sv`
- **Handles load and store operations** with single-cycle memory interface.
- **Computes effective addresses** using base + offset addressing.
- **Manages memory read/write control signals**.

#### `cdb_controller.sv`
- **Arbitrates access to Common Data Bus** between functional units.
- **Implements priority-based scheduling** (ALU > MEM > MUL > DIV).
- **Broadcasts results to all waiting instructions** simultaneously.

#### `commit_stage.sv`
- **Manages reorder buffer** for in-order instruction commit.
- **Handles branch misprediction recovery** and pipeline flushes.
- **Updates architectural state** (regfile, memory) only when instructions commit.

#### `register_status.sv`
- **Tracks register dependencies** by mapping architectural registers to ROB entries.
- **Implements register renaming mechanism** where busy registers point to ROB tags instead of values.

#### `gshare_branch_predictor.sv`
- **Branch prediction** using global history and local pattern tables.
- **Implements 2-bit saturating counters** for prediction confidence.
- **Updates prediction tables** based on actual branch outcomes.

#### `structs.svh`
- **Defines data structures** used throughout the design (reservation stations, ROB entries, CDB packets).