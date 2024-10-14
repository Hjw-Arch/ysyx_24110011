// 实际上是一个32位五选一数据选择器
module genImm(
    input [31 : 7] immToGen,
    input [2 : 0] extOP,
    output [31 : 0] imm
);

// 比直接判断少5个与门，一个或门
assign imm[31] = immToGen[31];

wire [30 : 0] imm_I = {{19{immToGen[31]}}, immToGen[31 : 20]};
wire [30 : 0] imm_S = {{19{immToGen[31]}}, immToGen[31 : 25], immToGen[11 : 7]};
wire [30 : 0] imm_B = {{19{immToGen[31]}}, immToGen[7], immToGen[30 : 25], immToGen[11 : 8], 1'b0};

wire [30 : 0] imm_U = {immToGen[30 : 12], 12'b0};
wire [30 : 0] imm_J = {{11{immToGen[31]}}, immToGen[19 : 12], immToGen[20], immToGen[30 : 21], 1'b0};

assign imm[30 : 0] = ({31{extOP[2]}} & imm_S) | 
             ({31{~extOP[2] & ~extOP[1] & ~extOP[0]}} & imm_I) | 
             ({31{~extOP[2] & ~extOP[1] & extOP[0]}} & imm_U) | 
             ({31{~extOP[2] & extOP[1] & ~extOP[0]}} & imm_B) | 
             ({31{~extOP[2] & extOP[1] & extOP[0]}} & imm_J);

endmodule
