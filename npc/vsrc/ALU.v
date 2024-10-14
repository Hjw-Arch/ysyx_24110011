// ALU实现
module ALU #(parameter WIDTH = 32) (
    input [3 : 0] ctrl,
    input [WIDTH - 1 : 0] input1,
    input [WIDTH - 1 : 0] input2,
    output [WIDTH - 1 : 0] result,
    // output [WIDTH - 1 : 0] computeResult,
    output carry_flag, zero_flag, overflow_flag
);

// 加法 0000 减法 1000
wire [WIDTH - 1 : 0] computeResult;

addsuber #(WIDTH) _addsuber(
    .input1(input1),
    .input2(input2),
    .add_or_sub(ctrl[3] | ctrl[1]),     // sub slt stlu slti sltiu需要作减法
    .result(computeResult),
    .carry_flag(carry_flag),
    .overflow_flag(overflow_flag)
);

// 移位操作
wire [WIDTH - 1 : 0] shifterResult;

barrel_shifter #(WIDTH) _shifter(
    .data(input1),
    .la(ctrl[3]),
    .lr(ctrl[2]),
    .shift_number(input2[$clog2(WIDTH) - 1 : 0]),
    .result(shifterResult)
);

// 与、或、异或
wire [WIDTH - 1 : 0] andResult = input1 & input2;
wire [WIDTH - 1 : 0] orResult = input1 | input2;
wire [WIDTH - 1 : 0] xorResult = input1 ^ input2;

// 比较大小
// 有符号数和无符号数 这种方式多了一层延时，分开写再选择输出会少一层延时
// wire lessSignedResult = computeResult[WIDTH - 1] ^ (overflow_flag & ~ctrl[3]);

wire [WIDTH - 1 : 0] lessSignedResult = {31'b0, computeResult[WIDTH - 1] ^ overflow_flag};
wire [WIDTH - 1 : 0] lessUnsignedResult = {31'b0, computeResult[WIDTH - 1]};

// 拷贝立即数
wire [WIDTH - 1 : 0] copyResult = input2;

ALUMux11_1 #(WIDTH) muxForResult(
    .inData({lessUnsignedResult, andResult, orResult, xorResult, copyResult, lessSignedResult, shifterResult, computeResult}),
    .sel(ctrl),
    .result(result)
);

assign zero_flag = |result;


endmodule
