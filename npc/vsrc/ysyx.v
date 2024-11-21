module ysyx #(parameter WIDTH = 32)(
    input clk,
    input rst
);

import "DPI-C" function int fetch_inst(input int pc);

/*************************************** IFU ***************************************/

// PC
wire [WIDTH - 1 : 0] pc;
pc #(WIDTH, 32'h80000000) _pc (
    .clk(clk),
    .rst(rst),
    .rs1_data(rs1_data),
    .imm(imm),
    .sel({pcAdderASel, pcAdderBSel}),
    .pc(pc)
);

// fetch instruction
wire [31 : 0] inst;
assign inst = fetch_inst(pc);

/*************************************** IDU ***************************************/
wire [6 : 0] opcode;
wire [2 : 0] func3;
wire [6 : 0] func7;

wire [31 : 0] imm;          // immediate
wire [4 : 0] rd_addr;       
wire [31 : 0] rd_data;
wire [4 : 0] rs1_addr;
wire [31 : 0] rs1_data;
wire [4 : 0] rs2_addr;
wire [31 : 0] rs2_data;

// 模块交互数据
wire [WIDTH - 1 : 0] aluA_input, aluB_input;
wire [WIDTH - 1 : 0] alu_result;

// 控制信号
wire aluASel;   // 控制aluA的输入选择
wire aluBSel;   // 控制aluA的输入选择, 目前jump指令需要选择4
wire [3 : 0] aluOP;     // 控制alu动作
wire rdWriteEnable;
wire memWriteEnable;
wire rdInputSel;
wire [2 : 0] memOP;
wire [2 : 0] branchWay;
wire pcAdderASel;
wire pcAdderBSel;

wire zero_flag;
wire [31 : 0] mem_result;

assign opcode = inst[6 : 0];
assign func3 = inst[14 : 12];
assign func7 = inst[31 : 25];

assign rd_addr = inst[11 : 7];
assign rs1_addr = inst[19 : 15];
assign rs2_addr = inst[24 : 20];

ctrl_gen _ctrl_gen(
    .opcode(opcode[6 : 2]),
    .func3(func3),
    .func7(func7[5]),
    .aluASel(aluASel),
    .aluBSel(aluBSel),
    .aluOP(aluOP),
    .pcAdderASel(pcAdderASel),
    .rdWriteEnable(rdWriteEnable),
    .memWriteEnable(memWriteEnable),
    .rdInputSel(rdInputSel),
    .memOP(memOP),
    .branchWay(branchWay)
);

// pcAdderBSel三级延迟，整个控制信号产生阶段需要四级延迟
assign pcAdderBSel = opcode[6] & opcode[2] |        // jump指令
                     ~branchWay[2] & branchWay[1] & ~branchWay[0] & zero_flag |
                     ~branchWay[2] & branchWay[1] & branchWay[0] & ~zero_flag |
                     branchWay[2] & branchWay[1] & ~branchWay[0] & alu_result[0] |
                     branchWay[2] & branchWay[1] & branchWay[0] & ~alu_result[0];

// 3~4级延迟
// generate imm
imm_gen _imm_gen(
    .opcode(opcode[6 : 2]),
    .inst(inst[31 : 7]),
    .imm(imm)
);

mux32_2_1 _mux_rd(
    .input1(alu_result),
    .input2(mem_result),
    .s(rdInputSel), 
    .result(rd_data)
);

// registerfile, get data required by IDU
registerFile #(32, 5) _registerFile(
    .clk(clk),
    .writeEnable(rdWriteEnable),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rs1_addr(rs1_addr),
    .rs1_data(rs1_data),
    .rs2_addr(rs2_addr),
    .rs2_data(rs2_data)
);


csr _csr(
    .clk(clk),
    .rst(rst),
    .addr(inst[31 : 20]),
    .data_in(_),    // TODO
    .data_out(_)
);


/*************************************** EXU ***************************************/

mux32_2_1 _mux_aluA(
    .input1(rs1_data),
    .input2(pc),
    .s(aluASel), 
    .result(aluA_input)
);

mux32_3_1 _mux_aluB(
    .input1(rs2_data),
    .input2(imm),
    .input3(32'h4),
    .s({aluASel, aluBSel}), // TODO
    .result(aluB_input)
);


alu #(32) _alu(
    .inputA(aluA_input),
    .inputB(aluB_input),
    .aluOP(aluOP),
    .result(alu_result),
    .zero_flag(zero_flag)
);

/*************************************** WB ***************************************/
wire [31 : 0] mem_data;
ram _ram(
    .clk(clk),
    .memWriteEnable(memWriteEnable),
    .aluOP(memOP[1 : 0]),
    .writeAddr(alu_result),
    .writeData(rs2_data),
    .readAddr(alu_result),
    .readData(mem_data)
);

assign mem_result = {mem_data[31 : 16] | {16{(~(|memOP) & mem_data[7]) | (~memOP[2] & ~memOP[1] & memOP[0] & mem_data[15])}}, mem_data[15 : 8] | {8{(~(|memOP) & mem_data[7])}}, mem_data[7 : 0]};


endmodule
