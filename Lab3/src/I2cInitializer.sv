module I2cInitializer_su (
	input 	i_rst_n,
	input 	i_clk,
	input 	i_start,
	input 	i_ack,
	output 	o_finished,
	output 	o_sclk,
	output 	o_sdat,
	output 	o_oen
	//output[3:0] o_command_num,
	//output[3:0] o_state,
	//output	ack_light
);

logic [2:0] state, state_nxt;
logic [3:0] counter, counter_nxt; // the command sending to WM8731
logic [4:0] counter_cmd, counter_cmd_nxt; // count 24 bits for single command
logic [3:0] counter_ack, counter_ack_nxt; // count 8 bits for ack

logic o_sclk_reg, o_sclk_reg_nxt;
logic o_sdat_reg, o_sdat_reg_nxt;
logic o_finished_reg, o_finished_reg_nxt;
logic ack_light_reg, ack_light_reg_nxt;

parameter S_IDLE 	= 0;
parameter S_START = 1;
parameter S_WRITE	= 2;
parameter S_READ 	= 3;
parameter S_ACK 	= 4;
parameter S_STOP	= 5;

logic [23:0] command[0:10];
//logic [23:0] command[0:9];
/*
parameter bit [23:0] command[0:10] = {	24'h341E00,	// Reset
											24'h340097, // Left line in
											24'h340297, // Right line in
											24'h340479, // Left headphone out
											24'h340679, // Right headphone out
											24'h340815, // Analog audio path control
											24'h340A00, // Digital audio path control
											24'h340C00, // Power down control
											24'h340E42, // Digital audio interface format
											24'h341019, // Sampling control
											24'h341201	// Active control
};  
*/
assign o_sclk 		= o_sclk_reg;
assign o_sdat 		= o_sdat_reg;
assign o_oen		= (state == S_ACK || state == S_IDLE) ? 0 : 1;
assign o_finished = o_finished_reg;
assign o_command_num = counter;
assign o_state = counter_cmd[3:0];

assign ack_light = counter_cmd[4];

always_comb begin
	ack_light_reg_nxt = ack_light_reg;
	state_nxt = state;
	counter_nxt = counter;
	counter_cmd_nxt = counter_cmd;
	counter_ack_nxt = counter_ack;
	o_sclk_reg_nxt = o_sclk_reg;
	o_sdat_reg_nxt = o_sdat_reg;
	o_finished_reg_nxt = o_finished_reg;

	case (state)
	
	S_IDLE: begin
		if (i_start) begin
			o_sdat_reg_nxt = 0;
			state_nxt = S_START;
		end
	end
	
	S_START: begin
		if (o_sdat_reg) begin
			o_sdat_reg_nxt = 0;
		end
		else begin
			state_nxt = S_WRITE;
			o_sclk_reg_nxt = 0;
			o_sdat_reg_nxt = command[counter][counter_cmd]; // change data at falling edge !
		end
	end
		
	S_WRITE: begin
		o_sclk_reg_nxt = 1;
		state_nxt = S_READ;
		counter_ack_nxt = counter_ack + 1;
		if (counter_cmd == 0) begin
			counter_nxt = counter + 1;
			counter_cmd_nxt = 23;
		end
		else begin
			counter_cmd_nxt = counter_cmd - 1;
		end
		
	end
	
	S_READ: begin
		state_nxt = S_WRITE;
		o_sclk_reg_nxt = 0;
		if (counter_ack == 8) begin
			state_nxt = S_ACK;
			counter_ack_nxt = 0;
		end
		else begin
			o_sdat_reg_nxt = command[counter][counter_cmd]; // change data at falling edge !
		end
	end
	
	S_ACK: begin
		o_sclk_reg_nxt = !(o_sclk_reg);
		if(!i_ack && o_sclk_reg) begin
			if (counter_cmd == 23) begin // finish "one" command !
				state_nxt = S_STOP;
				o_sdat_reg_nxt = 0;
			end
			else begin
				state_nxt = S_WRITE;
				o_sdat_reg_nxt = command[counter][counter_cmd]; // change data at falling edge !
			end
		end
		
		if(!i_ack) begin
			ack_light_reg_nxt = 1;
		end
	end
	
	S_STOP: begin
		if (!o_sclk_reg) begin
			o_sclk_reg_nxt = 1;
		end
		else begin
			if (counter == 11) begin
				o_finished_reg_nxt = 1;
				state_nxt = S_IDLE;
			end
			else begin
				state_nxt = S_START;
			end
			o_sdat_reg_nxt = 1;
		end
	end
	endcase
	
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state				<= S_IDLE;
		counter 			<= 0;
		counter_cmd 	<= 23;
		counter_ack 	<= 0;
		o_sclk_reg 		<= 1;
		o_sdat_reg 		<= 1;
		
		command[0] 		<= 24'h341E00;	// Reset
		command[1] 		<= 24'h340097;	// Left line in
		command[2] 		<= 24'h340297; // Right line in
		command[3] 		<= 24'h340479; // Left headphone out
		command[4] 		<= 24'h340679; // Right headphone out
		command[5] 		<= 24'h340815; // Analog audio path control
		command[6] 		<= 24'h340A00; // Digital audio path control
		command[7] 		<= 24'h340C00; // Power down control
		//command[7] 		<= 24'h340C80; // Power down control (Broken)
		command[8] 		<= 24'h340E42; // Digital audio interface format
		command[9] 		<= 24'h341019; // Sampling control
		command[10] 	<= 24'h341201; // Active control
		/*
		command[0] 	<= 24'h340097;	// Left line in
		command[1] 	<= 24'h340297; // Right line in
		command[2] 	<= 24'h340479; // Left headphone out
		command[3] 	<= 24'h340679; // Right headphone out
		command[4] 	<= 24'h340815; // Analog audio path control
		command[5] 	<= 24'h340A00; // Digital audio path control
		command[6] 	<= 24'h340C00; // Power down control
		command[7] 	<= 24'h340E42; // Digital audio interface format
		command[8] 	<= 24'h341019; // Sampling control
		command[9] <= 24'h341201; // Active control
		*/
		ack_light_reg 	<= 0;
		o_finished_reg	<= 0;
	end 
	else begin
		state				<= state_nxt;
		counter 			<= counter_nxt;
		counter_cmd 	<= counter_cmd_nxt;
		counter_ack 	<= counter_ack_nxt;
		o_sclk_reg 		<= o_sclk_reg_nxt;
		o_sdat_reg 		<= o_sdat_reg_nxt;
		ack_light_reg	<= ack_light_reg_nxt;
		o_finished_reg <= o_finished_reg_nxt;
	end 
end

endmodule