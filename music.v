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
                    12'd0: toneR = `he;	    12'd1: toneR = `he;
                    12'd2: toneR = `he;	    12'd3: toneR = `he;
                    12'd4: toneR = `he;	    12'd5: toneR = `he;
                    12'd6: toneR = `he;	    12'd7: toneR = `sil;
                    12'd8: toneR = `he;	    12'd9: toneR = `he;
                    12'd10: toneR = `he;	12'd11: toneR = `he;
                    12'd12: toneR = `he;	12'd13: toneR = `he;
                    12'd14: toneR = `he;	12'd15: toneR = `sil;

                    12'd16: toneR = `he;	12'd17: toneR = `he;
                    12'd18: toneR = `he;	12'd19: toneR = `he;
                    12'd20: toneR = `he;	12'd21: toneR = `he;
                    12'd22: toneR = `he;	12'd23: toneR = `he;
                    12'd24: toneR = `he;	12'd25: toneR = `he;
                    12'd26: toneR = `he;	12'd27: toneR = `he;
                    12'd28: toneR = `he;	12'd29: toneR = `he;
                    12'd30: toneR = `he;	12'd31: toneR = `sil;

                    default: toneR = `sil;
                endcase
            end else begin
                toneR = `sil;
            end
        end else toneR = `sil;

        toneL = toneR;
    end

endmodule