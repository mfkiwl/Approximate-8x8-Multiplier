`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 11:33:32 PM
// Design Name: 
// Module Name: A5_8x8
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


module A5_8x8(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [7:0] pp[7:0];

genvar i;

generate 
for(i=0;i<8;i=i+1)begin
assign pp[i] = A & {8{B[i]}};
end
endgenerate

assign P[3:0] = 4'd0;

// Stage 1
//column 4
wire s4,c4_to_5;
Half_Adder COL4_HA1(.a(pp[0][4]),.b(pp[1][3]),.sum(s4),.carry(c4_to_5));

//column 5
wire s5,c5_to_6;
approx_compressor_A5_5 COL5_COMP1(.X1(pp[0][5]),.X2(pp[1][4]),.X3(pp[2][3]),.X4(pp[3][2]),.S(s5),.C(c5_to_6));

//column 6
wire s6_comp,s6_ha,c6_to_7_comp,c6_to_7_ha;
approx_compressor_A5_5 COL6_COMP1(.X1(pp[0][6]),.X2(pp[1][5]),.X3(pp[2][4]),.X4(pp[3][3]),.S(s6_comp),.C(c6_to_7_comp));
Half_Adder COL6_HA1(.a(pp[4][2]),.b(pp[5][1]),.sum(s6_ha),.carry(c6_to_7_ha));

//column 7
wire s7_comp1,s7_comp2,c7_to_8_comp1,c7_to_8_comp2;
A5_COMP COL7_COMP1(.N1(pp[0][7]),.N2(pp[1][6]),.N3(pp[2][5]),.N4(pp[3][4]),.sum(s7_comp1),.carry(c7_to_8_comp1));
A5_COMP COL7_COMP2(.N1(pp[4][3]),.N2(pp[5][2]),.N3(pp[6][1]),.N4(pp[7][0]),.sum(s7_comp2),.carry(c7_to_8_comp2));

// Coorection logic Stage 1
wire c1,c2;
assign c1 = (pp[2][5])&(pp[3][4]);
assign c2 = (pp[6][1])&(pp[7][0]);

//column 8
wire s8_comp1,s8_comp2,c8_to_9_comp1,c8_to_c9_comp1,c8_to_9_comp2,c8_to_c9_comp2;
compressor_exact COL8_COMP1(.X1(pp[1][7]),.X2(pp[2][6]),.X3(pp[3][5]),.X4(pp[4][4]),.Cin(c1),.S(s8_comp1),.C(c8_to_9_comp1),.Cout(c8_to_c9_comp1));
compressor_exact COL8_COMP2(.X1(pp[5][3]),.X2(pp[6][2]),.X3(pp[7][1]),.X4(1'b0),.Cin(c2),.S(s8_comp2),.C(c8_to_9_comp2),.Cout(c8_to_c9_comp2));

//column 9
wire s9_comp,c9_to_10_comp,c9_to_c10_comp,s9_fa,c9_to_10_fa;
compressor_exact COL9_COMP1(.X1(pp[2][7]),.X2(pp[3][6]),.X3(pp[4][5]),.X4(pp[5][4]),.Cin(c8_to_c9_comp1),.S(s9_comp),.C(c9_to_10_comp),.Cout(c9_to_c10_comp));
Full_Adder COL9_FA1(.a(pp[6][3]),.b(pp[7][2]),.Cin(c8_to_c9_comp2),.sum(s9_fa),.Cout(c9_to_10_fa));

//column 10
wire s10,c10_to_11,c10_to_c11;
compressor_exact COL10_COMP1(.X1(pp[3][7]),.X2(pp[4][6]),.X3(pp[5][5]),.X4(pp[6][4]),.Cin(c9_to_c10_comp),.S(s10),.C(c10_to_11),.Cout(c10_to_c11));

//column 11
wire s11,c11_to_12;
Full_Adder COL11_FA1(.a(pp[4][7]),.b(pp[5][6]),.Cin(c10_to_c11),.sum(s11),.Cout(c11_to_12));

// Stage 2
//column 4
wire s4_,c4_to_5_;
approx_compressor_A5_5 COL4_COMP2(.X1(s4),.X2(pp[2][2]),.X3(pp[3][1]),.X4(pp[4][0]),.S(s4_),.C(c4_to_5_));

//column 5
wire s5_,c5_to_6_;
approx_compressor_A5_5 COL5_COMP2(.X1(s5),.X2(pp[4][1]),.X3(pp[5][0]),.X4(c4_to_5),.S(s5_),.C(c5_to_6_));

//column 6
wire s6_,c6_to_7_;
approx_compressor_A5_5 COL6_COMP2(.X1(s6_comp),.X2(s6_ha),.X3(c5_to_6),.X4(pp[6][0]),.S(s6_),.C(c6_to_7_));

//column 7
wire s7_,c7_to_8_;
A5_COMP COL7_COMP_2(.N1(s7_comp1),.N2(s7_comp2),.N3(c6_to_7_comp),.N4(c6_to_7_ha),.sum(s7_),.carry(c7_to_8_));

//Correction logic Stage 2
wire c3;
assign c3 = (c6_to_7_comp)&(c6_to_7_ha);

//column 8
wire s8_,c8_to_9_,c8_to_c9_;
compressor_exact COL8_COMP_2(.X1(s8_comp1),.X2(s8_comp2),.X3(c7_to_8_comp1),.X4(c7_to_8_comp2),.Cin(c3),.S(s8_),.C(c8_to_9_),.Cout(c8_to_c9_));

//column 9
wire s9_,c9_to_10_,c9_to_c10_;
compressor_exact COL9_COMP2(.X1(s9_comp),.X2(s9_fa),.X3(c8_to_9_comp1),.X4(c8_to_9_comp2),.Cin(c8_to_c9_),.S(s9_),.C(c9_to_10_),.Cout(c9_to_c10_));

//column 10
wire s10_,c10_to_11_,c10_to_c11_;
compressor_exact COL10_COMP2(.X1(s10),.X2(c9_to_10_fa),.X3(c9_to_10_comp),.X4(pp[7][3]),.Cin(c9_to_c10_),.S(s10_),.C(c10_to_11_),.Cout(c10_to_c11_));

//column 11
wire s11_,c11_to_12_,c11_to_c12_;
compressor_exact COL11_COMP2(.X1(s11),.X2(c10_to_11),.X3(pp[6][5]),.X4(pp[7][4]),.Cin(c10_to_c11_),.S(s11_),.C(c11_to_12_),.Cout(c11_to_c12_));

//column 12
wire s12_,c12_to_13_,c12_to_c13_;
compressor_exact COL12_COMP2(.X1(pp[5][7]),.X2(pp[6][6]),.X3(pp[7][5]),.X4(c11_to_12),.Cin(c11_to_c12_),.S(s12_),.C(c12_to_13_),.Cout(c12_to_c13_));

//column 13
wire s13_,c13_to_14_;
Full_Adder COL13_FA2(.a(pp[6][7]),.b(pp[7][6]),.Cin(c12_to_c13_),.sum(s13_),.Cout(c13_to_14_));

// Stage 3

wire [9:0] a,b;
assign a = {pp[7][7],s13_,s12_,s11_,s10_,s9_,s8_,s7_,s6_,s5_};
assign b = {c13_to_14_,c12_to_13_,c11_to_12_,c10_to_11_,c9_to_10_,c8_to_9_,c7_to_8_,c6_to_7_,c5_to_6_,c4_to_5_};

wire [10:0]s;
RCA_10bit Adder(.a(a),.b(b),.s(s));

assign P[15:5] = s;
assign P[4] = s4_;

endmodule
