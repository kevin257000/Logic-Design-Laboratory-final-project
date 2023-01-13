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
    input clk,
    input rst,
    input wire [1439:0] bricks,
    input ball_x,
    input ball_y,
    input board_x,
    input board_y,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output [16:0] pixel_addr
  );
    
    reg [16:0] addr;
    reg hint,hint2;
    reg [2:0] block;

    // 3*20*24 = 1440
    //9*2的array, 存7bits.[0]指X軸(水平方向)左上角為原點
    //    x1 x2 x3
    // y1  0  1  2
    // y2  3  4  5
    // y3  6  7  8

    assign pixel_addr = addr;

    always @(*) begin
        hint = (h_cnt < ball_x + 16 + 1) && (h_cnt >= ball_x) && (v_cnt < ball_y + 10 + 1) && (v_cnt >= ball_y);
        //hint2 = (h_cnt < board_x + 96 + 1) && (h_cnt >= board_x) && (v_cnt < board_y + 10 + 1) && (v_cnt >= board_y);
        block = bricks[(3*((h_cnt/32) + 20*(v_cnt/20)))+:3];
    end

    always@(*)begin
        if(hint) begin
            addr = ((h_cnt%32)+32*2)+(v_cnt%20)*96;
        end
        /*
        else if(hint2) begin
            addr = ((h_cnt%32)+32*3)+(v_cnt%20)*96;
        end 
        */
        else begin
            addr = ((h_cnt%32)+32*block)+(v_cnt%20)*96;
        end
    end
      
endmodule
