module gaussian_filter (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  p00, p01, p02,
    input  wire [7:0]  p10, p11, p12,
    input  wire [7:0]  p20, p21, p22,
    input  wire        valid_in,
    output reg  [7:0]  pixel_out,
    output reg         valid_out
);

    wire [15:0] prod00, prod01, prod02;
    wire [15:0] prod10, prod11, prod12;
    wire [15:0] prod20, prod21, prod22;

    // ── CHANGE ONLY THIS ONE LINE 
    `define MULT PBO_3_8X8

    `MULT m00(.A(p00), .B(8'd95),  .P(prod00));
    `MULT m01(.A(p01), .B(8'd118), .P(prod01));
    `MULT m02(.A(p02), .B(8'd95),  .P(prod02));
    `MULT m10(.A(p10), .B(8'd118), .P(prod10));
    `MULT m11(.A(p11), .B(8'd148), .P(prod11));
    `MULT m12(.A(p12), .B(8'd118), .P(prod12));
    `MULT m20(.A(p20), .B(8'd95),  .P(prod20));
    `MULT m21(.A(p21), .B(8'd118), .P(prod21));
    `MULT m22(.A(p22), .B(8'd95),  .P(prod22));

    // Sum of all kernel values = 1000
    wire [21:0] sum;
    assign sum = prod00 + prod01 + prod02
               + prod10 + prod11 + prod12
               + prod20 + prod21 + prod22;

    // FIXED: divide by 1000 
    // Kernel h2 was scaled by 1000 from h1
    // So divide by 1000 to get correct pixel values
    wire [21:0] normalized;
    assign normalized = sum / 1000;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_out <= 0;
            valid_out <= 0;
        end else begin
            valid_out <= valid_in;
            pixel_out <= (normalized > 22'd255) ?
                          8'd255 : normalized[7:0];
        end
    end

endmodule