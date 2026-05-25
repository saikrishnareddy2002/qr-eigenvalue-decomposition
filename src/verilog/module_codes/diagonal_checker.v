`timescale 1ns/1ps
module diagonal_checker(
    input  wire        clk, rst, start,
    input  wire [63:0] d1, off, d2,
    input  wire [63:0] threshold,
    output reg         converged,
    output reg         done
);
localparam [1:0] IDLE=2'd0,COMP=2'd1,WAIT=2'd2,DONE=2'd3;
reg [1:0] state;
reg [63:0] cmp_a,cmp_b; reg cmp_start;
wire [7:0] cmp_result; wire cmp_valid;
fp64_cmp u_cmp(.clk(clk),.a(cmp_a),.b(cmp_b),.start(cmp_start),
               .result(cmp_result),.valid_out(cmp_valid));
always @(posedge clk or posedge rst) begin
    if(rst) begin state<=IDLE;converged<=0;done<=0;cmp_start<=0; end
    else begin
        cmp_start<=0; done<=0;
        case(state)
        IDLE: if(start) begin converged<=0; state<=COMP; end
        COMP: begin
            cmp_a<={1'b0,off[62:0]};
            cmp_b<=threshold;
            cmp_start<=1; state<=WAIT;
        end
        WAIT: if(cmp_valid) begin converged<=cmp_result[0]; state<=DONE; end
        DONE: begin done<=1; state<=IDLE; end
        default: state<=IDLE;
        endcase
    end
end
endmodule
