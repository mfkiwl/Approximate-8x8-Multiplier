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


module approx_compressor_A5_6(X1,X2,X3,X4,S,C);

input X1,X2,X3,X4;
output S,C;

wire w1,w2;
assign w1 = X1&X2;
assign w2 = X3&X4;

assign S = ((X1^X2)|(X3^X4)|(w1&w2));
assign C = w1|w2;
endmodule
