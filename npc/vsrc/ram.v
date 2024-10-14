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

reg [7 : 0] RAM [32'h80005000 - 1 : 32'h80000000];

initial begin
    // {RAM[32'h80000003], RAM[32'h80000002], RAM[32'h80000001], RAM[32'h80000000]} = 32'h00000413;
    // {RAM[32'h80000007], RAM[32'h80000006], RAM[32'h80000005], RAM[32'h80000004]} = 32'h00009117; 
    // {RAM[32'h8000000B], RAM[32'h8000000A], RAM[32'h80000009], RAM[32'h80000008]} = 32'hffc10113; 
    // {RAM[32'h8000000F], RAM[32'h8000000E], RAM[32'h8000000D], RAM[32'h8000000C]} = 32'h00c000ef; 
    // {RAM[32'h80000013], RAM[32'h80000012], RAM[32'h80000011], RAM[32'h80000010]} = 32'h00000513;
    // {RAM[32'h80000017], RAM[32'h80000016], RAM[32'h80000015], RAM[32'h80000014]} = 32'h00008067;
    // {RAM[32'h8000001b], RAM[32'h8000001a], RAM[32'h80000019], RAM[32'h80000018]} = 32'hff010113;
    // {RAM[32'h8000001f], RAM[32'h8000001e], RAM[32'h8000001d], RAM[32'h8000001c]} = 32'h00000517;
    // {RAM[32'h80000023], RAM[32'h80000022], RAM[32'h80000021], RAM[32'h80000020]} = 32'h01c50513;
    // {RAM[32'h80000027], RAM[32'h80000026], RAM[32'h80000025], RAM[32'h80000024]} = 32'h00112623;
    // {RAM[32'h8000002b], RAM[32'h8000002a], RAM[32'h80000029], RAM[32'h80000028]} = 32'hfe9ff0ef;
    // {RAM[32'h8000002f], RAM[32'h8000002e], RAM[32'h8000002d], RAM[32'h8000002c]} = 32'h00050513;
    // {RAM[32'h80000033], RAM[32'h80000032], RAM[32'h80000031], RAM[32'h80000030]} = 32'h00100073;
    // {RAM[32'h80000037], RAM[32'h80000036], RAM[32'h80000035], RAM[32'h80000034]} = 32'h0000006f;
    $readmemh("/home/hjw-arch/add.txt", RAM);
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
