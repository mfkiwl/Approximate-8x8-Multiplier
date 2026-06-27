`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 06:48:54 PM
// Design Name: 
// Module Name: CD_PPU
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


module CD_PPU(ai,bi,Sin,Sout,Ai,Bi);
input ai,bi,Sin;
output Sout,Ai,Bi;

assign Ai= ai;
assign Bi = bi;

assign Sout = ((Sin)^(ai&bi));
endmodule
