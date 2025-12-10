module MEM_WB(
    input clk, rst,

    input RegWrite_i, MemtoReg_i,
    input [31:0] read_data_i,      // lw data
    input [31:0] ALU_i,            // ALU result
    input [4:0]  rd_i,             // destination register

    output reg RegWrite_o, MemtoReg_o,  
    // 是否允許把結果寫回 Register File (R-type, lw, immmediate)
    // WB 階段的 mux 控制 來自記憶體還是 ALU (ALU(0) / Memory(1, lw))
    output reg [31:0] read_data_o,
    output reg [31:0] ALU_o,
    output reg [4:0]  rd_o
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        RegWrite_o <= 0;
        MemtoReg_o <= 0;
        read_data_o <= 0;
        ALU_o <= 0;
        rd_o <= 0;
    end else begin
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        read_data_o <= read_data_i;
        ALU_o <= ALU_i;
        rd_o <= rd_i;
    end
end

endmodule
