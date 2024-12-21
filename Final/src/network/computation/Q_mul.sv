module Q_mul
// Format: Qa.b means a bits before the decimal point and b bits after the decimal point
// Total a + b + 1 bits
//code inpsired from: https://en.wikipedia.org/wiki/Q_(number_format)
#(  parameter Qa = 4,
    parameter Qb = 3,
    parameter bitwidth = Qa + Qb + 1)
(
    input  wire signed [bitwidth-1:0] a,
    input  wire signed [bitwidth-1:0] b,
    output wire signed [bitwidth-1:0] result
);
localparam K = (1 << (Qb - 1));

wire [bitwidth*2-1:0] tmp1;
wire [bitwidth*2-1:0] tmp2;

assign tmp1 = (2*bitwidth)'(a) * (2*bitwidth)'(b);
assign tmp2 = tmp1 >> (Qb);
Q_sat #(.inputwidth(bitwidth*2), .outputwidth(bitwidth)) sat(
    .a(tmp2),
    .result(result)
);
endmodule