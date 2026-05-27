`timescale 1ns / 1ps

// Create Date: 03/25/2026 11:51:56 PM
// Design Name: PBO_3 Approximate Multiplier Design 1 (8x4)
// Module Name: PBO_3

module PBO_3(input[7:0]A,
input [3:0] B,
output [11:0]P);

wire[7:0] pp0,pp1,pp2,pp3;
assign pp0 = A & {8{B[0]}};
assign pp1 = A & {8{B[1]}};
assign pp2 = A & {8{B[2]}};
assign pp3 = A & {8{B[3]}};

//column 0
assign P[0] = pp0[0];
//column 1
assign P[1] = pp0[1] | pp1[0] ;
//column 2
assign P[2] = pp0[2] | pp1[1] | pp2[0];
//column 3
assign P[3] = pp0[3] | pp1[2] | pp2[1] | pp3[0];
//column 4
wire C4_1,S4_1,C4_2;
Full_Adder FA1(.a(pp0[4]),.b(pp1[3]),.Cin(pp2[2]),.Cout(C4_1),.sum(S4_1));
Full_Adder FA2(.a(pp3[1]),.b(S4_1),.Cin(C4_1),.Cout(C4_2),.sum(P[4]));
//column 5
wire C5_1,C5_2,S5_1,S5_2,C5_3;
Full_Adder FA3(.a(pp0[5]),.b(pp1[4]),.Cin(pp2[3]),.sum(S5_1),.Cout(C5_1));
Full_Adder FA4(.a(C4_2),.b(pp3[2]),.Cin(C5_1),.sum(S5_2),.Cout(C5_2));
Full_Adder FA5(.a(S5_2),.b(S5_1),.Cin(C5_2),.sum(P[5]),.Cout(C5_3));
//column 6
wire S6_1,S6_2,C6_1,C6_3,C6_2;
Full_Adder FA6(.a(pp0[6]),.b(pp1[5]),.Cin(C5_3),.sum(S6_1),.Cout(C6_1));
Full_Adder FA7(.a(pp2[4]),.b(pp3[3]),.Cin(C6_1),.sum(S6_2),.Cout(C6_2));
Full_Adder FA8(.a(C6_2),.b(S6_2),.Cin(S6_1),.sum(P[6]),.Cout(C6_3));
//column 7
wire C7_1,C7_2,C7_3,S7_1,S7_2;
Full_Adder FA9(.a(pp0[7]),.b(pp1[6]),.Cin(C6_3),.sum(S7_1),.Cout(C7_1));
Full_Adder FA10(.a(pp2[5]),.b(pp3[4]),.Cin(C7_1),.sum(S7_2),.Cout(C7_2));
Full_Adder FA11(.a(S7_1),.b(S7_2),.Cin(C7_2),.sum(P[7]),.Cout(C7_3));
//column 8
wire S8_1, C8_1, C8_2;
Full_Adder FA12(.a(pp1[7]),.b(pp2[6]),.Cin(C7_3),.sum(S8_1),.Cout(C8_1));
Full_Adder FA13(.a(pp3[5]),.b(S8_1),.Cin(C8_1),.sum(P[8]),.Cout(C8_2));
//column 9
wire C9_1;
Full_Adder FA14(.a(pp2[7]),.b(pp3[6]),.Cin(C8_2),.sum(P[9]),.Cout(C9_1));
//column 10
Half_Adder HA1(.a(pp3[7]),.b(C9_1),.sum(P[10]),.carry(P[11]));
endmodule
