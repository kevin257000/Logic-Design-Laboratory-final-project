module main(
    clk,
    rst,
    PS2_DATA,   // Keyboard I/O
    PS2_CLK,    // Keyboard I/O
    led,       // LED: [15:13] octave & [4:0] volume
    audio_mclk, // master clock
    audio_lrck, // left-right clock
    audio_sck,  // serial clock
    audio_sdin, // serial audio data input
    DISPLAY,    // 7-seg
    DIGIT       // 7-seg
);
    input wire clk;
    input wire rst;

    inout PS2_DATA;
	inout PS2_CLK;
    output reg [15:0] led;
    output audio_mclk;
    output audio_lrck;
    output audio_sck;
    output audio_sdin;
    output [6:0] DISPLAY;
    output [3:0] DIGIT;

    reg [1439:0] bricks, next_bricks; // 3*20*24 = 1440

    reg [9:0] board_x, board_y, board_vx, board_vy;
    reg [9:0] next_board_x, next_board_y, next_board_vx, next_board_vy;

    reg [9:0] ball_x, ball_y, ball_vx, ball_vy; // speed can't exceed 8
    reg [9:0] next_ball_x, next_ball_y, next_ball_vx, next_ball_vy;

    reg[1:0] ball_dir, next_ball_dir;

    clock_divider #(.n(22)) clock_divider_22(.clk(clk), .rst(rst_pb), .clk_div(clk_22));

    reg [3:0] key_num;
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

    parameter keyA = 9'b0_0001_1100;
    parameter keyD = 9'b0_0010_0011;

    KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst_pb),
        .clk(clk)
    );

    always @(*) begin
        next_board_x = board_x;
        if(been_ready && key_down[last_change] == 1'b1) begin
            if(key_down[keyA]) next_board_x = (board_x < 370) ? board_x + 5 : board_x; // A
            else if(key_down[keyD]) next_board_x = (board_x > 100) ? board_x - 5 : board_x; // D
        end
    end



    always @(posedge clk_22, posedge rst) begin
        if(rst) begin
            bricks <= 1440'd0;
            ball_x <= 10'd320;
            ball_y <= 10'd240;
            ball_vx <= 10'd8;
            ball_vy <= 10'd6;
            ball_dir <= 2'b10; // right/up
            board_x <= 272;
        end
        else begin
            ball_x <= next_ball_x;
            ball_y <= next_ball_y;
            ball_vx <= next_ball_vx;
            ball_vy <= next_ball_vy;
            bricks <= next_bricks;
            ball_dir <=  next_ball_dir;
        end
    end

    // for testing
    always @(*) begin
        bricks[(3*0 + 60*0)+:3] = 3'd1; // (0,0)
        bricks[(3*1 + 60*0)+:3] = 3'd1; // (1,0)
        bricks[(3*3 + 60*0)+:3] = 3'd1; // (3,0)
        bricks[(3*19 + 60*0)+:3] = 3'd1; // (19,0)

        bricks[(3*0 + 60*1)+:3] = 3'd1; // (0,1)
        bricks[(3*0 + 60*2)+:3] = 3'd1; // (0,2)
    end
endmodule