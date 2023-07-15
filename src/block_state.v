`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2023 08:48:28 PM
// Design Name: 
// Module Name: block_state
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


module block_state #(
    parameter NUM_ROWS = 16
)(
    input clk,
    input nRst,
    output [12:0] line,
    input [12:0] new_line,
    input write_line,
    input next_line
);

    localparam STATE_WIDTH = NUM_ROWS * 13;

    localparam INITIAL_STATE = {
        13'b1010101010000,
        13'b0101010100001,
        13'b1010101010010,
        13'b0101010100011,
        13'b1010101010100,
        13'b0101010100101,
        13'b1010101010110,
        13'b0101010100111,
        13'b1010101011000,
        13'b0101010101001,
        13'b1010101011010,
        13'b0101010101011,
        13'b1010101011100,
        13'b0101010101101,
        13'b1010101011110,
        13'b0101010101111
    };

    reg [STATE_WIDTH-1:0] state;
    always @(posedge clk or negedge nRst)
    begin
        if (!nRst) begin
            state <= INITIAL_STATE;
        end else begin
            if (write_line) begin
                state <= {state[STATE_WIDTH - 1:13], new_line};
            end else if (next_line) begin
                state <= {state[12:0], state[STATE_WIDTH - 1:13]};
            end
        end
    end

    assign line = state[12:0];
endmodule
