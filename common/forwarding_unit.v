// ===============================================
// Forwarding Unit
// 決定 EX 階段需要從哪裡取運算元：正常 / EX/MEM / MEM/WB
// ===============================================
module Forwarding_Unit(

    // ===== 來自 ID/EX (現行指令使用的暫存器) =====
    input  [4:0] ID_EX_rs,          // EX 階段進來的rs 去對照有沒有跟後面要寫回的一樣
    input  [4:0] ID_EX_rt,          // EX 階段進來的rt 去對照有沒有跟後面要寫回的一樣

    // ===== 來自 EX/MEM (上一條指令) =====
    input        EX_MEM_RegWrite,
    input  [4:0] EX_MEM_rd,          // EX/MEM dest register

    // ===== 來自 MEM/WB (再上一條指令) =====
    input        MEM_WB_RegWrite,
    input  [4:0] MEM_WB_rd,          // MEM/WB dest register

    // ===== Forwarding outputs =====
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

always @(*) begin
    // 預設不 forward
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // ====================================
    // Forward A (src1)
    // ====================================
    // EX hazard：EX/MEM → EX
    if (EX_MEM_RegWrite &&
        (EX_MEM_rd != 0) &&
        (EX_MEM_rd == ID_EX_rs)) begin
        ForwardA = 2'b10;
    end
    // MEM hazard：MEM/WB → EX
    else if (MEM_WB_RegWrite &&
             (MEM_WB_rd != 0) &&
             (MEM_WB_rd == ID_EX_rs)) begin
        ForwardA = 2'b01;
    end

    // ====================================
    // Forward B (src2)
    // ====================================
    if (EX_MEM_RegWrite &&
        (EX_MEM_rd != 0) &&
        (EX_MEM_rd == ID_EX_rt)) begin
        ForwardB = 2'b10;
    end
    else if (MEM_WB_RegWrite &&
             (MEM_WB_rd != 0) &&
             (MEM_WB_rd == ID_EX_rt)) begin
        ForwardB = 2'b01;
    end
end

endmodule
