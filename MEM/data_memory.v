// =====================================
// Data Memory (for lw, sw)
// =====================================

module DataMemory(
    input         clk,
    input         MemRead_i,
    input         MemWrite_i,
    input  [31:0] addr_i,
    input  [31:0] write_data_i,
    output [31:0] read_data_o
);

reg [31:0] memory [0:255]; // 256 words = 1KB

// read (combinational)
assign read_data_o = (MemRead_i) ? memory[addr_i[31:2]] : 32'b0;

// write (synchronous)
always @(posedge clk) begin
    if (MemWrite_i)
        memory[addr_i[31:2]] <= write_data_i;
end

endmodule
