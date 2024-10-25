module ysyx #(parameter WIDTH = 32)(
    input clk,
    input rst
);

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
wire [2 : 0] func3;
wire [6 : 0] func7;

wire [31 : 0] imm;
wire [4 : 0] rd_addr;
wire [31 : 0] rd_data;
wire [4 : 0] rs1_addr;
wire [31 : 0] rs1_data;
// wire [4 : 0] rs2_addr;

// 模块交互数据
wire [WIDTH - 1 : 0] aluA_input, aluB_input;
wire [WIDTH - 1 : 0] alu_result;

// 控制信号
wire aluASel;   // 控制aluA的输入选择
wire aluBSel;   // 控制aluA的输入选择, 目前jump指令需要选择4
wire aluOP;     // 控制alu动作

assign opcode = inst[6 : 0];
assign func3 = inst[14 : 12];
assign func7 = inst[31 : 25];

assign rd_addr = inst[11 : 7];
assign rs1_addr = inst[19 : 15];
// assign rs2_data = inst[24 : 20];

ctrl_gen _ctrl_gen(
    .opcode(opcode[6 : 2]),
    .func3(func3),
    .func7(func7[5]),
    .aluASel(aluASel),
    .aluBSel(aluBSel),
    .aluOP(aluOP)
);

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
    .rs1_data(rs1_data)
);


/*************************************** EXU ***************************************/

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


alu #(32) _alu(
    .inputA(aluA_input),
    .inputB(aluB_input),
    .ctrl(aluOP),
    .result(alu_result)
);

/*************************************** WB ***************************************/
// now only alu's result need to be writed to register rd
assign rd_data = alu_result;


endmodule
