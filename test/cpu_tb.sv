// minimal testbench setup to run assembly benchmarks on the cpu

`include "../../src/macros.svh"
module cpu_tb ();
    logic clk, reset;
    
    cpu dut (.*);
    
    // Clock generation
    always #5 clk <= ~clk;

    initial begin
        clk <= 1'b0;

        // Reset
        reset <= 1'b1;
        @(posedge clk);
        @(posedge clk);
        reset <= 1'b0;
        @(posedge clk);

        // Run benchmark
        repeat(`SIM_CYCLES + 1)
            @(posedge clk);

        $finish;
    end

endmodule
