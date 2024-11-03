`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;
	//logic [127:0] tbdata = 128'hf0e1d2c3b4a59687f0e1d2c3b4a59687;
	logic [127:0] tbdata = 128'h11111111111111111111111111111111; //for test
	logic [127:0] collect_data;


	logic clk, rst, pause, stop, lrc;
	always #HCLK clk = ~clk;
	always #(36*CLK) lrc = ~lrc;
	logic dac_data, start;
	logic [19:0] o_addr;
	logic [15:0] play_data,recorder_data;

	AudRecorder rec0(
		.i_rst_n(rst), 
		.i_clk(clk),
		.i_daclrck(lrc),
		.i_start(start),
		.i_pause(pause),
		.i_stop(stop),
		.i_data(dac_data), // player output is the input of recorder
		.o_address(o_addr),
		.o_data(recorder_data)
	);
	AudPlayer player0(
		.i_rst_n(rst),
		.i_bclk(clk),
		.i_daclrck(lrc),
		.i_en(1'b1), // enable AudPlayer only when playing audio, work with AudDSP
		.i_dac_data(play_data), //dac_data
		.o_aud_dacdat(dac_data)
	);

	initial begin
		$fsdbDumpfile("I2S.fsdb");
		$fsdbDumpvars;
		clk = 0; 
		rst = 1; 
		start = 0;
		pause = 0; 
		stop = 0; 
		lrc = 0;

		rst = 0;
		#(2*CLK)
		rst = 1;

		start=0;
		#(2*CLK)
		start=1;
		

		for (int i = 0; i < 8; i++) begin
			play_data=tbdata[127-i*16 -: 16];
			@(posedge lrc);
			// if(i==1)begin
			// 	pause=1;
			// 	#(2*CLK)
			// 	pause=0;
			// end
			// if(i==3)begin
			// 	stop=1;
			// 	#(2*CLK)
			// 	stop=0;
			// end
			// if(i==4)begin
			// 	start=1;
			// 	#(2*CLK)
			// 	start=0;
			// end
			collect_data[127-i*16 -: 16] = recorder_data;
		end
		// display the both data
		for (logic[3:0] i = 0; i < 8; i++) begin
			$display("tb_data     [%d] = %b\ncollect_data[%d] = %b\n", i, tbdata[127-i*16 -: 16], i, collect_data[127-i*16 -: 16]);
		end

		$finish;
	end

	initial begin
		#(500000*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
