`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 03:55:30 AM
// Design Name: 
// Module Name: compressor_2
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


module compressor_2(input a,b,c,d,
output sum,carry);

assign sum = a|b|c|d;
assign carry = (a&b&c)|(a&c&d)|(b&c&d);
endmodule
