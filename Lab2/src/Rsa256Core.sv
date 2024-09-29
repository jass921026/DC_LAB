module Rsa256Core 
#(
	parameter bitwidth = 256;
)
(
	input          			i_clk,
	input         			i_rst,
	input          			i_start,
	input  [bitwidth-1:0] 	i_a, // cipher text y
	input  [bitwidth-1:0] 	i_d, // private key
	input  [bitwidth-1:0] 	i_n,
	output [bitwidth-1:0] 	o_a_pow_d, // plain text x
	output         			o_finished
);

// Define States and Parameters

localparam S_IDLE = 2'd0; // Follow the FSM in PPT
localparam S_PREP = 2'd1;
localparam S_MONT = 2'd2;
localparam S_CALC = 2'd3;

// Define Variables

logic [2:0] 					state_w, 	state_r;
logic [$clog2(bitwidth)-1:0] 	iter_w, 	iter_r;
logic [bitwidth-1:0] 			t_w, 		t_r;
logic [bitwidth-1:0] 			m_w, 		m_r;

// wiring and instantiation

montgomery #(.bitwidth(bitwidth)) montgomery_inst (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(),
	.i_mdl(),
	.i_a(),
	.i_b(),
	.o_finished(),
	.o_result()
);

// Combintional Circuits

always_comb begin

	// Unconditional Assignments
	state_w = state_r;
	iter_w 	= iter_r;
	t_w 	= t_r;
	m_w 	= m_r;

	case (state_r)
		S_IDLE: begin
		end
		S_PREP: begin
		end
		S_MONT: begin
		end
		S_CALC: begin
		end
	endcase

end


// Sequential Circuits

always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		state_r 	<= S_IDLE;
		iter_r 		<= 0;
		t_r 		<= 0;
		m_r 		<= 1; // m = 1, plz check the montgomery algorithm
	end
	else begin
		state_r 	<= state_w;
		iter_r 		<= iter_w;
		t_r 		<= t_w;
		m_r 		<= m_w;
	end
	else begin

	end
end

endmodule


module montgomery
// use module_name #(.PARAM(PARAM)) instance_name ( ... ); 
// to instantiate a module with parameters to support variable bitwidth

// This module only perform the montgomery once !!!
#(
	parameter bitwidth = 256;
)
(
	input          			i_clk,
	input         			i_rst,
	input          			i_start,
	input  [bitwidth-1:0] 	i_mdl, 	// modulus
	input  [bitwidth-1:0] 	i_a, 	// multiplier
	input  [bitwidth-1:0] 	i_b,	// multiplicand
	output         			o_finished
	output [bitwidth-1:0] 	o_result
);

// Define States and Parameters

localparam S_IDLE = 2'd0;
localparam S_CALC = 2'd1;

// Define Variables
logic [$clog2(bitwidth)-1:0] 	iter_w, 	iter_r;
logic 							state_w, 	state_r;
logic [bitwidth:0] 				m_w, 		m_r; // m might have carry bit

// wiring
assign o_result = m_r[bitwidth-1:0];

// Combintional Circuits
always_comb begin

	// Unconditional Assignments  
	state_w = state_r;
	iter_w 	= iter_r;
	m_w 	= m_r;

	case (state_r)
		S_IDLE: begin
		end
		S_CALC: begin
		end
	endcase
end

// Sequential Circuits
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		iter_r 		<= 0;
		state_r 	<= S_IDLE;
		m_r 		<= 0;
	end
	else begin
		iter_r 		<= iter_w;
		state_r 	<= state_w;
		m_r 		<= m_w;
	end
end	

endmodule
	
