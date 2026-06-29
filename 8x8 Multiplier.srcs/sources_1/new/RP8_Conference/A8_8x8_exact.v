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
wire a_0_1,b_1_1,c1_r1; //c1_r1 means carry of column 1 and row1
PPU P1(.a(A[0]),.b(B[1]),.Cin(1'b0),.Sin(pp[1]),.A(a_0_1),.B(b_1_1),.Sout(P[1]),.Cout(c1_r1));

//column 2
wire a_1_2,b_1_2,S2_1,c2_r1,c2_r2,a_0_2,b_2_2;
PPU P2_1(.a(A[1]),.b(b_1_1),.Cin(c1_r1),.Sin(pp[2]),.A(a_1_2),.B(b_1_2),.Sout(S2_1),.Cout(c2_r1));
PPU P2_2(.a(a_0_1),.b(B[2]),.Cin(1'b0),.Sin(S2_1),.A(a_0_2),.B(b_2_2),.Sout(P[2]),.Cout(c2_r2));

//column 3
wire a_2_3,b_1_3,S3_1,c3_r1,a_1_3,b_2_3,S3_2,c3_r2,a_0_3,b_3_3,c3_r3;
PPU P3_1(.a(A[2]),.b(b_1_2),.Cin(c2_r1),.Sin(pp[3]),.A(a_2_3),.B(b_1_3),.Sout(S3_1),.Cout(c3_r1));
PPU P3_2(.a(a_1_2),.b(b_2_2),.Cin(c2_r2),.Sin(S3_1),.A(a_1_3),.B(b_2_3),.Sout(S3_2),.Cout(c3_r2));
PPU P3_3(.a(a_0_2),.b(B[3]),.Cin(1'b0),.Sin(S3_2),.A(a_0_3),.B(b_3_3),.Sout(P[3]),.Cout(c3_r3));

//column 4
wire a_3_4,b_1_4,S4_1,c4_r1,a_2_4,b_2_4,S4_2,c4_r2,a_1_4,b_3_4,S4_3,c4_r3,a_0_4,b_4_4,c4_r4;
PPU P4_1(.a(A[3]),.b(b_1_3),.Cin(c3_r1),.Sin(pp[4]),.A(a_3_4),.B(b_1_4),.Sout(S4_1),.Cout(c4_r1));
PPU P4_2(.a(a_2_3),.b(b_2_3),.Cin(c3_r2),.Sin(S4_1),.A(a_2_4),.B(b_2_4),.Sout(S4_2),.Cout(c4_r2));
PPU P4_3(.a(a_1_3),.b(b_3_3),.Cin(c3_r3),.Sin(S4_2),.A(a_1_4),.B(b_3_4),.Sout(S4_3),.Cout(c4_r3));
PPU P4_4(.a(a_0_3),.b(B[4]),.Cin(1'b0),.Sin(S4_3),.A(a_0_4),.B(b_4_4),.Sout(P[4]),.Cout(c4_r4));

//column 5
wire a_4_5,b_1_5,S5_1,c5_r1,a_3_5,b_2_5,S5_2,c5_r2,a_2_5,b_3_5,S5_3,c5_r3,a_1_5,b_4_5,S5_4,c5_r4;
wire a_0_5,b_5_5,c5_r5;
PPU P5_1(.a(A[4]),.b(b_1_4),.Cin(c4_r1),.Sin(pp[5]),.A(a_4_5),.B(b_1_5),.Sout(S5_1),.Cout(c5_r1));
PPU P5_2(.a(a_3_4),.b(b_2_4),.Cin(c4_r2),.Sin(S5_1),.A(a_3_5),.B(b_2_5),.Sout(S5_2),.Cout(c5_r2));
PPU P5_3(.a(a_2_4),.b(b_3_4),.Cin(c4_r3),.Sin(S5_2),.A(a_2_5),.B(b_3_5),.Sout(S5_3),.Cout(c5_r3));
PPU P5_4(.a(a_1_4),.b(b_4_4),.Cin(c4_r4),.Sin(S5_3),.A(a_1_5),.B(b_4_5),.Sout(S5_4),.Cout(c5_r4));
PPU P5_5(.a(a_0_4),.b(B[5]),.Cin(1'b0),.Sin(S5_4),.A(a_0_5),.B(b_5_5),.Sout(P[5]),.Cout(c5_r5));

//column 6
wire a_5_6,b_1_6,S6_1,c6_r1;
wire a_4_6,b_2_6,S6_2,c6_r2;
wire a_3_6,b_3_6,S6_3,c6_r3;
wire a_2_6,b_4_6,S6_4,c6_r4;
wire a_1_6,b_5_6,S6_5,c6_r5;
wire a_0_6,b_6_6,c6_r6;
PPU P6_1(.a(A[5]),.b(b_1_5),.Cin(c5_r1),.Sin(pp[6]),.A(a_5_6),.B(b_1_6),.Sout(S6_1),.Cout(c6_r1));
PPU P6_2(.a(a_4_5),.b(b_2_5),.Cin(c5_r2),.Sin(S6_1),.A(a_4_6),.B(b_2_6),.Sout(S6_2),.Cout(c6_r2));
PPU P6_3(.a(a_3_5),.b(b_3_5),.Cin(c5_r3),.Sin(S6_2),.A(a_3_6),.B(b_3_6),.Sout(S6_3),.Cout(c6_r3));
PPU P6_4(.a(a_2_5),.b(b_4_5),.Cin(c5_r4),.Sin(S6_3),.A(a_2_6),.B(b_4_6),.Sout(S6_4),.Cout(c6_r4));
PPU P6_5(.a(a_1_5),.b(b_5_5),.Cin(c5_r5),.Sin(S6_4),.A(a_1_6),.B(b_5_6),.Sout(S6_5),.Cout(c6_r5));
PPU P6_6(.a(a_0_5),.b(B[6]),.Cin(1'b0),.Sin(S6_5),.A(a_0_6),.B(b_6_6),.Sout(P[6]),.Cout(c6_r6));

//column 7
wire a_6_7,b_1_7,S7_1,c7_r1;
wire a_5_7,b_2_7,S7_2,c7_r2;
wire a_4_7,b_3_7,S7_3,c7_r3;
wire a_3_7,b_4_7,S7_4,c7_r4;
wire a_2_7,b_5_7,S7_5,c7_r5;
wire a_1_7,b_6_7,S7_6,c7_r6;
wire a_0_7,b_7_7,c7_r7;
PPU P7_1(.a(A[6]),.b(b_1_6),.Cin(c6_r1),.Sin(pp[7]),.A(a_6_7),.B(b_1_7),.Sout(S7_1),.Cout(c7_r1));
PPU P7_2(.a(a_5_6),.b(b_2_6),.Cin(c6_r2),.Sin(S7_1),.A(a_5_7),.B(b_2_7),.Sout(S7_2),.Cout(c7_r2));
PPU P7_3(.a(a_4_6),.b(b_3_6),.Cin(c6_r3),.Sin(S7_2),.A(a_4_7),.B(b_3_7),.Sout(S7_3),.Cout(c7_r3));
PPU P7_4(.a(a_3_6),.b(b_4_6),.Cin(c6_r4),.Sin(S7_3),.A(a_3_7),.B(b_4_7),.Sout(S7_4),.Cout(c7_r4));
PPU P7_5(.a(a_2_6),.b(b_5_6),.Cin(c6_r5),.Sin(S7_4),.A(a_2_7),.B(b_5_7),.Sout(S7_5),.Cout(c7_r5));
PPU P7_6(.a(a_1_6),.b(b_6_6),.Cin(c6_r6),.Sin(S7_5),.A(a_1_7),.B(b_6_7),.Sout(S7_6),.Cout(c7_r6));
PPU P7_7(.a(a_0_6),.b(B[7]),.Cin(1'b0),.Sin(S7_6),.A(a_0_7),.B(b_7_7),.Sout(P[7]),.Cout(c7_r7));


//column 8
wire a_7_8,b_1_8,S8_1,c8_r1;
wire a_6_8,b_2_8,S8_2,c8_r2;
wire a_5_8,b_3_8,S8_3,c8_r3;
wire a_4_8,b_4_8,S8_4,c8_r4;
wire a_3_8,b_5_8,S8_5,c8_r5;
wire a_2_8,b_6_8,S8_6,c8_r6;
wire a_1_8,b_7_8,c8_r7;
PPU P8_1(.a(A[7]),.b(b_1_7),.Cin(c7_r1),.Sin(1'b0),.A(a_7_8),.B(b_1_8),.Sout(S8_1),.Cout(c8_r1));
PPU P8_2(.a(a_6_7),.b(b_2_7),.Cin(c7_r2),.Sin(S8_1),.A(a_6_8),.B(b_2_8),.Sout(S8_2),.Cout(c8_r2));
PPU P8_3(.a(a_5_7),.b(b_3_7),.Cin(c7_r3),.Sin(S8_2),.A(a_5_8),.B(b_3_8),.Sout(S8_3),.Cout(c8_r3));
PPU P8_4(.a(a_4_7),.b(b_4_7),.Cin(c7_r4),.Sin(S8_3),.A(a_4_8),.B(b_4_8),.Sout(S8_4),.Cout(c8_r4));
PPU P8_5(.a(a_3_7),.b(b_5_7),.Cin(c7_r5),.Sin(S8_4),.A(a_3_8),.B(b_5_8),.Sout(S8_5),.Cout(c8_r5));
PPU P8_6(.a(a_2_7),.b(b_6_7),.Cin(c7_r6),.Sin(S8_5),.A(a_2_8),.B(b_6_8),.Sout(S8_6),.Cout(c8_r6));
PPU P8_7(.a(a_1_7),.b(b_7_7),.Cin(c7_r7),.Sin(S8_6),.A(a_1_8),.B(b_7_8),.Sout(P[8]),.Cout(c8_r7));

//column 9
wire a_7_9,b_2_9,S9_1,c9_r1;
wire a_6_9,b_3_9,S9_2,c9_r2;
wire a_5_9,b_4_9,S9_3,c9_r3;
wire a_4_9,b_5_9,S9_4,c9_r4;
wire a_3_9,b_6_9,S9_5,c9_r5;
wire a_2_9,b_7_9,c9_r6;
PPU P9_1(.a(a_7_8),.b(b_2_8),.Cin(c8_r2),.Sin(c8_r1),.A(a_7_9),.B(b_2_9),.Sout(S9_1),.Cout(c9_r1));
PPU P9_2(.a(a_6_8),.b(b_3_8),.Cin(c8_r3),.Sin(S9_1),.A(a_6_9),.B(b_3_9),.Sout(S9_2),.Cout(c9_r2));
PPU P9_3(.a(a_5_8),.b(b_4_8),.Cin(c8_r4),.Sin(S9_2),.A(a_5_9),.B(b_4_9),.Sout(S9_3),.Cout(c9_r3));
PPU P9_4(.a(a_4_8),.b(b_5_8),.Cin(c8_r5),.Sin(S9_3),.A(a_4_9),.B(b_5_9),.Sout(S9_4),.Cout(c9_r4));
PPU P9_5(.a(a_3_8),.b(b_6_8),.Cin(c8_r6),.Sin(S9_4),.A(a_3_9),.B(b_6_9),.Sout(S9_5),.Cout(c9_r5));
PPU P9_6(.a(a_2_8),.b(b_7_8),.Cin(c8_r7),.Sin(S9_5),.A(a_2_9),.B(b_7_9),.Sout(P[9]),.Cout(c9_r6));

//column 10
wire a_7_10,b_3_10,S10_1,c10_r1;
wire a_6_10,b_4_10,S10_2,c10_r2;
wire a_5_10,b_5_10,S10_3,c10_r3;
wire a_4_10,b_6_10,S10_4,c10_r4;
wire a_3_10,b_7_10,S10_5,c10_r5;
PPU P10_1(.a(a_7_9),.b(b_3_9),.Cin(c9_r2),.Sin(c9_r1),.A(a_7_10),.B(b_3_10),.Sout(S10_1),.Cout(c10_r1));
PPU P10_2(.a(a_6_9),.b(b_4_9),.Cin(c9_r3),.Sin(S10_1),.A(a_6_10),.B(b_4_10),.Sout(S10_2),.Cout(c10_r2));
PPU P10_3(.a(a_5_9),.b(b_5_9),.Cin(c9_r4),.Sin(S10_2),.A(a_5_10),.B(b_5_10),.Sout(S10_3),.Cout(c10_r3));
PPU P10_4(.a(a_4_9),.b(b_6_9),.Cin(c9_r5),.Sin(S10_3),.A(a_4_10),.B(b_6_10),.Sout(S10_4),.Cout(c10_r4));
PPU P10_5(.a(a_3_9),.b(b_7_9),.Cin(c9_r6),.Sin(S10_4),.A(a_3_10),.B(b_7_10),.Sout(P[10]),.Cout(c10_r5));

//column 11
wire a_7_11,b_4_11,S11_1,c11_r1;
wire a_6_11,b_5_11,S11_2,c11_r2;
wire a_5_11,b_6_11,S11_3,c11_r3;
wire a_5_11,b_7_11,c11_r4;
PPU P11_1(.a(a_7_10),.b(b_4_10),.Cin(c10_r2),.Sin(c10_r1),.A(a_7_11),.B(b_4_11),.Sout(S11_1),.Cout(c11_r1));
PPU P11_2(.a(a_6_10),.b(b_5_10),.Cin(c10_r3),.Sin(S11_1),.A(a_6_11),.B(b_5_11),.Sout(S11_2),.Cout(c11_r2));
PPU P11_3(.a(a_5_10),.b(b_6_10),.Cin(c10_r4),.Sin(S11_2),.A(a_5_11),.B(b_6_11),.Sout(S11_3),.Cout(c11_r3));
PPU P11_4(.a(a_4_10),.b(b_7_10),.Cin(c10_r5),.Sin(S11_3),.A(a_4_11),.B(b_7_11),.Sout(P[11]),.Cout(c11_r4));

//column 12
wire a_7_12,b_5_12,S12_1,c12_r1;
wire a_6_12,b_6_12,S12_2,c12_r2;
wire a_5_12,b_7_12,c12_r3;
PPU P12_5(.a(a_7_11),.b(b_5_11),.Cin(c11_r2),.Sin(c11_r1),.A(a_7_12),.B(b_5_12),.Sout(S12_1),.Cout(c12_r1));
PPU P12_2(.a(a_6_11),.b(b_6_11),.Cin(c11_r3),.Sin(S12_1),.A(a_6_12),.B(b_6_12),.Sout(S12_2),.Cout(c12_r2));
PPU P12_3(.a(a_5_11),.b(b_7_11),.Cin(c11_r4),.Sin(S12_2),.A(a_5_12),.B(b_7_12),.Sout(P[12]),.Cout(c12_r3));

//column 13
wire a_7_13,b_6_13,c13_r1,S13_1;
wire a_6_13,b_7_13,c13_r2;
PPU P13_1(.a(a_7_12),.b(b_6_12),.Cin(c12_r2),.Sin(c12_r1),.A(a_7_13),.B(b_6_13),.Sout(S13_1),.Cout(c13_r1));
PPU P13_2(.a(a_6_12),.b(b_7_12),.Cin(c12_r3),.Sin(S13_1),.A(a_6_13),.B(b_7_13),.Sout(P[13]),.Cout(c13_r2));

//column 14
wire a_7_14,b_7_14;
PPU P14_1(.a(a_7_13),.b(b_7_13),.Cin(c13_r2),.Sin(c13_r1),.A(a_7_14),.B(b_7_14),.Sout(P[14]),.Cout(P[15]));

endmodule
