`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 00:35:41
// Design Name: 
// Module Name: ov7670_capture
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

module ov7670_capture (
    input  wire        pclk,
    input  wire        vsync,
    input  wire        href,
    input  wire [7:0]  d,
    output wire [14:0] addr,
    output reg  [11:0] dout,
    output reg         we
);

    reg [15:0] d_latch      = 16'h0000;
    reg [14:0] address      = 15'h0000;
    reg [14:0] address_next = 15'h0000;
    reg [1:0]  wr_hold      = 2'b00;
    reg [1:0]  pixel_count  = 2'd0; // Contador para seleccionar pixeles (0 to 3)

    assign addr = address;

    always @(posedge pclk) begin
        if (vsync == 1'b1) begin
            address      <= 15'h0000;
            address_next <= 15'h0000;
            wr_hold      <= 2'b00;
            pixel_count  <= 2'd0; // Reiniciar contador al inicio del frame
        end else begin
            dout <= {d_latch[11:8],  // 4 bits para rojo
                     d_latch[15:12], // 4 bits para verde
                     d_latch[7:4]};  // 4 bits para azul
            address <= address_next;
            we      <= 1'b0;
            if (href == 1'b1) begin
                // Incrementar el contador de pixeles
                if (pixel_count == 2'd3) begin
                    pixel_count  <= 2'd0;
                    we           <= 1'b1; // Habilitar escritura para el primer pixel de cada 4
                    address_next <= address_next + 15'd1;
                end else begin
                    pixel_count <= pixel_count + 2'd1;
                end
            end
            d_latch <= {d_latch[7:0], d}; // Almacenar los datos de entrada
        end
    end

endmodule