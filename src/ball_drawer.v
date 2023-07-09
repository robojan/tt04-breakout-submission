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


module ball_drawer(
    output in_ball,
    output [5:0] color,
    input [9:0] x,
    input [8:0] y,
    input [9:0] hpos,
    input [8:0] vpos
    );
    
    //                          BBGGRR
    parameter BALL_COLOR = 6'b001100;
    parameter BALL_WIDTH = 5; // Should be odd 
    
    assign color = BALL_COLOR;
    assign in_ball = (hpos >= x - (BALL_WIDTH / 2) && hpos < x + (BALL_WIDTH + 1) / 2) &&
        (vpos >= y - (BALL_WIDTH / 2) && vpos < y + (BALL_WIDTH + 1) / 2);
endmodule
