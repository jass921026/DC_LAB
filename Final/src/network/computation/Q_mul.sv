module Q_mul
// Format: Qa.b means a bits before the decimal point and b bits after the decimal point
// Total a + b + 1 bits
//code inpsired from: https://en.wikipedia.org/wiki/Q_(number_format)
#(  parameter Qa = 1,
    parameter Qb = 14,
    parameter bitwidth = Qa + Qb + 1)
(
    input  signed [bitwidth-1:0] a,
    input  signed [bitwidth-1:0] b,
    output signed [bitwidth-1:0] result
);
localparam K = (1 << (Qb - 1));

logic [bitwidth*2-1:0] tmp1;
logic [bitwidth*2-1:0] tmp2;

assign tmp1 = (2*bitwidth)'(a) * (2*bitwidth)'(b);
assign tmp2 = tmp1 >> (Qb);
Q_sat #(.inputwidth(bitwidth*2), .outputwidth(bitwidth)) sat(
    .a(tmp2),
    .result(result)
);
endmodule