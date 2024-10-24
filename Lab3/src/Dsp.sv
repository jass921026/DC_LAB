module AudDSP(
    input       i_rst_n,
    input       i_clk,
    input       i_start,
    input       i_pause,
    input       i_stop,
    input [3:0] i_speed, // 0 to 2 for slow, 3 is normal, 4 to 6 for fast
    input       i_interpolation_mode, // o for constant, 1 for linear
    input       i_daclrck,
    input [15:0] i_sram_data,
    output[15:0] o_dac_data,
    output[19:0] o_sram_addr
);

always_comb begin
    // design your control here
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        
    end
    else begin
        
    end
end

endmodule