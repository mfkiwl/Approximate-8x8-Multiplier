`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2026 04:01:21 PM
// Design Name: 
// Module Name: cla_12bit
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


module cla_12bit (
    input  [11:0] A, B,
    input         Cin,
    output [11:0] Sum,
    output        Cout
);
    wire C4, C8;
    wire PG0, GG0, PG1, GG1, PG2, GG2;
    wire C_1,C_2,C_3;

    cla_4bit U0 (.A(A[3:0]),   .B(B[3:0]),   .Cin(Cin), .Sum(Sum[3:0]),   .Cout(C_1), .PG(PG0), .GG(GG0));
    assign C4 = GG0 | (PG0 & Cin);

    cla_4bit U1 (.A(A[7:4]),   .B(B[7:4]),   .Cin(C4),  .Sum(Sum[7:4]),   .Cout(C_2), .PG(PG1), .GG(GG1));
    assign C8 = GG1 | (PG1 & GG0) | (PG1 & PG0 & Cin);

    cla_4bit U2 (.A(A[11:8]),  .B(B[11:8]),  .Cin(C8),  .Sum(Sum[11:8]),  .Cout(C_3), .PG(PG2), .GG(GG2));
    assign Cout = GG2 | (PG2 & GG1) | (PG2 & PG1 & GG0) | (PG2 & PG1 & PG0 & Cin);
endmodule

