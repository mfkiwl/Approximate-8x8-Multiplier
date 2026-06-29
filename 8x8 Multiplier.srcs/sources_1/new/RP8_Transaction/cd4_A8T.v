`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 12:20:53 AM
// Design Name: 
// Module Name: cd4_A8T
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


module cd4_A8T(A,B,P);
input [7:0] A;
input [4:0] B;
output [11:0] P;

wire [7:0] pp;
genvar i;
generate
for(i=0;i<8;i=i+1)begin
assign pp[i] = A[i]&B[0];
end
endgenerate

//column 0
assign P[0] = pp[0];

//column 1
wire a_0_1,b_1_1;
CD_PPU COL1_P1(.ai(A[0]),.bi(B[1]),.Sin(pp[1]),.Sout(P[1]),.Ai(a_0_1),.Bi(b_1_1));

//column 2
wire a_1_2,b_1_2,S2_1;
wire a_0_2,b_2_2;
CD_PPU COL2_P1(.ai(A[1]),.bi(b_1_1),.Sin(pp[2]),.Sout(S2_1),.Ai(a_1_2),.Bi(b_1_2));
CD_PPU COL2_P2(.ai(a_0_1),.bi(B[2]),.Sin(S2_1),.Sout(P[2]),.Ai(a_0_2),.Bi(b_2_2));

//column 3


endmodule
