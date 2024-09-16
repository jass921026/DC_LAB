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

// please check out the working example in lab1 README (or Top_exmaple.sv) first
always_comb begin

	initial begin
		timer_w = 20'd0;
		count_w = 5'd0;
		waiter_w = 11'd0;
	end
	timer_w = timer_r + 1;
	// FSM
	case(state_r)
	S_IDLE: begin /idle
		if (i_start) begin
			state_w = S_PROC;
			o_random_out_w = 4'd15;
		end
	end

	default: begin //running
		if (i_start) begin
			state_w 		= (o_random_out_r == 4'd10) ? S_IDLE : state_w;
			o_random_out_w 	= (o_random_out_r == 4'd10) ? 4'd1 : (o_random_out_r - 4'd1);
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