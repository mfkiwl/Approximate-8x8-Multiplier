`timescale 1ns / 1ps
`include "compressor_1.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 04:15:31 AM
// Design Name: 
// Module Name: mul_1_8x4
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


module mul_2_8x4(input [7:0] A, [3:0]B,
output [11:0] P, [2:0]carry);

wire [7:0] pp0,pp1,pp2,pp3;

assign pp0 = A& {8{B[0]}};
assign pp1 = A& {8{B[1]}};
assign pp2 = A& {8{B[2]}};
assign pp3 = A& {8{B[3]}};

//Generating LSB
assign P[0] = pp0[0];
assign P[1] = pp0[1]|pp1[0];
assign P[2] = pp0[2]|pp1[1]|pp2[0];
//Generating MSB
assign P[3] = pp0[3]|pp1[2]|pp2[1]|pp3[0];
assign P[4] = pp0[4]|pp1[3]|pp2[2]|pp3[1];
assign P[5] = pp0[5]|pp1[4]|pp2[3]|pp3[2];
assign P[6] = pp0[6]|pp1[5]|pp2[4]|pp3[3];
compressor_2 CM1(.a(pp0[7]),.b(pp1[6]),.c(pp2[5]),.d(pp3[4]),.sum(P[7]),.carry(carry[0]));
Full_Adder FA1(.a(pp1[7]),.b(pp2[6]),.Cin(pp3[5]),.sum(P[8]),.Cout(carry[1]));
Full_Adder FA2(.a(pp2[7]),.b(pp3[6]),.Cin(0),.sum(P[9]),.Cout(carry[2]));
assign P[10] = pp3[7];
assign P[11] = 1'b0;
endmodule
