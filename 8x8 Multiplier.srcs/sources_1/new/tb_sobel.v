`timescale 1ns/1ps
`include "image_params.vh"

module tb_sobel;

    // ── ONLY CHANGE THIS LINE FOR EACH DESIGN ────────────────────
    parameter DESIGN_NAME = "PBOM8_73Y";
    

    // Everything automatic from image_params.vh
    parameter IMG_WIDTH  = `SOBEL_WIDTH;
    parameter IMG_HEIGHT = `SOBEL_HEIGHT;
    parameter TOTAL_PIX  = `SOBEL_TOTAL;

    reg        clk, rst;
    reg  [7:0] pixel_in;
    reg        pixel_valid;
    wire [7:0] pixel_out;
    wire       valid_out;

    always #5 clk = ~clk;

    top_level_sobel #(
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) dut (
        .clk        (clk),
        .rst        (rst),
        .pixel_in   (pixel_in),
        .pixel_valid(pixel_valid),
        .pixel_out  (pixel_out),
        .valid_out  (valid_out)
    );

    reg     [7:0] image_mem [0:TOTAL_PIX-1];
    integer       out_file;
    integer       file_handle;
    integer       pixel_val;
    integer       valid_count;
    integer       i, idx;

    // Load image using $fscanf (reads DECIMAL) 
    initial begin
        file_handle = $fopen(`SOBEL_INPUT, "r");

        if (file_handle == 0) begin
            $display("ERROR: Cannot open input file!");
            $display("Check path in image_params.vh");
            $finish;
        end

        for (idx = 0; idx < TOTAL_PIX; idx = idx + 1) begin
            $fscanf(file_handle, "%d\n", pixel_val);
            image_mem[idx] = pixel_val[7:0];
        end

        $fclose(file_handle);

        // Verify image loaded correctly
        $display("Image loaded OK");
        $display("First pixel : %0d", image_mem[0]);
        $display("Middle pixel: %0d", image_mem[TOTAL_PIX/2]);
        $display("Last pixel  : %0d", image_mem[TOTAL_PIX-1]);
    end

    // ── Write output pixels to file
    always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(out_file, "%0d\n", pixel_out);
            valid_count = valid_count + 1;
        end
    end

    // ── Main simulation
    initial begin
        out_file = $fopen(
            {`SIM_OUTPUT, "sobel_", DESIGN_NAME, ".txt"},
            "w"
        );
        valid_count = 0;

        if (out_file == 0) begin
            $display("ERROR: Cannot open output file!");
            $display("Check sim_output folder exists");
            $finish;
        end

        clk         = 0;
        rst         = 1;
        pixel_valid = 0;
        pixel_in    = 0;

        repeat(10) @(posedge clk);
        rst = 0;
        repeat(5)  @(posedge clk);

        $display("=====================================");
        $display("Sobel Simulation Started");
        $display("Design      : %s",       DESIGN_NAME);
        $display("Image size  : %0d x %0d",
                  IMG_WIDTH, IMG_HEIGHT);
        $display("Total pixels: %0d",      TOTAL_PIX);
        $display("=====================================");

        // Feed all pixels one by one
        for (i = 0; i < TOTAL_PIX; i = i + 1) begin
            @(posedge clk);
            pixel_in    <= image_mem[i];
            pixel_valid <= 1;
        end

        // Flush pipeline
        pixel_valid <= 0;
        repeat(20) @(posedge clk);

        $display("=====================================");
        $display("Output pixels written : %0d", valid_count);
        $display("Expected pixels       : %0d",
                  (IMG_WIDTH-2)*(IMG_HEIGHT-2));
        $display("=====================================");

        $fclose(out_file);
        $display("Sobel Simulation DONE!");
        $finish;
    end

endmodule