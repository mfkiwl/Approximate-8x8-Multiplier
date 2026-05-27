`timescale 1ns / 1ps
`include "multiplier_8x4.v"

// Create Date: 03/19/2026 02:29:17 PM
// Design Name: Exact Multiplier 8x8
// Module Name: multiplier_8x8

module multiplier_8x8(input [7:0] A,B, output [15:0] P);
wire [3:0] B_H,B_L;
assign B_H = B[7:4];
assign B_L = B[3:0];

wire[11:0] P1,P2;
multiplier_8x4 MA1(.A(A),.B(B_H),.P(P1));
multiplier_8x4 MA2(.A(A),.B(B_L),.P(P2));

assign P = P2 + (P1<<4) ;
endmodule
