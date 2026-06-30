`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 03:08:35 PM
// Design Name: 
// Module Name: cd7_A8T
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


module cd7_A8T(A,B,P);

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
wire a_2_3,b_1_3,S3_1;
wire a_1_3,b_2_3,S3_2;
wire a_0_3,b_3_3;
CD_PPU COL3_P1(.ai(A[2]),.bi(b_1_2),.Sin(pp[3]),.Sout(S3_1),.Ai(a_2_3),.Bi(b_1_3));
CD_PPU COL3_P2(.ai(a_1_2),.bi(b_2_2),.Sin(S3_1),.Sout(S3_2),.Ai(a_1_3),.Bi(b_2_3));
CD_PPU COL3_P3(.ai(a_0_2),.bi(B[3]),.Sin(S3_2),.Sout(P[3]),.Ai(a_0_3),.Bi(b_3_3));

//column 4
wire a_3_4,b_1_4,S4_1;
wire a_2_4,b_2_4,S4_2;
wire a_1_4,b_3_4;
CD_PPU COL4_P1(.ai(A[3]),.bi(b_1_3),.Sin(pp[4]),.Sout(S4_1),.Ai(a_3_4),.Bi(b_1_4));
CD_PPU COL4_P2(.ai(a_2_3),.bi(b_2_3),.Sin(S4_1),.Sout(S4_2),.Ai(a_2_4),.Bi(b_2_4));
CD_PPU COL4_P3(.ai(a_1_3),.bi(b_3_3),.Sin(S4_2),.Sout(P[4]),.Ai(a_1_4),.Bi(b_3_4));

//column 5
wire a_4_5,b_1_5,S5_1;
wire a_3_5,b_2_5,S5_2;
wire a_2_5,b_3_5;
CD_PPU COL5_P1(.ai(A[4]),.bi(b_1_4),.Sin(pp[5]),.Sout(S5_1),.Ai(a_4_5),.Bi(b_1_5));
CD_PPU COL5_P2(.ai(a_3_4),.bi(b_2_4),.Sin(S5_1),.Sout(S5_2),.Ai(a_3_5),.Bi(b_2_5));
CD_PPU COL5_P3(.ai(a_2_4),.bi(b_3_4),.Sin(S5_2),.Sout(P[5]),.Ai(a_2_5),.Bi(b_3_5));

//column 6
wire a_5_6,b_1_6,S6_1;
wire a_4_6,b_2_6,S6_2;
wire a_3_6,b_3_6;
CD_PPU COL6_P1(.ai(A[5]),.bi(b_1_5),.Sin(pp[6]),.Sout(S6_1),.Ai(a_5_6),.Bi(b_1_6));
CD_PPU COL6_P2(.ai(a_4_5),.bi(b_2_5),.Sin(S6_1),.Sout(S6_2),.Ai(a_4_6),.Bi(b_2_6));
CD_PPU COL6_P3(.ai(a_3_5),.bi(b_3_5),.Sin(S6_2),.Sout(P[6]),.Ai(a_3_6),.Bi(b_3_6));

//column 7
wire a_6_7,b_1_7,a_5_7,b_2_7,S7_1,c7_r1;
wire c7_r2,a_4_7,b_3_7;
PPUF COL7_P1(.ai(A[6]),.bi(b_1_6),.aj(a_5_6),.bj(b_2_6),.Sin(pp[7]),.Ai(a_6_7),.Bi(b_1_7),.Aj(a_5_7),.Bj(b_2_7),.Sout(S7_1),.Cout(c7_r1));
PPUH COL7_P2(.ai(a_4_6),.bi(b_3_6),.Sin(S7_1),.Sout(P[7]),.Cout(c7_r2),.Ai(a_4_7),.Bi(b_3_7));

//column 8
wire a_7_8,b_1_8,S8_1;
wire a_6_8,b_2_8,S8_2,c8_r2;
wire a_5_8,b_3_8,c8_r3;
CD_PPU COL8_P1(.ai(A[7]),.bi(b_1_7),.Sin(1'b0),.Sout(S8_1),.Ai(a_7_8),.Bi(b_1_8));
PPU COL8_P2(.a(a_6_7),.b(b_2_7),.Cin(c7_r1),.Sin(S8_1),.A(a_6_8),.B(b_2_8),.Sout(S8_2),.Cout(c8_r2));
PPU COL8_P3(.a(a_5_7),.b(b_3_7),.Cin(c7_r2),.Sin(S8_2),.A(a_5_8),.B(b_3_8),.Sout(P[8]),.Cout(c8_r3));

//column 9
wire a_7_9,b_2_9,S9_1,c9_r1;
wire a_6_9,b_3_9,c9_r2;
PPU COL9_P1(.a(a_7_8),.b(b_2_8),.Cin(c8_r2),.Sin(1'b0),.A(a_7_9),.B(b_2_9),.Sout(S9_1),.Cout(c9_r1));
PPU COL9_P2(.a(a_6_8),.b(b_3_8),.Cin(c8_r3),.Sin(S9_1),.A(a_6_9),.B(b_3_9),.Sout(P[9]),.Cout(c9_r2));

//column 10
wire a_7_10,b_3_10;
PPU COL10_P1(.a(a_7_9),.b(b_3_9),.Cin(c9_r2),.Sin(c9_r1),.A(a_7_10),.B(b_3_10),.Sout(P[10]),.Cout(P[11]));

endmodule
