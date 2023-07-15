`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2023 07:48:32 PM
// Design Name: 
// Module Name: ball_logic
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


module game_logic 
#(
    parameter INITIAL_BALL_X = 10'd320 - 3'd2,
    parameter INITIAL_BALL_Y = 9'd452 - 3'd2,
    parameter INITIAL_VEL_X = 4'sd2,
    parameter INITIAL_VEL_Y = -4'sd2,
    parameter PADDLE_SPEED = 2,
    parameter PADDLE_WIDTH = 99,
    parameter INITIAL_PADDLE_X = 10'd320 - PADDLE_WIDTH / 2 - 1,
    parameter BORDER_WIDTH = 8
)(
    input clk,
    input nRst,
    output [9:0] ball_x,
    output [8:0] ball_y,
    output [9:0] paddle_x,
    input frame_pulse,
    input btn_action,
    input btn_left,
    input btn_right,
    input collision,
    input ball_top_col,
    input ball_left_col,
    input ball_bottom_col,
    input ball_right_col
);

    wire ball_out_of_bounds;
    wire paddle_is_at_left_limit;
    wire paddle_is_at_right_limit;

    /////////////////////////////////////////////
    // Game state
    /////////////////////////////////////////////
    localparam STATE_START = 0;
    localparam STATE_PLAYING = 1;
    reg game_state;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            game_state <= STATE_START;
        end else begin
            if(frame_pulse) begin
                case(game_state)
                    STATE_START: begin
                        if (btn_action) begin
                            game_state <= STATE_PLAYING;
                        end
                    end
                    STATE_PLAYING: begin
                        if(ball_out_of_bounds) begin
                            game_state <= STATE_START;
                        end
                    end
                endcase
            end
        end
    end


    /////////////////////////////////////////////
    // Ball logic
    /////////////////////////////////////////////
    // Latched collisions
    // Collisions are evaluated at the end of the frame but we keep track of collisions during the drawing.
    reg latched_ball_top_collision;
    reg latched_ball_bottom_collision;
    reg latched_ball_left_collision;
    reg latched_ball_right_collision;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            latched_ball_top_collision <= 1'b0;
            latched_ball_bottom_collision <= 1'b0;
            latched_ball_left_collision <= 1'b0;
            latched_ball_right_collision <= 1'b0;        
        end else begin
            if (frame_pulse) begin
                latched_ball_top_collision <= 1'b0;
                latched_ball_bottom_collision <= 1'b0;
                latched_ball_left_collision <= 1'b0;
                latched_ball_right_collision <= 1'b0;    
            end else if(collision) begin
                latched_ball_top_collision <= latched_ball_top_collision | ball_top_col;
                latched_ball_bottom_collision <= latched_ball_bottom_collision | ball_bottom_col;
                latched_ball_left_collision <= latched_ball_left_collision | ball_left_col;
                latched_ball_right_collision <= latched_ball_right_collision | ball_right_col;
            end
        end
    end

    reg signed [3:0] velocity_x;
    reg signed [3:0] velocity_y;
    reg signed [11:0] ball_state_x;
    reg signed [10:0] ball_state_y;
    assign ball_out_of_bounds = ball_state_y[10:2] == 9'd488 >> 1; // Ignore the last bit
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            ball_state_x <= {INITIAL_BALL_X, 1'b0};
            ball_state_y <= {INITIAL_BALL_Y, 1'b0};
            velocity_x <= INITIAL_VEL_X;
            velocity_y <= INITIAL_VEL_Y;
        end else begin
            if(frame_pulse) begin
                case(game_state)
                    STATE_START: begin
                        if (btn_left && !paddle_is_at_left_limit) begin
                            ball_state_x <= ball_state_x - {PADDLE_SPEED, 1'b0};
                        end else if (btn_right && !paddle_is_at_right_limit) begin
                            ball_state_x <= ball_state_x + {PADDLE_SPEED, 1'b0};
                        end
                    end
                    STATE_PLAYING: begin
                        if(ball_out_of_bounds) begin
                            velocity_x <= INITIAL_VEL_X;
                            velocity_y <= INITIAL_VEL_Y;
                            ball_state_x <= {INITIAL_BALL_X, 1'b0};
                            ball_state_y <= {INITIAL_BALL_Y, 1'b0};
                        end else if (latched_ball_top_collision || latched_ball_bottom_collision) begin
                            velocity_x <= velocity_x;
                            velocity_y <= -velocity_y;
                            ball_state_x <= ball_state_x + velocity_x;
                            ball_state_y <= ball_state_y - velocity_y;
                        end else if (latched_ball_left_collision || latched_ball_right_collision) begin
                            velocity_x <= -velocity_x;
                            velocity_y <= velocity_y;
                            ball_state_x <= ball_state_x - velocity_x;
                            ball_state_y <= ball_state_y + velocity_y;
                        end else begin
                            ball_state_x <= ball_state_x + velocity_x;
                            ball_state_y <= ball_state_y + velocity_y;
                        end
                    end
                endcase
            end
        end
    end
    
    assign ball_x = ball_state_x[10:1];
    assign ball_y = ball_state_y[9:1];

    /////////////////////////////////////////////
    // Paddle logic
    /////////////////////////////////////////////    
    reg [9:0] paddle_state_x;
    // Ignore the bottom bit to account for the velocity of the paddle
    assign paddle_is_at_left_limit = paddle_state_x[9:1] == BORDER_WIDTH >> 1;
    assign paddle_is_at_right_limit = paddle_state_x[9:1] == (640 - BORDER_WIDTH - PADDLE_WIDTH) >> 1;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            paddle_state_x <= INITIAL_PADDLE_X;
        end else begin
            if(frame_pulse) begin
                if(ball_out_of_bounds) begin
                    paddle_state_x <= INITIAL_PADDLE_X;
                end else if (btn_left && !paddle_is_at_left_limit) begin
                    paddle_state_x <= paddle_state_x - PADDLE_SPEED;
                end else if (btn_right && !paddle_is_at_right_limit) begin
                    paddle_state_x <= paddle_state_x + PADDLE_SPEED;
                end
            end
        end
    end
    
    assign paddle_x = paddle_state_x;

endmodule
