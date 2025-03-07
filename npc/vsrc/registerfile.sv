module registerfile #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input we,

    input valid,
    output reg start,
    
    input [4 : 0] rd_addr,
    input [WIDTH - 1 : 0] rd_data,

    input [4 : 0] rs1_addr,
    output [WIDTH - 1 : 0] rs1_data,

    input [4 : 0] rs2_addr,
    output [WIDTH - 1 : 0] rs2_data
);

reg [WIDTH - 1 : 0] register_file [31 : 0];

wire not_x0 = |rd_addr;

always @(posedge clk) begin
    if (we & not_x0 & valid) register_file[rd_addr] <= rd_data;
end

// 
always_ff @(posedge clk) begin
    if (valid || rst) begin
        start <= 1'b1;
    end else begin
        start <= 1'b0;
    end
end


assign rs1_data = rs1_addr != 0 ? register_file[rs1_addr] : {WIDTH{1'b0}};
assign rs2_data = rs2_addr != 0 ? register_file[rs2_addr] : {WIDTH{1'b0}};


endmodule
