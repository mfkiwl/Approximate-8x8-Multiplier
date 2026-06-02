`timescale 1ns / 1ps

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


module mul_1_8x4(input [7:0] A, [3:0]B,
output [11:0] P, [6:0]carry);

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
compressor_1 CM1(.a(pp0[3]),.b(pp1[2]),.c(pp2[1]),.d(pp3[0]),.sum(P[3]),.carry(carry[0]));
compressor_1 CM2(.a(pp0[4]),.b(pp1[3]),.c(pp2[2]),.d(pp3[1]),.sum(P[4]),.carry(carry[1]));
compressor_1 CM3(.a(pp0[5]),.b(pp1[4]),.c(pp2[3]),.d(pp3[2]),.sum(P[5]),.carry(carry[2]));
compressor_1 CM4(.a(pp0[6]),.b(pp1[5]),.c(pp2[4]),.d(pp3[3]),.sum(P[6]),.carry(carry[3]));
compressor_1 CM5(.a(pp0[7]),.b(pp1[6]),.c(pp2[5]),.d(pp3[4]),.sum(P[7]),.carry(carry[4]));
Full_Adder FA1(.a(pp1[7]),.b(pp2[6]),.Cin(pp3[5]),.sum(P[8]),.Cout(carry[5]));
Full_Adder FA2(.a(pp2[7]),.b(pp3[6]),.Cin(0),.sum(P[9]),.Cout(carry[6]));
assign P[10] = pp3[7];
assign P[11] = 1'b0;
endmodule
