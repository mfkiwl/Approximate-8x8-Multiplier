`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2026 03:31:58 PM
// Design Name: 
// Module Name: A6_FULL
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


module A6_FULL(A,B,P);
input [7:0] A,B;
output [15:0] P;

wire[7:0] pp[7:0];

genvar i;

generate
for(i=0;i<8;i=i+1)begin
assign pp[i] = A& {8{B[i]}};
end
endgenerate

assign P[0] = pp[0][0];

// Stage 1
//column 4
wire s4,c4_to_5;
Half_Adder COL4_HA1(.a(pp[0][4]),.b(pp[1][3]),.sum(s4),.carry(c4_to_5));

//column 5
wire s5, c5_to_6;
A6_COMP COL5_COMP1(.X1(pp[0][5]),.X2(pp[1][4]),.X3(pp[2][3]),.X4(pp[3][2]),.C(c5_to_6),.S(s5));

//column 6
wire s6_comp,s6_ha,c6_to_7_ha,c6_to_7_comp;
A6_COMP COL6_COMP1(.X1(pp[0][6]),.X2(pp[1][5]),.X3(pp[2][4]),.X4(pp[3][3]),.C(c6_to_7_comp),.S(s6_comp));
Half_Adder COL6_HA1(.a(pp[4][2]),.b(pp[5][1]),.sum(s6_ha),.carry(c6_to_7_ha));

//column 7
wire s7_comp1,s7_comp2,c7_to_8_comp1,c7_to_8_comp2;
A6_COMP COL7_COMP1(.X1(pp[0][7]),.X2(pp[1][6]),.X3(pp[2][5]),.X4(pp[3][4]),.C(c7_to_8_comp1),.S(s7_comp1));
A6_COMP COL7_COMP2(.X1(pp[4][3]),.X2(pp[5][2]),.X3(pp[6][1]),.X4(pp[7][0]),.C(c7_to_8_comp2),.S(s7_comp2));

//column 8
wire s8_comp,s8_fa,c8_to_9_comp,c8_to_9_fa;
A6_COMP COL8_COMP1(.X1(pp[1][7]),.X2(pp[2][6]),.X3(pp[3][5]),.X4(pp[4][4]),.S(s8_comp),.C(c8_to_9_comp));
Full_Adder COL8_FA1(.a(pp[5][3]),.b(pp[6][2]),.Cin(pp[7][1]),.sum(s8_fa),.Cout(c8_to_9_fa));

//column 9
wire s9_comp,s9_ha,c9_to_10_comp,c9_to_10_ha;
A6_COMP COL9_COMP1(.X1(pp[2][7]),.X2(pp[3][6]),.X3(pp[4][5]),.X4(pp[5][4]),.S(s9_comp),.C(c9_to_10_comp));
Half_Adder COL9_HA1(.a(pp[6][3]),.b(pp[7][2]),.sum(s9_ha),.carry(c9_to_10_ha));

//column 10
wire s10,c10_to_11;
A6_COMP COL10_COMP1(.X1(pp[3][7]),.X2(pp[4][6]),.X3(pp[5][5]),.X4(pp[6][4]),.S(s10),.C(c10_to_11));

//column 11
wire s11,c11_to_12;
Full_Adder COL11_FA1(.a(pp[4][7]),.b(pp[5][6]),.Cin(1'b0),.sum(s11),.Cout(c11_to_12));

// Stage 2
//column 2
wire s2_,c2_to_3_;
Half_Adder COL2_HA2(.a(pp[0][2]),.b(pp[1][1]),.sum(s2_),.carry(c2_to_3_));

//column 3
wire s3_,c3_to_4_;
A6_COMP COL3_COMP2(.X1(pp[0][3]),.X2(pp[1][2]),.X3(pp[2][1]),.X4(pp[3][0]),.C(c3_to_4_),.S(s3_));

//column 4
wire s4_,c4_to_5_;
A6_COMP COL4_COMP2(.X1(s4),.X2(pp[2][2]),.X3(pp[3][1]),.X4(pp[4][0]),.C(c4_to_5_),.S(s4_));

//column 5
wire s5_,c5_to_6_;
A6_COMP COL5_COMP2(.X1(s5),.X2(c4_to_5),.X3(pp[4][1]),.X4(pp[5][0]),.C(c5_to_6_),.S(s5_));

//column 6
wire s6_,c6_to_7_;
A6_COMP COL6_COMP2(.X1(s6_comp),.X2(s6_ha),.X3(c5_to_6),.X4(pp[6][0]),.C(c6_to_7_),.S(s6_));

//column 7
wire s7_,c7_to_8_;
A6_COMP COL7_COMP_2(.X1(s7_comp1),.X2(s7_comp2),.X3(c6_to_7_comp),.X4(c6_to_7_ha),.C(c7_to_8_),.S(s7_));

//column 8
wire s8_,c8_to_9_;
A6_COMP COL8_COMP2(.X1(s8_comp),.X2(s8_fa),.X3(c7_to_8_comp1),.X4(c7_to_8_comp2),.S(s8_),.C(c8_to_9_));

//column 9
wire s9_,c9_to_10_;
A6_COMP COL9_COMP2(.X1(s9_comp),.X2(s9_ha),.X3(c8_to_9_comp),.X4(c8_to_9_fa),.S(s9_),.C(c9_to_10_));

//column 10
wire s10_,c10_to_11_;
A6_COMP COL10_COMP2(.X1(s10),.X2(c9_to_10_comp),.X3(c9_to_10_ha),.X4(pp[7][3]),.S(s10_),.C(c10_to_11_));

//column 11
wire s11_,c11_to_12_;
A6_COMP COL11_COMP2(.X1(s11),.X2(c10_to_11),.X3(pp[6][5]),.X4(pp[7][4]),.S(s11_),.C(c11_to_12_));

//column 12
wire s12_,c12_to_13_;
A6_COMP COL12_COMP2(.X1(pp[5][7]),.X2(pp[6][6]),.X3(pp[7][5]),.X4(c11_to_12),.S(s12_),.C(c12_to_13_));

//column 13
wire s13_,c13_to_14_;
Full_Adder COL13_FA2(.a(pp[6][7]),.b(pp[7][6]),.Cin(1'b0),.sum(s13_),.Cout(c13_to_14_));

// Stage 3
wire [13:0] a,b;

assign a = {pp[7][7],s13_,s12_,s11_,s10_,s9_,s8_,s7_,s6_,s5_,s4_,s3_,s2_,pp[0][1]};
assign b = {c13_to_14_,c12_to_13_,c11_to_12_,c10_to_11_,c9_to_10_,c8_to_9_,c7_to_8_,c6_to_7_,c5_to_6_,c4_to_5_,c3_to_4_,c2_to_3_,pp[2][0],pp[1][0]};

RCA_14bit RCA (
    .a(a),
    .b(b),
    .s(P[15:1])
);

endmodule
