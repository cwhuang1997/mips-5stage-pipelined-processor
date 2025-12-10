// =====================================
// ID Stage (Instruction Decode)
// 負責：
//   1. Instruction Decode（由 opcode 產生控制訊號）
//   2. Register File → 讀 rs、rt
//   3. Sign-Extend → 立即值擴展為 32-bit
//   4. Branch 判斷（rs == rt）
//   5. 將所有資料送給 ID/EX pipeline register
// =====================================

module ID(
    input         clk,
    input         rst,

    // ===== 來自 IF/ID Pipeline Register =====
    input  [31:0] instr_i,      // 取出的指令
    input  [31:0] pc_plus4_i,   // PC + 4（供 branch 計算）

    // ===== 寫回階段需要寫回 RF =====
    input         WB_RegWrite_i, // (MEM/WB) RegWrite 信號
    // 跟著stage 移動的 RegWrite_in(1/0) 到達 MEM/WB後 output 出WB_RegWrite_i(1/0)傳至Reg file
    input  [4:0]  WB_WriteAddr_i,// (MEM/WB) 寫回的目的暫存器 (rd 或 rt)
    input  [31:0] WB_WriteData_i,// (MEM/WB) 寫回的資料

    // ===== 輸出給 ID/EX Pipeline Register =====
    output        RegWrite_o,     // 是否允許寫回 Register File
    output        MemtoReg_o,     // WB mux：ALU(0) / Memory(1)
    output        MemRead_o,      // 記憶體讀取控制 (lw=1 / 其他=0)
    output        MemWrite_o,     // 記憶體寫入控制 (sw=1 / 其他=0)
    output [1:0]  ALUOp_o,        // ALU 運算碼
    output        ALUSrc_o,       // ALU 第二運算元：寄存器(0) / 立即數(1)

    output [31:0] rs_data_o,      // rs 寄存器資料
    output [31:0] rt_data_o,      // rt 寄存器資料
    output [31:0] imm_o,          // 符號擴展後的立即數
    output [5:0]  funct_o,        // funct field（用於 ALU Control）

    output [4:0]  rs_addr_o,      // rs 位址
    output [4:0]  rt_addr_o,      // rt 位址
    output [4:0]  rd_addr_o,      // rd 位址

    // ===== BEQ  =====
    output        Branch_o, 
    output        Zero_o,              // rs == rt ?
    output [31:0] branch_target_o      // PC + 4 + (imm << 2)
);

wire [5:0] opcode  = instr_i[31:26];
wire [4:0] rs      = instr_i[25:21];
wire [4:0] rt      = instr_i[20:16];
wire [4:0] rd      = instr_i[15:11];
wire [5:0] funct   = instr_i[5:0];
wire [15:0] imm16  = instr_i[15:0];

// =====================================
// 控制單元（Decoder）
// =====================================
Decoder DEC(
    .instr_op_i(opcode),
    .RegWrite_o(RegWrite_o),
    .MemtoReg_o(MemtoReg_o),
    .MemRead_o(MemRead_o),
    .MemWrite_o(MemWrite_o),
    .ALUSrc_o(ALUSrc_o),
    .ALUOp_o(ALUOp_o),
    .Branch_o(Branch_o)  
);

// =====================================
// Register File（讀取 rs、rt）
// =====================================
Reg_File RF(
    .clk      (clk),
    .rst      (rst),

    .RSaddr_i   (rs),
    .RTaddr_i   (rt),

    // ===== 寫回階段的寫入 =====
    .RDaddr_i   (WB_WriteAddr_i),
    .RDdata_i   (WB_WriteData_i),
    .RegWrite_i (WB_RegWrite_i),

    // ===== 輸出 =====
    .RSdata_o   (rs_data_o),
    .RTdata_o   (rt_data_o)
);

// =====================================
// Sign Extend (branch address or immediate)
// =====================================
Sign_Extend SE(
    .data_i(imm16),
    .data_o(imm_o)
);

// =====================================
// Branch 判斷 (rs == rt ?)
// =====================================
assign Zero_o = (rs_data_o == rt_data_o);

// =====================================
// Branch Target Address
// PC + 4 + (imm << 2)
// =====================================
assign branch_target_o = pc_plus4_i + (imm_o << 2);

// =====================================
// 輸出位址資訊給 ID/EX
// =====================================
assign funct_o   = funct;
assign rs_addr_o = rs;
assign rt_addr_o = rt;
assign rd_addr_o = rd;

endmodule



