// 一位输入四选一数据选择器

module mux4_1(
    input [3 : 0] data,
    input [1 : 0] sel,
    output result
);

assign result = (~sel[1] & ~sel[0] & data[0]) | (~sel[1] & sel[0] & data[1]) | (sel[1] & ~sel[0] & data[2]) | (sel[1] & sel[0] & data[3]);

endmodule
