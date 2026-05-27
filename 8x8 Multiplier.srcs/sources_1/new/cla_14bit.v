`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2026 05:51:56 PM
// Design Name: 
// Module Name: cla_14bit
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


module cla_14bit (
    input  [13:0] a,
    input  [13:0] b,
    input         cin,
    output [13:0] sum,
    output        cout
);
    wire c1, c2, c3;
    wire P0, G0, P1, G1, P2, G2, P3, G3;

    // Inter-group carry lookahead
    assign c1 = G0 | (P0 & cin);
    assign c2 = G1 | (P1 & G0) | (P1 & P0 & cin);
    assign c3 = G2 | (P2 & G1) | (P2 & P1 & G0) | (P2 & P1 & P0 & cin);

    // Final carry out — group level
    assign cout = G3 | (P3 & G2) | (P3 & P2 & G1)
                     | (P3 & P2 & P1 & G0)
                     | (P3 & P2 & P1 & P0 & cin);

    // Group 0 : bits 3:0
    cla_4bit G0_INST (.a(a[3:0]),.b(b[3:0]),.cin(cin),.sum(sum[3:0]),.cout(),.P(P0),.G(G0));

    // Group 1 : bits 7:4
    cla_4bit G1_INST (.a(a[7:4]),.b(b[7:4]),.cin(c1),.sum (sum[7:4]),.cout(),.P(P1),.G(G1));

    // Group 2 : bits 11:8
    cla_4bit G2_INST (.a(a[11:8]),.b(b[11:8]),.cin(c2),.sum(sum[11:8]),.cout(),.P(P2),.G(G2));

    // Group 3 : bits 13:12
    cla_2bit G3_INST (.a(a[13:12]),.b(b[13:12]),.cin(c3),.sum(sum[13:12]),.cout(),.P(P3),.G(G3));

endmodule
