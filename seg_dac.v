// =====================================================================
//  seg_dac.v  [week11_preE_postC]  - 7-segment array 표시
// =====================================================================
// 8자리 7-segment array 표시 : [ch] [ ] [백][십][일] [V.][0.1V][0.01V]
//  예) A 128 2.50
module seg_dac(clk, rst, value, ch, seg_data, seg_com);

input clk, rst;
input [7:0] value;              // DAC 디지털 입력 (0~255)
input ch;                       // 0 = 출력 A, 1 = 출력 B
output reg [7:0] seg_data;      // {A,B,C,D,E,F,G,DP}, 1 = 켜짐
output reg [7:0] seg_com;       // [0]=S0(왼쪽) ~ [7]=S7(오른쪽), 0 = 선택

reg [2:0] pos;                  // 지금 켜는 자리 (0 = 왼쪽)

// 전압(mV) = value x 5000 / 256 = value x 625 / 32
wire [17:0] mv_full = value * 10'd625;
wire [12:0] mv = mv_full[17:5];

wire [3:0] d100 = value / 100;
wire [3:0] d10  = (value / 10) % 10;
wire [3:0] d1   = value % 10;
wire [3:0] v1   = mv / 1000;
wire [3:0] v01  = (mv / 100) % 10;
wire [3:0] v001 = (mv / 10) % 10;

function [7:0] num;
    input [3:0] n;
    case(n)
        0 : num = 8'b11111100;
        1 : num = 8'b01100000;
        2 : num = 8'b11011010;
        3 : num = 8'b11110010;
        4 : num = 8'b01100110;
        5 : num = 8'b10110110;
        6 : num = 8'b10111110;
        7 : num = 8'b11100000;
        8 : num = 8'b11111110;
        9 : num = 8'b11110110;
        default : num = 8'b00000000;
    endcase
endfunction

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        pos      <= 0;
        seg_com  <= 8'b1111_1111;
        seg_data <= 8'b0000_0000;
    end
    else begin
        pos     <= pos + 1;
        seg_com <= ~(8'b0000_0001 << pos);
        case(pos)
            0 : seg_data <= ch ? 8'b00111110 : 8'b11101110;   // b 또는 A
            1 : seg_data <= 8'b00000000;                      // 빈칸
            2 : seg_data <= num(d100);
            3 : seg_data <= num(d10);
            4 : seg_data <= num(d1);
            5 : seg_data <= num(v1) | 8'b00000001;            // 소수점
            6 : seg_data <= num(v01);
            7 : seg_data <= num(v001);
        endcase
    end
end

endmodule