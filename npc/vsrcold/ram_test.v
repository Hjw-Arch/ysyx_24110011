module ram_test(
    input clk,
    input WE,
    input [7 : 0] writeAddr,
    input [31 : 0] writeData,
    input [7 : 0] readAddr,
    output [31 : 0] readData
);

reg [31 : 0] RAM [7 : 0];

always @(posedge clk) begin
    if (WE) RAM[writeAddr] = writeData;
end

assign readData = RAM[readAddr];

endmodule