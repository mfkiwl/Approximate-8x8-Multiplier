`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2026 05:13:31 PM
// Design Name: 
// Module Name: A5_CAAM
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


module A5_CAAM(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [7:0] pp[7:0];

genvar i;

generate 
for(i=0;i<8;i=i+1) begin
 assign pp[i] = A & {8{B[i]}};
end
endgenerate

assign P[3:0] = 4'd0;

// Stage 1
//column 4
Half_Adder COL4_HA1();










endmodule
