`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 00:28:30
// Design Name: 
// Module Name: i2c_sender
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

// NOTE: "reg" is a reserved keyword in Verilog, so the register-name port
// is written as the escaped identifier \reg (with the required trailing
// space). Referring to it elsewhere (e.g. in a port map) also requires
// the escaped form: \reg .
module i2c_sender (
    input  wire        clk,
    inout  wire         siod,
    output reg          sioc,
    output reg          taken,
    input  wire         send,
    input  wire [7:0]   id,
    input  wire [7:0]   \reg ,
    input  wire [7:0]   value
);

    // Initial value gives a 254-cycle pause before the initial frame is sent
    reg [7:0]  divider = 8'b0000_0001;
    reg [31:0] busy_sr = 32'h0000_0000;
    reg [31:0] data_sr = 32'hFFFF_FFFF;

    // -------------------------------------------------------------------
    // Combinational: tri-state SIOD driver
    // -------------------------------------------------------------------
    wire release_siod;
    assign release_siod = (busy_sr[11:10] == 2'b10) ||
                           (busy_sr[20:19] == 2'b10) ||
                           (busy_sr[29:28] == 2'b10);

    assign siod = release_siod ? 1'bz : data_sr[31];

    // -------------------------------------------------------------------
    // Clocked: shift-register based I2C bit-banger
    // -------------------------------------------------------------------
    always @(posedge clk) begin
        taken <= 1'b0;

        if (busy_sr[31] == 1'b0) begin
            sioc <= 1'b1;
            if (send == 1'b1) begin
                if (divider == 8'b0000_0000) begin
                    data_sr <= {3'b100, id, 1'b0, \reg , 1'b0, value, 1'b0, 2'b01};
                    busy_sr <= {3'b111, 9'b1_1111_1111, 9'b1_1111_1111, 9'b1_1111_1111, 2'b11};
                    taken   <= 1'b1;
                end else begin
                    divider <= divider + 1'b1; // this only happens on powerup
                end
            end
        end else begin
            case ({busy_sr[31:29], busy_sr[2:0]})
                6'b111_111: // start seq #1
                    case (divider[7:6])
                        2'b00:   sioc <= 1'b1;
                        2'b01:   sioc <= 1'b1;
                        2'b10:   sioc <= 1'b1;
                        default: sioc <= 1'b1;
                    endcase

                6'b111_110: // start seq #2
                    case (divider[7:6])
                        2'b00:   sioc <= 1'b1;
                        2'b01:   sioc <= 1'b1;
                        2'b10:   sioc <= 1'b1;
                        default: sioc <= 1'b1;
                    endcase

                6'b111_100: // start seq #3
                    case (divider[7:6])
                        2'b00:   sioc <= 1'b0;
                        2'b01:   sioc <= 1'b0;
                        2'b10:   sioc <= 1'b0;
                        default: sioc <= 1'b0;
                    endcase

                6'b110_000: // end seq #1
                    case (divider[7:6])
                        2'b00:   sioc <= 1'b0;
                        2'b01:   sioc <= 1'b1;
                        2'b10:   sioc <= 1'b1;
                        default: sioc <= 1'b1;
                    endcase

                6'b100_000: // end seq #2
                    case (divider[7:6])
                        2'b00:   sioc <= 1'b1;
                        2'b01:   sioc <= 1'b1;
                        2'b10:   sioc <= 1'b1;
                        default: sioc <= 1'b1;
                    endcase

                6'b000_000: // Idle
                    case (divider[7:6])
                        2'b00:   sioc <= 1'b1;
                        2'b01:   sioc <= 1'b1;
                        2'b10:   sioc <= 1'b1;
                        default: sioc <= 1'b1;
                    endcase

                default:
                    case (divider[7:6])
                        2'b00:   sioc <= 1'b0;
                        2'b01:   sioc <= 1'b1;
                        2'b10:   sioc <= 1'b1;
                        default: sioc <= 1'b0;
                    endcase
            endcase

            if (divider == 8'b1111_1111) begin
                busy_sr <= {busy_sr[30:0], 1'b0};
                data_sr <= {data_sr[30:0], 1'b1};
                divider <= 8'b0000_0000;
            end else begin
                divider <= divider + 1'b1;
            end
        end
    end

endmodule