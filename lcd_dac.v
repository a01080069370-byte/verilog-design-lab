// =====================================================================
//  lcd_dac.v  [week11_preE_postC]  - Text LCD 표시
// =====================================================================
// Text LCD 표시
//  윗줄 : IN:128 HEX:80  A
//  아랫줄 : 10000000  2.500V
module lcd_dac(clk, rst, value, ch, LCD_E, LCD_RS, LCD_RW, LCD_DATA);

input clk, rst;
input [7:0] value;
input ch;
output LCD_E;
output reg LCD_RS, LCD_RW;
output reg [7:0] LCD_DATA;

reg [6:0] cnt;                  // 초기화 단계 카운터
reg       init_done;
reg [5:0] k;                    // 반복 단계 0~33
reg [7:0] v;                    // 한 화면을 쓰는 동안 고정할 값
reg       c;

wire [17:0] mv_full = v * 10'd625;
wire [12:0] mv = mv_full[17:5];

function [7:0] dec;             // 숫자 -> ASCII
    input [3:0] n;
    dec = 8'h30 + n;
endfunction

function [7:0] hex;
    input [3:0] n;
    hex = (n < 10) ? (8'h30 + n) : (8'h37 + n);
endfunction

wire [127:0] line1 = {"IN:", dec(v / 100), dec((v / 10) % 10), dec(v % 10),
                      " HEX:", hex(v[7:4]), hex(v[3:0]), "  ", (c ? "B" : "A")};
wire [127:0] line2 = {(v[7] ? "1" : "0"), (v[6] ? "1" : "0"), (v[5] ? "1" : "0"), (v[4] ? "1" : "0"),
                      (v[3] ? "1" : "0"), (v[2] ? "1" : "0"), (v[1] ? "1" : "0"), (v[0] ? "1" : "0"),
                      "  ", dec(mv / 1000), ".", dec((mv / 100) % 10), dec((mv / 10) % 10), dec(mv % 10), "V"};

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        cnt <= 0; init_done <= 0; k <= 0; v <= 0; c <= 0;
        {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0001;          // 리셋 동안 Clear
    end
    else if(!init_done) begin
        cnt <= cnt + 1;
        case(cnt)
            70 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0011_1000;  // 8bit, 2줄
            71 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1100;  // 화면 ON, 커서 OFF
            72 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0110;  // 주소 +1
            73 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0001;  // Clear (1.52ms)
            76 : init_done <= 1;
            default : if(cnt > 73) {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1100;
        endcase
    end
    else begin
        k <= (k == 33) ? 0 : k + 1;
        if(k == 0) begin
            v <= value;  c <= ch;                                  // 새 값으로 갱신
            {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1000_0000;       // 윗줄 0번 칸
        end
        else if(k <= 16)
            {LCD_RS, LCD_RW, LCD_DATA} <= {2'b1_0, line1[8*(16-k) +: 8]};
        else if(k == 17)
            {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1100_0000;       // 아랫줄 0번 칸
        else
            {LCD_RS, LCD_RW, LCD_DATA} <= {2'b1_0, line2[8*(33-k) +: 8]};
    end
end

assign LCD_E = clk;

endmodule