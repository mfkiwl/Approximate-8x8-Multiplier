`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2026 11:18:22 AM
// Design Name: 
// Module Name: sliding_window
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


module sliding_window #(
    parameter IMG_WIDTH  = 512,
    parameter IMG_HEIGHT = 512
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  pixel_in,
    input  wire        pixel_valid,
    output wire [7:0]  w00, w01, w02,
    output wire [7:0]  w10, w11, w12,
    output wire [7:0]  w20, w21, w22,
    output wire        window_valid
);

    reg [7:0] line_buf0 [0:IMG_WIDTH-1];
    reg [7:0] line_buf1 [0:IMG_WIDTH-1];

    reg [7:0] sr0_0, sr0_1, sr0_2;
    reg [7:0] sr1_0, sr1_1, sr1_2;
    reg [7:0] sr2_0, sr2_1, sr2_2;

    reg [11:0] col_cnt;
    reg [11:0] row_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            col_cnt <= 0;
            row_cnt <= 0;
            sr0_0 <= 0; sr0_1 <= 0; sr0_2 <= 0;
            sr1_0 <= 0; sr1_1 <= 0; sr1_2 <= 0;
            sr2_0 <= 0; sr2_1 <= 0; sr2_2 <= 0;
        end
        else if (pixel_valid) begin
            // Shift current row
            sr0_2 <= sr0_1;
            sr0_1 <= sr0_0;
            sr0_0 <= pixel_in;

            // Shift line buffer 1
            sr1_2 <= sr1_1;
            sr1_1 <= sr1_0;
            sr1_0 <= line_buf1[col_cnt];

            // Shift line buffer 0
            sr2_2 <= sr2_1;
            sr2_1 <= sr2_0;
            sr2_0 <= line_buf0[col_cnt];

            // Update line buffers
            line_buf0[col_cnt] <= line_buf1[col_cnt];
            line_buf1[col_cnt] <= pixel_in;

            // Update column and row counters
            if (col_cnt == IMG_WIDTH - 1) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1;
            end else begin
                col_cnt <= col_cnt + 1;
            end
        end
    end

    // Window outputs
assign w00 = sr0_2; assign w01 = sr0_1; assign w02 = sr0_0;
assign w10 = sr1_2; assign w11 = sr1_1; assign w12 = sr1_0;
assign w20 = sr2_2; assign w21 = sr2_1; assign w22 = sr2_0;

    // Window valid when at least 2 rows and 2 cols filled
    assign window_valid = pixel_valid
                        && (row_cnt >= 2)
                        && (col_cnt >= 2);

endmodule
