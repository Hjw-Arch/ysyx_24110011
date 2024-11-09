module ram #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32) (
    input clk,
    input we,
    input [1 : 0] format,
    input [DATA_WIDTH - 1 : 0] in_data,
    input [ADDR_WIDTH - 1 : 0] in_addr,
    input [ADDR_WIDTH - 1 : 0] out_inst_addr,   // 读指令地址
    output [DATA_WIDTH - 1 : 0] out_inst    ,  // 读指令数据
    input [ADDR_WIDTH - 1 : 0] out_data_addr,   // 读数据地址
    output [DATA_WIDTH - 1 : 0] out_data       // 读数据数据
);

import "DPI-C" function int fetch_inst(input int pc);
import "DPI-C" function int pmem_read(input int addr, input int len);
import "DPI-C" function void pmem_write(input int addr, input int data, input int len);

always @(posedge clk) begin
    if (we) begin
        pmem_write(in_addr, in_data, format);
    end
end

assign out_inst = fetch_inst(out_inst_addr);
assign out_data = pmem_read(out_data_addr, format);

endmodule
