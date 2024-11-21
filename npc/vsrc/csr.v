// Not a completed version
module csr(
    input clk,
    input rst,
    input write_enable,
    input [11 : 0] addr,
    input [31 : 0] data_in,
    output [31 : 0] data_out
);

reg [31 : 0] mcause, mstatus, mtvec, mepc;

wire is_mcause = (addr == 12'h342);
wire is_mstatus = (addr == 12'h300);
wire is_mtvec = (addr == 12'h305);
wire is_mepc = (addr == 12'h341);


always @(posedge clk) begin
    if (rst) begin
        mcause <= 32'h0;
        mstatus <= 32'h1800;
        mtvec <= 32'h0;
        mepc <= 32'h0;
    end else begin
        mcause <= (is_mcause & write_enable) ? data_in : mcause;
        mstatus <= (is_mstatus & write_enable) ? data_in : mstatus;
        mtvec <= (is_mtvec & write_enable) ? data_in : mtvec;
        mepc <= (is_mepc & write_enable) ? data_in : mepc;
    end
end


assign data_out = {32{is_mcause}} & mcause | 
                  {32{is_mstatus}} & mstatus | 
                  {32{is_mtvec}} & mtvec | 
                  {32{is_mepc}} & mepc;

endmodule