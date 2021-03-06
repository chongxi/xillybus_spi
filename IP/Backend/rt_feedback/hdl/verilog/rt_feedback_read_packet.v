// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2016.1
// Copyright (C) 1986-2016 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module rt_feedback_read_packet (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        fet_packet_spk_id_V_dout,
        fet_packet_spk_id_V_empty_n,
        fet_packet_spk_id_V_read,
        target_unit_id_V,
        ap_return,
        fet_packet_spk_id_V_blk_n
);

parameter    ap_ST_st1_fsm_0 = 7'b1;
parameter    ap_ST_st2_fsm_1 = 7'b10;
parameter    ap_ST_st3_fsm_2 = 7'b100;
parameter    ap_ST_st4_fsm_3 = 7'b1000;
parameter    ap_ST_st5_fsm_4 = 7'b10000;
parameter    ap_ST_st6_fsm_5 = 7'b100000;
parameter    ap_ST_st7_fsm_6 = 7'b1000000;
parameter    ap_const_lv32_0 = 32'b00000000000000000000000000000000;
parameter    ap_const_lv32_1 = 32'b1;
parameter    ap_const_lv32_2 = 32'b10;
parameter    ap_const_lv32_3 = 32'b11;
parameter    ap_const_lv32_4 = 32'b100;
parameter    ap_const_lv32_5 = 32'b101;
parameter    ap_const_lv32_6 = 32'b110;
parameter    ap_const_lv16_0 = 16'b0000000000000000;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [31:0] fet_packet_spk_id_V_dout;
input   fet_packet_spk_id_V_empty_n;
output   fet_packet_spk_id_V_read;
input  [15:0] target_unit_id_V;
output  [0:0] ap_return;
output   fet_packet_spk_id_V_blk_n;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg fet_packet_spk_id_V_read;
reg fet_packet_spk_id_V_blk_n;

(* fsm_encoding = "none" *) reg   [6:0] ap_CS_fsm;
reg    ap_sig_cseq_ST_st1_fsm_0;
reg    ap_sig_24;
reg    ap_sig_cseq_ST_st2_fsm_1;
reg    ap_sig_44;
reg    ap_sig_cseq_ST_st3_fsm_2;
reg    ap_sig_52;
reg    ap_sig_cseq_ST_st4_fsm_3;
reg    ap_sig_60;
reg    ap_sig_cseq_ST_st5_fsm_4;
reg    ap_sig_68;
reg    ap_sig_cseq_ST_st6_fsm_5;
reg    ap_sig_76;
reg    ap_sig_cseq_ST_st7_fsm_6;
reg    ap_sig_84;
reg   [15:0] ap_reg_ptbuf_target_unit_id_V;
reg    ap_sig_90;
wire   [31:0] tmp_fu_36_p1;
wire   [0:0] notrhs_fu_46_p2;
wire   [0:0] notlhs_fu_40_p2;
reg   [6:0] ap_NS_fsm;

// power-on initialization
initial begin
#0 ap_CS_fsm = 7'b1;
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_st1_fsm_0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_sig_cseq_ST_st1_fsm_0) & ~ap_sig_90)) begin
        ap_reg_ptbuf_target_unit_id_V <= target_unit_id_V;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_start) & (1'b1 == ap_sig_cseq_ST_st1_fsm_0)) | ((1'b1 == ap_sig_cseq_ST_st7_fsm_6) & ~(fet_packet_spk_id_V_empty_n == 1'b0)))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_start) & (1'b1 == ap_sig_cseq_ST_st1_fsm_0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_sig_cseq_ST_st7_fsm_6) & ~(fet_packet_spk_id_V_empty_n == 1'b0))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if (ap_sig_24) begin
        ap_sig_cseq_ST_st1_fsm_0 = 1'b1;
    end else begin
        ap_sig_cseq_ST_st1_fsm_0 = 1'b0;
    end
end

always @ (*) begin
    if (ap_sig_44) begin
        ap_sig_cseq_ST_st2_fsm_1 = 1'b1;
    end else begin
        ap_sig_cseq_ST_st2_fsm_1 = 1'b0;
    end
end

always @ (*) begin
    if (ap_sig_52) begin
        ap_sig_cseq_ST_st3_fsm_2 = 1'b1;
    end else begin
        ap_sig_cseq_ST_st3_fsm_2 = 1'b0;
    end
end

always @ (*) begin
    if (ap_sig_60) begin
        ap_sig_cseq_ST_st4_fsm_3 = 1'b1;
    end else begin
        ap_sig_cseq_ST_st4_fsm_3 = 1'b0;
    end
end

always @ (*) begin
    if (ap_sig_68) begin
        ap_sig_cseq_ST_st5_fsm_4 = 1'b1;
    end else begin
        ap_sig_cseq_ST_st5_fsm_4 = 1'b0;
    end
end

always @ (*) begin
    if (ap_sig_76) begin
        ap_sig_cseq_ST_st6_fsm_5 = 1'b1;
    end else begin
        ap_sig_cseq_ST_st6_fsm_5 = 1'b0;
    end
end

always @ (*) begin
    if (ap_sig_84) begin
        ap_sig_cseq_ST_st7_fsm_6 = 1'b1;
    end else begin
        ap_sig_cseq_ST_st7_fsm_6 = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_sig_cseq_ST_st1_fsm_0) & ~(ap_start == 1'b0)) | (1'b1 == ap_sig_cseq_ST_st2_fsm_1) | (1'b1 == ap_sig_cseq_ST_st3_fsm_2) | (1'b1 == ap_sig_cseq_ST_st4_fsm_3) | (1'b1 == ap_sig_cseq_ST_st5_fsm_4) | (1'b1 == ap_sig_cseq_ST_st6_fsm_5) | (1'b1 == ap_sig_cseq_ST_st7_fsm_6))) begin
        fet_packet_spk_id_V_blk_n = fet_packet_spk_id_V_empty_n;
    end else begin
        fet_packet_spk_id_V_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((((1'b1 == ap_sig_cseq_ST_st1_fsm_0) & ~ap_sig_90) | ((1'b1 == ap_sig_cseq_ST_st2_fsm_1) & ~(fet_packet_spk_id_V_empty_n == 1'b0)) | ((1'b1 == ap_sig_cseq_ST_st3_fsm_2) & ~(fet_packet_spk_id_V_empty_n == 1'b0)) | ((1'b1 == ap_sig_cseq_ST_st4_fsm_3) & ~(fet_packet_spk_id_V_empty_n == 1'b0)) | ((1'b1 == ap_sig_cseq_ST_st5_fsm_4) & ~(fet_packet_spk_id_V_empty_n == 1'b0)) | ((1'b1 == ap_sig_cseq_ST_st6_fsm_5) & ~(fet_packet_spk_id_V_empty_n == 1'b0)) | ((1'b1 == ap_sig_cseq_ST_st7_fsm_6) & ~(fet_packet_spk_id_V_empty_n == 1'b0)))) begin
        fet_packet_spk_id_V_read = 1'b1;
    end else begin
        fet_packet_spk_id_V_read = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_st1_fsm_0 : begin
            if (~ap_sig_90) begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end else begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end
        end
        ap_ST_st2_fsm_1 : begin
            if (~(fet_packet_spk_id_V_empty_n == 1'b0)) begin
                ap_NS_fsm = ap_ST_st3_fsm_2;
            end else begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end
        end
        ap_ST_st3_fsm_2 : begin
            if (~(fet_packet_spk_id_V_empty_n == 1'b0)) begin
                ap_NS_fsm = ap_ST_st4_fsm_3;
            end else begin
                ap_NS_fsm = ap_ST_st3_fsm_2;
            end
        end
        ap_ST_st4_fsm_3 : begin
            if (~(fet_packet_spk_id_V_empty_n == 1'b0)) begin
                ap_NS_fsm = ap_ST_st5_fsm_4;
            end else begin
                ap_NS_fsm = ap_ST_st4_fsm_3;
            end
        end
        ap_ST_st5_fsm_4 : begin
            if (~(fet_packet_spk_id_V_empty_n == 1'b0)) begin
                ap_NS_fsm = ap_ST_st6_fsm_5;
            end else begin
                ap_NS_fsm = ap_ST_st5_fsm_4;
            end
        end
        ap_ST_st6_fsm_5 : begin
            if (~(fet_packet_spk_id_V_empty_n == 1'b0)) begin
                ap_NS_fsm = ap_ST_st7_fsm_6;
            end else begin
                ap_NS_fsm = ap_ST_st6_fsm_5;
            end
        end
        ap_ST_st7_fsm_6 : begin
            if (~(fet_packet_spk_id_V_empty_n == 1'b0)) begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end else begin
                ap_NS_fsm = ap_ST_st7_fsm_6;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_return = (notrhs_fu_46_p2 & notlhs_fu_40_p2);

always @ (*) begin
    ap_sig_24 = (ap_CS_fsm[ap_const_lv32_0] == 1'b1);
end

always @ (*) begin
    ap_sig_44 = (1'b1 == ap_CS_fsm[ap_const_lv32_1]);
end

always @ (*) begin
    ap_sig_52 = (1'b1 == ap_CS_fsm[ap_const_lv32_2]);
end

always @ (*) begin
    ap_sig_60 = (1'b1 == ap_CS_fsm[ap_const_lv32_3]);
end

always @ (*) begin
    ap_sig_68 = (1'b1 == ap_CS_fsm[ap_const_lv32_4]);
end

always @ (*) begin
    ap_sig_76 = (1'b1 == ap_CS_fsm[ap_const_lv32_5]);
end

always @ (*) begin
    ap_sig_84 = (1'b1 == ap_CS_fsm[ap_const_lv32_6]);
end

always @ (*) begin
    ap_sig_90 = ((ap_start == 1'b0) | (fet_packet_spk_id_V_empty_n == 1'b0));
end

assign notlhs_fu_40_p2 = ((fet_packet_spk_id_V_dout == tmp_fu_36_p1) ? 1'b1 : 1'b0);

assign notrhs_fu_46_p2 = ((ap_reg_ptbuf_target_unit_id_V != ap_const_lv16_0) ? 1'b1 : 1'b0);

assign tmp_fu_36_p1 = ap_reg_ptbuf_target_unit_id_V;

endmodule //rt_feedback_read_packet
