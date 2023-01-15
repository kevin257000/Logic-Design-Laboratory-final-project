module ball_control(
    input wire [1439:0] bricks,
    input wire [9:0] ball_x,
    input wire [9:0] ball_y,
    input wire [9:0] ball_vx,
    input wire [9:0] ball_vy,
    input wire [1:0] ball_dir,
    input wire [9:0] board_x,
    input wire [2:0] state,
    input wire [2:0] skill,
    input wire [9:0] bulletA_x,
    input wire [9:0] bulletA_y,
    input wire [9:0] bulletB_x,
    input wire [9:0] bulletB_y,
    input wire [6:0] skill_point,
    input clk_22,
    input rst,

    output reg [1439:0] next_bricks,
    output reg [9:0] next_ball_x,
    output reg [9:0] next_ball_y,
    output reg [9:0] next_ball_vx,
    output reg [9:0] next_ball_vy,
    output reg [1:0] next_ball_dir,
    output reg [2:0] skill_remain,
    output reg [9:0] next_bulletA_x,
    output reg [9:0] next_bulletA_y,
    output reg [9:0] next_bulletB_x,
    output reg [9:0] next_bulletB_y,

    //Modify
    output reg collision_trig
);

    parameter MENU = 3'd0;
    parameter WIN = 3'd1;
    parameter LOSE = 3'd2;
    parameter STAGE1 = 3'd3;

    parameter H = 640;
    parameter V = 480;
    parameter BALL_W = 16;
    parameter BALL_H = 10;

    wire [9:0] ball_xl, ball_x_r, ball_yu, ball_yd; // 左右/上下
    assign ball_xl = ball_x;
    assign ball_xr = ball_x + BALL_W;
    assign ball_yu = ball_y;
    assign ball_yd = ball_y + BALL_H;

    reg [9:0] next_ball_xl, next_ball_xr, next_ball_yu, next_ball_yd; // 左右/上下

    parameter BY = 450;

    reg [2:0] next_skill_remain;


    always @(posedge clk_22, posedge rst) begin
        if(rst) begin
            skill_remain <= 0;
        end
        else begin
            skill_remain <= next_skill_remain;
        end
    end

    always @(*) begin
        if( state != STAGE1|| (ball_dir[0] == 1 && ball_vy + ball_yd > V+50) ) begin // 向下
            next_skill_remain = 3'b0;
        end else begin
            if(skill_point > 0) next_skill_remain = skill_remain | skill;
            else next_skill_remain = skill_remain;
        end
    end

    LFSR #(.NUM_BITS(3)) random (.clk(clk_22), .rst(rst), .o_LFSR_Data(random_num));

    reg [9:0] bullet_counter, next_bullet_counter;

    always @(posedge clk_22, posedge rst) begin
        if(rst) bullet_counter <= 0;
        else bullet_counter <= next_bullet_counter;
    end

    always @(*) begin
        if(skill_remain[2] == 0) next_bullet_counter = 0;
        else next_bullet_counter = (bullet_counter < 40) ? bullet_counter+1 : 1;
    end

    parameter bullet_v = 15;

    always @(*) begin
        next_bulletA_x = bulletA_x;
        next_bulletB_x = bulletB_x;

        if(bulletA_y != 700) next_bulletA_y = bulletA_y - bullet_v;
        else next_bulletA_y = bulletA_y;
        if(bulletB_y != 700) next_bulletB_y = bulletB_y - bullet_v;
        else next_bulletB_y = bulletB_y;

        // 撞到板子、上界
        if(
            bricks[(3*(next_bulletA_x/32) + 60*(next_bulletA_y/20))+:3] || 
            bricks[(3*((next_bulletA_x+16)/32) + 60*(next_bulletA_y/20))+:3] ||
            bulletA_y < bullet_v ||
            skill_remain[2] == 0
            ) begin
            next_bulletA_y = 700;
        end

        if(
            bricks[(3*(next_bulletB_x/32) + 60*(next_bulletB_y/20))+:3] || 
            bricks[(3*((next_bulletB_x+16)/32) + 60*(next_bulletB_y/20))+:3] ||
            bulletB_y < bullet_v ||
            skill_remain[2] == 0
            ) begin
            next_bulletB_y = 700;
        end

        if(bullet_counter == 1) begin
            next_bulletA_x = board_x;
            next_bulletA_y = BY;

            if(skill_remain[0] == 1) next_bulletB_x = board_x + 96*2 - 16;
            else next_bulletB_x = board_x + 96 - 16;
            next_bulletB_y = BY;
        end
    end

    reg [9:0] board_w;
    always @(*) begin
        if(skill_remain[0] == 1) board_w = 96*2;
        else board_w = 96;
    end

    // 目前所有碰撞判定只有使用左上角做判定，左上碰到才算碰
    reg [1:0] wall_collision;
    always @(*) begin

        next_ball_vx = ball_vx;
        next_ball_vy = ball_vy;

        // wall collision
        wall_collision = 2'b00; // x/y

        next_ball_dir = ball_dir;

        if(ball_dir[1] == 1) next_ball_x = ball_x + ball_vx;
        else next_ball_x = ball_x - ball_vx;

        if(ball_dir[0] == 1) next_ball_y = ball_y + ball_vy;
        else next_ball_y = ball_y - ball_vy;

        
        // x
        if(ball_dir[1] == 1) begin // 向右
            if(ball_x >= H-BALL_W) begin
                wall_collision[1] = 1;
                next_ball_dir[1] = 0;
                next_ball_x = H-BALL_W;
            end
        end
        else begin // 向左
            if(ball_vx > ball_xl) begin // 撞左牆
                wall_collision[1] = 1;
                next_ball_dir[1] = 1;
                // next_ball_x = 0;
                next_ball_x = ball_vx - ball_xl;
            end
            // else next_ball_x = ball_x - ball_vx;
        end

        // y
        if(ball_dir[0] == 1) begin // 向下
            // 不彈回
            if(ball_vy + ball_yd > V+50) begin // 掉落下界
                // wall_collision[0] = 1;
                // next_ball_dir[0] = 0;
                // next_ball_y = V - BALL_H;
                // next_ball_y = V - ( ball_vy + ball_yd - V ); // 下側-彈回量
                next_ball_dir[0] = 0;
                next_ball_y = BY-40;
                next_ball_x = board_x+40;
                next_ball_vx = 12;
                next_ball_vy = 9;
            end
            // else next_ball_y = ball_y + ball_vy;
        end
        else begin // 向上
            if(ball_vy > ball_yu) begin // 撞上牆
                wall_collision[0] = 1;
                next_ball_dir[0] = 1;
                // next_ball_y = 0;
                next_ball_y = ball_vy - ball_yu;
            end
            // else next_ball_y = ball_y - ball_vy;
        end

        // brick collision

        next_ball_xl = next_ball_x;
        next_ball_xr = next_ball_x + BALL_W;
        next_ball_yu = next_ball_y;
        next_ball_yd = next_ball_y + BALL_H;

        // 首先判斷球方向(右下/右上/左下/左上)
        // 接著判斷對應四角以何側碰撞(速度不超過球寬/高時，其中一角不會碰撞)
        // 將碰撞邊的速度反轉，並計算下個對應位置
        // 計算公式 : 撞到的位置座標 +/- 碰撞彈回量
        if(wall_collision == 0) begin
            if(ball_dir == 2'b11) begin // 往右下
                if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] != 0) begin // 右上角碰撞
                    // 右側碰撞
                    next_ball_dir[1] = 0;
                    // next_ball_x = ((next_ball_xl/32)) - ( (ball_x + ball_vx) - ((next_ball_xl/32)) );
                    
                end else if(bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] != 0) begin // 左下角碰撞
                    // 下側碰撞
                    next_ball_dir[0] = 0;
                    // next_ball_y = (20*(next_ball_yu/20)) - ( (ball_y + ball_vy) - (20*(next_ball_yu/20)) );

                end else if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3] != 0) begin // 右下角碰撞
                    if((((next_ball_xl/32) - ball_xl))*ball_vy > (ball_yu - (20*(next_ball_yu/20)))*ball_vx ) begin
                        // 右側碰撞
                        next_ball_dir[1] = 0;
                        // next_ball_x = (32*(next_ball_xl/32)) - ( (ball_x + ball_vx) - (32*(next_ball_xl/32)) );

                    end else begin
                        // 下側碰撞
                        next_ball_dir[0] = 0;
                        // next_ball_y = (20*(next_ball_yu/20)) - ( (ball_y + ball_vy) - (20*(next_ball_yu/20)) );

                    end
                end 
            end else if(ball_dir == 2'b10) begin // 往右上
                if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] != 0) begin // 左上角碰撞
                    // 上側碰撞
                    next_ball_dir[0] = 1;
                    // next_ball_y = ((next_ball_yu/20)) - ( (ball_y + ball_vy) - ((next_ball_yu/20)) );

                end else if(bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] != 0) begin // 右下角碰撞
                    // 右側碰撞
                    next_ball_dir[1] = 0;
                    // next_ball_x = ((next_ball_xl/32)) - ( (ball_x + ball_vx) - ((next_ball_xl/32)) );

                end else if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3] != 0) begin // 右上角碰撞
                    if((((next_ball_xl/32) - ball_xl))*ball_vy > (ball_yu - ((next_ball_yu/20) + 20))*ball_vx ) begin
                        // 右側碰撞
                        next_ball_dir[1] = 0;
                        // next_ball_x = ((next_ball_xl/32)) - ( (ball_x + ball_vx) - ((next_ball_xl/32)) );

                    end else begin
                        // 上側碰撞
                        next_ball_dir[0] = 1;
                        // next_ball_y = ((next_ball_yu/20)) - ( (ball_y + ball_vy) - ((next_ball_yu/20)) );

                    end
                end 
            end else if(ball_dir == 2'b01) begin // 往左下
                if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] != 0) begin // 左上角碰撞
                    // 左側碰撞
                    next_ball_dir[1] = 1;
                    // next_ball_x = ((next_ball_xl/32) + 32) + ( ((next_ball_xl/32) + 32) - (ball_x - ball_vx) );

                end else if(bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] != 0) begin // 右下角碰撞
                    // 下側碰撞
                    next_ball_dir[0] = 0;
                    // next_ball_y = ((next_ball_yu/20)) - ( (ball_y + ball_vy) - ((next_ball_yu/20)) );

                end else if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3] != 0) begin // 左下角碰撞
                    if((ball_xl - ((next_ball_xl/32) + 32))*ball_vy > (((next_ball_yu/20)) - ball_yu)*ball_vx ) begin
                        // 左側碰撞
                        next_ball_dir[1] = 1;
                        // next_ball_x = ((next_ball_xl/32) + 32) + ( ((next_ball_xl/32) + 32) - (ball_x - ball_vx) );

                    end else begin
                        // 下側碰撞
                        next_ball_dir[0] = 0;
                        // next_ball_y = ((next_ball_yu/20)) - ( (ball_y + ball_vy) - ((next_ball_yu/20)) );

                    end
                end 
            end else if(ball_dir == 2'b00) begin // 往左上 
                if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3] != 0) begin // 左下角碰撞
                    // 左側碰撞
                    next_ball_dir[1] = 1;
                    // next_ball_x = ((next_ball_xl/32) + 32) + ( ((next_ball_xl/32) + 32) - (ball_x - ball_vx) );

                end else if(bricks[(3*(next_ball_xr/32) + 60*(next_ball_yu/20))+:3] != 0) begin // 右上角碰撞
                    // 上側碰撞
                    next_ball_dir[0] = 1;
                    // next_ball_y = ((next_ball_yu/20) + 20) + ( ((next_ball_yu/20) + 20) - (ball_y - ball_vy) );

                end else if(bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] != 0) begin // 左上角碰撞
                    if((ball_xl - ((next_ball_xl/32) + 32))*ball_vy > (ball_yu - ((next_ball_yu/20) + 20))*ball_vx ) begin
                        // 左側碰撞
                        next_ball_dir[1] = 1;
                        // next_ball_x = ((next_ball_xl/32) + 32) + ( ((next_ball_xl/32) + 32) - (ball_x - ball_vx) );

                    end else begin
                        // 上側碰撞
                        next_ball_dir[0] = 1;
                        // next_ball_y = ((next_ball_yu/20) + 20) + ( ((next_ball_yu/20) + 20) - (ball_y - ball_vy) );

                    end
                end
            end
        end

        // test
        // board_y = BY
        // board_w

        if(next_ball_yd >= BY && next_ball_yd <= BY+30) begin 
            if( (next_ball_xr >= board_x && next_ball_xr <= board_x+board_w) || (next_ball_xl >= board_x && next_ball_xl <= board_x+board_w) )  begin
                next_ball_dir[0] = 0;
                // next_ball_y = BY - ( (next_ball_yd) - BY );
                if(next_ball_xl <= board_x+(board_w)/4) begin // 撞到板子左側
                    next_ball_dir[1] = 0;
                end else if(next_ball_xl >= ((board_x+board_w)/4)*3)begin
                    next_ball_dir[1] = 1;
                end

                if(random_num != 0) begin
                    if(random_num <= 4) begin
                        if(next_ball_vx + random_num <= 20) next_ball_vx = next_ball_vx + random_num;
                        if(next_ball_vx + random_num <= 20) next_ball_vy = next_ball_vy + random_num;
                    end 
                    // else begin
                    //     if(next_ball_vx > random_num-4) next_ball_vx = next_ball_vx - (random_num-4);
                    //     if(next_ball_vx > random_num-4) next_ball_vy = next_ball_vy - (random_num-4);
                    // end
                end
            end
        end

        // MENU state
        // test
        if(state != 3) begin
            next_ball_x = ball_x;
            next_ball_y = ball_y;
            next_ball_vx = ball_vx;
            next_ball_vy = ball_vy;
            next_ball_dir = ball_dir;
        end

    end

    always @(*) begin
        // 將球下個時間點的四個位置會碰到的磚塊破壞
        if(
            bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] != 0 || 
            bricks[(3*(next_ball_xr/32) + 60*(next_ball_yu/20))+:3] != 0 || 
            bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] != 0 || 
            bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3] != 0 ||
            (next_bulletA_y == 700 && bricks[(3*(next_bulletA_x/32) + 60*((bulletA_y - bullet_v)/20))+:3]) ||
            (next_bulletA_y == 700 && bricks[(3*((next_bulletA_x+16)/32) + 60*((bulletA_y - bullet_v)/20))+:3]) ||
            (next_bulletB_y == 700 && bricks[(3*(next_bulletB_x/32) + 60*((bulletB_y - bullet_v)/20))+:3]) ||
            (next_bulletB_y == 700 && bricks[(3*((next_bulletB_x+16)/32) + 60*((bulletB_y - bullet_v)/20))+:3])
        ) collision_trig = 1;
        else collision_trig = 0;

        next_bricks = bricks;
        next_bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] = 3'd0;
        next_bricks[(3*(next_ball_xr/32) + 60*(next_ball_yu/20))+:3] = 3'd0;
        next_bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] = 3'd0;
        next_bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3] = 3'd0;

        if(next_bulletA_y == 700) begin
            next_bricks[(3*(next_bulletA_x/32) + 60*((bulletA_y - bullet_v)/20))+:3] = 3'd0;
            next_bricks[(3*((next_bulletA_x+16)/32) + 60*((bulletA_y - bullet_v)/20))+:3] = 3'd0; 
        end
        if(next_bulletB_y == 700) begin
            next_bricks[(3*(next_bulletB_x/32) + 60*((bulletB_y - bullet_v)/20))+:3] = 3'd0;
            next_bricks[(3*((next_bulletB_x+16)/32) + 60*((bulletB_y - bullet_v)/20))+:3] = 3'd0;
        end

        // not STAGE state
        if(state != 3) begin
            next_bricks[(3*3 + 60*1)+:3] = 3'd3; // (3,1)
            next_bricks[(3*4 + 60*1)+:3] = 3'd4; // (4,1)
            next_bricks[(3*5 + 60*1)+:3] = 3'd5; // (5,1)
            next_bricks[(3*3 + 60*2)+:3] = 3'd6; // (3,2)
            next_bricks[(3*4 + 60*2)+:3] = 3'd7; // (4,2)
            next_bricks[(3*5 + 60*2)+:3] = 3'd3; // (5,2)
            next_bricks[(3*3 + 60*3)+:3] = 3'd3; // (3,3)
            next_bricks[(3*4 + 60*3)+:3] = 3'd5; // (4,3)
            next_bricks[(3*5 + 60*3)+:3] = 3'd7; // (5,3)

            next_bricks[(3*9 + 60*1)+:3] = 3'd3; // (9,1)
            next_bricks[(3*10 + 60*1)+:3] = 3'd4; // (10,1)
            next_bricks[(3*11 + 60*1)+:3] = 3'd5; // (11,1)
            next_bricks[(3*9 + 60*2)+:3] = 3'd6; // (9,2)
            next_bricks[(3*10 + 60*2)+:3] = 3'd7; // (10,2)
            next_bricks[(3*11 + 60*2)+:3] = 3'd3; // (11,2)
            next_bricks[(3*9 + 60*3)+:3] = 3'd3; // (9,3)
            next_bricks[(3*10 + 60*3)+:3] = 3'd5; // (10,3)
            next_bricks[(3*11 + 60*3)+:3] = 3'd7; // (11,3)

            next_bricks[(3*15 + 60*1)+:3] = 3'd3; // (15,1)
            next_bricks[(3*16 + 60*1)+:3] = 3'd4; // (16,1)
            next_bricks[(3*17 + 60*1)+:3] = 3'd5; // (17,1)
            next_bricks[(3*15 + 60*2)+:3] = 3'd6; // (15,2)
            next_bricks[(3*16 + 60*2)+:3] = 3'd7; // (16,2)
            next_bricks[(3*17 + 60*2)+:3] = 3'd3; // (17,2)
            next_bricks[(3*15 + 60*3)+:3] = 3'd3; // (15,3)
            next_bricks[(3*16 + 60*3)+:3] = 3'd5; // (16,3)
            next_bricks[(3*17 + 60*3)+:3] = 3'd7; // (17,3)

            next_bricks[(3*3 + 60*5)+:3] = 3'd3; // (3,5)
            next_bricks[(3*4 + 60*5)+:3] = 3'd4; // (4,5)
            next_bricks[(3*5 + 60*5)+:3] = 3'd5; // (5,5)
            next_bricks[(3*3 + 60*6)+:3] = 3'd6; // (3,6)
            next_bricks[(3*4 + 60*6)+:3] = 3'd7; // (4,6)
            next_bricks[(3*5 + 60*6)+:3] = 3'd3; // (5,6)
            next_bricks[(3*3 + 60*7)+:3] = 3'd3; // (3,7)
            next_bricks[(3*4 + 60*7)+:3] = 3'd5; // (4,7)
            next_bricks[(3*5 + 60*7)+:3] = 3'd7; // (5,7)

            next_bricks[(3*9 + 60*5)+:3] = 3'd3; // (9,5)
            next_bricks[(3*10 + 60*5)+:3] = 3'd4; // (10,5)
            next_bricks[(3*11 + 60*5)+:3] = 3'd5; // (11,5)
            next_bricks[(3*9 + 60*6)+:3] = 3'd6; // (9,6)
            next_bricks[(3*10 + 60*6)+:3] = 3'd7; // (10,6)
            next_bricks[(3*11 + 60*6)+:3] = 3'd3; // (11,6)
            next_bricks[(3*9 + 60*7)+:3] = 3'd3; // (9,7)
            next_bricks[(3*10 + 60*7)+:3] = 3'd5; // (10,7)
            next_bricks[(3*11 + 60*7)+:3] = 3'd7; // (11,7)

            next_bricks[(3*15 + 60*5)+:3] = 3'd3; // (15,5)
            next_bricks[(3*16 + 60*5)+:3] = 3'd4; // (16,5)
            next_bricks[(3*17 + 60*5)+:3] = 3'd5; // (17,5)
            next_bricks[(3*15 + 60*6)+:3] = 3'd6; // (15,6)
            next_bricks[(3*16 + 60*6)+:3] = 3'd7; // (16,6)
            next_bricks[(3*17 + 60*6)+:3] = 3'd3; // (17,6)
            next_bricks[(3*15 + 60*7)+:3] = 3'd3; // (15,7)
            next_bricks[(3*16 + 60*7)+:3] = 3'd5; // (16,7)
            next_bricks[(3*17 + 60*7)+:3] = 3'd7; // (17,7)

            next_bricks[(3*3 + 60*9)+:3] = 3'd3; // (3,9)
            next_bricks[(3*4 + 60*9)+:3] = 3'd4; // (4,9)
            next_bricks[(3*5 + 60*9)+:3] = 3'd5; // (5,9)
            next_bricks[(3*3 + 60*10)+:3] = 3'd6; // (3,10)
            next_bricks[(3*4 + 60*10)+:3] = 3'd7; // (4,10)
            next_bricks[(3*5 + 60*10)+:3] = 3'd3; // (5,10)
            next_bricks[(3*3 + 60*11)+:3] = 3'd3; // (3,11)
            next_bricks[(3*4 + 60*11)+:3] = 3'd5; // (4,11)
            next_bricks[(3*5 + 60*11)+:3] = 3'd7; // (5,11)

            next_bricks[(3*9 + 60*9)+:3] = 3'd3; // (9,9)
            next_bricks[(3*10 + 60*9)+:3] = 3'd4; // (10,9)
            next_bricks[(3*11 + 60*9)+:3] = 3'd5; // (11,9)
            next_bricks[(3*9 + 60*10)+:3] = 3'd6; // (9,10)
            next_bricks[(3*10 + 60*10)+:3] = 3'd7; // (10,10)
            next_bricks[(3*11 + 60*10)+:3] = 3'd3; // (11,10)
            next_bricks[(3*9 + 60*11)+:3] = 3'd3; // (9,11)
            next_bricks[(3*10 + 60*11)+:3] = 3'd5; // (10,11)
            next_bricks[(3*11 + 60*11)+:3] = 3'd7; // (11,11)

            next_bricks[(3*15 + 60*9)+:3] = 3'd3; // (15,9)
            next_bricks[(3*16 + 60*9)+:3] = 3'd4; // (16,9)
            next_bricks[(3*17 + 60*9)+:3] = 3'd5; // (17,9)
            next_bricks[(3*15 + 60*10)+:3] = 3'd6; // (15,10)
            next_bricks[(3*16 + 60*10)+:3] = 3'd7; // (16,10)
            next_bricks[(3*17 + 60*10)+:3] = 3'd3; // (17,10)
            next_bricks[(3*15 + 60*11)+:3] = 3'd3; // (15,11)
            next_bricks[(3*16 + 60*11)+:3] = 3'd5; // (16,11)
            next_bricks[(3*17 + 60*11)+:3] = 3'd7; // (17,11)



        end 
    end
endmodule


module LFSR #(parameter NUM_BITS = 3)
(
    input clk,
    input rst,
    output [NUM_BITS-1:0] o_LFSR_Data
);

    reg [NUM_BITS:1] r_LFSR = 0;
    reg              r_XNOR;

    always @(posedge clk) begin
        if (rst) r_LFSR <= 6;
        else r_LFSR <= {r_LFSR[NUM_BITS-1:1], r_XNOR};
    end
    
    always @(*)
        begin
        case (NUM_BITS)
            3: begin
                r_XNOR = r_LFSR[3] ^~ r_LFSR[2];
            end
            5: begin
                r_XNOR = r_LFSR[5] ^~ r_LFSR[3];
            end
            6: begin
                r_XNOR = r_LFSR[6] ^~ r_LFSR[5];
            end
            7: begin
                r_XNOR = r_LFSR[7] ^~ r_LFSR[6];
            end
        endcase // case (NUM_BITS)
        end // always @ (*)

    assign o_LFSR_Data = r_LFSR[NUM_BITS:1];

endmodule // LFSR