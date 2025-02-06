module ALU #(parameter WIDTH = 32) (        // 需要狠狠优化
    input [3 : 0] alu_op,
    input [WIDTH - 1 : 0] left_data,
    input [WIDTH - 1 : 0] right_data,

    output [WIDTH - 1 : 0] result,
    output zero_flag
);

// 加减法器
wire cin = alu_op[2] | alu_op[0];
wire [WIDTH - 1 : 0] addsub_result;
wire cout;
adder32 addsub(
    .a(left_data),
    .b(right_data ^ {WIDTH{cin}}),
    .cin(cin),
    .result(addsub_result),
    .cout(cout)
);

// assign {cout, addsub_result} = left_data + (right_data ^ {WIDTH{cin}}) + cin;    // 另一种方法

// 移位, 这么写可能带来巨大的面积开销，可以手写桶形移位器来解决
wire [WIDTH - 1 : 0] left_logic_shifter = left_data << right_data[$clog2(WIDTH) - 1 : 0];
wire [WIDTH - 1 : 0] right_logic_shifter = left_data >> right_data[$clog2(WIDTH) - 1 : 0];
wire [WIDTH - 1 : 0] right_arithmetic_shifter = left_data >>> right_data[$clog2(WIDTH) - 1 : 0];

// 与 或 异或
wire [WIDTH - 1 : 0] and_result = left_data & right_data;
wire [WIDTH - 1 : 0] or_result = left_data | right_data;
wire [WIDTH - 1 : 0] xor_result = left_data ^ right_data;

// 比较大小
wire real_symbol = right_data[WIDTH - 1] ^ cin;
wire overflow_flag = (left_data[WIDTH - 1] & real_symbol & ~addsub_result[WIDTH - 1]) | 
                     (~left_data[WIDTH - 1] & ~real_symbol & addsub_result[WIDTH - 1]);

wire [WIDTH - 1 : 0] less_signed_result = {{(WIDTH - 1){1'b0}}, addsub_result[WIDTH - 1] ^ overflow_flag};
wire [WIDTH - 1 : 0] less_unsigned_result = {{(WIDTH - 1){1'b0}}, cout ^ cin};


// 选择器
assign result = alu_op == 4'b0000 ? addsub_result : 
                alu_op == 4'b0001 ? addsub_result : 
                alu_op == 4'b1110 ? and_result : 
                alu_op == 4'b1100 ? or_result : 
                alu_op == 4'b1000 ? xor_result :
                alu_op == 4'b0010 ? left_logic_shifter :
                alu_op == 4'b1010 ? right_logic_shifter : 
                alu_op == 4'b1011 ? right_arithmetic_shifter : 
                alu_op == 4'b0100 ? less_signed_result : 
                alu_op == 4'b0110 ? less_unsigned_result : 
                right_data;

assign zero_flag = ~(|addsub_result);

endmodule
