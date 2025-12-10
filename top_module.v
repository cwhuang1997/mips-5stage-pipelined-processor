// ============================================================================
//                      5-stage Pipelined MIPS CPU (Top Module)
// IF → ID → EX → MEM → WB
// Hazard Unit：處理 load-use hazard（stall + bubble）
// Forwarding Unit：處理 EX/MEM 與 MEM/WB 的 data hazard
// Branch：於 ID 階段解決
// ============================================================================


module CPU(
    input clk,
    input rst
);

// ============================================================================
// Missing wire declarations (add these)
// ============================================================================

// WB stage
wire [4:0]  WB_WriteAddr;
wire [31:0] WB_WriteData;

// EX stage pass-through
wire        EX_RegWrite_pass;
wire        EX_MemtoReg_pass;
wire        EX_MemRead_pass;
wire        EX_MemWrite_pass;
wire [4:0]  EX_rs_addr_pass;
wire [4:0]  EX_rt_addr_pass;

// MEM stage pass-through
wire        MEM_RegWrite_pass;
wire        MEM_MemtoReg_pass;
wire [31:0] MEM_ALU_result_pass;
wire [4:0]  MEM_WriteAddr_pass;
/////////////////////////////////////////////////////////////////////

// ============================================================================
// IF Stage
// ============================================================================
wire [31:0] IF_instr;
wire [31:0] IF_pc_plus4;

wire        PC_Write;
wire        Branch;
wire        Zero;
wire [31:0] branch_target;

// IF Stage
IF IF_stage(
    .clk(clk),
    .rst(rst),
    .PC_Write(PC_Write),
    .Branch_i(Branch),
    .Zero_i(Zero),
    .branch_target_i(branch_target),
    .instr_o(IF_instr),
    .pc_plus4_o(IF_pc_plus4)
);

// ============================================================================
// IF/ID Pipeline Register
// ============================================================================
wire [31:0] ID_instr;
wire [31:0] ID_pc_plus4;
wire        IF_ID_Write;

IF_ID IF_ID_reg(
    .clk(clk),
    .rst(rst),
    .IF_ID_Write(IF_ID_Write),
    .instr_i(IF_instr),
    .pc_i(IF_pc_plus4),
    .instr_o(ID_instr),
    .pc_o(ID_pc_plus4)
);

// ============================================================================
// ID Stage
// ============================================================================
wire        ID_RegWrite;
wire        ID_MemtoReg;
wire        ID_MemRead;
wire        ID_MemWrite;
wire [1:0]  ID_ALUOp;
wire        ID_ALUSrc;

wire [31:0] ID_rs_data;
wire [31:0] ID_rt_data;
wire [31:0] ID_imm;
wire [5:0]  ID_funct;

wire [4:0]  ID_rs_addr;
wire [4:0]  ID_rt_addr;
wire [4:0]  ID_rd_addr;

ID ID_stage(
    .clk(clk),
    .rst(rst),
    .instr_i(ID_instr),
    .pc_plus4_i(ID_pc_plus4),

    .WB_RegWrite_i(WB_RegWrite),
    .WB_WriteAddr_i(WB_WriteAddr),
    .WB_WriteData_i(WB_WriteData),

    .RegWrite_o(ID_RegWrite),
    .MemtoReg_o(ID_MemtoReg),
    .MemRead_o(ID_MemRead),
    .MemWrite_o(ID_MemWrite),
    .ALUOp_o(ID_ALUOp),
    .ALUSrc_o(ID_ALUSrc),

    .rs_data_o(ID_rs_data),
    .rt_data_o(ID_rt_data),
    .imm_o(ID_imm),
    .funct_o(ID_funct),

    .rs_addr_o(ID_rs_addr),
    .rt_addr_o(ID_rt_addr),
    .rd_addr_o(ID_rd_addr),

    .Branch_o(Branch),
    .Zero_o(Zero),
    .branch_target_o(branch_target)
);

// ============================================================================
// Hazard Detection Unit
// ============================================================================
wire ID_EX_Flush;

Hazard_Detection_Unit hazard(
    .ID_EX_MemRead(EX_MemRead),
    .ID_EX_rt(EX_rt_addr),

    .IF_ID_rs(ID_rs_addr),
    .IF_ID_rt(ID_rt_addr),

    .PC_Write(PC_Write),
    .IF_ID_Write(IF_ID_Write),
    .ID_EX_Flush(ID_EX_Flush)
);

// ============================================================================
// ID/EX Pipeline Register
// ============================================================================
wire        EX_RegWrite;
wire        EX_MemtoReg;
wire        EX_MemRead;
wire        EX_MemWrite;
wire [1:0]  EX_ALUOp;
wire        EX_ALUSrc;

wire [31:0] EX_rs_data;
wire [31:0] EX_rt_data;
wire [31:0] EX_imm;
wire [5:0]  EX_funct;

wire [4:0]  EX_rs_addr;
wire [4:0]  EX_rt_addr;
wire [4:0]  EX_rd_addr;

ID_EX ID_EX_reg(
    .clk(clk),
    .rst(rst),
    .ID_EX_Flush(ID_EX_Flush),

    .RegWrite_i(ID_RegWrite),
    .MemtoReg_i(ID_MemtoReg),
    .MemRead_i(ID_MemRead),
    .MemWrite_i(ID_MemWrite),
    .ALUOp_i(ID_ALUOp),
    .ALUSrc_i(ID_ALUSrc),

    .rs_i(ID_rs_data),
    .rt_i(ID_rt_data),
    .imm_i(ID_imm),
    .funct_i(ID_funct),

    .rs_addr_i(ID_rs_addr),
    .rt_addr_i(ID_rt_addr),
    .rd_addr_i(ID_rd_addr),

    .RegWrite_o(EX_RegWrite),
    .MemtoReg_o(EX_MemtoReg),
    .MemRead_o(EX_MemRead),
    .MemWrite_o(EX_MemWrite),
    .ALUOp_o(EX_ALUOp),
    .ALUSrc_o(EX_ALUSrc),

    .rs_o(EX_rs_data),
    .rt_o(EX_rt_data),
    .imm_o(EX_imm),
    .funct_o(EX_funct),

    .rs_addr_o(EX_rs_addr),
    .rt_addr_o(EX_rt_addr),
    .rd_addr_o(EX_rd_addr)
);

// ============================================================================
// Forwarding Unit
// ============================================================================
wire [1:0] ForwardA;
wire [1:0] ForwardB;

Forwarding_Unit forward(
    .ID_EX_rs(EX_rs_addr),
    .ID_EX_rt(EX_rt_addr),

    .EX_MEM_RegWrite(MEM_RegWrite),
    .EX_MEM_rd(MEM_WriteAddr),

    .MEM_WB_RegWrite(WB_RegWrite),
    .MEM_WB_rd(WB_WriteAddr),

    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

// ============================================================================
// EX Stage
// ============================================================================
wire [31:0] EX_ALU_result;
wire [31:0] EX_rt_forwarded;
wire [4:0]  EX_dest_reg;

EX EX_stage(
    .RegWrite_i(EX_RegWrite),
    .MemtoReg_i(EX_MemtoReg),
    .MemRead_i(EX_MemRead),
    .MemWrite_i(EX_MemWrite),
    .ALUOp_i(EX_ALUOp),
    .ALUSrc_i(EX_ALUSrc),

    .rs_data_i(EX_rs_data),
    .rt_data_i(EX_rt_data),
    .imm_i(EX_imm),
    .funct_i(EX_funct),

    .rs_addr_i(EX_rs_addr),
    .rt_addr_i(EX_rt_addr),
    .rd_addr_i(EX_rd_addr),

    .EXMEM_ALU_i(MEM_ALU_result),
    .MEMWB_WriteData_i(WB_WriteData),

    .ForwardA_i(ForwardA),
    .ForwardB_i(ForwardB),

    .RegWrite_o(EX_RegWrite_pass),
    .MemtoReg_o(EX_MemtoReg_pass),
    .MemRead_o(EX_MemRead_pass),
    .MemWrite_o(EX_MemWrite_pass),

    .rs_addr_o(EX_rs_addr_pass),
    .rt_addr_o(EX_rt_addr_pass),

    .ALU_result_o(EX_ALU_result),
    .rt_data_o(EX_rt_forwarded),
    .dest_reg_o(EX_dest_reg)
);

// ============================================================================
// EX/MEM Pipeline Register
// ============================================================================
wire        MEM_RegWrite;
wire        MEM_MemtoReg;
wire        MEM_MemRead;
wire        MEM_MemWrite;

wire [31:0] MEM_ALU_result;
wire [31:0] MEM_rt_data;
wire [4:0]  MEM_WriteAddr;

EX_MEM EX_MEM_reg(
    .clk(clk),
    .rst(rst),

    .RegWrite_i(EX_RegWrite_pass),
    .MemtoReg_i(EX_MemtoReg_pass),
    .MemRead_i(EX_MemRead_pass),
    .MemWrite_i(EX_MemWrite_pass),

    .ALU_i(EX_ALU_result),
    .rt_i(EX_rt_forwarded),
    .rd_i(EX_dest_reg),

    .RegWrite_o(MEM_RegWrite),
    .MemtoReg_o(MEM_MemtoReg),
    .MemRead_o(MEM_MemRead),
    .MemWrite_o(MEM_MemWrite),

    .ALU_o(MEM_ALU_result),
    .rt_o(MEM_rt_data),
    .rd_o(MEM_WriteAddr)
);

// ============================================================================
// MEM Stage
// ============================================================================
wire [31:0] MEM_ReadData;

MEM MEM_stage(
    .clk(clk),
    .rst(rst),

    .RegWrite_i(MEM_RegWrite),
    .MemtoReg_i(MEM_MemtoReg),
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),

    .ALU_result_i(MEM_ALU_result),
    .rt_data_i(MEM_rt_data),
    .dest_reg_i(MEM_WriteAddr),

    .RegWrite_o(MEM_RegWrite_pass),
    .MemtoReg_o(MEM_MemtoReg_pass),
    .read_data_o(MEM_ReadData),
    .ALU_result_o(MEM_ALU_result_pass),
    .dest_reg_o(MEM_WriteAddr_pass)
);

// ============================================================================
// MEM/WB Pipeline Register
// ============================================================================
wire        WB_RegWrite;
wire        WB_MemtoReg;
wire [31:0] WB_ReadData;
wire [31:0] WB_ALU_result;

MEM_WB MEM_WB_reg(
    .clk(clk),
    .rst(rst),

    .RegWrite_i(MEM_RegWrite_pass),
    .MemtoReg_i(MEM_MemtoReg_pass),
    .read_data_i(MEM_ReadData),
    .ALU_i(MEM_ALU_result_pass),
    .rd_i(MEM_WriteAddr_pass),

    .RegWrite_o(WB_RegWrite),
    .MemtoReg_o(WB_MemtoReg),
    .read_data_o(WB_ReadData),
    .ALU_o(WB_ALU_result),
    .rd_o(WB_WriteAddr)
);

// ============================================================================
// WB Stage
// ============================================================================
wire        WB_RegWrite_sig;
wire [4:0]  WB_WriteAddr_sig;


WB WB_stage(
    .RegWrite_i(WB_RegWrite),
    .MemtoReg_i(WB_MemtoReg),
    .read_data_i(WB_ReadData),
    .ALU_result_i(WB_ALU_result),
    .dest_reg_i(WB_WriteAddr),

    .WB_RegWrite_o(WB_RegWrite_sig),     
    .WB_WriteAddr_o(WB_WriteAddr_sig),  
    .WB_WriteData_o(WB_WriteData)
);

endmodule


/*

iverilog -o cpu_tb testbench.v top_module.v ./IF/IF.v ./IF/IF_ID.v ./IF/instruction_memory.v ./ID/ID.v ./ID/decoder.v ./ID/ID_EX.v ./ID/reg_file.v ./ID/sign_extend.v ./EX/EX.v ./EX/ALU.v ./EX/EX_MEM.v ./MEM/MEM.v ./MEM/data_memory.v ./MEM/MEM_WB.v ./WB/WB.v ./common/forwarding_unit.v ./common/hazard_detection_unit.v

vvp cpu_tb

gtkwave cpu.vcd

*/