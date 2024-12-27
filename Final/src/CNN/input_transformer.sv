module Input_transformer
(
    input clk,
    input rst,
    input button_pressed,
    input [899:0] handwrite,
    output [7:0] pixel_i,
    output pixel_i_valid
);
    logic [15:0] count_time;
    logic state_w, state_r;
    
    localparam S_IDLE = 0;
    localparam S_DRAW = 1;

    //counter
    Counter #(
        .WIDTH(16),
        .MAX_COUNT(899)
    ) counter (
        .clk(clk),
        .rst_n(~button_pressed),
        .enable(state_r == S_DRAW),
        .count(count_time)
    );

    assign pixel_i_valid = (state_r == S_DRAW);
    assign pixel_i = handwrite[count_time] ? 8'b11111111 : 8'b00000000;

    always_comb begin
        state_w = state_r;
        case (state_r)
            S_IDLE:
            begin
                if (button_pressed)
                    state_w = S_DRAW;
            end
            S_DRAW:
            begin
                if (count_time == 899)
                    state_w = S_IDLE;
            end
        endcase
    end


    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            state_r <= S_IDLE;
        end
        else begin
            state_r <= state_w;
        end
    end


endmodule