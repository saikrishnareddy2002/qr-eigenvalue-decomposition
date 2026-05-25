`timescale 1ns/1ps
module fp64_addsub(
    input  wire        clk,
    input  wire [63:0] a, b,
    input  wire        sub,
    input  wire        start,
    output reg  [63:0] result,
    output reg         valid_out
);
`ifdef SIM_FAST
reg [63:0] a_r,b_r; reg sub_r,v1,v2;
initial begin valid_out=0;result=0;a_r=0;b_r=0;sub_r=0;v1=0;v2=0; end
always @(posedge clk) begin
    a_r<=a; b_r<=b; sub_r<=sub; v1<=start; v2<=v1;
    if(v1) begin
        if(sub_r) result<=$realtobits($bitstoreal(a_r)-$bitstoreal(b_r));
        else      result<=$realtobits($bitstoreal(a_r)+$bitstoreal(b_r));
    end
    valid_out<=v2;
end
`else
wire [63:0] ip_out; wire ip_valid,ar,br,opr;
reg [63:0] al,bl; reg sub_l,av,bv,opv;
initial begin valid_out=0;result=0;al=0;bl=0;sub_l=0;av=0;bv=0;opv=0; end
always @(posedge clk) begin
    if(start) begin al<=a;bl<=b;sub_l<=sub;av<=1;bv<=1;opv<=1; end
    else begin av<=0;bv<=0;opv<=0; end
end
floating_point_addsub u_ip(
    .aclk(clk),
    .s_axis_a_tvalid(av),.s_axis_a_tready(ar),.s_axis_a_tdata(al),
    .s_axis_b_tvalid(bv),.s_axis_b_tready(br),.s_axis_b_tdata(bl),
    .s_axis_operation_tvalid(opv),.s_axis_operation_tready(opr),
    .s_axis_operation_tdata({7'b0,sub_l}),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(ip_valid),.m_axis_result_tdata(ip_out)
);
always @(posedge clk) begin valid_out<=ip_valid; if(ip_valid) result<=ip_out; end
`endif
endmodule
