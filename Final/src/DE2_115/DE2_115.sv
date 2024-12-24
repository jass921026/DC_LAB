module DE2_115 (
    input CLOCK_50,
    input CLOCK2_50,
    input CLOCK3_50,
    input ENETCLK_25,
    input SMA_CLKIN,
    output SMA_CLKOUT,
    output [8:0] LEDG,
    output [17:0] LEDR,
    input [3:0] KEY,
    input [17:0] SW,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [6:0] HEX6,
    output [6:0] HEX7,
    output LCD_BLON,
    inout [7:0] LCD_DATA,
    output LCD_EN,
    output LCD_ON,
    output LCD_RS,
    output LCD_RW,
    output UART_CTS,
    input UART_RTS,
    input UART_RXD,
    output UART_TXD,
    inout PS2_CLK,
    inout PS2_DAT,
    inout PS2_CLK2,
    inout PS2_DAT2,
    output SD_CLK,
    inout SD_CMD,
    inout [3:0] SD_DAT,
    input SD_WP_N,
    output [7:0] VGA_B,
    output VGA_BLANK_N,
    output VGA_CLK,
    output [7:0] VGA_G,
    output VGA_HS,
    output [7:0] VGA_R,
    output VGA_SYNC_N,
    output VGA_VS,
    input AUD_ADCDAT,
    inout AUD_ADCLRCK,
    inout AUD_BCLK,
    output AUD_DACDAT,
    inout AUD_DACLRCK,
    output AUD_XCK,
    output EEP_I2C_SCLK,
    inout EEP_I2C_SDAT,
    output I2C_SCLK,
    inout I2C_SDAT,
    output ENET0_GTX_CLK,
    input ENET0_INT_N,
    output ENET0_MDC,
    input ENET0_MDIO,
    output ENET0_RST_N,
    input ENET0_RX_CLK,
    input ENET0_RX_COL,
    input ENET0_RX_CRS,
    input [3:0] ENET0_RX_DATA,
    input ENET0_RX_DV,
    input ENET0_RX_ER,
    input ENET0_TX_CLK,
    output [3:0] ENET0_TX_DATA,
    output ENET0_TX_EN,
    output ENET0_TX_ER,
    input ENET0_LINK100,
    output ENET1_GTX_CLK,
    input ENET1_INT_N,
    output ENET1_MDC,
    input ENET1_MDIO,
    output ENET1_RST_N,
    input ENET1_RX_CLK,
    input ENET1_RX_COL,
    input ENET1_RX_CRS,
    input [3:0] ENET1_RX_DATA,
    input ENET1_RX_DV,
    input ENET1_RX_ER,
    input ENET1_TX_CLK,
    output [3:0] ENET1_TX_DATA,
    output ENET1_TX_EN,
    output ENET1_TX_ER,
    input ENET1_LINK100,
    input TD_CLK27,
    input [7:0] TD_DATA,
    input TD_HS,
    output TD_RESET_N,
    input TD_VS,
    inout [15:0] OTG_DATA,
    output [1:0] OTG_ADDR,
    output OTG_CS_N,
    output OTG_WR_N,
    output OTG_RD_N,
    input OTG_INT,
    output OTG_RST_N,
    input IRDA_RXD,
    output [12:0] DRAM_ADDR,
    output [1:0] DRAM_BA,
    output DRAM_CAS_N,
    output DRAM_CKE,
    output DRAM_CLK,
    output DRAM_CS_N,
    inout [31:0] DRAM_DQ,
    output [3:0] DRAM_DQM,
    output DRAM_RAS_N,
    output DRAM_WE_N,
    output [19:0] SRAM_ADDR,
    output SRAM_CE_N,
    inout [15:0] SRAM_DQ,
    output SRAM_LB_N,
    output SRAM_OE_N,
    output SRAM_UB_N,
    output SRAM_WE_N,
    output [22:0] FL_ADDR,
    output FL_CE_N,
    inout [7:0] FL_DQ,
    output FL_OE_N,
    output FL_RST_N,
    input FL_RY,
    output FL_WE_N,
    output FL_WP_N,
    inout [35:0] GPIO,
    input HSMC_CLKIN_P1,
    input HSMC_CLKIN_P2,
    input HSMC_CLKIN0,
    output HSMC_CLKOUT_P1,
    output HSMC_CLKOUT_P2,
    output HSMC_CLKOUT0,
    inout [3:0] HSMC_D,
    input [16:0] HSMC_RX_D_P,
    output [16:0] HSMC_TX_D_P,
    inout [6:0] EX_IO
);

// logic key0down, key1down, key2down, key3down;
// logic CLK_12M, CLK_100K, CLK_800K;
// logic [3:0] curr_state ;
// logic [7:0] play_time;
// logic [15:0] end_address;
// logic fast, interpolation;
// logic [3:0] speed;

logic [9:0] red,blue,green;         //three channel wanna show with vga
logic [10:0] vgax,vgay;           //position to output
logic [21:0] addr_screen_img;       //addr of vga requesting (width * y_coord + x_coord)
logic VGA_Read;                     //vga requesting for input

logic clk25M;
logic reset;

assign reset    =   KEY[3];

// assign AUD_XCK = CLK_12M;

assign LEDR = SW ;


//	VGA Controller
logic [9:0] vga_r10;
logic [9:0] vga_g10;
logic [9:0] vga_b10;
assign VGA_R = vga_r10[9:2];
assign VGA_G = vga_g10[9:2];
assign VGA_B = vga_b10[9:2];

VGA_Ctrl vgactrl ( // Host Side
    .iRed(red),
    .iGreen(green),
    .iBlue(blue),
    .oCurrent_X(vgax),
    .oCurrent_Y(vgay),
    .oRequest(VGA_Read),
    .oAddress(addr_screen_img),
    //	VGA Side
    .oVGA_R(vga_r10 ),
    .oVGA_G(vga_g10 ),
    .oVGA_B(vga_b10 ),
    .oVGA_HS(VGA_HS),
    .oVGA_VS(VGA_VS),
    .oVGA_SYNC(VGA_SYNC_N),
    .oVGA_BLANK(VGA_BLANK_N),
    .oVGA_CLOCK(VGA_CLK),
    //	Control Signal
    .iCLK(clk25M),
    .iRST_N(reset)
);

Test t1(
	.i_rst_n(reset),
	.i_clk(clk25M),
    .i_x(vgax),
    .i_y(vgay),
    .o_blue(blue),
    .o_red(red),
    .o_green(green)
);

altpll pll0( // generate with qsys, please follow lab2 tutorials
    .clk_clk(CLOCK_50),
    .reset_reset_n(reset),
    .altpll_25m_clk_clk(clk25M)
);

// you can decide key down settings on your own, below is just an example
// Debounce deb0(
//     .i_in(KEY[0]), // Record/Pause
//     .i_rst_n(KEY[3]),
//     .i_clk(CLK_12M),
//     .o_neg(key0down) 
// );

// Debounce deb1(
//     .i_in(KEY[1]), // Play/Pause
//     .i_rst_n(KEY[3]),
//     .i_clk(CLK_12M),
//     .o_neg(key1down) 
// );

// Debounce deb2(
//     .i_in(KEY[2]), // Stop
//     .i_rst_n(KEY[3]),
//     .i_clk(CLK_12M),
//     .o_neg(key2down) 
// );

// Top top0(
//     .i_rst_n(KEY[3]),
//     .i_clk(CLK_12M),

//     .i_stop(key0down),
//     .i_start(key1down),
//     .i_pause(key2down),
//     .i_dsp_speed(SW[17:14]), // design how user can decide mode on your own
//     .i_dsp_fast(SW[12]),
//     .i_dsp_interpolation(SW[11]),
//     .i_play_enable(SW[0]),
    
//     // AudDSP and SRAM
//     .o_SRAM_ADDR(SRAM_ADDR), // [19:0]
//     .io_SRAM_DQ(SRAM_DQ), // [15:0]
//     .o_SRAM_WE_N(SRAM_WE_N),
//     .o_SRAM_CE_N(SRAM_CE_N),
//     .o_SRAM_OE_N(SRAM_OE_N),
//     .o_SRAM_LB_N(SRAM_LB_N),
//     .o_SRAM_UB_N(SRAM_UB_N),
    
//     // I2C
//     .i_clk_100k(CLK_100K),
//     .o_I2C_SCLK(I2C_SCLK),
//     .io_I2C_SDAT(I2C_SDAT),
    
//     // AudPlayer
//     .i_AUD_ADCDAT(AUD_ADCDAT),
//     .i_AUD_ADCLRCK(AUD_ADCLRCK),
//     .i_AUD_BCLK(AUD_BCLK),
//     .i_AUD_DACLRCK(AUD_DACLRCK),
//     .o_AUD_DACDAT(AUD_DACDAT),

//     // SEVENDECODER (optional display)
//     .o_fast(fast),
//     .o_interpolation(interpolation),
//     .o_speed(speed),
//     .o_curr_state(curr_state),
//     .o_play_time(play_time),
//     .o_end_address(end_address)

//     // LCD (optional display)
//     // .i_clk_800k(CLK_800K),
//     // .o_LCD_DATA(LCD_DATA), // [7:0]
//     // .o_LCD_EN(LCD_EN),
//     // .o_LCD_RS(LCD_RS),
//     // .o_LCD_RW(LCD_RW),
//     // .o_LCD_ON(LCD_ON),
//     // .o_LCD_BLON(LCD_BLON),

//     // LED
//     // .o_ledg(LEDG), // [8:0]
//     // .o_ledr(LEDR) // [17:0]
// );

// SevenHexDecoder seven_dec0(
// 	.i_hex(curr_state),
// 	.o_seven_ten(HEX7),
// 	.o_seven_one(HEX6)
// );

// assign HEX7 = fast ? (interpolation ? 7'b0101111 : 7'b1111111 ) : 7'b0111111 ;

// seven_hex_16_1 seven_dec0(
//     .i_hex(speed),
//     .o_seven(HEX6)
// );

seven_hex_16_4 seven_dec0(
    .i_hex(0),
    .o_seven_3(HEX7),
    .o_seven_2(HEX6),
    .o_seven_1(HEX5),
    .o_seven_0(HEX4)
);

seven_hex_16_4 seven_dec1(
    .i_hex(0),
    .o_seven_3(HEX3),
    .o_seven_2(HEX2),
    .o_seven_1(HEX1),
    .o_seven_0(HEX0)
);

// seven_hex_16_4 seven_dec_3(
//     .i_hex(end_address),
//     .o_seven_3(HEX3),
//     .o_seven_2(HEX2),
//     .o_seven_1(HEX1),
//     .o_seven_0(HEX0)
// );

// assign LEDG[0] = (curr_state == 'd0) ;
// assign LEDG[1] = (curr_state == 'd1) ;
// assign LEDG[2] = (curr_state == 'd2) ;
// assign LEDG[3] = (curr_state == 'd3) ;
// assign LEDG[4] = (curr_state == 'd4) ;
// assign LEDG[5] = (curr_state == 'd5) ;


// comment those are use for display
// assign HEX0 = '1;
// assign HEX1 = '1;
// assign HEX2 = '1;
// assign HEX3 = '1;
// assign HEX4 = '1;
// assign HEX5 = '1;
// assign HEX6 = '1;
// assign HEX7 = '1;

endmodule