`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 01:19:52 AM
// Design Name: 
// Module Name: approx_compressor_A5_6
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


module approx_compressor_A5_9(X1,X2,X3,X4,C,S);
input X1,X2,X3,X4;
output C,S;

wire w1,w2,w3;

assign w1 = (X1|X2);
assign w3 = X4;
assign w2 = (X3|(X1&X2));

Full_Adder FA1(.a(w1),.b(w2),.Cin(w3),.sum(S),.Cout(C));
endmodule
