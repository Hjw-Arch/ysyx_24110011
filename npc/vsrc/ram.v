module ram (
    input clk,
    input memWriteEnable,
    input [1 : 0] aluOP,
    input [31 : 0] writeAddr,
    input [31 : 0] writeData,
 
    input [31 : 0] readAddr,
    output [31 : 0] readData
);

import "DPI-C" function int pmem_read(input int addr, input int len);
import "DPI-C" function void pmem_write(input int addr, input int data, input int len);



always @(posedge clk) begin
    if(memWriteEnable) pmem_write(writeAddr, writeData, aluOP);
end


assign readData = pmem_read(readAddr, aluOP);



/*

wire [31 : 0] testForWB1;

registerFile #(32, 8) testForWB(
    clk,
    memWriteEnable,
    writeAddr[7 : 0],
    writeData,
    readAddr[7 : 0],
    readData,
    {4{aluOP}},
    testForWB1
);

*/

endmodule
