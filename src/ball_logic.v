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


module ball_logic 
#(
    parameter INITIAL_X = 10'd320,
    parameter INITIAL_Y = 9'd452,
    parameter INITIAL_VEL_X = 4'sd2,
    parameter INITIAL_VEL_Y = -4'sd2
)(
    input clk,
    input nRst,
    output [9:0] x,
    output [8:0] y,
    input frame_pulse,
    input do_move,
    input collision,
    input ball_top_col,
    input ball_left_col,
    input ball_bottom_col,
    input ball_right_col
);

    // Latched collisions
    // Collisions are evaluated at the end of the frame but we keep track of collisions during the drawing.
    reg latched_collision;
    reg latched_ball_top_collision;
    reg latched_ball_bottom_collision;
    reg latched_ball_left_collision;
    reg latched_ball_right_collision;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            latched_collision <= 1'b0;
            latched_ball_top_collision <= 1'b0;
            latched_ball_bottom_collision <= 1'b0;
            latched_ball_left_collision <= 1'b0;
            latched_ball_right_collision <= 1'b0;        
        end else begin
            if (frame_pulse) begin
                latched_collision <= 1'b0;
                latched_ball_top_collision <= 1'b0;
                latched_ball_bottom_collision <= 1'b0;
                latched_ball_left_collision <= 1'b0;
                latched_ball_right_collision <= 1'b0;    
            end else if(collision) begin
                latched_collision <= 1'b1;
                latched_ball_top_collision <= latched_ball_top_collision | ball_top_col;
                latched_ball_bottom_collision <= latched_ball_bottom_collision | ball_bottom_col;
                latched_ball_left_collision <= latched_ball_left_collision | ball_left_col;
                latched_ball_right_collision <= latched_ball_right_collision | ball_right_col;
            end
            
            
        end
    end

    reg signed [3:0] velocity_x;
    reg signed [3:0] velocity_y;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
        end else begin
            if(collision) begin
            end        
        end
    end

    reg signed [11:0] state_x;
    reg signed [10:0] state_y;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            state_x <= {INITIAL_X, 1'b0};
            state_y <= {INITIAL_Y, 1'b0};
            velocity_x <= INITIAL_VEL_X;
            velocity_y <= INITIAL_VEL_Y;
        end else begin
            if(do_move && frame_pulse) begin
                if(latched_collision) begin
                    if (latched_ball_top_collision || latched_ball_bottom_collision) begin
                        velocity_x <= velocity_x;
                        velocity_y <= -velocity_y;
                        state_x <= state_x + velocity_x;
                        state_y <= state_y - velocity_y;
                    end else if (latched_ball_left_collision || latched_ball_right_collision) begin
                        velocity_x <= -velocity_x;
                        velocity_y <= velocity_y;
                        state_x <= state_x - velocity_x;
                        state_y <= state_y + velocity_y;
                    end
                end else begin
                    state_x <= state_x + velocity_x;
                    state_y <= state_y + velocity_y;
                end
            end
        end
    end
    
    assign x = state_x[10:1];
    assign y = state_y[9:1];

endmodule
