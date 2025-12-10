// =====================================
// EX Stage (Execute)
// 負責：
//   1. 決定 ALU 控制碼（由 ALUOp + funct）
//   2. ALU 運算
//   3. ALUSrc MUX（rt vs immediate）
//   4. RegDst MUX（rd vs rt）
//   5. 結果送到 EX/MEM pipeline register
// =====================================

module EX(

    // ===== 基本控制 =====
    input         RegWrite_i,
    input         MemtoReg_i,
    input         MemRead_i,
    input         MemWrite_i,
    input  [1:0]  ALUOp_i,
    input         ALUSrc_i,             // rt(0)/imm(1)

    // ===== 來自 ID/EX pipeline =====
    input  [31:0] rs_data_i,
    input  [31:0] rt_data_i,
    input  [31:0] imm_i,
    input  [5:0]  funct_i,

    input  [4:0]  rs_addr_i,
    input  [4:0]  rt_addr_i,
    input  [4:0]  rd_addr_i,

    // ===== Forwarding data =====
    input  [31:0] EXMEM_ALU_i,          // from EX/MEM
    input  [31:0] MEMWB_WriteData_i,    // from MEM/WB

    // ===== Forwarding control =====
    input  [1:0]  ForwardA_i,
    input  [1:0]  ForwardB_i,

    // ===== 輸出到 EX/MEM pipeline =====
    output        RegWrite_o,
    output        MemtoReg_o,
    output        MemRead_o,
    output        MemWrite_o,

    output [4:0]  rs_addr_o,            // to Forwarding Unit
    output [4:0]  rt_addr_o,            // to Forwarding + Hazard Detection
    output [31:0] ALU_result_o,
    output [31:0] rt_data_o,            // sw 使用的原始 rt value
    output [4:0]  dest_reg_o            // 寫回暫存器編號(rd or rt)
);

assign rs_addr_o = rs_addr_i;           // 給 forwarding unit
assign rt_addr_o = rt_addr_i;           // 給 forwarding + hazard detection unit

// =====================================
// 1. Forwarding MUX for operand A
// =====================================
reg [31:0] ALU_src1;

always @(*) begin
    case (ForwardA_i)
        2'b00: ALU_src1 = rs_data_i;          // no forwarding
        2'b10: ALU_src1 = EXMEM_ALU_i;        // EX → EX
        2'b01: ALU_src1 = MEMWB_WriteData_i;  // WB → EX
        default: ALU_src1 = rs_data_i;
    endcase
end

// =====================================
// 2. Forwarding MUX for operand B
// =====================================
reg [31:0] rt_forwarded;

always @(*) begin
    case (ForwardB_i)
        2'b00: rt_forwarded = rt_data_i;     // normal
        2'b10: rt_forwarded = EXMEM_ALU_i;                 // EX/MEM forwarding
        2'b01: rt_forwarded = MEMWB_WriteData_i;           // MEM/WB forwarding
        default: rt_forwarded = rt_data_i;
    endcase
end

// =====================================
// 3. ALUSrc MUX（先決定用 rt 還是 imm）
// =====================================
wire [31:0] ALU_src2 = ALUSrc_i ? imm_i : rt_forwarded;

// =====================================
// 4. ALU Control
// =====================================
reg [3:0] ALU_control;

always @(*) begin
    case (ALUOp_i)
        2'b00: ALU_control = 4'b0010;  // add (lw/sw/addi)
        2'b10: begin                   // R-type
            case (funct_i)
                6'b100000: ALU_control = 4'b0010; // add
                6'b100010: ALU_control = 4'b0110; // sub
                6'b100100: ALU_control = 4'b0000; // and
                6'b100101: ALU_control = 4'b0001; // or
                6'b101010: ALU_control = 4'b0111; // slt
                default:   ALU_control = 4'b0010;
            endcase
        end
        default: ALU_control = 4'b0010;
    endcase
end

// =====================================
// 5. ALU
// =====================================
wire [31:0] ALU_result;

ALU alu(
    .src1(ALU_src1),
    .src2(ALU_src2),
    .ALU_control(ALU_control),
    .result(ALU_result)
);

// =====================================
// 6. RegDst MUX
// =====================================
wire [4:0] dest_reg = (ALUOp_i == 2'b10) ? rd_addr_i : rt_addr_i;

// =====================================
// 7. 輸出到 EX/MEM pipeline
// =====================================
assign RegWrite_o    = RegWrite_i;
assign MemtoReg_o    = MemtoReg_i;
assign MemRead_o     = MemRead_i;
assign MemWrite_o    = MemWrite_i;

assign ALU_result_o  = ALU_result;
assign rt_data_o     = rt_forwarded;     // sw 使用原始 RT（不 forward、不 ALUSrc）
assign dest_reg_o    = dest_reg;

endmodule