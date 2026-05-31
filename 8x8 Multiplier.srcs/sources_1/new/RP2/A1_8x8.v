`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2026 06:51:25 PM
// Design Name: 
// Module Name: A1_8x8
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


module A1_8x8(input [7:0] A,B, output [15:0] P);

wire [7:0] pp[7:0];
genvar i;
generate 
for(i=0; i<8; i = i+1) begin
    assign pp[i] = A & {8{B[i]}};
end
endgenerate

// STAGE 1
//column 4
wire s4, c4_to_5;
Half_Adder COL3_HA1(.a(pp[0][4]),.b(pp[1][3]),.sum(s4),.carry(c4_to_5));

//column 5
wire s5, c5_to_6;
Approx_Compressor_A1 COL5_COMP1(.X1(pp[0][5]),.X2(pp[1][4]),.X3(pp[2][3]),.X4(pp[3][2]),.S(s5),.C(c5_to_6));

//column 6
wire s6_comp,c6_to_7_comp,s6_ha,c6_to_7_ha;
Approx_Compressor_A1 COL6_COMP1(.X1(pp[0][6]),.X2(pp[1][5]),.X3(pp[2][4]),.X4(pp[3][3]),.S(s6_comp),.C(c6_to_7_comp));
Half_Adder COL6_HA1(.a(pp[4][2]),.b(pp[5][1]),.sum(s6_ha),.carry(c6_to_7_ha));

//column 7
wire s7_comp1,c7_to_8_comp1,s7_comp2,c7_to_8_comp2;
Approx_Compressor_A1 COL7_COMP1(.X1(pp[0][7]),.X2(pp[1][6]),.X3(pp[2][5]),.X4(pp[3][4]),.S(s7_comp1),.C(c7_to_8_comp1));
Approx_Compressor_A1 COL7_COMP2(.X1(pp[4][3]),.X2(pp[5][2]),.X3(pp[6][1]),.X4(pp[7][0]),.S(s7_comp2),.C(c7_to_8_comp2));

//column 8
wire s8_comp,c8_to_9_comp,c8_to_c9_comp,s8_fa,c8_to_9_fa;
compressor_exact COL8_COMP1(.X1(pp[1][7]),.X2(pp[2][6]),.X3(pp[3][5]),.X4(pp[4][4]),.Cin(1'b0),.S(s8_comp),.C(c8_to_9_comp),.Cout(c8_to_c9_comp));
Full_Adder COL8_FA1(.a(pp[5][3]),.b(pp[6][2]),.Cin(pp[7][1]),.sum(s8_fa),.Cout(c8_to_9_fa));

//column 9
wire s9_comp,c9_to_10_comp,c9_to_c10_comp,s9_ha,c9_to_10_ha;
compressor_exact COL9_COMP1(.X1(pp[2][7]),.X2(pp[3][6]),.X3(pp[4][5]),.X4(pp[5][4]),.Cin(c8_to_c9_comp),.S(s9_comp),.C(c9_to_10_comp),.Cout(c9_to_c10_comp));
Half_Adder COL9_HA1(.a(pp[6][3]),.b(pp[7][2]),.sum(s9_ha),.carry(c9_to_10_ha));

//column 10
wire s10,c10_to_11,c10_to_c11;
compressor_exact COL10_COMP1(.X1(pp[3][7]),.X2(pp[4][6]),.X3(pp[5][5]),.X4(pp[6][4]),.Cin(c9_to_c10_comp),.S(s10),.C(c10_to_11),.Cout(c10_to_c11));

//column 11
wire s11, c11_to_12;
Full_Adder COL11_FA1(.a(pp[4][7]),.b(pp[5][6]),.Cin(c10_to_c11),.sum(s11),.Cout(c11_to_12));

//Error Recovery Module
wire Q;
Error_Detection_Module_A1 E1(.X3_1(pp[2][5]),.X4_1(pp[3][4]),.X3_2(pp[6][1]),.X4_2(pp[7][0]),.Q(Q));

// STAGE 2
//column 4
wire s4_,c4_to_5_;
Approx_Compressor_A1 COL4_COMP2(.X1(s4),.X2(pp[2][2]),.X3(pp[3][1]),.X4(pp[4][0]),.S(s4_),.C(c4_to_5_));

//column 5
wire s5_,c5_to_6_;
Approx_Compressor_A1 COL5_COMP2(.X1(s5),.X2(c4_to_5),.X3(pp[4][1]),.X4(pp[5][0]),.S(s5_),.C(c5_to_6_));

//column 6
wire s6_,c6_to_7_;
Approx_Compressor_A1 COL6_COMP2(.X1(s6_comp),.X2(s6_ha),.X3(c5_to_6),.X4(pp[6][0]),.S(s6_),.C(c6_to_7_));

//column 7
wire s7_,c7_to_8_;
Approx_Compressor_A1 COL7_COMP3(.X1(s7_comp1),.X2(s7_comp2),.X3(c6_to_7_comp),.X4(c6_to_7_ha),.S(s7_),.C(c7_to_8_));

//column 8
wire s8_,c8_to_9_,c8_to_c9_;
compressor_exact COL8_COMP2(.X1(s8_comp),.X2(s8_fa),.X3(c7_to_8_comp1),.X4(c7_to_8_comp2),.Cin(Q),.S(s8_),.C(c8_to_9_),.Cout(c8_to_c9_));

//column 9
wire s9,c9_to_10_,c9_to_c10_;
compressor_exact COL9_COMP2(.X1(s9_comp),.X2(s9_ha),.X3(c8_to_9_comp),.X4(c8_to_9_fa),.Cin(c8_to_c9_),.S(s9_),.C(c9_to_10_),.Cout(c9_to_c10_));

//column 10
wire s10_,c10_to_11_,c10_to_c11_;
compressor_exact COL10_COMP2(.X1(s10),.X2(pp[7][3]),.X3(c9_to_10_comp),.X4(c9_to_10_ha),.Cin(c9_to_c10_),.S(s10_),.C(c10_to_11_),.Cout(c10_to_c11_));

//column 11
wire c11_to_12_,c11_to_c12_;
compressor_exact COL11_COMP1(.X1(s11),.X2(pp[6][5]),.X3(pp[7][4]),.X4(c10_to_11),.Cin(c10_to_c11_),.S(s11_),.C(c11_to_12_),.Cout(c11_to_c12_));

//column 12
wire s12_,c12_to_13_,c12_to_c13_;
compressor_exact COL12_COMP1(.X1(c11_to_12),.X2(pp[5][7]),.X3(pp[6][6]),.X4(pp[7][5]),.Cin(c11_to_c12_),.S(s12_),.C(c12_to_13_),.Cout(c12_to_c13_));

//column 13
wire s13_,c13_to_14_;
Full_Adder COL13_FA1(.a(pp[6][7]),.b(pp[7][6]),.Cin(c12_to_c13_),.sum(s13_),.Cout(c13_to_14_));

// STAGE 3
 assign P[3:0] = 4'b0;
 
 assign P[4] = s4_;
 
 wire [9:0] a,b;
 assign a = {pp[7][7], s13_,s12_,s11_,s10_,s9_,s8_,s7_,s6_,s5_};
 assign b = {c13_to_14_,c12_to_13_,c11_to_12_,c10_to_11_,c9_to_10_,c8_to_9_,c7_to_8_,c6_to_7_,c5_to_6_,c4_to_5_};
 assign {P[15] , P[14:5]} = a+b;

endmodule
