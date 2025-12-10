module ID_EX(
    input    clk,
    input    rst, 
    input ID_EX_Flush,      // hazard unit 控制：1=清除(ID/EX插入NOP), 0=正常更新
// Cycle 1: lw 在 ID 階段
//          - Hazard Unit 偵測到：下一指令要用 lw 的結果
//          - 發出信號：IF_ID_Write=0, PC_Write=0, ID_EX_Flush=0
         
// Cycle 2: lw 進 EX，後面指令「卡在 IF/ID」
//          - IF/ID 不更新（IF_ID_Write=0）
//          - PC 不動（PC_Write=0）
//          - ID_EX 保持原值（ID_EX_Flush=0，正常更新 lw）
//          - 後面指令還在 IF 階段，沒進 ID
         
// Cycle 3: lw 進 MEM（此時結果可能出來了）
//          - 後面指令終於進 ID
//          - 用前饋拿到 lw 結果，避免再卡一次

    // Control signals
    input RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i,
    // 是否允許把結果寫回 Register File (R-type, lw, immmediate)
    // WB 階段的 mux 控制 來自記憶體還是 ALU (ALU(0) / Memory(1, lw))
    // 記憶體是否要做「讀取」動作 (lw(1) / sw, R-type(0))
    // 記憶體是否要做「寫入」動作 (sw(1) / lw, R-type(0))
    input [1:0] ALUOp_i,                               // ALU control signals
    input ALUSrc_i,                                    // 決定 ALU 的第二個運算元來自哪裡 rt(0)/imm(1)

    // Data
    input [31:0] rs_i, rt_i, imm_i,                  // rs, rt, sign extended immediate
    input [5:0]  funct_i,                            // 與 ALUOp 一起決定 ALU 控制信號
    input [4:0]  rs_addr_i, rt_addr_i, rd_addr_i,    // 下面四條線

    // Outputs
    output reg RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o,
    output reg [1:0] ALUOp_o,
    output reg ALUSrc_o,

    output reg [31:0] rs_o, rt_o, imm_o,
    output reg [5:0]  funct_o,
    output reg [4:0]  rs_addr_o, rt_addr_o, rd_addr_o
);

always @(posedge clk or posedge rst) begin
    if (rst || ID_EX_Flush) begin
        {RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 0;
        ALUOp_o    <= 0;
        ALUSrc_o   <= 0;
        funct_o    <= 0;
        rs_o       <= 0;
        rt_o       <= 0;
        imm_o      <= 0;
        rs_addr_o  <= 0;
        rt_addr_o  <= 0;
        rd_addr_o  <= 0;
    end else begin
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        MemRead_o  <= MemRead_i;
        MemWrite_o <= MemWrite_i;
        ALUOp_o    <= ALUOp_i;
        ALUSrc_o   <= ALUSrc_i;

        funct_o    <= funct_i;
        rs_o       <= rs_i;
        rt_o       <= rt_i;
        imm_o      <= imm_i;
        rs_addr_o  <= rs_addr_i;
        rt_addr_o  <= rt_addr_i;
        rd_addr_o  <= rd_addr_i;
    end
end

endmodule
