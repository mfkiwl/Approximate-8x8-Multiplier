`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2026 05:00:18 PM
// Design Name: 
// Module Name: A5_COMP
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


module A5_COMP(N1,N2,N3,N4,sum,carry);
input N1,N2,N3,N4;
output sum,carry;

wire p1,p2;

assign p1 = (N1^N2);
assign p2 = (N3|N4);

assign sum = p1^p2;

assign carry = (p1&p2)|(N1&N2);
endmodule
