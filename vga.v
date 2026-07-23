`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 00:43:02
// Design Name: 
// Module Name: vga
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


module vga (
    input  wire        clk25,
    output reg  [3:0]  vga_red,
    output reg  [3:0]  vga_green,
    output reg  [3:0]  vga_blue,
    output reg         vga_hsync,
    output reg         vga_vsync,
    output wire [14:0] frame_addr,
    input  wire [11:0] frame_pixel
);

    // Timing constants
    localparam integer hRez       = 640;
    localparam integer hStartSync = 640+16;
    localparam integer hEndSync   = 640+16+96;
    localparam integer hMaxCount  = 800;

    localparam integer vRez       = 480;
    localparam integer vStartSync = 480+10;
    localparam integer vEndSync   = 480+10+2;
    localparam integer vMaxCount  = 480+10+2+33;

    localparam hsync_active = 1'b0;
    localparam vsync_active = 1'b0;

    reg [9:0]  hCounter = 10'd0;
    reg [9:0]  vCounter = 10'd0;
    reg [16:0] address  = 17'd0;
    reg        blank    = 1'b1;

    assign frame_addr = address[14:0];

    always @(posedge clk25) begin
        // Count the lines and rows
        if (hCounter == hMaxCount-1) begin
            hCounter <= 10'd0;
            if (vCounter == vMaxCount-1) begin
                vCounter <= 10'd0;
            end else begin
                vCounter <= vCounter + 10'd1;
            end
        end else begin
            hCounter <= hCounter + 10'd1;
        end

        if (blank == 1'b0 && hCounter < 320 && vCounter < 180) begin
            vga_red   <= frame_pixel[11:8];
            vga_green <= frame_pixel[7:4];
            vga_blue  <= frame_pixel[3:0];
            address   <= address + 17'd1; // Incrementa solo dentro del area visible
        end else begin
            vga_red   <= 4'b0000;
            vga_green <= 4'b0000;
            vga_blue  <= 4'b0000;
        end

        if (vCounter >= vRez) begin
            address <= 17'd0;
            blank   <= 1'b1;
        end else begin
            if (hCounter < 640) begin
                blank   <= 1'b0;
                address <= address + 17'd1;
            end else begin
                blank <= 1'b1;
            end
        end

        // Are we in the hSync pulse? (one has been added to include frame_buffer_latency)
        if (hCounter > hStartSync && hCounter <= hEndSync) begin
            vga_hsync <= hsync_active;
        end else begin
            vga_hsync <= ~hsync_active;
        end

        // Are we in the vSync pulse?
        if (vCounter >= vStartSync && vCounter < vEndSync) begin
            vga_vsync <= vsync_active;
        end else begin
            vga_vsync <= ~vsync_active;
        end
    end

endmodule
