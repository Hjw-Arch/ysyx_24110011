module mux32_2_1(
    input [31 : 0] input1,
    input [31 : 0] input2,
    input s,
    output [31 : 0] result
);
// 两级门电路延迟
assign result = ({32{~s}} & input1) | ({32{s}} & input2);

// assign result = s ? input2 : input1;

endmodule
