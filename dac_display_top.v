// =====================================================================
//  dac_display_top.v  [week11_preE_postC]  - 예비 E 최상위 모듈
// =====================================================================
// 예비보고서 E : DAC 디지털 입력을 7-segment array와 Text LCD로 표시
module dac_display_top(clk, rst, btn, add_sel,
                       dac_csn, dac_ldacn, dac_wrn, dac_a_b, dac_d, led_out,
                       seg_data, seg_com, LCD_E, LCD_RS, LCD_RW, LCD_DATA);

input clk, rst;
input [5:0] btn;
input add_sel;
output dac_csn, dac_ldacn, dac_wrn, dac_a_b;
output [7:0] dac_d;
output [7:0] led_out;
output [7:0] seg_data, seg_com;
output LCD_E, LCD_RS, LCD_RW;
output [7:0] LCD_DATA;

DAC      U0(.clk(clk), .rst(rst), .btn(btn), .add_sel(add_sel),
            .dac_csn(dac_csn), .dac_ldacn(dac_ldacn), .dac_wrn(dac_wrn), .dac_a_b(dac_a_b),
            .dac_d(dac_d), .led_out(led_out));

seg_dac  U1(.clk(clk), .rst(rst), .value(dac_d), .ch(add_sel),
            .seg_data(seg_data), .seg_com(seg_com));

lcd_dac  U2(.clk(clk), .rst(rst), .value(dac_d), .ch(add_sel),
            .LCD_E(LCD_E), .LCD_RS(LCD_RS), .LCD_RW(LCD_RW), .LCD_DATA(LCD_DATA));

endmodule