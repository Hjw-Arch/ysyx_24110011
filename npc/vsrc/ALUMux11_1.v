// 专为ALU输出做选择的数据选择器，不通用

module ALUMux11_1 #(parameter WIDTH = 32) (
    input [WIDTH - 1 : 0] inData [7 : 0],
    input [3 : 0] sel,
    output [WIDTH - 1 : 0] result
);

// 0000和1000共用结果
// 0001 0101 1101共用结果

assign result = ({WIDTH{~sel[3] & ~sel[2] & ~sel[1] & ~sel[0]}} & inData[0]) | 
                ({WIDTH{~sel[3] & ~sel[2] & ~sel[1] & sel[0]}} & inData[1]) | 
                ({WIDTH{~sel[3] & ~sel[2] & sel[1] & ~sel[0]}} & inData[2]) | 
                ({WIDTH{~sel[3] & ~sel[2] & sel[1] & sel[0]}} & inData[3]) |
                ({WIDTH{~sel[3] & sel[2] & ~sel[1] & ~sel[0]}} & inData[4]) | 
                ({WIDTH{~sel[3] & sel[2] & ~sel[1] & sel[0]}} & inData[1]) |
                ({WIDTH{~sel[3] & sel[2] & sel[1] & ~sel[0]}} & inData[5]) | 
                ({WIDTH{~sel[3] & sel[2] & sel[1] & sel[0]}} & inData[6]) |
                ({WIDTH{sel[3] & ~sel[2] & ~sel[1] & ~sel[0]}} & inData[0]) |
                ({WIDTH{sel[3] & ~sel[2] & sel[1] & ~sel[0]}} & inData[7]) | 
                ({WIDTH{sel[3] & sel[2] & ~sel[1] & sel[0]}} & inData[1]);

endmodule
