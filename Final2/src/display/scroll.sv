module scroll (
    input i_clk,
    input i_rst_n,
    input[10:0] i_x,
    input[10:0] i_y,
    output[9:0] o_blue,
    output[9:0] o_red,
    output[9:0] o_green,
    input[899:0] i_handwrite,
    input[3:0] i_digit_answered,
    input i_digit_identified
);

logic[10:0] scroll_w, scroll_r;
logic[1:0] correctness_w, correctness_r;
logic[23:0] problems_w, problems_r;
logic state_w, state_r;
logic[8:0] random_index;
logic[95:0] digit_showed_w, digit_showed_r;

LFSR random_gen (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .o_random_out(random_index)
);

display_nums display (
    .i_x(i_x),
    .i_y(i_y),
    .o_blue(o_blue),
    .o_red(o_red),
    .o_green(o_green),
    .i_handwrite(i_handwrite),
    .i_digit_showed(digit_showed_r),
    .i_correctness(correctness_r),
    .i_displacement(scroll_r)
);

generate_problem prob (
    .problem_index(random_index),
    .problem(problems_w)
);

parameter S_IDLE      = 0;
parameter S_SCROLL    = 1;

always_comb begin
    scroll_w = scroll_r;
    correctness_w = correctness_r;
    problems_w = problems_r;
    digit_showed_w = digit_showed_r;
    state_w = state_r;
    case (state_r)
    S_IDLE: begin
        if (i_digit_identified) begin
            state_w = S_SCROLL;
            correctness_w = {i_digit_answered == digit_showed_r[51:48], correctness_r[0]};
            digit_showed_w = {digit_showed_r[95:52], i_digit_answered, digit_showed_r[47:24], problems_r};
        end
    end
    S_SCROLL: begin
        if (scroll_r < 150) begin
            if (i_x == 640 && i_y == 480) begin
                scroll_w = scroll_r + 3;
            end
        end
        else begin
            scroll_w = 0;
            correctness_w = {correctness_r[0],1'b0};
            digit_showed_w = {digit_showed_r[71:0], 24'hffffff};
            state_w = S_IDLE;
        end
    end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        scroll_r = 0;
        state_r = S_IDLE;
        correctness_r = 0;
        problems_r = 0;
    end
    else begin
        scroll_r = scroll_w;
        state_r = state_w;
        correctness_r = correctness_w;
        problems_r = problems_w;
    end
end
endmodule