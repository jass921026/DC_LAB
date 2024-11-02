module AudDSP(
    input       i_rst_n,
    input       i_clk,
    input       i_start,
    input       i_pause,
    input       i_stop,
    input [2:0] i_speed, // 0 to 2 for slow, 3 is normal, 4 to 6 for fast
    input       i_interpolation_mode, // o for constant, 1 for linear
    input       i_daclrck, // 0 for left channel, 1 for right channel, we use 0
    input [15:0] i_sram_data,
    output[15:0] o_dac_data,
    output[19:0] o_sram_addr //1M bytes * 16 bits
);

logic [19:0] addr_r, addr_w;
logic [ 2:0] state_r, state_w;
logic        prev_daclrck_r, prev_daclrck_w;
logic [15:0] out_data_r, out_data_w;
logic [15:0] prev_data_r, prev_data_w;
logic [2:0] interpolation_counter_r, interpolation_counter_w;

parameter S_IDLE      = 0;
parameter S_PAUSE     = 1;
parameter S_PLAY      = 2;

assign o_sram_addr = addr_r;
assign o_dac_data = out_data_r;

always_comb begin
    // work at dac clock change

    // unconditional assignments
    state_w = state_r;
    addr_w  = addr_r;
    prev_daclrck_w = prev_daclrck_r;
    prev_data_w = prev_data_r;
    out_data_w = out_data_r;
    interpolation_counter_w = interpolation_counter_r;


    case (state_r)
        S_IDLE: begin
            if (i_start) begin
                state_w <= S_PLAY;
                if (i_speed <3) addr_w = 1<<(-i_speed+3);
                else addr_w = 0;
            end
        end
        S_PAUSE: begin
            if (!i_pause) begin
                state_w <= S_PLAY;
            end
        end
        S_PLAY: begin
            if (i_pause) begin
                state_w <= S_PAUSE;
            end
            if (i_stop) begin
                state_w <= S_IDLE;
            end
            // work at daclrck change to left (0)
            if (prev_daclrck_r && !i_daclrck) begin
                if (i_speed >= 3) begin //no interpolation
                    addr_w = addr_r + 1<<(i_speed-3);
                    out_data_w = prev_data_r;
                end
                else begin //slow down
                    if (interpolation_counter_r == 1<<(-i_speed+3)-1) begin
                        interpolation_counter_w = 0;
                        addr_w = addr_r + 1 ;
                        prev_data_w = i_sram_data;
                    end
                    else begin
                        interpolation_counter_w = interpolation_counter_r + 1;
                    end
                    out_data_w = prev_data_r + (i_sram_data - prev_data_r) * interpolation_counter_r / (1<<(-i_speed+3));
                end
            end

        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        prev_data_r <= i_sram_data ;
        prev_daclrck_r <= i_daclrck;
        interpolation_counter_r <= 0;
        state_r <= S_IDLE;
        addr_r <= 0;
        out_data_r <= 0;
    end
    else begin
        prev_data_r <= prev_data_w;
        prev_daclrck_r <= prev_daclrck_w;
        interpolation_counter_r <= interpolation_counter_w;
        state_r <= state_w;
        addr_r <= addr_w;
        out_data_r <= out_data_w;
    end
end

endmodule