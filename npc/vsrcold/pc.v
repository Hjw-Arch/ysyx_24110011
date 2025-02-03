module pc #(parameter BITWIDTH = 32, RST_VALUE = 32'h80000000) (
    input clk,
    input rst,
    input [BITWIDTH - 1 : 0] rs1_data,
    input [31 : 0] imm,
    input [31 : 0] mtvec,
    input [31 : 0] mepc,
    input [1 : 0] pc_sel,
    input [1 : 0] adderSel,
    output reg [BITWIDTH - 1 : 0] pc
);

wire [31 : 0] addrA_input, addrB_input;

mux32_2_1 _adderAMux(
    .input1(pc),
    .input2(rs1_data),
    .s(adderSel[1]),
    .result(addrA_input)
);

mux32_2_1 _adderBMux(
    .input1(4),
    .input2(imm),
    .s(adderSel[0]),
    .result(addrB_input)
);

wire [BITWIDTH - 1 : 0] adder_res;

wire unused_wire;
adder #(BITWIDTH) _adder(
    .augend(addrA_input),
    .addend(addrB_input),
    .cin(0),
    .sum(adder_res),
    .cout(unused_wire)
);

wire [31 : 0] new_pc = pc_sel == 2'b00 ? adder_res : 
                       pc_sel == 2'b01 ? mtvec : 
                       pc_sel == 2'b11 ? mepc : adder_res;

always @(posedge clk) begin
    if (rst) pc <= RST_VALUE;
    else pc <= new_pc;
end


endmodule
