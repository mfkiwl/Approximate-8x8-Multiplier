`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 03:52:07 PM
// Design Name: 
// Module Name: A4_ECB_1
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


module A4_ECB_1(C1,C2,C3,E);
input C1,C2,C3;
output E;

wire a;
assign a = C3 & (C1 | C2);
assign E = (a | (C1&C2));
endmodule
