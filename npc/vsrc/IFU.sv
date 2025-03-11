module IFU #(parameter WIDTH = 32) (
    input clk,
    input rst,

    input start,
    input [WIDTH - 1 : 0] pc,

    output ifu_valid,
    output reg [63 : 0] ifu_data,
    input idu_ready
);

import "DPI-C" function int fetch_inst(input int pc);

typedef enum logic { 
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
            next_state = (ifu_valid && !idu_ready) ? S_WAIT_READY : S_IDLE;
        S_WAIT_READY:
            next_state = (idu_ready) ? S_IDLE : S_WAIT_READY;
        default:
            next_state = state;
    endcase
end

wire has_new_inst = start;

assign ifu_valid = has_new_inst | (state == S_WAIT_READY);

// 模拟SRAM取指
always_ff @(posedge clk) begin
    ifu_data <= start ? {fetch_inst(pc), pc} : ifu_data;
    $display("start = %d", start);
    $display("ifu_valid = %d", ifu_valid);
end


endmodule

