module line_buffer
# ( parameter linelen,
    parameter bitwidth = 16
)
(
    input i_clk,
    input i_rst,
    input i_enable,
    input signed [bitwidth-1:0] i_data,
    output signed [bitwidth-1:0] o_data
);
    logic [bitwidth-1:0] data_r[linelen], data_w[linelen];
    
    assign o_data = data_r[linelen-1];
    

    always_comb begin
        if (i_enable) begin
            data_w[0] = i_data;
            for (int i = 1; i < linelen; i++) begin
                data_w[i] = data_r[i-1];
            end
        end
        else begin
            for (int i = 0; i < linelen; i++) begin
                data_w[i] = data_r[i];
            end
        end
    end

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            for (int i = 0; i < linelen; i++) begin
                data_r[i] <= 0;
            end
        end
        else begin
            for (int i = 0; i < linelen; i++) begin
                data_r[i] <= data_w[i];
            end
        end
    end
endmodule