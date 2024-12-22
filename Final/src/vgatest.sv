module Test (
	input i_rst_n,
	input i_clk,
    input read,
    output[9:0] o_blue,
    output[9:0] o_red,
    output[9:0] o_green
);

logic [10:0] xcnt_w, xcnt_r;
logic [9:0] ycnt_w, ycnt_r;

always_comb begin
    xcnt_w  =   xcnt_r+1;
    ycnt_w  =   ycnt_r>
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
