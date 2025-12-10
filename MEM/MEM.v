// =====================================
// MEM Stage (Memory Access)
// 負責：
//   - lw：讀資料 memory[ALU_result]
//   - sw：寫資料 memory[ALU_result]
//   - 控制訊號傳遞到 MEM/WB
// =====================================

module MEM(
    input         clk,
    input         rst,

    // ===== EX/MEM pipeline inputs =====
    input         RegWrite_i,
    input         MemtoReg_i,
    input         MemRead_i,
    input         MemWrite_i,

    input  [31:0] ALU_result_i,   // memory address
    input  [31:0] rt_data_i,      // sw data
    input  [4:0]  dest_reg_i,     // 寫回的暫存器編號

    // ===== outputs to MEM/WB pipeline =====
    output        RegWrite_o,     // 分一條給forwarding unit 告知這邊有資料要寫回, 一條給MEM/WB
    output        MemtoReg_o,     // 繼續往下傳到 WB 階段的 mux 控制 來自記憶體還是 ALU (ALU(0) / Memory(1, lw))
    output [31:0] read_data_o,    // lw data, 只有 MemRead=1 時才會讀
    output [31:0] ALU_result_o,   // bypass 到 WB 以及 forwarding時需要
    output [4:0]  dest_reg_o      // to MEM/WB and forwarding unit
);

// =====================================
// DataMemory (lw / sw)
// =====================================
DataMemory DMEM(
    .clk        (clk),
    .MemRead_i  (MemRead_i),
    .MemWrite_i (MemWrite_i),
    .addr_i     (ALU_result_i),
    .write_data_i (rt_data_i),   // sw 的資料
    .read_data_o  (read_data_o)  // lw 的資料
);

// =====================================
// Pass signals to MEM/WB and forwarding unit
// =====================================
assign RegWrite_o   = RegWrite_i;       // to MEM/WB and forwarding unit
assign MemtoReg_o   = MemtoReg_i;       // to MEM/WB
assign ALU_result_o = ALU_result_i;     // to MEM/WB and forwarding unit and ALU mux
assign dest_reg_o   = dest_reg_i;       // to MEM/WB and forwarding unit

endmodule
