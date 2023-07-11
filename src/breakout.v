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

    parameter NUM_ROWS = 8;
    
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
    wire [5:0] border_color;
    wire draw_border;
    wire [5:0] ball_color;
    wire draw_ball;
    wire [5:0] paddle_color;
    wire draw_paddle;
    wire [5:0] blocks_color;
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
    wire [9:0]ball_x;
    wire [8:0]ball_y;
    wire ball_top_en;
    wire ball_left_en;
    wire ball_bottom_en;
    wire ball_right_en;
    ball_painter ball_painter(
        .clk(clk),
        .nRst(nRst),
        .in_ball(draw_ball),
        .in_ball_top(ball_top_en),
        .in_ball_left(ball_left_en),
        .in_ball_bottom(ball_bottom_en),
        .in_ball_right(ball_right_en),
        .color(ball_color),
        .x(ball_x),
        .y(ball_y),
        .hpos(vga_hpos),
        .vpos(vga_vpos),
        .line_pulse(vga_line_pulse)
    );
    
    // Paddle painter
    wire [9:0]paddle_x;
    paddle_painter paddle_painter(
        .clk(clk),
        .nRst(nRst),
        .in_paddle(draw_paddle),
        .color(paddle_color),
        .x(paddle_x),
        .hpos(vga_hpos),
        .vpos(vga_vpos)
    );
    
    // Blocks painter
    blocks_painter #(
        .NUM_ROWS(NUM_ROWS)
    ) blocks_painter(
        .clk(clk),
        .nRst(nRst),
        .block_en(draw_blocks),
        .color(blocks_color),
        .hpos(vga_hpos),
        .vpos(vga_vpos),
        .new_frame(vga_frame_pulse),
        .new_line(vga_line_pulse),
        .display_active(vga_active),
        .block_line_state(block_line_state),
        .go_next_line(state_go_next_line)
    );
    
    // Collisions
    wire wall_collision = draw_border && draw_ball;
    wire paddle_collision = draw_paddle && draw_ball;
    wire block_collision = draw_blocks && draw_ball;
    wire collision = wall_collision || paddle_collision || block_collision;
    
    // State storage
    wire [12:0] block_line_state;
    wire state_go_next_line;
    block_state  #(
        .NUM_ROWS(NUM_ROWS)
    ) block_state (
        .clk(clk),
        .nRst(nRst),
        .line(block_line_state),
        .next_line(state_go_next_line)
    );
    
    // Game logic
    ball_logic ball_logic(
        .clk(clk),
        .nRst(nRst),
        .x(ball_x),
        .y(ball_y),
        .frame_pulse(vga_frame_pulse),
        .do_move(1'b1),
        .collision(collision),
        .ball_top_col(ball_top_en),
        .ball_left_col(ball_left_en),
        .ball_bottom_col(ball_bottom_en),
        .ball_right_col(ball_right_en)
    );
    
    paddle_logic paddle_logic(
        .clk(clk),
        .nRst(nRst),
        .frame_pulse(vga_frame_pulse),
        .paddle_x(paddle_x),
        .button_left(btn_left),
        .button_right(btn_right)
    );
    
endmodule
