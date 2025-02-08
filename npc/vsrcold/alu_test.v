module alu_test #(parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] inputA,
    input [BITWIDTH - 1 : 0] inputB,
    input [3 : 0] aluOP,
    output [BITWIDTH - 1 : 0] result,
    output zero_flag
);

assign result = aluOP == 4'b0000 ? inputA + inputB : 
                aluOP == 4'b0001 ? inputA - inputB :
                aluOP == 4'b0010 ? inputA << inputB[4 : 0] :
                aluOP == 4'b0100 ? inputA < inputB :
                aluOP == 4'b0110 ? $unsigned(inputA) < $unsigned(inputB) :
                aluOP == 4'b1000 ? inputA ^ inputB :
                aluOP == 4'b1100 ? inputA | inputB :
                aluOP == 4'b1110 ? inputA & inputB :
                aluOP == 4'b1010 ? inputA >> inputB[4 : 0] :
                aluOP == 4'b1011 ? inputA >>> inputB[4 : 0] :
                aluOP == 4'b1001 ? inputB : 32'b0;

assign zero_flag = result == 0;





endmodule