`timescale 1ns / 1ps

// Create Date: 03/19/2026 02:30:57 PM
// Design Name: Exact 8x4 Multiplier
// Module Name: multiplier_8x4

module multiplier_8x4(input [7:0] A, input [3:0] B, output [11:0] P);
// Partial products
wire [7:0] pp0, pp1, pp2, pp3;

assign pp0 = A & {8{B[0]}};
assign pp1 = A & {8{B[1]}};
assign pp2 = A & {8{B[2]}};
assign pp3 = A & {8{B[3]}};

// Column 0
assign P[0] = pp0[0];

// Column 1 (HA 1)
wire c1;
Half_Adder HA1(.a(pp0[1]), .b(pp1[0]), .sum(P[1]), .carry(c1));

// Column 2
wire s2, c2, c2_2;
Full_Adder FA1(.a(pp0[2]), .b(pp1[1]), .Cin(pp2[0]), .sum(s2), .Cout(c2));
Full_Adder FA2(.a(s2), .b(c1), .Cin(1'b0), .sum(P[2]), .Cout(c2_2));

// Column 3
wire s3_1, s3_2, c3_1, c3_2, c3_3;
Full_Adder FA3(.a(pp0[3]), .b(pp1[2]), .Cin(pp2[1]), .sum(s3_1), .Cout(c3_1));
Full_Adder FA4(.a(pp3[0]), .b(c2), .Cin(c2_2), .sum(s3_2), .Cout(c3_2));
Full_Adder FA5(.a(s3_1), .b(s3_2), .Cin(1'b0), .sum(P[3]), .Cout(c3_3));

// Column 4
wire s4_1, s4_2, c4_1, c4_2, c4_3;
Full_Adder FA6(.a(pp0[4]), .b(pp1[3]), .Cin(pp2[2]), .sum(s4_1), .Cout(c4_1));
Full_Adder FA7(.a(pp3[1]), .b(c3_1), .Cin(c3_2), .sum(s4_2), .Cout(c4_2));
Full_Adder FA8(.a(s4_1), .b(s4_2), .Cin(c3_3), .sum(P[4]), .Cout(c4_3));

// Column 5
wire s5_1, s5_2, c5_1, c5_2, c5_3;
Full_Adder FA9(.a(pp0[5]), .b(pp1[4]), .Cin(pp2[3]), .sum(s5_1), .Cout(c5_1));
Full_Adder FA10(.a(pp3[2]), .b(c4_1), .Cin(c4_2), .sum(s5_2), .Cout(c5_2));
Full_Adder FA11(.a(s5_1), .b(s5_2), .Cin(c4_3), .sum(P[5]), .Cout(c5_3));

// Column 6
wire s6_1, s6_2, c6_1, c6_2, c6_3;
Full_Adder FA12(.a(pp0[6]), .b(pp1[5]), .Cin(pp2[4]), .sum(s6_1), .Cout(c6_1));
Full_Adder FA13(.a(pp3[3]), .b(c5_1), .Cin(c5_2), .sum(s6_2), .Cout(c6_2));
Full_Adder FA14(.a(s6_1), .b(s6_2), .Cin(c5_3), .sum(P[6]), .Cout(c6_3));

// Column 7
wire s7_1, s7_2, c7_1, c7_2, c7_3;
Full_Adder FA15(.a(pp0[7]), .b(pp1[6]), .Cin(pp2[5]), .sum(s7_1), .Cout(c7_1));
Full_Adder FA16(.a(pp3[4]), .b(c6_1), .Cin(c6_2), .sum(s7_2), .Cout(c7_2));
Full_Adder FA17(.a(s7_1), .b(s7_2), .Cin(c6_3), .sum(P[7]), .Cout(c7_3));

// Column 8
wire s8, c8_1, c8_2;
Full_Adder FA18(.a(pp1[7]), .b(pp2[6]), .Cin(pp3[5]), .sum(s8), .Cout(c8_1));
Full_Adder FA19(.a(s8), .b(c7_1), .Cin(c7_2), .sum(P[8]), .Cout(c8_2));

// Column 9 (HA 2 introduced here)
wire s9, c9;
Half_Adder HA2(.a(pp2[7]), .b(pp3[6]), .sum(s9), .carry(c9));

// combine with previous carry using FA
wire c9_out;
Full_Adder FA20(.a(s9), .b(c8_1), .Cin(c8_2), .sum(P[9]), .Cout(c9_out));

// Column 10 (HA 3)
wire s10, c10;
Half_Adder HA3(.a(pp3[7]), .b(c9_out), .sum(s10), .carry(c10));

// Column 11 (HA 4 - final balancing)
Half_Adder HA4(.a(s10), .b(1'b0), .sum(P[10]), .carry(P[11]));
endmodule