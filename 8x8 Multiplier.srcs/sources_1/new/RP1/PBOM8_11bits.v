`timescale 1ns / 1ps
// Create Date: 04/07/2026 11:52:20 PM
// Design Name: 
// Module Name: PBOM8_8bits
// Project Name: 

module PBOM8_11bits(input [7:0] A,B, output [15:0]P);

wire [7:0] pp0,pp1,pp2,pp3,pp4,pp5,pp6,pp7;
assign pp0 = A & {8{B[0]}};
assign pp1 = A & {8{B[1]}};
assign pp2 = A & {8{B[2]}};
assign pp3 = A & {8{B[3]}};
assign pp4 = A & {8{B[4]}};
assign pp5 = A & {8{B[5]}};
assign pp6 = A & {8{B[6]}};
assign pp7 = A & {8{B[7]}};

assign P[0] = pp0[0];
assign P[1] = pp0[1]|pp1[0];
assign P[2] = pp0[2]|pp1[1]|pp2[0];
assign P[3] = pp0[3]|pp1[2]|pp2[1]|pp3[0];
assign P[4] = pp0[4]|pp1[3]|pp2[2]|pp3[1]|pp4[0];
assign P[5] = pp0[5]|pp1[4]|pp2[3]|pp3[2]|pp4[1]|pp5[0];
assign P[6] = pp0[6]|pp1[5]|pp2[4]|pp3[3]|pp4[2]|pp5[1]|pp6[0];
assign P[7] = pp0[7]|pp1[6]|pp2[5]|pp3[4]|pp4[3]|pp5[2]|pp6[1]|pp7[0];
assign P[8] = pp1[7]|pp2[6]|pp3[5]|pp4[4]|pp5[3]|pp6[2]|pp7[1];
assign P[9] = pp2[7]|pp3[6]|pp4[5]|pp5[4]|pp6[3]|pp7[2];
assign P[10]= pp3[7]|pp4[6]|pp5[5]|pp6[4]|pp7[3];
assign P[11]= pp4[7]|pp5[6]|pp6[5]|pp7[4];
//column 12
wire C12_1;
Full_Adder FA12(.a(pp5[7]),.b(pp6[6]),.Cin(pp7[5]),.Cout(C12_1),.sum(P[12]));
//column 13
wire C13_1;
Full_Adder FA13(.a(pp6[7]),.b(pp7[6]),.Cin(C12_1),.Cout(C13_1),.sum(P[13]));
//column 14 and 15
Full_Adder FA14(.a(pp7[7]),.b(0),.Cin(C13_1),.Cout(P[15]),.sum(P[14]));
endmodule
