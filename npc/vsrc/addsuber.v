// 加减法器，add_or_sub位为0时使用加法，为1时使用减法

module addsuber #(parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] input1,
    input [BITWIDTH - 1 : 0] input2,
    input add_or_sub,
    output [BITWIDTH - 1 : 0] result,
    output carry_flag, overflow_flag
);

wire cout;

adder #(BITWIDTH) add_sub(
    input1,
    {BITWIDTH{add_or_sub}} ^ input2,
    add_or_sub,
    result,
    cout
);

// 判断是否为0
// assign zero_flag = ~(|result);

// 判断是否溢出，仅对有符号位有效
// 取符号位
wire symbol_bit = add_or_sub ^ input2[BITWIDTH - 1];
assign overflow_flag = (input1[BITWIDTH - 1] & symbol_bit & ~result[BITWIDTH - 1]) | (~input1[BITWIDTH - 1] & ~symbol_bit & result[BITWIDTH - 1]);

// 判断进位位，仅对无符号数有效
// 判断规则，如果是加法，则进位位为1表示溢出，如果是减法，进位位为0表示溢出

assign carry_flag = add_or_sub ^ cout;


endmodule
