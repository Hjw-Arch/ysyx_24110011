// 桶形移位器
module barrel_shifter #(parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] data,
    input la,       // 算术/逻辑    // 0: 逻辑  1: 算数
    input lr,       // 左移/右移    // 0: 左移  1: 右移
    input [$clog2(BITWIDTH) - 1 : 0] shift_number,
    output [BITWIDTH - 1 : 0] result
);


wire [BITWIDTH - 1 : 0] temp_in[$clog2(BITWIDTH) : 0]/* verilator split_var */;

assign temp_in[0] = data;

genvar i, j;
generate
    for (i = 0; i < ($clog2(BITWIDTH)); i = i + 1) begin
        wire [BITWIDTH - 1 : 0] left_in, right_in;

        for (j = 0; j < BITWIDTH; j = j + 1) begin
            if (j < 2 ** i) begin
                assign left_in[j] = 0;
                assign right_in[BITWIDTH - 1 - j] = la & data[BITWIDTH - 1];
            end else begin
                assign left_in[j] = temp_in[i][j - 2 ** i];
                assign right_in[BITWIDTH - 1 - j] = temp_in[i][BITWIDTH - 1 - j + 2 ** i];
            end
        end


        for(j = 0; j < BITWIDTH; j = j + 1)
            mux4_1 mux({right_in[j], temp_in[i][j], left_in[j], temp_in[i][j]}, {lr, shift_number[i]}, temp_in[i + 1][j]);
    end

endgenerate

assign result = temp_in[$clog2(BITWIDTH)];


endmodule
