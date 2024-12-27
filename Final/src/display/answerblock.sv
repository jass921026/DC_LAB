module add_hand_write (
    input i_clk,
    input i_rst_n,
    input[10:0] i_x,
    input[10:0] i_y,
    input[9:0] i_blue,
    input[9:0] i_red,
    input[9:0] i_green,
    output[9:0] o_blue,
    output[9:0] o_red,
    output[9:0] o_green,
    input[10:0] i_displacement,
    input[899:0] i_handwrite
);

logic [9:0] blue, blue_next;
logic [9:0] red, red_next;
logic [9:0] green, green_next;

assign o_blue = blue;
assign o_red = red;
assign o_green = green;

always_comb begin

    if (i_displacement==0 && i_x >= 536 && i_x < 636 && i_y >= 180 && i_y < 280)begin
        if (i_y <= 184 || i_y >= 275 || i_x <= 540 || i_x >= 631) begin
            blue_next = 10'h3ff;
            red_next = 10'h3ff;
            green_next = 10'h3ff;
        end
        else begin
            if (i_handwrite['d899-((32'(i_y-184) * 16'h5555) >> 16) * 'd30 - ((32'(i_x-540) * 16'h5555) >> 16)]) begin
                blue_next = 10'h3ff;
                red_next = 10'h3ff;
                green_next = 10'h3ff;
            end
            else begin
                blue_next = i_blue;
                red_next = i_red;
                green_next = i_green;
            end
        end
    end
    else if (i_displacement>0 && i_x >= 536 && i_x < 636 && i_y >= 330 - i_displacement && i_y < 430 - i_displacement) begin
        if (i_y <= 334 - i_displacement || i_y >= 425 - i_displacement || i_x <= 540 || i_x >= 631) begin
            blue_next = 10'h3ff;
            red_next = 10'h3ff;
            green_next = 10'h3ff;
        end
        else begin
            blue_next = i_blue;
            red_next = i_red;
            green_next = i_green;
        end
    end
    else begin
        blue_next = i_blue;
        red_next = i_red;
        green_next = i_green;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        blue <= 0;
        red <= 0;
        green <= 0;
    end
    else begin
        blue <= blue_next;
        red <= red_next;
        green <= green_next;
    end
end

endmodule