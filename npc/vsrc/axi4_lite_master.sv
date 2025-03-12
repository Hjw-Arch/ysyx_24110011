module axi4_lite_master (
    // Global Signals
    input clk,
    input rst,

    // User Signals
    input  wen,
    input  ren,
    input  user_ready,
    input  [3 : 0] wmask,
    input  [31 : 0] waddr,
    input  [31 : 0] wdata,
    input  [31 : 0] raddr,
    output [31 : 0] rdata,
    output [1 : 0] rresp,
    output [1 : 0] wresp,
    output done,

    // READ ADDRESS CHANNEL
    output [31 : 0] ARADDR,
    output ARVALID,
    input  ARREADY,

    // READ DATA CHANNEL
    input  [31 : 0] RDATA,
    input  [1 : 0] RRESP,
    input  RVALID,
    output RREADY,

    // WRITE ADDRESS CHANNEL
    output [31 : 0] AWADDR,
    output AWVALID,
    input  AWREADY,

    // WRITE DATA CHANNEL
    output [31 : 0] WDATA,
    output [3 : 0] WSTRB,
    output WVALID,
    input  WREADY,

    // BRESP CHANNEL
    input  [1 : 0] BRESP,
    input  BVALID,
    output BREADY
);

typedef enum logic { 
    R_IDLE,
    R_WAIT_RDATA
} r_state_t;

typedef enum logic [3 : 0] { 
    W_IDLE,
    W_WAIT_AWREADY,
    W_WAIT_WREADY,
    W_WAIT_BRESP
} w_state_t;

r_state_t r_state, next_r_state;
w_state_t w_state, next_w_state;

always_ff @(posedge clk) begin
    r_state <= rst ? R_IDLE : next_r_state;    
end

always_comb begin
    case(r_state)
        R_IDLE:
            next_r_state = ARVALID & ARREADY ? R_WAIT_RDATA : R_IDLE;
        R_WAIT_RDATA:
            next_r_state = RVALID & RREADY ? R_IDLE : R_WAIT_RDATA;
        default: 
            next_r_state = R_IDLE;
    endcase
end

assign ARADDR = raddr;
assign rdata = RDATA;
assign rresp = RRESP;

assign ARVALID = r_state == R_IDLE & ren;
assign RREADY = r_state == R_WAIT_RDATA & user_ready;



// 写通道
always_ff @(posedge clk) begin
    w_state <= rst ? W_IDLE : next_w_state;    
end

always_comb begin
    case(w_state)
        W_IDLE:
            case({AWVALID & WVALID, AWREADY, WREADY})
                3'b111: next_w_state = W_WAIT_BRESP;
                3'b110: next_w_state = W_WAIT_WREADY;
                3'b101: next_w_state = W_WAIT_AWREADY;
                default: next_w_state = W_IDLE;
            endcase
        W_WAIT_AWREADY:
            next_w_state = AWREADY ? W_WAIT_BRESP : W_WAIT_AWREADY;
        W_WAIT_WREADY:
            next_w_state = WREADY ? W_WAIT_BRESP : W_WAIT_WREADY;
        W_WAIT_BRESP:
            next_w_state = BVALID & BREADY ? W_IDLE : W_WAIT_BRESP;
        default: 
            next_w_state = W_IDLE;
    endcase
end

assign AWADDR = waddr;
assign WDATA = wdata;
assign WSTRB = wmask;
assign wresp = BRESP;

assign AWVALID = w_state == W_IDLE & wen | w_state == W_WAIT_AWREADY;
assign WVALID = w_state == W_IDLE & wen | w_state == W_WAIT_WREADY;
assign BREADY = w_state == W_WAIT_BRESP & user_ready;

// 这里可能需要修改，根据user的需要，可能需要修改成rdone和wdone
assign done = RVALID & RREADY | BVALID & BREADY;    // 其实是will done

endmodule
