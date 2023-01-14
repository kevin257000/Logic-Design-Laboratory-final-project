module main(
    clk,
    rst,
    start,
    PS2_DATA,   // Keyboard I/O
    PS2_CLK,    // Keyboard I/O
    led,       // LED: [15:13] octave & [4:0] volume
    audio_mclk, // master clock
    audio_lrck, // left-right clock
    audio_sck,  // serial clock
    audio_sdin, // serial audio data input
    DISPLAY,    // 7-seg
    DIGIT,       // 7-seg
    vgaRed,
    vgaGreen,
    vgaBlue,
    hsync,
    vsync
);
    input wire clk;
    input wire rst;
    input wire start;
    inout PS2_DATA;
	inout PS2_CLK;
    output reg [7:0] led;
    output audio_mclk;
    output audio_lrck;
    output audio_sck;
    output audio_sdin;
    output [6:0] DISPLAY;
    output [3:0] DIGIT;

    output [3:0] vgaRed;
    output [3:0] vgaGreen;
    output [3:0] vgaBlue;
    output hsync;
    output vsync;

    // state
    parameter MENU = 3'd0;
    parameter WIN = 3'd1;
    parameter LOSE = 3'd2;
    parameter STAGE1 = 3'd3;
    reg [2:0] state, next_state;

    reg [1439:0] bricks;
    wire [1439:0] next_bricks; // 3*20*24 = 1440

    reg [1439:0] Game;

    reg [9:0] board_x, board_y, board_vx, board_vy;
    reg [9:0] next_board_x, next_board_y, next_board_vx, next_board_vy;

    reg [9:0] ball_x, ball_y, ball_vx, ball_vy;
    wire [9:0] next_ball_x, next_ball_y, next_ball_vx, next_ball_vy;

    reg[1:0] ball_dir;
    wire [1:0] next_ball_dir;

    wire [3:0] collision_trig;

    //clock_divider #(.n(22)) clock_divider_22(.clk(clk), .rst(rst), .clk_div(clk_22));
    debounce start_debounce(.clk(clk_22), .pb(start), .pb_debounced(start_debounced));
    one_pulse start_one_pulse(.clk(clk_22), .pb_in(start_debounced), .pb_out(start_press));

    reg [7:0] nled;

    always @(posedge clk_22) begin
        if(rst)begin
            led <= 8'b0;
        end else begin
            led <= nled;
        end
    end

    always @(*) begin
        case(state)
            MENU : begin
                if(start_press) nled = 8'b0001_1111;
                else nled = 8'b0;
            end
            WIN : nled = 8'b1000_0000;
            LOSE : nled = 8'b0100_0000;
            STAGE1 : begin
                if( ( ball_vy + ball_y + 10 ) > ( 480 + 50 ) ) nled = led >> 1;
                else nled = led;
            end
            default : nled = led;
        endcase
    end

    always @(posedge clk_22, posedge rst) begin
        if (rst) begin
            state <= MENU;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case(state)
            MENU : begin
                if(start_press) begin
                    next_state = STAGE1;
                end
                else begin
                    next_state = state;
                end
            end
            WIN : begin
                next_state = state;
            end
            LOSE : begin
                next_state = state;
            end
            STAGE1 : begin
                if(bricks == 1440'd0) next_state = WIN;
                else if(led == 16'b0) next_state = LOSE;
                else next_state = STAGE1;
            end
            default : begin
                next_state = state;
            end
        endcase
    end


    always @(posedge clk_22, posedge rst) begin
        if(rst) begin
            bricks <= Game;
            ball_x <= 10'd320;
            ball_y <= 10'd240;
            ball_vx <= 10'd12;
            ball_vy <= 10'd9;
            ball_dir <= 2'b10; // right/up
            board_x <= 10'd200;
        end
        else begin
            ball_x <= next_ball_x;
            ball_y <= next_ball_y;
            ball_vx <= next_ball_vx;
            ball_vy <= next_ball_vy;
            bricks <= next_bricks;
            ball_dir <= next_ball_dir;
            board_x <= next_board_x;
        end
    end

    ball_control BallController(
        .bricks(bricks),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .ball_vx(ball_vx),
        .ball_vy(ball_vy),
        .ball_dir(ball_dir),
        .board_x(board_x),
        .state(state),

        .next_bricks(next_bricks),
        .next_ball_x(next_ball_x),
        .next_ball_y(next_ball_y),
        .next_ball_vx(next_ball_vx),
        .next_ball_vy(next_ball_vy),
        .next_ball_dir(next_ball_dir),
        .collision_trig(collision_trig)
    );



    // 0 空 1 磚
    // for testing
    always @(*) begin
        Game = 1440'd0;
        
        //Game[(3*x + 60*y)+:3] = 3'd1; // (x,y)

        Game[(3*1 + 60*1)+:3] = 3'd1; // (1,1)
        Game[(3*2 + 60*1)+:3] = 3'd1; // (2,1)
        Game[(3*3 + 60*1)+:3] = 3'd1; // (3,1)
        Game[(3*1 + 60*2)+:3] = 3'd1; // (1,2)
        Game[(3*2 + 60*2)+:3] = 3'd1; // (2,2)
        Game[(3*3 + 60*2)+:3] = 3'd1; // (3,2)
        Game[(3*1 + 60*3)+:3] = 3'd1; // (1,3)
        Game[(3*2 + 60*3)+:3] = 3'd1; // (2,3)
        Game[(3*3 + 60*3)+:3] = 3'd1; // (3,3)

        Game[(3*13 + 60*1)+:3] = 3'd1; // (13,1)
        Game[(3*14 + 60*1)+:3] = 3'd1; // (14,1)
        Game[(3*15 + 60*1)+:3] = 3'd1; // (15,1)
        Game[(3*13 + 60*2)+:3] = 3'd1; // (13,2)
        Game[(3*14 + 60*2)+:3] = 3'd1; // (14,2)
        Game[(3*15 + 60*2)+:3] = 3'd1; // (15,2)

        Game[(3*13 + 60*5)+:3] = 3'd1; // (13,1)
        Game[(3*14 + 60*5)+:3] = 3'd1; // (14,1)
        Game[(3*15 + 60*5)+:3] = 3'd1; // (15,1)
        Game[(3*13 + 60*6)+:3] = 3'd1; // (13,2)
        Game[(3*14 + 60*6)+:3] = 3'd1; // (14,2)
        Game[(3*15 + 60*6)+:3] = 3'd1; // (15,2)

        Game[(3*7 + 60*4)+:3] = 3'd1; // (0,1)
        Game[(3*8 + 60*4)+:3] = 3'd1; // (1,1)
        Game[(3*9 + 60*4)+:3] = 3'd1; // (3,1)
        Game[(3*7 + 60*5)+:3] = 3'd1; // (0,2)
        Game[(3*8 + 60*5)+:3] = 3'd1; // (1,2)
        Game[(3*9 + 60*5)+:3] = 3'd1; // (3,2)

        Game[(3*7 + 60*8)+:3] = 3'd1; // (0,1)
        Game[(3*8 + 60*8)+:3] = 3'd1; // (1,1)
        Game[(3*9 + 60*8)+:3] = 3'd1; // (3,1)
        Game[(3*7 + 60*9)+:3] = 3'd1; // (0,2)
        Game[(3*8 + 60*9)+:3] = 3'd1; // (1,2)
        Game[(3*9 + 60*9)+:3] = 3'd1; // (3,2)
    end

    wire [11:0] data;
    wire [11:0] data_menu;
    wire [11:0] data_win;
    wire [11:0] data_lose;
    wire clk_25MHz;
    wire [16:0] pixel_addr;
    reg [11:0] pixel;
    wire [11:0] pixel_play;
    wire [11:0] pixel_menu;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480

    always @(*) begin
        case(state)
            MENU : begin
                if(start_press) begin
                    pixel = pixel_play;
                end
                else begin
                    pixel = pixel_menu;
                end
            end
            WIN : begin
                pixel = pixel_win;
            end
            LOSE : begin
                pixel = pixel_lose;
            end
            STAGE1 : begin
                if(bricks == 1440'd0) pixel = pixel_win;
                else pixel = pixel_play;
            end
            default : begin
                pixel = pixel_menu;
            end
        endcase
    end

    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

    music_control music_ctrl(
        .clk(clk),
        .clk_22(clk_22), // clk/0.05sec
        .rst(rst),
        .collision_trig(collision_trig),
        .state(state),

        .audio_mclk(audio_mclk), // master clock
        .audio_lrck(audio_lrck), // left-right clock
        .audio_sck(audio_sck),  // serial clock
        .audio_sdin(audio_sdin) // serial audio data input
    );

    clock_divider2 clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    );

    mem_addr_gen mem_addr_gen_inst(
      .state(state),
      .bricks(bricks),
      .ball_x(ball_x),
      .ball_y(ball_y),
      .board_x(board_x),
      .board_y(10'd467),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt),
      .pixel_addr(pixel_addr)
    );
    
    //block memory for play
    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel_play)
    ); 

    //block memory for menu
    blk_mem_gen_1 blk_mem_gen_1_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data_menu[11:0]),
      .douta(pixel_menu)
    ); 

    //block memory for win 
    blk_mem_gen_2 blk_mem_gen_2_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data_win[11:0]),
      .douta(pixel_win)
    ); 

    //block memory for lose 
    blk_mem_gen_3 blk_mem_gen_3_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data_lose[11:0]),
      .douta(pixel_lose)
    ); 

    vga_controller vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
    
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
        .rst(rst),
        .clk(clk)
    );

    always @(*) begin
        next_board_x = board_x;
        if(state != MENU) begin
            if(key_down[last_change] == 1'b1) begin
                if(last_change == keyD) next_board_x = (board_x < 540) ? board_x + 10 : board_x; // A
                else if(last_change == keyA) next_board_x = (board_x > 5) ? board_x - 10 : board_x; // D
            end
        end
    end
    
endmodule

module clock_divider2(clk1, clk, clk22);
    parameter n = 26; 
    input clk;
    output clk1;
    output clk22;
    reg [21:0] num;
    wire [21:0] next_num;

    always @(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1'b1;
    assign clk1 = num[1];
    assign clk22 = num[21];
endmodule
