module imm_gen(
    input [6 : 2] opcode,
    input [31 : 7] inst,
    output [31 : 0] imm
);


// 仅需opcode[4] + opcode[2] 即可判断U类型 即 opcode[4] & opcode[2]
// 仅需opcode[3] 即可区分J类型 即 opcode[3]
// I类型：00  0 + __001
// opcode[6] & ~opcode[2] 可区分B类型
// ~opcode[6] & opcode[5] & ~opcode[4] 可区分S

// 仅需opcode[5] & ~opcode[2] 即可判断S + B

// 还无法判断是否为关键路径

// 零级延迟
assign imm[31] = inst[31];

// 两级延迟
assign imm[10 : 5] = inst[30 : 25] & {6{~(opcode[4] & opcode[2])}}; // U-Type does not have imm[10 : 5] // {6~{~opcode[6] & opcode[4] & ~opcode[3] & opcode[2]}}， ~U

// 三级延迟，可以优化为两级延迟，需要增加16+16+8个晶体管
assign imm[4 : 1] = inst[11 : 8] & {4{opcode[5] & ~opcode[2]}} |                    // S + B
                    inst[24 : 21] & {4{opcode[3]}} |                                // J
                    inst[24 : 21] & {4{~opcode[6] & ~opcode[5] & ~opcode[2]}} |     // I
                    inst[24 : 21] & {4{~opcode[4] & ~opcode[3] & opcode[2]}};       // I

// 两级延迟
assign imm[0] = inst[20] & ~opcode[6] & ~opcode[5] & ~opcode[2]  |              // I
                inst[20] & ~opcode[4] & ~opcode[3] & opcode[2] |      // I
                inst[7] & ~opcode[6] & opcode[5] & ~opcode[4];       // S

// 三级延迟 --> 可优化成两级延迟
assign imm[30 : 20] = {11{inst[31] & ~(opcode[4] & opcode[2])}} | 
                      inst[30 : 20] & {11{opcode[4] & opcode[2]}}; // ~U | U

// 两级延迟（三级）
assign imm[19 : 12] = {8{inst[31] & opcode[5] & ~opcode[2]}} |                      // S + B
                      {8{inst[31] & ~opcode[6] & ~opcode[5] & ~opcode[2]}} |        // I
                      {8{inst[31] & ~opcode[4] & ~opcode[3] & opcode[2]}} |         // I
                      inst[19 : 12] & {8{opcode[4] & opcode[2]}} |                  // U
                      inst[19 : 12] & {8{opcode[3]}};                               // J
// 一级延迟
assign imm[11] = inst[31] & ~opcode[6] & opcode[5] & ~opcode[4] | 
                 inst[31] & ~opcode[6] & ~opcode[5] & ~opcode[2] |
                 inst[31] & ~opcode[4] & ~opcode[3] & opcode[2] |
                 inst[7] & opcode[6] & ~opcode[2] |
                 inst[20] & opcode[3];


endmodule
