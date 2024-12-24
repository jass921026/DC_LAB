module Q_sat()
# (parameter inputwidth = 16)
# (parameter outputwidth = 8)
(
    input  wire signed [inputwidth-1:0] a,
    output wire signed [outputwidth-1:0] result
);
    assign result = (a > (1 << (outputwidth-1)) - 1) ? (1 << (outputwidth-1)) - 1 : (a < -(1 << (outputwidth-1))) ? -(1 << (outputwidth-1)) : a[inputwidth-1:inputwidth-outputwidth];
endmodule