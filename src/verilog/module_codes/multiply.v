`timescale 1ns/1ps
module multiply #(parameter N=4)(
    input  wire              clk, rst, start,
    input  wire [64*N*N-1:0] A_flat, B_flat,
    output reg  [64*N*N-1:0] C_flat,
    output reg               done
);
localparam [2:0] IDLE=3'd0,MUL=3'd1,WMUL=3'd2,ADD=3'd3,
                 WADD=3'd4,NEXT=3'd5,DONE=3'd6;
reg [2:0] state;
reg [3:0] i,j,k;
reg [63:0] acc,prod_r;
reg [63:0] mul_a,mul_b; reg mul_start;
reg [63:0] add_a,add_b; reg add_start;
wire [63:0] mul_out,add_out; wire mul_valid,add_valid;
fp64_mul    u_mul(.clk(clk),.a(mul_a),.b(mul_b),.start(mul_start),
                  .result(mul_out),.valid_out(mul_valid));
fp64_addsub u_add(.clk(clk),.a(add_a),.b(add_b),.sub(1'b0),
                  .start(add_start),.result(add_out),.valid_out(add_valid));
always @(posedge clk or posedge rst) begin
    if(rst) begin
        state<=IDLE;done<=0;i<=0;j<=0;k<=0;
        acc<=0;prod_r<=0;mul_start<=0;add_start<=0;
        C_flat<={64*N*N{1'b0}};
    end else begin
        mul_start<=0; add_start<=0; done<=0;
        case(state)
        IDLE: if(start) begin i<=0;j<=0;k<=0;acc<=0;state<=MUL; end
        MUL:  begin mul_a<=A_flat[(i*N+k)*64+:64];
                    mul_b<=B_flat[(k*N+j)*64+:64];
                    mul_start<=1; state<=WMUL; end
        WMUL: if(mul_valid) begin prod_r<=mul_out; state<=ADD; end
        ADD:  begin add_a<=acc;add_b<=prod_r;add_start<=1;state<=WADD; end
        WADD: if(add_valid) begin acc<=add_out; state<=NEXT; end
        NEXT: begin
            if(k<N-1) begin k<=k+1; state<=MUL; end
            else begin
                C_flat[(i*N+j)*64+:64]<=acc; acc<=0; k<=0;
                if(j<N-1) begin j<=j+1; state<=MUL; end
                else begin j<=0;
                    if(i<N-1) begin i<=i+1; state<=MUL; end
                    else state<=DONE;
                end
            end
        end
        DONE: begin done<=1; state<=IDLE; end
        default: state<=IDLE;
        endcase
    end
end
endmodule
