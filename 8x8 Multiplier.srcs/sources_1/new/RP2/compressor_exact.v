`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2026 01:04:35 PM
// Design Name: 
// Module Name: compressor_exact
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


module compressor_exact(input X1,X2,X3,X4,Cin, 
   output S,C,Cout);

  
wire xor1, xor2, xor3;
wire sum1;
assign sum1 = xor1 ^ X3;   // intermediate sum of FA1
// XOR stages
assign xor1 = X1 ^ X2;
assign xor2 = X3 ^ X4;
assign xor3 = xor1 ^ xor2;

// SUM output
assign S    = sum1 ^ X4 ^ Cin;

// Carry to next column (same stage)
assign Cout = (X1 & X2) | (X3 & xor1);

// Carry to next stage (diagonal)
// intermediate sum from FA1 = X1^X2^X3 (NOT xor3)
assign C    = (sum1 & X4) | (sum1 & Cin) | (X4 & Cin);  // correct FA2 carry
endmodule
