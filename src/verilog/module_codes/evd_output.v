`timescale 1ns/1ps
module evd_output #(parameter N=4)(
    input  wire              clk, rst, start,
    input  wire [64*N*N-1:0] Q_iter,
    output reg  [64*N*N-1:0] V_flat,
    output reg               done
);
localparam FP_ZERO=64'h0, FP_ONE=64'h3FF0000000000000;
localparam [1:0] IDLE=2'd0,RUN=2'd1,DONE=2'd2;
reg [1:0] state;
reg mul_start; wire mul_done; wire [64*N*N-1:0] mul_out;
multiply #(.N(N)) u_mul(
    .clk(clk),.rst(rst),.start(mul_start),
    .A_flat(V_flat),.B_flat(Q_iter),.C_flat(mul_out),.done(mul_done)
);
integer ri,ci;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        state<=IDLE; done<=0; mul_start<=0;
        for(ri=0;ri<N;ri=ri+1)
            for(ci=0;ci<N;ci=ci+1)
                V_flat[(ri*N+ci)*64+:64]<=(ri==ci)?FP_ONE:FP_ZERO;
    end else begin
        mul_start<=0; done<=0;
        case(state)
        IDLE: if(start) begin mul_start<=1; state<=RUN; end
        RUN:  if(mul_done) begin V_flat<=mul_out; state<=DONE; end
        DONE: begin done<=1; state<=IDLE; end
        default: state<=IDLE;
        endcase
    end
end
endmodule
