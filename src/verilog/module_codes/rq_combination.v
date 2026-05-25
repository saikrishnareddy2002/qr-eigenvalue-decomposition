`timescale 1ns/1ps
module rq_combination #(parameter N=4)(
    input  wire              clk, rst, start,
    input  wire [64*N*N-1:0] R_flat, Q_flat,
    output reg  [64*N*N-1:0] A_next_flat,
    output reg               done
);
localparam [1:0] IDLE=2'd0,RUN=2'd1,DONE=2'd2;
reg [1:0] state;
reg mul_start; wire mul_done; wire [64*N*N-1:0] mul_out;
multiply #(.N(N)) u_mul(
    .clk(clk),.rst(rst),.start(mul_start),
    .A_flat(R_flat),.B_flat(Q_flat),.C_flat(mul_out),.done(mul_done)
);
always @(posedge clk or posedge rst) begin
    if(rst) begin state<=IDLE;done<=0;mul_start<=0;A_next_flat<={64*N*N{1'b0}}; end
    else begin
        mul_start<=0; done<=0;
        case(state)
        IDLE: if(start) begin mul_start<=1; state<=RUN; end
        RUN:  if(mul_done) begin A_next_flat<=mul_out; state<=DONE; end
        DONE: begin done<=1; state<=IDLE; end
        default: state<=IDLE;
        endcase
    end
end
endmodule
