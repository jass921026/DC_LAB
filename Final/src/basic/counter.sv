module Counter 
#(
    parameter WIDTH = 20,
    parameter MAX_COUNT = 524288
)
(
    input wire clk,
    input wire rst_n,
    input wire enable,
    output wire [WIDTH-1:0] count
);

    assign count = count_r;
    // Internal signals
    reg [WIDTH-1:0] count_r, count_w;

    always_comb begin
        if (enable) begin
            if (count_r > MAX_COUNT) begin
                count_w = 0;
            end
            else begin
                count_w = count_r + 1;
            end
        end
        else begin
            count_w = count_r;
        end
    end

    // Counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            count_r <= 0;
        end 
        else begin
            count_r <= count_w;
        end
    end
endmodule