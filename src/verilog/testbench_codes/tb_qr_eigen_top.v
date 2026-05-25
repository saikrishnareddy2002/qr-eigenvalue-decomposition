`timescale 1ns/1ps
// ============================================================
// tb_qr_eigen_top.v  -  User Input NxN Matrix Testbench
//
// HOW TO USE:
//   1. Create file "matrix.txt" in simulation directory:
//      C:\vlsi\project_X\project_X.sim\sim_1\behav\xsim\matrix.txt
//
//   2. First line: matrix size N (3 to 8)
//      Following N lines: N space-separated decimal values
//
//   Example matrix.txt for 4x4:
//      4
//      5.0 1.0 0.0 0.0
//      1.0 6.0 1.0 0.0
//      0.0 1.0 7.0 1.0
//      0.0 0.0 1.0 8.0
//
//   3. Set parameter N in qr_eigen_top.v to match file
//   4. Run Simulation -> run all
// ============================================================
module tb_qr_eigen_top;

// Max matrix size supported - N is compile-time constant
// MUST match N in qr_eigen_top.v
parameter N = 5;

reg  clk, rst, start;
reg  [64*N*N-1:0] A_in;
wire [64*N-1:0]   eigenvalues;
wire [64*N*N-1:0] V_flat;
wire [64*N-1:0]   sigma_flat;
wire [64*N*N-1:0] U_flat, SV_flat;
wire              done;

qr_eigen_top #(.N(N)) dut(
    .clk(clk),.rst(rst),.start(start),.A_in(A_in),
    .eigenvalues(eigenvalues),.V_flat(V_flat),
    .sigma_flat(sigma_flat),.U_flat(U_flat),.SV_flat(SV_flat),.done(done)
);

initial clk=0;
always #5 clk=~clk;

real eig_val[0:N-1];
real sig_val[0:N-1];
real mat_val[0:N*N-1];
integer ii, jj;
integer fd, code;
integer file_N;
real    val;

initial begin
    rst = 1;
    start = 0;
    A_in = {(64*N*N){1'b0}};

    // ── Open user input file ──────────────────────────────
    fd = $fopen("matrix.txt", "r");
    if (fd == 0) begin
        $display("ERROR: Cannot open matrix.txt");
        $display("Create matrix.txt in simulation directory:");
        $display("  Line 1: N");
        $display("  Lines 2 to N+1: N decimal values each");
        $finish;
    end

    // ── Read matrix size from file ────────────────────────
    code = $fscanf(fd, "%d", file_N);
    if (file_N != N) begin
        $display("WARNING: File says N=%0d but testbench N=%0d", file_N, N);
        $display("Change parameter N in qr_eigen_top.v and testbench to match");
    end

    // ── Read N*N decimal values ───────────────────────────
    $display("");
    $display("==============================================");
    $display("  Reading %0dx%0d matrix from matrix.txt", N, N);
    $display("==============================================");
    for (ii = 0; ii < N; ii = ii + 1) begin
        for (jj = 0; jj < N; jj = jj + 1) begin
            code = $fscanf(fd, "%f", val);
            if (code != 1) begin
                $display("ERROR reading A[%0d][%0d]", ii, jj);
                $fclose(fd);
                $finish;
            end
            A_in[(ii*N+jj)*64 +: 64] = $realtobits(val);
            mat_val[ii*N+jj] = val;
        end
    end
    $fclose(fd);

    // ── Display loaded matrix ─────────────────────────────
    for (ii = 0; ii < N; ii = ii + 1) begin
        $write("  [");
        for (jj = 0; jj < N; jj = jj + 1)
            $write(" %8.4f", mat_val[ii*N+jj]);
        $display(" ]");
    end
    $display("==============================================");

    // ── Reset and start ───────────────────────────────────
    repeat(5) @(posedge clk); #1;
    rst = 0;
    repeat(3) @(posedge clk); #1;
    start = 1;
    @(posedge clk); #1;
    start = 0;

    $display("");
    $display("Running QR iteration...");

    // ── Wait for completion with timeout ──────────────────
    fork
        begin : wd
            wait(done);
            disable tb;
        end
        begin : tb
            repeat(200000000) @(posedge clk);
            $display("TIMEOUT - try increasing MAX_ITER");
            disable wd;
        end
    join

    repeat(3) @(posedge clk);

    // ── Read results ──────────────────────────────────────
    for (ii = 0; ii < N; ii = ii + 1) begin
        eig_val[ii] = $bitstoreal(eigenvalues[ii*64 +: 64]);
        sig_val[ii] = $bitstoreal(sigma_flat[ii*64 +: 64]);
    end

    // ── Display EVD ───────────────────────────────────────
    $display("");
    $display("==============================================");
    $display("  EVD RESULTS (%0dx%0d)", N, N);
    $display("  Eigenvalues in descending order");
    $display("==============================================");
    for (ii = 0; ii < N; ii = ii + 1)
        $display("  lambda[%0d] = %16.10f", ii, eig_val[ii]);

    // ── Display SVD ───────────────────────────────────────
    $display("");
    $display("==============================================");
    $display("  SVD RESULTS (%0dx%0d)", N, N);
    $display("  sigma_i = |lambda_i|");
    $display("==============================================");
    for (ii = 0; ii < N; ii = ii + 1)
        $display("  sigma[%0d]  = %16.10f", ii, sig_val[ii]);
    $display("==============================================");

    #10;
    $finish;
end

endmodule