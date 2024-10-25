module ctrl_gen(
    input [6 : 2] opcode,
    input [2 : 0] func3,
    input func7,
    output aluASel,
    output aluBSel,
    output aluOP
);

assign aluOP = ~opcode[6] & opcode[5] & opcode[2];
assign aluASel = opcode[2];
assign aluBSel = opcode[6] & opcode[2];


endmodule
