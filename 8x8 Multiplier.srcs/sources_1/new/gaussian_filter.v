`timescale 1ns / 1ps
`include "PBOM8_73Y.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2026 11:10:14 AM
// Design Name: 
// Module Name: gaussian_filter
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


module gaussian_filter (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  p00, p01, p02,
    input  wire [7:0]  p10, p11, p12,
    input  wire [7:0]  p20, p21, p22,
    input  wire        valid_in,
    output reg  [7:0]  pixel_out,
    output reg         valid_out
);

    // Gaussian kernel h2:
    // [95  118  95 ]
    // [118 148 118 ]
    // [95  118  95 ]

    wire [15:0] prod00, prod01, prod02;
    wire [15:0] prod10, prod11, prod12;
    wire [15:0] prod20, prod21, prod22;

    // ── CHANGE THIS NAME TO YOUR DESIGN
    // Change PBOM8_73Y to your multiplier module name
    // You need to change it in ALL 9 lines below
    PBOM8_73Y m00(.A(p00), .B(8'd95),  .P(prod00));
    PBOM8_73Y m01(.A(p01), .B(8'd118), .P(prod01));
    PBOM8_73Y m02(.A(p02), .B(8'd95),  .P(prod02));
    PBOM8_73Y m10(.A(p10), .B(8'd118), .P(prod10));
    PBOM8_73Y m11(.A(p11), .B(8'd148), .P(prod11));
    PBOM8_73Y m12(.A(p12), .B(8'd118), .P(prod12));
    PBOM8_73Y m20(.A(p20), .B(8'd95),  .P(prod20));
    PBOM8_73Y m21(.A(p21), .B(8'd118), .P(prod21));
    PBOM8_73Y m22(.A(p22), .B(8'd95),  .P(prod22));

    // Accumulate all 9 products
    wire [21:0] sum;
    assign sum = prod00 + prod01 + prod02
               + prod10 + prod11 + prod12
               + prod20 + prod21 + prod22;

    // Normalize: divide by 256 (right shift 8)
    wire [13:0] normalized = sum >> 8;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_out <= 0;
            valid_out <= 0;
        end else begin
            valid_out <= valid_in;
            pixel_out <= (normalized > 14'd255) ? 
                          8'd255 : normalized[7:0];
        end
    end

endmodule
