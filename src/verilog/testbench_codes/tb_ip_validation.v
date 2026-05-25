`timescale 1ns/1ps

module tb_ip_validation;

// ================= CLOCK =================
reg clk;
initial clk = 0;
always #5 clk = ~clk;   // 100 MHz

// ================= INPUTS =================
reg [63:0] a, b;
reg start;

// ================= OUTPUTS =================
wire [63:0] add_out, mul_out, div_out, sqrt_out;
wire [7:0]  cmp_out;

wire add_valid, mul_valid, div_valid, sqrt_valid, cmp_valid;

// ================= DUT INSTANCES =================

// ADD/SUB (sub = 0 → ADD)
fp64_addsub u_add (
    .clk(clk),
    .a(a),
    .b(b),
    .sub(1'b0),
    .start(start),
    .result(add_out),
    .valid_out(add_valid)
);

// MUL
fp64_mul u_mul (
    .clk(clk),
    .a(a),
    .b(b),
    .start(start),
    .result(mul_out),
    .valid_out(mul_valid)
);

// DIV
fp64_div u_div (
    .clk(clk),
    .a(a),
    .b(b),
    .start(start),
    .result(div_out),
    .valid_out(div_valid)
);

// SQRT
fp64_sqrt u_sqrt (
    .clk(clk),
    .a(a),
    .start(start),
    .result(sqrt_out),
    .valid_out(sqrt_valid)
);

// CMP
fp64_cmp u_cmp (
    .clk(clk),
    .a(a),
    .b(b),
    .start(start),
    .result(cmp_out),
    .valid_out(cmp_valid)
);

// ================= TASK =================
task start_pulse;
begin
    start = 1;
    @(posedge clk);
    start = 0;
end
endtask

// ================= TEST SEQUENCE =================
initial begin

    start = 0;

    // =====================================================
    // TEST 1: ADD → 3 + 2 = 5
    // =====================================================
    a = 64'h4008000000000000; // 3.0
    b = 64'h4000000000000000; // 2.0

    @(posedge clk);
    start_pulse();

    wait(add_valid);
    $display("[ADD] 3 + 2 = %h", add_out);

    // =====================================================
    // TEST 2: SUB → 5 - 3 = 2
    // =====================================================
    a = 64'h4014000000000000; // 5.0
    b = 64'h4008000000000000; // 3.0

    @(posedge clk);
    start_pulse();

    wait(add_valid);
    $display("[SUB] 5 - 3 = %h", add_out);

    // =====================================================
    // TEST 3: MUL → 3 * 2 = 6
    // =====================================================
    a = 64'h4008000000000000; // 3.0
    b = 64'h4000000000000000; // 2.0

    @(posedge clk);
    start_pulse();

    wait(mul_valid);
    $display("[MUL] 3 * 2 = %h", mul_out);

    // =====================================================
    // TEST 4: MUL → 0.03 * 0.03 = 0.0009
    // =====================================================
    a = 64'h3F9EB851EB851EB8; // 0.03
    b = 64'h3F9EB851EB851EB8; // 0.03

    @(posedge clk);
    start_pulse();

    wait(mul_valid);
    $display("[MUL] 0.03 * 0.03 = %h", mul_out);

    // =====================================================
    // TEST 5: DIV → 6 / 2 = 3
    // =====================================================
    a = 64'h4018000000000000; // 6.0
    b = 64'h4000000000000000; // 2.0

    @(posedge clk);
    start_pulse();

    wait(div_valid);
    $display("[DIV] 6 / 2 = %h", div_out);

    // =====================================================
    // TEST 6: SQRT → sqrt(9) = 3
    // =====================================================
    a = 64'h4022000000000000; // 9.0

    @(posedge clk);
    start_pulse();

    wait(sqrt_valid);
    $display("[SQRT] sqrt(9) = %h", sqrt_out);

    // =====================================================
    // TEST 7: CMP → 3 > 2
    // =====================================================
    a = 64'h4008000000000000; // 3
    b = 64'h4000000000000000; // 2

    @(posedge clk);
    start_pulse();

    wait(cmp_valid);
    $display("[CMP] 3 vs 2 = %b", cmp_out);

    // =====================================================
    // END
    // =====================================================
    #100;
    $finish;

end

endmodule