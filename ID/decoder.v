module Decoder(
    input  [5:0] instr_op_i,

    output reg       RegWrite_o,
    output reg       MemtoReg_o,         // WB (ALU(0) / Memory(1, lw))
    output reg       MemRead_o,
    output reg       MemWrite_o,
    output reg       ALUSrc_o,           // 決定 ALU 的第二個運算元來自哪裡 rt(0)/imm(1, address)
    output reg [1:0] ALUOp_o,            // 00(lw, sw, addi), 01(beq, 這邊不用了 branch改到ID stage), 10(R-type)
    output reg       Branch_o 
);

always @(*) begin
    // 預設值（避免 Latch）
    RegWrite_o = 0;
    MemtoReg_o = 0;             
    MemRead_o  = 0;
    MemWrite_o = 0;
    ALUSrc_o   = 0;
    ALUOp_o    = 2'b00;
    Branch_o   = 0;

    case (instr_op_i)

        6'b000000: begin
            // R-type
            RegWrite_o = 1;
            ALUSrc_o   = 0;
            ALUOp_o    = 2'b10;
        end

        6'b100011: begin
            // lw
            RegWrite_o = 1;
            MemtoReg_o = 1;
            MemRead_o  = 1;
            ALUSrc_o   = 1;
            ALUOp_o    = 2'b00;
        end

        6'b101011: begin
            // sw
            MemWrite_o = 1;
            ALUSrc_o   = 1;
            ALUOp_o    = 2'b00;
        end

        6'b001000: begin
            // addi
            RegWrite_o = 1;
            ALUSrc_o   = 1;
            ALUOp_o    = 2'b00;
        end

        6'b000100: begin   // beq
            Branch_o = 1;         
        end

        default: begin
            // 全部維持預設 0
        end
    endcase
end

endmodule
