module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

parameter S_IDLE = 1'b0;
parameter S_PROC = 1'b1;

logic 			state_r, 		state_w;		//Finite State Machine
logic [15:0] 	random_number; 					//catch the output of LFSR
logic [3:0] 	o_random_out_r, o_random_out_w;	//Stored Random Variable
logic [3:0] 	last_random_r, 	last_random_w;	//Last Random Variable
logic [10:0] 	clk_50hz_r, 	clk_50hz_w; 	//a slower clock runs at 50hz
logic [19:0] 	accumulator_r, 	accumulator_w; 	//50hz clock internal variable
logic [4:0]		rnd_gen_cnt_r, 	rnd_gen_cnt_w; 	//count how many times the random number is generated
int rnd_gen_cnt_wait[35] = '{7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,9,10,11,12,14,16,18,20,23,26,30,35,40,50,50,50,50,50};

lfsr lfsr_inst (
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_random_out(random_number)
);

assign o_random_out = o_random_out_r;

always_comb begin
	// Default Values
	state_w        	= state_r;
	o_random_out_w 	= o_random_out_r;
	last_random_w	= last_random_r;
	clk_50hz_w 		= clk_50hz_r;
	accumulator_w 	= accumulator_r + 1;
	rnd_gen_cnt_w 	= rnd_gen_cnt_r;

	// FSM
	case(state_r)
	S_IDLE: begin //idle
		if (i_start) begin
			state_w = S_PROC; //before enter the proc state, run the first time
			o_random_out_w 	= random_number[3:0];
			last_random_w  	= o_random_out_r;
			rnd_gen_cnt_w 	= 5'd0;
		end
	end

	S_PROC: begin //running
		if (rnd_gen_cnt_r >= 5'd25) begin
			state_w = S_IDLE;
		end
		else begin
			if (clk_50hz_r >= rnd_gen_cnt_wait[rnd_gen_cnt_r]) begin
				o_random_out_w 	= random_number[3:0];
				last_random_w 	= o_random_out_r;
				clk_50hz_w 		= 11'd0;
				rnd_gen_cnt_w 	= rnd_gen_cnt_r + 1;
			end
			else begin
				if (accumulator_r == 20'd0) begin
					clk_50hz_w = clk_50hz_r + 1;
					if (last_random_r == o_random_out_r) begin
						o_random_out_w 	= random_number[3:0];
						last_random_w  	= o_random_out_r;
					end
				end
			end
		end
	end
	endcase
end


// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		state_r        	<= S_IDLE;
		o_random_out_r 	<= 4'd0;
		last_random_r 	<= 4'd0;
		clk_50hz_r 		<= 11'd0;
		accumulator_r 	<= 20'd0;
		rnd_gen_cnt_r 	<= 5'd0;
	end
	else begin
		state_r        	<= state_w;
		o_random_out_r 	<= o_random_out_w;
		last_random_r 	<= last_random_w;
		clk_50hz_r 		<= clk_50hz_w;
		accumulator_r 	<= accumulator_w;
		rnd_gen_cnt_r 	<= rnd_gen_cnt_w;
	end
end

endmodule

module lfsr // Linear feedback shift register
#(
	parameter WIDTH = 16
)
(
	input  i_clk,
	input  i_rst_n,
	output [WIDTH-1:0] o_random_out
);

logic [WIDTH-1:0] random_w,random_r;

// ===== Output Assignments =====
assign o_random_out = random_r;

always_comb begin	
	random_w = {random_r[14:0],random_r[3]^random_r[8]^random_r[11]^random_r[15]};
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		random_r 	<= 16'h5CA7; //Magic Number
	end
	else begin
		random_r 	<= random_w;
	end
end
endmodule
