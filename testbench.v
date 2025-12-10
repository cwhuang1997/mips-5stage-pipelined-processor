`timescale 1ns/1ps

module tb_CPU;

reg clk;
reg rst;

// Instantiate CPU
CPU dut (
    .clk(clk),
    .rst(rst)
);

// Clock generation: 10ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;   // 100MHz
end

// Reset logic
initial begin
    rst = 1;
    #20 rst = 0;
end

// Simulation control
initial begin
    // waveform
    $dumpfile("cpu.vcd");
    $dumpvars(0, tb_CPU);

    // Run simulation long enough for pipeline
    #500;

    $display("=== Simulation Finished ===");
    $finish;
end

endmodule
