`timescale 1ns/1ps
module gram_schmidt #(parameter N=4)(
    input  wire              clk, rst, start,
    input  wire [64*N*N-1:0] A_flat,
    output reg  [64*N*N-1:0] Q_flat, R_flat,
    output reg               done
);
localparam [63:0] FP_ZERO=64'h0;
localparam [4:0]
    GS_IDLE=5'd0,  GS_INITV=5'd1,
    GS_DOTMUL=5'd2,GS_WDOTMUL=5'd3,GS_WDOTADD=5'd4,
    GS_STORERIJ=5'd5,
    GS_PROJMUL=5'd6,GS_WPROJMUL=5'd7,GS_WPROJSUB=5'd8,
    GS_NORMMUL=5'd9,GS_WNORMMUL=5'd10,GS_WNORMADD=5'd11,
    GS_SQRT=5'd12,GS_WSQRT=5'd13,
    GS_DIVQ=5'd14,GS_WDIVQ=5'd15,
    GS_DONE=5'd16;
reg [4:0] state;
reg [3:0] j_col, i_proj, row;
reg [64*N-1:0] v_vec;
reg [63:0] acc, rij_r, norm_r;
reg [63:0] mul_a, mul_b; reg mul_start;
reg [63:0] add_a, add_b; reg add_start, add_sub_sel;
reg [63:0] sqr_a;        reg sqr_start;
reg [63:0] div_a, div_b; reg div_start;
wire [63:0] mul_out,add_out,sqr_out,div_out;
wire        mul_valid,add_valid,sqr_valid,div_valid;
fp64_mul    u_mul (.clk(clk),.a(mul_a),.b(mul_b),.start(mul_start),
                   .result(mul_out),.valid_out(mul_valid));
fp64_addsub u_add (.clk(clk),.a(add_a),.b(add_b),.sub(add_sub_sel),
                   .start(add_start),.result(add_out),.valid_out(add_valid));
fp64_sqrt   u_sqrt(.clk(clk),.a(sqr_a),.start(sqr_start),
                   .result(sqr_out),.valid_out(sqr_valid));
fp64_div    u_div (.clk(clk),.a(div_a),.b(div_b),.start(div_start),
                   .result(div_out),.valid_out(div_valid));
wire [63:0] v_row = v_vec[row*64+:64];
integer ii;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        state<=GS_IDLE; done<=0; j_col<=0; i_proj<=0; row<=0;
        acc<=FP_ZERO; rij_r<=FP_ZERO; norm_r<=FP_ZERO;
        v_vec<={64*N{1'b0}};
        mul_start<=0; add_start<=0; sqr_start<=0; div_start<=0; add_sub_sel<=0;
        Q_flat<={64*N*N{1'b0}}; R_flat<={64*N*N{1'b0}};
    end else begin
        mul_start<=0; add_start<=0; sqr_start<=0; div_start<=0; done<=0;
        case(state)
        GS_IDLE: if(start) begin j_col<=0; state<=GS_INITV; end
        GS_INITV: begin
            for(ii=0;ii<N;ii=ii+1)
                v_vec[ii*64+:64]<=A_flat[(ii*N+j_col)*64+:64];
            i_proj<=0; acc<=FP_ZERO; row<=0;
            state<=(j_col==4'd0)?GS_NORMMUL:GS_DOTMUL;
        end
        GS_DOTMUL: begin
            mul_a<=Q_flat[(row*N+i_proj)*64+:64];
            mul_b<=v_row; mul_start<=1; state<=GS_WDOTMUL;
        end
        GS_WDOTMUL: if(mul_valid) begin
            add_a<=acc; add_b<=mul_out; add_sub_sel<=0;
            add_start<=1; state<=GS_WDOTADD;
        end
        GS_WDOTADD: if(add_valid) begin
            acc<=add_out;
            if(row<N-1) begin row<=row+1; state<=GS_DOTMUL; end
            else begin rij_r<=add_out; state<=GS_STORERIJ; end
        end
        GS_STORERIJ: begin
            R_flat[(i_proj*N+j_col)*64+:64]<=rij_r;
            acc<=FP_ZERO; row<=0; state<=GS_PROJMUL;
        end
        GS_PROJMUL: begin
            mul_a<=rij_r;
            mul_b<=Q_flat[(row*N+i_proj)*64+:64];
            mul_start<=1; state<=GS_WPROJMUL;
        end
        GS_WPROJMUL: if(mul_valid) begin
            add_a<=v_row; add_b<=mul_out; add_sub_sel<=1;
            add_start<=1; state<=GS_WPROJSUB;
        end
        GS_WPROJSUB: if(add_valid) begin
            v_vec[row*64+:64]<=add_out;
            if(row<N-1) begin row<=row+1; state<=GS_PROJMUL; end
            else begin
                i_proj<=i_proj+1; row<=0; acc<=FP_ZERO;
                state<=(i_proj<j_col-1)?GS_DOTMUL:GS_NORMMUL;
            end
        end
        GS_NORMMUL: begin
            mul_a<=v_row; mul_b<=v_row;
            mul_start<=1; state<=GS_WNORMMUL;
        end
        GS_WNORMMUL: if(mul_valid) begin
            add_a<=acc; add_b<=mul_out; add_sub_sel<=0;
            add_start<=1; state<=GS_WNORMADD;
        end
        GS_WNORMADD: if(add_valid) begin
            acc<=add_out;
            if(row<N-1) begin row<=row+1; state<=GS_NORMMUL; end
            else state<=GS_SQRT;
        end
        GS_SQRT:  begin sqr_a<=acc; sqr_start<=1; state<=GS_WSQRT; end
        GS_WSQRT: if(sqr_valid) begin
            norm_r<=sqr_out;
            R_flat[(j_col*N+j_col)*64+:64]<=sqr_out;
            row<=0; state<=GS_DIVQ;
        end
        GS_DIVQ: begin
            div_a<=v_row; div_b<=norm_r;
            div_start<=1; state<=GS_WDIVQ;
        end
        GS_WDIVQ: if(div_valid) begin
            Q_flat[(row*N+j_col)*64+:64]<=div_out;
            if(row<N-1) begin row<=row+1; state<=GS_DIVQ; end
            else begin
                if(j_col<N-1) begin j_col<=j_col+1; state<=GS_INITV; end
                else state<=GS_DONE;
            end
        end
        GS_DONE: begin done<=1; state<=GS_IDLE; end
        default:  state<=GS_IDLE;
        endcase
    end
end
endmodule
