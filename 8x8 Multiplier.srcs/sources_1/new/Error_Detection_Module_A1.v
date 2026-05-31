`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2026 08:19:29 PM
// Design Name: 
// Module Name: Error_Detection_Module_A1
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


module Error_Detection_Module_A1(input X3_1,X4_1,X3_2,X4_2, output Q);

wire Q1,Q2;
assign Q1 = (X3_1 & X4_1);
assign Q2 = (X3_2 & X4_2);

assign Q = Q1&Q2;
endmodule
