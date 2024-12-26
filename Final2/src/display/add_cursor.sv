module add_cursor(
    input i_clk,  // system clock
    input i_rst_n,  // system reset
    inout ps2_clk,  // mouse clock
    inout ps2_data, // mouse data
    input[9:0] i_red,
    input[9:0] i_green,
    input[9:0] i_blue,
    input[10:0] i_displacement,
    input[10:0] i_x,
    input[10:0] i_y,
    output[9:0] o_blue,
    output[9:0] o_red,
    output[9:0] o_green,
    output[899:0] o_handwrite
);

logic[899:0] handwrite_w, handwrite_r;
logic[15:0] cursor_x_w, cursor_x_r;
logic[15:0] cursor_y_w, cursor_y_r;
logic btn_left, btn_right, mouse_valid;
logic[8:0] move_x, move_y;
logic[15:0] y_pos;

Mouse mouse(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .o_button_left(btn_left),
    .o_button_right(btn_right),
    .o_movement_x(move_x), // signed
    .o_movement_y(move_y),
    .o_valid(mouse_valid)
);

assign o_handwrite  =   handwrite_r;
assign y_pos        =   {9'b0,cursor_y_r[15:9]};

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
        else if (($signed(cursor_x_r) + $signed(move_x)) >= (16'd30<<9)) begin
            cursor_x_w = (16'd30<<9)-1;
        end
        else begin
            cursor_x_w = $signed(cursor_x_r) + $signed(move_x);
        end
        if (($signed(cursor_y_r) + $signed(move_y)) < 0) begin
            cursor_y_w = 0;
        end
        else if (($signed(cursor_y_r) + $signed(move_y)) >= (16'd30<<9)) begin
            cursor_y_w = (16'd30<<9)-1;
        end
        else begin
            cursor_y_w = $signed(cursor_y_r) + $signed(move_y);
        end
        if (btn_left) begin
            handwrite_w[y_pos * 'd30 + cursor_x_r[15:9]] = 1;
        end
        else if (btn_right) begin
            handwrite_w[y_pos * 'd30 + cursor_x_r[15:9]] = 0;
        end
    end
    if (i_x == (cursor_x_r[15:9] * 'd3 + 'd537)) begin
        if (i_displacement == 0 && i_y >= (cursor_y_r[15:9] * 'd3 + 11'd271) && i_y <= (cursor_y_r[15:9] * 'd3 + 11'd281)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h3ff;
        end
        else if (i_displacement > 0 && i_y >= (cursor_y_r[15:9] * 'd3 - i_displacement + 11'd421) && i_y <= (cursor_y_r[15:9] * 'd3 - i_displacement + 11'd431)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h3ff;
        end
        else begin
            o_red = i_red;
            o_blue = i_blue;
            o_green = i_green;
        end
    end
    else if (i_x >= (cursor_x_r[15:9] * 'd3 + 11'd532) && i_x >= (cursor_x_r[15:9] * 'd3 + 11'd542)) begin
        if (i_displacement == 0 && i_y == (cursor_y_r[15:9] * 'd3 + 11'd276)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h3ff;
        end
        else if (i_displacement > 0 && (i_y + i_displacement) == (cursor_y_r[15:9] * 'd3 + 11'd436)) begin
            o_red = 10'h3ff;
            o_green = 10'h3ff;
            o_blue = 10'h3ff;
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