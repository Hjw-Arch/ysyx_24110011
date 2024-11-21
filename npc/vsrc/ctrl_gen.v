module ctrl_gen(
    input [6 : 2] opcode,
    input [2 : 0] func3,
    input func7,
    input inst_21,
    output aluASel,
    output aluBSel,
    output pcAdderASel,
    output [1 : 0] pcSel,
    output CSRWriteEnable,
    output CSRSel,
    output is_ecall,
    output rdWriteEnable,
    output memWriteEnable,
    output [1 : 0] rdInputSel,
    output [3 : 0] aluOP,
    output [2 : 0] memOP,
    output [2 : 0] branchWay
);


wire is_sys = opcode[6] & opcode[4] & ~(|func3[1 : 0]);     // 添加更多指令需要改变
// 最高三级延迟，为aluOP[0], 其他均为两级延迟
// 加入CSR控制信号后有四级延迟（有一级是非门）

assign aluASel = opcode[2];     // U + J
assign aluBSel = ~opcode[6] & ~opcode[4] | ~opcode[5] & opcode[4] | opcode[4] & ~opcode[3] & opcode[2];     // imm

assign rdWriteEnable = ~(opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2]);     // ~(B + S)

assign memWriteEnable = ~opcode[6] & opcode[5] & ~opcode[4];        // S

assign rdInputSel[0] = ~opcode[5] & ~opcode[4];        // L
assign rdInputSel[1] = opcode[6] & opcode[4];       // CSR

assign aluOP[0] = ~opcode[5] & opcode[4] & ~opcode[2] & func3[2] & ~func3[1] & func3[0] & func7 |             // srai
                   opcode[5] & opcode[4] & func7 |          // R
                   opcode[5] & opcode[4] & opcode[2];   //  lui

assign aluOP[1] = opcode[4] & ~opcode[2] & func3[0] |      // compute i + compute R
                  opcode[6] & ~opcode[2] & func3[1];    // Bu

assign aluOP[2] = opcode[4] & ~opcode[2] & func3[1] |       // compute i + compute R
                  opcode[6] & ~opcode[2];     // B

assign aluOP[3] = opcode[4] & ~opcode[2] & func3[2] |        // compute i + compute R
                  opcode[5] & opcode[4] & opcode[2];        // lui

assign memOP = func3;


assign branchWay[0] = opcode[6] & ~opcode[2] & func3[0];
assign branchWay[1] = opcode[6] & ~opcode[2];
assign branchWay[2] = opcode[6] & ~opcode[2] & func3[2];

// pcAdderBSel 需要根据alu计算结果判断
assign pcAdderASel = opcode[6] & ~opcode[3] & opcode[2];        // jalr

assign pcSel[0] = is_sys;
assign pcSel[1] = is_sys & inst_21;

assign CSRWriteEnable = opcode[6] & opcode[4] & |func3[1 : 0];  // Zicsr    // 仅仅在只有csrrw和csrrs的情况下
assign CSRSel = opcode[6] & opcode[4] & func3[1];       // csrrs    仅仅在只有csrrw和csrrs的情况下
assign is_ecall = is_sys & ~inst_21;    // 仅仅在只有ecall和mret下有效果

endmodule
