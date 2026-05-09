`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2026 01:46:53 AM
// Design Name: 
// Module Name: tb_8x8
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


module tb_8x8();

reg  [7:0] A, B;
wire [15:0] P;

    initial begin

        A = 8'd5;   B = 8'd3;
        #10;

        A = 8'd10;  B = 8'd12;
        #10;

        A = 8'd25;  B = 8'd4;
        #10;

        A = 8'd255; B = 8'd2;
        #10;

        $finish;
    end


endmodule
