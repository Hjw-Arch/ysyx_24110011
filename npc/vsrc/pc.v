module pc #(parameter BITWIDTH = 32, RST_VALUE = 32'h80000000) (
    input clk,
    input rst,
    output reg [BITWIDTH - 1 : 0] pc
);

wire [BITWIDTH - 1 : 0] new_pc;

wire unused_wire;
adder #(BITWIDTH) _adder(
    .augend(pc),
    .addend(32'h4),
    .cin(0),
    .sum(new_pc),
    .cout(unused_wire)
);

always @(posedge clk) begin
    if (rst) pc <= RST_VALUE;
    else pc <= new_pc;
end


endmodule
