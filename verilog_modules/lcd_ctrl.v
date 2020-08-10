
//////////////////////////////////////////////////////////////////////////////////
// Company       : 
// Engineer      : Johnzchgrd
// 
// Create Date   : 2020-08-07 18:21:52
// Design Name   : 
// File Name     : lcd_ctrl.v
// Project Name  : 
// Target Devices: Tang Nano(GW1N-LV1QN48C5/I4)
// Tool Versions : 
// Description   : a generic LCD display controller.
// 
// Dependencies  : -
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lcd_ctrl (
  input        clk  , // <=25.2MHz, tested 10.2MHz~24MHz, recommended <20MHz for more stable display
  input        rst  ,
  output       DE   , // data enable
  output       hsync,
  output       vsync,
  output [9:0] h_cnt,
  output [9:0] v_cnt
);

/* timing parameters */
parameter pixel_height = 'd272;
parameter pixel_width  = 'd480;
/* copied from szg's lecture */
localparam v_p = 'd2         ;
localparam v_q = 'd33        ;
localparam v_r = pixel_height;
localparam v_s = 'd10        ;

localparam h_b = 'd77       ;
localparam h_c = 'd53       ;
localparam h_d = pixel_width;
localparam h_e = 'd24       ;

/* extreme situation also works... no idea why...
localparam v_p = 'd1         ;
localparam v_q = 'd0         ;
localparam v_r = pixel_height;
localparam v_s = 'd1         ;

localparam h_b = 'd1        ;
localparam h_c = 'd0        ;
localparam h_d = pixel_width;
localparam h_e = 'd1        ;
*/

localparam v_p_q     = v_p     + v_q;
localparam v_p_q_r   = v_p_q   + v_r;
localparam v_p_q_r_s = v_p_q_r + v_s;
localparam h_b_c     = h_b     + h_c;
localparam h_b_c_d   = h_b_c   + h_d;
localparam h_b_c_d_e = h_b_c_d + h_e;

/* nets definitions */
reg  [9:0] pcnt_h ; // pixel counts
reg  [9:0] pcnt_v ;
wire       h_valid;
wire       v_valid;


always@(posedge clk or posedge rst) begin
  if(rst) begin
    pcnt_v <= 'd1;
    pcnt_h <= 'd1;
  end else begin
    pcnt_h <= pcnt_h == h_b_c_d_e ? 'd1 : pcnt_h + 'd1;
    pcnt_v <= pcnt_h == h_b_c_d_e ?
      (pcnt_v == v_p_q_r_s ? 'd1 : pcnt_v + 'd1) :
      pcnt_v;
  end
end

assign h_valid = (pcnt_h > h_b_c && pcnt_h <= h_b_c_d) ? 1'b1 :
                 1'b0;
assign v_valid = (pcnt_v > v_p_q && pcnt_v <= v_p_q_r) ? 1'b1 : 
                 1'b0; 
assign DE = h_valid & v_valid;

/* generate VSYNC & HSYNC */

assign hsync = (pcnt_h <= h_b ? 1'b1 : 1'b0);
assign vsync = (pcnt_v <= v_p ? 1'b1 : 1'b0);

assign h_cnt = h_valid ? pcnt_h - h_b_c : 'd0;
assign v_cnt = v_valid ? pcnt_v - v_p_q : 'd0;
 
endmodule
