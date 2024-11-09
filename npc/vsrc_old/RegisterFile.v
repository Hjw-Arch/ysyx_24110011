// `include "define"

module RegisterFile #(parameter ADDR_WIDTH = `reg_addr_width, DATA_WIDTH = `reg_data_width) (
    // test
    output [DATA_WIDTH - 1 : 0] rf [2 ** ADDR_WIDTH - 1 : 0],

    input clk,

    input [ADDR_WIDTH - 1 : 0] rdAddr,
    input [DATA_WIDTH - 1 : 0] rdData,
    input writeEnable,

    input [ADDR_WIDTH - 1 : 0] rs1Addr,
    input [ADDR_WIDTH - 1 : 0] rs2Addr,

    output [DATA_WIDTH - 1 : 0] rs1Data,
    output [DATA_WIDTH - 1 : 0] rs2Data
);

reg [DATA_WIDTH - 1 : 0] register0;     // 0号寄存器
reg [DATA_WIDTH - 1 : 0] register1_31 [2 ** ADDR_WIDTH - 1 : 1];    // 1_32号寄存器

assign register0 = 32'b0;

wire [DATA_WIDTH - 1 : 0] registerFile [2 ** ADDR_WIDTH - 1 : 0];
assign registerFile[2 ** ADDR_WIDTH - 1 : 1] =register1_31 [2 ** ADDR_WIDTH - 1 : 1];
assign registerFile[0] =register0;


always @(posedge clk) begin
    if(writeEnable) register1_31[rdAddr] <= rdData;
end

assign rs1Data = registerFile[rs1Addr];
assign rs2Data = registerFile[rs2Addr];

assign rf = registerFile;
    
endmodule //RegisterFile
