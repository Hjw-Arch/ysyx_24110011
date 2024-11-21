module test_ctrl(
    input [6 : 2] opcode,
    input [2 : 0] func3,
    input func7,
    output aluASel,
    output aluBSel,
    output pcAdderASel,
    output rdWriteEnable,
    output memWriteEnable,
    output rdInputSel,
    output [3 : 0] aluOP,
    output [2 : 0] memOP,
    output [2 : 0] branchWay
);

wire is_lui = (opcode == 5'b01101);
wire is_auipc = (opcode == 5'b00101);
wire is_addi = (opcode == 5'b00100 && func3 == 3'b000);
wire is_slti = (opcode == 5'b00100 && func3 == 3'b010);
wire is_sltiu = (opcode == 5'b00100 && func3 == 3'b011);
wire is_xori = (opcode == 5'b00100 && func3 == 3'b100);
wire is_ori = (opcode == 5'b00100 && func3 == 3'b110);
wire is_andi = (opcode == 5'b00100 && func3 == 3'b111);
wire is_slli = (opcode == 5'b00100 && func3 == 3'b001 && func7 == 1'b0);
wire is_srli = (opcode == 5'b00100 && func3 == 3'b101 && func7 == 1'b0);
wire is_srai = (opcode == 5'b00100 && func3 == 3'b101 && func7 == 1'b1);


wire is_add = (opcode == 5'b01100 && func3 == 3'b000 && func7 == 1'b0);
wire is_sub = (opcode == 5'b01100 && func3 == 3'b000 && func7 == 1'b1);
wire is_sll = (opcode == 5'b01100 && func3 == 3'b001 && func7 == 1'b0);
wire is_slt = (opcode == 5'b01100 && func3 == 3'b010 && func7 == 1'b0);
wire is_sltu = (opcode == 5'b01100 && func3 == 3'b011 && func7 == 1'b0);
wire is_xor = (opcode == 5'b01100 && func3 == 3'b100 && func7 == 1'b0);
wire is_sri = (opcode == 5'b01100 && func3 == 3'b101 && func7 == 1'b0);
wire is_sra = (opcode == 5'b01100 && func3 == 3'b101 && func7 == 1'b1);
wire is_or = (opcode == 5'b01100 && func3 == 3'b110 && func7 == 1'b0);
wire is_and = (opcode == 5'b01100 && func3 == 3'b111 && func7 == 1'b0);

wire is_jal = (opcode == 5'b11011);
wire is_jalr = (opcode == 5'b11001 && func3 == 3'b000);

wire is_beq = (opcode == 5'b11000 && func3 == 3'b000);
wire is_bne = (opcode == 5'b11000 && func3 == 3'b001);
wire is_blt = (opcode == 5'b11000 && func3 == 3'b100);
wire is_bge = (opcode == 5'b11000 && func3 == 3'b101);
wire is_bltu = (opcode == 5'b11000 && func3 == 3'b110);
wire is_bgeu = (opcode == 5'b11000 && func3 == 3'b111);

wire is_lb = (opcode == 5'b00000 && func3 == 3'b000);
wire is_lh = (opcode == 5'b00000 && func3 == 3'b001);
wire is_lw = (opcode == 5'b00000 && func3 == 3'b010);
wire is_lbu = (opcode == 5'b00000 && func3 == 3'b100);
wire is_lhu = (opcode == 5'b00000 && func3 == 3'b101);

wire is_sb = (opcode == 5'b01000 && func3 == 3'b000);
wire is_sh = (opcode == 5'b01000 && func3 == 3'b001);
wire is_sw = (opcode == 5'b01000 && func3 == 3'b010);

assign aluAsel = is_auipc | is_jal | is_jalr;
assign aluBsel[0] = (opcode == 5'b00100 || is_lui || is_auipc || opcode == 5'b00000 || opcode == 5'b01000);
assign aluBsel[1] = aluAsel;

assign rdWriteEnable = ~(opcode == 5'b11000 || opcode == 5'b01000);

assign memWriteEnable = (opcode == 5'b01000);

assign rdInputSel = (opcode == 5'b00000);

assign memOP = func3;

assign aluOP = is_lui ? 4'b1001 : 
               is_auipc || is_addi || is_add || is_jal || is_jalr || opcode == 5'b00000 || opcode == 5'b01000 ? 4'b0000 :
               is_slti || is_slt || opcode == 5'b11000 ? 4'b0100 :
               is_sltiu || is_sltu ? 4'b0110 :
               is_xori || is_xor ? 4'b1000 :
               is_ori || is_or ? 4'b1100 :
               is_andi || is_and ? 4'b1110 :
               is_slli || is_sll ? 4'b0010 :
               is_srli || is_srl ? 4'b1010 :
               is_srai || is_sra ? 4'b1011 : 4'b0000;


// assign aluOP[0] = ~opcode[5] & opcode[4] & ~opcode[2] & func3[2] & ~func3[1] & func3[0] & func7 |             // srai
//                    opcode[5] & opcode[4] & func7 |          // R
//                    opcode[5] & opcode[4] & opcode[2];   //  lui

// assign aluOP[1] = opcode[4] & ~opcode[2] & func3[0] |      // compute i + compute R
//                   opcode[6] & ~opcode[2] & func3[1];    // Bu

// assign aluOP[2] = opcode[4] & ~opcode[2] & func3[1] |       // compute i + compute R
//                   opcode[6] & ~opcode[2];     // B

// assign aluOP[3] = opcode[4] & ~opcode[2] & func3[2] |        // compute i + compute R
//                   opcode[5] & opcode[4] & opcode[2];        // lui


// assign branchWay[0] = opcode[6] & ~opcode[2] & func3[0];
// assign branchWay[1] = opcode[6] & ~opcode[2];
// assign branchWay[2] = opcode[6] & ~opcode[2] & func3[2];

assign branchWay = is_beq ? 3'b010 : 
                   is_bne ? 3'b011 : 
                   is_blt ? 3'b110 :
                   is_bge ? 3'b111 :
                   is_bltu ? 3'b110 :
                   is_bgeu ? 3'b111 : 0;

endmodule
