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
    input clk,
    input nRst,
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
    
    reg in_paddle_x;
    reg [6:0] paddle_x;
    wire paddle_x_start = hpos == x;
    wire paddle_x_end = paddle_x == PADDLE_WIDTH - 1;

    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            paddle_x <= 0;
        end else begin
            if(in_paddle_x) begin
                paddle_x <= paddle_x + 1'b1;
            end else begin
                paddle_x <= 0;
            end
        end
    end    

    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            in_paddle_x <= 0;
        end else begin
            if(paddle_x_start) begin
                in_paddle_x <= 1;
            end else if(paddle_x_end) begin
                in_paddle_x <= 0;
            end
        end
    end

    reg in_paddle_y;
    wire in_paddle_y_start = vpos == PADDLE_Y;
    wire in_paddle_y_end = vpos == PADDLE_Y + PADDLE_HEIGHT;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            in_paddle_y <= 0;
        end else begin
            if(in_paddle_y_start) begin
                in_paddle_y <= 1;
            end else if(in_paddle_y_end) begin
                in_paddle_y <= 0;
            end
        end
    end

    assign color = PADDLE_COLOR;
    assign in_paddle = in_paddle_x && in_paddle_y;
endmodule
