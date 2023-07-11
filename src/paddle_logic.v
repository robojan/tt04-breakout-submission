`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2023 07:50:47 PM
// Design Name: 
// Module Name: paddle_logic
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


module paddle_logic
#(
    parameter PADDLE_WIDTH = 99,
    parameter INITIAL_X = 10'd320 - PADDLE_WIDTH / 2 - 1,
    parameter BORDER_WIDTH = 8
)(
    input clk,
    input nRst,
    input frame_pulse,
    input button_left,
    input button_right,
    output [9:0] paddle_x
);
    
    reg [9:0] state_x;
    // Ignore the bottom bit to account for the velocity of the paddle
    wire is_at_left_limit = state_x[9:1] == BORDER_WIDTH >> 1;
    wire is_at_right_limit = state_x[9:1] == (640 - BORDER_WIDTH - PADDLE_WIDTH) >> 1;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            state_x <= INITIAL_X;
        end else begin
            if(frame_pulse) begin
                if (button_left && !is_at_left_limit) begin
                    state_x <= state_x - 2'd2;
                end else if (button_right && !is_at_right_limit) begin
                    state_x <= state_x + 2'd2;
                end
            end
        end
    end
    
    assign paddle_x = state_x;
endmodule
