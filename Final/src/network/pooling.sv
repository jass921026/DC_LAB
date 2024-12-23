//pure memory bound task
module pooling
//current 2x2 pooling support only
#(  parameter bitwidth = 16,
    parameter i_kernel_n,
    parameter i_width,
    parameter i_height,
    parameter kernel_width = 2, //fixed
    parameter kernel_height = 2, //fixed

    parameter SRAM_DATA_WIDTH = 16,
    parameter SRAM_ADDR_WIDTH = 20,
    parameter [SRAM_ADDR_WIDTH-1:0] DATA_ADDR   = 20'b0,
    parameter [SRAM_ADDR_WIDTH-1:0] RESULT_ADDR = 20'b0
)
(
    input i_clk,
    input i_rst,
    input i_enable,
    output o_finished,

    input  [SRAM_DATA_WIDTH-1:0] i_data,
    output o_wren,
    output [SRAM_DATA_WIDTH-1:0] o_data,
    output [SRAM_ADDR_WIDTH-1:0] o_data_addr
);

localparam pack_n = SRAM_DATA_WIDTH / bitwidth; //1
localparam i_data_n = i_width * i_height / pack_n;
localparam o_data_n = (i_width/kernel_width * i_height/kernel_height )  / pack_n; //no ceil


logic [3:0][bitwidth-1:0] load_buf_r, load_buf_w;
//logic [bitwidth-1:0] save_buf_r, save_buf_w;

logic [$clog2(i_kernel_n):0] kernel_i_r, kernel_i_w;
logic [$clog2(i_width):0] width_i_r, width_i_w;
logic [$clog2(i_height):0] height_i_r, height_i_w;
logic [SRAM_ADDR_WIDTH-1:0] out_data_addr_r, out_data_addr_w;
logic [bitwidth-1:0] out_data_r, out_data_w;

logic [2:0] load_buf_i_r, load_buf_i_w ;

logic [bitwidth-1:0] tmp1, tmp2;

logic wren_r, wren_w;

logic [2:0] state_r, state_w;

localparam S_IDLE = 3'b000;
localparam S_READ = 3'b001;
localparam S_SAVE = 3'b010;
localparam S_DONE = 3'b011;

//save method: each 2 data saved as 1 data

assign o_finished = (state_r == S_DONE);
assign o_wren = wren_r;
assign o_data = out_data_r;
assign o_data_addr = out_data_addr_r;


function [SRAM_DATA_WIDTH-1:0] read_addr_calc(//input [SRAM_ADDR_WIDTH-1:0] base, 
    input [$clog2(i_kernel_n):0] i_kern, input [$clog2(i_width):0] i_w, 
    input [$clog2(i_height):0] i_h);
    begin
        return DATA_ADDR + i_kern * (i_width * i_height) + i_h * i_width + i_w;
    end
endfunction

function [SRAM_DATA_WIDTH-1:0] write_addr_calc(//input [SRAM_ADDR_WIDTH-1:0] base, 
    input [$clog2(i_kernel_n):0] i_kern, input [$clog2(i_width):0] i_w, 
    input [$clog2(i_height):0] i_h);
    begin
        return RESULT_ADDR + i_kern * ((i_width)/2 * (i_height)/2) + i_h * (i_width)/2 + i_w;
    end
endfunction


always_comb begin
    state_r = state_w;
    kernel_i_r = kernel_i_w;
    load_buf_r = load_buf_w;
    wren_r = wren_w;
    out_data_addr_r = out_data_addr_w;
    out_data_r = out_data_w;



    case(state_r)
        S_IDLE: begin
            if(i_enable) begin
                state_w = S_READ;
                kernel_i_w = 0;
                load_buf_i_w = 3'b0;
                out_data_addr_w = DATA_ADDR;
            end
        end
        S_READ: begin
            case (load_buf_i_r)
                3: begin
                    state_w = S_SAVE;
                    load_buf_i_w = 3'b0;
                    out_data_addr_w = 0; //dummy
                end
                2: begin
                    load_buf_i_w = load_buf_i_r + 3'b1;
                    load_buf_w[load_buf_i_r] = i_data;
                    out_data_addr_w = read_addr_calc(kernel_i_r, width_i_r << 1 + 1 , height_i_r << 1 + 1);
                end
                1: begin
                    load_buf_i_w = load_buf_i_r + 1'b1;
                    load_buf_w[load_buf_i_r] = i_data;
                    out_data_addr_w = read_addr_calc(kernel_i_r, width_i_r << 1 , height_i_r << 1 + 1);
                end
                0: begin
                    load_buf_i_w = load_buf_i_r + 1'b1;
                    load_buf_w[load_buf_i_r] = i_data;
                    out_data_addr_w = read_addr_calc(kernel_i_r, width_i_r << 1 + 1 , height_i_r << 1);
                end        
                default: begin
                end        
            endcase 
        end
        S_SAVE: begin
            case (load_buf_i_r)
                1: begin
                    if (width_i_r == i_width >> 1 - 1) begin
                        if (height_i_r == i_height >> 1 - 1) begin
                            if (kernel_i_r == i_kernel_n - 1) begin
                                state_w = S_DONE;
                            end
                            else begin // kernel end
                                kernel_i_w = kernel_i_r + 1'b1;
                                load_buf_i_w = 3'b0;
                                out_data_addr_w = read_addr_calc(kernel_i_r, 0, 0);
                            end
                        end
                        else begin // line end
                            height_i_w = height_i_r + 1'b1;
                            load_buf_i_w = 3'b0;
                            out_data_addr_w = read_addr_calc(kernel_i_r, 0, (height_i_r+1) << 1);
                        end
                    end
                    else begin
                        width_i_w = width_i_r + 1'b1;
                        load_buf_i_w = 3'b0;
                        out_data_addr_w = read_addr_calc(kernel_i_r, (width_i_r + 1) << 1, height_i_r << 1);
                    end
                end
                0: begin
                    tmp1 = load_buf_r[0] > load_buf_r[1] ? load_buf_r[0] : load_buf_r[1];
                    tmp2 = load_buf_r[2] > load_buf_r[3] ? load_buf_r[2] : load_buf_r[3];
                    out_data_w = tmp1 > tmp2 ? tmp1 : tmp2;
                    out_data_addr_w = write_addr_calc(kernel_i_r, width_i_r , height_i_r );
                end
                default: begin
                end
            endcase
        end
           
    endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        state_w <= S_IDLE;
        kernel_i_w <= 0;
        load_buf_i_w <= 3'b0;
        wren_w <= 0;
        out_data_addr_w <= 0;
        out_data_w <= 0;
    end
    else begin
        state_w <= state_w;
        kernel_i_w <= kernel_i_w;
        load_buf_i_w <= load_buf_i_w;
        wren_w <= wren_w;
        out_data_addr_w <= out_data_addr_w;
        out_data_w <= out_data_w;
    end
end

endmodule