module AudPalyer(
	input           i_rst_n,
	input           i_bclk,
	input           i_daclrck,
	input           i_en,
	input [15:0]    i_dac_data,
	output          o_aud_dacdat
);
//parameters
localparam S_IDLE   = 0;
localparam S_DATAL  = 1;
localparam S_IDLE2  = 2;
localparam S_DATAR  = 3;

//registers and wires
logic[1:0]  state_w      , state_r;
logic       aud_dacdat_w , aud_dacdat_r;
logic[3:0]  counter_w    , counter_r;

assign aud_dacdat = aud_dacdat_r;

//combinational circuit
always_comb begin
    // Unconditional Assignments
    state_w         = state_r;
    counter_w       = counter_r;
    aud_dacdat_w    = aud_dacdat_r;

    case(state_r)
        S_IDLE: begin
            if(i_en && !i_daclrck) begin//left channel
                state_w = S_DATAL;
            end
        end
        S_DATAL: begin
            if(counter_r != 0) begin
                aud_dacdat_w    = i_dac_data[counter_r];
                counter_w       = counter_r-1;
            end
            else begin
                aud_dacdat_w    = i_dac_data[counter_r];
                counter_w       = 4'hf;
                state_w         = S_IDLE2;
            end
        end
        S_IDLE2: begin
            if(i_en && i_daclrck) begin//right channel
                state_w = S_DATAR;
            end
        end
        S_DATAR: begin
            if(counter_r != 0) begin
                aud_dacdat_w    = i_dac_data[counter_r];
                counter_w       = counter_r-1;
            end
            else begin
                aud_dacdat_w    = i_dac_data[counter_r];
                counter_w       = 4'hf;
                state_w         = S_IDLE;
            end
        end
    endcase
end
//sequential circuit
always_ff@(posedge i_bclk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r         <= S_IDLE;
        aud_dacdat_r    <= 1'b0;
        counter_r       <= 4'hf;
    end
    else begin
        state_r         <= state_w;
        aud_dacdat_r    <= aud_dacdat_w;
        counter_r       <= counter_w;
    end
end
endmodule

module AudRecorder(
	input           i_rst_n, 
	input           i_clk,
	input           i_lrc,
	input           i_start,
	input           i_pause,
	input           i_stop,
	input           i_data,
	output [19:0]   o_address,
	output [15:0]   o_data
);

//parameters
localparam S_IDLE   = 0;
localparam S_REC    = 1;// record left channel 
localparam S_WAIT   = 2;// wait for the next left channel
localparam S_PAUSE  = 3;

//registers and wires
logic [1:0]     state_w     , state_r;
logic [3:0]     counter_w   , counter_r;
logic [19:0]    address_w   , address_r;
logic [15:0]    data_w      , data_r;

assign o_address    = address_r;
assign o_data       = data_r;

//combinational circuit
always_comb begin
    // Unconditional Assignments
    state_w         = state_r;
    counter_w       = counter_r;
    address_w       = address_r;
    data_w          = data_r;

    case(state_r)
        S_IDLE: begin
            if(i_start) begin
                state_w     = S_WAIT;
                counter_w   = 4'h0;
                address_w   = 20'hfffff;
                data_w      = 0;
            end
        end
        S_REC: begin
            if(i_stop)begin
                state_w     = S_IDLE;
            end
            else if(i_pause) begin
                state_w     = S_PAUSE;
            end
            else if(!i_lrc) begin//only record left channel
                if(counter_r != 4'hf) begin
                    data_w      = {data_r[14:0],i_data};
                    counter_w   = counter_r+1;
                end
                else begin
                    data_w      = {data_r[14:0],i_data};
                    counter_w   = 0;
                    state_w     = S_WAIT;
                    address_w   = address_r+1;
                end
            end
        end
        S_WAIT: begin
            if(i_stop)begin
                state_w     = S_IDLE;
            end
            else if(i_pause) begin
                state_w     = S_PAUSE;
            end
            else if(i_lrc) begin//wait for right channel
                state_w     = S_REC;
                data_w      = 0;
                counter_w   = 0;
            end
        end
        S_PAUSE: begin
            if(i_stop)begin
                state_w     = S_IDLE;
            end
            else if(i_start) begin
                state_w     = S_WAIT;
            end
        end
    endcase
end
//sequential circuit
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r         <= S_IDLE;
        counter_r       <= 4'h0;
        address_r       <= 20'hfffff;
        data_r          <= 16'h0;
    end
    else begin
        state_r         <= state_w;
        address_r       <= address_w;
        counter_r       <= counter_w;
        data_r          <= data_w;
    end
end
endmodule