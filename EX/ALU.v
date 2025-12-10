// =====================================
// ALU
// 支援：AND, OR, ADD, SUB, SLT
// =====================================

module ALU(
    input  [31:0] src1,
    input  [31:0] src2,
    input  [3:0]  ALU_control,
    output reg [31:0] result
);


always @(*) begin
    case (ALU_control)

        4'b0000: result = src1 & src2;       // AND
        4'b0001: result = src1 | src2;       // OR
        4'b0010: result = src1 + src2;       // ADD
        4'b0110: result = src1 - src2;       // SUB
        4'b0111: result = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0;  // SLT

        default: result = 32'hDEAD_BEEF;     // debug 用，正常情況不會出現
    endcase
end

endmodule
