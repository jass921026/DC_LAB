`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;
	localparam[127:0] tbdata = 128'hf0e1d2c3b4a59687f0e1d2c3b4a59687;

	logic clk, rst, pause, stop, lrc;
	initial clk = 0;
	initial lrc = 0;
	always #HCLK clk = ~clk;
	always #(32*CLK) lrc = ~lrc;
	logic data, start;
	logic [19:0] o_addr;
	logic [15:0] dac_data,recorder_data;

	AudRecorder rec0(
		.i_rst_n(rst), 
		.i_clk(clk),
		.i_lrc(lrc),
		.i_start(start),
		.i_pause(pause),
		.i_stop(stop),
		.i_data(data),
		.o_address(o_addr),
		.o_data(recorder_data)
	);
	AudPlayer player0(
		.i_rst_n(rst),
		.i_bclk(clk),
		.i_daclrck(lrc),
		.i_en(1'b1), // enable AudPlayer only when playing audio, work with AudDSP
		.i_dac_data(dac_data), //dac_data
		.o_aud_dacdat(data)
	);

	initial begin
		$fsdbDumpfile("I2S.fsdb");
		$fsdbDumpvars;
		rst = 0;
		#(2*CLK)
		rst = 1;
		for (int i = 0; i < 8; i++) begin
			@(posedge lrc);
			dac_data=tbdata[127-i*16 -: 16];
			if(i==0)begin
				start=1;
				#(2*CLK)
				start=0;
			end
			if(i==3)begin
				pause=1;
				#(2*CLK)
				pause=0;
			end
			if(i==4)begin
				start=1;
				#(2*CLK)
				start=0;
			end
			if(i==5)begin
				stop=1;
				#(2*CLK)
				stop=0;
			end
			if(i==6)begin
				start=1;
				#(2*CLK)
				start=0;
			end
		end
		$finish;
	end

	initial begin
		#(500000*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
