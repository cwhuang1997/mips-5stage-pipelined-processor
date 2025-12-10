module Reg_File(
    input         clk,
    input         rst,

    // read ports
    input  [4:0]  RSaddr_i,
    input  [4:0]  RTaddr_i,
    output [31:0] RSdata_o,
    output [31:0] RTdata_o,

    // write port (WB stage)
    input  [4:0]  RDaddr_i,
    input  [31:0] RDdata_i,
    input         RegWrite_i
);

reg [31:0] registers[0:31];     // 32 registers of 32 bits each

// read (combinational) + bypass for same-cycle write
assign RSdata_o =
    (RegWrite_i && (RSaddr_i == RDaddr_i) && RDaddr_i != 0)
        ? RDdata_i
        : registers[RSaddr_i];

assign RTdata_o =
    (RegWrite_i && (RTaddr_i == RDaddr_i) && RDaddr_i != 0)
        ? RDdata_i
        : registers[RTaddr_i];

integer i;

// write (sequential)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // reset to 0
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'b0;
    end else begin
        if (RegWrite_i && (RDaddr_i != 5'b0))      // write back to register file, $0 always zero
            registers[RDaddr_i] <= RDdata_i;
        // MIPS: register $0 ¥Ã»·¬O 0
    end
end

endmodule
