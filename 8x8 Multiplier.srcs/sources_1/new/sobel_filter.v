`timescale 1ns / 1ps
`include "PBOM8_73Y.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2026 11:16:34 AM
// Design Name: 
// Module Name: sobel_filter
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


module sobel_filter (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  p00, p01, p02,
    input  wire [7:0]  p10, p11, p12,
    input  wire [7:0]  p20, p21, p22,
    input  wire        valid_in,
    output reg  [7:0]  edge_out,
    output reg         valid_out
);

    // Sx = [-1  0 +1]    Sy = [-1 -2 -1]
    //      [-2  0 +2]         [ 0  0  0]
    //      [-1  0 +1]         [+1 +2 +1]

    wire [15:0] p00x1, p10x2, p20x1;
    wire [15:0] p02x1, p12x2, p22x1;
    wire [15:0] p01x2, p21x2;

    // CHANGE THIS NAME TO YOUR DESIGN 
    // Change PBOM8_73Y to your multiplier module name
    // You need to change it in ALL 8 lines below
    PBOM8_73Y gx_n0(.A(p00), .B(8'd1), .P(p00x1));
    PBOM8_73Y gx_n1(.A(p10), .B(8'd2), .P(p10x2));
    PBOM8_73Y gx_n2(.A(p20), .B(8'd1), .P(p20x1));
    PBOM8_73Y gx_p0(.A(p02), .B(8'd1), .P(p02x1));
    PBOM8_73Y gx_p1(.A(p12), .B(8'd2), .P(p12x2));
    PBOM8_73Y gx_p2(.A(p22), .B(8'd1), .P(p22x1));
    PBOM8_73Y gy_m0(.A(p01), .B(8'd2), .P(p01x2));
    PBOM8_73Y gy_m1(.A(p21), .B(8'd2), .P(p21x2));
    

    // Gx computation
    wire [17:0] gx_pos = p02x1 + p12x2 + p22x1;
    wire [17:0] gx_neg = p00x1 + p10x2 + p20x1;
    wire [17:0] gx_abs = (gx_pos >= gx_neg) ?
                         (gx_pos - gx_neg) :
                         (gx_neg - gx_pos);

    // Gy computation
    wire [17:0] gy_pos = p20x1 + p21x2 + p22x1;
    wire [17:0] gy_neg = p00x1 + p01x2 + p02x1;
    wire [17:0] gy_abs = (gy_pos >= gy_neg) ?
                         (gy_pos - gy_neg) :
                         (gy_neg - gy_pos);

    // Gradient magnitude: |Gx| + |Gy|
    wire [18:0] gradient = gx_abs + gy_abs;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_out  <= 0;
            valid_out <= 0;
        end else begin
            valid_out <= valid_in;
            edge_out  <= (gradient > 19'd255) ? 
                          8'd255 : gradient[7:0];
        end
    end

endmodule