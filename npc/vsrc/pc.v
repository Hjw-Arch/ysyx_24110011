module pc #(parameter BITWIDTH = 32, RST_VALUE = 32'h80000000) (
    input clk,
    input rst,
    input [BITWIDTH - 1 : 0] rs1_data,
    input [31 : 0] imm,
    input [1 : 0] sel,
    output reg [BITWIDTH - 1 : 0] pc
);

wire [31 : 0] addrA_input, addrB_input;

mux32_2_1 _adderAMux(
    .input1(pc),
    .input2(rs1_data),
    .s(sel[0]),  // TODO
    .result(addrA_input)
);

mux32_2_1 _adderBMux(
    .input1(4),
    .input2(imm),
    .s(sel[1]),  // TODO
    .result(addrB_input)
);

wire [BITWIDTH - 1 : 0] new_pc;

wire unused_wire;
adder #(BITWIDTH) _adder(
    .augend(addrA_input),
    .addend(addrB_input),
    .cin(0),
    .sum(new_pc),
    .cout(unused_wire)
);

always @(posedge clk) begin
    if (rst) pc <= RST_VALUE;
    else pc <= new_pc;
end


endmodule
