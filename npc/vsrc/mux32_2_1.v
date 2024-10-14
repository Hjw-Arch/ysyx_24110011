module mux32_2_1(
    input [31 : 0] input1,
    input [31 : 0] input2,
    input s,
    output [31 : 0] result
);

assign result = ({32{~s}} & input1) | ({32{s}} & input2);

endmodule
