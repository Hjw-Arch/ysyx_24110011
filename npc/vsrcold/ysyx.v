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
    .mtvec(mtvec),
    .mepc(mepc),
    .pc_sel(pcSel),
    .adderSel({pcAdderASel, pcAdderBSel}),
    .pc(pc)
);

// fetch instruction
wire [31 : 0] inst;
assign inst = fetch_inst(pc);


/*
// 测试单周期NPC性能

ram_test TestIF(
    .clk(clk),
    .WE(1'b0),
    .writeAddr(8'b0),
    .writeData(32'b0),
    .readAddr(pc[7 : 0]),
    .readData(inst)
);

// 结束位置
*/


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
wire [1 : 0] rdInputSel;
wire [2 : 0] memOP;
wire [2 : 0] branchWay;
wire pcAdderASel;
wire pcAdderBSel;

wire [1 : 0] pcSel;
wire CSRSel;
wire CSRWriteEnable;
wire is_ecall;

wire [31 : 0] csr_data_out;
wire [31 : 0] mtvec;
wire [31 : 0] mepc;

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
    .inst_21(inst[21]),
    .aluASel(aluASel),
    .aluBSel(aluBSel),
    .aluOP(aluOP),
    .pcAdderASel(pcAdderASel),
    .rdWriteEnable(rdWriteEnable),
    .memWriteEnable(memWriteEnable),
    .rdInputSel(rdInputSel),
    .memOP(memOP),
    .branchWay(branchWay),

    .pcSel(pcSel),
    .CSRSel(CSRSel),
    .CSRWriteEnable(CSRWriteEnable),
    .is_ecall(is_ecall)
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

assign rd_data = rdInputSel == 2'b00 ? alu_result : 
                 rdInputSel == 2'b01 ? mem_result :
                 rdInputSel == 2'b10 ? csr_data_out : 32'b0;

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



wire [31 : 0] csr_data_in = CSRSel ? rs1_data | csr_data_out : rs1_data;
csr _csr(
    .clk(clk),
    .rst(rst),
    .write_enable(CSRWriteEnable),
    .is_ecall(is_ecall),
    .pc(pc),
    .addr(inst[31 : 20]),
    .data_in(csr_data_in),
    .data_out(csr_data_out),
    .mtvec_out(mtvec),
    .mepc_out(mepc)
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


alu_test #(32) _alu(
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
