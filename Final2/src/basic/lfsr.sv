module LFSR // Linear feedback shift register
(
	input  i_clk,
	input  i_rst_n,
	output [7:0] o_random_out,
	output [7:0] o_random_out2
);

logic [31:0] random_w,random_r;
logic [7:0] random_out, random_out2;

// ===== Output Assignments =====
assign random_out = {random_r[27],random_r[5],random_r[19],random_r[24],random_r[30],random_r[31],random_r[29],random_r[11],random_r[8]};
assign random_out2 = {random_r[4],random_r[7],random_r[2],random_r[9],random_r[13],random_r[23],random_r[26],random_r[16],random_r[15]};
assign o_random_out = (random_out > 8'd228) ? random_out - 8'd28 : random_out;
assign o_random_out2 = (random_out2 > 8'd228) ? random_out2 - 8'd28 : random_out2;

always_comb begin	
	if (random_r == 32'b0) begin
		random_w = 32'h5CA77A5C;
	end
	else begin
		random_w = {random_r[30:0],random_r[3]^random_r[8]^random_r[11]^random_r[15]^random_r[18]^random_r[24]^random_r[29]};
	end
end
// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (~i_rst_n) begin
		;
		//random_r 	<= 32'h5CA77A5C; //Magic Number
	end
	else begin
		random_r 	<= random_w;
	end
end
endmodule