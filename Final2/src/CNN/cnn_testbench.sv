`timescale 1ns/100ps

module CNN_testbench
#(
    parameter GS_BITS = 8, 
    parameter BCD_BITS = 4 
)
(
);

    localparam CLK = 10;
	localparam HCLK = CLK/2;

    logic clk, rst_n;
    always #HCLK clk = ~clk;

    initial begin
        clk = 1'b0;
    end

    //pixel

    logic [29:0][29:0] digit_1 = '{
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000011000000000000000,
            30'b000000011111111000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000011000000000000000,
            30'b000000111111111111111110000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000
    };

    logic [29:0][29:0] digit_2 = '{
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000111111111111000000000,
            30'b000001111000000000000110000000,
            30'b000110000000000000000110000000,
            30'b000000000000000000000110000000,
            30'b000000000000000000001100000000,
            30'b000000000000000000111000000000,
            30'b000000000000000011100000000000,
            30'b000000000000001110000000000000,
            30'b000000000000011000000000000000,
            30'b000000000000110000000000000000,
            30'b000000000001100000000000000000,
            30'b000000000111000000000000000000,
            30'b000000001110000000000000000000,
            30'b000000001100000000000000000000,
            30'b000000011000000000000000000000,
            30'b000000110000000000000000000000,
            30'b000001100000000000000000000000,
            30'b000001100000000000000000000000,
            30'b000011111111111111111110000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000
    };



    logic [29:0][29:0] digit_8 = '{
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000011111111100000000000,
            30'b000000001111111111111100000000,
            30'b000000111111111111111110000000,
            30'b000011111000000000001111000000,
            30'b000111100000000000000111110000,
            30'b000111100000000000001111100000,
            30'b000111110000000000011111000000,
            30'b000001111100000000111100000000,
            30'b000000011110000011111000000000,
            30'b000000000111111111100000000000,
            30'b000000000011111110000000000000,
            30'b000000000111111111110000000000,
            30'b000000000111100011111000000000,
            30'b000000001111000000011111000000,
            30'b000000111110000000000111100000,
            30'b000001111000000000000001111000,
            30'b000011110000000000000001111000,
            30'b001111000000000000000011110000,
            30'b001111000000000000000011110000,
            30'b000111100000000000000111100000,
            30'b000011111111111111111111000000,
            30'b000000111111111111111100000000,
            30'b000000001111111111100000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000,
            30'b000000000000000000000000000000
    };

    // CNN
    logic [7:0] pixel_i;
    logic pixel_i_valid;
    logic [3:0] digit_o;
    logic digit_o_valid;
    CNN_top cnn0 (
        .clk(clk),
        .rst(rst_n),
        .pixel_i(pixel_i),
        .pixel_i_valid(pixel_i_valid),
        .digit_o(digit_o),
        .digit_o_valid(digit_o_valid)
    );

    initial begin
        $fsdbDumpfile("CNN.fsdb");
        $fsdbDumpvars;
        rst_n = 0;
        #(6*CLK)
        rst_n = 1;
        #(2*CLK)
        for (int i = 0; i < 30; i++) begin
            for (int j = 0; j < 30; j++) begin
                pixel_i = digit_8[i][j] ? 8'h0 : 8'hff ;
                pixel_i_valid = 1;
                #(CLK);
            end
        end
        pixel_i_valid = 1;
        #(2*CLK)
        pixel_i_valid = 0;

        @(posedge cnn0.digit_o_valid);
        $display("Finished.");
        $finish;
    end

    //abort 
    initial begin
        #(100000*CLK)
        $display("Automatic abort.");
        $finish;
    end

endmodule