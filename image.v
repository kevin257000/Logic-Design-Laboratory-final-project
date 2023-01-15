`timescale 1ns/1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////
module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk)
        if (reset)
            pixel_cnt <= 0;
        else
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            hsync_i <= hsync_default;
        else
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 

    always @(posedge pclk)
        if (reset)
            line_cnt <= 0;
        else
            if (pixel_cnt == (HT -1))
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;
endmodule

module mem_addr_gen(
    input [2:0] state,
    input wire [1439:0] bricks,
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] board_x,
    input [9:0] board_y,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [2:0] skill_remain,
    input [9:0] bulletA_x,
    input [9:0] bulletA_y,
    input [9:0] bulletB_x,
    input [9:0] bulletB_y,
    output [16:0] pixel_addr
  );
    
    reg [16:0] addr;
    reg hint,hint2,hint3,hint4,hint5;
    reg [2:0] block;

    // 3*20*24 = 1440
    //9*2的array, 存7bits.[0]指X軸(水平方向)左上角為原點
    //    x1 x2 x3
    // y1  0  1  2
    // y2  3  4  5
    // y3  6  7  8

    assign pixel_addr = addr;

    integer _x,_y,_xA,_yA,_xB,_yB;

    always @(*) begin
        if(h_cnt < ball_x+8) _x = ball_x+8-h_cnt;
        else _x = h_cnt - (ball_x+8);
    end

    always @(*) begin
        if(v_cnt < ball_y+10) _y = ball_y+10-v_cnt;
        else _y = v_cnt - (ball_y+10);
    end

    always @(*) begin
        if(h_cnt < bulletA_x+8) _xA = bulletA_x+8-h_cnt;
        else _xA = h_cnt - (bulletA_x+8);
    end

    always @(*) begin
        if(v_cnt < bulletA_y+10) _yA = bulletA_y+10-v_cnt;
        else _yA = v_cnt - (bulletA_y+10);
    end

    always @(*) begin
        if(h_cnt < bulletB_x+8) _xB = bulletB_x+8-h_cnt;
        else _xB = h_cnt - (bulletB_x+8);
    end

    always @(*) begin
        if(v_cnt < bulletB_y+10) _yB = bulletB_y+10-v_cnt;
        else _yB = v_cnt - (bulletB_y+10);
    end

    always @(*) begin
        
        //hint = (h_cnt < ball_x + 16 + 1) && (h_cnt >= ball_x) && (v_cnt < ball_y + 10 + 1) && (v_cnt >= ball_y) ;
        hint = (h_cnt < board_x + 96*(1+skill_remain[0]) + 1) && (h_cnt >= board_x) && (v_cnt < board_y + 10 + 1) && (v_cnt >= board_y);
        hint2 = ((_x*_x +_y*_y) < 100);
        hint3 = ((_xA*_xA +_yA*_yA) < 100)&&(bulletA_y!=700);
        hint4 = ((_xB*_xB +_yB*_yB) < 100)&&(bulletB_y!=700);

        block = bricks[(3*((h_cnt/32) + 20*(v_cnt/20)))+:3];
    end

    parameter MENU = 3'd0;
    parameter WIN = 3'd1;
    parameter LOSE = 3'd2;
    parameter STAGE1 = 3'd3;

    always @(*) begin
        case(state)
            MENU : begin
                addr = ((h_cnt>>1)+320*(v_cnt>>1))% 76800; //640*480 --> 320*240
                //addr = ((h_cnt%32)+32*block)+(v_cnt%20)*96;
            end
            WIN : begin
                addr = ((h_cnt>>2)+160*(v_cnt>>2))% 19200; //640*480 --> 160*120
            end
            LOSE : begin
                addr = ((h_cnt>>2)+160*(v_cnt>>2))% 19200; //640*480 --> 160*120
            end
            STAGE1 : begin
                if(hint) begin
                    addr = ((h_cnt%32)+32*3)+(v_cnt%20+20)*96;
                end
                else if(hint2) begin
                    addr = ((h_cnt%32)+32*2)+(v_cnt%20)*96;
                end
                else if(hint3) begin
                    addr = ((h_cnt%32)+32*5)+(v_cnt%20+20)*96;
                end
                else if(hint4) begin
                    addr = ((h_cnt%32)+32*5)+(v_cnt%20+20)*96;
                end
                else begin
                    addr = ((h_cnt%32)+32*block)+(v_cnt%20+20*(block/3))*96;
                end
            end
            default : begin
                if(hint) begin
                    addr = ((h_cnt%32)+32*3)+(v_cnt%20+20)*96;
                end
                else if(hint2) begin
                    addr = ((h_cnt%32)+32*2)+(v_cnt%20)*96;
                end
                else if(hint3) begin
                    addr = ((h_cnt%32)+32*5)+(v_cnt%20)*96;
                end
                else if(hint4) begin
                    addr = ((h_cnt%32)+32*5)+(v_cnt%20)*96;
                end
                else begin
                    addr = ((h_cnt%32)+32*block)+(v_cnt%20+20*(block/3))*96;
                end
            end
        endcase
    end
      
endmodule
