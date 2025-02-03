module MEM #(parameter WIDTH = 32) (
    input clk,
    input we,
    input [2 : 0] mem_op,
    input [WIDTH - 1 : 0] write_addr,
    input [WIDTH - 1 : 0] write_data,
    input [WIDTH - 1 : 0] read_addr,
    output [WIDTH - 1 : 0] read_data
);

import "DPI-C" function int pmem_read(input int addr, input int len);
import "DPI-C" function void pmem_write(input int addr, input int data, input int len);


always @(posedge clk) begin
    if(we) pmem_write(write_addr, write_data, mem_op);
end


wire [WIDTH - 1 : 0] _read_data = pmem_read(read_addr, mem_op);


// wire [WIDTH - 1 : 0] _read_data;

// RAM #(32, 8) MEM_RAM(
//     .clk(clk),
//     .we(we),
//     .write_addr(write_addr),
//     .write_data(write_data),
//     .read_addr(read_addr),
//     .read_data(_read_data)
// );


assign read_data = {_read_data[31 : 16] | {16{(~(|mem_op) & _read_data[7]) | (~mem_op[2] & ~mem_op[1] & mem_op[0] & _read_data[15])}}, _read_data[15 : 8] | {8{(~(|mem_op) & _read_data[7])}}, _read_data[7 : 0]};



endmodule

