`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2023 11:43:48 AM
// Design Name: 
// Module Name: ball_drawer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ball_painter(
    output in_ball,
    output in_ball_top,
    output in_ball_bottom,
    output in_ball_left,
    output in_ball_right,
    output [5:0] color,
    input [9:0] x,
    input [8:0] y,
    input [9:0] hpos,
    input [8:0] vpos
    );
    
    //                          BBGGRR
    parameter BALL_COLOR = 6'b001100;
    
    // Pixel ball positions:
    //   0 1   2 3
    // 0   X X X  
    // 1 X X X X X
    //   X X X X X
    // 2 X X X X X
    // 3   X X X
    
    wire gt_x0 = hpos >= x - 2;
    wire gt_x1 = hpos >= x - 1;
    wire lt_x2 = hpos <= x + 1;
    wire lt_x3 = hpos <= x + 2;
    wire gt_y0 = vpos >= y - 2;
    wire gt_y1 = vpos >= y - 1;
    wire lt_y2 = vpos <= y + 1;
    wire lt_y3 = vpos <= y + 2;
    
    wire left_lobe = gt_x0 && lt_x2 && gt_y1 && lt_y2;
    wire right_lobe = gt_x1 && lt_x3 && gt_y1 && lt_y2;
    wire top_lobe = gt_x1 && lt_x2 && gt_y0 && lt_y2;
    wire bottom_lobe = gt_x1 && lt_x2 && gt_y1 && lt_y3;
    wire left_mask = gt_x1 && lt_x3 && gt_y0 && lt_y3;
    wire right_mask = gt_x0 && lt_x2 && gt_y0 && lt_y3;
    wire top_mask = gt_x0 && lt_x3 && gt_y1 && lt_y3;
    wire bottom_mask = gt_x0 && lt_x3 && gt_y0 && lt_y2;
    
    assign in_ball = left_lobe || right_lobe || top_lobe || bottom_lobe;
    assign in_ball_top = top_lobe && !top_mask;
    assign in_ball_left = left_lobe && !left_mask;
    assign in_ball_bottom = bottom_lobe && !bottom_mask;
    assign in_ball_right = right_lobe && !right_mask;
    
    assign color = BALL_COLOR;
endmodule
