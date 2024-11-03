`timescale 1ns/100ps

// `define max (a, b) \
//     ((a) > (b) ? (a) : (b))

module tb;
    localparam CLK = 10;
    localparam HCLK = CLK/2;
    localparam memsize = 2**10; // 1K for testing
    localparam memaddr = 10; // 10 bits for addressing

    logic clk, daclrck;
    logic rst, start, pause, stop, interpolation, fast;
    logic [2:0] speed;
    logic [15:0] sram_data[0:memsize-1], dac_data[0:memsize-1], golden[0:memsize-1];
    logic [15:0] sram_block, dac_block;
    logic [19:0] sram_addr;
    int fd, fg;
    initial clk = 0;
    initial daclrck = 0;
    always #(HCLK) clk = ~clk;
    

    AudDSP dsp(
        .i_rst_n(~rst),
        .i_clk(clk),
        .i_start(start),
        .i_pause(pause),
        .i_stop(stop),
        .i_fast(fast),
        .i_speed(speed),
        .i_interpolation(interpolation),
        .i_daclrck(daclrck),
        .i_sram_data(sram_block),
        .o_dac_data(dac_block),
        .o_sram_addr(sram_addr)
    );

    initial begin
        $fsdbDumpfile("lab3_dsp.fsdb");
        $fsdbDumpvars;
        fd = $fopen("./dsp_testdata.txt", "rb");
        fg = $fopen("./dsp_golden.txt", "rb");

        // Read test data
        for (int i = 0; i < memsize; i++) begin
            $fscanf(fd, "%h", sram_data[i]);
        end
            



        for (int iter = 0 ; iter < 22; iter++) begin
            // prepare test data
            $fscanf(fd, "%d %d %d" ,fast, speed, interpolation);
            $display("config %d %d %d", fast, speed, interpolation);
            // read golden data
            for (int i = 0; i < memsize; i++) begin
                $fscanf(fg, "%h", golden[i]);
            end
            $display("Golden data: %h %h %h %h", golden[0], golden[1], golden[2], golden[3]);
            
            daclrck = 1;
            rst = 1;
            #(3*CLK)
            rst = 0;
            start = 1;
            #(CLK)
            start = 0;


            // function int maxab(int a, int b);
            //     return (a > b) ? a : b;
            // endfunction

            
            for (int i = 0; i < (fast ? memsize/speed :memsize); i++) begin
                daclrck = 0;
                #(5*CLK)
                // collect output data
                //$display("Collect %d th data", i);
                dac_data[i] = dac_block;
                if (dac_data[i] !== golden[i]) begin
                    $display("Error at %d: %h != %h", i, dac_data[i], golden[i]);
                    $finish;
                end

                daclrck = 1;
                #(5*CLK);
            end
            // TODO: add random pause

            stop = 1;
            #(CLK)
            stop = 0;

            // compare result
            $display("Obtain Data: %h %h %h %h", dac_data[0], dac_data[1], dac_data[2], dac_data[3]);
        end
        // no error
        $display("Test passed.");
        $finish;
    end


    always begin //work sram
        #(CLK/2)
        sram_block = sram_data[sram_addr[0 +: memaddr]];
    end

    initial begin //timeout
        #(7000000*CLK)
        $display("Too slow, abort.");
        $finish;
    end

    initial begin //timer
        for (int i = 0; 1; i++) begin
            #(100000*CLK)
            $display("Time: %d", i*100000);
        end
    end

endmodule
