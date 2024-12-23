module kernel
#(  parameter width = 5,
    parameter height = 5,
    parameter bitwidth = 16
)
(
    input i_clk,
    input i_rst,
    input i_loading_weight,
    input [bitwidth-1:0] i_bias,
    input [width -1:0][bitwidth-1:0] i_weight,
    input [height-1:0][bitwidth-1:0] i_data,
    output [bitwidth-1:0] o_result
);
    logic [bitwidth-1:0] bias_r, bias_w;
    logic [width*height-1:0][bitwidth-1:0] result_i_inter, result_o_inter;
    logic [width*height-1:0][bitwidth-1:0] weight_i_inter, weight_o_inter;
    logic [width*height-1:0][bitwidth-1:0] data_i_inter  , data_o_inter  ;

    //logic [bitwidth-1:0] buf_data_i_inter[width];
    logic [width-1:0][bitwidth-1:0] buf_result_i_inter, buf_result_o_inter;


    //declare systonic nodes and output buffer
    genvar gv_i, gv_j;
    generate
        for (gv_i = 0; gv_i < height; gv_i++) begin : n_h
            for (gv_j = 0; gv_j < width; gv_j++) begin : n_w
                systonic_node #(.bitwidth(bitwidth)) node(
                    .i_clk(i_clk),
                    .i_rst(i_rst),
                    .i_is_loading_weight(is_loading_weight),
                    .i_result(result_i_inter[gv_i*width + gv_j]),
                    .o_result(result_o_inter[gv_i*width + gv_j]),
                    .i_data  (data_i_inter  [gv_i*width + gv_j]),
                    .o_data  (data_o_inter  [gv_i*width + gv_j]),
                    .i_weight(weight_i_inter[gv_i*width + gv_j]),
                    .o_weight(weight_o_inter[gv_i*width + gv_j])
                );
            end
        end
    endgenerate
    generate
        for (gv_j = 0; gv_j < width; gv_j++) begin : n_w
            output_buffer #(.bitwidth(bitwidth)) obuf(
                .i_clk(i_clk),
                .i_rst(i_rst),
                .i_data(data_o_inter[gv_j]),
                .i_result(buf_result_i_inter[gv_j]),
                .o_result(buf_result_o_inter[gv_j])
            );
        end
    endgenerate

    //connecting wires
    genvar i, j;
    for (j = 0; j < width; j++) begin
        assign weight_i_inter[j] = i_weight[j];
    end
    for (i = 1 ; i < height; i++) begin
        for (j = 0; j < width; j++) begin
            assign weight_i_inter[i*width + j] = weight_o_inter[(i-1)*width + j];
        end
    end


    
    for (j = 0; j < width; j++) begin
        assign result_i_inter[width*(height-1) + j] = 0; //bias add in output
    end
    for (i = 0; i < height-1; i++) begin
        for (j = 0; j < width; j++) begin
            assign result_i_inter[i*width + j] = result_o_inter[(i+1)*width + j];
        end
    end



    for (i=0; i<height; i++) begin
        assign data_i_inter[i*width] = i_data[i];
    end
    for (j = 1; j < width; j++) begin
        for (i = 0; i < height; i++) begin
            assign data_i_inter[i*width + j] = data_o_inter[i*width + j-1];
        end
    end

    //output
    assign buf_result_i_inter[0] = bias_r;
    generate
        for (j = 1; j < width; j++) begin 
            assign buf_result_i_inter[j] = buf_result_o_inter[j-1];
        end
    endgenerate
    assign o_result = buf_result_o_inter[width-1];

    assign bias_w = i_loading_weight ? i_bias : bias_r;


    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            bias_r <= 0;
        end

        else begin
            bias_r <= bias_w;
        end
    end

endmodule