module sram 
#(
    parameter ADDR_WIDTH = 20,
    parameter DATA_WIDTH = 16
)
(
    output [ADDR_WIDTH-1:0] o_SRAM_ADDR,
	inout  [DATA_WIDTH-1:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,

    input i_wren,
    input [ADDR_WIDTH-1:0] i_addr,
    input [DATA_WIDTH-1:0] i_data,
    output [DATA_WIDTH-1:0] o_data
);

    // SRAM control signals
    assign o_SRAM_CE_N = 1'b0;
    assign o_SRAM_OE_N = 1'b0;
    assign o_SRAM_LB_N = 1'b0;
    assign o_SRAM_UB_N = 1'b0;
    assign o_SRAM_WE_N = ~i_wren;

    assign o_SRAM_ADDR = i_addr;
    assign io_SRAM_DQ = i_wren ? i_data : 16'dz;
    assign o_data = io_SRAM_DQ;

endmodule
