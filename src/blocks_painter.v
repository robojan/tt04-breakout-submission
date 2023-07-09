`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2023 12:28:34 PM
// Design Name: 
// Module Name: blocks_drawer
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


module blocks_painter (
    input clk,
    input nRst,
    output block_en,
    output [5:0] color,
    input [9:0] hpos,
    input [8:0] vpos,
    input new_frame,
    input new_line,
    input [207:0] block_state
    );
    
    parameter BORDER_WIDTH = 8;
    parameter BLOCK_WIDTH = 48;
    parameter BLOCK_HEIGHT = 16;
    parameter BLOCKS_PER_ROW = 13;
    parameter NUM_ROWS = 16;
    
    wire [7:0] block_idx;
    
    wire in_vertical_block_region = vpos >= BORDER_WIDTH && vpos < (BORDER_WIDTH + NUM_ROWS * BLOCK_HEIGHT);
    wire in_horizontal_block_region = hpos >= BORDER_WIDTH && hpos < (BORDER_WIDTH + BLOCKS_PER_ROW * BLOCK_WIDTH); 
    wire in_block_region = in_horizontal_block_region && in_vertical_block_region; 
    
    reg [5:0] block_x_cnt;
    wire is_last_block_x = block_x_cnt == BLOCK_WIDTH-1;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            block_x_cnt <= 0;
        end else begin
            if(is_last_block_x || new_line) begin
                block_x_cnt <= 0;                
            end else if(in_horizontal_block_region) begin
                block_x_cnt <= block_x_cnt + 1'b1;
            end
        end
    end
    
    reg [3:0] block_y_cnt;
    wire is_last_block_y = block_y_cnt == NUM_ROWS-1;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            block_y_cnt <= 0;
        end else begin
            if((new_line && is_last_block_y) || new_frame) begin
                block_y_cnt <= 0;                
            end else if(new_line && in_vertical_block_region) begin
                block_y_cnt <= block_y_cnt + 1'b1;
            end
        end
    end
    
    reg [7:0] base_block_idx;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            base_block_idx <= 8'd0;
        end else begin
            if(new_frame) begin
                base_block_idx <= 8'd0;
            end else if(new_line && in_vertical_block_region && is_last_block_y) begin
                base_block_idx <= block_idx;
            end
        end
    end
    
    reg [3:0] block_offset_idx;
    assign block_idx = base_block_idx + block_offset_idx;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            block_offset_idx <= 8'd0;
        end else begin
            if(new_line || new_frame) begin
                block_offset_idx <= 8'd0;
            end else if(is_last_block_x && in_block_region) begin
                block_offset_idx <= block_offset_idx + 1'b1;
            end
        end
    end
    
    assign block_idx = base_block_idx + block_offset_idx;
    
    wire in_block_border = block_y_cnt == 0 || block_x_cnt == 0 || block_x_cnt == BLOCK_WIDTH - 1 || block_y_cnt == BLOCK_HEIGHT - 1; 
    wire current_block_present = block_state[block_idx];
    wire in_block = in_block_region && current_block_present && !in_block_border;
    
    assign block_en = in_block;
    assign color = 6'b110000;
    
endmodule
