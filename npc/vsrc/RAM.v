module RAM  (
    input clk,
    input we,
    input [7 : 0] write_addr,
    input [31 : 0] write_data,
    input [7 : 0] read_addr,
    output [31 : 0] read_data
);

reg [31 : 0] ram_reg [255 : 0];

always @(posedge clk) begin
    if (we) begin
        ram_reg[write_addr] <= write_data;
    end
end

assign read_data = ram_reg[read_addr];

endmodule
