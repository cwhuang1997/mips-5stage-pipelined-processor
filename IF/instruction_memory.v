module Instr_Memory(
    input  [31:0] addr_i,
    output [31:0] instr_o
);

reg [31:0] memory [0:255];  // 256 words (each 32-bit), 共 1 KB 指令記憶體

// ----------------------
// 從檔案載入指令
// ----------------------
initial begin
    // 將 instruction.txt 的每一行 HEX 依序載入到 memory[0], memory[1], ...
    // 第 0 行 → memory[0]
    // 第 1 行 → memory[1]
    // 第 N 行 → memory[N]
    $readmemb("instruction.txt", memory);
end

// ----------------------
// 指令讀取（使用 word addressing）
// ----------------------
assign instr_o = memory[addr_i[31:2]];  
// 因為 MIPS 指令是 4 bytes(32-bit)，PC 每次增加 4。
// addr_i[31:2] 等於把 byte address 右移 2，轉成 word index。
// PC = 0 → index=0
// PC = 4 → index=1
// PC = 8 → index=2

endmodule