`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;
	localparam[127:0] tbdata = 128'hf0e1d2c3b4a59687f0e1d2c3b4a59687;

	logic clk, rst, oen;
	initial clk = 0;
	always #HCLK clk = ~clk;
	logic sdat, sclk, start;

	I2cInitializer init0(
		.i_rst_n(~rst),
		.i_clk(clk),
		.i_start(start),
		.o_finished(finish),
		.o_sclk(sclk),
		.o_sdat(sdat),
		.o_oen(oen),
		.i_ack(oen)
	);

	initial begin
		$fsdbDumpfile("I2C.fsdb");
		$fsdbDumpvars;
		rst = 1;
		#(2*CLK)
		rst = 0;
		start = 1;
	end

	initial begin
		#(500000*CLK)
		$display("Automatic abort.");
		$finish;
	end

endmodule
