module alutest(
    input [3 : 0] alu_op,
    input [31 : 0] left_data,
    input [31 : 0] right_data,

    output reg [31 : 0] result,
    output zero_flag
);

always @(*) begin
    case(alu_op)
        4'b0000: result = left_data + right_data;
        4'b0001: result = left_data - right_data;
        4'b1110: result = left_data & right_data;
        4'b1100: result = left_data | right_data;
        4'b1000: result = left_data ^ right_data;
        4'b0010: result = left_data << right_data[4 : 0];
        4'b1010: result = left_data >> right_data[4 : 0];
        4'b1011: result = left_data >>> right_data[4 : 0];
        4'b0100: result = left_data < right_data;
        4'b0110: result = $unsigned(left_data) < $unsigned(right_data);
        default: result = 32'b0;
    endcase
end

assign zero_flag = result == 32'b0;


endmodule
