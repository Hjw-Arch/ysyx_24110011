// 32位四选一通用数据选择器, 不通用 

module mux32_3_1 (
    input [31 : 0] input1,
    input [31 : 0] input2,
    input [31 : 0] input3,
    input [1 : 0] s,
    output [31 : 0] result
);
// 三级门电路延迟，可优化为两级，代价不大, 多32*2*4个晶体管
assign result = ({32{~s[1] & ~s[0]}} & input1) | ({32{~s[1] & s[0]}} & input2) | ({32{s[1] & ~s[0]}} & input3) | ({32{s[1] & s[0]}} & input2);

endmodule
