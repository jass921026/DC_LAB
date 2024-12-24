// Module for mouse communication
// References: 
// https://www.burtonsys.com/ps2_chapweske.htm?fbclid=IwZXh0bgNhZW0CMTAAAR2DL3qmzPo2J2OSEvgakW2yYYRzJI0-HepxaNcXNqBdeyr6h_xeeeL7mjk_aem_hXzdYlPoQijf39Vk5K4SkA
// https://isdaman.com/alsos/hardware/mouse/ps2interface.htm?fbclid=IwZXh0bgNhZW0CMTAAAR0gVb8onQjVVoY3b_PKli0uNilHLbXRY0Q7EyQYnUH9kDMHW1facEGdkig_aem_jJE0v8PxG2btSPeeI_wB4w
// https://web.mit.edu/6.111/www/f2005/code/ps2_mouse.v

module Mouse
(
    input i_clk,  // system clock
    input i_rst_n,  // system reset
    inout ps2_clk,  // mouse clock
    inout ps2_data, // mouse data
    output o_button_left,
    output o_button_right,
    output [8:0] o_movement_x, // signed
    output [8:0] o_movement_y,
    output o_valid
);

// FSM

localparam S_WRITE_WAIT = 2'b00;
localparam S_WRITE_LOOP = 2'b01;
localparam S_READ       = 2'b10;
localparam S_OUTPUT     = 2'b11;

localparam WRITE_WAIT_CYCLES = 6000;
localparam READ_WAIT_CYCLES = 30000;

logic [1:0] state_w, state_r;           // state
logic [20:0] counter_w, counter_r;      // count cycles of main clock
logic [32:0] shiftreg_w, shiftreg_r;    // shift register for read / write data
logic [5:0] bitcnt_w, bitcnt_r;         // count bits read / write by mouse
logic ps2_clk_deb, ps2_clk_neg, ps2_clk_pos;

// Debounce ps2_clk, get posedge and negedge

ClkDebounce deb0 (
    .i_in(ps2_clk),
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .o_debounced(ps2_clk_deb),
    .o_neg(ps2_clk_neg),
    .o_pos(ps2_clk_pos)
);

assign ps2_clk = (state_r == S_WRITE_WAIT) ? 1'b0 : 1'bz;
assign ps2_data = (state_r == S_WRITE_LOOP) ? shiftreg_r[0] : 1'bz;

assign o_valid = (
    (state_r == S_OUTPUT)
    && (shiftreg_r[0]  == 0)
    && (shiftreg_r[10] == 1)
    && (shiftreg_r[11] == 0)
    && (shiftreg_r[21] == 1)
    && (shiftreg_r[22] == 0)
    && (shiftreg_r[32] == 1)
    && (^shiftreg_r[9:1]  == 1)     // odd parity bit
    && (^shiftreg_r[20:12] == 1)  
    && (^shiftreg_r[31:23] == 1)  
);

assign o_button_left = shiftreg_r[1];
assign o_button_right = shiftreg_r[2];
assign o_movement_x = {shiftreg_r[5], shiftreg_r[19:12]};
assign o_movement_y = {shiftreg_r[6], shiftreg_r[30:23]};


always_comb begin
    state_w = state_r;
    counter_w = counter_r + 1;
    shiftreg_w = shiftreg_r;
    bitcnt_w = bitcnt_r;

    // WRITE: First, pull clock low for more than 100 us
    // Then start by sending first bit and release clock
    // When we see a clock negedge, move to next bit
    // After all bits are sent, realase data and switch to READ state

    // READ: If see a clock negedge, load data bit into shift register, bitcnt += 1
    // If > 500 us no incoming bit, reset bitcnt
    // If bitcnt full, switch to output state for 1 cycle, then reset bitcnt

    case (state_r)
        S_WRITE_WAIT: begin
            if (counter_r == WRITE_WAIT_CYCLES) begin
                state_w = S_WRITE_LOOP;
                counter_w = 0;
                shiftreg_w = 10'b0_1111_0100_0; // parity - F4 - start
                bitcnt_w = 0;
            end
        end
        S_WRITE_LOOP: begin
            if (ps2_clk_neg) begin
                if (bitcnt_r == 4'd9) begin
                    state_w = S_READ;
                    counter_w = 0;
                    bitcnt_w = 0;
                end
                else begin
                    shiftreg_w = {1'b0, shiftreg_r[32:1]};
                    bitcnt_w = bitcnt_r + 1;
                end
            end
        end
        S_READ: begin
            if (ps2_clk_neg) begin
                counter_w = 0;
                shiftreg_w = {ps2_data, shiftreg_r[32:1]};
                if (bitcnt_r == 6'd32) begin
                    bitcnt_w = 0;
                    state_w = S_OUTPUT;
                end
                else begin
                    bitcnt_w = bitcnt_r + 1;
                end
            end
            else if (counter_r == READ_WAIT_CYCLES) begin
                bitcnt_w = 0;
            end
        end
        S_OUTPUT: begin
            state_w = S_READ;
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state_r <= S_WRITE_WAIT;
        counter_r <= 0;
        shiftreg_r <= 0;
        bitcnt_r <= 0;
    end
    else begin
        state_r <= state_w;
        counter_r <= counter_w;
        shiftreg_r <= shiftreg_w;
        bitcnt_r <= bitcnt_w;
    end
end

endmodule