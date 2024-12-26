`timescale 1ns/1ns

module wt_mem6 #(parameter ADDR_WIDTH = 11, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'hf6d1125a0fe314181da01824022d07ba0282;
mem[1] = 144'h14bffe0800f41c7dfeff18381b290982fcb8;
mem[2] = 144'h038807330086025203f003c6001b02c8066f;
mem[3] = 144'h007502e30016027301f502d3f896fe5902cb;
mem[4] = 144'h0159095f019b089406fe08c0018b066ffd92;
mem[5] = 144'h035400f2fe21fd9a00a20465fa80febefaa8;
mem[6] = 144'h013c0716fcd6073f0ce706efff49007dfedd;
mem[7] = 144'h00bf03efff77fa1a05d8ffe0fd210197fe38;
mem[8] = 144'hf530fa3cfd240282fe3c05ee075808bd0ac3;
mem[9] = 144'hfa7ef88c0062043803d8fd4f0118074503e7;
mem[10] = 144'hf10bfb6c0351f31e01730b02001607fa08af;
mem[11] = 144'hf990f9d7fcf7f91c008c005a01bafeb5090d;
mem[12] = 144'hf874f102f5c5f56ef765f82a037a00a10a5b;
mem[13] = 144'h0447fc2cfdb302d8fd5f05d8069e02c80a77;
mem[14] = 144'hfb17fe5206df00df0b17039a044803740183;
mem[15] = 144'hf390f5bdf883ff1b046e05b5034ffbeff928;
mem[16] = 144'hfcc806c00c72f97709750e72fae50a2608c3;
mem[17] = 144'hf51cfe780209f4bdf737072eff3efa46fd91;
mem[18] = 144'hfcd7fc5502b906eb06d3ffb3082f090bfd4d;
mem[19] = 144'hfa45fcc6fe22fb6901c80484ffae02f8fefa;
mem[20] = 144'h03f4fcd8fb9f08260569fe4e038002400053;
mem[21] = 144'h005b0289f7980280038c008bf886fc7efcfc;
mem[22] = 144'h0845fce4ef4e095bff9cf2090b62ff0bf043;
mem[23] = 144'h03290a180081060904ce00480ae7098cfe5f;
mem[24] = 144'hf8daf9c3fcf70131fcdffdb1032e01c6fec2;
mem[25] = 144'h007ff966fb430076fac1fc25fd110120fb85;
mem[26] = 144'hf5cdf252f3d80308fdd6057409f10dae0c51;
mem[27] = 144'h00d2f936f8dc01a003e9ffc000ec006704d5;
mem[28] = 144'hfae403220072018d013809a50578ff38ff6d;
mem[29] = 144'hf913fb57fb0df8ecfcfd009e02f901e7fb1f;
mem[30] = 144'hf1bef233f86efb73f832068400a107b20b3a;
mem[31] = 144'h02b3fab4fe28fd00016b0275052f0b120a87;
mem[32] = 144'h01a50676f9b1067e023efebafe5aff91f3fa;
mem[33] = 144'hfa4dfdb3fc16ff7ffe16fc46fcb002a0fd59;
mem[34] = 144'h0498027b0140080e085c0a250188086a05d5;
mem[35] = 144'hfbaafc62fd21fe800409fc42f619ff8b01eb;
mem[36] = 144'hfc0cfc1afb01005505ff02fe01770a0d0878;
mem[37] = 144'hfcc2fd98fa4000a7026f027fff28021e08f4;
mem[38] = 144'h01a7fb6cf0fd0920077102990212021d0349;
mem[39] = 144'hfb5a0070f918fbf1057307d7f4500392ff57;
mem[40] = 144'hf96ffa8ff5bf05720b04031709fd06d307d5;
mem[41] = 144'h012efff0fb1eff55064a079f003d045900b6;
mem[42] = 144'h01a8faa0fec605740b85079901ba0b2c0483;
mem[43] = 144'hfc3201f9f99b03b806510407fd72fd92fd74;
mem[44] = 144'h099eff45f5c000f4f580f726007ffb7ffa9f;
mem[45] = 144'h0a740311fe61026105d605b3061d0406ff4a;
mem[46] = 144'hf79e00f20bb2f399ffb8076df7b2fe720e23;
mem[47] = 144'h01befbb8055502c1fc8b080af8f3010903cb;
mem[48] = 144'h03870073f07604db00b3f8190b6afa50f825;
mem[49] = 144'h02efff3afe88060804fdfeb8ff8a015d013d;
mem[50] = 144'h048f03d6fcc802b3028ffbbcfda6fdae00e9;
mem[51] = 144'hfcb9fb5dffeefcc8ffddf9eafdc60388009a;
mem[52] = 144'hff36fe9a0237f23b018d0613f2cdfdf30df4;
mem[53] = 144'h0257f9ba039d031301aa0745fdf8fc4505f0;
mem[54] = 144'hfed8039b0413fc63fca1fb7d00b9ff550052;
mem[55] = 144'hfcdc0277fc11fc15fdd8fa3001b100dafe5b;
mem[56] = 144'h0fb60f5d12b9006905310556f1c1f119f293;
mem[57] = 144'h037e05db083204220165050cf8e3fb67f93e;
mem[58] = 144'h025b057affea029d053d02f2f525fd96f7c8;
mem[59] = 144'hff0a09a303c4016b05beff2ff3cef6f9fc98;
mem[60] = 144'hf32400750103fd7d061d00450b7504bf001e;
mem[61] = 144'hf82af467fcf0fdc101d5fdf004e405f2072d;
mem[62] = 144'hfdef0460fcae09030b89082401540321fe5c;
mem[63] = 144'hfd87fbcefbae0002042efb53f6a2001c0174;
mem[64] = 144'hfc9c04ed019b04b5034a08ee072704ab04a7;
mem[65] = 144'hf7f4fd7e0075fa06069004ba039304620452;
mem[66] = 144'h0a83ff20fc41fc28ff34fc16fd9cfd84f572;
mem[67] = 144'hfa59f35e0272fe9af4df037efeda028101e0;
mem[68] = 144'h054d08f8f4e407ecfc7902ce050400a10875;
mem[69] = 144'hff400168f96a0019f78e0428fe2302d703a7;
mem[70] = 144'hff58fc5df93bfe6b0243056a021f02dc0660;
mem[71] = 144'h003dfec00a120339fad700ce015e00f3fa09;
mem[72] = 144'h0263fbf6fc940369fd9701a0015a02650639;
mem[73] = 144'hfebffa3206ed05fc01af058cfeb100c6f66a;
mem[74] = 144'hfbf1f6aa0511053d0836f9f6f7aefa85fa33;
mem[75] = 144'hf50bf81b0697fac40221fa0efbd7f8abfa74;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule