`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2026 02:37:07 PM
// Design Name: 
// Module Name: AM8EC_2
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


module AM8EC_2(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire [7:0] pp[7:0];

genvar i;
generate
   for(i=0;i<8;i=i+1)begin
    assign pp[i] = A & {8{B[i]}};
   end
endgenerate

assign P[0] = pp[0][0];

// Stage 1
//column 2
wire s2,c2_to_3;
Half_Adder COL2_HA1(.a(pp[0][2]),.b(pp[1][1]),.sum(s2),.carry(c2_to_3));

//column 3
wire s3;
assign s3 = ((pp[0][3])&(pp[1][2])&(pp[2][1])&(pp[3][0]));

//column 4
wire s4;
assign s4 = ((pp[0][4])&(pp[1][3])&(pp[2][2])&(pp[3][1]));

//column 5
wire s5,s5_ha,c5_to_6;
assign s5 = ((pp[0][5])&(pp[1][4])&(pp[2][3])&(pp[3][2]));
Half_Adder COL5_HA1(.a(pp[4][1]),.b(pp[5][0]),.sum(s5_ha),.carry(c5_to_6));

//column 6
wire s6,s6_fa,c6_to_c7;
assign s6 = ((pp[0][6])&(pp[1][5])&(pp[2][4])&(pp[3][3]));
Full_Adder COL6_FA1(.a(pp[4][2]),.b(pp[5][1]),.Cin(pp[6][0]),.Cout(c6_to_c7),.sum(s6_fa));

//Error Correction Block
wire Cout1,Cout2,E;
assign Cout1 = (pp[2][1] & pp[3][0]);
assign Cout2 = (pp[2][2] & pp[3][1]);
assign E = (Cout1&Cout2);

//column 7
wire s7_comp1,s7_comp2,c7_to_8_comp1,c7_to_8_comp2,c7_to_c8_comp1,c7_to_c8_comp2;
compressor_exact COL7_COMP1(.X1(pp[0][7]),.X2(pp[1][6]),.X3(pp[2][5]),.X4(pp[3][4]),.Cin(E),.S(s7_comp1),.C(c7_to_8_comp1),.Cout(c7_to_c8_comp1));
compressor_exact COL7_COMP2(.X1(pp[4][3]),.X2(pp[5][2]),.X3(pp[6][1]),.X4(pp[7][0]),.Cin(c6_to_c7),.S(s7_comp2),.C(c7_to_8_comp2),.Cout(c7_to_c8_comp2));

//column 8
wire s8_comp1,s8_comp2,c8_to_9_comp1,c8_to_9_comp2,c8_to_c9_comp1,c8_to_c9_comp2;
compressor_exact COL8_COMP1(.X1(pp[1][7]),.X2(pp[2][6]),.X3(pp[3][5]),.X4(pp[4][4]),.Cin(c7_to_c8_comp1),.S(s8_comp1),.C(c8_to_9_comp1),.Cout(c8_to_c9_comp1));
compressor_exact COL8_COMP2(.X1(pp[5][3]),.X2(pp[6][2]),.X3(pp[7][1]),.X4(1'b0),.Cin(c7_to_c8_comp2),.S(s8_comp2),.C(c8_to_9_comp2),.Cout(c8_to_c9_comp2));

//column 9
wire s9_comp,s9_fa,c9_to_10_comp,c9_to_10_fa,c9_to_c10_comp;
compressor_exact COL9_COMP1(.X1(pp[2][7]),.X2(pp[3][6]),.X3(pp[4][5]),.X4(pp[5][4]),.Cin(c8_to_c9_comp1),.S(s9_comp),.C(c9_to_10_comp),.Cout(c9_to_c10_comp));
Full_Adder COL9_FA1(.a(pp[6][3]),.b(pp[7][2]),.Cin(c8_to_c9_comp2),.Cout(c9_to_10_fa),.sum(s9_fa));

//column 10
wire s10,c10_to_11,c10_to_c11;
compressor_exact COL10_COMP1(.X1(pp[3][7]),.X2(pp[4][6]),.X3(pp[5][5]),.X4(pp[6][4]),.Cin(c9_to_c10_comp),.S(s10),.C(c10_to_11),.Cout(c10_to_c11));

//column 11
wire c11_to_12,s11;
Full_Adder COL11_FA1(.a(pp[4][7]),.b(pp[5][6]),.Cin(c10_to_c11),.Cout(c11_to_12),.sum(s11));

// Stage 2
//column 8
wire s8_,c8_to_9_;
Full_Adder COL8_FA2(.a(s8_comp1),.b(s8_comp2),.Cin(c7_to_8_comp1),.Cout(c8_to_9_),.sum(s8_));

//column 9
wire s9_,c9_to_c10_,c9_to_10_;
compressor_exact COL9_COMP2(.X1(s9_comp),.X2(s9_fa),.X3(c8_to_9_comp1),.X4(c8_to_9_comp2),.Cin(1'b0),.S(s9_),.C(c9_to_10_),.Cout(c9_to_c10_));

//column 10
wire s10_,c10_to_11_,c10_to_c11_;
compressor_exact COL10_COMP2(.X1(s10),.X2(pp[7][3]),.X3(c9_to_10_comp),.X4(c9_to_10_fa),.Cin(c9_to_c10_),.S(s10_),.C(c10_to_11_),.Cout(c10_to_c11_));

//column 11
wire s11_,c11_to_12_,c11_to_c12_;
compressor_exact COL11_COMP2(.X1(s11),.X2(pp[6][5]),.X3(pp[7][4]),.X4(c10_to_11),.Cin(c10_to_c11_),.S(s11_),.C(c11_to_12_),.Cout(c11_to_c12_));

//column 12
wire s12_,c12_to_13_,c12_to_c13_;
compressor_exact COL12_COMP2(.X1(pp[5][7]),.X2(pp[6][6]),.X3(pp[7][5]),.X4(c11_to_12),.Cin(c11_to_c12_),.S(s12_),.C(c12_to_13_),.Cout(c12_to_c13_));

//column 13
wire s13_,c13_to_14_;
Full_Adder COL13_FA2(.a(pp[6][7]),.b(pp[7][6]),.Cin(c12_to_c13_),.Cout(c13_to_14_),.sum(s13_));

// Stage 3
wire [13:0] a,b;
assign a = {pp[7][7],s13_,s12_,s11_,s10_,s9_,s8_,s7_comp1,s6,s5,s4,s3,s2,pp[0][1]};
assign b = {c13_to_14_,c12_to_13_,c11_to_12_,c10_to_11_,c9_to_10_,c8_to_9_,c7_to_8_comp2,s7_comp2,s6_fa,s5_ha,pp[4][0],c2_to_3,pp[2][0],pp[1][0]};

assign {P[15], P[14:1]} = a+b;
endmodule
