module Magic_model
(
    input i_clk,
    input i_rst_n,
    input button_pressed,
    input [899:0] handwrite,
    output [3:0] digit_o,
    output digit_o_valid
);

localparam S_IDLE = 0;
localparam S_INPUT = 1;
localparam S_OUTPUT = 2;

logic [1:0] state, state_next;
logic [4:0] x, x_next;
logic [4:0] y, y_next;
logic [10:0] idx;

logic [9:0][29:0][29:0] masks;
logic [9:0][15:0] sons ;
logic [9:0][15:0] sons_next ;
logic [9:0][15:0] moms ;
logic [9:0][15:0] moms_next ;

logic [3:0]  p1w_idx1, p1w_idx2, p1w_idx3, p1w_idx4, p1w_idx5, p2w_idx1, p2w_idx2, p3w_idx;
logic [15:0] p1w_son1, p1w_son2, p1w_son3, p1w_son4, p1w_son5, p2w_son1, p2w_son2, p3w_son;
logic [15:0] p1w_mom1, p1w_mom2, p1w_mom3, p1w_mom4, p1w_mom5, p2w_mom1, p2w_mom2, p3w_mom;

assign idx = y * 30 + x;
assign digit_o_valid = (state == S_OUTPUT);

always_comb begin
    state_next = state;
    x_next = x;
    y_next = y;


    for (int i = 0; i < 10; i = i + 1) begin
        sons_next[i] = sons[i];
        moms_next[i] = moms[i];
    end

    case (state) 
        S_IDLE: begin
            if (button_pressed)
                state_next = S_INPUT;
                x_next = 0;
                y_next = 0;
        end

        S_INPUT: begin
            for (int i = 0; i < 10; i = i + 1) begin
                if (handwrite[idx]) begin
                    if (masks[i][y][x]) begin
                        sons_next[i] = sons[i] + 2;
                        moms_next[i] = moms[i] + 2;
                    end
                    else begin
                        moms_next[i] = moms[i] + 1;
                    end
                end
                else begin
                    if (masks[i][y][x]) begin
                        moms_next[i] = moms[i] + 1;
                    end
                end
            end
            if (x == 5'd29) begin
                x_next = 0;
                if (y == 5'd29) begin
                    y_next = 0;
                    state_next = S_OUTPUT;
                end
                else begin
                    y_next = y + 1;
                end
            end
            else begin
                x_next = x + 1;
            end
        end

        S_OUTPUT: begin
            state_next = S_IDLE;
        end

    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
            state <= S_IDLE;
            x <= 0;
            y <= 0;
    end
    else begin
        state <= state_next;
        x <= x_next;
        y <= y_next;
    end
end

Magic_mask umask0 (
    .idx(4'd0),
    .mask(masks[0])
);

Magic_mask umask1 (
    .idx(4'd1),
    .mask(masks[1])
);

Magic_mask umask2 (
    .idx(4'd2),
    .mask(masks[2])
);

Magic_mask umask3 (
    .idx(4'd3),
    .mask(masks[3])
);

Magic_mask umask4 (
    .idx(4'd4),
    .mask(masks[4])
);
Magic_mask umask5 (
    .idx(4'd5),
    .mask(masks[5])
);

Magic_mask umask6 (
    .idx(4'd6),
    .mask(masks[6])
);

Magic_mask umask7 (
    .idx(4'd7),
    .mask(masks[7])
);

Magic_mask umask8 (
    .idx(4'd8),
    .mask(masks[8])
);

Magic_mask umask9 (
    .idx(4'd9),
    .mask(masks[9])
);

Magic_compare p1_1 (
    .idx_a(4'd0),
    .idx_b(4'd1),
    .son_a(sons[0]),
    .son_b(sons[1]),
    .mom_a(moms[0]),
    .mom_b(moms[1]),
    .idx_won(p1w_idx1),
    .son_won(p1w_son1),
    .mom_won(p1w_mom1)
);

Magic_compare p1_2 (
    .idx_a(4'd2),
    .idx_b(4'd3),
    .son_a(sons[2]),
    .son_b(sons[3]),
    .mom_a(moms[2]),
    .mom_b(moms[3]),
    .idx_won(p1w_idx2),
    .son_won(p1w_son2),
    .mom_won(p1w_mom2)
);

Magic_compare p1_3 (
    .idx_a(4'd4),
    .idx_b(4'd5),
    .son_a(sons[4]),
    .son_b(sons[5]),
    .mom_a(moms[4]),
    .mom_b(moms[5]),
    .idx_won(p1w_idx3),
    .son_won(p1w_son3),
    .mom_won(p1w_mom3)
);

Magic_compare p1_4 (
    .idx_a(4'd6),
    .idx_b(4'd7),
    .son_a(sons[6]),
    .son_b(sons[7]),
    .mom_a(moms[6]),
    .mom_b(moms[7]),
    .idx_won(p1w_idx4),
    .son_won(p1w_son4),
    .mom_won(p1w_mom4)
);

Magic_compare p1_5 (
    .idx_a(4'd8),
    .idx_b(4'd9),
    .son_a(sons[8]),
    .son_b(sons[9]),
    .mom_a(moms[8]),
    .mom_b(moms[9]),
    .idx_won(p1w_idx5),
    .son_won(p1w_son5),
    .mom_won(p1w_mom5)
);

Magic_compare p2_1 (
    .idx_a(p1w_idx1),
    .idx_b(p1w_idx2),
    .son_a(p1w_son1),
    .son_b(p1w_son2),
    .mom_a(p1w_mom1),
    .mom_b(p1w_mom2),
    .idx_won(p2w_idx1),
    .son_won(p2w_son1),
    .mom_won(p2w_mom1)
);

Magic_compare p2_2 (
    .idx_a(p1w_idx3),
    .idx_b(p1w_idx4),
    .son_a(p1w_son3),
    .son_b(p1w_son4),
    .mom_a(p1w_mom3),
    .mom_b(p1w_mom4),
    .idx_won(p2w_idx2),
    .son_won(p2w_son2),
    .mom_won(p2w_mom2)
);

Magic_compare p3 (
    .idx_a(p2w_idx1),
    .idx_b(p2w_idx2),
    .son_a(p2w_son1),
    .son_b(p2w_son2),
    .mom_a(p2w_mom1),
    .mom_b(p2w_mom2),
    .idx_won(p3w_idx),
    .son_won(p3w_son),
    .mom_won(p3w_mom)
);

Magic_compare p4 (
    .idx_a(p1w_idx5),
    .idx_b(p3w_idx),
    .son_a(p1w_son5),
    .son_b(p3w_son),
    .mom_a(p1w_mom5),
    .mom_b(p3w_mom),
    .idx_won(digit_o)
);

endmodule