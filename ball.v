module ball_control(
    input wire [1439:0] bricks,
    input wire [9:0] ball_x,
    input wire [9:0] ball_y,
    input wire [9:0] ball_vx,
    input wire [9:0] ball_vy,
    input wire [1:0] ball_dir,
    input wire [9:0] board_x,
    input wire [2:0] state,

    output reg [1439:0] next_bricks,
    output reg [9:0] next_ball_x,
    output reg [9:0] next_ball_y,
    output reg [9:0] next_ball_vx,
    output reg [9:0] next_ball_vy,
    output reg [1:0] next_ball_dir,

    //Modify
    output reg [3:0] collision_trig
);

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
            // if(ball_vx + ball_xr >= H) begin // 撞右牆
            //     wall_collision[1] = 1;
            //     next_ball_dir[1] = 0;
            //     // next_ball_x = 200; //test
            //     // next_ball_x = H - BALL_W;
            //     // next_ball_x = H - ( ball_vx + ball_xr - H ) - BALL_W; // 右側-彈回量
            // end
            // else next_ball_x = ball_x + ball_vx;
            
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
            if(ball_vy + ball_yd > V+50) begin // 撞下牆
                // wall_collision[0] = 1;
                // next_ball_dir[0] = 0;
                // next_ball_y = V - BALL_H;
                // next_ball_y = V - ( ball_vy + ball_yd - V ); // 下側-彈回量
                next_ball_y = 467-12;
                next_ball_x = board_x+40;
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
        // board_y = 467
        if(next_ball_yd >= 467 && next_ball_yd <= 467+10) begin 
            if( (next_ball_xr >= board_x && next_ball_xr <= board_x+96) || (next_ball_xl >= board_x && next_ball_xl <= board_x+96) )  begin
                next_ball_dir[0] = 0;
                // next_ball_y = 467 - ( (next_ball_yd) - 467 );
                if(next_ball_xl <= board_x+20) begin // 撞到板子左側
                    next_ball_dir[1] = 0;
                end else if(next_ball_xl >= board_x+68)begin
                    next_ball_dir[1] = 1;
                end
            end
        end

        // MENU state
        // test
        if(state == 0) begin
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
            bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] ||
            bricks[(3*(next_ball_xr/32) + 60*(next_ball_yu/20))+:3] ||
            bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] ||
            bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3]
        ) begin
            //Modify
            //collision_trig = 1;
            collision_trig = bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] + bricks[(3*(next_ball_xr/32) + 60*(next_ball_yu/20))+:3] + bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] + bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3];
        end else collision_trig = 0;

        next_bricks = bricks;
        next_bricks[(3*(next_ball_xl/32) + 60*(next_ball_yu/20))+:3] = 3'd0;
        next_bricks[(3*(next_ball_xr/32) + 60*(next_ball_yu/20))+:3] = 3'd0;
        next_bricks[(3*(next_ball_xr/32) + 60*(next_ball_yd/20))+:3] = 3'd0;
        next_bricks[(3*(next_ball_xl/32) + 60*(next_ball_yd/20))+:3] = 3'd0;


        // MENU state
        if(state == 0) begin
            next_bricks = bricks;
        end
    end

endmodule