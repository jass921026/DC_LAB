module add_hand_write (
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
always_comb begin
    if (i_displacement==0 && i_x >= 536 && i_x < 636 && i_y >= 180 && i_y < 280)begin
        if (i_y <= 184 || i_y >= 275 || i_x <= 540 || i_x >= 631) begin
            o_blue = 10'h3ff;
            o_red = 10'h3ff;
            o_green = 10'h3ff;
        end
        else begin
            if (i_handwrite['d899-((32'(i_y-184) * 16'h5555) >> 16) * 'd30 - ((32'(i_x-540) * 16'h5555) >> 16)]) begin
                o_blue = 10'h3ff;
                o_red = 10'h3ff;
                o_green = 10'h3ff;
            end
            else begin
                o_blue = i_blue;
                o_red = i_red;
                o_green = i_green;
            end
        end
    end
    else if (i_displacement>0 && i_x >= 536 && i_x < 636 && i_y >= 330 - i_displacement && i_y < 430 - i_displacement) begin
        if (i_y <= 334 - i_displacement || i_y >= 425 - i_displacement || i_x <= 540 || i_x >= 631) begin
            o_blue = 10'h3ff;
            o_red = 10'h3ff;
            o_green = 10'h3ff;
        end
        else begin
            o_blue = i_blue;
            o_red = i_red;
            o_green = i_green;
        end
    end
    else begin
        o_blue = i_blue;
        o_red = i_red;
        o_green = i_green;
    end
end
endmodule