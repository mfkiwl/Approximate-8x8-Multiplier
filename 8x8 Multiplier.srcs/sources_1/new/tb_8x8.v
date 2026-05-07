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

integer i;
/*
PBOM8_73Y dut (
    .A(A),
    .B(B),
    .P(P)
);
*/
initial begin

    // CHECK x1
    for(i=0; i<256; i=i+1) begin

        A = i;
        B = 8'd1;
        #1;

        if(P !== i)
            $display("ERROR x1: A=%d P=%d", A, P);
    end

    // CHECK x2
    for(i=0; i<256; i=i+1) begin

        A = i;
        B = 8'd2;
        #1;

        if(P !== (i<<1))
            $display("ERROR x2: A=%d P=%d", A, P);
    end

    $display("DONE");
    $finish;

end
endmodule
