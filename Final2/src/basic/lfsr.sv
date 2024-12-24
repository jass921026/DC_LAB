module LFSR // Linear feedback shift register
(
	input  i_clk,
	input  i_rst_n,
	output [8:0] o_random_out
);

logic [31:0] random_w,random_r;

// ===== Output Assignments =====
assign o_random_out = {random_r[27],random_r[5],random_r[19],random_r[24],random_r[30],random_r[31],random_r[29],random_r[11],random_r[8]};

always_comb begin	
	random_w = {random_r[30:0],random_r[3]^random_r[8]^random_r[11]^random_r[15]^random_r[18]^random_r[24]^random_r[29]};
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		random_r 	<= 32'h5CA77A5C; //Magic Number
	end
	else begin
		random_r 	<= random_w;
	end
end
endmodule