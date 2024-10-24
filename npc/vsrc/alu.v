module alu #(parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] inputA,
    input [BITWIDTH - 1 : 0] inputB,
    input ctrl,
    output [BITWIDTH - 1 : 0] result
);
// only support addition operation now
// addition

wire unusedSigned_cout;
wire [BITWIDTH - 1 : 0] adder_result;
adder #(BITWIDTH) _adder(
    .augend(inputA),
    .addend(inputB),
    .cin(0),
    .sum(adder_result),
    .cout(unusedSigned_cout)
);

mux32_2_1 _mux32_2_1(
    .input1(adder_result),
    .input2(inputB),
    .s(ctrl),
    .result(result)
);

endmodule
