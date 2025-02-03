module IFU #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input [WIDTH - 1 : 0] pc,
    output [31 : 0] inst
);


import "DPI-C" function int fetch_inst(input int pc);

assign inst = fetch_inst(pc);

// RAM #(32, 8) IF_RAM (
//     .clk(clk),
//     .we(0),
//     .write_addr(32'b0),
//     .write_data(32'b0),
//     .read_addr(pc[7 : 0]),
//     .read_data(inst)
// );

endmodule

