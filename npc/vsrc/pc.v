module pc #(parameter WIDTH = 32, RST_VALUE = 32'h80000000) (
    input clk,
    input rst,
    input adderASel,
    input adderBSel,
    input [WIDTH - 1 : 0] rs1Data,
    input [WIDTH - 1 : 0] imm,
    output reg [WIDTH - 1 : 0] PC
);

// 需要两个二选一数据选择器

wire [WIDTH - 1 : 0] adderAInput;
wire [WIDTH - 1 : 0] adderBInput;

mux32_2_1 adderAMux(
    .input1(PC),
    .input2(rs1Data),
    .s(adderASel),
    .result(adderAInput)
);

mux32_2_1 adderBMux(
    .input1(4),
    .input2(imm),
    .s(adderBSel),
    .result(adderBInput)
);

// 加法器，每次输出的pc值是之前的pc+4
wire [WIDTH - 1 : 0] sum;
wire unuesd_signal;
adder #(32) _adder(.augend(adderAInput),
                   .addend(adderBInput),
                   .cin(0),
                   .sum(sum),
                   .cout(unuesd_signal)
);

always @(posedge clk) begin
    $display("input1 = 0x%x, input2 = 0x%x, sum = 0x%x", adderAInput, adderBInput, sum);
    if(rst) PC <= RST_VALUE;
    else PC <= sum;
end

endmodule
