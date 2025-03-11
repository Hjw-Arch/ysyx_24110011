module WB #(parameter WIDTH = 32) (
    // 给到IDU
    input [4 : 0] rs1_addr,
    input [4 : 0] rs2_addr,
    output [31 : 0] rs1_data,
    output [31 : 0] rs2_data,

    // 真正的WBU
    input clk,
    input rst,

    input lsu_valid,
    output can_start,

    input rd_wen,
    input [1 : 0] rd_input_sel,
    input [4 : 0] rd_addr,
    input [31 : 0] alu_result,
    input [31 : 0] lsu_data,
    input [31 : 0] csr_data_o
);

// WB部分
// 作为最后一个阶段，WB不需要状态机，接到新的任务就直接执行
// 因此LSU或许也不需要WAIT_READY这个状态，只要准备好就直接发，而WB只要接到新任务就直接写，但在这里我不进行这样的处理，等到五级流水线再说
// 多周期节省数据通路，直接在WB完成CSR的全部操作

reg has_new_data;
always_ff @(posedge clk) begin
    has_new_data <= lsu_valid ? 1'b1 : 1'b0;
end

reg can_start;

always_ff @(posedge clk) begin
    can_start <= has_new_data | rst ? 1'b1 : 1'b0;
end

assign wbu_ready = 1'b1;    // 永远能立即处理   五级流水线时考虑去掉wbu_ready


// 若为五级流水线，这里的csr_data需要通过上游模块传过来
wire [WIDTH - 1 : 0] rd_data = rd_input_sel == 2'b01 ? lsu_data : 
                               rd_input_sel == 2'b10 ? csr_data_o : 
                               result;

registerfile #(32) RF_INTER (
    .clk(clk),
    .rst(rst),
    .we(rd_wen & has_new_data),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rs1_addr(rs1_addr),
    .rs1_data(rs1_data),
    .rs2_addr(rs2_addr),
    .rs2_data(rs2_data)
);


endmodule

