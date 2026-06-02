`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2026 06:41:23 PM
// Design Name: 
// Module Name: A3_8X8
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


module A3_8X8(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [7:0] pp[7:0];

genvar i;
generate
for(i=0;i<8;i=i+1)begin
assign pp[i] = A & {8{B[i]}};
end
endgenerate

// STAGE 1
//column 0
assign P[0] = pp[0][0];

//column 1
wire c1_to_2;
Half_Adder COL1_HA1(.a(pp[0][1]),.b(pp[1][0]),.sum(P[1]),.carry(c1_to_2));

//column 2
wire s2,c2_to_3;
Full_Adder COL2_FA1(.a(pp[0][2]),.b(pp[1][1]),.Cin(pp[2][0]),.sum(s2),.Cout(c2_to_3));

//column 3
wire s3,c3_to_4;
A3_comp COL3_COMP1(.A1(pp[0][3]),.A2(pp[1][2]),.A3(pp[2][1]),.A4(pp[3][0]),.sum(s3),.carry(c3_to_4));

//column 4
wire s4,c4_to_5;
A3_comp COL4_COMP1(.A1(pp[0][4]),.A2(pp[1][3]),.A3(pp[2][2]),.A4(pp[3][1]),.sum(s4),.carry(c4_to_5));

//column 5
wire s5_comp,c5_to_6_comp;
A3_comp COL5_COMP1(.A1(pp[0][5]),.A2(pp[1][4]),.A3(pp[2][3]),.A4(pp[3][2]),.sum(s5_comp),.carry(c5_to_6_comp));
wire s5_ha,c5_to_6_ha;
Half_Adder COL5_HA1(.a(pp[4][1]),.b(pp[5][0]),.sum(s5_ha),.carry(c5_to_6_ha));

//column 6
wire s6_comp,c6_to_7_comp;
A3_comp COL6_COMP1(.A1(pp[0][6]),.A2(pp[1][5]),.A3(pp[2][4]),.A4(pp[3][3]),.sum(s6_comp),.carry(c6_to_7_comp));
wire s6_fa,c6_to_7_fa;
Full_Adder COL6_FA1(.a(pp[4][2]),.b(pp[5][1]),.Cin(pp[6][0]),.sum(s6_fa),.Cout(c6_to_7_fa));

//column 7
wire s7_comp1,c7_to_8_comp1;
A3_comp COL7_COMP1(.A1(pp[0][7]),.A2(pp[1][6]),.A3(pp[2][5]),.A4(pp[3][4]),.sum(s7_comp1),.carry(c7_to_8_comp1));
wire s7_comp2,c7_to_8_comp2;
A3_comp COL7_COMP2(.A1(pp[4][3]),.A2(pp[5][2]),.A3(pp[6][1]),.A4(pp[7][0]),.sum(s7_comp2),.carry(c7_to_8_comp2));

//column 8
wire s8_fa,c8_to_9_fa;
Full_Adder COL8_FA1(.a(pp[1][7]),.b(pp[2][6]),.Cin(pp[3][5]),.sum(s8_fa),.Cout(c8_to_9_fa));
wire s8_comp,c8_to_9_comp;
A3_comp COL8_COMP(.A1(pp[4][4]),.A2(pp[5][3]),.A3(pp[6][2]),.A4(pp[7][1]),.sum(s8_comp),.carry(c8_to_9_comp));

//column 9
wire s9_ha,c9_to_10_ha;
Half_Adder COL9_HA1(.a(pp[2][7]),.b(pp[3][6]),.sum(s9_ha),.carry(c9_to_10_ha));
wire s9_comp,c9_to_10_comp,c9_to_c10;
compressor_exact COL9_COMP1(.X1(pp[4][5]),.X2(pp[5][4]),.X3(pp[6][3]),.X4(pp[7][2]),.Cin(1'b0),.S(s9_comp),.C(c9_to_10_comp),.Cout(c9_to_c10));

//column 10
wire s10,c10_to_11,c10_to_c11;
compressor_exact COL10_COMP1(.X1(pp[4][6]),.X2(pp[5][5]),.X3(pp[6][4]),.X4(pp[7][3]),.Cin(c9_to_c10),.S(s10),.C(c10_to_11),.Cout(c10_to_c11));

//column 11
wire s11,c11_to_12;
Full_Adder COL11_FA1(.a(pp[4][7]),.b(pp[5][6]),.Cin(c10_to_c11),.sum(s11),.Cout(c11_to_12));


// STAGE 2
//column 2
wire c2_to_3_;
Half_Adder COL2_HA2(.a(s2),.b(c1_to_2),.sum(P[2]),.carry(c2_to_3_));

//column 3
wire s3_,c3_to_4_;
Half_Adder COL3_HA2(.a(s3),.b(c2_to_3),.sum(s3_),.carry(c3_to_4_));

//column 4
wire s4_,c4_to_5_;
Full_Adder COL4_FA2(.a(pp[4][0]),.b(s4),.Cin(c3_to_4),.sum(s4_),.Cout(c4_to_5_));

//column 5
wire s5_,c5_to_6_;
Full_Adder COL5_FA1(.a(s5_comp),.b(s5_ha),.Cin(c4_to_5),.sum(s5_),.Cout(c5_to_6_));

//column 6
wire s6_,c6_to_7_;
A3_comp COL6_COMP2(.A1(s6_comp),.A2(s6_fa),.A3(c5_to_6_comp),.A4(c5_to_6_ha),.sum(s6_),.carry(c6_to_7_));

//column 7
wire s7_,c7_to_8_;
A3_comp COL7_COMP(.A1(s7_comp1),.A2(s7_comp2),.A3(c6_to_7_comp),.A4(c6_to_7_fa),.sum(s7_),.carry(c7_to_8_));

//column 8
wire s8_,c8_to_9_;
A3_comp COL8_COMP2(.A1(s8_comp),.A2(s8_fa),.A3(c7_to_8_comp1),.A4(c7_to_8_comp2),.sum(s8_),.carry(c8_to_9_));

//column 9
wire s9_,c9_to_10_,c9_to_c10_;
compressor_exact COL9_COMP2(.X1(s9_comp),.X2(s9_ha),.X3(c8_to_9_comp),.X4(c8_to_9_fa),.Cin(1'b0),.S(s9_),.C(c9_to_10_),.Cout(c9_to_c10_));

//column 10
wire s10_,c10_to_11_,c10_to_c11_;
compressor_exact COL10_COMP2(.X1(pp[3][7]),.X2(s10),.X3(c9_to_10_ha),.X4(c9_to_10_comp),.Cin(c9_to_c10_),.S(s10_),.C(c10_to_11_),.Cout(c10_to_c11_));

//column 11
wire s11_,c11_to_12_,c11_to_c12_;
compressor_exact COL11_COMP1(.X1(pp[6][5]),.X2(s11),.X3(c10_to_11),.X4(pp[7][4]),.Cin(c10_to_c11_),.S(s11_),.C(c11_to_12_),.Cout(c11_to_c12_));

// column 12
wire s12_,c12_to_13_,c12_to_c13_;
compressor_exact COL12_COMP2(.X1(pp[5][7]),.X2(pp[6][6]),.X3(pp[7][5]),.X4(c11_to_12),.Cin(c11_to_c12_),.S(s12_),.C(c12_to_13_),.Cout(c12_to_c13_));

//column 13
wire s13_,c13_to_14_;
Full_Adder COL13_FA2(.a(pp[6][7]),.b(pp[7][6]),.Cin(c12_to_c13_),.sum(s13_),.Cout(c13_to_14_));

// STAGE 3
wire [11:0] a,b;
assign a = {pp[7][7],s13_,s12_,s11_,s10_,s9_,s8_,s7_,s6_,s5_,s4_,s3_};
assign b = {c13_to_14_,c12_to_13_,c11_to_12_,c10_to_11_,c9_to_10_,c8_to_9_,c7_to_8_,c6_to_7_,c5_to_6_,c4_to_5_,c3_to_4_,c2_to_3_};

assign {P[15], P[14:3]} = a+b;

endmodule
