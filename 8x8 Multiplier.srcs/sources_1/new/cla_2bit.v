`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2026 05:47:43 PM
// Design Name: 
// Module Name: cla_2bit
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


module cla_2bit (
    input  [1:0] a,
    input  [1:0] b,
    input        cin,
    output [1:0] sum,
    output       cout,
    output       P,
    output       G
);
    wire [1:0] g, p;
    assign g = a & b;
    assign p = a ^ b;
 
    wire [1:0] c;
    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & cin);
 
    assign sum  = p ^ c;
    assign cout = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
 
    assign P = p[1] & p[0];
    assign G = g[1] | (p[1] & g[0]);
endmodule
