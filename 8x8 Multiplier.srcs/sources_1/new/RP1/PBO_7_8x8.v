`timescale 1ns / 1ps
`include "PBO_7.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2026 11:12:32 PM
// Design Name: 
// Module Name: PBO_7_8x8
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


module PBO_7_8x8(input [7:0]A,B, output[15:0]P);
wire [3:0] B_H, B_L;
assign B_H = B[7:4];
assign B_L = B[3:0];

wire [11:0] P1,P2;
PBO_7 Pb1(.A(A),.B(B_L),.P(P1));
multiplier_8x4 Pb2(.A(A),.B(B_H),.P(P2));

assign P = P1 + (P2<<4);
endmodule

