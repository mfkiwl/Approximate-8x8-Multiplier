`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2026 02:06:12 AM
// Design Name: 
// Module Name: A3_comp
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


module A3_comp(A1,A2,A3,A4,sum,carry);
input A1,A2,A3,A4;
output sum,carry;

assign carry = (A1|A2);

mux_2x1 M1(.s(A1^A2),.a(A3|A4),.b(A3&A4),.y(sum));
endmodule
