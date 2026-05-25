`timescale 1ns/1ps
// ============================================================
// qr_eigen_top.v - Top level EVD+SVD
// CHANGE ONLY THIS: parameter N = 4
// Valid values: 3,4,5,6,7,8
// ============================================================
module qr_eigen_top #(parameter N=5)(
    input  wire              clk, rst, start,
    input  wire [64*N*N-1:0] A_in,
    output wire [64*N-1:0]   eigenvalues,
    output wire [64*N*N-1:0] V_flat,
    output wire [64*N-1:0]   sigma_flat,
    output wire [64*N*N-1:0] U_flat, SV_flat,
    output wire              done
);
reg  [64*N*N-1:0] A_reg;
wire [64*N*N-1:0] A_next;
wire qr_start,qr_done,rq_start,rq_done,ev_start,ev_done;
wire check_start,check_done,converged;
wire [64*N*N-1:0] Q_gs, R_gs;

central_fsm u_fsm(
    .clk(clk),.rst(rst),.start(start),
    .qr_start(qr_start),.qr_done(qr_done),
    .rq_start(rq_start),.rq_done(rq_done),
    .ev_start(ev_start),.ev_done(ev_done),
    .check_start(check_start),.check_done(check_done),
    .converged(converged),.done(done)
);
gram_schmidt #(.N(N)) u_gs(
    .clk(clk),.rst(rst),.start(qr_start),
    .A_flat(A_reg),.Q_flat(Q_gs),.R_flat(R_gs),.done(qr_done)
);
rq_combination #(.N(N)) u_rq(
    .clk(clk),.rst(rst),.start(rq_start),
    .R_flat(R_gs),.Q_flat(Q_gs),.A_next_flat(A_next),.done(rq_done)
);
evd_output #(.N(N)) u_ev(
    .clk(clk),.rst(rst),.start(ev_start),
    .Q_iter(Q_gs),.V_flat(V_flat),.done(ev_done)
);
diagonal_checker u_chk(
    .clk(clk),.rst(rst),.start(check_start),
    .d1 (A_reg[(N*(N-2)+(N-2))*64+:64]),
    .off(A_reg[(N*(N-2)+(N-1))*64+:64]),
    .d2 (A_reg[(N*(N-1)+(N-1))*64+:64]),
    .threshold(64'h3EB0C6F7A0B5ED8D),
    .converged(converged),.done(check_done)
);
always @(posedge clk or posedge rst) begin
    if(rst)          A_reg<={64*N*N{1'b0}};
    else if(start)   A_reg<=A_in;
    else if(rq_done) A_reg<=A_next;
end
genvar gi;
generate
    for(gi=0;gi<N;gi=gi+1) begin:eig_out
        assign eigenvalues[gi*64+:64]=A_reg[(gi*N+gi)*64+:64];
    end
endgenerate
svd_output #(.N(N)) u_svd(
    .eigenvalues(eigenvalues),.V_flat(V_flat),
    .sigma_flat(sigma_flat),.U_flat(U_flat),.SV_flat(SV_flat)
);
endmodule
