module registerFile #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 5) (
    output [31 : 0] rf [31 : 0],

    // above is for test
    input clk,

    input [ADDR_WIDTH - 1 : 0] rd_addr,
    input [DATA_WIDTH - 1 : 0] rd_data,

    input [ADDR_WIDTH - 1 : 0] rs1_addr,
    output [DATA_WIDTH - 1 : 0] rs1_data
);

wire [DATA_WIDTH - 1 : 0] registerFile0 = 32'b0;        // number zero register, it's value keeps zero forever
reg [DATA_WIDTH - 1 : 0] registerFile31_1 [2 ** ADDR_WIDTH - 1 : 1]; // nember one to thirty-one registers

wire [DATA_WIDTH - 1 : 0] registerFile [2 ** ADDR_WIDTH - 1 : 0];
assign registerFile[2 ** ADDR_WIDTH - 1 : 1] = registerFile31_1;
assign registerFile[0] = registerFile0;

// write registers, sequence circuit
always @(posedge clk) 
    registerFile31_1[rd_addr] <= rd_data;

// read registers, combinational circuit
assign rs1_data = registerFile[rs1_addr];

// for test
assign rf = registerFile;

endmodule