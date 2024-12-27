module Magic_model
(
    input i_clk,
    input i_rst_n,
    input i_button_pressed_n,
    input [899:0] handwrite,
    output [3:0] digit_o,
    output digit_o_valid
);

localparam S_IDLE = 0;
localparam S_INPUT = 1;
localparam S_CMP1 = 2;
localparam S_CMP2 = 3;
localparam S_CMP3 = 4;
localparam S_CMP4 = 5;
localparam S_OUTPUT = 6;

logic [2:0] state, state_next;
logic [4:0] x, x_next;
logic [4:0] y, y_next;
logic [10:0] idx;

logic [9:0][29:0][29:0] masks;
logic [9:0][15:0] sons ;
logic [9:0][15:0] sons_next ;
logic [9:0][15:0] moms ;
logic [9:0][15:0] moms_next ;

logic [3:0]  p1w_idx1, p1w_idx2, p1w_idx3, p1w_idx4, p1w_idx5, p2w_idx1, p2w_idx2, p3w_idx, p4w_idx;
logic [3:0]  p1w_idx1_n, p1w_idx2_n, p1w_idx3_n, p1w_idx4_n, p1w_idx5_n, p2w_idx1_n, p2w_idx2_n, p3w_idx_n, p4w_idx_n;


assign idx = y * 30 + x;
assign digit_o_valid = (state == S_OUTPUT);
assign digit_o = p4w_idx;

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
            if (!i_button_pressed_n) begin
                state_next = S_INPUT;
                x_next = 0;
                y_next = 0;
                
                for (int i = 0; i < 10; i = i + 1) begin
                    sons_next[i] = 0;
                    moms_next[i] = 0;
                end
            end
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
                else begin // handwrite[idx] == 0
                    if (masks[i][y][x]) begin
                        moms_next[i] = moms[i] + 1;
                    end
                end
            end
            if (x == 5'd29) begin
                x_next = 0;
                if (y == 5'd29) begin
                    y_next = 0;
                    state_next = S_CMP1;
                end
                else begin
                    y_next = y + 1;
                end
            end
            else begin
                x_next = x + 1;
            end
        end

        S_CMP1: begin
            state_next = S_CMP2;
        end

        S_CMP2: begin
            state_next = S_CMP3;
        end

        S_CMP3: begin
            state_next = S_CMP4;
        end

        S_CMP4: begin
            state_next = S_OUTPUT;
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
            for (int i = 0; i < 10; i = i + 1) begin
                sons[i] = 0;
                moms[i] = 0;
            end
            p1w_idx1 = 0;
            p1w_idx2 = 0;
            p1w_idx3 = 0;
            p1w_idx4 = 0;
            p1w_idx5 = 0;
            p2w_idx1 = 0;
            p2w_idx2 = 0;
            p3w_idx = 0;
            p4w_idx = 0;
    end
    else begin
        state <= state_next;
        x <= x_next;
        y <= y_next;
        for (int i = 0; i < 10; i = i + 1) begin
            sons[i] = sons_next[i];
            moms[i] = moms_next[i];
        end
        p1w_idx1 = p1w_idx1_n;
        p1w_idx2 = p1w_idx2_n;
        p1w_idx3 = p1w_idx3_n;
        p1w_idx4 = p1w_idx4_n;
        p1w_idx5 = p1w_idx5_n;
        p2w_idx1 = p2w_idx1_n;
        p2w_idx2 = p2w_idx2_n;
        p3w_idx = p3w_idx_n;
        p4w_idx = p4w_idx_n;
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
    .idx_won(p1w_idx1_n)
);

Magic_compare p1_2 (
    .idx_a(4'd2),
    .idx_b(4'd3),
    .son_a(sons[2]),
    .son_b(sons[3]),
    .mom_a(moms[2]),
    .mom_b(moms[3]),
    .idx_won(p1w_idx2_n)
);

Magic_compare p1_3 (
    .idx_a(4'd4),
    .idx_b(4'd5),
    .son_a(sons[4]),
    .son_b(sons[5]),
    .mom_a(moms[4]),
    .mom_b(moms[5]),
    .idx_won(p1w_idx3_n)
);

Magic_compare p1_4 (
    .idx_a(4'd6),
    .idx_b(4'd7),
    .son_a(sons[6]),
    .son_b(sons[7]),
    .mom_a(moms[6]),
    .mom_b(moms[7]),
    .idx_won(p1w_idx4_n)
);

Magic_compare p1_5 (
    .idx_a(4'd8),
    .idx_b(4'd9),
    .son_a(sons[8]),
    .son_b(sons[9]),
    .mom_a(moms[8]),
    .mom_b(moms[9]),
    .idx_won(p1w_idx5_n)
);

Magic_compare p2_1 (
    .idx_a(p1w_idx1),
    .idx_b(p1w_idx2),
    .son_a(sons[p1w_idx1]),
    .son_b(sons[p1w_idx2]),
    .mom_a(moms[p1w_idx1]),
    .mom_b(moms[p1w_idx2]),
    .idx_won(p2w_idx1_n)
);

Magic_compare p2_2 (
    .idx_a(p1w_idx3),
    .idx_b(p1w_idx4),
    .son_a(sons[p1w_idx3]),
    .son_b(sons[p1w_idx4]),
    .mom_a(moms[p1w_idx3]),
    .mom_b(moms[p1w_idx4]),
    .idx_won(p2w_idx2_n)
);

Magic_compare p3 (
    .idx_a(p2w_idx1),
    .idx_b(p2w_idx2),
    .son_a(sons[p2w_idx1]),
    .son_b(sons[p2w_idx2]),
    .mom_a(moms[p2w_idx1]),
    .mom_b(moms[p2w_idx2]),
    .idx_won(p3w_idx_n)
);

Magic_compare p4 (
    .idx_a(p1w_idx5),
    .idx_b(p3w_idx),
    .son_a(sons[p1w_idx5]),
    .son_b(sons[p3w_idx]),
    .mom_a(moms[p1w_idx5]),
    .mom_b(moms[p3w_idx]),
    .idx_won(p4w_idx_n)
);

endmodule