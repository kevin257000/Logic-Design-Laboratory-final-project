module ball_control(
    input wire [1439:0] bricks,
    input wire [9:0] ball_x,
    input wire [9:0] ball_y,
    input wire [9:0] ball_vx,
    input wire [9:0] ball_vy,
    input wire [1:0] ball_dir,

    output reg [1439:0] next_bricks,
    output reg [9:0] next_ball_x,
    output reg [9:0] next_ball_y,
    output reg [9:0] next_ball_vx,
    output reg [9:0] next_ball_vy,
    output reg [1:0] next_ball_dir
);

    parameter H = 640;
    parameter V = 480;

    reg [1:0] wall_collision;
    always @(*) begin
        wall_collision = 2'b00; // x/y

        if(ball_dir[1] == 1) begin // 向右
            if(ball_vx + ball_x > H) begin // 撞牆
                wall_collision[1] = 1;
                next_ball_x = H - ( ball_vx + ball_x - H ); // 右側-彈回量
            end
            else next_ball_x = ball_x + ball_vx;
        end
        else begin // 向左
            if(ball_vx > ball_x) begin // 撞牆
                wall_collision[1] = 1;
                next_ball_x = ball_vx - ball_x;
            end
            else next_ball_x = ball_x - ball_vx;
        end

        if(ball_dir[0] == 1) begin // 向下
            if(ball_vy + ball_y > V) begin // 撞牆
                wall_collision[1] = 1;
                next_ball_y = V - ( ball_vy + ball_y - V ); // 下側-彈回量
            end
            else next_ball_y = ball_y + ball_vy;
        end
        else begin // 向上
            if(ball_vy > ball_y) begin // 撞牆
                wall_collision[1] = 1;
                next_ball_y = ball_vy - ball_y;
            end
            else next_ball_y = ball_y - ball_vy;
        end
    end

    // collision detect
    // if()


endmodule