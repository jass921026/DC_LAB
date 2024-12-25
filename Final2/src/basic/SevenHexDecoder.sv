/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */

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

module seven_hex_16_4 (
    input [15:0] i_hex,
    output logic [6:0] o_seven_3,
    output logic [6:0] o_seven_2,
    output logic [6:0] o_seven_1,
    output logic [6:0] o_seven_0
);

always_comb begin
    o_seven_3 = seven_hex_16(i_hex[15:12]);
    o_seven_2 = seven_hex_16(i_hex[11:8]);
    o_seven_1 = seven_hex_16(i_hex[7:4]);
    o_seven_0 = seven_hex_16(i_hex[3:0]);
end
endmodule

module seven_hex_16_2 (
    input [7:0] i_hex,
    output logic [6:0] o_seven_1,
    output logic [6:0] o_seven_0
);
always_comb begin
    o_seven_1 = seven_hex_16(i_hex[7:4]);
    o_seven_0 = seven_hex_16(i_hex[3:0]);
end
endmodule

module seven_hex_16_1 (
    input [3:0] i_hex,
    output logic [6:0] o_seven
);	
always_comb begin
    o_seven = seven_hex_16(i_hex);
end
endmodule