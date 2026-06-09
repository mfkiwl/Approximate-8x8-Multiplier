`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 03:49:31 PM
// Design Name: 
// Module Name: AM8EC_1
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


module AM8EC_1(A,B,P);
input [7:0] A,B;
output [15:0] P;

genvar i;
wire [7:0] pp[7:0];

generate 
for(i=0;i<8;i=i+1) begin
assign pp[i] = A & {8{B[i]}};
end
endgenerate

//column 0
assign P[0] = pp[0][0];

// Stage 1
//coloumn 4
wire s4,c4_to_5;
Half_Adder COL4_HA1(.a(pp[0][4]),.b(pp[1][3]),.sum(s4),.carry(c4_to_5));

//column 5
wire s5,c5,c5_to_6;
LPHS_1_COMP COL5_COMP1(.X1(pp[0][5]),.X2(pp[1][4]),.X3(pp[2][3]),.X4(pp[3][2]),.sum(s5),.Cout(c5),.carry(c5_to_6));

//column 6
wire s6_comp,s6_ha,c6,c6_to_7_ha,c6_to_7_comp;
LPHS_1_COMP COL6_COMP1(.X1(pp[0][6]),.X2(pp[1][5]),.X3(pp[2][4]),.X4(pp[3][3]),.sum(s6_comp),.Cout(c6),.carry(c6_to_7_comp));
Half_Adder COL6_HA1(.a(pp[4][2]),.b(pp[5][1]),.sum(s6_ha),.carry(c6_to_7_ha));

//column 7
wire s7_comp1,c7,c7_to_c8,s7_comp2,c7_to_8_comp1,c7_to_8_comp2;
LPHS_1_COMP COL7_COMP1(.X1(pp[0][7]),.X2(pp[1][6]),.X3(pp[2][5]),.X4(pp[3][4]),.sum(s7_comp1),.Cout(c7),.carry(c7_to_8_comp1));
LPHS_1_COMP COL7_COMP2(.X1(pp[4][3]),.X2(pp[5][2]),.X3(pp[6][1]),.X4(pp[7][0]),.sum(s7_comp2),.Cout(c7_to_c8),.carry(c7_to_8_comp2));

//column 8
wire s8_comp1,s8_comp2,c8_to_9_comp1,c8_to_9_comp2,c8_to_c9_comp1,c8_to_c9_comp2;
compressor_exact COL8_COMP1(.X1(pp[1][7]),.X2(pp[2][6]),.X3(pp[3][5]),.X4(pp[4][4]),.Cin(1'b0),.S(s8_comp1),.C(c8_to_9_comp1),.Cout(c8_to_c9_comp1));
compressor_exact COL8_COMP2(.X1(pp[5][3]),.X2(pp[6][2]),.X3(pp[7][1]),.X4(1'b0),.Cin(c7_to_c8),.S(s8_comp2),.C(c8_to_9_comp2),.Cout(c8_to_c9_comp2));

//column 9
wire s9_comp,s9_fa,c9_to_10_comp,c9_to_10_fa,c9_to_c10;
compressor_exact COL9_COMP1(.X1(pp[2][7]),.X2(pp[3][6]),.X3(pp[4][5]),.X4(pp[5][4]),.Cin(c8_to_c9_comp1),.S(s9_comp),.C(c9_to_10_comp),.Cout(c9_to_c10));
Full_Adder COL9_FA1(.a(pp[6][3]),.b(pp[7][2]),.Cin(c8_to_c9_comp2),.Cout(c9_to_10_fa),.sum(s9_fa));

//column 10
wire s10,c10_to_11,c10_to_c11;
compressor_exact COL10_COMP1(.X1(pp[3][7]),.X2(pp[4][6]),.X3(pp[5][5]),.X4(pp[6][4]),.Cin(c9_to_c10),.S(s10),.C(c10_to_11),.Cout(c10_to_c11));

//column 11
wire s11,c11_to_12;
Full_Adder COL11_FA1(.a(pp[4][7]),.b(pp[5][6]),.Cin(c10_to_c11),.Cout(c11_to_12),.sum(s11));


// Error Coorection Module
wire E;
A4_ECB_1 ECB(.C1(c5),.C2(c6),.C3(c7),.E(E));


// Stage 2
//column 2
wire s2_,c2_to_3_;
Half_Adder COL2_HA1(.a(pp[0][2]),.b(pp[1][1]),.sum(s2_),.carry(c2_to_3_));

//column 3
wire s3_,c3_to_4_;
LPHS_2_COMP COL3_COMP2(.X1(pp[0][3]),.X2(pp[1][2]),.X3(pp[2][1]),.X4(pp[3][0]),.sum(s3_),.carry(c3_to_4_));

//column 4
wire s4_,c4_to_5_;
LPHS_2_COMP COL4_COMP2(.X1(s4),.X2(pp[2][2]),.X3(pp[3][1]),.X4(pp[4][0]),.sum(s4_),.carry(c4_to_5_));

//column 5
wire s5_,c5_to_6_;
LPHS_2_COMP COL5_COMP2(.X1(s5),.X2(pp[4][1]),.X3(pp[5][0]),.X4(c4_to_5),.sum(s5_),.carry(c5_to_6_));

//column 6
wire s6_,c6_to_7_;
LPHS_2_COMP COL6_COMP2(.X1(pp[6][0]),.X2(s6_comp),.X3(s6_ha),.X4(c5_to_6),.sum(s6_),.carry(c6_to_7_));

//column 7
wire s7_,c7_to_8_;
LPHS_2_COMP COL7_COMP_2(.X1(s7_comp1),.X2(s7_comp2),.X3(c6_to_7_ha),.X4(c6_to_7_comp),.sum(s7_),.carry(c7_to_8_));

//column 8
wire s8_,c8_to_9_,c8_to_c9_;
compressor_exact COL8_COMP_2(.X1(s8_comp1),.X2(s8_comp2),.X3(c7_to_8_comp1),.X4(c7_to_8_comp2),.Cin(E),.S(s8_),.C(c8_to_9_),.Cout(c8_to_c9_));

//column 9
wire s9_,c9_to_10_,c9_to_c10_;
compressor_exact COL9_COMP_2(.X1(s9_comp),.X2(s9_fa),.X3(c8_to_9_comp1),.X4(c8_to_9_comp2),.Cin(c8_to_c9_),.S(s9_),.C(c9_to_10_),.Cout(c9_to_c10_));

//column 10
wire s10_,c10_to_11_,c10_to_c11_;
compressor_exact COL10_COMP_2(.X1(s10),.X2(pp[7][3]),.X3(c9_to_10_comp),.X4(c9_to_10_fa),.Cin(c9_to_c10_),.S(s10_),.C(c10_to_11_),.Cout(c10_to_c11_));

//column 11
wire s11_,c11_to_12_,c11_to_c12_;
compressor_exact COL11_COMP_2(.X1(s11),.X2(pp[6][5]),.X3(pp[7][4]),.X4(c10_to_11),.Cin(c10_to_c11_),.S(s11_),.C(c11_to_12_),.Cout(c11_to_c12_));

//column 12
wire s12_,c12_to_13_,c12_to_c13;
compressor_exact COL12_COMP_2(.X1(pp[5][7]),.X2(pp[6][6]),.X3(pp[7][5]),.X4(c11_to_12),.Cin(c11_to_c12_),.S(s12_),.C(c12_to_13_),.Cout(c12_to_c13_));

//column 13
wire s13_,c13_to_14_;
Full_Adder COL13_FA2(.a(pp[6][7]),.b(pp[7][6]),.Cin(c12_to_c13_),.Cout(c13_to_14_),.sum(s13_));

// Stage 3
wire [13:0] a,b;
assign a = {pp[7][7],s13_,s12_,s11_,s10_,s9_,s8_,s7_,s6_,s5_,s4_,s3_,s2_,pp[0][1]};
assign b = {c13_to_14_,c12_to_13_,c11_to_12_,c10_to_11_,c9_to_10_,c8_to_9_,c7_to_8_,c6_to_7_,c5_to_6_,c4_to_5_,c3_to_4_,c2_to_3_,pp[2][0],pp[1][0]};
assign {P[15], P[14:1]} = a+b;

endmodule
