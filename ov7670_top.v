`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 00:22:09
// Design Name: 
// Module Name: ov7670_top
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

module ov7670_top (
    input  wire        clk100,
    output wire        OV7670_SIOC,
    inout  wire        OV7670_SIOD,
    output wire        OV7670_RESET,
    output wire        OV7670_PWDN,
    input  wire        OV7670_VSYNC,
    input  wire        OV7670_HREF,
    input  wire        OV7670_PCLK,
    output wire        OV7670_XCLK,
    input  wire [7:0]  OV7670_DATA,

    output wire        config_finished,

    output wire [3:0]  vga_red,
    output wire [3:0]  vga_green,
    output wire [3:0]  vga_blue,
    output wire        vga_hsync,
    output wire        vga_vsync,

    input  wire        btn
);

    wire [14:0] frame_addr;
    wire [11:0] frame_pixel;

    wire [14:0] capture_addr;
    wire [11:0] capture_data;
    wire        capture_we;
    wire        resend;

    wire        clk50;
    wire        clk25;

    // -------------------------------------------------------------------
    // Button debounce
    // -------------------------------------------------------------------
    debounce btn_debounce (
        .clk (clk50),
        .i   (btn),
        .o   (resend)
    );

    // -------------------------------------------------------------------
    // VGA output
    // -------------------------------------------------------------------
    vga Inst_vga (
        .clk25       (clk25),
        .vga_red     (vga_red),
        .vga_green   (vga_green),
        .vga_blue    (vga_blue),
        .vga_hsync   (vga_hsync),
        .vga_vsync   (vga_vsync),
        .frame_addr  (frame_addr),
        .frame_pixel (frame_pixel)
    );

    // -------------------------------------------------------------------
    // Frame buffer (dual-port BRAM)
    // -------------------------------------------------------------------
    frame_buffer fb (
        .clka  (OV7670_PCLK),
        .wea   (capture_we),
        .addra (capture_addr),
        .dina  (capture_data),

        .clkb  (clk50),
        .enb   (1'b1),
        .addrb (frame_addr),
        .doutb (frame_pixel)
    );

    // -------------------------------------------------------------------
    // Camera capture
    // -------------------------------------------------------------------
    ov7670_capture capture (
        .pclk  (OV7670_PCLK),
        .vsync (OV7670_VSYNC),
        .href  (OV7670_HREF),
        .d     (OV7670_DATA),
        .addr  (capture_addr),
        .dout  (capture_data),
        .we    (capture_we)
    );

    // -------------------------------------------------------------------
    // Camera register/config controller
    // -------------------------------------------------------------------
    ov7670_controller controller (
        .clk             (clk50),
        .resend          (resend),
        .config_finished (config_finished),
        .siod            (OV7670_SIOD),
        .sioc            (OV7670_SIOC),
        .reset           (OV7670_RESET),
        .pwdn            (OV7670_PWDN),
        .xclk            (OV7670_XCLK)
    );

    // -------------------------------------------------------------------
    // Clock generation (MMCM/PLL wrapper)
    // -------------------------------------------------------------------
    clocking your_instance_name (
        .CLK_100 (clk100),
        .CLK_50  (clk50),
        .CLK_25  (clk25)
    );

endmodule