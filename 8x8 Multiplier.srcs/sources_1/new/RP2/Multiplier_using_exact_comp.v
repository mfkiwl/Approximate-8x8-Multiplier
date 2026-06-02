`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2026 12:31:43 AM
// Design Name: 
// Module Name: Multiplier_using_exact_comp
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

module Multiplier_using_exact_comp(input [7:0] A,B, output[15:0]P);

wire [7:0] pp[7:0];

genvar i,j;

generate
    for(i=0; i<8; i=i+1) begin
        for(j=0; j<8; j=j+1) begin
            assign pp[i][j] = A[j] & B[i];
        end
    end
endgenerate
// STAGE 1
//column 0
wire s0;
assign s0 = pp[0][0];
assign P[0] = s0;

//column 4
wire s4,c4_to_5;
Half_Adder COL4_HA1(.a(pp[0][4]),.b(pp[1][3]),
.sum(s4),.carry(c4_to_5));

//column 5
wire s5,c5_to_6,c5_to_c6;
compressor_exact COL5_COMP1(.X1(pp[0][5]),.X2(pp[1][4]),.X3(pp[2][3]),.X4(pp[3][2]),.Cin(1'b0),.S(s5),.C(c5_to_6),.Cout(c5_to_c6));

//column 6
wire s6_comp,s6_ha,c6_to_7_comp,c6_to_7_ha,c6_to_c7;
compressor_exact COL6_COMP1(.X1(pp[0][6]),.X2(pp[1][5]),.X3(pp[2][4]),.X4(pp[3][3]),.Cin(c5_to_c6),.S(s6_comp),.C(c6_to_7_comp),.Cout(c6_to_c7));
Half_Adder COL6_HA1(.a(pp[4][2]),.b(pp[5][1]),.sum(s6_ha),.carry(c6_to_7_ha));

//column 7
wire s7_comp1,c7_to_8_comp1,c7_to_c8_1,s7_comp2,c7_to_8_comp2,c7_to_c8_2;
compressor_exact COL7_COMP1(.X1(pp[0][7]),.X2(pp[1][6]),.X3(pp[2][5]),.X4(pp[3][4]),.Cin(c6_to_c7),.S(s7_comp1),.C(c7_to_8_comp1),.Cout(c7_to_c8_1));
compressor_exact COL7_COMP2(.X1(pp[4][3]),.X2(pp[5][2]),.X3(pp[6][1]),.X4(pp[7][0]),.Cin(1'b0),.S(s7_comp2),.C(c7_to_8_comp2),.Cout(c7_to_c8_2));

//column 8
wire s8_comp1,c8_to_9_comp1,c8_to_c9_1,s8_comp2,c8_to_9_comp2,c8_to_9_2;
compressor_exact COL8_COMP1(.X1(pp[1][7]),.X2(pp[2][6]),.X3(pp[3][5]),.X4(pp[4][4]),.Cin(c7_to_c8_1),.S(s8_comp1),.C(c8_to_9_comp1),.Cout(c8_to_c9_1));
compressor_exact COL8_COMP2(.X1(pp[5][3]),.X2(pp[6][2]),.X3(pp[7][1]),.X4(1'b0),.Cin(c7_to_c8_2),.S(s8_comp2),.C(c8_to_9_comp2),.Cout(c8_to_c9_2));

//column 9
wire s9_comp,c9_to_10_comp,c9_to_c10,s9_fa,c9_to_10_fa;
compressor_exact COL9_COMP1(.X1(pp[2][7]),.X2(pp[3][6]),.X3(pp[4][5]),.X4(pp[5][4]),.Cin(c8_to_c9_1),.S(s9_comp),.C(c9_to_10_comp),.Cout(c9_to_c10));
Full_Adder COL9_FA1(.a(pp[6][3]),.b(pp[7][2]),.Cin(c8_to_c9_2),.sum(s9_fa),.Cout(c9_to_10_fa));

//column 10
wire s10,c10_to_11,c10_to_c11;
compressor_exact COL10_COMP1(.X1(pp[3][7]),.X2(pp[4][6]),.X3(pp[5][5]),.X4(pp[6][4]),.Cin(c9_to_c10),.S(s10),.C(c10_to_11),.Cout(c10_to_c11));

//column 11
wire s11,c11_to_12;
Full_Adder COL11_FA1(.a(pp[4][7]),.b(pp[5][6]),.Cin(c10_to_c11),.sum(s11),.Cout(c11_to_12));

// STAGE 2

//column 2
wire s2_b,c2_to_3_;
Full_Adder COL2_FA2(.a(pp[0][2]),.b(pp[1][1]),.Cin(pp[2][0]),.sum(s2_b),.Cout(c2_to_3_));

//column 3
wire s3_b,c3_to_4_,c3_to_c4_;
compressor_exact COL3_COMP1_2(.X1(pp[0][3]),.X2(pp[1][2]),.X3(pp[2][1]),.X4(pp[3][0]),.Cin(1'b0),.S(s3_b),.C(c3_to_4_),.Cout(c3_to_c4_));

//column 4
wire s4_b,c4_to_5_,c4_to_c5_;
compressor_exact COL4_COMP1_2(.X1(pp[2][2]),.X2(pp[3][1]),.X3(pp[4][0]),.X4(s4),.Cin(c3_to_c4_),.S(s4_b),.C(c4_to_5_),.Cout(c4_to_c5_));

//column 5
wire s5_b,c5_to_6_,c5_to_c6_;
compressor_exact COL5_COMP1_2(.X1(pp[4][1]),.X2(pp[5][0]),.X3(s5),.X4(c4_to_5),.Cin(c4_to_c5_),.S(s5_b),.C(c5_to_6_),.Cout(c5_to_c6_));

//column 6
wire s6_b,c6_to_7_,c6_to_c7_;
compressor_exact COL6_COMP1_2(.X1(pp[6][0]),.X2(s6_comp),.X3(s6_ha),.X4(c5_to_6),.Cin(c5_to_c6_),.S(s6_b),.C(c6_to_7_),.Cout(c6_to_c7_));
//
//column 7
wire s7_b,c7_to_8_,c7_to_c8_;
compressor_exact COL7_COMP1_2(.X1(s7_comp1),.X2(s7_comp2),.X3(c6_to_7_comp),.X4(c6_to_7_ha),.Cin(c6_to_c7_),.S(s7_b),.C(c7_to_8_),.Cout(c7_to_c8_));

//column 8
wire s8_b,c8_to_9_,c8_to_c9_;
compressor_exact COL8_COMP1_2(.X1(s8_comp1),.X2(s8_comp2),.X3(c7_to_8_comp1),.X4(c7_to_8_comp2),.Cin(c7_to_c8_),.S(s8_b),.C(c8_to_9_),.Cout(c8_to_c9_));

//column 9
wire s9_b,c9_to_10_,c9_to_c10_;
compressor_exact COL9_COMP1_2(.X1(s9_comp),.X2(s9_fa),.X3(c8_to_9_comp1),.X4(c8_to_9_comp2),.Cin(c8_to_c9_),.S(s9_b),.C(c9_to_10_),.Cout(c9_to_c10_));

//column 10
wire s10_b,c10_to_11_,c10_to_c11_;
compressor_exact COL10_COMP1_2(.X1(pp[7][3]),.X2(s10),.X3(c9_to_10_comp),.X4(c9_to_10_fa),.Cin(c9_to_c10_),.S(s10_b),.C(c10_to_11_),.Cout(c10_to_c11_));

//column 11
wire s11_b,c11_to_12_,c11_to_c12_;
compressor_exact COL11_COMP1_2(.X1(pp[6][5]),.X2(pp[7][4]),.X3(s11),.X4(c10_to_11),.Cin(c10_to_c11_),.S(s11_b),.C(c11_to_12_),.Cout(c11_to_c12_));

//column 12
wire s12_b,c12_to_13_,c12_to_c13_;
compressor_exact COL12_COMP1_2(.X1(pp[5][7]),.X2(pp[6][6]),.X3(pp[7][5]),.X4(c11_to_12),.Cin(c11_to_c12_),.S(s12_b),.C(c12_to_13_),.Cout(c12_to_c13_));

//column 13
wire s13_b,c13_to_14_,c13_to_c14_;
Full_Adder COL113_FA2(.a(pp[6][7]),.b(pp[7][6]),.Cin(c12_to_c13_),.sum(s13_b),.Cout(c13_to_14_));

//STAGE 3
wire [13:0]a,b,S;
assign a = {pp[7][7], s13_b, s12_b, s11_b, s10_b, s9_b, s8_b, s7_b,s6_b, s5_b, s4_b, s3_b, s2_b, pp[0][1]};

assign b = {c13_to_14_, c12_to_13_, c11_to_12_, c10_to_11_, c9_to_10_,c8_to_9_,c7_to_8_,c6_to_7_,c5_to_6_,c4_to_5_,c3_to_4_,c2_to_3_,1'b0,pp[1][0]};

assign {P[15], P[14:1]} = a + b;

endmodule