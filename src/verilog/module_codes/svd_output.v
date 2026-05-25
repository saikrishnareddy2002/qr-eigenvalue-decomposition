`timescale 1ns/1ps
module svd_output #(parameter N=4)(
    input  wire [64*N-1:0]   eigenvalues,
    input  wire [64*N*N-1:0] V_flat,
    output wire [64*N-1:0]   sigma_flat,
    output wire [64*N*N-1:0] U_flat,
    output wire [64*N*N-1:0] SV_flat
);
genvar i,j;
generate
    for(i=0;i<N;i=i+1) begin:svd_i
        // sigma = |lambda|
        assign sigma_flat[i*64+:64]={1'b0,eigenvalues[i*64+62:i*64]};
        for(j=0;j<N;j=j+1) begin:svd_j
            // U[:,i] = V[:,i] if lambda>=0, else -V[:,i]
            assign U_flat[(j*N+i)*64+:64]=
                eigenvalues[i*64+63]?
                {~V_flat[(j*N+i)*64+63],V_flat[(j*N+i)*64+62:i*64+0]}:
                V_flat[(j*N+i)*64+:64];
            // SV = V always
            assign SV_flat[(j*N+i)*64+:64]=V_flat[(j*N+i)*64+:64];
        end
    end
endgenerate
endmodule
