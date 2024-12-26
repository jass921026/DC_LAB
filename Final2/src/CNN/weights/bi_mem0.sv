`timescale 1ns/1ns
module bi_mem0 #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 128, DEPTH = 16) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
initial begin
mem[0] = 128'hfe74fbb1f13cffeefff60ff1ffed14cc;
mem[1] = 128'h0026002cffecffe706abffe30f8dee94;
mem[2] = 128'hf78dfbf1f6b3fc7c03520965feb8ff9b;
mem[3] = 128'hfe96ff47071201060658fc66081cfdfc;
mem[4] = 128'hfd57fcb3f911f9d9f724066704b4fe39;
mem[5] = 128'hfad705f6fb370498fbe6fcb6f5aaf93c;
mem[6] = 128'h0074fe40fe8affa0ffa0fe40ffb3ffb6;
mem[7] = 128'h01b5ff57025800aa00260177010a027d;
mem[8] = 128'h017b022eff1cff9e012600c7019dff66;
mem[9] = 128'hfef2025efd4ffe90008effd900f4ff35;
mem[10] = 128'h01c50336fdc2016cfe52fef10167ff87;
mem[11] = 128'hff63fefc00ad00c8004c024fff050150;
mem[12] = 128'hff580041fe06007cff330282ff3b012f;
mem[13] = 128'h028ffe5c00eb0048fdebfeab017200a7;
mem[14] = 128'hfb8dfc6cf858f985082dfb7b025200d5;
mem[15] = {32'h021ef901, 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000};
end

always @ (posedge clk) begin

q_a <= mem[addr_a];
end
always @ (posedge clk) begin

q_b <= mem[addr_b];
end

endmodule