module alu #(parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] inputA,
    input [BITWIDTH - 1 : 0] inputB,
    output [BITWIDTH - 1 : 0] result
);
// only support addition operation now
// addition

wire unusedSigned_cout;
adder #(BITWIDTH) _adder(
    .augend(inputA),
    .addend(inputB),
    .cin(0),
    .sum(result),
    .cout(unusedSigned_cout)
);

endmodule
