`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2023 07:53:38 PM
// Design Name: 
// Module Name: breakout
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


module breakout(
    input clk,
    input nRst,
    input en,
    input btn_left,
    input btn_right,
    input btn_select,
    output [1:0] vga_r,
    output [1:0] vga_g,
    output [1:0] vga_b,
    output vga_hsync,
    output vga_vsync,
    output [7:0] dbg
    );
    
    // Generate the VGA timing
    wire vga_hactive;
    wire [9:0] vga_hpos;
    wire vga_vactive;
    wire [8:0] vga_vpos;
    wire vga_line_pulse;
    wire vga_frame_pulse;
    wire vga_active;
    vga_timing vga_timing(
        .clk(clk),
        .nRst(nRst),
        .hsync(vga_hsync),
        .hactive(vga_hactive),
        .hpos(vga_hpos),
        .vsync(vga_vsync),
        .vactive(vga_vactive),
        .vpos(vga_vpos),
        .active(vga_active),
        .line_pulse(vga_line_pulse),
        .frame_pulse(vga_frame_pulse)
    );
    
    // Video mux
    wire [5:0] video_out;
    wire [6:0] border_color;
    wire draw_border;
    wire [6:0] ball_color;
    wire draw_ball;
    wire [6:0] paddle_color;
    wire draw_paddle;
    wire [6:0] blocks_color;
    wire draw_blocks;
    video_mux video_mux(
        .out(video_out),
        .in_frame(vga_active),
        .background(6'b000000),
        .border(border_color),
        .border_en(draw_border),
        .ball(ball_color),
        .ball_en(draw_ball),
        .paddle(paddle_color),
        .paddle_en(draw_paddle),
        .blocks(blocks_color),
        .blocks_en(draw_blocks)
    );
    assign vga_r = video_out[1:0];
    assign vga_g = video_out[3:2];
    assign vga_b = video_out[5:4];
    
    // Border generator
    border_painter border(
        .in_border(draw_border),
        .color(border_color),
        .hpos(vga_hpos),
        .vpos(vga_vpos)
    );
    
    // Ball painter
    wire [9:0]ball_x = 10'd320;
    wire [8:0]ball_y = 9'd240;
    ball_painter ball_painter(
        .in_ball(draw_ball),
        .color(ball_color),
        .x(ball_x),
        .y(ball_y),
        .hpos(vga_hpos),
        .vpos(vga_vpos)
    );
    
    // Paddle painter
    wire [9:0]paddle_x = 10'd320;
    paddle_painter paddle_painter(
        .in_paddle(draw_paddle),
        .color(paddle_color),
        .x(paddle_x),
        .hpos(vga_hpos),
        .vpos(vga_vpos)
    );
    
    // Blocks drawer
    wire [207:0] block_state = {
        13'b1010101010101,
        13'b0101010101010,
        13'b1010101010101,
        13'b0101010101010,
        13'b1010101010101,
        13'b0101010101010,
        13'b1010101010101,
        13'b0101010101010,
        13'b1010101010101,
        13'b0101010101010,
        13'b1010101010101,
        13'b0101010101010,
        13'b1010101010101,
        13'b0101010101010,
        13'b1010101010101,
        13'b0101010101010
    };
    blocks_painter blocks_painter(
        .clk(clk),
        .nRst(nRst),
        .block_en(draw_blocks),
        .color(blocks_color),
        .hpos(vga_hpos),
        .vpos(vga_vpos),
        .new_frame(vga_frame_pulse),
        .new_line(vga_line_pulse),
        .block_state(block_state)
    );
    
    
    assign dbg[0] = vga_hactive;
    assign dbg[1] = vga_vactive;
    assign dbg[2] = vga_active;
    
endmodule
