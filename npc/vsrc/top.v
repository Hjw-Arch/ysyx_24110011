module top #(parameter WIDTH = 32)(
    // test
    output [31 : 0] rf [31 : 0],

    input clk, 
    input rst,
    output [31 : 0] pc, 
    output [31 : 0] _inst
);

// test
assign _inst = inst;
// assign _imm = imm;
// assign _inputA = ALUAInput;
// assign _inputB = ALUBInput;
// assign _aluresult = ALUResult;
// assign _rdaddr = rd_addr;
// assign _rddata = rd_data;
// assign _rdenable = rdEnable;

/***************************** 数据定义 *********************************/
// 取值模块

wire pcAdderASel, pcAdderBSel;      // pc内置加法器的A、B两端的数据选择控制信号
wire [31 : 0] inst;

// 译码模块

wire [4 : 0] rs1_addr, rs2_addr, rd_addr;   // 寄存器地址
wire [31 : 7] immToGen;         // 待生成的立即数
wire [6 : 0] opcode;        // 操作码
wire [2 : 0] funct3;
wire [6 : 0] funct7;

// 控制信号
wire [2 : 0] extOP; // 指令的类型 I:000; U:001; B:010; J:011; S:100; 用于生成立即数
wire readMemEnable;  // 是否需要读内存(将内存值写入rd寄存器，1即表示将内存值写入rd寄存器)
wire writeMemEnable;    // 是否需要写内存(1时需要写回)
wire rdEnable;      // 是否需要rd(是否需要写寄存器)
wire ALUASel;       // 控制ALU A端的输入方式
wire [1 : 0] ALUBSel;   // 控制ALU B段的输入方式
wire [3 : 0] ALUCtrl;   // 控制ALU的行为
wire [2 : 0] branchWay;  // PC的更新方式(分支指令)， 配合ALU计算结果判断PC的更新方式
wire [2 : 0] memOP; // 操作内存的方式

// 获取操作数
wire [31 : 0] imm;      // 最终的立即数
wire [31 : 0] rs1_data, rs2_data;   // rs1 rs2

// ALU A B两端的输入
wire [31 : 0] ALUAInput;
wire [31 : 0] ALUBInput;

// ALU的输出
wire [31 : 0] ALUResult;
wire carry_flag, zero_flag, overflow_flag;  // 标志信号

// mem的输出
wire [31 : 0] memResult;

// rd寄存器的输入
wire [31 : 0] rd_data;



/***************************** 模块组合、赋值数据 *********************************/

// IFU

// pc module

pc _PC(.clk(clk),
      .rst(rst),
      .adderASel(pcAdderASel), // TODO
      .adderBSel(pcAdderBSel), // TODO
      .rs1Data(rs1_data),
      .imm(imm),
      .PC(pc));

// inst = pmem_read(pc)

// IDU

assign rs1_addr = inst[19 : 15];
assign rs2_addr = inst[24 : 20];
assign rd_addr = inst[11 : 7];
assign immToGen = inst[31 : 7];


assign opcode = inst[6 : 0];
assign funct3 = inst[14 : 12];
assign funct7 = inst[31 : 25];


// 四级延迟， 用于比较是否相等的同或、与门两级，与键值与运算一级，产生输出选择的或门一级，共四级延迟
// 产生控制信号
// MuxKeyWithDefault #(1, 9, 19) genCtrl (
//     .out({extOP, readMemEnable, writeMemEnable, rdEnable, ALUASel, ALUBSel, ALUCtrl, branchWay, memOP}),
//     .key({opcode[6 : 2], funct3[2 : 0], funct7[5]}),
//     .default_out(19'b0),
//     .lut({
//         5'b00100, 3'b000, 1'bX,     3'b000, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, 4'b0000, 3'b000, 3'b000           // addi
//     })
// );

// 直接通过与或门得到控制信号，比较复杂，但是电路少，延迟低, 会比较麻烦, 还需考虑如何编码能使译码高效   // 仅有两级延迟，即与或门
// 多拉了一根线（ALUBSel[1]），可以消掉, 影响不大
genCtrl _genCtrl(
    .opcode6_2(opcode[6 : 2]),
    .funct3(funct3),
    .funct7_5(funct7[5]),
    .extOP(extOP),
    .readMemEnable(readMemEnable),
    .writeMemEnable(writeMemEnable),
    .rdEnable(rdEnable),
    .memOP(memOP),
    .branchOP(branchWay),
    .ALUCtrl(ALUCtrl),
    .ALUASel(ALUASel),
    .ALUBSel(ALUBSel)
);

// PC跳转控制信号
assign pcAdderASel = ~branchWay[2] & branchWay[1] & ~branchWay[0];

assign pcAdderBSel = ~branchWay[2] & ~branchWay[1] & branchWay[0] | 
                     ~branchWay[2] & branchWay[1] & ~branchWay[0] | 
                     branchWay[2] & ~branchWay[1] & ~branchWay[0] & zero_flag |
                     branchWay[2] & ~branchWay[1] & branchWay[0] & ~zero_flag | 
                     branchWay[2] & branchWay[1] & ~branchWay[0] & ALUResult[0] |
                     branchWay[2] & branchWay[1] & branchWay[0] & ~ALUResult[0];


// 获取数据

// 生成立即数
genImm _genImm(
    .immToGen(immToGen),
    .extOP(extOP),
    .imm(imm)
);

mux32_2_1 ALUAMux(
    .input1(rs1_data),
    .input2(pc),
    .s(ALUASel),
    .result(ALUAInput)
);

mux32_3_1 ALUBMux(
    .input1(imm),
    .input2(rs2_data),
    .input3(32'h4),
    .s(ALUBSel),
    .result(ALUBInput)
);

mux32_2_1 rdDataMux (
    .input1(ALUResult),
    .input2(memResult), // TODO: memResult
    .s(readMemEnable),
    .result(rd_data)
);

// get rs
RegisterFile #(5, 32) _registerFile(
    .rf(rf),
    .clk(clk),
    .rdAddr(rd_addr),
    .rdData(rd_data),
    .writeEnable(rdEnable),

    .rs1Addr(rs1_addr),
    .rs1Data(rs1_data),

    .rs2Addr(rs2_addr),
    .rs2Data(rs2_data)
);


// EXU
ALU #(WIDTH) alu(
    .ctrl(ALUCtrl),
    .input1(ALUAInput),
    .input2(ALUBInput),
    .result(ALUResult),
    .carry_flag(carry_flag),
    .zero_flag(zero_flag),
    .overflow_flag(overflow_flag)
);



// ram module
wire [31 : 0] _memResult;
ram _RAM(.clk(clk),
        .we(writeMemEnable),
        .format(memOP[1 : 0]),
        .in_data(rs2_data),
        .in_addr(ALUResult),
        .out_inst_addr(pc),
        .out_inst(inst),
        .out_data_addr(ALUResult),
        .out_data(_memResult)
);


assign memResult = {_memResult[31 : 16] | {16{(~(|memOP) & _memResult[7]) | (~memOP[2] & ~memOP[1] & memOP[0] & _memResult[15])}}, _memResult[15 : 8] | {8{(~(|memOP) & _memResult[7])}}, _memResult[7 : 0]};


endmodule
