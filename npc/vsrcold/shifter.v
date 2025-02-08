module shifter #(parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] data,
    input la,       // 算术/逻辑    // 0: 逻辑  1: 算数
    input lr,       // 左移/右移    // 0: 左移  1: 右移
    input [$clog2(BITWIDTH) - 1 : 0] shift_number,
    output [BITWIDTH - 1 : 0] result
);

assign result = (la == 1'b0 && lr == 1'b0) ? data << shift_number : 
                (la == 1'b1 && lr == 1'b0) ? data << shift_number : 
                (la == 1'b0 && lr == 1'b1) ? data >>> shift_number : 
                data >> shift_number;


endmodule

