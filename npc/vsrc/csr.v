// Not a completed version
module csr(
    input clk,
    input rst,
    input write_enable,
    input is_ecall,
    input [31 : 0] pc,
    input [11 : 0] addr,
    input [31 : 0] data_in,
    output [31 : 0] data_out,
    output [31 : 0] mtvec_out,
    output [31 : 0] mepc_out
);

assign mtvec_out = mtvec;
assign mepc_out = mepc;

reg [31 : 0] mcause, mstatus, mtvec, mepc;

wire is_mcause = (addr[7 : 0] == 8'h42);
wire is_mstatus = (addr[7 : 0] == 8'h00);
wire is_mtvec = (addr[7 : 0] == 8'h05);
wire is_mepc = (addr[7 : 0] == 8'h41);


always @(posedge clk) begin
    if (rst) begin
        mcause <= 32'h0;
        mstatus <= 32'h1800;
        mtvec <= 32'h0;
        mepc <= 32'h0;
    end else begin
        if (is_ecall) begin
            mcause <= 32'd11;
            mepc <= pc;
        end else begin
            mcause <= (is_mcause & write_enable) ? data_in : mcause;
            mstatus <= (is_mstatus & write_enable) ? data_in : mstatus;
            mtvec <= (is_mtvec & write_enable) ? data_in : mtvec;
            mepc <= (is_mepc & write_enable) ? data_in : mepc;
        end
    end
end


assign data_out = {32{is_mcause}} & mcause | 
                  {32{is_mstatus}} & mstatus | 
                  {32{is_mtvec}} & mtvec | 
                  {32{is_mepc}} & mepc;

endmodule
