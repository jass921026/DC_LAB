module AudDSP(
    input       i_rst_n,
    input       i_clk,
    input       i_start,
    input       i_pause,
    input       i_stop,
    input       i_fast, // 1 for fast, 0 for slow
    input [3:0] i_speed, // i for i times fast/slow
    input       i_interpolation, // 0 for constant, 1 for linear
    input       i_daclrck, // 0 for left channel, 1 for right channel, we use 0
    input [15:0] i_sram_data,
    input [19:0] i_end_addr,
    output[15:0] o_dac_data,
    output[19:0] o_sram_addr //1M bytes * 16 bits
);

logic [19:0] addr_r, addr_w;
logic [ 2:0] state_r, state_w;
logic        prev_daclrck;
logic [15:0] out_data_r, out_data_w;
logic [15:0] prev_data_r, prev_data_w;
logic [15:0] pre_pre_data_r, pre_pre_data_w;
logic [3:0] interpolation_cnt_r, interpolation_cnt_w;

parameter S_IDLE      = 0;
parameter S_PAUSE     = 1;
parameter S_PLAY      = 2;
parameter S_BACKTRACK = 3;

assign o_sram_addr = addr_r;
assign o_dac_data = out_data_r;

function logic [15:0] frac_mul_16;
    input logic [15:0] value;
    input logic [3:0] frac;
    begin
        case (frac)
            4'b0000: frac_mul_16 = 16'hFFFF;
            4'b0001: frac_mul_16 = value;
            4'b0010: frac_mul_16 = {1'b0,value[15:1]};
            4'b0011: frac_mul_16 = (32'(value) * 16'h5555) >> 16;
            4'b0100: frac_mul_16 = value >> 2;
            4'b0101: frac_mul_16 = (32'(value) * 16'h3333) >> 16;
            4'b0110: frac_mul_16 = (32'(value) * 16'h2AAA) >> 16;
            4'b0111: frac_mul_16 = (32'(value) * 16'h2492) >> 16;
            4'b1000: frac_mul_16 = value >> 3;
            4'b1001: frac_mul_16 = (32'(value) * 16'h1C71) >> 16;
            4'b1010: frac_mul_16 = (32'(value) * 16'h1999) >> 16;
            4'b1011: frac_mul_16 = (32'(value) * 16'h1745) >> 16;
            4'b1100: frac_mul_16 = (32'(value) * 16'h1555) >> 16;
            4'b1101: frac_mul_16 = (32'(value) * 16'h13B1) >> 16;
            4'b1110: frac_mul_16 = (32'(value) * 16'h1249) >> 16;
            4'b1111: frac_mul_16 = (32'(value) * 16'h1111) >> 16;
        endcase
    end
endfunction


always_comb begin
    // work at dac clock change

    // unconditional assignments
    state_w = state_r;
    addr_w  = addr_r;
    prev_data_w = prev_data_r;
    out_data_w = out_data_r;
    interpolation_cnt_w = interpolation_cnt_r;
    pre_pre_data_w = pre_pre_data_r;

    // make backtrack is fast and interpolation
    case (state_r)
        S_IDLE: begin
            out_data_w = 0;
            if (i_fast && i_interpolation) // backtrack
                addr_w = i_end_addr;
            else addr_w = 0;

            if (i_start) begin //address must be 0
                if (i_fast && i_interpolation) begin // backtrack
                    addr_w = i_end_addr-i_speed ;
                    state_w = S_BACKTRACK;
                end
                else begin
                    prev_data_w = i_sram_data;
                    state_w = S_PLAY;
                    if (i_fast) addr_w = i_speed;
                    else addr_w = 1;
                end
            end
        end
        S_PAUSE: begin
            out_data_w = 0;
            if (i_stop) begin
                state_w <= S_IDLE;
                addr_w = 0;
            end
            else if (!i_pause) begin
                state_w <= S_PLAY;
            end
        end
        S_PLAY: begin
            if (i_pause) begin
                state_w <= S_PAUSE;
            end
            else if (i_stop) begin
                state_w <= S_IDLE;
                addr_w = 0;
            end
            else if (i_fast && i_interpolation) begin
                state_w <= S_BACKTRACK;
            end
            // work at daclrck change to left (0)
            else if (prev_daclrck && !i_daclrck) begin
                if (i_fast) begin //fast forward
                    addr_w = addr_r + i_speed;
                    out_data_w = prev_data_r;
                    prev_data_w = i_sram_data;
                end
                else begin //slow down
                    if (interpolation_cnt_r >= i_speed-1) begin
                        interpolation_cnt_w = 0;
                        addr_w = addr_r + 1'b1 ;
                        prev_data_w = i_sram_data;
                        pre_pre_data_w = prev_data_r;
                    end
                    else begin 
                        interpolation_cnt_w = interpolation_cnt_r + 1'b1;
                    end

                    // if (interpolation_cnt_r == 4'b0) begin
                        
                    // end


                    if (!i_interpolation) begin // no interpolation
                        out_data_w = prev_data_r;
                    end
                    else begin // linear interpolation
                        out_data_w = (frac_mul_16(.value(pre_pre_data_r),.frac(i_speed)) * (i_speed - interpolation_cnt_r ))  + (frac_mul_16(.value(prev_data_r),.frac(i_speed)) * (interpolation_cnt_r)) ;
                    end
                end
            end
        end
        S_BACKTRACK: begin
            if (i_pause) begin
                state_w <= S_PAUSE;
            end
            else if (i_stop) begin
                state_w <= S_IDLE;
                addr_w = 0;
            end
            else if (!(i_fast && i_interpolation)) begin
                state_w <= S_PLAY;
            end
            else if (prev_daclrck && !i_daclrck) begin //only fast exist
                addr_w = addr_r - i_speed;
                out_data_w = prev_data_r;
                prev_data_w = i_sram_data;
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        prev_data_r <= 0 ;
        pre_pre_data_r <= i_sram_data ;
        prev_daclrck <= i_daclrck;
        interpolation_cnt_r <= 0;
        state_r <= S_IDLE;
        addr_r <= 0;
        out_data_r <= 0;
    end
    else begin
        prev_data_r <= prev_data_w;
        pre_pre_data_r <= pre_pre_data_w;
        prev_daclrck <= i_daclrck;
        interpolation_cnt_r <= interpolation_cnt_w;
        state_r <= state_w;
        addr_r <= addr_w;
        out_data_r <= out_data_w;
    end
end

endmodule