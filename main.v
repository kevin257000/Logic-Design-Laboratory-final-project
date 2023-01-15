module main(
    clk,
    rst,
    start,
    PS2_DATA,   // Keyboard I/O
    PS2_CLK,    // Keyboard I/O
    led,       // LED
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
    output reg [15:0] led;
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

    reg [9:0] board_x, board_y, board_vx, board_vy;
    reg [9:0] next_board_x, next_board_y, next_board_vx, next_board_vy;

    reg [9:0] ball_x, ball_y, ball_vx, ball_vy;
    wire [9:0] next_ball_x, next_ball_y, next_ball_vx, next_ball_vy;

    reg [9:0] bulletA_x, bulletA_y, bulletB_x, bulletB_y; // skill2
    wire [9:0] next_bulletA_x, next_bulletA_y, next_bulletB_x, next_bulletB_y;

    reg[1:0] ball_dir;
    wire [1:0] next_ball_dir;

    wire [3:0] collision_trig;

    reg [6:0] skill_point, next_skill_point;

    reg [7:0] life_point, next_life_point;

    reg [15:0] nums;

    always @(posedge clk_22, posedge rst) begin
        if(rst)begin
            life_point <= 8'd5;
        end else begin
            life_point <= next_life_point;
        end
    end

    always @(*) begin
        next_life_point = life_point;
        if( ( ball_vy + ball_y + 10 ) > ( 480 + 50 ) )begin
            next_life_point = (life_point > 0) ? life_point-1 : 0;
        end
    end

    always @(*) begin
        nums = 16'd0;
        if(state == STAGE1) nums[7:0] = life_point;
    end

    SevenSegment SS_00(.display(DISPLAY), .digit(DIGIT), .nums(nums), .rst(rst), .clk(clk));

    debounce start_debounce(.clk(clk_22), .pb(start), .pb_debounced(start_debounced));
    one_pulse start_one_pulse(.clk(clk_22), .pb_in(start_debounced), .pb_out(start_press));

    reg [15:0] nled;

    always @(posedge clk_22, posedge rst) begin
        if(rst)begin
            led <= 16'b0;
        end else begin
            led <= nled;
        end
    end

    always @(*) begin
        case(state)
            MENU : begin
                if(start_press) nled = 16'b0000_0000_0000_0000;
                else nled = 16'b0;
            end
            WIN : nled = 16'b0000_0000_1000_0000;
            LOSE : nled = 16'b0000_0000_0100_0000;
            STAGE1 : begin
                nled = led;
                // if( ( ball_vy + ball_y + 10 ) > ( 480 + 50 ) ) nled[4:0] = led[4:0] >> 1;
                if(skill_point == 0) nled[15:13] = 3'b000;
                if(skill_point == 1) nled[15:13] = 3'b100;
                if(skill_point == 2) nled[15:13] = 3'b110;
                if(skill_point == 3) nled[15:13] = 3'b111;
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
                if(start_press) begin
                    next_state = MENU;
                end
                else begin
                    next_state = state;
                end
            end
            LOSE : begin
                if(start_press) begin
                    next_state = MENU;
                end
                else begin
                    next_state = state;
                end
            end
            STAGE1 : begin
                if(bricks == 1440'd0) next_state = WIN;
                else if(life_point == 0) next_state = LOSE;
                else next_state = STAGE1;
            end
            default : begin
                next_state = state;
            end
        endcase
    end


    always @(posedge clk_22, posedge rst) begin
        if(rst) begin
            bricks <= 1440'd0;
            ball_x <= 10'd320;
            ball_y <= 10'd240;
            ball_vx <= 10'd12;
            ball_vy <= 10'd9;
            ball_dir <= 2'b10; // right/up
            board_x <= 10'd200;

            bulletA_x <= 10'd250;
            bulletA_y <= 10'd700;
            bulletB_x <= 10'd100;
            bulletB_y <= 10'd700;
        end
        else begin
            ball_x <= next_ball_x;
            ball_y <= next_ball_y;
            ball_vx <= next_ball_vx;
            ball_vy <= next_ball_vy;
            bricks <= next_bricks;
            ball_dir <= next_ball_dir;
            board_x <= next_board_x;

            bulletA_x <= next_bulletA_x;
            bulletA_y <= next_bulletA_y;
            bulletB_x <= next_bulletB_x;
            bulletB_y <= next_bulletB_y;        
        end
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
    // wire [11:0] pixel_win;
    // wire [11:0] pixel_lose;
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

    // test

    reg [2:0] skill_press; // 2:J, 1:K, 0:L
    wire [2:0] skill, skill_remain; // if the skill is still remained

    reg [3:0] key_num;
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

    parameter keyA = 9'b0_0001_1100; // 1C
    parameter keyD = 9'b0_0010_0011; // 23
    parameter keyJ = 9'b0_0011_1011; // 3B
    parameter keyK = 9'b0_0100_0010; // 42
    parameter keyL = 9'b0_0100_1011; // 4B

    always @(*) begin
        skill_press = 3'd0;
        if(state == STAGE1) begin
            if(key_down[last_change] == 1'b1) begin
                if(key_down[keyJ]) skill_press[2] = 1;
                if(key_down[keyK]) skill_press[1] = 1;
                if(key_down[keyL]) skill_press[0] = 1;
            end
        end
    end

    one_pulse J_one_pulse(.clk(clk_22), .pb_in(skill_press[2]), .pb_out(skill[0]));
    one_pulse K_one_pulse(.clk(clk_22), .pb_in(skill_press[1]), .pb_out(skill[1]));
    one_pulse L_one_pulse(.clk(clk_22), .pb_in(skill_press[0]), .pb_out(skill[2]));

    reg [9:0] skill_counter; // 0.05*200 = 10sec

    always @(posedge clk_22, posedge rst) begin
        if(rst) begin
            skill_counter <= 0;
        end
        else begin
            skill_counter <= (skill_counter < 200) ? skill_counter+1 : 0;
        end
    end

    always @(posedge clk_22, posedge rst) begin
        if(rst) begin
            skill_point <= 0;
        end
        else begin
            skill_point <= next_skill_point;
        end
    end

    always @(*) begin
        next_skill_point = skill_point;
        if(state == STAGE1) begin
            if( (skill[2] & ~skill_remain[2]) == 1 || (skill[1] & ~skill_remain[1]) || (skill[0] & ~skill_remain[0])) begin
                next_skill_point = (skill_point > 0) ? skill_point-1 : 0; // A
            end
            if(skill_counter == 1 && next_skill_point <= 3) next_skill_point = next_skill_point+1;
        end
    end

    always @(*) begin
        if(skill_remain[1] == 1) board_vx = 20;
        else board_vx = 10;
    end

    always @(*) begin
        next_board_x = board_x;
        if(state == STAGE1) begin
            if(key_down[last_change] == 1'b1) begin
                if(skill_remain[0] == 1) begin
                    if(last_change == keyD) next_board_x = (board_x < 540-96) ? board_x + board_vx : board_x; // A
                    else if(last_change == keyA) next_board_x = (board_x > 5) ? board_x - board_vx : board_x; // D        
                end 
                else begin
                    if(last_change == keyD) next_board_x = (board_x < 540) ? board_x + board_vx : board_x; // A
                    else if(last_change == keyA) next_board_x = (board_x > 5) ? board_x - board_vx : board_x; // D
                end
            end
        end
    end

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
      .skill_remain(skill_remain),
      .bulletA_x(bulletA_x),
      .bulletA_y(bulletA_y),
      .bulletB_x(bulletB_x),
      .bulletB_y(bulletB_y),
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

    KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );

    ball_control BallController(
        .bricks(bricks),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .ball_vx(ball_vx),
        .ball_vy(ball_vy),
        .ball_dir(ball_dir),
        .board_x(board_x),
        .state(state),
        .skill(skill),
        .bulletA_x(bulletA_x),
        .bulletA_y(bulletA_y),
        .bulletB_x(bulletB_x),
        .bulletB_y(bulletB_y),
        .skill_point(skill_point),
        .clk_22(clk_22),
        .rst(rst),

        .next_bricks(next_bricks),
        .next_ball_x(next_ball_x),
        .next_ball_y(next_ball_y),
        .next_ball_vx(next_ball_vx),
        .next_ball_vy(next_ball_vy),
        .next_ball_dir(next_ball_dir),
        .skill_remain(skill_remain),
        .next_bulletA_x(next_bulletA_x),
        .next_bulletA_y(next_bulletA_y),
        .next_bulletB_x(next_bulletB_x),
        .next_bulletB_y(next_bulletB_y),

        .collision_trig(collision_trig)
    );
    
endmodule