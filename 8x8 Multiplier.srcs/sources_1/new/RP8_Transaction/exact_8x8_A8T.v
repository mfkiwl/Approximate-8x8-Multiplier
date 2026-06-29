`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2026 08:50:41 PM
// Design Name: 
// Module Name: exact_8x8_A8T
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


module exact_8x8_A8T(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [3:0] B_L,B_H;

assign B_L = B[3:0];
assign B_H = B[7:4];

wire [11:0] P1,P2;

exact_8x4_A8T dut1(.A(A),.B(B_L),.P(P1));
exact_8x4_A8T dut2(.A(A),.B(B_H),.P(P2));

assign P[3:0] = P1[3:0];
wire Co;
cla_12bit A1(.A(P2),.B({4'd0,P1[11:4]}),.Cin(1'b0),.Sum(P[15:4]),.Cout(Co));

endmodule
