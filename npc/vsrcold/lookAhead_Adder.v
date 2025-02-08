module lookAhead_Adder (
    input [3 : 0] augend,
    input [3 : 0] addend,
    input cin,
    output [3 : 0] sum,
    output cout
);


wire [3 : 0] C, G, P;
assign G = augend & addend;
assign P = augend ^ addend;

assign C[0] = G[0] | (P[0] & cin);
assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & cin);
assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & cin);
assign C[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & cin);

assign cout = C[3];

assign sum[0] = P[0] ^ cin;
assign sum[1] = P[1] ^ C[0];
assign sum[2] = P[2] ^ C[1];
assign sum[3] = P[3] ^ C[2];


endmodule
