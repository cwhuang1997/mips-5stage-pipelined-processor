module IF_ID(
    input         clk,
    input         rst,              
    input         IF_ID_Write,      // hazard unit 控制：1=更新, 0=保持 (用於load use hazard stalling)
    input  [31:0] instr_i,         // 從 IF 階段來的指令
    input  [31:0] pc_i,            // 從 IF 階段來的 PC+4
    output reg [31:0] instr_o,    // 給 ID 階段的指令
    output reg [31:0] pc_o        // 給 ID 階段的 PC+4
);

// 優先度：rst > IF_Flush > IF_ID_Write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        instr_o <= 32'b0;
        pc_o    <= 32'b0;
    end 
    else if (IF_ID_Write) begin
        // Normal：沒有 hazard → pipeline 正常流動
        instr_o <= instr_i;
        pc_o    <= pc_i;
    end
    // else: IF_ID_Write=0 時保持現有數值
end

endmodule
