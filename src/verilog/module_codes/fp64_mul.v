`timescale 1ns/1ps
module fp64_mul(
    input  wire        clk,
    input  wire [63:0] a, b,
    input  wire        start,
    output reg  [63:0] result,
    output reg         valid_out
);
`ifdef SIM_FAST
reg [63:0] a_r,b_r; reg v1,v2;
initial begin valid_out=0;result=0;a_r=0;b_r=0;v1=0;v2=0; end
always @(posedge clk) begin
    a_r<=a; b_r<=b; v1<=start; v2<=v1;
    if(v1) result<=$realtobits($bitstoreal(a_r)*$bitstoreal(b_r));
    valid_out<=v2;
end
`else
wire [63:0] ip_out; wire ip_valid,ar,br;
reg [63:0] al,bl; reg av,bv;
initial begin valid_out=0;result=0;al=0;bl=0;av=0;bv=0; end
always @(posedge clk) begin
    if(start) begin al<=a;bl<=b;av<=1;bv<=1; end
    else begin av<=0;bv<=0; end
end
floating_point_mul u_ip(
    .aclk(clk),
    .s_axis_a_tvalid(av),.s_axis_a_tready(ar),.s_axis_a_tdata(al),
    .s_axis_b_tvalid(bv),.s_axis_b_tready(br),.s_axis_b_tdata(bl),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(ip_valid),.m_axis_result_tdata(ip_out)
);
always @(posedge clk) begin valid_out<=ip_valid; if(ip_valid) result<=ip_out; end
`endif
endmodule
