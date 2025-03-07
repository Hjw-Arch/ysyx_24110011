module IFU #(parameter WIDTH = 32) (
    input clk,
    input rst,

    input start,
    input [WIDTH - 1 : 0] pc,

    output ifu_valid,
    output reg [31 : 0] ifu_inst,
    input ifu_ready
);

import "DPI-C" function int fetch_inst(input int pc);

typedef enum logic [1 : 0] { 
    S_IDLE,
    S_WAIT_READY
} ifu_state_t;

ifu_state_t state, next_state;

always_ff @(posedge clk) begin
    state <= rst ? S_IDLE : next_state;
end

always_comb begin
    case(state)
        S_IDLE:
            next_state = (ifu_valid && !ifu_ready) ? S_WAIT_READY : S_IDLE;
        S_WAIT_READY:
            next_state = (ifu_ready) ? S_IDLE : S_WAIT_READY;
        default:
            next_state = state;
    endcase
end

assign ifu_valid = inst_available | (state == S_WAIT_READY);

reg [31 : 0] inst_reg, old_inst_buffer;
reg inst_available;

// 模拟SRAM取指
always_ff @(posedge clk) begin
    inst_reg <= start ? fetch_inst(pc) : inst_reg;
    inst_available <= start ? 1'b1 : 1'b0;  // 取到指令标志
end

// 如果ifu ready没拉高，保存现有指令
always_ff @(posedge clk) begin
    old_inst_buffer <= (ifu_valid & ifu_ready) ? inst_reg : old_inst_buffer;
end

assign ifu_inst = (ifu_valid & ifu_ready) ? inst_reg : old_inst_buffer;


endmodule

