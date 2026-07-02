`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 03:17:32 PM
// Design Name: 
// Module Name: CDM8_62T
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


module CDM8_62T(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [3:0] B_L,B_H;
assign B_L = B[3:0];
assign B_H = B[7:4];

wire [11:0] P1,P2;
cd6_A8T M1(.A(A),.B(B_L),.P(P1));
cd2_A8T M2(.A(A),.B(B_H),.P(P2));

assign P[3:0] = P1[3:0];
wire [11:0] P3;
assign P3 = {4'd0,P1[11:4]};
wire Co;
cla_12bit C1(.A(P2),.B(P3),.Cin(1'b0),.Sum(P[15:4]),.Cout(Co));
endmodule
