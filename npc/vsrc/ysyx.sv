module ysyx #(parameter WIDTH = 32) (
    input clk,
    input rst
);

// PC
// 五级流水线需要修改
wire [1 : 0] pc_sel;
wire pc_sel_for_adder_left;
wire is_branch;
wire [31 : 0] pc_imm;
wire [31 : 0] pc_inst;
wire pc;


// IF
wire ifu_valid;
wire [63 : 0] ifu_data;

// ID
wire idu_ready;
wire idu_valid;
wire [190 : 0] idu_data;


// EX
wire exu_ready;
wire exu_valid;
wire [107 : 0] exu_data;

// LS
wire lsu_ready;
wire lsu_valid;
wire [ : ] lsu_data;




// IF
IFU #(32) IFU_INTER(
    .clk(clk),
    .rst(rst),
    .start(start),
    .pc(pc),        // 五级流水线需要修改
    .ifu_valid(ifu_valid),
    .ifu_data(ifu_data),
    .idu_ready(idu_ready)
);


// ID
IDU #(32) IDU_INTER(
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),

    .clk(clk),
    .rst(rst),
    .ifu_valid(ifu_valid),
    .ifu_data(ifu_data),
    .idu_ready(idu_ready),
    .idu_valid(idu_valid),
    .idu_data(idu_data),
    .exu_ready(exu_ready),

    // PC直通，五级流水线需要修改
    .pc_sel(pc_sel),
    .pc_sel_for_adder_left(pc_sel_for_adder_left),
    .is_branch(is_branch),
    .imm(imm),
    .inst(inst)
);

// EX
EXU #(32) EXU_INTER(
    .clk(clk),
    .rst(rst),

    .idu_valid(idu_valid),
    .idu_data(idu_data),
    .exu_ready(exu_ready),

    .exu_valid(exu_valid),
    .exu_data(exu_data),
    .lsu_ready(lsu_ready),

    // 直通PC，五级流水线需修改
    .pc_sel(pc_sel),
    .pc_sel_for_adder_left(pc_sel_for_adder_left),
    .is_branch(is_branch),
    .imm(imm),
    .inst(inst),
    .pc(pc)
);

// MEM
LSU #(32) LSU_INTER(
    
);

// WB  rf

wire [WIDTH - 1 : 0] rd_data = rd_input_sel == 2'b01 ? read_data : 
                               rd_input_sel == 2'b10 ? csr_data_out : 
                               result;


registerfile #(32) RF_INTER (
    .clk(clk),
    .rst(rst),
    .we(rd_we),
    .valid(ifu_valid),
    .start(start),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rs1_addr(rs1_addr),
    .rs1_data(rs1_data),
    .rs2_addr(rs2_addr),
    .rs2_data(rs2_data)
);

wire [31 : 0] csr_data_in = csr_sel ? rs1_data | csr_data_out : rs1_data;

CSR #(32) CSR_INTER(
    .clk(clk),
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




endmodule
