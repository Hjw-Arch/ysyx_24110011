module IDU #(parameter WIDTH = 32) (
    // input clk,
    input [31 : 0] inst,
    input zero_flag,
    input less_flag,

    output [4 : 0] rd_addr,
    output [4 : 0] rs1_addr,
    output [4 : 0] rs2_addr,

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

    output [WIDTH - 1 : 0] imm
);

// rf index
assign rd_addr = inst[11 : 7];
assign rs1_addr = inst[19 : 15];
assign rs2_addr = inst[24 : 20];

// PC Control signals
wire is_sys = inst[6] & inst[4] & ~inst[13] & ~inst[12];    // 系统相关指令，ecall、mret，添加指令时可能需要做调整
wire is_b_type = inst[6] & ~inst[4] & ~inst[2];

// 想法：只需要在ID阶段做一个减法器就能在ID阶段判断出是否需要转移
assign pc_val_sel[1] = is_sys & inst[29];   // mret
assign pc_val_sel[0] = is_sys;  // ecall
assign pc_adder_left_sel = inst[6] & ~inst[3] & inst[2];
assign pc_adder_right_sel = inst[6] & inst[2] |     // 这条信号会是瓶颈，是关键路径，单周期不影响，流水线需要单独设置这条信号
                            is_b_type & ~inst[14] & ~inst[12] & zero_flag |
                            is_b_type & ~inst[14] & inst[12] & ~zero_flag |
                            is_b_type & inst[14] & ~inst[12] & less_flag |
                            is_b_type & inst[14] & inst[12] & ~less_flag;

// MEM Control signals
assign mem_we = ~inst[6] & inst[5] & ~inst[4];      // S
assign mem_op = inst[14 : 12];


// RF Control signals
assign rd_we = ~(inst[5] & ~inst[4] & ~inst[2] | is_sys);   // ~((B + S) | sys)
assign rd_input_sel[1] = inst[6] & inst[4];     // CSR
assign rd_input_sel[0] = ~inst[5] & ~inst[4];   // Load

// CSR Control signals
assign csr_we = inst[6] & inst[4] & |inst[13 : 12]; // Zicsr    添加此类指令需重构
assign csr_sel = inst[6] & inst[4] & inst[13];  // // Zicsr    添加此类指令需重构
assign csr_is_ecall = is_sys & ~inst[29];

// ALU Control signals
assign alu_op[0] = ~inst[5] & inst[4] & ~inst[2] & inst[14] & ~inst[13] & inst[12] & inst[30] |             // srai
                   inst[5] & inst[4] & inst[30] |          // R
                   inst[5] & inst[4] & inst[2];   //  lui

assign alu_op[1] = inst[4] & ~inst[2] & inst[12] |      // compute i + compute R
                  inst[6] & ~inst[2] & inst[13];    // Bu

assign alu_op[2] = inst[4] & ~inst[2] & inst[13] |       // compute i + compute R
                  inst[6] & ~inst[2];     // B

assign alu_op[3] = inst[4] & ~inst[2] & inst[14] |        // compute i + compute R
                  inst[5] & inst[4] & inst[2];        // lui

assign alu_left_sel = inst[2];  // U + J
assign alu_right_sel = inst[4] & inst[2] | ~inst[5] & inst[4] | ~inst[6] & ~inst[4];    // U + competeI + L + S

// imm

// 64位需要扩展符号位
assign imm[WIDTH - 1 : 31] = {(WIDTH - 31){inst[31]}};

// 两级延迟
assign imm[10 : 5] = inst[30 : 25] & {6{~(inst[4] & inst[2])}}; // U-Type does not have imm[10 : 5] // {6~{~opcode[6] & opcode[4] & ~opcode[3] & opcode[2]}}， ~U

// 三级延迟，可以优化为两级延迟
assign imm[4 : 1] = inst[11 : 8] & {4{inst[5] & ~inst[2]}} |                    // S + B
                    inst[24 : 21] & {4{inst[3]}} |                                // J
                    inst[24 : 21] & {4{~inst[6] & ~inst[5] & ~inst[2]}} |     // I
                    inst[24 : 21] & {4{~inst[4] & ~inst[3] & inst[2]}};       // I

assign imm[0] = inst[20] & ~inst[6] & ~inst[5] & ~inst[2]  |              // I
                inst[20] & ~inst[4] & ~inst[3] & inst[2] |      // I
                inst[7] & ~inst[6] & inst[5] & ~inst[4];       // S

assign imm[30 : 20] = {11{inst[31] & ~(inst[4] & inst[2])}} | 
                      inst[30 : 20] & {11{inst[4] & inst[2]}}; // ~U | U

assign imm[19 : 12] = {8{inst[31] & inst[5] & ~inst[2]}} |                      // S + B
                      {8{inst[31] & ~inst[6] & ~inst[5] & ~inst[2]}} |        // I
                      {8{inst[31] & ~inst[4] & ~inst[3] & inst[2]}} |         // I
                      inst[19 : 12] & {8{inst[4] & inst[2]}} |                  // U
                      inst[19 : 12] & {8{inst[3]}};                               // J

assign imm[11] = inst[31] & ~inst[6] & inst[5] & ~inst[4] | 
                 inst[31] & ~inst[6] & ~inst[5] & ~inst[2] |
                 inst[31] & ~inst[4] & ~inst[3] & inst[2] |
                 inst[7] & inst[6] & ~inst[2] |
                 inst[20] & inst[3];

endmodule
