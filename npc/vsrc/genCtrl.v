module genCtrl(
    input [4 : 0] opcode6_2,
    input [2 : 0] funct3,
    input funct7_5,
    output [2 : 0] extOP,
    output readMemEnable,
    output writeMemEnable,
    output rdEnable,
    output [2 : 0] memOP,
    output [2 : 0] branchOP,
    output [3 : 0] ALUCtrl,
    output ALUASel,
    output [1 : 0] ALUBSel
);

// extOP
assign extOP[0] = opcode6_2[0] & ~opcode6_2[1] & opcode6_2[2] & ~opcode6_2[4] | ~opcode6_2[0] & ~opcode6_2[1] & ~opcode6_2[2] & opcode6_2[3] & opcode6_2[4];   // u + b
assign extOP[1] = ~opcode6_2[0] & ~opcode6_2[1] & ~opcode6_2[2] & opcode6_2[3];         // s+b
assign extOP[2] = opcode6_2[0] & opcode6_2[1] & ~opcode6_2[2] & opcode6_2[3] & opcode6_2[4];    // j

// readMemEnable    0: reg(rd) = ALUResult  1: reg(rd) = memData    //l指令
assign readMemEnable = ~opcode6_2[4] & ~opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0];

// writeMemEnable   0: disable  1: enable       // s指令
assign writeMemEnable = ~opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0];

// rdEnable     0: disable  1: enable       // 把0当作使能信号还可以干掉一个非门    // 除了S和B指令
assign rdEnable = ~(~opcode6_2[0] & ~opcode6_2[1] & ~opcode6_2[2] & opcode6_2[3]);  // ~extOP[1]

// 实际上只需要两位就可以控制ALUA和ALUB的输入，00选rs1 + imm， 01选rs1 + rs2， 10选pc + imm， 11选pc + 4， 高位用于选择rs1/pc，两位用来选择imm、rs2、4
// ALUASel      0: rs1, 1: pc       // jump + auipc
assign ALUASel = ~opcode6_2[4] & ~opcode6_2[3] & opcode6_2[2] & ~opcode6_2[1] & opcode6_2[0] | opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & opcode6_2[0];

// ALUBSel  00: imm  01: rs2  11: 4         ALUBSel[1] = ALUASel

assign ALUBSel[0] = opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & opcode6_2[0];     // Jump指令
assign ALUBSel[1] = ALUASel;

// memOP
assign memOP = funct3;

// branchOP
assign branchOP[0] = (opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & opcode6_2[1] & opcode6_2[0]) | 
                     (opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0] & funct3[0]);

assign branchOP[1] = (opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & opcode6_2[0]) |
                     (opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0] & funct3[2]);

assign branchOP[2] = opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0];


// ALUCtrl
// 一级与门的整体是可以复用的（用来参与二级或运算），但是一级与门的部分是不可以复用的，否则会带来一级门电路的延迟
assign ALUCtrl[0] = ~opcode6_2[4] & opcode6_2[3] & opcode6_2[2] & ~opcode6_2[1] & opcode6_2[0] |
                    ~opcode6_2[4] & ~opcode6_2[3] & opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0] & funct3[0];

assign ALUCtrl[1] = ~opcode6_2[4] & opcode6_2[3] & opcode6_2[2] & ~opcode6_2[1] & opcode6_2[0] | 
                    ~opcode6_2[4] & opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0] & funct3[1] | 
                    opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0];

assign ALUCtrl[2] = ~opcode6_2[4] & opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0] & funct3[2];

assign ALUCtrl[3] = ~opcode6_2[4] & opcode6_2[3] & opcode6_2[2] & ~opcode6_2[1] & opcode6_2[0] | 
                    ~opcode6_2[4] & opcode6_2[3] & opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0] & funct7_5 | 
                    opcode6_2[4] & opcode6_2[3] & ~opcode6_2[2] & ~opcode6_2[1] & ~opcode6_2[0] & funct3[2] & funct3[1];

endmodule
