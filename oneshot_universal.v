// =====================================================================
//  oneshot_universal.v  - 원샷 트리거 (교안 6쪽)
//  버튼이 0 -> 1 로 바뀌는 순간에만 1클럭 동안 1을 출력한다.
// =====================================================================
module oneshot_universal(clk, rst, btn, btn_trig);

parameter WIDTH = 1;
input clk, rst;
input [WIDTH-1:0] btn;
reg [WIDTH-1:0] btn_reg;
output reg [WIDTH-1:0] btn_trig;

always @(negedge rst or posedge clk) begin
    if(!rst) begin
        btn_reg  <= {WIDTH{1'b0}};
        btn_trig <= {WIDTH{1'b0}};
    end
    else begin
        btn_reg  <= btn;
        btn_trig <= btn & ~btn_reg;
    end
end

endmodule