`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 11:44:35 AM
// Design Name: 
// Module Name: PBOM8_53N
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


module PBOM8_53N(input [7:0] A,B,
 output [15:0] P);
 
wire [11:0] P1,P2;


PBO_3 Multiplier1(.A(A),.B(B[7:4]),.P(P1));
PBO_5 Multiplier2(.A(A),.B(B[3:0]),.P(P2));

wire [15:0] P1_extend;
assign P1_extend = {P1,4'b0000};

assign P[3:0] = P2[3:0];
assign P[11:4] = P2[11:4] | P1_extend[11:4];
assign P[15:12] = P1_extend[15:12];


endmodule
