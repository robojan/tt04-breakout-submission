`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2023 11:43:48 AM
// Design Name: 
// Module Name: paddle_drawer
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


module paddle_painter (
    output in_paddle,
    output [5:0] color,
    input [9:0] hpos,
    input [8:0] vpos,
    input [9:0] x
    );
    
    
    //                          BBGGRR
    parameter PADDLE_COLOR = 6'b111111;
    parameter PADDLE_WIDTH = 10'd99; // Should be odd
    parameter PADDLE_HEIGHT = 9'd8;
    parameter PADDLE_Y =  9'd456;
    
    assign color = PADDLE_COLOR;
    assign in_paddle = (hpos >= x - (PADDLE_WIDTH / 2) && hpos < x + (PADDLE_WIDTH + 1) / 2) &&
        (vpos >= PADDLE_Y  && vpos < PADDLE_Y + PADDLE_HEIGHT);
endmodule
