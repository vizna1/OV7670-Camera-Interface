`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 00:49:41
// Design Name: 
// Module Name: ov7670_controller
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


module ov7670_controller (
    input  wire clk,
    input  wire resend,
    output wire config_finished,
    output wire sioc,
    inout  wire siod,
    output wire reset,
    output wire pwdn,
    output wire xclk
);

    reg  sys_clk  = 1'b0;
    wire [15:0] command;
    wire        finished;
    wire        taken;
    wire        send;

    // Device write ID - see top of page 11 of data sheet
    localparam [7:0] camera_address = 8'h42;

    assign config_finished = finished;

    assign send = ~finished;

    i2c_sender Inst_i2c_sender (
        .clk   (clk),
        .taken (taken),
        .siod  (siod),
        .sioc  (sioc),
        .send  (send),
        .id    (camera_address),
        .\reg  (command[15:8]),
        .value (command[7:0])
    );

    assign reset = 1'b1; // Normal mode
    assign pwdn  = 1'b0; // Power device up
    assign xclk  = sys_clk;

    ov7670_registers Inst_ov7670_registers (
        .clk      (clk),
        .advance  (taken),
        .command  (command),
        .finished (finished),
        .resend   (resend)
    );

    always @(posedge clk) begin
        sys_clk <= ~sys_clk;
    end

endmodule