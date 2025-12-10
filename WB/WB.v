// =====================================
// WB Stage (Write Back)
// 負責：
//   - 根據 MemtoReg 決定要寫回 ALU 結果 or Memory data
//   - 將結果輸出給 Register File
// =====================================

module WB(
    // ===== MEM/WB pipeline inputs =====
    input         RegWrite_i,       // 是否要寫回 RF
    input         MemtoReg_i,       // 1 = Memory data, 0 = ALU result
    input  [31:0] read_data_i,      // lw 資料
    input  [31:0] ALU_result_i,     // R-type/addi/sw/lw 的 ALU result
    input  [4:0]  dest_reg_i,       // 最終要寫回的 register index

    // ===== outputs to Register File =====
    output        WB_RegWrite_o,    // 給 RF 的寫入 enable
    output [4:0]  WB_WriteAddr_o,   // 寫入的暫存器編號
    output [31:0] WB_WriteData_o    // 寫入的資料
);

//
// =====================================
// 1. MemtoReg MUX
// =====================================
// 決定要寫回哪個資料
assign WB_WriteData_o = (MemtoReg_i) ? read_data_i : ALU_result_i;      // to ALU mux and RF

//
// =====================================
// 2. 回傳給 Register File 的控制
// =====================================
assign WB_RegWrite_o  = RegWrite_i;    // 是否要寫回, to forwarding unit and RF
assign WB_WriteAddr_o = dest_reg_i;    // 寫回哪個暫存器 to forwarding unit and RF

endmodule
