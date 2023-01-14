`define c   32'd262   // C3
`define d   32'd293   // D3
`define e   32'd330   // E3
`define f   32'd349   // F3
`define g   32'd392   // G3
`define a   32'd440   // A3
`define b   32'd494   // B3
`define hc  32'd524   // C4
`define hd  32'd588   // D4
`define he  32'd660   // E4
`define hf  32'd698   // F4
`define hg  32'd784   // G4
`define ha  32'd880   // A4
`define hb  32'd988   // B4

`define sil   32'd50000000 // slience

module music_control (
	input clk, 
    input clk_22, // clk/0.05sec
    input rst,
    input [3:0] collision_trig,
    input [2:0] state,

    output audio_mclk, // master clock
    output audio_lrck, // left-right clock
    output audio_sck,  // serial clock
    output audio_sdin // serial audio data input
);

    // state
    parameter MENU = 3'd0;
    parameter WIN = 3'd1;
    parameter LOSE = 3'd2;
    parameter STAGE1 = 3'd3;

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;

    wire [11:0] ibeatSE, ibeatMENU;               // Beat counter
    wire [31:0] freqL_SE, freqR_SE, freqL_MENU, freqR_MENU;    
    wire [31:0] freqL, freqR;           // Raw frequency, produced by music module
    reg [21:0] freq_outL, freq_outR;    // Processed frequency, adapted to the clock rate of Basys3

    reg [9:0] SE_counter, next_SE_counter; // sound effect counter

    assign freqL = (state == MENU) ? freqL_MENU : freqL_SE;
    assign freqR = (state == MENU) ? freqR_MENU : freqR_SE;

    always @(posedge clk_22, posedge rst) begin
        if(rst) begin
            SE_counter <= 0;
        end
        else begin
            SE_counter <= next_SE_counter;
        end
    end
    always @(*) begin
        if(collision_trig != 0) begin
            // next_SE_counter = 16;
            if(SE_counter < 8*6) next_SE_counter = SE_counter+8;
            else next_SE_counter = 8;
        end 
        else next_SE_counter = SE_counter;
    end

    always @(*) begin
        freq_outL = 50000000 / freqL;
        freq_outR = 50000000 / freqR;
    end

    player_control_SE #(.LEN(48)) playerCtrl_01 ( 
        .clk(clk_22),
        .rst(rst),
        .state(state),
        .SE_counter(SE_counter),
        .ibeat(ibeatSE)
    );

    player_control #(.LEN(256)) playerCtrl_00 ( 
        .clk(clk_22),
        .rst(rst),
        .state(state),
        .ibeat(ibeatMENU)
    );

    sound_effect music_SE (
        .ibeatNum(ibeatSE),
        .state(state),
        .toneL(freqL_SE),
        .toneR(freqR_SE)
    );

    music_MENU music_00 (
        .ibeatNum(ibeatMENU),
        .state(state),
        .toneL(freqL_MENU),
        .toneR(freqR_MENU)
    );

    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    note_gen noteGen_00(
        .clk(clk), 
        .rst(rst), 
        .volume(3'd4),
        .note_div_left(freq_outL), 
        .note_div_right(freq_outR), 
        .audio_left(audio_in_left),     // left sound audio
        .audio_right(audio_in_right)    // right sound audio
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk), 
        .rst(rst), 
        .audio_in_left(audio_in_left),      // left channel audio data input
        .audio_in_right(audio_in_right),    // right channel audio data input
        .audio_mclk(audio_mclk),            // master clock
        .audio_lrck(audio_lrck),            // left-right clock
        .audio_sck(audio_sck),              // serial clock
        .audio_sdin(audio_sdin)             // serial audio data input
    );
    
endmodule

module player_control_SE #(parameter LEN=256)  (
	input clk, 
	input rst,
	input [2:0] state,
    input [9:0] SE_counter,
	output reg [11:0] ibeat
);
	// parameter LEN = 256;
    reg [11:0] next_ibeat;


	always @(posedge clk, posedge rst) begin
		if (rst) begin
			ibeat <= 0;
		end else begin
			ibeat <= next_ibeat;
		end
	end

    always @* begin
    	if(rst || ibeat > SE_counter+8) begin
    		next_ibeat = 0;
        end else if(state != 0 && ibeat + 1 < SE_counter)begin // MEMU state
    		next_ibeat = (ibeat + 1 < LEN) ? (ibeat + 1) : 0; //LEN-1;
        end else begin
            next_ibeat = ibeat;
        end
    end

endmodule

module player_control #(parameter LEN=256)  (
	input clk, 
	input rst,
	input [2:0] state,
	output reg [11:0] ibeat
);
	// parameter LEN = 256;
    reg [11:0] next_ibeat;


	always @(posedge clk, posedge rst) begin
		if (rst) begin
			ibeat <= 0;
		end else begin
			ibeat <= next_ibeat;
		end
	end

    always @* begin
    	if(rst) begin
    		next_ibeat = 0;
    	end else if(state == 0)begin // MEMU state
    		next_ibeat = (ibeat + 1 < LEN) ? (ibeat + 1) : 0; //LEN-1;
        end else begin
            next_ibeat = 0;
        end
    end

endmodule

module sound_effect (
	input [11:0] ibeatNum,
    input [2:0] state,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);
    // test
    always @* begin
        if(state != 0) begin
            case(ibeatNum)
                // --- Measure 1 ---
                12'd0: toneR = `sil;	12'd1: toneR = `he;
                12'd2: toneR = `he;	    12'd3: toneR = `he;
                12'd4: toneR = `he;	    12'd5: toneR = `he;
                12'd6: toneR = `he;	    12'd7: toneR = `sil;
                12'd8: toneR = `he;	    12'd9: toneR = `he;
                12'd10: toneR = `he;	12'd11: toneR = `he;
                12'd12: toneR = `he;	12'd13: toneR = `he;
                12'd14: toneR = `he;	12'd15: toneR = `sil;

                12'd16: toneR = `hc;	    12'd17: toneR = `hc;
                12'd18: toneR = `hc;	    12'd19: toneR = `hc;
                12'd20: toneR = `hc;	    12'd21: toneR = `hc;
                12'd22: toneR = `hc;	    12'd23: toneR = `sil;
                12'd24: toneR = `hc;	    12'd25: toneR = `hc;
                12'd26: toneR = `hc;	    12'd27: toneR = `hc;
                12'd28: toneR = `hc;	    12'd29: toneR = `hc;
                12'd30: toneR = `hc;	    12'd31: toneR = `sil;

                12'd32: toneR = `hg;	    12'd33: toneR = `hg;
                12'd34: toneR = `hg;	    12'd35: toneR = `hg;
                12'd36: toneR = `hg;	    12'd37: toneR = `hg;
                12'd38: toneR = `hg;	    12'd39: toneR = `sil;
                12'd40: toneR = `hg;	    12'd41: toneR = `hg;
                12'd42: toneR = `hg;	    12'd43: toneR = `hg;
                12'd44: toneR = `hg;	    12'd45: toneR = `hg;
                12'd46: toneR = `hg;	    12'd47: toneR = `sil;

                default: toneR = `sil;
            endcase
        end else toneR = `sil;

        toneL = toneR;
    end

endmodule

module music_MENU (
	input [11:0] ibeatNum,
    input [2:0] state,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);

    always @* begin
        if(state == 0) begin
            case(ibeatNum)
                // --- Measure 1 ---
                12'd0: toneR = `c;	    12'd1: toneR = `c;
                12'd2: toneR = `c;	    12'd3: toneR = `c;
                12'd4: toneR = `c;	    12'd5: toneR = `c;
                12'd6: toneR = `c;	    12'd7: toneR = `c;
                12'd8: toneR = `c;	    12'd9: toneR = `c;
                12'd10: toneR = `c;	    12'd11: toneR = `c;
                12'd12: toneR = `c;	    12'd13: toneR = `c;
                12'd14: toneR = `c;	    12'd15: toneR = `c;

                12'd16: toneR = `c;	    12'd17: toneR = `c;
                12'd18: toneR = `c;	    12'd19: toneR = `c;
                12'd20: toneR = `c;	    12'd21: toneR = `c;
                12'd22: toneR = `c;	    12'd23: toneR = `c;
                12'd24: toneR = `c;	    12'd25: toneR = `c;
                12'd26: toneR = `c;	    12'd27: toneR = `c;
                12'd28: toneR = `c;	    12'd29: toneR = `c;
                12'd30: toneR = `c;	    12'd31: toneR = `sil;

                12'd32: toneR = `g;	    12'd33: toneR = `g;
                12'd34: toneR = `g;	    12'd35: toneR = `g;
                12'd36: toneR = `g;	    12'd37: toneR = `g;
                12'd38: toneR = `g;	    12'd39: toneR = `g;
                12'd40: toneR = `g;	    12'd41: toneR = `g;
                12'd42: toneR = `g;	    12'd43: toneR = `g;
                12'd44: toneR = `g;	    12'd45: toneR = `g;
                12'd46: toneR = `g;	    12'd47: toneR = `sil;

                12'd48: toneR = `f;	    12'd49: toneR = `f;
                12'd50: toneR = `f;	    12'd51: toneR = `f;
                12'd52: toneR = `f;	    12'd53: toneR = `e;
                12'd54: toneR = `e;	    12'd55: toneR = `e;
                12'd56: toneR = `e;	    12'd57: toneR = `e;
                12'd58: toneR = `d;	    12'd59: toneR = `d;
                12'd60: toneR = `d;	    12'd61: toneR = `d;
                12'd62: toneR = `d;	    12'd63: toneR = `sil;

                12'd64: toneR = `hc;	    12'd65: toneR = `hc;
                12'd66: toneR = `hc;	    12'd67: toneR = `hc;
                12'd68: toneR = `hc;	    12'd69: toneR = `hc;
                12'd70: toneR = `hc;	    12'd71: toneR = `hc;
                12'd72: toneR = `hc;	    12'd73: toneR = `hc;
                12'd74: toneR = `hc;	    12'd75: toneR = `hc;
                12'd76: toneR = `hc;	    12'd77: toneR = `hc;
                12'd78: toneR = `hc;	    12'd79: toneR = `hc;

                12'd80: toneR = `hc;	    12'd81: toneR = `hc;
                12'd82: toneR = `hc;	    12'd83: toneR = `hc;
                12'd84: toneR = `hc;	    12'd85: toneR = `hc;
                12'd86: toneR = `hc;	    12'd87: toneR = `hc;
                12'd88: toneR = `hc;	    12'd89: toneR = `hc;
                12'd90: toneR = `hc;	    12'd91: toneR = `hc;
                12'd92: toneR = `hc;	    12'd93: toneR = `hc;
                12'd94: toneR = `hc;	    12'd95: toneR = `sil;

                12'd96: toneR = `g;	        12'd97: toneR = `g;
                12'd98: toneR = `g;	        12'd99: toneR = `g;
                12'd100: toneR = `g;	    12'd101: toneR = `g;
                12'd102: toneR = `g;	    12'd103: toneR = `g;
                12'd104: toneR = `g;	    12'd105: toneR = `g;
                12'd106: toneR = `g;	    12'd107: toneR = `g;
                12'd108: toneR = `g;	    12'd109: toneR = `g;
                12'd110: toneR = `g;	    12'd111: toneR = `sil;

                12'd112: toneR = `f;	    12'd113: toneR = `f;
                12'd114: toneR = `f;	    12'd115: toneR = `f;
                12'd116: toneR = `f;	    12'd117: toneR = `e;
                12'd118: toneR = `e;	    12'd119: toneR = `e;
                12'd120: toneR = `e;	    12'd121: toneR = `e;
                12'd122: toneR = `d;	    12'd123: toneR = `d;
                12'd124: toneR = `d;	    12'd125: toneR = `d;
                12'd126: toneR = `d;	    12'd127: toneR = `sil;

                12'd128: toneR = `hc;	    12'd129: toneR = `hc;
                12'd130: toneR = `hc;	    12'd131: toneR = `hc;
                12'd132: toneR = `hc;	    12'd133: toneR = `hc;
                12'd134: toneR = `hc;	    12'd135: toneR = `hc;
                12'd136: toneR = `hc;	    12'd137: toneR = `hc;
                12'd138: toneR = `hc;	    12'd139: toneR = `hc;
                12'd140: toneR = `hc;	    12'd141: toneR = `hc;
                12'd142: toneR = `hc;	    12'd143: toneR = `hc;

                12'd144: toneR = `hc;	    12'd145: toneR = `hc;
                12'd146: toneR = `hc;	    12'd147: toneR = `hc;
                12'd148: toneR = `hc;	    12'd149: toneR = `hc;
                12'd150: toneR = `hc;	    12'd151: toneR = `hc;
                12'd152: toneR = `hc;	    12'd153: toneR = `hc;
                12'd154: toneR = `hc;	    12'd155: toneR = `hc;
                12'd156: toneR = `hc;	    12'd157: toneR = `hc;
                12'd158: toneR = `hc;	    12'd159: toneR = `sil;

                12'd160: toneR = `g;	    12'd161: toneR = `g;
                12'd162: toneR = `g;	    12'd163: toneR = `g;
                12'd164: toneR = `g;	    12'd165: toneR = `g;
                12'd166: toneR = `g;	    12'd167: toneR = `g;
                12'd168: toneR = `g;	    12'd169: toneR = `g;
                12'd170: toneR = `g;	    12'd171: toneR = `g;
                12'd172: toneR = `g;	    12'd173: toneR = `g;
                12'd174: toneR = `g;	    12'd175: toneR = `sil;

                12'd176: toneR = `f;	    12'd177: toneR = `f;
                12'd178: toneR = `f;	    12'd179: toneR = `f;
                12'd180: toneR = `f;	    12'd181: toneR = `e;
                12'd182: toneR = `e;	    12'd183: toneR = `e;
                12'd184: toneR = `e;	    12'd185: toneR = `e;
                12'd186: toneR = `f;	    12'd187: toneR = `f;
                12'd188: toneR = `f;	    12'd189: toneR = `f;
                12'd190: toneR = `f;	    12'd191: toneR = `sil;

                12'd192: toneR = `d;	    12'd193: toneR = `d;
                12'd194: toneR = `d;	    12'd195: toneR = `d;
                12'd196: toneR = `d;	    12'd197: toneR = `d;
                12'd198: toneR = `d;	    12'd199: toneR = `d;
                12'd200: toneR = `d;	    12'd201: toneR = `d;
                12'd202: toneR = `d;	    12'd203: toneR = `d;
                12'd204: toneR = `d;	    12'd205: toneR = `d;
                12'd206: toneR = `d;	    12'd207: toneR = `d;

                12'd208: toneR = `d;	    12'd209: toneR = `d;
                12'd210: toneR = `d;	    12'd211: toneR = `d;
                12'd212: toneR = `d;	    12'd213: toneR = `d;
                12'd214: toneR = `d;	    12'd215: toneR = `d;
                12'd216: toneR = `d;	    12'd217: toneR = `d;
                12'd218: toneR = `d;	    12'd219: toneR = `d;
                12'd220: toneR = `d;	    12'd221: toneR = `d;
                12'd222: toneR = `d;	    12'd223: toneR = `d;

                12'd224: toneR = `d;	    12'd225: toneR = `d;
                12'd226: toneR = `d;	    12'd227: toneR = `d;
                12'd228: toneR = `d;	    12'd229: toneR = `d;
                12'd230: toneR = `d;	    12'd231: toneR = `d;
                12'd232: toneR = `d;	    12'd233: toneR = `d;
                12'd234: toneR = `d;	    12'd235: toneR = `d;
                12'd236: toneR = `d;	    12'd237: toneR = `d;
                12'd238: toneR = `d;	    12'd239: toneR = `d;

                12'd240: toneR = `d;	    12'd241: toneR = `d;
                12'd242: toneR = `d;	    12'd243: toneR = `d;
                12'd244: toneR = `d;	    12'd245: toneR = `d;
                12'd246: toneR = `d;	    12'd247: toneR = `d;
                12'd248: toneR = `d;	    12'd249: toneR = `d;
                12'd250: toneR = `d;	    12'd251: toneR = `d;
                12'd252: toneR = `d;	    12'd253: toneR = `d;
                12'd254: toneR = `d;	    12'd255: toneR = `sil;

                default: toneR = `sil;
            endcase
        end else toneR = `sil;

        toneL = toneR;
    end

endmodule

module note_gen(
    clk, // clock from crystal
    rst, // active high rst
    volume, 
    note_div_left, // div for note generation
    note_div_right,
    audio_left,
    audio_right
);

    // I/O declaration
    input clk; // clock from crystal
    input rst; // active low rst
    input [2:0] volume;
    input [21:0] note_div_left, note_div_right; // div for note generation
    output reg [15:0] audio_left, audio_right;

    // Declare internal signals
    reg [21:0] clk_cnt_next, clk_cnt;
    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg b_clk, b_clk_next;
    reg c_clk, c_clk_next;

    // Note frequency generation
    // clk_cnt, clk_cnt_2, b_clk, c_clk
    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            begin
                clk_cnt <= 22'd0;
                clk_cnt_2 <= 22'd0;
                b_clk <= 1'b0;
                c_clk <= 1'b0;
            end
        else
            begin
                clk_cnt <= clk_cnt_next;
                clk_cnt_2 <= clk_cnt_next_2;
                b_clk <= b_clk_next;
                c_clk <= c_clk_next;
            end
    
    // clk_cnt_next, b_clk_next
    always @*
        if (clk_cnt == note_div_left)
            begin
                clk_cnt_next = 22'd0;
                b_clk_next = ~b_clk;
            end
        else
            begin
                clk_cnt_next = clk_cnt + 1'b1;
                b_clk_next = b_clk;
            end

    // clk_cnt_next_2, c_clk_next
    always @*
        if (clk_cnt_2 == note_div_right)
            begin
                clk_cnt_next_2 = 22'd0;
                c_clk_next = ~c_clk;
            end
        else
            begin
                clk_cnt_next_2 = clk_cnt_2 + 1'b1;
                c_clk_next = c_clk;
            end

    // Assign the amplitude of the note
    // Volume is controlled here
    always @(*) begin
        if(note_div_left == 22'd1) audio_left = 16'h0000;
        else begin
            if(volume == 1) begin
                audio_left  = (b_clk == 1'b0) ? 16'hF800 : 16'h0800;
                audio_right = (c_clk == 1'b0) ? 16'hF800 : 16'h0800;
            end
            else if(volume == 2)begin
                audio_left  = (b_clk == 1'b0) ? 16'hF000 : 16'h1000;
                audio_right = (c_clk == 1'b0) ? 16'hF000 : 16'h1000;
            end
            else if(volume == 3) begin
                audio_left  = (b_clk == 1'b0) ? 16'hE000 : 16'h2000;
                audio_right = (c_clk == 1'b0) ? 16'hE000 : 16'h2000;
            end
            else if(volume == 4)begin
                audio_left  = (b_clk == 1'b0) ? 16'hC000 : 16'h4000;
                audio_right = (c_clk == 1'b0) ? 16'hC000 : 16'h4000;
            end
            else begin
                audio_left  = (b_clk == 1'b0) ? 16'hA000 : 16'h6000;
                audio_right = (c_clk == 1'b0) ? 16'hA000 : 16'h6000;
            end
        end
    end
    // assign audio_left = (note_div_left == 22'd1) ? 16'h0000 : 
    //                             (b_clk == 1'b0) ? 16'hE000 : 16'h2000;
    // assign audio_right = (note_div_right == 22'd1) ? 16'h0000 : 
    //                             (c_clk == 1'b0) ? 16'hE000 : 16'h2000;
endmodule

module speaker_control(
    clk,  // clock from the crystal
    rst,  // active high reset
    audio_in_left, // left channel audio data input
    audio_in_right, // right channel audio data input
    audio_mclk, // master clock
    audio_lrck, // left-right clock, Word Select clock, or sample rate clock
    audio_sck, // serial clock
    audio_sdin // serial audio data input
);

    // I/O declaration
    input clk;  // clock from the crystal
    input rst;  // active high reset
    input [15:0] audio_in_left; // left channel audio data input
    input [15:0] audio_in_right; // right channel audio data input
    output audio_mclk; // master clock
    output audio_lrck; // left-right clock
    output audio_sck; // serial clock
    output audio_sdin; // serial audio data input
    reg audio_sdin;

    // Declare internal signal nodes 
    wire [8:0] clk_cnt_next;
    reg [8:0] clk_cnt;
    reg [15:0] audio_left, audio_right;

    // Counter for the clock divider
    assign clk_cnt_next = clk_cnt + 1'b1;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            clk_cnt <= 9'd0;
        else
            clk_cnt <= clk_cnt_next;

    // Assign divided clock output
    assign audio_mclk = clk_cnt[1];
    assign audio_lrck = clk_cnt[8];
    assign audio_sck = 1'b1; // use internal serial clock mode

    // audio input data buffer
    always @(posedge clk_cnt[8] or posedge rst)
        if (rst == 1'b1)
            begin
                audio_left <= 16'd0;
                audio_right <= 16'd0;
            end
        else
            begin
                audio_left <= audio_in_left;
                audio_right <= audio_in_right;
            end

    always @*
        case (clk_cnt[8:4])
            5'b00000: audio_sdin = audio_right[0];
            5'b00001: audio_sdin = audio_left[15];
            5'b00010: audio_sdin = audio_left[14];
            5'b00011: audio_sdin = audio_left[13];
            5'b00100: audio_sdin = audio_left[12];
            5'b00101: audio_sdin = audio_left[11];
            5'b00110: audio_sdin = audio_left[10];
            5'b00111: audio_sdin = audio_left[9];
            5'b01000: audio_sdin = audio_left[8];
            5'b01001: audio_sdin = audio_left[7];
            5'b01010: audio_sdin = audio_left[6];
            5'b01011: audio_sdin = audio_left[5];
            5'b01100: audio_sdin = audio_left[4];
            5'b01101: audio_sdin = audio_left[3];
            5'b01110: audio_sdin = audio_left[2];
            5'b01111: audio_sdin = audio_left[1];
            5'b10000: audio_sdin = audio_left[0];
            5'b10001: audio_sdin = audio_right[15];
            5'b10010: audio_sdin = audio_right[14];
            5'b10011: audio_sdin = audio_right[13];
            5'b10100: audio_sdin = audio_right[12];
            5'b10101: audio_sdin = audio_right[11];
            5'b10110: audio_sdin = audio_right[10];
            5'b10111: audio_sdin = audio_right[9];
            5'b11000: audio_sdin = audio_right[8];
            5'b11001: audio_sdin = audio_right[7];
            5'b11010: audio_sdin = audio_right[6];
            5'b11011: audio_sdin = audio_right[5];
            5'b11100: audio_sdin = audio_right[4];
            5'b11101: audio_sdin = audio_right[3];
            5'b11110: audio_sdin = audio_right[2];
            5'b11111: audio_sdin = audio_right[1];
            default: audio_sdin = 1'b0;
        endcase

endmodule