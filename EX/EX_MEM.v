module EX_MEM(
    input clk, rst,

    // Control
    input RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i,
    // 是否允許把結果寫回 Register File (R-type, lw, immmediate)
    // WB 階段的 mux 控制 來自記憶體還是 ALU (ALU(0) / Memory(1, lw))
    // 記憶體是否要做「讀取」動作 (lw(1) / sw, R-type(0))
    // 記憶體是否要做「寫入」動作 (sw(1) / lw, R-type(0))

    // Data
    input [31:0] ALU_i,    // ALU result (運算結果, memory address)
    input [31:0] rt_i,     // 為了 sw 要寫入 Data Memory 的資料 (第二個mux下面那條Output)
    input [4:0]  rd_i,     // 要寫回的暫存器編號

    // Output
    output reg RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o,
    output reg [31:0] ALU_o,
    output reg [31:0] rt_o,
    output reg [4:0]  rd_o
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        {RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 0;
        ALU_o <= 0;
        rt_o  <= 0;
        rd_o  <= 0;
    end else begin
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        MemRead_o  <= MemRead_i;
        MemWrite_o <= MemWrite_i;
    
        ALU_o <= ALU_i;
        rt_o  <= rt_i;
        rd_o  <= rd_i;
    end
end

endmodule
