`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2026 20:26:48
// Design Name: 
// Module Name: Error_Tb
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
module Error_tb;

    reg [7:0] A, B;
    wire [15:0] exact_out;
    wire [15:0] approx_out;

    reg [15:0] exact_sample, approx_sample;
    reg [31:0] abs_error_int;
    reg [31:0] total_combinations;
    reg [31:0] incorrect_outputs;
    reg [31:0] max_error;

    reg incorrect_flag;

    real total_med, total_mred, total_mse;
    real abs_err_real, sq_err_real, mred_per;
    real MED, NMED, MRED, MSE, ER, EDmax;

    integer i, j, fd;

    //---------------------------------------------------------
    // DUT Instantiation
    //---------------------------------------------------------

    Multiplier_using_exact_comp uut_exact (
        .A(A),
        .B(B),
        .P(exact_out)
    );

    AM8EC_1 uut_approx (
        .A(A),
        .B(B),
        .P(approx_out)
    );

    //---------------------------------------------------------
    // Testbench
    //---------------------------------------------------------

    initial begin

        //-----------------------------------------------------
        // Initialize inputs
        //-----------------------------------------------------

        A = 0;
        B = 0;

        //-----------------------------------------------------
        // Open CSV file
        //-----------------------------------------------------

        fd = $fopen("A1.csv", "w");

        if (fd == 0)
        begin
            $display("ERROR: File open failed.");
            $finish;
        end

        //-----------------------------------------------------
        // CSV Header
        //-----------------------------------------------------

        $fdisplay(fd,
        "A,B,Exact,Approx,Abs_Error,Sq_Error,MRED_per,Incorrect");

        //-----------------------------------------------------
        // Initialize Variables
        //-----------------------------------------------------

        total_med  = 0.0;
        total_mred = 0.0;
        total_mse  = 0.0;

        total_combinations = 0;
        incorrect_outputs  = 0;
        max_error          = 0;

        //-----------------------------------------------------
        // Exhaustive Testing
        //-----------------------------------------------------

        for (i = 0; i < 256; i = i + 1)
        begin

            for (j = 0; j < 256; j = j + 1)
            begin

                //---------------------------------------------
                // Apply Inputs
                //---------------------------------------------

                A = i;
                B = j;

                #10;

                //---------------------------------------------
                // Sample Outputs
                //---------------------------------------------

                exact_sample  = exact_out;
                approx_sample = approx_out;

                //---------------------------------------------
                // Absolute Error
                //---------------------------------------------

                if (approx_sample >= exact_sample)
                    abs_error_int =
                    approx_sample - exact_sample;
                else
                    abs_error_int =
                    exact_sample - approx_sample;

                abs_err_real =
                $itor(abs_error_int);

                sq_err_real =
                abs_err_real *
                abs_err_real;

                //---------------------------------------------
                // MRED
                //---------------------------------------------

                if (exact_sample != 0)
                    mred_per =
                    abs_err_real /
                    $itor(exact_sample);
                else
                    mred_per = 0.0;

                //---------------------------------------------
                // Max Error
                //---------------------------------------------

                if (abs_error_int > max_error)
                    max_error =
                    abs_error_int;

                //---------------------------------------------
                // Incorrect Outputs
                //---------------------------------------------

                if (approx_sample != exact_sample)
                begin
                    incorrect_outputs =
                    incorrect_outputs + 1;

                    incorrect_flag = 1;
                end
                else
                begin
                    incorrect_flag = 0;
                end

                //---------------------------------------------
                // Accumulate Metrics
                //---------------------------------------------

                total_med =
                total_med +
                abs_err_real;

                total_mred =
                total_mred +
                mred_per;

                total_mse =
                total_mse +
                sq_err_real;

                total_combinations =
                total_combinations + 1;

                //---------------------------------------------
                // Write CSV Row
                //---------------------------------------------

                $fdisplay(fd,
                "%0d,%0d,%0d,%0d,%0d,%0d,%f,%0d",
                i,
                j,
                exact_sample,
                approx_sample,
                abs_error_int,
                $rtoi(sq_err_real),
                mred_per,
                incorrect_flag);

            end

            $fflush(fd);

        end

        //-----------------------------------------------------
        // Final Metrics
        //-----------------------------------------------------

        MED =
        total_med /
        $itor(total_combinations);

        NMED =
        MED / 65535.0;

        MRED =
        total_mred /
        $itor(total_combinations);

        MSE =
        total_mse /
        $itor(total_combinations);

        ER =
        ($itor(incorrect_outputs) /
        $itor(total_combinations))
        * 100.0;

        EDmax =
        $itor(max_error);

        //-----------------------------------------------------
        // Write Summary
        //-----------------------------------------------------

        $fdisplay(fd, "");
        $fdisplay(fd, "Metric,Value");

        $fdisplay(fd, "MED,%f", MED);
        $fdisplay(fd, "NMED,%f", NMED);
        $fdisplay(fd, "MRED,%f", MRED);
        $fdisplay(fd, "MSE,%f", MSE);
        $fdisplay(fd, "ER(%%),%f", ER);
        $fdisplay(fd, "EDmax,%f", EDmax);

        $fclose(fd);

        //-----------------------------------------------------
        // Console Output
        //-----------------------------------------------------

        $display("================================================");
        $display("Total Combinations : %0d",
                  total_combinations);
        $display("MED                : %f",
                  MED);
        $display("NMED               : %f",
                  NMED);
        $display("MRED               : %f",
                  MRED);
        $display("MSE                : %f",
                  MSE);
        $display("ER (%%)            : %f",
                  ER);
        $display("EDmax              : %f",
                  EDmax);
        $display("================================================");

        $finish;

end
endmodule