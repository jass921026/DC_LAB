module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

parameter S_IDLE = 1'b0;
parameter S_PROC = 1'b1;

logic [3:0] o_random_out_r, o_random_out_w;
logic state_r, state_w;
logic [19:0] timer_r, timer_w; //create a 50hz clock
logic [4:0]	count_r, count_w; //count how many times the random number is generated
logic [10:0] waiter_r, waiter_w; //waiter for the random number to be generated
logic [15:0] random_number; //random number generated

lfsr lfsr_inst (
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_random_out(random_number)
);

// please check out the working example in lab1 README (or Top_exmaple.sv) first
always_comb begin

	// Default Values
	o_random_out_w 	= o_random_out_r;
	state_w        	= state_r;
	waiter_w 		= waiter_r;
	count_w 		= count_r;
	timer_w 		= timer_r + 1;

	// 50hz clock
	if (timer_r == 20'd0) begin
		count_w 	= count_r + 1;
	end

	// FSM
	case(state_r)
	S_IDLE: begin //idle
		o_random_out_w = 4'd00;
		if (i_start) begin
			state_w = S_PROC;
			count_w = 5'd1;
			o_random_out_w = random_number[3:0];
		end
	end

	S_PROC: begin //running
		if (count_r == 5'd25) begin
			state_w = S_IDLE;
		end
		else begin
			if (waiter_r >= count_r**2) begin
				o_random_out_w = random_number[3:0];
				waiter_w = 11'd0;
				count_w = count_r + 1;
			end
			else begin
				waiter_w = waiter_r + 1;
			end
		end
	end

	endcase
end


// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		o_random_out_r 	<= 4'd0;
		state_r        	<= S_IDLE;
		timer_r 		<= 20'd0;
		count_r 		<= 5'd0;
		waiter_r 		<= 11'd0;
	end
	else begin
		o_random_out_r 	<= o_random_out_w;
		state_r        	<= state_w;
		timer_r 		<= timer_w;
		count_r 		<= count_w;
	end
end

endmodule

module lcg 
#(
	parameter WIDTH = 16,
)
(
	input  i_clk,
	input  i_rst_n,
	output [WIDTH-1:0] o_random_out
);
initial begin
	
end
endmodule