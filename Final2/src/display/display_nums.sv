module display_nums(
    input[10:0] i_x,
    input[10:0] i_y,
    output[9:0] o_blue,
    output[9:0] o_red,
    output[9:0] o_green,
    input[899:0] i_handwrite,
    input[95:0] i_digit_showed,
    input[1:0] i_correctness,
    input[10:0] i_displacement
);


function logic [4:0] coord2numindex;
    input logic [10:0] x;
    input logic [10:0] y;
    input logic [10:0] displacement;
    begin
        if (y + displacement >= 30  && y + displacement < 130) begin
            if (x >= 6 && x < 106) begin
                return 5'b00000;
            end
            else if (x >= 112 && x < 212) begin
                return 5'b00001;
            end
            else if (x >= 218 && x < 318) begin
                return 5'b00010;
            end
            else if (x >= 324 && x < 424) begin
                return 5'b00011;
            end
            else if (x >= 430 && x < 530) begin
                return 5'b00100;
            end
            else if (x >= 536 && x < 636) begin
                return 5'b00101;
            end
            else begin
                return 5'b11111;
            end
        end
        else if(y >= 180 - displacement && y < 280 - displacement) begin
            if (x >= 6 && x < 106) begin
                return 5'b00110;
            end
            else if (x >= 112 && x < 212) begin
                return 5'b00111;
            end
            else if (x >= 218 && x < 318) begin
                return 5'b01000;
            end
            else if (x >= 324 && x < 424) begin
                return 5'b01001;
            end
            else if (x >= 430 && x < 530) begin
                return 5'b01010;
            end
            else if (x >= 536 && x < 636) begin
                return 5'b01011;
            end
            else begin
                return 5'b11111;
            end
        end
        else if(y >= 330 - displacement && y < 430 - displacement) begin
            if (x >= 6 && x < 106) begin
                return 5'b01100;
            end
            else if (x >= 112 && x < 212) begin
                return 5'b01101;
            end
            else if (x >= 218 && x < 318) begin
                return 5'b01110;
            end
            else if (x >= 324 && x < 424) begin
                return 5'b01111;
            end
            else if (x >= 430 && x < 530) begin
                return 5'b10000;
            end
            else if (x >= 536 && x < 636) begin
                return 5'b10001;
            end
            else begin
                return 5'b11111;
            end
        end
        else if(y >= 480 - displacement && y < 580 - displacement) begin
            if (x >= 6 && x < 106) begin
                return 5'b10010;
            end
            else if (x >= 112 && x < 212) begin
                return 5'b10011;
            end
            else if (x >= 218 && x < 318) begin
                return 5'b10100;
            end
            else if (x >= 324 && x < 424) begin
                return 5'b10101;
            end
            else if (x >= 430 && x < 530) begin
                return 5'b10110;
            end
            else if (x >= 536 && x < 636) begin
                return 5'b10111;
            end
            else begin
                return 5'b11111;
            end
        end
        else begin
            return 5'b11111;
        end
    end
endfunction

function logic [7:0] relative_adddress;
    input logic [10:0] x;
    input logic [10:0] y;
    input logic [10:0] displacement;
    logic [4:0] index = coord2numindex(.x(x),.y(y),.displacement(displacement));
    begin
        if (index < 5'b00110) begin
            relative_adddress = (((32'(y-30+displacement) * 16'h1999) >> 16)) + ('d10 * ((32'(x - (106 * index) - 6) * 16'h1999) >> 16));
        end
        else if (index < 5'b01100) begin
            relative_adddress = (((32'(y-180+displacement) * 16'h1999) >> 16)) + ('d10 * ((32'(x - (106 * (index - 5'b00110)) - 6) * 16'h1999) >> 16));
        end
        else if (index < 5'b10010) begin
            relative_adddress = (((32'(y-330+displacement) * 16'h1999) >> 16)) + ('d10 * ((32'(x - (106 * (index - 5'b01100)) - 6) * 16'h1999) >> 16));
        end
        else if (index < 5'b11111) begin
            relative_adddress = (((32'(y-480+displacement) * 16'h1999) >> 16)) + ('d10 * ((32'(x - (106 * (index - 5'b10010)) - 6) * 16'h1999) >> 16));
        end
        else begin
            relative_adddress = 'd0;
        end
    end
endfunction

logic [3:0] shownum;
logic [7:0] numaddr;
logic [9:0] gray;
num2pixel num0 (
    .num(shownum),
    .addr(numaddr),
    .brightness(gray)
);
assign numaddr = relative_adddress(.x(i_x),.y(i_y),.displacement(i_displacement));
assign shownum = i_digit_showed[95 - (4 * coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement))) -: 4];
always_comb begin
    if (coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement)) < 5'b00110) begin
        if (i_correctness[0]) begin
            o_blue = 10'b0;
            o_red = 10'b0;
            o_green = gray;
        end
        else begin
            o_blue = 10'b0000000000;
            o_red = gray;
            o_green = 10'b0000000000;
        end
    end
    else if (coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement)) < 5'b01100) begin
        if (i_displacement !=0) begin
            if (i_correctness[1]) begin
                o_blue = 10'b0;
                o_red = 10'b0;
                o_green = gray;
            end
            else begin
                o_blue = 10'b0000000000;
                o_red = gray;
                o_green = 10'b0000000000;
            end
        end
        else begin
            if (coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement)) < 5'b01011) begin
                o_blue = gray;
                o_red = gray;
                o_green = gray;
            end
            else begin
                o_blue = 10'b0000000000;//need modified
                o_red = 10'b0000000000;
                o_green = 10'b0000000000;
            end
        end
    end
    else if (coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement)) < 5'b10010) begin
        if (coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement)) < 5'b10001) begin
            o_blue = gray;
            o_red = gray;
            o_green = gray;
        end
        else begin
            o_blue = 10'b0000000000;
            o_red = 10'b0000000000;
            o_green = 10'b0000000000;
        end
    end
    else if (coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement)) < 5'b11111) begin
        if (coord2numindex(.x(i_x),.y(i_y),.displacement(i_displacement)) < 5'b10111) begin
            o_blue = gray;
            o_red = gray;
            o_green = gray;
        end
        else begin
            o_blue = 10'b0000000000;
            o_red = 10'b0000000000;
            o_green = 10'b0000000000;
        end
    end
    else begin
        o_blue = 10'b0000000000;
        o_red = 10'b0000000000;
        o_green = 10'b0000000000;
    end
end
endmodule

module lfsr // Linear feedback shift register
(
	input  i_clk,
	input  i_rst_n,
	output [8:0] o_random_out
);

logic [31:0] random_w,random_r;

// ===== Output Assignments =====
assign o_random_out = {random_r[27],random_r[5],random_r[19],random_r[24],random_r[30],random_r[31],random_r[29],random_r[11],random_r[8]};

always_comb begin	
	random_w = {random_r[30:0],random_r[3]^random_r[8]^random_r[11]^random_r[15]^random_r[18]^random_r[24]^random_r[29]};
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		random_r 	<= 32'h5CA77A5C; //Magic Number
	end
	else begin
		random_r 	<= random_w;
	end
end
endmodule

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

lfsr random_gen (
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