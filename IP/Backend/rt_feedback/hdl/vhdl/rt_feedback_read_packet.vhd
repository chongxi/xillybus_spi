-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2016.1
-- Copyright (C) 1986-2016 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rt_feedback_read_packet is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    fet_packet_spk_id_V_dout : IN STD_LOGIC_VECTOR (31 downto 0);
    fet_packet_spk_id_V_empty_n : IN STD_LOGIC;
    fet_packet_spk_id_V_read : OUT STD_LOGIC;
    target_unit_id_V : IN STD_LOGIC_VECTOR (15 downto 0);
    ap_return : OUT STD_LOGIC_VECTOR (0 downto 0);
    fet_packet_spk_id_V_blk_n : OUT STD_LOGIC );
end;


architecture behav of rt_feedback_read_packet is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_st1_fsm_0 : STD_LOGIC_VECTOR (6 downto 0) := "0000001";
    constant ap_ST_st2_fsm_1 : STD_LOGIC_VECTOR (6 downto 0) := "0000010";
    constant ap_ST_st3_fsm_2 : STD_LOGIC_VECTOR (6 downto 0) := "0000100";
    constant ap_ST_st4_fsm_3 : STD_LOGIC_VECTOR (6 downto 0) := "0001000";
    constant ap_ST_st5_fsm_4 : STD_LOGIC_VECTOR (6 downto 0) := "0010000";
    constant ap_ST_st6_fsm_5 : STD_LOGIC_VECTOR (6 downto 0) := "0100000";
    constant ap_ST_st7_fsm_6 : STD_LOGIC_VECTOR (6 downto 0) := "1000000";
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";
    constant ap_const_lv32_3 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000011";
    constant ap_const_lv32_4 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000100";
    constant ap_const_lv32_5 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000101";
    constant ap_const_lv32_6 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000110";
    constant ap_const_lv16_0 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";

    signal ap_CS_fsm : STD_LOGIC_VECTOR (6 downto 0) := "0000001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_sig_cseq_ST_st1_fsm_0 : STD_LOGIC;
    signal ap_sig_24 : BOOLEAN;
    signal ap_sig_cseq_ST_st2_fsm_1 : STD_LOGIC;
    signal ap_sig_44 : BOOLEAN;
    signal ap_sig_cseq_ST_st3_fsm_2 : STD_LOGIC;
    signal ap_sig_52 : BOOLEAN;
    signal ap_sig_cseq_ST_st4_fsm_3 : STD_LOGIC;
    signal ap_sig_60 : BOOLEAN;
    signal ap_sig_cseq_ST_st5_fsm_4 : STD_LOGIC;
    signal ap_sig_68 : BOOLEAN;
    signal ap_sig_cseq_ST_st6_fsm_5 : STD_LOGIC;
    signal ap_sig_76 : BOOLEAN;
    signal ap_sig_cseq_ST_st7_fsm_6 : STD_LOGIC;
    signal ap_sig_84 : BOOLEAN;
    signal ap_reg_ptbuf_target_unit_id_V : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_sig_90 : BOOLEAN;
    signal tmp_fu_36_p1 : STD_LOGIC_VECTOR (31 downto 0);
    signal notrhs_fu_46_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal notlhs_fu_40_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_NS_fsm : STD_LOGIC_VECTOR (6 downto 0);


begin




    ap_CS_fsm_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_CS_fsm <= ap_ST_st1_fsm_0;
            else
                ap_CS_fsm <= ap_NS_fsm;
            end if;
        end if;
    end process;

    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_logic_1 = ap_sig_cseq_ST_st1_fsm_0) and not(ap_sig_90))) then
                ap_reg_ptbuf_target_unit_id_V <= target_unit_id_V;
            end if;
        end if;
    end process;

    ap_NS_fsm_assign_proc : process (ap_CS_fsm, fet_packet_spk_id_V_empty_n, ap_sig_90)
    begin
        case ap_CS_fsm is
            when ap_ST_st1_fsm_0 => 
                if (not(ap_sig_90)) then
                    ap_NS_fsm <= ap_ST_st2_fsm_1;
                else
                    ap_NS_fsm <= ap_ST_st1_fsm_0;
                end if;
            when ap_ST_st2_fsm_1 => 
                if (not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) then
                    ap_NS_fsm <= ap_ST_st3_fsm_2;
                else
                    ap_NS_fsm <= ap_ST_st2_fsm_1;
                end if;
            when ap_ST_st3_fsm_2 => 
                if (not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) then
                    ap_NS_fsm <= ap_ST_st4_fsm_3;
                else
                    ap_NS_fsm <= ap_ST_st3_fsm_2;
                end if;
            when ap_ST_st4_fsm_3 => 
                if (not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) then
                    ap_NS_fsm <= ap_ST_st5_fsm_4;
                else
                    ap_NS_fsm <= ap_ST_st4_fsm_3;
                end if;
            when ap_ST_st5_fsm_4 => 
                if (not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) then
                    ap_NS_fsm <= ap_ST_st6_fsm_5;
                else
                    ap_NS_fsm <= ap_ST_st5_fsm_4;
                end if;
            when ap_ST_st6_fsm_5 => 
                if (not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) then
                    ap_NS_fsm <= ap_ST_st7_fsm_6;
                else
                    ap_NS_fsm <= ap_ST_st6_fsm_5;
                end if;
            when ap_ST_st7_fsm_6 => 
                if (not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) then
                    ap_NS_fsm <= ap_ST_st1_fsm_0;
                else
                    ap_NS_fsm <= ap_ST_st7_fsm_6;
                end if;
            when others =>  
                ap_NS_fsm <= "XXXXXXX";
        end case;
    end process;

    ap_done_assign_proc : process(ap_start, ap_sig_cseq_ST_st1_fsm_0, fet_packet_spk_id_V_empty_n, ap_sig_cseq_ST_st7_fsm_6)
    begin
        if ((((ap_const_logic_0 = ap_start) and (ap_const_logic_1 = ap_sig_cseq_ST_st1_fsm_0)) or ((ap_const_logic_1 = ap_sig_cseq_ST_st7_fsm_6) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))))) then 
            ap_done <= ap_const_logic_1;
        else 
            ap_done <= ap_const_logic_0;
        end if; 
    end process;


    ap_idle_assign_proc : process(ap_start, ap_sig_cseq_ST_st1_fsm_0)
    begin
        if (((ap_const_logic_0 = ap_start) and (ap_const_logic_1 = ap_sig_cseq_ST_st1_fsm_0))) then 
            ap_idle <= ap_const_logic_1;
        else 
            ap_idle <= ap_const_logic_0;
        end if; 
    end process;


    ap_ready_assign_proc : process(fet_packet_spk_id_V_empty_n, ap_sig_cseq_ST_st7_fsm_6)
    begin
        if (((ap_const_logic_1 = ap_sig_cseq_ST_st7_fsm_6) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0)))) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;

    ap_return <= (notrhs_fu_46_p2 and notlhs_fu_40_p2);

    ap_sig_24_assign_proc : process(ap_CS_fsm)
    begin
                ap_sig_24 <= (ap_CS_fsm(0 downto 0) = ap_const_lv1_1);
    end process;


    ap_sig_44_assign_proc : process(ap_CS_fsm)
    begin
                ap_sig_44 <= (ap_const_lv1_1 = ap_CS_fsm(1 downto 1));
    end process;


    ap_sig_52_assign_proc : process(ap_CS_fsm)
    begin
                ap_sig_52 <= (ap_const_lv1_1 = ap_CS_fsm(2 downto 2));
    end process;


    ap_sig_60_assign_proc : process(ap_CS_fsm)
    begin
                ap_sig_60 <= (ap_const_lv1_1 = ap_CS_fsm(3 downto 3));
    end process;


    ap_sig_68_assign_proc : process(ap_CS_fsm)
    begin
                ap_sig_68 <= (ap_const_lv1_1 = ap_CS_fsm(4 downto 4));
    end process;


    ap_sig_76_assign_proc : process(ap_CS_fsm)
    begin
                ap_sig_76 <= (ap_const_lv1_1 = ap_CS_fsm(5 downto 5));
    end process;


    ap_sig_84_assign_proc : process(ap_CS_fsm)
    begin
                ap_sig_84 <= (ap_const_lv1_1 = ap_CS_fsm(6 downto 6));
    end process;


    ap_sig_90_assign_proc : process(ap_start, fet_packet_spk_id_V_empty_n)
    begin
                ap_sig_90 <= ((ap_start = ap_const_logic_0) or (fet_packet_spk_id_V_empty_n = ap_const_logic_0));
    end process;


    ap_sig_cseq_ST_st1_fsm_0_assign_proc : process(ap_sig_24)
    begin
        if (ap_sig_24) then 
            ap_sig_cseq_ST_st1_fsm_0 <= ap_const_logic_1;
        else 
            ap_sig_cseq_ST_st1_fsm_0 <= ap_const_logic_0;
        end if; 
    end process;


    ap_sig_cseq_ST_st2_fsm_1_assign_proc : process(ap_sig_44)
    begin
        if (ap_sig_44) then 
            ap_sig_cseq_ST_st2_fsm_1 <= ap_const_logic_1;
        else 
            ap_sig_cseq_ST_st2_fsm_1 <= ap_const_logic_0;
        end if; 
    end process;


    ap_sig_cseq_ST_st3_fsm_2_assign_proc : process(ap_sig_52)
    begin
        if (ap_sig_52) then 
            ap_sig_cseq_ST_st3_fsm_2 <= ap_const_logic_1;
        else 
            ap_sig_cseq_ST_st3_fsm_2 <= ap_const_logic_0;
        end if; 
    end process;


    ap_sig_cseq_ST_st4_fsm_3_assign_proc : process(ap_sig_60)
    begin
        if (ap_sig_60) then 
            ap_sig_cseq_ST_st4_fsm_3 <= ap_const_logic_1;
        else 
            ap_sig_cseq_ST_st4_fsm_3 <= ap_const_logic_0;
        end if; 
    end process;


    ap_sig_cseq_ST_st5_fsm_4_assign_proc : process(ap_sig_68)
    begin
        if (ap_sig_68) then 
            ap_sig_cseq_ST_st5_fsm_4 <= ap_const_logic_1;
        else 
            ap_sig_cseq_ST_st5_fsm_4 <= ap_const_logic_0;
        end if; 
    end process;


    ap_sig_cseq_ST_st6_fsm_5_assign_proc : process(ap_sig_76)
    begin
        if (ap_sig_76) then 
            ap_sig_cseq_ST_st6_fsm_5 <= ap_const_logic_1;
        else 
            ap_sig_cseq_ST_st6_fsm_5 <= ap_const_logic_0;
        end if; 
    end process;


    ap_sig_cseq_ST_st7_fsm_6_assign_proc : process(ap_sig_84)
    begin
        if (ap_sig_84) then 
            ap_sig_cseq_ST_st7_fsm_6 <= ap_const_logic_1;
        else 
            ap_sig_cseq_ST_st7_fsm_6 <= ap_const_logic_0;
        end if; 
    end process;


    fet_packet_spk_id_V_blk_n_assign_proc : process(ap_start, ap_sig_cseq_ST_st1_fsm_0, fet_packet_spk_id_V_empty_n, ap_sig_cseq_ST_st2_fsm_1, ap_sig_cseq_ST_st3_fsm_2, ap_sig_cseq_ST_st4_fsm_3, ap_sig_cseq_ST_st5_fsm_4, ap_sig_cseq_ST_st6_fsm_5, ap_sig_cseq_ST_st7_fsm_6)
    begin
        if ((((ap_const_logic_1 = ap_sig_cseq_ST_st1_fsm_0) and not((ap_start = ap_const_logic_0))) or (ap_const_logic_1 = ap_sig_cseq_ST_st2_fsm_1) or (ap_const_logic_1 = ap_sig_cseq_ST_st3_fsm_2) or (ap_const_logic_1 = ap_sig_cseq_ST_st4_fsm_3) or (ap_const_logic_1 = ap_sig_cseq_ST_st5_fsm_4) or (ap_const_logic_1 = ap_sig_cseq_ST_st6_fsm_5) or (ap_const_logic_1 = ap_sig_cseq_ST_st7_fsm_6))) then 
            fet_packet_spk_id_V_blk_n <= fet_packet_spk_id_V_empty_n;
        else 
            fet_packet_spk_id_V_blk_n <= ap_const_logic_1;
        end if; 
    end process;


    fet_packet_spk_id_V_read_assign_proc : process(ap_sig_cseq_ST_st1_fsm_0, fet_packet_spk_id_V_empty_n, ap_sig_cseq_ST_st2_fsm_1, ap_sig_cseq_ST_st3_fsm_2, ap_sig_cseq_ST_st4_fsm_3, ap_sig_cseq_ST_st5_fsm_4, ap_sig_cseq_ST_st6_fsm_5, ap_sig_cseq_ST_st7_fsm_6, ap_sig_90)
    begin
        if ((((ap_const_logic_1 = ap_sig_cseq_ST_st1_fsm_0) and not(ap_sig_90)) or ((ap_const_logic_1 = ap_sig_cseq_ST_st2_fsm_1) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) or ((ap_const_logic_1 = ap_sig_cseq_ST_st3_fsm_2) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) or ((ap_const_logic_1 = ap_sig_cseq_ST_st4_fsm_3) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) or ((ap_const_logic_1 = ap_sig_cseq_ST_st5_fsm_4) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) or ((ap_const_logic_1 = ap_sig_cseq_ST_st6_fsm_5) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))) or ((ap_const_logic_1 = ap_sig_cseq_ST_st7_fsm_6) and not((fet_packet_spk_id_V_empty_n = ap_const_logic_0))))) then 
            fet_packet_spk_id_V_read <= ap_const_logic_1;
        else 
            fet_packet_spk_id_V_read <= ap_const_logic_0;
        end if; 
    end process;

    notlhs_fu_40_p2 <= "1" when (fet_packet_spk_id_V_dout = tmp_fu_36_p1) else "0";
    notrhs_fu_46_p2 <= "0" when (ap_reg_ptbuf_target_unit_id_V = ap_const_lv16_0) else "1";
    tmp_fu_36_p1 <= std_logic_vector(resize(unsigned(ap_reg_ptbuf_target_unit_id_V),32));
end behav;
