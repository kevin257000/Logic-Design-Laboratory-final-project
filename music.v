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
	input clk, // clk/0.05sec
    input rst,
	input reset,
    input collision_trig,
    input [2:0] state,

    output audio_mclk, // master clock
    output audio_lrck, // left-right clock
    output audio_sck,  // serial clock
    output audio_sdin // serial audio data input
);

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;

    wire [11:0] ibeatNum;               // Beat counter
    wire [31:0] freqL, freqR;           // Raw frequency, produced by music module
    reg [21:0] freq_outL, freq_outR;    // Processed frequency, adapted to the clock rate of Basys3

    player_control #(.LEN(512)) playerCtrl_00 ( 
        .clk(clk),
        .reset(rst_pb),
        .state(state),
        .ibeat(ibeatNum)
    );
    
endmodule


module player_control (
	input clk, 
	input reset,
	input [2:0] state,
	output reg [11:0] ibeat
);
	parameter LEN = 128;
    reg [11:0] next_ibeat;


	always @(posedge clk, posedge reset) begin
		if (reset) begin
			ibeat <= 0;
		end else begin
			ibeat <= next_ibeat;
		end
	end

    always @* begin
    	if(reset) begin
    		next_ibeat = 0;
    	end else if(state == 0)begin // MEMU state
    		next_ibeat = (ibeat + 1 < LEN) ? (ibeat + 1) : 0; //LEN-1;
        end else begin
            next_ibeat = 0;
        end
    end

endmodule

module music_MENU (
	input [11:0] ibeatNum,
	input en,
    input _music,
    input [767:0] record_music,
    input [2:0] state,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);

    always @* begin
        if(state == 0) begin
            if(en == 1) begin
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
                    12'd206: toneR = `d;	    12'd207: toneR = `sil;

                    12'd208: toneR = `d;	    12'd209: toneR = `d;
                    12'd210: toneR = `d;	    12'd211: toneR = `d;
                    12'd212: toneR = `d;	    12'd213: toneR = `d;
                    12'd214: toneR = `d;	    12'd215: toneR = `d;
                    12'd216: toneR = `d;	    12'd217: toneR = `d;
                    12'd218: toneR = `d;	    12'd219: toneR = `d;
                    12'd220: toneR = `d;	    12'd221: toneR = `d;
                    12'd222: toneR = `d;	    12'd223: toneR = `sil;

                    12'd224: toneR = `d;	    12'd225: toneR = `d;
                    12'd226: toneR = `d;	    12'd227: toneR = `d;
                    12'd228: toneR = `d;	    12'd229: toneR = `d;
                    12'd230: toneR = `d;	    12'd231: toneR = `d;
                    12'd232: toneR = `d;	    12'd233: toneR = `d;
                    12'd234: toneR = `d;	    12'd235: toneR = `d;
                    12'd236: toneR = `d;	    12'd237: toneR = `d;
                    12'd238: toneR = `d;	    12'd239: toneR = `sil;

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
            end else begin
                toneR = `sil;
            end
        end else toneR = `sil;

        toneL = toneR;
    end

endmodule