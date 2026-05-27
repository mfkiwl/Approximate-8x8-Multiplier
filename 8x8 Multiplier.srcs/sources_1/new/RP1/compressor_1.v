`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 03:36:06 AM
// Design Name: 
// Module Name: compressor_1
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


module compressor_1(input a,b,c,d,
output sum, carry);

assign sum = a^b^c^d;
assign carry = (a&b)|(a&c)|(a&d)|(b&c)|(b&d)|(c&d);
endmodule
