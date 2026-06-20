`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2026 12:53:35 AM
// Design Name: 
// Module Name: PPU
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


module PPU(a,b,Cin,Sin,A,B,Sout,Cout);
input a,b,Cin,Sin;
output A,B,Sout,Cout;

assign A = a;
assign B = b;

wire w;
assign w= (a&b);

Full_Adder FA1(.a(Sin),.b(w),.Cin(Cin),.sum(Sout),.Cout(Cout));
endmodule
