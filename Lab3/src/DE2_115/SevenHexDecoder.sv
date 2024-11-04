/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */

module seven_hex_16_4 (
	input [15:0] i_hex,
	output logic [6:0] o_seven_3,
	output logic [6:0] o_seven_2,
	output logic [6:0] o_seven_1,
	output logic [6:0] o_seven_0
);

function logic [6:0] seven_hex_16;
	input logic [3:0] value;
	begin
		case (value)
			4'h0: seven_hex_16 = 7'b1000000;
			4'h1: seven_hex_16 = 7'b1111001;
			4'h2: seven_hex_16 = 7'b0100100;
			4'h3: seven_hex_16 = 7'b0110000;
			4'h4: seven_hex_16 = 7'b0011001;
			4'h5: seven_hex_16 = 7'b0010010;
			4'h6: seven_hex_16 = 7'b0000010;
			4'h7: seven_hex_16 = 7'b1111000;
			4'h8: seven_hex_16 = 7'b0000000;
			4'h9: seven_hex_16 = 7'b0010000;
			4'ha: seven_hex_16 = 7'b0001000;
			4'hb: seven_hex_16 = 7'b0000011;
			4'hc: seven_hex_16 = 7'b1000110;
			4'hd: seven_hex_16 = 7'b0100001;
			4'he: seven_hex_16 = 7'b0000110;
			4'hf: seven_hex_16 = 7'b0001110;
		endcase
	end
endfunction

assign o_seven_3 = seven_hex_16(i_hex[15:12]);
assign o_seven_2 = seven_hex_16(i_hex[11:8]);
assign o_seven_1 = seven_hex_16(i_hex[7:4]);
assign o_seven_0 = seven_hex_16(i_hex[3:0]);
endmodule

module SevenHexDecoder (
	input        [3:0] i_hex,
	output logic [6:0] o_seven_ten,
	output logic [6:0] o_seven_one
);

parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;
always_comb begin
	case(i_hex)
		4'h0: begin o_seven_ten = D0; o_seven_one = D0; end
		4'h1: begin o_seven_ten = D0; o_seven_one = D1; end
		4'h2: begin o_seven_ten = D0; o_seven_one = D2; end
		4'h3: begin o_seven_ten = D0; o_seven_one = D3; end
		4'h4: begin o_seven_ten = D0; o_seven_one = D4; end
		4'h5: begin o_seven_ten = D0; o_seven_one = D5; end
		4'h6: begin o_seven_ten = D0; o_seven_one = D6; end
		4'h7: begin o_seven_ten = D0; o_seven_one = D7; end
		4'h8: begin o_seven_ten = D0; o_seven_one = D8; end
		4'h9: begin o_seven_ten = D0; o_seven_one = D9; end
		4'ha: begin o_seven_ten = D1; o_seven_one = D0; end
		4'hb: begin o_seven_ten = D1; o_seven_one = D1; end
		4'hc: begin o_seven_ten = D1; o_seven_one = D2; end
		4'hd: begin o_seven_ten = D1; o_seven_one = D3; end
		4'he: begin o_seven_ten = D1; o_seven_one = D4; end
		4'hf: begin o_seven_ten = D1; o_seven_one = D5; end
	endcase
end

endmodule