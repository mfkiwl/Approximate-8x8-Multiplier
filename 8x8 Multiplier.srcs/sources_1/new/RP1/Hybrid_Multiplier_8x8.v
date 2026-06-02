`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 08:35:27 PM
// Design Name: 
// Module Name: Hybrid_Multiplier_8x8
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


module Hybrid_Multiplier_8x8(input [7:0]A,B,
output [15:0] P);

wire[3:0] B_L,B_H;
assign B_L = B[3:0];
assign B_H = B[7:4];

wire[11:0] P1,P2;
wire[6:0] C1;
wire[2:0] C2;
mul_1_8x4 M1(.A(A),.B(B_H),.P(P1),.carry(C1));
mul_2_8x4 M2(.A(A),.B(B_L),.P(P2),.carry(C2));

//stage 2
assign P[0] = P2[0];
assign P[1] = P2[1];
assign P[2] = P2[2];
assign P[3] = P2[3];
assign P[4] = P2[4]|P1[0];
assign P[5] = P2[5]|P1[1];
assign P[6] = P2[6]|P1[2];
assign P[7] = P2[7]|P1[3];

wire CC4,CC5,CC6,CC7,CC8,CC9,CC10,PP5,PP6,PP7,PP8,PP9,PP10,PP11;
compressor_1 COMP1(.a(P2[8]),.b(P1[4]),.c(C2[0]),.d(C1[0]),.sum(P[8]),.carry(CC4));
compressor_1 COMP2(.a(P2[9]),.b(P1[5]),.c(C2[1]),.d(C1[1]),.sum(PP5),.carry(CC5));
compressor_1 COMP3(.a(P2[10]),.b(P1[6]),.c(C2[2]),.d(C1[2]),.sum(PP6),.carry(CC6));

Full_Adder FA1(.a(P2[11]),.b(P1[7]),.Cin(C1[3]),.sum(PP7),.Cout(CC7));
Half_Adder HA2(.a(P1[8]),  .b(C1[4]), .sum(PP8),  .carry(CC8));
Half_Adder HA3(.a(P1[9]),  .b(C1[5]), .sum(PP9),  .carry(CC9));
Half_Adder HA4(.a(P1[10]), .b(C1[6]), .sum(PP10), .carry(CC10));
assign PP11 = P1[11];

//stage 3
wire CO1, CO2, CO3, CO4, CO5, CO6;
wire CO7;
Half_Adder HA1(.a(PP5),.b(CC4),.sum(P[9]),.carry(CO1));
Full_Adder FAA1(.a(PP6),.b(CC5),.Cin(CO1),.Cout(CO2),.sum(P[10]));
Full_Adder FAA2(.a(PP7),.b(CC6),.Cin(CO2),.Cout(CO3),.sum(P[11]));
Full_Adder FAA3(.a(PP8),.b(CC7),.Cin(CO3),.Cout(CO4),.sum(P[12]));
Full_Adder FAA4(.a(PP9),.b(CC8),.Cin(CO4),.Cout(CO5),.sum(P[13]));
Full_Adder FAA5(.a(PP10),.b(CC9),.Cin(CO5),.Cout(CO6),.sum(P[14]));
Full_Adder FAA6(.a(PP11),.b(CC10),.Cin(CO6),.Cout(CO7),.sum(P[15]));
endmodule
