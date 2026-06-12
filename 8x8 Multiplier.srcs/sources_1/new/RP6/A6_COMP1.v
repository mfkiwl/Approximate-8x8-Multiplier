`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2026 12:46:14 PM
// Design Name: 
// Module Name: A6_COMP1
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


module A6_COMP1(X1,X2,X3,X4,C,S);

input X1,X2,X3,X4;
output C,S;

wire w1;
assign w1 = (X2|X1);

Full_Adder FA(.a(w1),.b(X3),.Cin(X4),.sum(S),.Cout(C));

endmodule
