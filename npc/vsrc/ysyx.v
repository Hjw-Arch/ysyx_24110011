module ysyx(
    output [31 : 0] PC,
    output [31 : 0] rf [31 : 0],
    output [31 : 0] _inst,
    // above variable is for test

    input clk,
    input rst
);

import "DPI-C" function int fetch_inst(input int pc);

/*************************************** IFU ***************************************/

// PC
wire [31 : 0] pc;
pc #(32, 32'h80000000) _pc (
    .clk(clk),
    .rst(rst),
    .pc(pc)
);

// fetch instruction
wire [31 : 0] inst;
assign inst = fetch_inst(pc);

/*************************************** IDU ***************************************/
wire [6 : 0] opcode;
wire [2 : 0] funct3;
wire [6 : 0] funct7;

wire [31 : 0] imm;
wire [4 : 0] rd_addr;
wire [31 : 0] rd_data;
wire [4 : 0] rs1_addr;
wire [31 : 0] rs1_data;

// wire [4 : 0] rs2_addr;

assign opcode = inst[6 : 0];
assign funct3 = inst[14 : 12];
assign funct7 = inst[31 : 25];

assign imm = {{20{inst[31]}}, inst[31 : 20]};
assign rd_addr = inst[11 : 7];
assign rs1_addr = inst[19 : 15];
// assign rs2_data = inst[24 : 20];

// registerfile, get data required by IDU
registerFile #(32, 5) _registerFile(
    .clk(clk),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rs1_addr(rs1_addr),
    .rs1_data(rs1_data),

    // for test
    .rf(rf)
);


/*************************************** EXU ***************************************/
wire [31 : 0] alu_result;
alu #(32) _alu(
    .inputA(rs1_data),
    .inputB(imm),
    .result(alu_result)
);

/*************************************** WB ***************************************/
// now only alu's result need to be writed to register rd
assign rd_data = alu_result;


assign PC = pc;
assign _inst = inst;

endmodule
