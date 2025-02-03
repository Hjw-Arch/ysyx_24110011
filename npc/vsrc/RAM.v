module RAM #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 8) (
    input clk,
    input we,
    input [ADDR_WIDTH - 1 : 0] write_addr,
    input [DATA_WIDTH - 1 : 0] write_data,
    input [ADDR_WIDTH - 1 : 0] read_addr,
    output [DATA_WIDTH - 1 : 0] read_data
);

reg [DATA_WIDTH - 1 : 0] ram_reg [ 2 ** ADDR_WIDTH - 1 : 0];

always @(posedge clk) begin
    if (we) begin
        ram_reg[write_addr] <= write_data;
    end
end

assign read_data = ram_reg[read_addr];

endmodule
