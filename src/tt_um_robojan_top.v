`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2023 07:53:38 PM
// Design Name: 
// Module Name: robojan_top
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


module tt_um_robojan_top (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    
    assign uio_oe = 8'b00000000;
    assign uio_out = 8'b00000000;

    breakout breakout(
        .clk(clk),
        .nRst(rst_n),
        .btn_left(ui_in[0]),
        .btn_right(ui_in[1]),
        .btn_select(ui_in[2]),
        .vga_r(uo_out[1:0]),
        .vga_g(uo_out[3:2]),
        .vga_b(uo_out[5:4]),
        .vga_hsync(uo_out[6]),
        .vga_vsync(uo_out[7])
    );
    
endmodule
