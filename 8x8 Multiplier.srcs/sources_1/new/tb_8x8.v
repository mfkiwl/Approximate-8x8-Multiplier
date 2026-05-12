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


// ======================================================
wire [15:0] P8;
wire [15:0] P11;

// ======================================================
// Instantiate BOTH designs
// ======================================================

PBOM8_8bits dut1 (
    .A(A),
    .B(B),
    .P(P8)
);

PBOM8_11bits dut2 (
    .A(A),
    .B(B),
    .P(P11)
);

// ======================================================

task run_test;

    input [7:0] a_in;
    input [7:0] b_in;

    reg [15:0] exact;

    begin

        A = a_in;
        B = b_in;

        exact = a_in * b_in;

        #10;

        $display(
        "A=%3d  B=%3d  Exact=%5d   PBOM8_8bits=%5d   PBOM8_11bits=%5d",
        A, B, exact, P8, P11
        );

    end

endtask


initial begin

    $display("====================================================================");
    $display("                 MULTIPLIER COMPARISON");
    $display("====================================================================");

    run_test(10 , 10);
    run_test(15 , 15);
    run_test(50 , 50);
    run_test(100,100);
    run_test(128,  2);
    run_test(200,100);
    run_test(255,255);

    $display("====================================================================");

    $finish;

end
endmodule
