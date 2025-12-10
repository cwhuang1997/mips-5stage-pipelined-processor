// ===============================================
// Hazard Detection Unit
// 處理 lw-use hazard
// ===============================================
module Hazard_Detection_Unit(
    input        ID_EX_MemRead,    // EX 階段的指令是否是 lw
    input  [4:0] ID_EX_rt,         // lw 的目的暫存器 (rt)

    input  [4:0] IF_ID_rs,         // 下一條指令的 rs
    input  [4:0] IF_ID_rt,         // 下一條指令的 rt

    output reg   PC_Write,         // PC_Write = 0 → PC 停住 不更新 PC (也就是下一個 clk時PC 不變)
    output reg   IF_ID_Write,      // IF/ID Write = 0 → IF/ID 暫存器不更新 保持原值
    output reg   ID_EX_Flush       // 1 → 插入 NOP（讓 EX 泡 1 cycle）
);

always @(*) begin
    // 預設正常前進（不 stall）
    PC_Write    = 1;
    IF_ID_Write = 1;
    ID_EX_Flush = 0;

    // ==========================
    // load-use hazard：
    // lw $rt, XXX
    // 下一條指令如果需要 rt → forwarding 無法解決 → 必須 stall
    // ==========================
    if (ID_EX_MemRead &&
       ((ID_EX_rt == IF_ID_rs) || (ID_EX_rt == IF_ID_rt))) begin    // 只檢查 rt有沒有相同(i.e., lw 的目的暫存器) 另一種情況rs 用forwarding 解決

        PC_Write    = 0;   // PC 停住（IF 不會取新指令）
        IF_ID_Write = 0;   // IF/ID 暫存器保持（避免下一條進入 EX）
        ID_EX_Flush = 1;   // 在 EX 插入 bubble (NOP)
    end
end

endmodule
