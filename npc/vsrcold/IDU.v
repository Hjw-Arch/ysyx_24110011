module IDU #(parameter WIDTH = 32) (
    // input clk,
    input [31 : 0] inst,
    input zero_flag,
    input less_flag,

    output [3 : 0] alu_op,
    output alu_left_sel,
    output alu_right_sel,

    output [1 : 0] pc_val_sel,
    output pc_adder_left_sel,
    output pc_adder_right_sel,

    output mem_we,
    output [2 : 0] mem_op,

    output rd_we,
    output [1 : 0] rd_input_sel,

    output csr_we,
    output csr_sel,
    output csr_is_ecall,

    // output [WIDTH - 1 : 0] imm
);

wire is_lui = inst[6 : 2] == 5'b01101;
wire is_auipc = inst[6 : 2] == 5'b00101;
wire is_addi = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b000;
wire is_slti = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b010;
wire is_sltiu = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b011;
wire is_xori = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b100;
wire is_ori = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b110;
wire is_andi = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b111;
wire is_slli = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b001 && inst[30] == 1'b0;
wire is_srli = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b101 && inst[30] == 1'b0;
wire is_srai = inst[6 : 2] == 5'b00100 && inst[14 : 12] == 3'b101 && inst[30] == 1'b1;

wire is_add = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b000 && inst[30] == 1'b0;
wire is_sub = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b000 && inst[30] == 1'b1;
wire is_sll = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b001 && inst[30] == 1'b0;
wire is_slt = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b010 && inst[30] == 1'b0;
wire is_sltu = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b011 && inst[30] == 1'b0;
wire is_xor = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b100 && inst[30] == 1'b0;
wire is_srl = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b101 && inst[30] == 1'b0;
wire is_sra = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b000 && inst[30] == 1'b1;
wire is_or = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b110 && inst[30] == 1'b0;
wire is_and = inst[6 : 2] == 5'b01100 && inst[14 : 12] == 3'b111 && inst[30] == 1'b0;

wire is_jal = inst[6 : 2] == 5'b11011;
wire is_jalr = inst[6 : 2] == 5'b11001 && inst[14 : 12] == 3'b000;

wire is_beq = inst[6 : 2] == 5'b11000 && inst[14 : 12] == 3'b000;
wire is_bne = inst[6 : 2] == 5'b11000 && inst[14 : 12] == 3'b001;
wire is_blt = inst[6 : 2] == 5'b11000 && inst[14 : 12] == 3'b100;
wire is_bge = inst[6 : 2] == 5'b11000 && inst[14 : 12] == 3'b101;
wire is_bltu = inst[6 : 2] == 5'b11000 && inst[14 : 12] == 3'b110;
wire is_bgeu = inst[6 : 2] == 5'b11000 && inst[14 : 12] == 3'b111;

wire is_lb = inst[6 : 2] == 5'b00000 && inst[14 : 12] == 3'b000;
wire is_lh = inst[6 : 2] == 5'b00000 && inst[14 : 12] == 3'b001;
wire is_lw = inst[6 : 2] == 5'b00000 && inst[14 : 12] == 3'b010;
wire is_lbu = inst[6 : 2] == 5'b00000 && inst[14 : 12] == 3'b100;
wire is_lhu = inst[6 : 2] == 5'b00000 && inst[14 : 12] == 3'b101;

wire is_sb = inst[6 : 2] == 5'b01000 && inst[14 : 12] == 3'b000;
wire is_sh = inst[6 : 2] == 5'b01000 && inst[14 : 12] == 3'b001;
wire is_sw = inst[6 : 2] == 5'b01000 && inst[14 : 12] == 3'b010;

wire is_csrrw = inst[6 : 2] == 5'b11100 && inst[14 : 12] == 3'b001;
wire is_csrrs = inst[6 : 2] == 5'b11100 && inst[14 : 12] == 3'b010;

wire is_ecall = inst[6 : 2] == 5'b11100 && inst[14 : 12] == 3'b010 && inst[29] == 1'b0;
wire is_mret = inst[6 : 2] == 5'b11100 && inst[14 : 12] == 3'b010 && inst[29] == 1'b1;


assign alu_left_sel = is_auipc | is_jal | is_jalr;
assign alu_right_sel = ~(inst[6 : 2] == 5'b01100 | is_jal | is_jalr | inst[6 : 2] == 5'b11000);

assign pc_val_sel[1] = is_mret;
assign pc_val_sel[0] = is_ecall;
assign pc_adder_left_sel = is_jalr;
assign pc_adder_right_sel = is_jal | is_jalr | (is_beq & zero_flag) | (is_bne & ~zero_flag) | 
                            (is_blt & less_flag) | (is_bge & ~less_flag) | 
                            (is_bltu & less_flag) | (is_bgeu & ~less_flag);

assign mem_we = is_sb | is_sh | is_sw;
assign mem_op = inst[14 : 12];

assign rd_we = ~(inst[6 : 2] == 5'b11000 | inst[6 : 2] == 5'b01000 | is_ecall | is_mret);
assign rd_input_sel[1] = is_csrrw | is_csrrs;
assign rd_input_sel[0] = inst[6 : 2] == 5'b00000;

assign csr_we = is_csrrs | is_csrrw;
assign csr_sel = is_csrrs;

assign alu_op[0] = ~inst[5] & inst[4] & ~inst[2] & inst[14] & ~inst[13] & inst[12] & inst[30] |             // srai
                   inst[5] & inst[4] & inst[30] |          // R
                   inst[5] & inst[4] & inst[2];   //  lui

assign alu_op[1] = inst[4] & ~inst[2] & inst[12] |      // compute i + compute R
                  inst[6] & ~inst[2] & inst[13];    // Bu

assign alu_op[2] = inst[4] & ~inst[2] & inst[13] |       // compute i + compute R
                  inst[6] & ~inst[2];     // B

assign alu_op[3] = inst[4] & ~inst[2] & inst[14] |        // compute i + compute R
                  inst[5] & inst[4] & inst[2];        // lui


endmodule
