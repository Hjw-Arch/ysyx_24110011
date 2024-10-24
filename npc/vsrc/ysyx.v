module ysyx #(parameter WIDTH = 32)(
    output [31 : 0] PC,
    output [31 : 0] rf [31 : 0],
    output [31 : 0] _inst,
    output _pc_adderA_sel,
    output _pc_adderB_sel,
    output [31 : 0] _imm,
    output [31 : 0] _aluA_input,
    output [31 : 0] _aluB_input,
    // above variable is for test

    input clk,
    input rst
);

assign _pc_adderA_sel = pc_adderA_sel;
assign _pc_adderB_sel = pc_adderB_sel;
assign _imm = imm;
assign _aluA_input = aluA_input;
assign _aluB_input = aluB_input;

import "DPI-C" function int fetch_inst(input int pc);

/*************************************** IFU ***************************************/

// 控制信号
wire pc_adderA_sel, pc_adderB_sel;
assign pc_adderA_sel = ~opcode[4] & ~opcode[3] & opcode[2];
assign pc_adderB_sel = opcode[6] & opcode[2];

// PC
wire [WIDTH - 1 : 0] pc;
pc #(WIDTH, 32'h80000000) _pc (
    .clk(clk),
    .rst(rst),
    .rs1_data(rs1_data),
    .imm(imm),
    .sel({pc_adderB_sel, pc_adderA_sel}),
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

// assign imm = {{20{inst[31]}}, inst[31 : 20]};
assign rd_addr = inst[11 : 7];
assign rs1_addr = inst[19 : 15];
// assign rs2_data = inst[24 : 20];

// generate imm
imm_gen _imm_gen(
    .opcode(opcode[6 : 2]),
    .inst(inst[31 : 7]),
    .imm(imm)
);

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
wire [WIDTH - 1 : 0] aluA_input, aluB_input;

// 控制信号
wire aluASel = opcode[2];   // 控制aluA的输入选择
wire aluBSel = opcode[6] & opcode[2];   // 控制aluA的输入选择, 目前jump指令需要选择4

mux32_2_1 _mux_aluA(
    .input1(rs1_data),
    .input2(pc),
    .s(aluASel), // TODO
    .result(aluA_input)
);

mux32_2_1 _mux_aluB(
    .input1(imm),
    .input2(4),
    .s(aluBSel), // TODO
    .result(aluB_input)
);


// 控制信号
wire alu_ctrl = ~opcode[6] & opcode[5] & opcode[2];

wire [WIDTH - 1 : 0] alu_result;
alu #(32) _alu(
    .inputA(aluA_input),
    .inputB(aluB_input),
    .ctrl(alu_ctrl),
    .result(alu_result)
);

/*************************************** WB ***************************************/
// now only alu's result need to be writed to register rd
assign rd_data = alu_result;


assign PC = pc;
assign _inst = inst;

endmodule
