module Rsa256Wrapper 
// and decoder for the RSA
#(
    parameter bitwidth = 256
)
(
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Define States and Parameters
localparam S_GET_KEY_N = 0; 
localparam S_GET_KEY_D = 1;
localparam S_GET_DATA  = 2;
localparam S_REQ_CALC  = 3;
localparam S_WAIT_CALC = 4;
localparam S_SEND_DATA = 5;

// Define Variables

// datas
logic [bitwidth-1:0] n_r, n_w; // the public n 
logic [bitwidth-1:0] d_r, d_w; // the private key
logic [bitwidth-1:0] enc_r, enc_w; // the cipher text
logic [bitwidth-1:0] dec_r, dec_w; // the plain text

// states
logic [2:0] state_r, state_w; // finite state machine
logic [$clog2(bitwidth)-4:0] byte_cnt_r, byte_cnt_w; // count current IO byte

// io 

logic [4:0] avm_address_r, avm_address_w; // address access register
logic avm_read_r, avm_read_w; // indicate this model is reading
logic avm_write_r, avm_write_w; // indicate this model is writing

// RSA core
logic rsa_start_r, rsa_start_w;
logic rsa_finished;
logic [bitwidth-1:0] rsa_dec;

assign avm_address      = avm_address_r;
assign avm_read         = avm_read_r;
assign avm_write        = avm_write_r;
assign avm_writedata    = dec_r[bitwidth-9 -:8]; //the only thing to write is plain text

Rsa256Core #(.bitwidth(256)) rsa256_core(
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_a(enc_r),
    .i_d(d_r),
    .i_n(n_r),
    .o_a_pow_d(rsa_dec),
    .o_finished(rsa_finished)
);

task Reading;
    begin
        avm_read_w      = 1;
        avm_write_w     = 0;
    end
endtask
task Writing;
    begin
        avm_read_w      = 0;
        avm_write_w     = 1;
    end
endtask

always_comb begin
    // Unconditional Assignments
    n_w             = n_r;
    d_w             = d_r;
    enc_w           = enc_r;
    dec_w           = dec_r;
    avm_read_w      = avm_read_r;   
    avm_write_w     = avm_write_r;
    byte_cnt_w      = byte_cnt_r;
    rsa_start_w     = rsa_start_r;
    avm_address_w   = avm_address_r;
    state_w         = state_r;

    case (state_r)
        S_GET_KEY_N: begin
            Reading();
            if (!avm_waitrequest) begin
                if (avm_address_r == STATUS_BASE && avm_readdata[RX_OK_BIT]) begin
                    avm_address_w = RX_BASE;
                end
                if (avm_address_r == RX_BASE) begin
                    avm_address_w = STATUS_BASE;
                    n_w[7:0] = avm_readdata[7:0];
                    n_w[bitwidth-1 : 8] = n_r[bitwidth-9 : 0]; // shift left 8 bits
                    if (byte_cnt_r == bitwidth/8 -1) begin
                        // read finished
                        byte_cnt_w = 0;
                        state_w = S_GET_KEY_D;
                    end
                    else begin
                        byte_cnt_w = byte_cnt_r + 1;
                    end
                end
            end
        end
        S_GET_KEY_D: begin
            Reading();
            if (!avm_waitrequest) begin
                if (avm_address_r == STATUS_BASE && avm_readdata[RX_OK_BIT]) begin
                    avm_address_w = RX_BASE;
                end
                if (avm_address_r == RX_BASE) begin
                    avm_address_w = STATUS_BASE;
                    d_w[7:0] = avm_readdata[7:0];
                    d_w[bitwidth-1 : 8] = d_r[bitwidth-9 : 0]; // shift left 8 bits
                    if (byte_cnt_r == bitwidth/8 -1) begin
                        // read finished
                        byte_cnt_w = 0;
                        state_w = S_GET_DATA;
                    end
                    else begin
                        byte_cnt_w = byte_cnt_r + 1;
                    end
                end
            end
        end
        S_GET_DATA: begin
            Reading();
            if (!avm_waitrequest) begin
                if (avm_address_r == STATUS_BASE && avm_readdata[RX_OK_BIT]) begin
                    avm_address_w = RX_BASE;
                end
                if (avm_address_r == RX_BASE) begin
                    avm_address_w = STATUS_BASE;
                    enc_w[7:0] = avm_readdata[7:0];
                    enc_w[bitwidth-1 : 8] = enc_r[bitwidth-9 : 0]; // shift left 8 bits
                    if (byte_cnt_r == bitwidth/8 -1) begin
                        // read finished
                        byte_cnt_w = 0;
                        state_w = S_REQ_CALC;
                    end
                    else begin
                        byte_cnt_w = byte_cnt_r + 1;
                    end
                end
            end
        end
        S_REQ_CALC: begin
            rsa_start_w = 1;
            state_w = S_WAIT_CALC;
        end
        S_WAIT_CALC: begin
            if (rsa_finished) begin
                dec_w = rsa_dec;
                state_w = S_SEND_DATA;
            end
        end
        S_SEND_DATA: begin
            //after finish, loop back to get data
            Reading();
            if (!avm_waitrequest) begin
                if (avm_address_r == STATUS_BASE && avm_readdata[TX_OK_BIT]) begin
                    avm_address_w = TX_BASE;
                    Writing();
                end
                if (avm_address_r == TX_BASE) begin
                    Reading();
                    dec_w[bitwidth-1 : 8] = dec_r[bitwidth-9 : 0]; // shift left 8 bits
                    if (byte_cnt_r == bitwidth/8 -2) begin // only 31 bytes are required
                        // write finished
                        byte_cnt_w = 0;
                        state_w = S_GET_DATA;
                    end
                    else begin
                        byte_cnt_w = byte_cnt_r + 1;
                    end
                end
            end
        end
    endcase
end

always_ff @(posedge avm_clk or posedge avm_rst) begin
    // reset
    if (avm_rst) begin
        n_r             <= 0;
        d_r             <= 0;
        enc_r           <= 0;
        dec_r           <= 0;
        avm_read_r      <= 0;
        avm_write_r     <= 0;
        byte_cnt_r      <= 0;
        rsa_start_r     <= 0;
        avm_address_r   <= STATUS_BASE;
        state_r         <= S_GET_KEY_N;
    end 
    else begin
        n_r             <= n_w;
        d_r             <= d_w;
        enc_r           <= enc_w;
        dec_r           <= dec_w;
        avm_read_r      <= avm_read_w;
        avm_write_r     <= avm_write_w;
        byte_cnt_r      <= byte_cnt_w;
        rsa_start_r     <= rsa_start_w;
        avm_address_r   <= avm_address_w;
        state_r         <= state_w;
    end
end
endmodule
