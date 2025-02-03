// not a competed version
module CSR #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input we,
    input is_ecall,
    input [11 : 0] addr,
    input [WIDTH - 1 : 0] data_in,
    input [WIDTH - 1 : 0] pc,

    output [WIDTH - 1 : 0] data_out,
    output [WIDTH - 1 : 0] mtvec,
    output [WIDTH - 1 : 0] mepc
);

reg [WIDTH - 1 : 0] reg_mcause, reg_mstatus, reg_mtvec, reg_mepc;

wire is_mcause = (addr[7 : 0] == 8'h42);
wire is_mstatus = (addr[7 : 0] == 8'h00);
wire is_mtvec = (addr[7 : 0] == 8'h05);
wire is_mepc = (addr[7 : 0] == 8'h41);

always @(posedge clk) begin
    if (rst) begin
        reg_mcause <= {WIDTH{1'b0}};
        reg_mtvec <= {WIDTH{1'b0}};
        reg_mepc <= {WIDTH{1'b0}};
    end else begin
        if (is_ecall) begin
            reg_mcause <= 32'd11;
            reg_mepc <= pc;
            reg_mstatus <= 32'h1800;    // for difftest
        end else begin
            reg_mcause <= (is_mcause & we) ? data_in : reg_mcause;
            reg_mstatus <= (is_mstatus & we) ? data_in : reg_mstatus;
            reg_mtvec <= (is_mtvec & we) ? data_in : reg_mtvec;
            reg_mepc <= (is_mepc & we) ? data_in : reg_mepc;
        end
    end
end

assign data_out = {32{is_mcause}} & reg_mcause | 
                  {32{is_mstatus}} & reg_mstatus | 
                  {32{is_mtvec}} & reg_mtvec | 
                  {32{is_mepc}} & reg_mepc;

assign mtvec = reg_mtvec;
assign mepc = reg_mepc;


endmodule
