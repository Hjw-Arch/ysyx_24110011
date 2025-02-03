module PC #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input [1 : 0] sel,
    input sel_for_adder_left,
    input sel_for_adder_right,
    input [WIDTH - 1 : 0] rs1,
    input [WIDTH - 1 : 0] imm,
    input [WIDTH - 1 : 0] mtvec,
    input [WIDTH - 1 : 0] mepc,

    output reg [WIDTH - 1 : 0] pc
);

wire [WIDTH - 1 : 0] adder_left = sel_for_adder_left ? rs1 : pc;
wire [WIDTH - 1 : 0] adder_right = sel_for_adder_right ? imm : {{(WIDTH-3){1'b0}}, 3'b100};

wire [WIDTH - 1 : 0] adder_result = adder_left + adder_right;

wire [WIDTH - 1 : 0] new_pc = sel == 2'b01 ? mtvec :
                              sel == 2'b11 ? mepc  : 
                              adder_result;

always @(posedge clk) begin
    if (rst) pc <= 32'h80000000;
    else pc <= new_pc;
end


endmodule
