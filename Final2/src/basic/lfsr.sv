module LFSR // Linear feedback shift register
(
	input  i_clk,
	input  i_rst_n,
	output [8:0] o_random_out,
	output [8:0] o_random_out2
);

logic [31:0] random_w,random_r;

// ===== Output Assignments =====
assign o_random_out = {random_r[27],random_r[5],random_r[19],random_r[24],random_r[30],random_r[31],random_r[29],random_r[11],random_r[8]};
assign o_random_out2 = {random_r[4],random_r[7],random_r[2],random_r[9],random_r[13],random_r[23],random_r[26],random_r[16],random_r[15]};

always_comb begin	
	random_w = {random_r[30:0],random_r[3]^random_r[8]^random_r[11]^random_r[15]^random_r[18]^random_r[24]^random_r[29]};
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (random_r == 32'0) begin
		random_r 	<= 32'h5CA77A5C; //Magic Number
	end
	else begin
		random_r 	<= random_w;
	end
end
endmodule