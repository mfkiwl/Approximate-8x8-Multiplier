`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 03:44:54 PM
// Design Name: 
// Module Name: LPHS_2_COMP
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


module LPHS_2_COMP(X1,X2,X3,X4,sum,carry);
input X1,X2,X3,X4;
output sum,carry;

assign carry = X4;
assign sum = (~X4)&(X1|X2);
endmodule
