module I2cInitializer(
    input  i_rst_n,
    input  i_clk,
    input  i_ack,
    input  i_start,
    output o_finished,
    output o_sclk,    
    output o_sdat,    
    output o_oen
);

//FSM
localparam S_IDLE   = 0;
localparam S_START  = 1;
localparam S_STOP   = 2;
localparam S_ACK    = 3;
localparam S_DATA   = 4;
localparam S_COOLDOWN = 5;



logic [23:0] data[6:0] = '{ // Unpacked Array
    24'b0011_0100_000_1111_0_0000_0000,
    24'b0011_0100_000_0100_0_0001_0101,
    24'b0011_0100_000_0101_0_0000_0000,
    24'b0011_0100_000_0110_0_0000_0000,
    24'b0011_0100_000_0111_0_0100_0010,
    24'b0011_0100_000_1000_0_0001_1001,
    24'b0011_0100_000_1001_0_0000_0001
};


logic[2:0]  state_w     , state_r;
logic       sclk_w      , sclk_r;
logic       sdat_w      , sdat_r;
logic       finished_w  , finished_r;
logic       oen_w       , oen_r;//oen=0 only when acking
logic[2:0]  cmdcnt_w    , cmdcnt_r;//which cmd is sending
logic[4:0]  bitcnt_w    , bitcnt_r;//which bit in a cmd to send

assign o_finished   = finished_r;
assign o_oen        = oen_r;
assign o_sclk       = sclk_r;
assign o_sdat       = sdat_r;



always_comb begin
    state_w     = state_r;
    sclk_w      = sclk_r;
    sdat_w      = sdat_r;
    finished_w  = finished_r;
    oen_w       = oen_r;
    cmdcnt_w    = cmdcnt_r;
    bitcnt_w    = bitcnt_r;

    case(state_r)
        S_IDLE: begin
            if(i_start) begin
                state_w  = S_START;
                cmdcnt_w = 'd6; //7 cmds
            end
        end
        S_DATA : begin
            sclk_w  = ~sclk_r;
            if(sclk_r) begin //this cycle 1, next cycle 0
                if(bitcnt_r[2:0] == 3'b111 && bitcnt_r[4:3] != 2'b10) begin //into ack
                    state_w = S_ACK;
                    oen_w   = 0;
                    sdat_w  = 0; //actually don't care
                end
                else begin
                    sdat_w = data[cmdcnt_r][bitcnt_r];
                    bitcnt_w = bitcnt_r - 1;
                end
            end
        end
        S_ACK : begin
            sclk_w  = ~sclk_r;
            if (sclk_r) begin
                oen_w = 1;
                //if(!i_ack) begin //ack = 0 -> acked
					 if (bitcnt_r == 5'b11111) begin //finish this cmd
                    state_w = S_STOP;
                end 
                else begin //next byte
                    state_w = S_DATA;
                    bitcnt_w = bitcnt_r - 1;
                end/*
                end
                else begin //ack = 1 -> not acked, resend
                    cmdcnt_w    = cmdcnt_r+1;
                    state_w     = S_STOP;
                end*/
            end

        end
        S_START : begin
            if (sdat_r) begin // first cycle
                sclk_w = 1;
                sdat_w = 0;
                oen_w  = 1;
            end
            else begin // second cycle
                state_w = S_DATA;
                bitcnt_w = 'd23;
            end
        end
        S_STOP : begin
            if (~sclk_r) sclk_w = 1 ;
            else if (~sdat_r) sdat_w = 1 ;
            else begin
                if (cmdcnt_r == 0) begin //finish
                    state_w = S_COOLDOWN;
                    bitcnt_w = 'd23;
                    finished_w = 1;
                end
                else begin
                    state_w = S_START;
                    cmdcnt_w = cmdcnt_r - 1;
                end
            end
        end
        S_COOLDOWN : begin
            finished_w = 0;
            if (bitcnt_r == 'd0) begin
                state_w = S_IDLE;
            end
            else begin
                bitcnt_w = bitcnt_r - 1;
            end
        end
        default: begin //won't use
        end
    endcase
end


always_ff @ (posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        finished_r  <= 0;
        sclk_r      <= 1;
        sdat_r      <= 1;
        oen_r       <= 1;
        cmdcnt_r    <= 0;
        bitcnt_r    <= 0;
    end
    else begin
        state_r     <= state_w;
        finished_r  <= finished_w;
        sclk_r      <= sclk_w;
        sdat_r      <= sdat_w;
        oen_r       <= oen_w;
        cmdcnt_r    <= cmdcnt_w;
        bitcnt_r    <= bitcnt_w;
    end

end
endmodule