module I2cInitializer(
    input  i_rst_n,
    input  i_clk,
    input  i_start,
    output o_finished,
    output o_sclk,    
    output o_sdat,    
    output o_oen,
    input  i_ack
);

//FSM
localparam S_IDLE       = 0;
localparam S_DATA       = 1;
localparam S_ACK        = 2;
localparam S_STARTSTOP  = 3;

logic [24*7-1:0] data = { //Packed Array
    24'b0011_0100_000_1111_0_0000_0000,
    24'b0011_0100_000_0100_0_0001_0101,
    24'b0011_0100_000_0101_0_0000_0000,
    24'b0011_0100_000_0110_0_0000_0000,
    24'b0011_0100_000_0111_0_0100_0010,
    24'b0011_0100_000_1000_0_0001_1001,
    24'b0011_0100_000_1001_0_0000_0001
} ;


logic[1:0]  state_w     , state_r;
logic       sclk_w      , sclk_r;
logic       sdat_w      , sdat_r;
logic       finished_w  , finished_r;
logic[7:0]  counter_w   , counter_r;//which bit in whold data
logic       oen_w       , oen_r;//oen=0 only when acking
logic       ack_w       , ack_r;
logic[1:0]  startcnt_w  , startcnt_r;//how many byte has sent, stop when 3 byte sent
logic[2:0]  bitcnt_w    , bitcnt_r;//which bit in a byte, ack when whole byte sent

assign o_finished   = finished_r;
assign o_oen        = oen_r;
assign o_sclk       = sclk_r;
assign o_sdat       = sdat_r;



always_comb begin
    state_w     = state_r;
    sclk_w      = sclk_r;
    sdat_w      = sdat_r;
    finished_w  = finished_r;
    counter_w   = counter_r;
    ack_w       = ack_r;
    oen_w       = oen_r;
    startcnt_w  = startcnt_r;
    bitcnt_w    = bitcnt_r;

    case(state_r)
        S_IDLE: begin
            if(i_start) begin
                state_w     = S_STARTSTOP;
                sclk_w      = 1;
                sdat_w      = 1;
                finished_w  = 0; 
                counter_w   = 0;
                ack_w       = 0;
                oen_w       = 1;
                startcnt_w  = 0;
                bitcnt_w    = 0;
            end
        end
        S_DATA : begin
            sclk_w  = 0;
            if(!sclk_r) begin
                if(startcnt_r==3 && ack_r==1 ) begin
                    state_w = S_STARTSTOP;
                end
                else if(bitcnt_r==0 && ack_r==0 && counter_r!=0) begin
                    state_w = S_ACK;
                    oen_w   = 0;
                    sclk_w  = 1;
                    sdat_w  = 0;
                end
                else begin
                    ack_w       = 0;
                    sdat_w      = data[24*6-1-counter_r];
                    counter_w   = counter_r+1;
                    bitcnt_w    = bitcnt_r+1;
                    sclk_w      = 1;
                end
            end
        end
        S_ACK : begin
            if(!i_ack) begin
                ack_w       = 1;
                state_w     = S_DATA;
                startcnt_w  = startcnt_r+1;
                oen_w       = 1;
            end
        end
        S_STARTSTOP : begin
            sclk_w  = 1;
            if(sclk_r) begin
                sdat_w  = 1;
                if( counter_r == 24*6) begin
                    state_w     = S_IDLE;
                    sclk_w      = 1;
                    sdat_w      = 1;
                    finished_w  = 1;
                end
                else begin
                    if(sdat_r) begin
                        sdat_w      = 0;
                        state_w     = S_DATA;
                        startcnt_w  = 0;
                    end
                end
            end
        end
    endcase
end


always_ff @ (posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        finished_r  <= 0;
        sclk_r      <= 1;
        sdat_r      <= 1;
        counter_r   <= 0;
        oen_r       <= 1;
        ack_r       <= 0;
        startcnt_r  <= 0;
        bitcnt_r    <= 0;
    end
    else begin
        state_r     <= state_w;
        finished_r  <= finished_w;
        sclk_r      <= sclk_w;
        sdat_r      <= sdat_w;
        counter_r   <= counter_w;
        oen_r       <= oen_w;
        ack_r       <= ack_w;
        startcnt_r  <= startcnt_w;
        bitcnt_r    <= bitcnt_w;
    end

end
endmodule