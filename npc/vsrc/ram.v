module ram #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32) (
    input clk,
    input we,
    input [1 : 0] format,
    input [DATA_WIDTH - 1 : 0] in_data,
    input [ADDR_WIDTH - 1 : 0] in_addr,
    input [ADDR_WIDTH - 1 : 0] out_inst_addr,   // 读指令地址
    output [DATA_WIDTH - 1 : 0] out_inst    ,  // 读指令数据
    input [ADDR_WIDTH - 1 : 0] out_data_addr,   // 读数据地址
    output [DATA_WIDTH - 1 : 0] out_data       // 读数据数据
);

reg [7 : 0] RAM [32'h80000100 - 1 : 32'h80000000];

initial begin
    {RAM[32'h80000003], RAM[32'h80000002], RAM[32'h80000001], RAM[32'h80000000]} = 32'b11111111100000000000000000010011; 
    {RAM[32'h80000007], RAM[32'h80000006], RAM[32'h80000005], RAM[32'h80000004]} = 32'b11111111100100000000000010010011; 
    {RAM[32'h8000000B], RAM[32'h8000000A], RAM[32'h80000009], RAM[32'h80000008]} = 32'b11111111101000000000000100010011; 
    {RAM[32'h8000000F], RAM[32'h8000000E], RAM[32'h8000000D], RAM[32'h8000000C]} = 32'b10111111101100000000000110010011; 
    {RAM[32'h80000013], RAM[32'h80000012], RAM[32'h80000011], RAM[32'h80000010]} = 32'b10111111110000000000001000010011;
end

always @(posedge clk) begin
    if (we) begin
        case (format) 
            2'b00: RAM[in_addr] <= in_data[7 : 0];
            2'b01: {RAM[in_addr + 1], RAM[in_addr]} <= in_data[15 : 0];
            2'b10: {RAM[in_addr + 3], RAM[in_addr + 2], RAM[in_addr + 1], RAM[in_addr]} <= in_data;
            default: {RAM[in_addr + 3], RAM[in_addr + 2], RAM[in_addr + 1], RAM[in_addr]} <= in_data;
        endcase
    end
end

assign out_inst = {RAM[out_inst_addr + 3], RAM[out_inst_addr + 2], RAM[out_inst_addr + 1], RAM[out_inst_addr]};
assign out_data = {{RAM[out_data_addr + 3], RAM[out_data_addr + 2]} & {16{format[1]}}, RAM[out_data_addr + 1] & {8{format[1] | format[0]}}, RAM[out_data_addr]};

endmodule
