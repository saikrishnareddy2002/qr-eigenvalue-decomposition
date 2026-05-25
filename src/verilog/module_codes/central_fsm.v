`timescale 1ns/1ps
module central_fsm(
    input  wire clk, rst, start,
    output reg  qr_start, input wire qr_done,
    output reg  rq_start, input wire rq_done,
    output reg  ev_start, input wire ev_done,
    output reg  check_start, input wire check_done,
    input  wire converged, output reg done
);
localparam [2:0] IDLE=3'd0,S_QR=3'd1,S_RQ=3'd2,S_EV=3'd3,
                 S_CHK=3'd4,S_DEC=3'd5,S_DONE=3'd6;
reg [2:0] state;
reg [7:0] iter;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        state<=IDLE; done<=0; iter<=8'd0;
        qr_start<=0; rq_start<=0; ev_start<=0; check_start<=0;
    end else begin
        qr_start<=0; rq_start<=0; ev_start<=0; check_start<=0; done<=0;
        case(state)
        IDLE:  if(start) begin iter<=8'd0; state<=S_QR; end
        S_QR:  begin qr_start<=1; state<=S_RQ; end
        S_RQ:  if(qr_done)  begin rq_start<=1;    state<=S_EV;  end
        S_EV:  if(rq_done)  begin ev_start<=1;    state<=S_CHK; end
        S_CHK: if(ev_done)  begin check_start<=1; state<=S_DEC; end
        S_DEC: if(check_done) begin
            if(converged || iter==8'd99)
                state<=S_DONE;
            else begin
                iter<=iter+8'd1;
                state<=S_QR;
            end
        end
        S_DONE: begin done<=1; state<=S_DONE; end
        default: state<=IDLE;
        endcase
    end
end
endmodule
