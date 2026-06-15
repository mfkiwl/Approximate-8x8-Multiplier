`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 01:15:30 AM
// Design Name: 
// Module Name: RCA_10bit
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


module RCA_10bit(a, b, s);
    input  [9:0]  a, b;
    output [10:0] s;
    wire   [8:0]  c;

    Full_Adder FA0 (.a(a[0]), .b(b[0]), .Cin(1'b0), .sum(s[0]),  .Cout(c[0]));
    Full_Adder FA1 (.a(a[1]), .b(b[1]), .Cin(c[0]), .sum(s[1]),  .Cout(c[1]));
    Full_Adder FA2 (.a(a[2]), .b(b[2]), .Cin(c[1]), .sum(s[2]),  .Cout(c[2]));
    Full_Adder FA3 (.a(a[3]), .b(b[3]), .Cin(c[2]), .sum(s[3]),  .Cout(c[3]));
    Full_Adder FA4 (.a(a[4]), .b(b[4]), .Cin(c[3]), .sum(s[4]),  .Cout(c[4]));
    Full_Adder FA5 (.a(a[5]), .b(b[5]), .Cin(c[4]), .sum(s[5]),  .Cout(c[5]));
    Full_Adder FA6 (.a(a[6]), .b(b[6]), .Cin(c[5]), .sum(s[6]),  .Cout(c[6]));
    Full_Adder FA7 (.a(a[7]), .b(b[7]), .Cin(c[6]), .sum(s[7]),  .Cout(c[7]));
    Full_Adder FA8 (.a(a[8]), .b(b[8]), .Cin(c[7]), .sum(s[8]),  .Cout(c[8]));
    Full_Adder FA9 (.a(a[9]), .b(b[9]), .Cin(c[8]), .sum(s[9]),  .Cout(s[10]));

endmodule

