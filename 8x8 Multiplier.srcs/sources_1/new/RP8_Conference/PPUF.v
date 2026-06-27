`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 08:22:26 PM
// Design Name: 
// Module Name: PPUF
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


module PPUF(ai,bi,aj,bj,Sin,Ai,Bi,Aj,Bj,Sout,Cout);
input ai,bi,aj,bj,Sin;
output Ai,Bi,Bj,Aj,Sout,Cout;
assign Ai = ai;
assign Bi = bi;
assign Aj = aj;
assign Bj = bj;

wire aib,ajb;

assign aib = ai&bi;
assign ajb = aj&bj;

Full_Adder FA(.a(Sin),.b(aib),.Cin(ajb),.sum(Sout),.Cout(Cout));

endmodule
