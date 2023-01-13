module player_control #(parameter LEN = 128) (
	input clk, 
	input reset,
	input state_reset,
	output reg [11:0] ibeat
);
	// parameter LEN = 128;
    reg [11:0] next_ibeat;


	always @(posedge clk, posedge reset) begin
		if (reset) begin
			ibeat <= 0;
		end else if(state_reset == 1) begin
			ibeat <= 0;
		end else begin
			ibeat <= next_ibeat;
		end
	end

    always @* begin
    	if(reset) begin
    		next_ibeat = 0;
    	end else if(state_reset == 1) begin
			next_ibeat <= 0;
    	end else begin
    		next_ibeat = (ibeat + 1 < LEN) ? (ibeat + 1) : 0; //LEN-1;
		end
    end

endmodule
