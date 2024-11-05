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
parameter S_WRITE	= 2;
parameter S_READ 	= 3;
parameter S_ACK 	= 4;
parameter S_STOP	= 5;



//logic [23:0] data[10:0] = '{ // Unpacked Array
//    24'b0011_0100_000_1111_0_0000_0000,
//    24'b0011_0100_000_0000_0_1001_0111,
//    24'b0011_0100_000_0001_0_1001_0111,
//    24'b0011_0100_000_0010_0_0111_1001,
//    24'b0011_0100_000_0011_0_0111_1001,
//		
//    24'b0011_0100_000_0100_0_0001_0101,
//    24'b0011_0100_000_0101_0_0000_0000,
//    24'b0011_0100_000_0110_0_0000_0000,
//    24'b0011_0100_000_0111_0_0100_0010,
//    24'b0011_0100_000_1000_0_0001_1001,
//    24'b0011_0100_000_1001_0_0000_0001
//};

logic [23:0] data[10:0];


logic[2:0]  state_w     , state_r;
logic       sclk_w      , sclk_r;
logic       sdat_w      , sdat_r;
logic       finished_w  , finished_r;
logic[3:0]  cmdcnt_w    , cmdcnt_r; // which cmd is sending
logic[4:0]  bitcnt_w    , bitcnt_r; // which bit in a cmd to send

assign o_finished   = finished_r;
assign o_oen        = !(state_r == S_ACK || state_r == S_IDLE);
assign o_sclk       = sclk_r;
assign o_sdat       = sdat_r;



always_comb begin
    state_w     = state_r;
    sclk_w      = sclk_r;
    sdat_w      = sdat_r;
    finished_w  = finished_r;
    cmdcnt_w    = cmdcnt_r;
    bitcnt_w    = bitcnt_r;

    case(state_r)
        S_IDLE: begin
            if (i_start) begin
                state_w = S_START;
                sdat_w = 0;
                cmdcnt_w = 0;
                bitcnt_w = 23;
            end
        end
        S_START: begin
            if (sdat_r) begin
                sdat_w = 0;
            end
            else begin
                state_w = S_WRITE;
                sclk_w = 0;
                sdat_w = data[cmdcnt_r][bitcnt_r];
            end
        end
        S_WRITE: begin
            state_w = S_READ;
            sclk_w = 1;
            if (bitcnt_r == 0) begin
                cmdcnt_w = cmdcnt_r + 1;
                bitcnt_w = 23;
            end
            else begin
                bitcnt_w = bitcnt_r - 1;
            end
        end
        S_READ: begin
            sclk_w = 0;
            if (bitcnt_r[2:0] == 3'b111) begin
                state_w = S_ACK;
            end
            else begin
                state_w = S_WRITE;
                sdat_w = data[cmdcnt_r][bitcnt_r];
            end
        end
        S_ACK: begin
            sclk_w = !sclk_r;
            if (!i_ack && sclk_r) begin
                if (bitcnt_r == 23) begin
                    state_w = S_STOP;
                    sdat_w = 0;
                end
                else begin
                    state_w = S_WRITE;
                    sdat_w = data[cmdcnt_r][bitcnt_r];
                end
            end
        end
        S_STOP: begin
            if (!sclk_r) begin
                sclk_w = 1;
            end
            else begin
                sdat_w = 1;
                if (cmdcnt_r == 11) begin
                    state_w = S_IDLE;
                    finished_w = 1;
                end
                else begin
                    state_w = S_START;
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
        cmdcnt_r    <= 0;
        bitcnt_r    <= 23;
        data[0] 	<= 24'b0011_0100_000_1111_0_0000_0000;
        data[1]     <= 24'b0011_0100_000_0000_0_1001_0111;
        data[2]     <= 24'b0011_0100_000_0001_0_1001_0111;
        data[3]     <= 24'b0011_0100_000_0010_0_0111_1001;
        data[4]     <= 24'b0011_0100_000_0011_0_0111_1001;
        data[5]     <= 24'b0011_0100_000_0100_0_0001_0101;
        data[6]     <= 24'b0011_0100_000_0101_0_0000_0000;
        data[7]     <= 24'b0011_0100_000_0110_0_0000_0000;
        data[8]     <= 24'b0011_0100_000_0111_0_0100_0010;
        data[9]     <= 24'b0011_0100_000_1000_0_0001_1001;
        data[10]    <= 24'b0011_0100_000_1001_0_0000_0001;
    end
    else begin
        state_r     <= state_w;
        finished_r  <= finished_w;
        sclk_r      <= sclk_w;
        sdat_r      <= sdat_w;
        cmdcnt_r    <= cmdcnt_w;
        bitcnt_r    <= bitcnt_w;
    end

end
endmodule