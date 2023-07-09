`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2023 09:48:35 PM
// Design Name: 
// Module Name: vga_timing
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


module vga_timing(
    input clk,
    input nRst,
    output hsync,
    output hactive,
    output [9:0] hpos,
    output vsync,
    output vactive,
    output [8:0] vpos,
    output active,
    output line_pulse,
    output frame_pulse
    );
    
    
    reg [9:0] hor_counter;
    wire hor_at_end = hor_counter == 10'd799;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            hor_counter <= 10'b0;
        end else begin
            if(hor_at_end) begin
                hor_counter <= 10'b0;            
            end else begin
                hor_counter <= hor_counter + 1'b1;
            end
        end
    end
    
    reg [9:0] vert_counter;
    wire vert_at_end = vert_counter == 10'd524;
    always @(posedge clk or negedge nRst)
    begin
        if(!nRst) begin
            vert_counter <= 10'b0;
        end else begin
            if(hor_at_end) begin
                if(vert_at_end) begin
                    vert_counter <= 10'b0;
                end else begin
                    vert_counter <= vert_counter + 1'b1;
                end            
            end
        end
    end
    
    assign line_pulse = hor_at_end;
    assign frame_pulse = vert_at_end && line_pulse; // Make sure that the pulse is only one clock cycle wide
    assign hsync = !(hor_counter >= 10'd656 && hor_counter < 10'd752);
    assign hactive = hor_counter < 10'd640;
    assign hpos = hor_counter;
    assign vsync = !(vert_counter >= 10'd490 && vert_counter < 10'd492);
    assign vactive = vert_counter < 10'd480;
    assign vpos = vert_counter[8:0];
    assign active = hactive && vactive;
    
endmodule
