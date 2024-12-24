module Test (
	input i_rst_n,
	input i_clk,
    input[10:0] i_x,
    input[10:0] i_y,
    output[9:0] o_blue,
    output[9:0] o_red,
    output[9:0] o_green
);

logic [10:0] xcnt_w, xcnt_r;
logic [9:0] ycnt_w, ycnt_r;
logic [11:0] sumi,sumcnt;

assign sumi     =   i_x + i_y;
assign sumcnt   =   xcnt_r + ycnt_r;
assign o_blue   =   (i_x > xcnt_r && i_x < xcnt_r + 'd200) || (xcnt_r > 'd440 && i_x < xcnt_r - 'd440) ? 'b1111111111 : 'b0000000000;
assign o_red    =   (i_y > ycnt_r && i_y < ycnt_r + 'd150) || (ycnt_r > 'd330 && i_y < ycnt_r - 'd330) ? 'b1111111111 : 'b0000000000;
assign o_green  =   (sumi > xcnt_r + ycnt_r && sumi < sumcnt + 'd300) || (sumcnt > 'd820 && sumi < sumcnt - 'd820) ? 'b1111111111 : 'b0000000000;

always_comb begin
    xcnt_w  =   (i_x != 640 || i_y != 480) ? xcnt_r : (xcnt_r >= 'd640 ? 0 : xcnt_r+1);
    ycnt_w  =   (i_x != 640 || i_y != 480) ? ycnt_r : (ycnt_r >= 'd480 ? 0 : ycnt_r+1);
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		xcnt_r <= 0;
		ycnt_r <= 0;
	end
	else begin
		xcnt_r <= xcnt_w;
		ycnt_r <= ycnt_w;
	end
end

endmodule
