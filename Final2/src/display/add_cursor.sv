module add_cursor(
    input i_clk,  // system clock
    input i_rst_n,  // system reset
    input[9:0] i_red,
    input[9:0] i_green,
    input[9:0] i_blue,
    input[10:0] i_displacement,
    input[10:0] i_x,
    input[10:0] i_y,
    output[9:0] o_blue,
    output[9:0] o_red,
    output[9:0] o_green,
    output[899:0] o_handwrite,
    input[8:0] move_x,
    input[8:0] move_y,
    input btn_left,
    input btn_right,
    input mouse_valid
);

logic[899:0] handwrite_w, handwrite_r;
logic[15:0] cursor_x_w, cursor_x_r;
logic[15:0] cursor_y_w, cursor_y_r;
logic[15:0] y_pos;

assign o_handwrite  =   handwrite_r;
assign y_pos        =   {9'b0,cursor_y_r[15:4]};

always_comb begin
    handwrite_w =   handwrite_r;
    cursor_x_w  =   cursor_x_r;
    cursor_y_w  =   cursor_y_r;
    if (i_displacement != 11'b0) begin
        handwrite_w = 900'b0;
    end
    else if (mouse_valid) begin
        if (($signed(cursor_x_r) + $signed(move_x)) < 0) begin
            cursor_x_w = 0;
        end
        else if (($signed(cursor_x_r) + $signed(move_x)) >= (16'd30<<4)) begin
            cursor_x_w = (16'd30<<4)-1;
        end
        else begin
            cursor_x_w = $signed(cursor_x_r) + $signed(move_x);
        end
        if (($signed(cursor_y_r) - $signed(move_y)) < 0) begin
            cursor_y_w = 0;
        end
        else if (($signed(cursor_y_r) - $signed(move_y)) >= (16'd30<<4)) begin
            cursor_y_w = (16'd30<<4)-1;
        end
        else begin
            cursor_y_w = $signed(cursor_y_r) - $signed(move_y);
        end
        if (btn_left) begin
            handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4])] = 1;
            handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd30] = 1;
            if (cursor_x_r[15:4] != 0) begin
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd29] = 1;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd1] = 1;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd31] = 1;
            end
            handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd30] = 1;
            if (cursor_x_r[15:4] != 29) begin
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd29] = 1;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd1] = 1;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd31] = 1;
            end
        end
        else if (btn_right) begin
            handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4])] = 0;
            handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd30] = 0;
            if (cursor_x_r[15:4] != 0) begin
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd1] = 0;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd31] = 0;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd29] = 0;
            end
            handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd30] = 0;
            if (cursor_x_r[15:4] != 29) begin
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) - 'd29] = 0;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd1] = 0;
                handwrite_w['d899-(y_pos * 'd30 + cursor_x_r[15:4]) + 'd31] = 0;
            end
        end
    end
    if (i_x == (cursor_x_r[15:4] * 'd3 + 'd542)) begin
        if (i_displacement == 0 && i_y >= (cursor_y_r[15:4] * 'd3 + 11'd181) && i_y <= (cursor_y_r[15:4] * 'd3 + 11'd191)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h0;
        end
        else if (i_displacement > 0 && i_y >= (cursor_y_r[15:4] * 'd3 - i_displacement + 11'd331) && i_y <= (cursor_y_r[15:4] * 'd3 - i_displacement + 11'd341)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h0;
        end
        else begin
            o_red = i_red;
            o_blue = i_blue;
            o_green = i_green;
        end
    end
    else if (i_x >= (cursor_x_r[15:4] * 'd3 + 11'd537) && i_x <= (cursor_x_r[15:4] * 'd3 + 11'd547)) begin
        if (i_displacement == 0 && i_y == (cursor_y_r[15:4] * 'd3 + 11'd186)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h0;
        end
        else if (i_displacement > 0 && (i_y + i_displacement) == (cursor_y_r[15:4] * 'd3 + 11'd336)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h0;
        end
        else begin
            o_red = i_red;
            o_blue = i_blue;
            o_green = i_green;
        end
    end
    else begin
        o_red = i_red;
        o_blue = i_blue;
        o_green = i_green;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        handwrite_r <=  900'b0;
        cursor_x_r  <=  7'b0;
        cursor_y_r  <=  7'b0;
    end
    else begin
        handwrite_r <=  handwrite_w;
        cursor_x_r  <=  cursor_x_w;
        cursor_y_r  <=  cursor_y_w;
    end
end

endmodule