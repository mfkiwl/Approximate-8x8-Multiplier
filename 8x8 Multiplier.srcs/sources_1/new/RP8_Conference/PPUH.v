`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 06:45:12 PM
// Design Name: 
// Module Name: PPUH
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


module PPUH(ai,bi,Sin,Sout,Cout,Ai,Bi);
input ai,bi,Sin;
output Sout,Cout,Ai,Bi;

assign Ai = ai;
assign Bi = bi;
wire ab;
assign ab = (ai&bi);

Half_Adder HA1(.a(ab),.b(Sin),.sum(Sout),.carry(Cout));

endmodule
