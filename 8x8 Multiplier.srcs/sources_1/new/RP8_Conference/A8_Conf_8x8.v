`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 06:28:08 PM
// Design Name: 
// Module Name: A8_Conf_8x8
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


module A8_Conf_8x8(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [3:0] B_H,B_L;
assign B_H = B[7:4];
assign B_L = B[3:0];
wire [11:0] P_L,P_H;
A8_Conf_8x4_H A1(.A(A),.B(B_H),.P(P_H));
A8_Conf_8x4_L A2(.A(A),.B(B_L),.P(P_L));
wire [11:0] p1;
assign p1 = {4'b0000,P_L[11:4]}; 
assign P[3:0] = P_L[3:0];
wire Co;
cla_12bit C1(.A(P_H),.B(p1),.Cin(1'b0),.Sum(P[15:4]),.Cout(Co));

endmodule
