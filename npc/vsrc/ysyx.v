module ysyx #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input rst_clk_n,

    output [WIDTH - 1 : 0] _pc,
    output [WIDTH - 1 : 0] _inst,
    output [WIDTH - 1 : 0] _result,
    output [WIDTH - 1 : 0] _csr_data_out,
    output [WIDTH - 1 : 0] _rs1_data, _rs2_data,
    output [WIDTH - 1 : 0] _read_data,
    output [4 : 0] _rs1_addr, _rs2_addr,
    output [WIDTH - 1 : 0] _imm, 
);

reg clk_2, clk_2_n;

always @(posedge clk) begin
    if (rst_clk_n) begin
        clk_2 <= 1'b0;
    end else
        clk_2 <= ~clk_2;
end

assign clk_2_n = ~clk_2;

// 内部信号
// PC
wire [1 : 0] pc_sel;
wire pc_sel_for_adder_left, pc_sel_for_adder_right;
wire [WIDTH - 1 : 0] rs1_data, rs2_data, imm, mtvec, mepc;
wire [WIDTH - 1 : 0] pc;

// IF
wire [31 : 0] inst; 

// ID
wire [4 : 0] rd_addr, rs1_addr, rs2_addr;
wire [3 : 0] alu_op;
wire alu_left_sel, alu_right_sel;
wire mem_we;
wire [2 : 0] mem_op;
wire rd_we;
wire [1 : 0] rd_input_sel;
wire [WIDTH - 1 : 0] csr_data_out;
wire csr_we, csr_sel, csr_is_ecall;

// EX
wire [WIDTH - 1 : 0] result;
wire zero_flag;

// MEM
wire [WIDTH - 1 : 0] read_data;

// PC

PC #(WIDTH) PC_INTER(
    .clk(clk_2_n),
    .rst(rst),
    .sel(pc_sel),
    .sel_for_adder_left(pc_sel_for_adder_left),
    .sel_for_adder_right(pc_sel_for_adder_right),
    .rs1(rs1_data),
    .imm(imm),
    .mtvec(mtvec),
    .mepc(mepc),
    .pc(pc)
);

// IF
IFU #(32) IFU_INTER(
    .clk(clk_2),
    .rst(rst),
    .pc(pc),
    .inst(inst)
);

// ID
IDU #(32) IDU_INTER(
    .inst(inst),
    .zero_flag(zero_flag),
    .less_flag(result[0]),
    .rd_addr(rd_addr),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .alu_op(alu_op),
    .alu_left_sel(alu_left_sel),
    .alu_right_sel(alu_right_sel),
    .pc_val_sel(pc_sel),
    .pc_adder_left_sel(pc_sel_for_adder_left),
    .pc_adder_right_sel(pc_sel_for_adder_right),
    .mem_we(mem_we),
    .mem_op(mem_op),
    .rd_we(rd_we),
    .rd_input_sel(rd_input_sel),
    .csr_we(csr_we),
    .csr_sel(csr_sel),
    .csr_is_ecall(csr_is_ecall),
    .imm(imm)
);

// EX
EXU #(32) EXU_INTER(
    .alu_op(alu_op),
    .rs1(rs1_data),
    .pc(pc),
    .imm(imm),
    .rs2(rs2_data),
    .alu_sel_left(alu_left_sel),
    .alu_sel_right({alu_left_sel, alu_right_sel}),
    .result(result),
    .zero_flag(zero_flag)
);

// MEM
MEM #(32) MEM_INTER(
    .clk(clk_2_n),
    .we(mem_we),
    .mem_op(mem_op),
    .write_addr(result),
    .write_data(rs2_data),
    .read_addr(result),
    .read_data(read_data)
);

// WB  rf

wire [WIDTH - 1 : 0] rd_data = rd_input_sel == 2'b01 ? read_data : 
                               rd_input_sel == 2'b10 ? csr_data_out : 
                               result;


registerfile #(32) RF_INTER (
    .clk(clk_2_n),
    .we(rd_we),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rs1_addr(rs1_addr),
    .rs1_data(rs1_data),
    .rs2_addr(rs2_addr),
    .rs2_data(rs2_data)
);

wire [31 : 0] csr_data_in = csr_sel ? rs1_data | csr_data_out : rs1_data;

CSR #(32) CSR_INTER(
    .clk(clk_2_n),
    .rst(rst),
    .we(csr_we),
    .is_ecall(csr_is_ecall),
    .addr(inst[31 : 20]),
    .data_in(csr_data_in),
    .pc(pc),
    .data_out(csr_data_out),
    .mtvec(mtvec),
    .mepc(mepc)
);

assign _pc = pc;
assign _inst = inst;
assign _result = result;
assign _csr_data_out = csr_data_out;
assign _rs1_data = rs1_data;
assign _rs2_data = rs2_data;
assign _read_data = read_data;
assign _rs1_addr = rs1_addr;
assign _rs2_addr = rs2_addr;
assign _imm = imm;


endmodule
