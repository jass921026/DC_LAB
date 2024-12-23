module output_buffer
# ( parameter bitwidth = 16
)
(
    input i_clk,
    input i_rst,
    input signed [bitwidth-1:0] i_data,
    input signed [bitwidth-1:0] i_result,
    output signed [bitwidth-1:0] o_result
);
    logic [bitwidth-1:0] result_r, result_w;
    
    assign o_result = result_r;
    assign result_w = i_data + i_result;

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            for (int i = 0; i < bitwidth; i++) begin
                result_r[i] <= 0;
            end
        end
        else begin
            for (int i = 0; i < bitwidth; i++) begin
                result_r[i] <= result_w[i];
            end
        end
    end
endmodule