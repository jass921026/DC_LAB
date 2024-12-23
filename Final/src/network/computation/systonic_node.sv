// node structure: https://www.researchgate.net/publication/317574806_Automated_Systolic_Array_Architecture_Synthesis_for_High_Throughput_CNN_Inference_on_FPGAs 
// not use currently 
module alu_node
//perform multiplication and addition
#(parameter bitwidth = 16)
(
    input i_clk,
    input i_rst,
    input i_is_loading_weight,
    input  signed [bitwidth-1:0] i_result,
    output signed [bitwidth-1:0] o_result,
    input  signed [bitwidth-1:0] i_data,
    output signed [bitwidth-1:0] o_data,
    input  signed [bitwidth-1:0] i_weight,
    output signed [bitwidth-1:0] o_weight

);
    logic [bitwidth-1:0] result_r, result_w;
    logic [bitwidth-1:0] data_out_r, data_out_w;
    logic [bitwidth-1:0] weight_r, weight_w;
    logic [bitwidth-1:0] tmp_result;

    assign o_result = result_r;
    assign o_data = data_out_r;
    assign o_weight = weight_r;

    Q_mul #(.bitwidth(bitwidth)) mul(
        .a(i_data),
        .b(weight_r),
        .result(tmp_result)
    );

    always_comb begin 
        result_w = result_r;
        data_out_w = data_out_r;
        weight_w = weight_r;

        if (i_is_loading_weight) begin
            result_w = 0 ;
            data_out_w = 0;
            weight_w = i_data;
        end
        else begin
            result_w = tmp_result + i_result;
            data_out_w = i_data;
        end
        
    end

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            result_r    <= 0;
            data_out_r  <= 0;
            weight_r    <= 0;
        end
        else begin
            result_r    <= result_w;
            data_out_r  <= data_out_w;
            weight_r    <= weight_w;
        end
    end
    
endmodule
