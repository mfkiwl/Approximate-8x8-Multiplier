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
wire [15:0] P17;


// ======================================================
// Instantiate BOTH designs
// ======================================================

/*PBOM8_8bits dut1 (
    .A(A),
    .B(B),
    .P(P8)
);

PBOM8_11bits dut2 (
    .A(A),
    .B(B),
    .P(P11)
);


Multiplier_using_exact_comp dut3(.A(A),.B(B),.P(P9));


A1_8x8 dut3(.A(A),.B(B),.P(P10));


A3_8X8 dut3(.A(A),.B(B),.P(P15));

AM8EC_1 dut4(.A(A),.B(B),.P(P16));
*/
A6_FULL dut4(.A(A),.B(B),.P(P17));
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
        "A=%3d  B=%3d  Exact=%5d   A6_FULL=%5d" ,
        A, B, exact, P17
        );

    end

endtask


initial begin

    $display("====================================================================");
    $display("                 MULTIPLIER COMPARISON");
    $display("====================================================================");

 
    run_test(8'b00000001, 8'b11111111);  // A=1,   B=255
run_test(8'b11111111, 8'b00000100);  // A=255, B=4
run_test(8'b00000001, 8'b00000100);  // A=1,   B=4  
run_test(8'b11111111, 8'b10000000);  // A=255, B=128
run_test(8'b10000000, 8'b11111111);  // A=128, B=255
    run_test(8'hFF, 8'hFF);  // 255×255, error=128
run_test(8'hFE, 8'hFF);  // 254×255 — does it fail?
run_test(8'hFF, 8'hFE);  // 255×254 — does it fail?
run_test(8'hFF, 8'hFD);  // 255×253 — does it fail?
run_test(8'hFF, 8'hFB);  // 255×251 — does it fail?
run_test(8'hFF, 8'hF7);  // 255×247 — fails 
run_test(8'd1, 8'd16);
run_test(8'd1, 8'd32);
run_test(8'd1, 8'd64);
run_test(8'd1, 8'd128);
run_test(8'd2, 8'd128);
run_test(8'd16, 8'd16);
run_test(8'd32, 8'd32);
    
    $display("====================================================================");

    $finish;

end
endmodule
