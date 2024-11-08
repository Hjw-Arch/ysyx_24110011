module alu #(parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] inputA,
    input [BITWIDTH - 1 : 0] inputB,
    input [3 : 0] aluOP,
    output [BITWIDTH - 1 : 0] result,
    output zero_flag
);
// only support addition operation now
// addition

wire unusedSigned_cout;
wire [BITWIDTH - 1 : 0] computeResult;
wire carry_flag, overflow_flag;
addsuber #(BITWIDTH) _addsuber(
    .input1(inputA),
    .input2(inputB),
    .add_or_sub(aluOP[0] | aluOP[2]),     // sub slt... need sub operation
    .result(computeResult),
    .carry_flag(carry_flag),
    .overflow_flag(overflow_flag),
    .zero_flag(zero_flag)
);

// 移位操作
wire [BITWIDTH - 1 : 0] shifterResult;

barrel_shifter #(BITWIDTH) _shifter(
    .data(inputA),
    .la(aluOP[0]),
    .lr(aluOP[3]),
    .shift_number(inputB[$clog2(BITWIDTH) - 1 : 0]),
    .result(shifterResult)
);

// 与、或、异或
wire [BITWIDTH - 1 : 0] andResult = inputA & inputB;
wire [BITWIDTH - 1 : 0] orResult = inputA | inputB;
wire [BITWIDTH - 1 : 0] xorResult = inputA ^ inputB;

// less
wire [BITWIDTH - 1 : 0] lessSignedResult = {31'b0, (computeResult[BITWIDTH - 1] ^ overflow_flag)};
wire [BITWIDTH - 1 : 0] lessUnsignedResult = {31'b0, carry_flag};

// 拷贝立即数
wire [BITWIDTH - 1 : 0] copyResult = inputB;

assign result = {BITWIDTH{~aluOP[3] & ~aluOP[2] & ~aluOP[1]}} & computeResult | 
                {BITWIDTH{~aluOP[2] & aluOP[1]}} & shifterResult |
                {BITWIDTH{~aluOP[3] & aluOP[2] & ~aluOP[1]}} & lessSignedResult |
                {BITWIDTH{~aluOP[3] & aluOP[2] & aluOP[1]}} & lessUnsignedResult |
                {BITWIDTH{aluOP[3] & ~aluOP[2] & ~aluOP[1] & ~aluOP[0]}} & xorResult |
                {BITWIDTH{aluOP[3] & aluOP[2] & ~aluOP[1] & ~aluOP[0]}} & orResult |
                {BITWIDTH{aluOP[3] & aluOP[2] & aluOP[1] & ~aluOP[0]}} & andResult |
                {BITWIDTH{aluOP[3] & ~aluOP[2] & ~aluOP[1] & aluOP[0]}} & copyResult;

endmodule
