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


module approx_compressor_A5_7(X1,X2,X3,X4,C,S);
input X1,X2,X3,X4;
output C,S;

wire nand12, nand34;
wire xnor12, xnor34;

assign nand12 = ~(X1 & X2);
assign nand34 = ~(X3 & X4);


assign C = ~(nand12 & nand34);


assign xnor12 = ~(X1 ^ X2);   // X1 XNOR X2
assign xnor34 = ~(X3 ^ X4);   // X3 XNOR X4


assign S = xnor12 & xnor34 & nand12 & nand34;

endmodule

