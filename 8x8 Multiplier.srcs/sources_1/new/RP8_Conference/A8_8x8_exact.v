`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2026 12:52:27 AM
// Design Name: 
// Module Name: A8_8x8_exact
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


module A8_8x8_exact(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [0:7] pp;
genvar i;

generate 
for(i=0;i<8;i=i+1)begin
assign pp[i] = A[i] & B[0];
end
endgenerate

//column 0
assign P[0] = pp[0];

//column 1
wire a_0,b_1,c1_r1; //c1_r1 means carry of column 1 and row1
PPU P1(.a(A[0]),.b(B[1]),.Cin(1'b0),.Sin(pp[1]),.A(a_0),.B(b_1),.Sout(P[1]),.Cout(c1_r1));

//column 2







endmodule
