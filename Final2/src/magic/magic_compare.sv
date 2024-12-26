module Magic_compare
(
    input [3:0] idx_a,
    input [3:0] idx_b,
    input [15:0] son_a, // 分子
    input [15:0] son_b, 
    input [15:0] mom_a, // 分母
    input [15:0] mom_b,
    output [3:0] idx_won,
    output [15:0] son_won,
    output [15:0] mom_won
);

    logic [31:0] prod_a, prod_b;

    assign prod_a = 32'(son_a) * mom_b;
    assign prod_b = 32'(son_b) * mom_a;

    assign idx_won = (prod_a >= prod_b) ? idx_a : idx_b;
    assign son_won = (prod_a >= prod_b) ? son_a : son_b;
    assign mom_won = (prod_a >= prod_b) ? mom_a : mom_b;

endmodule