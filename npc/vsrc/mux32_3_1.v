// 32位四选一通用数据选择器, 不通用 

module mux32_3_1 (
    input [31 : 0] input1,
    input [31 : 0] input2,
    input [31 : 0] input3,
    input [1 : 0] s,
    output [31 : 0] result
);

assign result = ({32{~s[0] & ~s[1]}} & input1) | ({32{s[0] & ~s[1]}} & input2) | ({32{s[0] & s[1]}} & input3) | ({32{~s[0] & s[1]}} & input1);

endmodule
