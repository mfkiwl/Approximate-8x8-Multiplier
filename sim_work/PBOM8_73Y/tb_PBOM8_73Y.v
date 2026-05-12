`timescale 1ns/1ps
module tb_PBOM8_73Y;

    reg  [7:0]  A, B;
    wire [15:0] P;

    PBOM8_73Y dut (
        .A(A),
        .B(B),
        .P(P)
    );

    integer fin, fout, code;
    reg [7:0] a_val, b_val;

    initial begin
        fin  = $fopen("C:/Users/ankit/8x8 Multiplier/sim_work/PBOM8_73Y/inputs.hex", "r");
        fout = $fopen("C:/Users/ankit/8x8 Multiplier/sim_work/PBOM8_73Y/outputs.hex", "w");

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
