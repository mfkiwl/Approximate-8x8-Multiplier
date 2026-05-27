module tb_debug;
reg [7:0] A, B;
wire [15:0] P;

// instantiate your multiplier
Multiplier_using_exact_comp UUT(.A(A),.B(B),.P(P));

initial begin
    A = 255; B = 255;
    #10;
    
    $display("=== PARTIAL PRODUCTS (column weight) ===");
    $display("pp[0][1]=%b pp[1][0]=%b (col1)", UUT.pp[0][1], UUT.pp[1][0]);
    $display("pp[2][0]=%b s2_b=%b c2_to_3_=%b (col2)", UUT.pp[2][0], UUT.s2_b, UUT.c2_to_3_);
    $display("s3_b=%b c3_to_4_=%b (col3)", UUT.s3_b, UUT.c3_to_4_);
    $display("s4_b=%b c4_to_5_=%b (col4)", UUT.s4_b, UUT.c4_to_5_);
    $display("s5_b=%b c5_to_6_=%b (col5)", UUT.s5_b, UUT.c5_to_6_);
    $display("s6_b=%b c6_to_7_=%b (col6)", UUT.s6_b, UUT.c6_to_7_);
    $display("s7_b=%b c7_to_8_=%b (col7)", UUT.s7_b, UUT.c7_to_8_);
    $display("s8_b=%b c8_to_9_=%b (col8)", UUT.s8_b, UUT.c8_to_9_);
    $display("s9_b=%b c9_to_10_=%b (col9)", UUT.s9_b, UUT.c9_to_10_);
    $display("s10_b=%b c10_to_11_=%b (col10)", UUT.s10_b, UUT.c10_to_11_);
    $display("s11_b=%b c11_to_12_=%b (col11)", UUT.s11_b, UUT.c11_to_12_);
    $display("s12_b=%b c12_to_13_=%b (col12)", UUT.s12_b, UUT.c12_to_13_);
    $display("s13_b=%b c13_to_14_=%b (col13)", UUT.s13_b, UUT.c13_to_14_);
    $display("pp[7][7]=%b (col14)", UUT.pp[7][7]);
    
    $display("=== CLA INPUTS ===");
    $display("a = %b", UUT.a);
    $display("b = %b", UUT.b);
    
    $display("=== OUTPUT ===");
    $display("P = %d (expected 65025)", P);
    $display("P = %b", P);
    $display("Expected = %b", 16'd65025);
    
    $display("=== STAGE 1 COL7 ===");
$display("s7_comp1=%b s7_comp2=%b", UUT.s7_comp1, UUT.s7_comp2);
$display("c6_to_7_comp=%b c6_to_7_ha=%b", UUT.c6_to_7_comp, UUT.c6_to_7_ha);

$display("=== STAGE 1 COL8 ===");
$display("s8_comp=%b s8_fa=%b", UUT.s8_comp, UUT.s8_fa);
$display("c7_to_8_comp1=%b c7_to_8_comp2=%b", UUT.c7_to_8_comp1, UUT.c7_to_8_comp2);

$display("=== STAGE 1 COL9 ===");
$display("s9_comp=%b s9_ha=%b", UUT.s9_comp, UUT.s9_ha);
$display("c8_to_9_comp=%b c8_to_9_fa=%b", UUT.c8_to_9_comp, UUT.c8_to_9_fa);

$display("=== STAGE 2 COL7 ===");
$display("s7_b=%b c7_to_8_=%b c7_to_c8_=%b", UUT.s7_b, UUT.c7_to_8_, UUT.c7_to_c8_);

$display("=== STAGE 2 COL8 ===");
$display("s8_b=%b c8_to_9_=%b c8_to_c9_=%b", UUT.s8_b, UUT.c8_to_9_, UUT.c8_to_c9_);

$display("=== STAGE 2 COL9 ===");
$display("s9_b=%b c9_to_10_=%b c9_to_c10_=%b", UUT.s9_b, UUT.c9_to_10_, UUT.c9_to_c10_);

$display("c8_to_c9_=%b", UUT.c8_to_c9_);

$display("COL9 inputs: s9_comp=%b s9_ha=%b c8_to_9_comp=%b c8_to_9_fa=%b Cin=c8_to_c9_=%b", UUT.s9_comp, UUT.s9_ha, UUT.c8_to_9_comp, UUT.c8_to_9_fa, UUT.c8_to_c9_);
$display("COL9 outputs: s9_b=%b c9_to_10_=%b c9_to_c10_=%b", UUT.s9_b, UUT.c9_to_10_, UUT.c9_to_c10_);

$display("c8_to_9_=%b (should feed b[8]->P[9])", UUT.c8_to_9_);
$display("b = %b", UUT.b);
$display("a = %b", UUT.a);

          
end
endmodule