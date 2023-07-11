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
    input display_active,
    input [12:0] block_line_state,
    output go_next_line
    );
    
    parameter BORDER_WIDTH = 8;
    parameter BLOCK_WIDTH = 48;
    parameter BLOCK_HEIGHT = 24;
    parameter BLOCKS_PER_ROW = 13;
    parameter NUM_ROWS = 16;
    
    reg in_vertical_block_region;
    wire vertical_block_region_start = vpos == BORDER_WIDTH && display_active;
    wire vertical_block_region_end = vpos == BORDER_WIDTH + NUM_ROWS * BLOCK_HEIGHT;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            in_vertical_block_region <= 1'b0;
        end else begin
            if(vertical_block_region_start) begin
                in_vertical_block_region <= 1'b1;
            end else if(vertical_block_region_end) begin
                in_vertical_block_region <= 1'b0;
            end
        end
    end

    reg in_horizontal_block_region;
    wire horizontal_block_region_start = hpos == BORDER_WIDTH - 1 && display_active;
    wire horizontal_block_region_end = hpos == (BORDER_WIDTH + BLOCKS_PER_ROW * BLOCK_WIDTH) - 1; 
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            in_horizontal_block_region <= 1'b0;
        end else begin
            if(horizontal_block_region_start) begin
                in_horizontal_block_region <= 1'b1;
            end else if(horizontal_block_region_end) begin
                in_horizontal_block_region <= 1'b0;
            end
        end
    end

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
    
    reg [4:0] block_y_cnt;
    wire is_last_block_y = block_y_cnt == BLOCK_HEIGHT-1;
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
    assign go_next_line = new_line && in_vertical_block_region && is_last_block_y;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            base_block_idx <= 8'd0;
        end else begin
            if(new_frame) begin
                base_block_idx <= 8'd0;
            end else if(go_next_line) begin
                base_block_idx <= base_block_idx + BLOCKS_PER_ROW;
            end
        end
    end
    
    reg [3:0] block_offset_idx;
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
        
    wire in_block_border = block_y_cnt == 0 || block_x_cnt == 0 || block_x_cnt == BLOCK_WIDTH - 1 || block_y_cnt == BLOCK_HEIGHT - 1; 
    wire current_block_present = block_line_state[block_offset_idx];
    wire in_block = in_block_region && current_block_present && !in_block_border;
    
    assign block_en = in_block;
    assign color = 6'b110000;
    
endmodule
