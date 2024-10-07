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

localparam S_IDLE 	= 3'd0;
localparam S_CALC 	= 3'd1;
localparam S_MONT1	= 3'd2;
localparam S_LSHIFT	= 3'd3;
localparam S_MONT2	= 3'd4;

// Define Variables

logic [2:0] 					state_w, 	state_r;
logic [$clog2(bitwidth):0]	 	iter_w, 	iter_r;
logic [bitwidth-1:0] 			t_w, 		t_r;
logic [bitwidth-1:0] 			m_w, 		m_r;
logic							finished_w,	finished_r;
logic							montfin;
logic							montstart;
logic [bitwidth-1:0]			mont_a,		mont_b;
logic [bitwidth-1:0]			mont_result;

// wiring and instantiation

montgomery #(.bitwidth(bitwidth)) montgomery_inst (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(montstart),
	.i_mdl(i_n),
	.i_a(mont_a),
	.i_b(mont_b),
	.o_finished(montfin),
	.o_result(mont_result)
);

// Combintional Circuits

always_comb begin

	// Unconditional Assignments
	state_w = state_r;
	iter_w 	= iter_r;
	t_w 	= t_r;
	m_w 	= m_r;
	finished_w = finished_r;

	case (state_r)
		S_IDLE: begin
			if (i_start) begin//before enter the lshift state, run the first time
				state_w = S_LSHIFT;
				iter_w	= 0;
				t_w		= i_a;
				m_w		= 1;
			end
		end
		S_LSHIFT: begin
			if (iter_r == bitwidth) begin
				state_w	= S_CALC;
				iter_w	= 0;
			end
			else begin
				t_w		= ((t_r<<1)<i_n)?(t_r<<1):((t_r<<1)-i_n);
				iter_w	= iter_r+1;
			end
		end
		S_CALC: begin
			if (iter_r	== bitwidth) begin
				state_w		= S_IDLE;
				finished_w	= 1;
				o_a_pow_d	= m_r;
				iter_w		= 0;
			end
			else begin
				if (i_d[iter_r] == 1) begin
					state_w		= S_MONT1;
					mont_a		= m_r;
					mont_b		= t_r;
					montstart	= 1;
				end
				else begin
					state_w	= S_MONT2;
					mont_a	= t_r;
					mont_b	= t_r;					
				end
			end
		end
		S_MONT1: begin
			if(montfin==1) begin
				m_w		= mont_result;
				state_w	= S_MONT2;
				mont_a	= t_r;
				mont_b	= t_r;
			end
		end
		S_MONT2: begin
			if(montfin==1) begin
				t_w		= mont_result;
				state_w	= S_CALC;
			end
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
		finished_r	<= 0;
	end
	else begin
		state_r 	<= state_w;
		iter_r 		<= iter_w;
		t_r 		<= t_w;
		m_r 		<= m_w;
		finished_r	<= finished_w;
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
logic [$clog2(bitwidth):0]	 	iter_w, 	iter_r;
logic 							state_w, 	state_r;
logic [bitwidth:0] 				m_w, 		m_r; // m might have carry bit
logic [bitwidth+1:0]			m1;
logic [bitwidth+1:0]			m2;
logic							finished_w,	finished_r;

// wiring
assign o_result 	= 	m_r[bitwidth-1:0];
assign o_finished	=	finished_r;

// Combintional Circuits
always_comb begin

	// Unconditional Assignments  
	state_w 	= state_r;
	iter_w 		= iter_r;
	m_w 		= m_r;
	finished_w	= finished_r;
	case (state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w 	=	S_CALC;
				iter_w		=	0;
				m_w			=	0;
				finished_w	=	1'b0;
			end
		end
		S_CALC: begin
			if ( iter_r < bitwidth) begin
				if ( i_a[iter_r]) begin
					m1	=	m_r+i_b;
				end
				else begin
					m1	=	m_r;
				end
				if ( m1[0]) begin
					m2	=	m1+i_mdl;
				end
				else begin
					m2	=	m1;
				end
				m_w		=	m2>>1;
				iter_w	=	iter_r+1;
			end
			else begin
				if ( m_r>=i_mdl) begin
					m_w		=	m_r-i_mdl;
				end
				finished_w	=	1'b1;
				state_w		=	S_IDLE;
			end
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
		finished_r	<= 1'b0;
	end
	else begin
		iter_r 		<= iter_w;
		state_r 	<= state_w;
		m_r 		<= m_w;
		finished_r	<= finished_w;
	end
end	

endmodule
	
