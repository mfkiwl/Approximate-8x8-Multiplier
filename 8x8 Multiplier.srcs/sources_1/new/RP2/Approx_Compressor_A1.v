`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2026 05:06:22 PM
// Design Name: 
// Module Name: Approx_Compressor_A1
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


module Approx_Compressor_A1(input X1,X2,X3,X4, output S,C);

assign S = (X1 ^ X2) ^ (X3 ^ X4);
assign C = (X1&X3)+(X1&X2)+(X2&X3)+(X2&X4);

endmodule
