// =====================================
// IF Stage (Instruction Fetch)
// 負責：
//   1. 取得 PC
//   2. 從指令記憶體取出 instr
//   3. 計算 PC + 4
//   4. 輸出給 IF/ID pipeline register
// =====================================

module IF(
    input         clk,
    input         rst,
    input         PC_Write,        // hazard unit：0 = stall 不更新 PC

    // ===== 來自 ID stage 的 branch 判斷 =====
    input         Branch_i,            // beq 指令？
    input         Zero_i,              // rs == rt ?
    input  [31:0] branch_target_i,     // branch target address

    output [31:0] instr_o,         // 從 IMEM 取出的指令
    output [31:0] pc_plus4_o,       // PC + 4 給 IF/ID


    output branch_taken_o
);


reg  [31:0] pc_reg;

// =====================================
// Branch 決策（PC 選擇器）
// branch_taken = Branch AND Zero
// =====================================
wire branch_taken = Branch_i & Zero_i;
assign branch_taken_o = branch_taken;

wire [31:0] pc_next = (branch_taken) ?
                      branch_target_i :   // branch 命中 → 跳到目標
                      pc_reg + 32'd4;     // otherwise → PC + 4

// ===============================
// Program Counter (內建於本模組)
// ===============================
always @(posedge clk or posedge rst) begin
    if (rst)
        pc_reg <= 32'b0;
    else if (PC_Write)
        pc_reg <= pc_next;   // 正常更新 PC
    // else: PC_Write = 0 → stall → PC 不變
end

// ===============================
// Instruction Memory
// ===============================
Instr_Memory IMEM(
    .addr_i(pc_reg),
    .instr_o(instr_o)
);

// ===============================
// PC + 4 加法器
// ===============================
assign pc_plus4_o = pc_reg + 32'd4;

endmodule
