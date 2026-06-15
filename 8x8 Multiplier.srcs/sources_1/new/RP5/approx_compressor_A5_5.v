`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 11:47:46 PM
// Design Name: 
// Module Name: approx_compressor_A5_5
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


module approx_compressor_A5_5(X1,X2,X3,X4,S,C);

input X1,X2,X3,X4;
output S,C;

assign S = (X1 ^ X2) ^ (X3 ^ X4);
assign C = (X1&X3)+(X1&X2)+(X2&X3)+(X2&X4);

endmodule