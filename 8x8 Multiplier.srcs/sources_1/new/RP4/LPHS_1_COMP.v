`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2026 01:05:52 PM
// Design Name: 
// Module Name: LPHS_1_COMP
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


module LPHS_1_COMP(X1,X2,X3,X4,sum,Cout,carry);
input X1,X2,X3,X4;
output sum,Cout,carry;

assign carry = X4;
assign sum = (~X4)&(X1|X2);
assign Cout = (X1 & X2) + X3&(X1|X2);
endmodule
