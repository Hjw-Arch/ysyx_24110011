module UART(
    input clk,
    input rst,

    input  ARVALID,
    output ARREADY,
    input  [31 : 0] ARADDR,

    output RVALID,
    input  RREADY,
    output [31 : 0] RDATA,
    output [1 : 0] RRESP,

    input  AWVALID,
    output AWREADY,
    input  [31 : 0] AWADDR,

    input  WVALID,
    output WREADY,
    input  [31 : 0] WDATA,
    input  [3 : 0] WSTRB,

    input  BREADY,
    output BVALID,
    output [1 : 0] BRESP
);

// 读通道

assign ARREADY = 1'b0;
assign RVALID = 1'b0;
assign RDATA = 32'b00;
assign RRESP = 2'b00;


// 写通道

typedef enum logic [4 : 0] { 
    W_IDLE = 5'b00001,
    W_WAIT_ADDR = 5'b00010,
    W_WAIT_DATA = 5'b00100,
    W_ACTIVE = 5'b01000,
    W_WAIT_BREADY = 5'b10000
} w_state_t;

w_state_t w_state, next_w_state;

always_ff @(posedge clk) begin
    w_state <= rst ? W_IDLE : next_w_state;
end

always_comb begin
    case(w_state)
        W_IDLE:
            case({AWVALID, WVALID})
                2'b11: next_w_state = W_ACTIVE;
                2'b10: next_w_state = W_WAIT_DATA;
                2'b01: next_w_state = W_WAIT_ADDR;
                default: next_w_state = W_IDLE;
            endcase
        W_WAIT_ADDR:
            next_w_state = AWVALID ? W_ACTIVE : W_WAIT_ADDR;
        W_WAIT_DATA:
            next_w_state = WVALID ? W_ACTIVE : W_WAIT_DATA;
        W_ACTIVE:
            case({BVALID, BREADY})
                2'b11: next_w_state = W_IDLE;
                2'b10: next_w_state = W_WAIT_BREADY;
                default: next_w_state = W_ACTIVE;
            endcase
        W_WAIT_BREADY:
            next_w_state = BREADY ? W_IDLE : W_WAIT_BREADY;
        default:
            next_w_state = W_IDLE;
    endcase
end

reg [31 : 0] waddr_buf;
reg [31 : 0] wdata_buf;
always_ff @(posedge clk) begin
    waddr_buf <= AWVALID & AWREADY ? AWADDR : waddr_buf;
    wdata_buf <= WVALID & WREADY ? WDATA : wdata_buf;
end

assign AWREADY = w_state == W_IDLE | w_state == W_WAIT_ADDR;
assign WREADY = w_state == W_IDLE | w_state == W_WAIT_DATA;
assign BVALID = w_state == W_ACTIVE | w_state == W_WAIT_BREADY;

always_ff @(posedge clk) begin
    if (w_state == W_ACTIVE) $display("%c", wdata_buf[7 : 0]);
end

assign BRESP = 2'b00;



endmodule
