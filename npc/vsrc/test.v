module test (
    input [6 : 0]opcode,
    input [2 : 0] func3,
    input zero_flag,
    input alu_result,
    output pcAdderBSel
);

wire [2 : 0] branch_way;

assign branchWay[0] = opcode[6] & ~opcode[4] & ~opcode[2] & func3[0];
assign branchWay[1] = opcode[6] & ~opcode[4] & ~opcode[2];
assign branchWay[2] = opcode[6] & ~opcode[4] & ~opcode[2] & func3[2];

// pcAdderBSel三级延迟，整个控制信号产生阶段需要四级延迟
wire pcAdderBSel = opcode[6] & opcode[2] |        // jump指令
                     ~branchWay[2] & branchWay[1] & ~branchWay[0] & zero_flag |
                     ~branchWay[2] & branchWay[1] & branchWay[0] & ~zero_flag |
                     branchWay[2] & branchWay[1] & ~branchWay[0] & alu_result |
                     branchWay[2] & branchWay[1] & branchWay[0] & ~alu_result;



endmodule

