module convolution
#(  parameter i_kernel_n,
    parameter o_kernel_n,
    parameter i_width,
    parameter i_height,
    parameter kernel_height = 5,
    parameter kernel_width = 5,
    parameter bitwidth = 16,

    parameter SRAM_DATA_WIDTH = 16,
    parameter SRAM_ADDR_WIDTH = 20,
    parameter [SRAM_ADDR_WIDTH-1:0] DATA_ADDR   = 20'b0,
    parameter [SRAM_ADDR_WIDTH-1:0] WEIGHT_ADDR = 20'b0,
    parameter [SRAM_ADDR_WIDTH-1:0] OUTPUT_ADDR = 20'b0

)
(
    input  i_clk,
    input  i_rst,
    input  i_enable,
    output o_finished,

    input  [SRAM_DATA_WIDTH-1:0] i_data,
    output [SRAM_DATA_WIDTH-1:0] o_data,
    output [SRAM_ADDR_WIDTH-1:0] o_data_addr,

    //extern kernel
    output [SRAM_DATA_WIDTH-1:0] o_weight,
    output [SRAM_ADDR_WIDTH-1:0] o_weight_addr,

    output o_kern_loading_weight,
    output [bitwidth-1:0] o_kern_bias,
    output [kernel_width -1:0][bitwidth-1:0] o_kern_weight,
    output [kernel_height-1:0][bitwidth-1:0] o_kern_data,
    input  [bitwidth-1:0] i_kern_result
);

    logic [3:0] state_r, state_w;  
    logic [kernel_height:0][bitwidth-1:0] ln_buf_in, ln_buf_out;
    logic [i_width-1:0][bitwidth-1:0] weight_buf_r, weight_buf_w;
    logic [bitwidth-1:0] bias_buf_r, bias_buf_w;
    logic [$clog2(kernel_height):0] cnt_h_r, cnt_h_w;
    logic [$clog2(kernel_width):0] cnt_w_r, cnt_w_w;
    logic [$clog2(i_kernel_n):0] cnt_ikern_r, cnt_ikern_w;
    logic [$clog2(o_kernel_n):0] cnt_okern_r, cnt_okern_w;
    logic uni_flag_r, uni_flag_w;
    logic data_buf_enable, out_buf_enable;
    logic [bitwidth-1:0] out_buf_in, out_buf_out;
    logic wren_r, wren_w;
    logic out_data_addr_r, out_data_addr_w;

    localparam S_IDLE = 4'b0000;
    localparam S_NEW_OUTPUT = 4'b0001;
    localparam S_LOAD_KERNEL = 4'b0010;
    localparam S_LOAD_LINES = 4'b0011;
    localparam S_CONV = 4'b0100;
    localparam S_STORE = 4'b0101;
    localparam S_DONE = 4'b0110;

    assign o_finished = (state_r == S_DONE);
    assign o_wren = wren_r;
    assign o_data = out_buf_out;
    assign o_data_addr = out_data_addr_r;

function [SRAM_DATA_WIDTH-1:0] read_addr_calc(//input [SRAM_ADDR_WIDTH-1:0] base, 
    input [$clog2(i_kernel_n):0] i_kern, input [$clog2(o_data_n):0] o_kern,
    input [$clog2(i_width):0] i_w, input [$clog2(i_height):0] i_h);
    begin
        return DATA_ADDR + i_kern * (i_width * i_height * o_kernel_n) + o_kern * (i_width * i_height ) + i_h * i_width + i_w;
    end
endfunction

function [SRAM_DATA_WIDTH-1:0] kern_addr_calc(//input [SRAM_ADDR_WIDTH-1:0] base, 
    input [$clog2(i_kernel_n):0] i_kern, input [$clog2(o_data_n):0] o_kern,
    input [$clog2(i_width):0] i_w, input [$clog2(i_height):0] i_h);
    begin
        return WEIGHT_ADDR + i_kern * ((kernel_width * kernel_height + 1) * o_kernel_n) + o_kern * (kernel_width * kernel_height + 1) + i_h * kernel_width + i_w ;
    end
endfunction

function [SRAM_DATA_WIDTH-1:0] write_addr_calc(//input bit [SRAM_ADDR_WIDTH-1:0] base, 
    input [$clog2(i_kernel_n):0] i_kern, input [$clog2(o_data_n):0] o_kern,
    input [$clog2(i_width):0] i_w, input [$clog2(i_height):0] i_h);
    begin
        return OUTPUT_ADDR + i_kern * ((i_width-kernel_width+1) * (i_height - kernel_height + 1) * o_kernel_n) + o_kern * ((i_width-kernel_width+1) * (i_height - kernel_height + 1)) + i_h * (i_width-kernel_width+1) + i_w;
    end
endfunction

    genvar gv_i, gv_j;
    generate
        for (gv_i = 0 ; gv_i < kernel_height + 1 ; gv_i++) begin : ln_buf 
            line_buffer #( 
                .linelen(i_width+1) //for extra delay
            )
            lb(
                .i_clk(i_clk),
                .i_rst(i_rst),
                .i_enable(data_buf_enable),
                .i_data(ln_buf_in[gv_i]),
                .o_data(ln_buf_out[gv_i])
            );
        end
    endgenerate

    line_buffer  #(
        .linelen(i_width*i_height)
    ) output_buf (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_enable(out_buf_enable),
        .i_data(out_buf_in),
        .o_data(out_buf_out)
    );

    always_comb begin 
        state_w = state_r;


        case(state_r)
            S_IDLE: begin
                if(i_enable) begin
                    state_w = S_NEW_OUTPUT;
                    o_data_addr = WEIGHT_ADDR;
                    cnt_h_w = 0;
                    cnt_w_w = 0;
                    uni_flag_w = 0;
                end
            end
            S_NEW_OUTPUT: begin
                if (cnt_okern_r == o_kernel_n - 1) begin //done
                    state_w = S_DONE;
                end
                else begin
                    state_w = S_LOAD_KERNEL;
                    o_data_addr = kern_addr_calc(cnt_ikern_r, cnt_okern_r, cnt_w_r, cnt_h_r);
                    cnt_ikern_w = 0;
                    cnt_okern_w = cnt_okern_r + 1;
                end
            end
            S_LOAD_KERNEL: begin //include bias
                //first data is bias
                //o_kern_loading_weight = 1 ;
                if(!uni_flag_r) begin
                    o_data_addr = kern_addr_calc()
                    bias_buf_w = i_data;
                    uni_flag_w = 1;
                end
                else begin
                    //2 phases: 1st phase load 5 data to buffer, 2nd phase from buffer to kernel;
                    if (cnt_w_r < kernel_width) begin
                        if (cnt_h_r > kernel_height) begin
                            cnt_h_w = 0;
                            state_w = S_LOAD_LINES;
                        end
                        else begin
                            cnt_h_w = cnt_h_r + 1;
                        end
                        o_kern_loading_weight = 1;
                        
                    end
                    else begin
                        cnt_h_w = cnt_h_r + 1;
                        cnt_w_w = 0;
                        weight_buf_w[cnt_w_r] = i_data;
                    end
                end

            end
            S_LOAD_LINES: begin
                //load 5 lines to buffer
                
                if(cnt_w_r < i_width-1) begin
                    ln_buf_in[cnt_h_r] = i_data;
                    cnt_w_w = cnt_w_r + 1;
                end
                else begin
                    if (cnt_h_r == kernel_height-1) begin
                    end
                    else begin
                        cnt_h_w = cnt_h_r + 1;
                        cnt_w_w = 0;
                    end
                end
                

            end
            S_CONV: begin
                //ignore every first 5 result
                if(i_data_addr == i_weight_addr + i_kernel + i_height + i_width - 1) begin
                    state_w = S_STORE;
                    o_data_addr = o_result_addr;
                end
            end
            S_STORE: begin
                //drain from out buffer
                if(i_data_addr == o_result_addr + o_kernel - 1) begin
                    state_w = S_DONE;
                    o_finished = 1;
                end
            end
            S_DONE: begin
                if(i_enable) begin
                    state_w = S_LOAD_KERNEL;
                    o_data_addr = i_weight_addr;
                end
            end
        endcase
        
    end 



endmodule