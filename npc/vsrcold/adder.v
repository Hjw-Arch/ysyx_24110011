module adder # (parameter BITWIDTH = 32) (
    input [BITWIDTH - 1 : 0] augend, addend,
    input cin,
    output [BITWIDTH - 1 : 0] sum,
    output cout
);

generate
    genvar i;  
    wire [BITWIDTH / 4 : 0] c_wire;
    assign c_wire[0] = cin;
    for (i = 0; i < BITWIDTH / 4; i = i + 1) begin
        lookAhead_Adder add(.augend(augend[(i + 1) * 4 - 1 : i * 4]), 
                            .addend(addend[(i + 1) * 4 - 1 : i * 4]), 
                            .cin(c_wire[i]), 
                            .sum(sum[(i + 1) * 4 - 1 : i * 4]), 
                            .cout(c_wire[i + 1])
                            );
    end
    assign cout = c_wire[BITWIDTH / 4];
endgenerate

endmodule

