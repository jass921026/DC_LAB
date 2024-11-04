module Top (
	input i_rst_n,
	input i_clk,

	// btns & switch
	input i_stop, // Stop
	input i_start, // Start
	input i_pause, // Pause

	// switch
	input [3:0] i_dsp_speed, // for speed

	input i_dsp_fast, // Fast Enable
	input i_dsp_interpolation, // Interpolation Enable
	input i_play_enable, // Play Enable
	
	
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	output [3:0] o_record_time,
	output [3:0] o_play_time

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr
);

// design the FSM and states as you like
parameter S_I2C  = 0;
parameter S_RECD = 1;
parameter S_PLAY = 2;

logic [2:0] state_r, state_w;


logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;


logic i2c_start, i2c_finished, i2c_ack,i2c_oen, i2c_sdat;

logic play_mode;
logic dsp_start, dsp_pause, dsp_stop;
logic rec_start, rec_pause, rec_stop;
logic play_en;
logic [3:0] acktimes_w,acktimes_r;
logic [3:0] second_rec,second_play;
logic [3:0] startcnt_w,startcnt_r;

assign o_play_time = startcnt_r;
assign o_record_time = second_rec;

assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play;
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r == S_PLAY) ? io_SRAM_DQ : 16'd0; // sram_dq as input

// SRAM control signals
assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

assign i2c_start = (state_r == S_I2C);
assign i2c_ack = i2c_oen ? 1 : io_I2C_SDAT;
assign play_en = (state_r == S_PLAY);

assign dsp_start = (state_r == S_PLAY) && (i_start);
assign dsp_pause = (state_r == S_PLAY) && (i_pause);
assign dsp_stop = ((state_r == S_PLAY) && i_stop) || (state_r == S_RECD) ;

assign rec_start = (state_r == S_RECD) && (i_start);
assign rec_pause = (state_r == S_RECD) && (i_pause);
assign rec_stop = ((state_r == S_RECD) && i_stop) || (state_r == S_PLAY);
assign acktimes_w = (!i2c_ack) ? acktimes_r + 1 : acktimes_r;
assign startcnt_w = ((state_r == S_RECD) && (i_start))?(startcnt_r+1):startcnt_r;

// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_ack(i2c_ack),
	.i_start(i2c_start),
	.o_finished(i2c_finished),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(dsp_start),
	.i_pause(dsp_pause),
	.i_stop(dsp_stop),
	.i_speed(i_dsp_speed),
	.i_fast(i_dsp_fast),
	.i_interpolation(dsp_interpolation),
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(play_en), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT),
	.o_second(second_play)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_daclrck(i_AUD_ADCLRCK),
	.i_start(rec_start),
	.i_pause(rec_pause),
	.i_stop(rec_stop),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record),
	.o_second(second_rec)
);

always_comb begin
	// design your control here
	state_w = state_r;
	case (state_r)
		S_I2C: begin
			if (i2c_finished) begin
				if (i_play_enable) state_w = S_PLAY;
				else state_w = S_RECD;	
			end
		end
		S_RECD: begin
			if (i_play_enable) state_w = S_PLAY;
			else state_w = S_RECD;	
		end
		S_PLAY: begin
			if (i_play_enable) state_w = S_PLAY;
			else state_w = S_RECD;	
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_I2C;
		acktimes_r <= 0;
		startcnt_r <= 0;
	end
	else begin
		state_r <= state_w;
		acktimes_r <= acktimes_w;
		startcnt_r <= startcnt_w;
	end
end

endmodule
