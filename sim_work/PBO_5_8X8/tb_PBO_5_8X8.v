`timescale 1ns/1ps
module tb_PBO_5_8X8;

    reg  [7:0]  A, B;
    wire [15:0] P;

    PBO_5_8X8 dut (
        .A(A),
        .B(B),
        .P(P)
    );

    integer fin, fout, code;
    reg [7:0] a_val, b_val;

    initial begin
        fin  = $fopen("C:/Users/ankit/8x8 Multiplier/sim_work/PBO_5_8X8/inputs.hex", "r");
        fout = $fopen("C:/Users/ankit/8x8 Multiplier/sim_work/PBO_5_8X8/outputs.hex", "w");

        if (fin  == 0) begin
            $display("ERROR: cannot open input file");
            $finish;
        end

        if (fout == 0) begin
            $display("ERROR: cannot open output file");
            $finish;
        end

        while (!$feof(fin)) begin
            code = $fscanf(fin, "%h %h\n", a_val, b_val);

            if (code == 2) begin
                A = a_val;
                B = b_val;

                #10;

                $fdisplay(fout, "%h", P);
            end
        end

        $fclose(fin);
        $fclose(fout);

        $finish;
    end

endmodule
