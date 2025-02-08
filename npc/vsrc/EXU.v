module EXU #(parameter WIDTH = 32) (
    input [3 : 0] alu_op,
    input [WIDTH - 1 : 0] rs1,
    input [WIDTH - 1 : 0] pc,
    input [WIDTH - 1 : 0] imm,
    input [WIDTH - 1 : 0] rs2,
    input alu_sel_left,
    input [1 : 0] alu_sel_right,

    output [WIDTH - 1 : 0] result,
    output zero_flag
);

// 判断需要的数据
wire [WIDTH - 1 : 0] left_data = alu_sel_left ? pc : rs1;
wire [WIDTH - 1 : 0] right_data = alu_sel_right == 2'b00 ? rs2 : 
                                  alu_sel_right == 2'b10 ? {{(WIDTH - 3){1'b0}}, 3'b100} : 
                                  imm;

ALU #(WIDTH) alu (
    .alu_op(alu_op),
    .left_data(left_data),
    .right_data(right_data),
    .result(result),
    .zero_flag(zero_flag)
);






endmodule
