`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 00:25:34
// Design Name: 
// Module Name: debounce
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


module debounce(
    input  wire clk,
    input  wire i,
    output reg  o
);

    reg [23:0] c;

    always @(posedge clk) begin
        if (i == 1'b1) begin
            if (c == 24'hFFFFFF)
                o <= 1'b1;
            else
                o <= 1'b0;
            c <= c + 1'b1;
        end else begin
            c <= 24'h000000;
            o <= 1'b0;
        end
    end

endmodule
