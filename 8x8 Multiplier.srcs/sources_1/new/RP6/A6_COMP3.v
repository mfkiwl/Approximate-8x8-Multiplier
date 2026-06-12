`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2026 12:48:41 PM
// Design Name: 
// Module Name: A6_COMP3
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


module A6_COMP3(X1,X2,X3,X4,C,S);

input X1,X2,X3,X4;
output C,S;
wire w1,w2,w3;
assign w1 = (X1|X2);
assign w2 = (X3|(X1&X2));
assign w3 = (X4|(X3&X1&X2));

Full_Adder FA2(.a(w1),.b(w2),.Cin(w3),.sum(S),.Cout(C));

endmodule
