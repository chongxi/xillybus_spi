module spi_intan_interface_4_bank (
  // clock and reset
  input             bus_clk                       , //
  input             sys_clk                       , //
  output            spi_clk                       ,
  input             reset                         , //

  // Wires related to /dev/xillybus_auxcmd1_membank_16
  input             user_w_auxcmd1_membank_16_wren,
  input      [15:0] user_w_auxcmd1_membank_16_data,
  input      [15:0] user_auxcmd1_membank_16_addr  ,

  // Wires related to /dev/xillybus_auxcmd2_membank_16
  input             user_w_auxcmd2_membank_16_wren,
  input      [15:0] user_w_auxcmd2_membank_16_data,
  input      [15:0] user_auxcmd2_membank_16_addr  ,

  // Wires related to /dev/xillybus_auxcmd3_membank_16
  input             user_w_auxcmd3_membank_16_wren,
  input      [15:0] user_w_auxcmd3_membank_16_data,
  input      [15:0] user_auxcmd3_membank_16_addr  ,

  // Wires related to /dev/xillybus_control_regs_16
  input             user_r_control_regs_16_rden   ,
  output reg [15:0] user_r_control_regs_16_data   ,
  input             user_w_control_regs_16_wren   ,
  input      [15:0] user_w_control_regs_16_data   ,
  input      [ 4:0] user_control_regs_16_addr     ,

  // Wires related to /dev/xillybus_status_regs_16
  input             user_r_status_regs_16_rden    ,
  output reg [15:0] user_r_status_regs_16_data    ,
  input      [ 4:0] user_status_regs_16_addr      ,

  // Protocal input
  input             MISO_A1                       ,
  input             MISO_A2                       ,
  input             MISO_B1                       ,
  input             MISO_B2                       ,
  input             MISO_C1                       ,
  input             MISO_C2                       ,
  input             MISO_D1                       ,
  input             MISO_D2                       ,

  // Protocol output
  output reg        SPI_running                   ,
  output reg        SCLK                          ,
  output reg        CS                            ,
  output reg        MOSI_A                        ,
  output reg        MOSI_B                        ,
  output reg        MOSI_C                        ,
  output reg        MOSI_D                        ,
  output reg [15:0] FIFO_DATA_STREAM              ,
  output reg        FIFO_DATA_STREAM_WEN          ,

  // To Xike
  output reg        XIKE_ENABLE                   ,
  output reg [31:0] TIME_TO_XIKE                  ,
  output reg [15:0] FIFO_DATA_TO_XIKE             ,
  output reg        FIFO_DATA_TO_XIKE_WEN         ,
  output reg [15:0] STREAM_TO_XIKE                ,
  output reg [9:0 ] CHANNEL_TO_XIKE               ,
  
  // Sync
  input sync_pulse
);


// -- SPI Clock
// fout = fin * M / (D*O)
// 84MHz = 200MHz/(25*4) * 42    for 30kS/sec
// 70MHz = 200MHz/(25*4) * 35    for 25kS/sec
// 56MHz = 200MHz/(25*4) * 28    for 20kS/sec
  reg [7:0] dataclk_O       ;
  reg [3:0] dataclk_D       ;
  reg [6:0] dataclk_M       ;
  reg       PLL_prog_trigger;

  clock_generator spi_clkgen (
    .config_clk_in(bus_clk         ),    // input
    .clk_in       (sys_clk         ),    // input
    .rst          (reset           ),    // input
    .O            (dataclk_O       ),    // input
    .D            (dataclk_D       ),    // input
    .M            (dataclk_M       ),    // input
    .start_sig    (PLL_prog_trigger),    // input 
    .ready        (PLL_prog_done   ),    // output
    .locked       (dataclk_locked  ),    // output
    .clk_out      (spi_clk         )     // output
  );  


// -- SPI Control registers -----------------------------------------------------------------------------------------------------

  localparam BOARD_ID      = 16'd701;
  localparam BOARD_VERSION = 16'd1  ;

  reg [15:0] aux_output;
  reg [1:0]  aux_input = 2'b0;

  reg SPI_start_trigger;
  reg SPI_run_continuous_in;
  reg DSP_settle;
  reg [31:0] max_timestep_in;
  reg [3:0] delay_A, delay_B, delay_C, delay_D;

  reg THRES_ENABLE;

  //Control registers
  always @(posedge bus_clk)
  begin
      SPI_start_trigger <= 1'b0;
      PLL_prog_trigger <= 1'b0;
      if (reset)
      begin
        if (user_r_control_regs_16_rden)
        begin
            user_r_control_regs_16_data <= 16'b0;
        end 
      //Fill other reset conditions here   
      SPI_run_continuous_in <= 1'b0;
      DSP_settle <= 1'b0; 
      max_timestep_in <= 32'h00;
      delay_A <= 4'b0;
      delay_B <= 4'b0;
      delay_C <= 4'b0;
      delay_D <= 4'b0;
      
      aux_cmd_bank_1_A_in <= 4'b0;
      aux_cmd_bank_1_B_in <= 4'b0;
      aux_cmd_bank_1_C_in <= 4'b0;
      aux_cmd_bank_1_D_in <= 4'b0;
      
      aux_cmd_bank_2_A_in <= 4'b0;
      aux_cmd_bank_2_B_in <= 4'b0;
      aux_cmd_bank_2_C_in <= 4'b0;
      aux_cmd_bank_2_D_in <= 4'b0;
      
      aux_cmd_bank_3_A_in <= 4'b0;
      aux_cmd_bank_3_B_in <= 4'b0;
      aux_cmd_bank_3_C_in <= 4'b0;
      aux_cmd_bank_3_D_in <= 4'b0;
      
      max_aux_cmd_index_1_in <= 10'b0;
      max_aux_cmd_index_2_in <= 10'b0;
      max_aux_cmd_index_3_in <= 10'b0;
      loop_aux_cmd_index_1 <= 10'b0; 
      loop_aux_cmd_index_2 <= 10'b0;
      loop_aux_cmd_index_3 <= 10'b0;
      
      data_stream_1_sel_in <= 4'b0;
      data_stream_2_sel_in <= 4'b0;
      data_stream_3_sel_in <= 4'b0;
      data_stream_4_sel_in <= 4'b0;
      data_stream_5_sel_in <= 4'b0;
      data_stream_6_sel_in <= 4'b0;
      data_stream_7_sel_in <= 4'b0;
      data_stream_8_sel_in <= 4'b0;
      data_stream_9_sel_in <= 4'b0;
      data_stream_10_sel_in <= 4'b0;
      data_stream_11_sel_in <= 4'b0;
      data_stream_12_sel_in <= 4'b0;
      data_stream_13_sel_in <= 4'b0;
      data_stream_14_sel_in <= 4'b0;
      data_stream_15_sel_in <= 4'b0;
      data_stream_16_sel_in <= 4'b0;
      
      data_stream_1_en_in <= 1'b0;
      data_stream_2_en_in <= 1'b0;
      data_stream_3_en_in <= 1'b0;
      data_stream_4_en_in <= 1'b0;
      data_stream_5_en_in <= 1'b0;
      data_stream_6_en_in <= 1'b0;
      data_stream_7_en_in <= 1'b0;
      data_stream_8_en_in <= 1'b0;
      data_stream_9_en_in <= 1'b0;
      data_stream_10_en_in <= 1'b0;
      data_stream_11_en_in <= 1'b0;
      data_stream_12_en_in <= 1'b0;
      data_stream_13_en_in <= 1'b0;
      data_stream_14_en_in <= 1'b0;
      data_stream_15_en_in <= 1'b0;
      data_stream_16_en_in <= 1'b0;
      
      dataclk_O <= 8'd25;
      dataclk_M <= 7'd42;
      dataclk_D <= 4'd04;
      
      aux_output <= 16'b0;
      end
      else
      begin
        if (user_w_control_regs_16_wren)
        begin
            case(user_control_regs_16_addr)
                5'h00:
                begin
                    SPI_run_continuous_in <= user_w_control_regs_16_data[1];
                    DSP_settle <= user_w_control_regs_16_data[2];
                end
                5'h01: max_timestep_in[15:0] <= user_w_control_regs_16_data;
                5'h02: max_timestep_in[31:16] <= user_w_control_regs_16_data;
                5'h03: 
                begin
                    dataclk_O <= user_w_control_regs_16_data[7:0];
                    dataclk_M <= user_w_control_regs_16_data[14:8];
                    dataclk_D <= user_w_control_regs_16_data[15] ? 4'h08 : 4'h04;
                    PLL_prog_trigger <= 1'b1;
                end
                5'h04:
                begin
                    delay_A <= user_w_control_regs_16_data[3:0];
                    delay_B <= user_w_control_regs_16_data[7:4];
                    delay_C <= user_w_control_regs_16_data[11:8];
                    delay_D <= user_w_control_regs_16_data[15:12];
                end
                5'h05:
                begin
                    XIKE_ENABLE  <= user_w_control_regs_16_data[0];
                    THRES_ENABLE <= user_w_control_regs_16_data[1];
                end
                5'h08:
                begin
                    aux_cmd_bank_1_A_in <= user_w_control_regs_16_data[3:0];
                    aux_cmd_bank_1_B_in <= user_w_control_regs_16_data[7:4];
                    aux_cmd_bank_1_C_in <= user_w_control_regs_16_data[11:8];
                    aux_cmd_bank_1_D_in <= user_w_control_regs_16_data[15:12];
                end
                5'h09:
                begin
                    aux_cmd_bank_2_A_in <= user_w_control_regs_16_data[3:0];
                    aux_cmd_bank_2_B_in <= user_w_control_regs_16_data[7:4];
                    aux_cmd_bank_2_C_in <= user_w_control_regs_16_data[11:8];
                    aux_cmd_bank_2_D_in <= user_w_control_regs_16_data[15:12];
                end
                5'h0A:
                begin
                    aux_cmd_bank_3_A_in <= user_w_control_regs_16_data[3:0];
                    aux_cmd_bank_3_B_in <= user_w_control_regs_16_data[7:4];
                    aux_cmd_bank_3_C_in <= user_w_control_regs_16_data[11:8];
                    aux_cmd_bank_3_D_in <= user_w_control_regs_16_data[15:12];
                end
                5'h0B: max_aux_cmd_index_1_in <= user_w_control_regs_16_data[9:0];
                5'h0C: max_aux_cmd_index_2_in <= user_w_control_regs_16_data[9:0];
                5'h0D: max_aux_cmd_index_3_in <= user_w_control_regs_16_data[9:0];
                5'h0E: loop_aux_cmd_index_1 <= user_w_control_regs_16_data[9:0]; 
                5'h0F: loop_aux_cmd_index_2 <= user_w_control_regs_16_data[9:0];
                5'h10: loop_aux_cmd_index_3 <= user_w_control_regs_16_data[9:0];
                5'h12:
                begin
                    data_stream_1_sel_in <= user_w_control_regs_16_data[3:0];
                    data_stream_2_sel_in <= user_w_control_regs_16_data[7:4];
                    data_stream_3_sel_in <= user_w_control_regs_16_data[11:8];
                    data_stream_4_sel_in <= user_w_control_regs_16_data[15:12];
                end
                5'h13:
                begin
                    data_stream_5_sel_in <= user_w_control_regs_16_data[3:0];
                    data_stream_6_sel_in <= user_w_control_regs_16_data[7:4];
                    data_stream_7_sel_in <= user_w_control_regs_16_data[11:8];
                    data_stream_8_sel_in <= user_w_control_regs_16_data[15:12];
                end
                5'h14:
                begin
                    data_stream_9_sel_in <= user_w_control_regs_16_data[3:0];
                    data_stream_10_sel_in <= user_w_control_regs_16_data[7:4];
                    data_stream_11_sel_in <= user_w_control_regs_16_data[11:8];
                    data_stream_12_sel_in <= user_w_control_regs_16_data[15:12];
                end
                5'h15:
                begin
                    data_stream_13_sel_in <= user_w_control_regs_16_data[3:0];
                    data_stream_14_sel_in <= user_w_control_regs_16_data[7:4];
                    data_stream_15_sel_in <= user_w_control_regs_16_data[11:8];
                    data_stream_16_sel_in <= user_w_control_regs_16_data[15:12];
                end
                5'h16:
                    begin
                        data_stream_1_en_in <= user_w_control_regs_16_data[0];
                        data_stream_2_en_in <= user_w_control_regs_16_data[1];
                        data_stream_3_en_in <= user_w_control_regs_16_data[2];
                        data_stream_4_en_in <= user_w_control_regs_16_data[3];
                        data_stream_5_en_in <= user_w_control_regs_16_data[4];
                        data_stream_6_en_in <= user_w_control_regs_16_data[5];
                        data_stream_7_en_in <= user_w_control_regs_16_data[6];
                        data_stream_8_en_in <= user_w_control_regs_16_data[7];
                        data_stream_9_en_in <= user_w_control_regs_16_data[8];
                        data_stream_10_en_in <= user_w_control_regs_16_data[9];
                        data_stream_11_en_in <= user_w_control_regs_16_data[10];
                        data_stream_12_en_in <= user_w_control_regs_16_data[11];
                        data_stream_13_en_in <= user_w_control_regs_16_data[12];
                        data_stream_14_en_in <= user_w_control_regs_16_data[13];
                        data_stream_15_en_in <= user_w_control_regs_16_data[14];
                        data_stream_16_en_in <= user_w_control_regs_16_data[15];
                    end
                5'h17: aux_output <= user_w_control_regs_16_data;
                5'h1F:
                    SPI_start_trigger <= user_w_control_regs_16_data[0];
            endcase
        end
        if (user_r_control_regs_16_rden)
            begin
                case(user_control_regs_16_addr)
                    5'h00: user_r_control_regs_16_data <= {13'b0, DSP_settle, SPI_run_continuous_in, 1'b0};
                    5'h01: user_r_control_regs_16_data <= max_timestep_in[15:0];
                    5'h02: user_r_control_regs_16_data <= max_timestep_in[31:16];
                    5'h03: user_r_control_regs_16_data <= {dataclk_D[3], dataclk_M, dataclk_O};
                    5'h04: user_r_control_regs_16_data <= {delay_D, delay_C, delay_B, delay_A};
                    5'h08: user_r_control_regs_16_data <= {aux_cmd_bank_1_D_in, aux_cmd_bank_1_C_in, aux_cmd_bank_1_B_in, aux_cmd_bank_1_A_in};
                    5'h09: user_r_control_regs_16_data <= {aux_cmd_bank_2_D_in, aux_cmd_bank_2_C_in, aux_cmd_bank_2_B_in, aux_cmd_bank_2_A_in};
                    5'h0A: user_r_control_regs_16_data <= {aux_cmd_bank_3_D_in, aux_cmd_bank_3_C_in, aux_cmd_bank_3_B_in, aux_cmd_bank_3_A_in};
                    5'h0B: user_r_control_regs_16_data <= {6'b0, max_aux_cmd_index_1_in};
                    5'h0C: user_r_control_regs_16_data <= {6'b0, max_aux_cmd_index_2_in};
                    5'h0D: user_r_control_regs_16_data <= {6'b0, max_aux_cmd_index_3_in};
                    5'h0E: user_r_control_regs_16_data <= {6'b0, loop_aux_cmd_index_1};
                    5'h0F: user_r_control_regs_16_data <= {6'b0, loop_aux_cmd_index_2};
                    5'h10: user_r_control_regs_16_data <= {6'b0, loop_aux_cmd_index_3};
                    5'h12: user_r_control_regs_16_data <= {data_stream_4_sel, data_stream_3_sel,  data_stream_2_sel,  data_stream_1_sel};  
                    5'h13: user_r_control_regs_16_data <= {data_stream_8_sel, data_stream_7_sel,  data_stream_6_sel,  data_stream_5_sel};
                    5'h14: user_r_control_regs_16_data <= {data_stream_12_sel, data_stream_11_sel,  data_stream_10_sel,  data_stream_9_sel};
                    5'h15: user_r_control_regs_16_data <= {data_stream_16_sel, data_stream_15_sel,  data_stream_14_sel,  data_stream_13_sel};
                    5'h16: user_r_control_regs_16_data <= {
                    data_stream_16_en_in,
                    data_stream_15_en_in,
                    data_stream_14_en_in,
                    data_stream_13_en_in,
                    data_stream_12_en_in,
                    data_stream_11_en_in,
                    data_stream_10_en_in,
                    data_stream_9_en_in,
                    data_stream_8_en_in,
                    data_stream_7_en_in,
                    data_stream_6_en_in,
                    data_stream_5_en_in,
                    data_stream_4_en_in,
                    data_stream_3_en_in,
                    data_stream_2_en_in,
                    data_stream_1_en_in
                    };
                    5'h17: user_r_control_regs_16_data <= aux_output;
                    default:  user_r_control_regs_16_data <= 16'b0;
                endcase
            end
      end
  end

  always @(posedge bus_clk)
  begin
    if (user_r_status_regs_16_rden)
    begin
        if (reset)
            user_r_status_regs_16_data <= 16'b0;
         else
         begin
            case (user_status_regs_16_addr)
                //numwords ignored
                5'h02: user_r_status_regs_16_data <= {15'b0, SPI_running};
                5'h04: user_r_status_regs_16_data <= {14'b0, PLL_prog_done, dataclk_locked };
                5'h05: user_r_status_regs_16_data <= BOARD_ID;
                5'h06: user_r_status_regs_16_data <= BOARD_VERSION;
                5'h07: user_r_status_regs_16_data <= {15'b0, aux_input[0]};
                default: user_r_status_regs_16_data <= 16'h00;
            endcase
         end
    end
  end
  
// Control register end ------------------------------------------------------------------------------------------------------
  reg  [ 9:0] RAM_addr_rd       ;
  reg  [ 3:0] RAM_bank_sel_rd   ;
  wire [15:0] RAM_data_out_1_pre, RAM_data_out_2_pre, RAM_data_out_3_pre;
  reg  [15:0] RAM_data_out_1, RAM_data_out_2, RAM_data_out_3;

  reg [ 5:0] channel, channel_MISO; // varies from 0-34 (amplfier channels 0-31, plus 3 auxiliary commands)
  reg [15:0] MOSI_cmd_A, MOSI_cmd_B, MOSI_cmd_C, MOSI_cmd_D;

  reg  [73:0] in4x_A1, in4x_A2;
  reg  [73:0] in4x_B1, in4x_B2;
  reg  [73:0] in4x_C1, in4x_C2;
  reg  [73:0] in4x_D1, in4x_D2;
  wire [15:0] in_A1, in_A2;
  wire [15:0] in_B1, in_B2;
  wire [15:0] in_C1, in_C2;
  wire [15:0] in_D1, in_D2;
  wire [15:0] in_DDR_A1, in_DDR_A2;
  wire [15:0] in_DDR_B1, in_DDR_B2;
  wire [15:0] in_DDR_C1, in_DDR_C2;
  wire [15:0] in_DDR_D1, in_DDR_D2;

  reg [15:0] result_A1, result_A2;
  reg [15:0] result_B1, result_B2;
  reg [15:0] result_C1, result_C2;
  reg [15:0] result_D1, result_D2;
  reg [15:0] result_DDR_A1, result_DDR_A2;
  reg [15:0] result_DDR_B1, result_DDR_B2;
  reg [15:0] result_DDR_C1, result_DDR_C2;
  reg [15:0] result_DDR_D1, result_DDR_D2;

  reg  [31:0] timestamp            ;
  reg  [31:0] max_timestep         ;
  wire [31:0] max_timestep_dataclk ;
  wire [63:0] header_magic_number  ;
  wire [15:0] data_stream_filler   ;

  reg [15:0] data_stream_1, data_stream_2, data_stream_3, data_stream_4;
  reg [15:0] data_stream_5, data_stream_6, data_stream_7, data_stream_8;
  reg [15:0] data_stream_9, data_stream_10, data_stream_11, data_stream_12;
  reg [15:0] data_stream_13, data_stream_14, data_stream_15, data_stream_16;
  reg [ 3:0] data_stream_1_sel, data_stream_2_sel, data_stream_3_sel, data_stream_4_sel;
  reg [ 3:0] data_stream_5_sel, data_stream_6_sel, data_stream_7_sel, data_stream_8_sel;
  reg [ 3:0] data_stream_9_sel, data_stream_10_sel, data_stream_11_sel, data_stream_12_sel;
  reg [ 3:0] data_stream_13_sel, data_stream_14_sel, data_stream_15_sel, data_stream_16_sel;
  reg [ 3:0] data_stream_1_sel_in, data_stream_2_sel_in, data_stream_3_sel_in, data_stream_4_sel_in;
  reg [ 3:0] data_stream_5_sel_in, data_stream_6_sel_in, data_stream_7_sel_in, data_stream_8_sel_in;
  reg [ 3:0] data_stream_9_sel_in, data_stream_10_sel_in, data_stream_11_sel_in, data_stream_12_sel_in;
  reg [ 3:0] data_stream_13_sel_in, data_stream_14_sel_in, data_stream_15_sel_in, data_stream_16_sel_in;
  reg        data_stream_1_en, data_stream_2_en, data_stream_3_en, data_stream_4_en;
  reg        data_stream_5_en, data_stream_6_en, data_stream_7_en, data_stream_8_en;
  reg        data_stream_9_en, data_stream_10_en, data_stream_11_en, data_stream_12_en;
  reg        data_stream_13_en, data_stream_14_en, data_stream_15_en, data_stream_16_en;
  reg        data_stream_1_en_in, data_stream_2_en_in, data_stream_3_en_in, data_stream_4_en_in;
  reg        data_stream_5_en_in, data_stream_6_en_in, data_stream_7_en_in, data_stream_8_en_in;
  reg        data_stream_9_en_in, data_stream_10_en_in, data_stream_11_en_in, data_stream_12_en_in;
  reg        data_stream_13_en_in, data_stream_14_en_in, data_stream_15_en_in, data_stream_16_en_in;

  reg  [15:0] data_stream_TTL_in, data_stream_TTL_out;
  wire [15:0] data_stream_ADC_1, data_stream_ADC_2, data_stream_ADC_3, data_stream_ADC_4;
  wire [15:0] data_stream_ADC_5, data_stream_ADC_6, data_stream_ADC_7, data_stream_ADC_8;


  wire SPI_start;
  reg  SPI_run_continuous        ;
  wire SPI_run_continuous_dataclk;

  wire [15:0] MOSI_cmd_selected_A, MOSI_cmd_selected_B, MOSI_cmd_selected_C, MOSI_cmd_selected_D;

  reg [15:0] aux_cmd_A, aux_cmd_B, aux_cmd_C, aux_cmd_D;
  reg [ 9:0] aux_cmd_index_1, aux_cmd_index_2, aux_cmd_index_3;
  reg [ 9:0] max_aux_cmd_index_1_in, max_aux_cmd_index_2_in, max_aux_cmd_index_3_in;
  reg [ 9:0] max_aux_cmd_index_1, max_aux_cmd_index_2, max_aux_cmd_index_3;
  reg [ 9:0] loop_aux_cmd_index_1, loop_aux_cmd_index_2, loop_aux_cmd_index_3;

  reg [3:0] aux_cmd_bank_1_A_in, aux_cmd_bank_1_B_in, aux_cmd_bank_1_C_in, aux_cmd_bank_1_D_in;
  reg [3:0] aux_cmd_bank_2_A_in, aux_cmd_bank_2_B_in, aux_cmd_bank_2_C_in, aux_cmd_bank_2_D_in;
  reg [3:0] aux_cmd_bank_3_A_in, aux_cmd_bank_3_B_in, aux_cmd_bank_3_C_in, aux_cmd_bank_3_D_in;
  reg [3:0] aux_cmd_bank_1_A, aux_cmd_bank_1_B, aux_cmd_bank_1_C, aux_cmd_bank_1_D;
  reg [3:0] aux_cmd_bank_2_A, aux_cmd_bank_2_B, aux_cmd_bank_2_C, aux_cmd_bank_2_D;
  reg [3:0] aux_cmd_bank_3_A, aux_cmd_bank_3_B, aux_cmd_bank_3_C, aux_cmd_bank_3_D;

  reg       external_fast_settle_enable  = 1'b0                                  ;
  reg [3:0] external_fast_settle_channel = 4'b0                                  ;
  reg       external_fast_settle         = 1'b0, external_fast_settle_prev = 1'b0;

  reg       external_digout_enable_A  = 1'b0, external_digout_enable_B = 1'b0, external_digout_enable_C = 1'b0, external_digout_enable_D = 1'b0   ;
  reg [3:0] external_digout_channel_A = 4'b0, external_digout_channel_B = 4'b0, external_digout_channel_C = 4'b0, external_digout_channel_D = 4'b0;
  reg       external_digout_A, external_digout_B, external_digout_C, external_digout_D;

  //Bogus signals
  wire [15:0] TTL_in    ;
  wire [15:0] TTL_out   ;
  assign TTL_in[15]        = sync_pulse;
  assign TTL_out           = 16'b0;
  assign data_stream_ADC_1 = 16'b0;
  assign data_stream_ADC_2 = 16'b0;
  assign data_stream_ADC_3 = 16'b0;
  assign data_stream_ADC_4 = 16'b0;
  assign data_stream_ADC_5 = 16'b0;
  assign data_stream_ADC_6 = 16'b0;
  assign data_stream_ADC_7 = 16'b0;
  assign data_stream_ADC_8 = 16'b0;
  assign data_stream_ADC_8 = 16'b0;

  wire unused_spi_cdc;

  flag_cdc SPI_cdc (
    .clkA(bus_clk          ),
    .clkB(spi_clk          ),
    .in  (SPI_start_trigger),
    .out (SPI_start        ),
    .busy(unused_spi_cdc   )
  );
              
  bus_cdc SPI_cont_cdc (
    .clkDst(spi_clk                   ),
    .in    (SPI_run_continuous_in     ),
    .out   (SPI_run_continuous_dataclk)
  );

  bus_cdc #(.WIDTH(32)) max_timestep_cdc (
    .clkDst(spi_clk             ),
    .in    (max_timestep_in     ),
    .out   (max_timestep_dataclk)
  ); 
              
// ---- MOSI -------------------------------------------------------------------------------------------------           
  // MOSI auxiliary command sequence RAM banks
  RAM_bank RAM_bank_1 (
    .clka (bus_clk                           ),
    .wea  (user_w_auxcmd1_membank_16_wren    ),
    .addra(user_auxcmd1_membank_16_addr[13:0]),
    .dina (user_w_auxcmd1_membank_16_data    ),
    .clkb (spi_clk                           ),
    .rstb (reset                             ),
    .addrb({RAM_bank_sel_rd, RAM_addr_rd}    ),
    .doutb(RAM_data_out_1_pre                )
  );

  
  wire external_fast_settle_rising_edge, external_fast_settle_falling_edge;
  assign external_fast_settle_rising_edge = external_fast_settle_prev == 1'b0 && external_fast_settle == 1'b1;
  assign external_fast_settle_falling_edge = external_fast_settle_prev == 1'b1 && external_fast_settle == 1'b0;
      
  // If the user has enabled external fast settling of amplifiers, inject commands to set fast settle
  // (bit D[5] in RAM Register 0) on a rising edge and reset fast settle on a falling edge of the control
  // signal.  We only inject commands in the auxcmd1 slot, since this is typically used only for setting
  // impedance test waveforms.
  always @(*) begin
    if (external_fast_settle_enable == 1'b0)
      RAM_data_out_1 <= RAM_data_out_1_pre; // If external fast settle is disabled, pass command from RAM
    else if (external_fast_settle_rising_edge)
      RAM_data_out_1 <= 16'h80fe; // Send WRITE(0, 254) command to set fast settle when rising edge detected.
    else if (external_fast_settle_falling_edge)
      RAM_data_out_1 <= 16'h80de; // Send WRITE(0, 222) command to reset fast settle when falling edge detected.
    else if (RAM_data_out_1_pre[15:8] == 8'h80)
      // If the user tries to write to Register 0, override it with the external fast settle value.
      RAM_data_out_1 <= { RAM_data_out_1_pre[15:6], external_fast_settle, RAM_data_out_1_pre[4:0] };
    else RAM_data_out_1 <= RAM_data_out_1_pre; // Otherwise pass command from RAM.
  end
  

  RAM_bank RAM_bank_2(
    .clka(bus_clk),
    .wea(user_w_auxcmd2_membank_16_wren),
    .addra(user_auxcmd2_membank_16_addr[13:0]),
    .dina(user_w_auxcmd2_membank_16_data),
    .clkb(spi_clk),
    .rstb(reset),
    .addrb({RAM_bank_sel_rd, RAM_addr_rd}),
    .doutb(RAM_data_out_2_pre)
    );


  always @(*) begin
      if (external_fast_settle_enable == 1'b1 && RAM_data_out_2_pre[15:8] == 8'h80)
          // If the user tries to write to Register 0 when external fast settle is enabled, override it
          // with the external fast settle value.
          RAM_data_out_2 <= { RAM_data_out_2_pre[15:6], external_fast_settle, RAM_data_out_2_pre[4:0] };
      else RAM_data_out_2 <= RAM_data_out_2_pre;
  end


  RAM_bank RAM_bank_3(
    .clka(bus_clk),
    .wea(user_w_auxcmd3_membank_16_wren),
    .addra(user_auxcmd3_membank_16_addr[13:0]),
    .dina(user_w_auxcmd3_membank_16_data),
    .clkb(spi_clk),
    .rstb(reset),
    .addrb({RAM_bank_sel_rd, RAM_addr_rd}),
    .doutb(RAM_data_out_3_pre)
    );

    
  always @(*) begin
      if (external_fast_settle_enable == 1'b1 && RAM_data_out_3_pre[15:8] == 8'h80)
          // If the user tries to write to Register 0 when external fast settle is enabled, override it
          // with the external fast settle value.
          RAM_data_out_3 <= { RAM_data_out_3_pre[15:6], external_fast_settle, RAM_data_out_3_pre[4:0] };
      else RAM_data_out_3 <= RAM_data_out_3_pre;
  end
      
      
  MOSI_command_selector_4x MOSI_command_generator (
    .channel          (channel            ),
    .DSP_settle       (DSP_settle         ),
    .aux_cmd_A        (aux_cmd_A          ),
    .aux_cmd_B        (aux_cmd_B          ),
    .aux_cmd_C        (aux_cmd_C          ),
    .aux_cmd_D        (aux_cmd_D          ),
    .external_digout_A(external_digout_A  ),
    .external_digout_B(external_digout_B  ),
    .external_digout_C(external_digout_C  ),
    .external_digout_D(external_digout_D  ),
    .MOSI_cmd_A       (MOSI_cmd_selected_A),
    .MOSI_cmd_B       (MOSI_cmd_selected_B),
    .MOSI_cmd_C       (MOSI_cmd_selected_C),
    .MOSI_cmd_D       (MOSI_cmd_selected_D)
  );
// ---- MOSI end ----------------------------------------------------------------------------------------------

          assign header_magic_number = 64'hC691199927021942;  // Fixed 64-bit "magic number" that begins each data frame
                                                                                   // to aid in synchronization.
          assign data_stream_filler = 16'd0;
              
          integer main_state;
         localparam
                        ms_wait    = 99,
                     ms_clk1_a  = 100,
                       ms_clk1_b  = 101,
                    ms_clk1_c  = 102,
                    ms_clk1_d  = 103,
                        ms_clk2_a  = 104,
                       ms_clk2_b  = 105,
                    ms_clk2_c  = 106,
                    ms_clk2_d  = 107,
                        ms_clk3_a  = 108,
                       ms_clk3_b  = 109,
                    ms_clk3_c  = 110,
                    ms_clk3_d  = 111,
                        ms_clk4_a  = 112,
                       ms_clk4_b  = 113,
                    ms_clk4_c  = 114,
                    ms_clk4_d  = 115,
                        ms_clk5_a  = 116,
                       ms_clk5_b  = 117,
                    ms_clk5_c  = 118,
                    ms_clk5_d  = 119,
                        ms_clk6_a  = 120,
                       ms_clk6_b  = 121,
                    ms_clk6_c  = 122,
                    ms_clk6_d  = 123,
                        ms_clk7_a  = 124,
                       ms_clk7_b  = 125,
                    ms_clk7_c  = 126,
                    ms_clk7_d  = 127,
                        ms_clk8_a  = 128,
                       ms_clk8_b  = 129,
                    ms_clk8_c  = 130,
                    ms_clk8_d  = 131,
                        ms_clk9_a  = 132,
                       ms_clk9_b  = 133,
                    ms_clk9_c  = 134,
                    ms_clk9_d  = 135,
                        ms_clk10_a = 136,
                       ms_clk10_b = 137,
                    ms_clk10_c = 138,
                    ms_clk10_d = 139,
                        ms_clk11_a = 140,
                       ms_clk11_b = 141,
                    ms_clk11_c = 142,
                    ms_clk11_d = 143,
                        ms_clk12_a = 144,
                       ms_clk12_b = 145,
                    ms_clk12_c = 146,
                    ms_clk12_d = 147,
                        ms_clk13_a = 148,
                       ms_clk13_b = 149,
                    ms_clk13_c = 150,
                    ms_clk13_d = 151,
                        ms_clk14_a = 152,
                       ms_clk14_b = 153,
                    ms_clk14_c = 154,
                    ms_clk14_d = 155,
                        ms_clk15_a = 156,
                       ms_clk15_b = 157,
                    ms_clk15_c = 158,
                    ms_clk15_d = 159,
                        ms_clk16_a = 160,
                       ms_clk16_b = 161,
                    ms_clk16_c = 162,
                    ms_clk16_d = 163,
                        
                    ms_clk17_a = 164,
                    ms_clk17_b = 165,
                        
                        ms_cs_a    = 166,
                        ms_cs_b    = 167,
                        ms_cs_c    = 168,
                        ms_cs_d    = 169,
                        ms_cs_e    = 170,
                        ms_cs_f    = 171,
                        ms_cs_g    = 172,
                        ms_cs_h    = 173,
                        ms_cs_i    = 174,
                        ms_cs_j    = 175,
                        ms_cs_k    = 176,
                        ms_cs_l    = 177,
                        ms_cs_m    = 178,
                        ms_cs_n    = 179;
      
                           
          always @(posedge spi_clk or posedge reset) begin
              if (reset) begin
                  main_state <= ms_wait;
                  timestamp <= 0;
                  channel <= 0;
                  CS <= 1'b1;
                  SCLK <= 1'b0;
                  MOSI_A <= 1'b0;
                  MOSI_B <= 1'b0;
                  MOSI_C <= 1'b0;
                  MOSI_D <= 1'b0;
                  FIFO_DATA_STREAM <= 16'b0;
                  FIFO_DATA_STREAM_WEN <= 1'b0;
                  FIFO_DATA_TO_XIKE <= 16'b0;
                  FIFO_DATA_TO_XIKE_WEN <= 1'b0; 
                  STREAM_TO_XIKE <= 16'b0;
                  max_timestep <= 32'b0;   
                  SPI_running <= 1'b0;
                  SPI_run_continuous <= 1'b0;
              end else begin
                  CS <= 1'b0;
                  SCLK <= 1'b0;
                  FIFO_DATA_STREAM <= 16'b0;
                  FIFO_DATA_STREAM_WEN <= 1'b0;
                  FIFO_DATA_TO_XIKE <= 16'b0;
                  FIFO_DATA_TO_XIKE_WEN <= 1'b0; 
                  STREAM_TO_XIKE <= 16'b0;
                        
                  case (main_state)
                  
                      ms_wait: begin
                          timestamp <= 0;
                          channel <= 0;
                          channel_MISO <= 33;    // channel of MISO output, accounting for 2-cycle pipeline in RHD2000 SPI interface (Bug fix: changed 2 to 33, 1/26/13)
                          CS <= 1'b1;
                          SCLK <= 1'b0;
                          MOSI_A <= 1'b0;
                          MOSI_B <= 1'b0;
                          MOSI_C <= 1'b0;
                          MOSI_D <= 1'b0;
                          FIFO_DATA_STREAM <= 16'b0;
                          FIFO_DATA_STREAM_WEN <= 1'b0;
                          FIFO_DATA_TO_XIKE <= 16'b0;
                          FIFO_DATA_TO_XIKE_WEN <= 1'b0; 
                          STREAM_TO_XIKE <= 16'b0;
                          aux_cmd_index_1 <= 0;
                          aux_cmd_index_2 <= 0;
                          aux_cmd_index_3 <= 0;
                          max_aux_cmd_index_1 <= max_aux_cmd_index_1_in;
                          max_aux_cmd_index_2 <= max_aux_cmd_index_2_in;
                          max_aux_cmd_index_3 <= max_aux_cmd_index_3_in;
                          aux_cmd_bank_1_A <= aux_cmd_bank_1_A_in;
                          aux_cmd_bank_1_B <= aux_cmd_bank_1_B_in;
                          aux_cmd_bank_1_C <= aux_cmd_bank_1_C_in;
                          aux_cmd_bank_1_D <= aux_cmd_bank_1_D_in;
                          aux_cmd_bank_2_A <= aux_cmd_bank_2_A_in;
                          aux_cmd_bank_2_B <= aux_cmd_bank_2_B_in;
                          aux_cmd_bank_2_C <= aux_cmd_bank_2_C_in;
                          aux_cmd_bank_2_D <= aux_cmd_bank_2_D_in;
                          aux_cmd_bank_3_A <= aux_cmd_bank_3_A_in;
                          aux_cmd_bank_3_B <= aux_cmd_bank_3_B_in;
                          aux_cmd_bank_3_C <= aux_cmd_bank_3_C_in;
                          aux_cmd_bank_3_D <= aux_cmd_bank_3_D_in;
                          
                          data_stream_1_en <= data_stream_1_en_in;        // can only change USB streams after stopping SPI
                          data_stream_2_en <= data_stream_2_en_in;
                          data_stream_3_en <= data_stream_3_en_in;
                          data_stream_4_en <= data_stream_4_en_in;
                          data_stream_5_en <= data_stream_5_en_in;
                          data_stream_6_en <= data_stream_6_en_in;
                          data_stream_7_en <= data_stream_7_en_in;
                          data_stream_8_en <= data_stream_8_en_in;
                          
                          data_stream_9_en <= data_stream_9_en_in;        
                          data_stream_10_en <= data_stream_10_en_in;
                          data_stream_11_en <= data_stream_11_en_in;
                          data_stream_12_en <= data_stream_12_en_in;
                          data_stream_13_en <= data_stream_13_en_in;
                          data_stream_14_en <= data_stream_14_en_in;
                          data_stream_15_en <= data_stream_15_en_in;
                          data_stream_16_en <= data_stream_16_en_in;
                          
                          data_stream_1_sel <= data_stream_1_sel_in;
                          data_stream_2_sel <= data_stream_2_sel_in;
                          data_stream_3_sel <= data_stream_3_sel_in;
                          data_stream_4_sel <= data_stream_4_sel_in;
                          data_stream_5_sel <= data_stream_5_sel_in;
                          data_stream_6_sel <= data_stream_6_sel_in;
                          data_stream_7_sel <= data_stream_7_sel_in;
                          data_stream_8_sel <= data_stream_8_sel_in;
                          
                          data_stream_9_sel <= data_stream_9_sel_in;
                          data_stream_10_sel <= data_stream_10_sel_in;
                          data_stream_11_sel <= data_stream_11_sel_in;
                          data_stream_12_sel <= data_stream_12_sel_in;
                          data_stream_13_sel <= data_stream_13_sel_in;
                          data_stream_14_sel <= data_stream_14_sel_in;
                          data_stream_15_sel <= data_stream_15_sel_in;
                          data_stream_16_sel <= data_stream_16_sel_in;

                          SPI_running <= 1'b0;
                          
                          max_timestep <= max_timestep_dataclk;
                          SPI_run_continuous <= SPI_run_continuous_dataclk;
      
                          if (SPI_start) begin
                              main_state <= ms_cs_n;
                          end
                      end
      
                      ms_cs_n: begin
                          max_timestep <= max_timestep_dataclk; //Sample timestep at the start of the cycle
                          SPI_run_continuous <= SPI_run_continuous_dataclk;  
                          SPI_running <= 1'b1;
                          MOSI_cmd_A <= MOSI_cmd_selected_A;
                          MOSI_cmd_B <= MOSI_cmd_selected_B;
                          MOSI_cmd_C <= MOSI_cmd_selected_C;
                          MOSI_cmd_D <= MOSI_cmd_selected_D;
                          CS <= 1'b1;
                          main_state <= ms_clk1_a;
                      end
      
                      ms_clk1_a: begin
      
                          if (channel == 0) begin                // grab TTL inputs, and grab current state of TTL outputs and manual DAC outputs
                              data_stream_TTL_in <= TTL_in;
                              data_stream_TTL_out <= TTL_out;
                              
                              // Route selected TTL input to external fast settle signal
                              external_fast_settle_prev <= external_fast_settle;    // save previous value so we can detecting rising/falling edges
                              external_fast_settle <= TTL_in[external_fast_settle_channel];
                              
                              // Route selected TLL inputs to external digout signal
                              external_digout_A <= external_digout_enable_A ? TTL_in[external_digout_channel_A] : 0;
                              external_digout_B <= external_digout_enable_B ? TTL_in[external_digout_channel_B] : 0;
                              external_digout_C <= external_digout_enable_C ? TTL_in[external_digout_channel_C] : 0;
                              external_digout_D <= external_digout_enable_D ? TTL_in[external_digout_channel_D] : 0;                        
                          end
      
                          MOSI_A <= MOSI_cmd_A[15];
                          MOSI_B <= MOSI_cmd_B[15];
                          MOSI_C <= MOSI_cmd_C[15];
                          MOSI_D <= MOSI_cmd_D[15];
                          main_state <= ms_clk1_b;
                      end
      
                      ms_clk1_b: begin
                          // Note: After selecting a new RAM_addr_rd, we must wait two clock cycles before reading from the RAM
                          if (channel == 31) begin
                              RAM_addr_rd <= aux_cmd_index_1;
                          end else if (channel == 32) begin
                              RAM_addr_rd <= aux_cmd_index_2;
                          end else if (channel == 33) begin
                              RAM_addr_rd <= aux_cmd_index_3;
                          end
      
                          if (channel == 0) begin
                              FIFO_DATA_STREAM <= header_magic_number[15:0];
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          main_state <= ms_clk1_c;
                      end
      
                      ms_clk1_c: begin
                          // Note: We only need to wait one clock cycle after selecting a new RAM_bank_sel_rd
                          if (channel == 31) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_1_A;
                          end else if (channel == 32) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_2_A;
                          end else if (channel == 33) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_3_A;
                          end
      
                          if (channel == 0) begin
                              FIFO_DATA_STREAM <= header_magic_number[31:16];
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[0] <= MISO_A1; in4x_A2[0] <= MISO_A2;
                          in4x_B1[0] <= MISO_B1; in4x_B2[0] <= MISO_B2;
                          in4x_C1[0] <= MISO_C1; in4x_C2[0] <= MISO_C2;
                          in4x_D1[0] <= MISO_D1; in4x_D2[0] <= MISO_D2;                    
                          main_state <= ms_clk1_d;
                      end
                      
                      ms_clk1_d: begin
                          if (channel == 31) begin
                              aux_cmd_A <= RAM_data_out_1;
                          end else if (channel == 32) begin
                              aux_cmd_A <= RAM_data_out_2;
                          end else if (channel == 33) begin
                              aux_cmd_A <= RAM_data_out_3;
                          end
      
                          if (channel == 0) begin
                              FIFO_DATA_STREAM <= header_magic_number[47:32];
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[1] <= MISO_A1; in4x_A2[1] <= MISO_A2;
                          in4x_B1[1] <= MISO_B1; in4x_B2[1] <= MISO_B2;
                          in4x_C1[1] <= MISO_C1; in4x_C2[1] <= MISO_C2;
                          in4x_D1[1] <= MISO_D1; in4x_D2[1] <= MISO_D2;                
                          main_state <= ms_clk2_a;
                      end
      
                      ms_clk2_a: begin
                          if (channel == 31) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_1_B;
                          end else if (channel == 32) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_2_B;
                          end else if (channel == 33) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_3_B;
                          end
      
                          if (channel == 0) begin
                              FIFO_DATA_STREAM <= header_magic_number[63:48];
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          MOSI_A <= MOSI_cmd_A[14];
                          MOSI_B <= MOSI_cmd_B[14];
                          MOSI_C <= MOSI_cmd_C[14];
                          MOSI_D <= MOSI_cmd_D[14];
                          in4x_A1[2] <= MISO_A1; in4x_A2[2] <= MISO_A2;
                          in4x_B1[2] <= MISO_B1; in4x_B2[2] <= MISO_B2;
                          in4x_C1[2] <= MISO_C1; in4x_C2[2] <= MISO_C2;
                          in4x_D1[2] <= MISO_D1; in4x_D2[2] <= MISO_D2;                
                          main_state <= ms_clk2_b;
                      end
      
                      ms_clk2_b: begin
                          if (channel == 31) begin
                              aux_cmd_B <= RAM_data_out_1;
                          end else if (channel == 32) begin
                              aux_cmd_B <= RAM_data_out_2;
                          end else if (channel == 33) begin
                              aux_cmd_B <= RAM_data_out_3;
                          end
      
                          if (channel == 0) begin
                              FIFO_DATA_STREAM     <= timestamp[15:0];
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          in4x_A1[3] <= MISO_A1; in4x_A2[3] <= MISO_A2;
                          in4x_B1[3] <= MISO_B1; in4x_B2[3] <= MISO_B2;
                          in4x_C1[3] <= MISO_C1; in4x_C2[3] <= MISO_C2;
                          in4x_D1[3] <= MISO_D1; in4x_D2[3] <= MISO_D2;                
                          main_state <= ms_clk2_c;
                      end
      
                      ms_clk2_c: begin
                          if (channel == 31) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_1_C;
                          end else if (channel == 32) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_2_C;
                          end else if (channel == 33) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_3_C;
                          end
      
                          if (channel == 0) begin
                              FIFO_DATA_STREAM <= timestamp[31:16];
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                              TIME_TO_XIKE[31:0] <= timestamp[31:0];
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[4] <= MISO_A1; in4x_A2[4] <= MISO_A2;
                          in4x_B1[4] <= MISO_B1; in4x_B2[4] <= MISO_B2;
                          in4x_C1[4] <= MISO_C1; in4x_C2[4] <= MISO_C2;
                          in4x_D1[4] <= MISO_D1; in4x_D2[4] <= MISO_D2;                    
                          main_state <= ms_clk2_d;
                      end
                      
                      ms_clk2_d: begin
                          if (channel == 31) begin
                              aux_cmd_C <= RAM_data_out_1;
                          end else if (channel == 32) begin
                              aux_cmd_C <= RAM_data_out_2;
                          end else if (channel == 33) begin
                              aux_cmd_C <= RAM_data_out_3;
                          end
      
                          if (data_stream_1_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_1;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_1;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 0;
                                STREAM_TO_XIKE        <= 16'b0000000000000001;
                              end
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[5] <= MISO_A1; in4x_A2[5] <= MISO_A2;
                          in4x_B1[5] <= MISO_B1; in4x_B2[5] <= MISO_B2;
                          in4x_C1[5] <= MISO_C1; in4x_C2[5] <= MISO_C2;
                          in4x_D1[5] <= MISO_D1; in4x_D2[5] <= MISO_D2;                
                          main_state <= ms_clk3_a;
                      end
                      
                      ms_clk3_a: begin
                          if (channel == 31) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_1_D;
                          end else if (channel == 32) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_2_D;
                          end else if (channel == 33) begin
                              RAM_bank_sel_rd <= aux_cmd_bank_3_D;
                          end
      
                          if (data_stream_2_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_2;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_2;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 1;
                                STREAM_TO_XIKE        <= 16'b0000000000000010;
                              end
                         end
      
                          MOSI_A <= MOSI_cmd_A[13];
                          MOSI_B <= MOSI_cmd_B[13];
                          MOSI_C <= MOSI_cmd_C[13];
                          MOSI_D <= MOSI_cmd_D[13];
                          in4x_A1[6] <= MISO_A1; in4x_A2[6] <= MISO_A2;
                          in4x_B1[6] <= MISO_B1; in4x_B2[6] <= MISO_B2;
                          in4x_C1[6] <= MISO_C1; in4x_C2[6] <= MISO_C2;
                          in4x_D1[6] <= MISO_D1; in4x_D2[6] <= MISO_D2;                
                          main_state <= ms_clk3_b;
                      end
      
                      ms_clk3_b: begin
                          if (channel == 31) begin
                              aux_cmd_D <= RAM_data_out_1;
                          end else if (channel == 32) begin
                              aux_cmd_D <= RAM_data_out_2;
                          end else if (channel == 33) begin
                              aux_cmd_D <= RAM_data_out_3;
                          end
                          if (data_stream_3_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_3;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_3;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 2;
                                STREAM_TO_XIKE        <= 16'b0000000000000100;
                              end
			                    end
      
                          in4x_A1[7] <= MISO_A1; in4x_A2[7] <= MISO_A2;
                          in4x_B1[7] <= MISO_B1; in4x_B2[7] <= MISO_B2;
                          in4x_C1[7] <= MISO_C1; in4x_C2[7] <= MISO_C2;
                          in4x_D1[7] <= MISO_D1; in4x_D2[7] <= MISO_D2;                
                          main_state <= ms_clk3_c;
                      end
      
                      ms_clk3_c: begin
                          if (data_stream_4_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_4;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_4;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 3;
                                STREAM_TO_XIKE        <= 16'b0000000000001000;
                              end
			                    end
      
                          SCLK <= 1'b1;
                          in4x_A1[8] <= MISO_A1; in4x_A2[8] <= MISO_A2;
                          in4x_B1[8] <= MISO_B1; in4x_B2[8] <= MISO_B2;
                          in4x_C1[8] <= MISO_C1; in4x_C2[8] <= MISO_C2;
                          in4x_D1[8] <= MISO_D1; in4x_D2[8] <= MISO_D2;                    
                          main_state <= ms_clk3_d;
                      end
                      
                      ms_clk3_d: begin
                          if (data_stream_5_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_5;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_5;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 4;
                                STREAM_TO_XIKE        <= 16'b0000000000010000;
                              end
                         end
      
                          SCLK <= 1'b1;
                          in4x_A1[9] <= MISO_A1; in4x_A2[9] <= MISO_A2;
                          in4x_B1[9] <= MISO_B1; in4x_B2[9] <= MISO_B2;
                          in4x_C1[9] <= MISO_C1; in4x_C2[9] <= MISO_C2;
                          in4x_D1[9] <= MISO_D1; in4x_D2[9] <= MISO_D2;                
                          main_state <= ms_clk4_a;
                      end
      
                      ms_clk4_a: begin
                          if (data_stream_6_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_6;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_6;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 5;
                                STREAM_TO_XIKE        <= 16'b0000000000100000;
                              end
                         end
      
                          MOSI_A <= MOSI_cmd_A[12];
                          MOSI_B <= MOSI_cmd_B[12];
                          MOSI_C <= MOSI_cmd_C[12];
                          MOSI_D <= MOSI_cmd_D[12];
                          in4x_A1[10] <= MISO_A1; in4x_A2[10] <= MISO_A2;
                          in4x_B1[10] <= MISO_B1; in4x_B2[10] <= MISO_B2;
                          in4x_C1[10] <= MISO_C1; in4x_C2[10] <= MISO_C2;
                          in4x_D1[10] <= MISO_D1; in4x_D2[10] <= MISO_D2;                
                          main_state <= ms_clk4_b;
                      end
      
                      ms_clk4_b: begin
                          if (data_stream_7_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_7;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_7;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 6;
                                STREAM_TO_XIKE        <= 16'b0000000001000000;
                              end
                         end
      
                          in4x_A1[11] <= MISO_A1; in4x_A2[11] <= MISO_A2;
                          in4x_B1[11] <= MISO_B1; in4x_B2[11] <= MISO_B2;
                          in4x_C1[11] <= MISO_C1; in4x_C2[11] <= MISO_C2;
                          in4x_D1[11] <= MISO_D1; in4x_D2[11] <= MISO_D2;                
                          main_state <= ms_clk4_c;
                      end
      
                      ms_clk4_c: begin
                          if (data_stream_8_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_8;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_8;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 7;
                                STREAM_TO_XIKE        <= 16'b0000000010000000;
                              end
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[12] <= MISO_A1; in4x_A2[12] <= MISO_A2;
                          in4x_B1[12] <= MISO_B1; in4x_B2[12] <= MISO_B2;
                          in4x_C1[12] <= MISO_C1; in4x_C2[12] <= MISO_C2;
                          in4x_D1[12] <= MISO_D1; in4x_D2[12] <= MISO_D2;                    
                          main_state <= ms_clk4_d;
                      end
                      
                      ms_clk4_d: begin
                          if (data_stream_9_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_9;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_9;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 8;
                                STREAM_TO_XIKE        <= 16'b0000000100000000;
                              end
                         end
                          
                          SCLK <= 1'b1;
                          in4x_A1[13] <= MISO_A1; in4x_A2[13] <= MISO_A2;
                          in4x_B1[13] <= MISO_B1; in4x_B2[13] <= MISO_B2;
                          in4x_C1[13] <= MISO_C1; in4x_C2[13] <= MISO_C2;
                          in4x_D1[13] <= MISO_D1; in4x_D2[13] <= MISO_D2;                
                          main_state <= ms_clk5_a;
                      end
                      
                      ms_clk5_a: begin
                          if (data_stream_10_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_10;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_10;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 9;
                                STREAM_TO_XIKE        <= 16'b0000001000000000;
                              end
                          end
                          
                          MOSI_A <= MOSI_cmd_A[11];
                          MOSI_B <= MOSI_cmd_B[11];
                          MOSI_C <= MOSI_cmd_C[11];
                          MOSI_D <= MOSI_cmd_D[11];
                          in4x_A1[14] <= MISO_A1; in4x_A2[14] <= MISO_A2;
                          in4x_B1[14] <= MISO_B1; in4x_B2[14] <= MISO_B2;
                          in4x_C1[14] <= MISO_C1; in4x_C2[14] <= MISO_C2;
                          in4x_D1[14] <= MISO_D1; in4x_D2[14] <= MISO_D2;                
                          main_state <= ms_clk5_b;
                      end
      
                      ms_clk5_b: begin
                          if (data_stream_11_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_11;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_11;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 10;
                                STREAM_TO_XIKE        <= 16'b0000010000000000;
                              end
                          end
                          
                          in4x_A1[15] <= MISO_A1; in4x_A2[15] <= MISO_A2;
                          in4x_B1[15] <= MISO_B1; in4x_B2[15] <= MISO_B2;
                          in4x_C1[15] <= MISO_C1; in4x_C2[15] <= MISO_C2;
                          in4x_D1[15] <= MISO_D1; in4x_D2[15] <= MISO_D2;                
                          main_state <= ms_clk5_c;
                      end
      
                      ms_clk5_c: begin
                          if (data_stream_12_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_12;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_12;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 11;
                                STREAM_TO_XIKE        <= 16'b0000100000000000;
                              end
                          end
                          
                          SCLK <= 1'b1;
                          in4x_A1[16] <= MISO_A1; in4x_A2[16] <= MISO_A2;
                          in4x_B1[16] <= MISO_B1; in4x_B2[16] <= MISO_B2;
                          in4x_C1[16] <= MISO_C1; in4x_C2[16] <= MISO_C2;
                          in4x_D1[16] <= MISO_D1; in4x_D2[16] <= MISO_D2;                    
                          main_state <= ms_clk5_d;
                      end
                      
                      ms_clk5_d: begin
                          if (data_stream_13_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_13;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_13;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 12;
                                STREAM_TO_XIKE        <= 16'b0001000000000000;
                              end
                          end
                          
                          SCLK <= 1'b1;
                          in4x_A1[17] <= MISO_A1; in4x_A2[17] <= MISO_A2;
                          in4x_B1[17] <= MISO_B1; in4x_B2[17] <= MISO_B2;
                          in4x_C1[17] <= MISO_C1; in4x_C2[17] <= MISO_C2;
                          in4x_D1[17] <= MISO_D1; in4x_D2[17] <= MISO_D2;                
                          main_state <= ms_clk6_a;
                      end
                      
                      ms_clk6_a: begin
                          if (data_stream_14_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_14;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_14;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 13;
                                STREAM_TO_XIKE        <= 16'b0010000000000000;
                              end
                          end
                          
                          MOSI_A <= MOSI_cmd_A[10];
                          MOSI_B <= MOSI_cmd_B[10];
                          MOSI_C <= MOSI_cmd_C[10];
                          MOSI_D <= MOSI_cmd_D[10];
                          in4x_A1[18] <= MISO_A1; in4x_A2[18] <= MISO_A2;
                          in4x_B1[18] <= MISO_B1; in4x_B2[18] <= MISO_B2;
                          in4x_C1[18] <= MISO_C1; in4x_C2[18] <= MISO_C2;
                          in4x_D1[18] <= MISO_D1; in4x_D2[18] <= MISO_D2;                
                          main_state <= ms_clk6_b;
                      end
      
                      ms_clk6_b: begin
                          if (data_stream_15_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_15;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_15;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 14;
                                STREAM_TO_XIKE        <= 16'b0100000000000000;
                              end
                          end
                          
                          in4x_A1[19] <= MISO_A1; in4x_A2[19] <= MISO_A2;
                          in4x_B1[19] <= MISO_B1; in4x_B2[19] <= MISO_B2;
                          in4x_C1[19] <= MISO_C1; in4x_C2[19] <= MISO_C2;
                          in4x_D1[19] <= MISO_D1; in4x_D2[19] <= MISO_D2;                
                          main_state <= ms_clk6_c;
                      end
      
                      ms_clk6_c: begin
                          if (data_stream_16_en == 1'b1) begin
                              FIFO_DATA_STREAM      <= data_stream_16;
                              FIFO_DATA_STREAM_WEN  <= 1'b1;
                              if(channel_MISO <= 32 && channel_MISO > 0) begin
                                FIFO_DATA_TO_XIKE     <= data_stream_16;
                                FIFO_DATA_TO_XIKE_WEN <= 1'b1;
                                CHANNEL_TO_XIKE       <= channel_MISO - 1 + 32 * 15;
                                STREAM_TO_XIKE        <= 16'b1000000000000000;
                              end
                          end
                          
                          SCLK <= 1'b1;
                          in4x_A1[20] <= MISO_A1; in4x_A2[20] <= MISO_A2;
                          in4x_B1[20] <= MISO_B1; in4x_B2[20] <= MISO_B2;
                          in4x_C1[20] <= MISO_C1; in4x_C2[20] <= MISO_C2;
                          in4x_D1[20] <= MISO_D1; in4x_D2[20] <= MISO_D2;                    
                          main_state <= ms_clk6_d;
                      end
                      
                      ms_clk6_d: begin
                          SCLK <= 1'b1;
                          in4x_A1[21] <= MISO_A1; in4x_A2[21] <= MISO_A2;
                          in4x_B1[21] <= MISO_B1; in4x_B2[21] <= MISO_B2;
                          in4x_C1[21] <= MISO_C1; in4x_C2[21] <= MISO_C2;
                          in4x_D1[21] <= MISO_D1; in4x_D2[21] <= MISO_D2;                
                          main_state <= ms_clk7_a;
                      end
                      
                      ms_clk7_a: begin
                          MOSI_A <= MOSI_cmd_A[9];
                          MOSI_B <= MOSI_cmd_B[9];
                          MOSI_C <= MOSI_cmd_C[9];
                          MOSI_D <= MOSI_cmd_D[9];
                          in4x_A1[22] <= MISO_A1; in4x_A2[22] <= MISO_A2;
                          in4x_B1[22] <= MISO_B1; in4x_B2[22] <= MISO_B2;
                          in4x_C1[22] <= MISO_C1; in4x_C2[22] <= MISO_C2;
                          in4x_D1[22] <= MISO_D1; in4x_D2[22] <= MISO_D2;                
                          main_state <= ms_clk7_b;
                      end
      
                      ms_clk7_b: begin
                          in4x_A1[23] <= MISO_A1; in4x_A2[23] <= MISO_A2;
                          in4x_B1[23] <= MISO_B1; in4x_B2[23] <= MISO_B2;
                          in4x_C1[23] <= MISO_C1; in4x_C2[23] <= MISO_C2;
                          in4x_D1[23] <= MISO_D1; in4x_D2[23] <= MISO_D2;                
                          main_state <= ms_clk7_c;
                      end
      
                      ms_clk7_c: begin
                          SCLK <= 1'b1;
                          in4x_A1[24] <= MISO_A1; in4x_A2[24] <= MISO_A2;
                          in4x_B1[24] <= MISO_B1; in4x_B2[24] <= MISO_B2;
                          in4x_C1[24] <= MISO_C1; in4x_C2[24] <= MISO_C2;
                          in4x_D1[24] <= MISO_D1; in4x_D2[24] <= MISO_D2;                    
                          main_state <= ms_clk7_d;
                      end
                      
                      ms_clk7_d: begin
                          SCLK <= 1'b1;
                          in4x_A1[25] <= MISO_A1; in4x_A2[25] <= MISO_A2;
                          in4x_B1[25] <= MISO_B1; in4x_B2[25] <= MISO_B2;
                          in4x_C1[25] <= MISO_C1; in4x_C2[25] <= MISO_C2;
                          in4x_D1[25] <= MISO_D1; in4x_D2[25] <= MISO_D2;                
                          main_state <= ms_clk8_a;
                      end
      
                      ms_clk8_a: begin
                          MOSI_A <= MOSI_cmd_A[8];
                          MOSI_B <= MOSI_cmd_B[8];
                          MOSI_C <= MOSI_cmd_C[8];
                          MOSI_D <= MOSI_cmd_D[8];
                          in4x_A1[26] <= MISO_A1; in4x_A2[26] <= MISO_A2;
                          in4x_B1[26] <= MISO_B1; in4x_B2[26] <= MISO_B2;
                          in4x_C1[26] <= MISO_C1; in4x_C2[26] <= MISO_C2;
                          in4x_D1[26] <= MISO_D1; in4x_D2[26] <= MISO_D2;                
                          main_state <= ms_clk8_b;
                      end
      
                      ms_clk8_b: begin
                          in4x_A1[27] <= MISO_A1; in4x_A2[27] <= MISO_A2;
                          in4x_B1[27] <= MISO_B1; in4x_B2[27] <= MISO_B2;
                          in4x_C1[27] <= MISO_C1; in4x_C2[27] <= MISO_C2;
                          in4x_D1[27] <= MISO_D1; in4x_D2[27] <= MISO_D2;                
                          main_state <= ms_clk8_c;
                      end
      
                      ms_clk8_c: begin
                          SCLK <= 1'b1;
                          in4x_A1[28] <= MISO_A1; in4x_A2[28] <= MISO_A2;
                          in4x_B1[28] <= MISO_B1; in4x_B2[28] <= MISO_B2;
                          in4x_C1[28] <= MISO_C1; in4x_C2[28] <= MISO_C2;
                          in4x_D1[28] <= MISO_D1; in4x_D2[28] <= MISO_D2;                    
                          main_state <= ms_clk8_d;
                      end
                      
                      ms_clk8_d: begin
                          SCLK <= 1'b1;
                          in4x_A1[29] <= MISO_A1; in4x_A2[29] <= MISO_A2;
                          in4x_B1[29] <= MISO_B1; in4x_B2[29] <= MISO_B2;
                          in4x_C1[29] <= MISO_C1; in4x_C2[29] <= MISO_C2;
                          in4x_D1[29] <= MISO_D1; in4x_D2[29] <= MISO_D2;                
                          main_state <= ms_clk9_a;
                      end
      
                      ms_clk9_a: begin
                          MOSI_A <= MOSI_cmd_A[7];
                          MOSI_B <= MOSI_cmd_B[7];
                          MOSI_C <= MOSI_cmd_C[7];
                          MOSI_D <= MOSI_cmd_D[7];
                          in4x_A1[30] <= MISO_A1; in4x_A2[30] <= MISO_A2;
                          in4x_B1[30] <= MISO_B1; in4x_B2[30] <= MISO_B2;
                          in4x_C1[30] <= MISO_C1; in4x_C2[30] <= MISO_C2;
                          in4x_D1[30] <= MISO_D1; in4x_D2[30] <= MISO_D2;                
                          main_state <= ms_clk9_b;
                      end
      
                      ms_clk9_b: begin
                          in4x_A1[31] <= MISO_A1; in4x_A2[31] <= MISO_A2;
                          in4x_B1[31] <= MISO_B1; in4x_B2[31] <= MISO_B2;
                          in4x_C1[31] <= MISO_C1; in4x_C2[31] <= MISO_C2;
                          in4x_D1[31] <= MISO_D1; in4x_D2[31] <= MISO_D2;                
                          main_state <= ms_clk9_c;
                      end
      
                      ms_clk9_c: begin
                          SCLK <= 1'b1;
                          in4x_A1[32] <= MISO_A1; in4x_A2[32] <= MISO_A2;
                          in4x_B1[32] <= MISO_B1; in4x_B2[32] <= MISO_B2;
                          in4x_C1[32] <= MISO_C1; in4x_C2[32] <= MISO_C2;
                          in4x_D1[32] <= MISO_D1; in4x_D2[32] <= MISO_D2;                    
                          main_state <= ms_clk9_d;
                      end
                      
                      ms_clk9_d: begin
                          SCLK <= 1'b1;
                          in4x_A1[33] <= MISO_A1; in4x_A2[33] <= MISO_A2;
                          in4x_B1[33] <= MISO_B1; in4x_B2[33] <= MISO_B2;
                          in4x_C1[33] <= MISO_C1; in4x_C2[33] <= MISO_C2;
                          in4x_D1[33] <= MISO_D1; in4x_D2[33] <= MISO_D2;                
                          main_state <= ms_clk10_a;
                      end
      
                      ms_clk10_a: begin
                          MOSI_A <= MOSI_cmd_A[6];
                          MOSI_B <= MOSI_cmd_B[6];
                          MOSI_C <= MOSI_cmd_C[6];
                          MOSI_D <= MOSI_cmd_D[6];
                          in4x_A1[34] <= MISO_A1; in4x_A2[34] <= MISO_A2;
                          in4x_B1[34] <= MISO_B1; in4x_B2[34] <= MISO_B2;
                          in4x_C1[34] <= MISO_C1; in4x_C2[34] <= MISO_C2;
                          in4x_D1[34] <= MISO_D1; in4x_D2[34] <= MISO_D2;                
                          main_state <= ms_clk10_b;
                      end
      
                      ms_clk10_b: begin
                          in4x_A1[35] <= MISO_A1; in4x_A2[35] <= MISO_A2;
                          in4x_B1[35] <= MISO_B1; in4x_B2[35] <= MISO_B2;
                          in4x_C1[35] <= MISO_C1; in4x_C2[35] <= MISO_C2;
                          in4x_D1[35] <= MISO_D1; in4x_D2[35] <= MISO_D2;                
                          main_state <= ms_clk10_c;
                      end
      
                      ms_clk10_c: begin
                          SCLK <= 1'b1;
                          in4x_A1[36] <= MISO_A1; in4x_A2[36] <= MISO_A2;
                          in4x_B1[36] <= MISO_B1; in4x_B2[36] <= MISO_B2;
                          in4x_C1[36] <= MISO_C1; in4x_C2[36] <= MISO_C2;
                          in4x_D1[36] <= MISO_D1; in4x_D2[36] <= MISO_D2;                    
                          main_state <= ms_clk10_d;
                      end
                      
                      ms_clk10_d: begin
                          SCLK <= 1'b1;
                          in4x_A1[37] <= MISO_A1; in4x_A2[37] <= MISO_A2;
                          in4x_B1[37] <= MISO_B1; in4x_B2[37] <= MISO_B2;
                          in4x_C1[37] <= MISO_C1; in4x_C2[37] <= MISO_C2;
                          in4x_D1[37] <= MISO_D1; in4x_D2[37] <= MISO_D2;                
                          main_state <= ms_clk11_a;
                      end
      
                      ms_clk11_a: begin
                          MOSI_A <= MOSI_cmd_A[5];
                          MOSI_B <= MOSI_cmd_B[5];
                          MOSI_C <= MOSI_cmd_C[5];
                          MOSI_D <= MOSI_cmd_D[5];
                          in4x_A1[38] <= MISO_A1; in4x_A2[38] <= MISO_A2;
                          in4x_B1[38] <= MISO_B1; in4x_B2[38] <= MISO_B2;
                          in4x_C1[38] <= MISO_C1; in4x_C2[38] <= MISO_C2;
                          in4x_D1[38] <= MISO_D1; in4x_D2[38] <= MISO_D2;                
                          main_state <= ms_clk11_b;
                      end
      
                      ms_clk11_b: begin
                          in4x_A1[39] <= MISO_A1; in4x_A2[39] <= MISO_A2;
                          in4x_B1[39] <= MISO_B1; in4x_B2[39] <= MISO_B2;
                          in4x_C1[39] <= MISO_C1; in4x_C2[39] <= MISO_C2;
                          in4x_D1[39] <= MISO_D1; in4x_D2[39] <= MISO_D2;                
                          main_state <= ms_clk11_c;
                      end
      
                      ms_clk11_c: begin
                          SCLK <= 1'b1;
                          in4x_A1[40] <= MISO_A1; in4x_A2[40] <= MISO_A2;
                          in4x_B1[40] <= MISO_B1; in4x_B2[40] <= MISO_B2;
                          in4x_C1[40] <= MISO_C1; in4x_C2[40] <= MISO_C2;
                          in4x_D1[40] <= MISO_D1; in4x_D2[40] <= MISO_D2;                    
                          main_state <= ms_clk11_d;
                      end
                      
                      ms_clk11_d: begin
                          SCLK <= 1'b1;
                          in4x_A1[41] <= MISO_A1; in4x_A2[41] <= MISO_A2;
                          in4x_B1[41] <= MISO_B1; in4x_B2[41] <= MISO_B2;
                          in4x_C1[41] <= MISO_C1; in4x_C2[41] <= MISO_C2;
                          in4x_D1[41] <= MISO_D1; in4x_D2[41] <= MISO_D2;                
                          main_state <= ms_clk12_a;
                      end
      
                      ms_clk12_a: begin
                          MOSI_A <= MOSI_cmd_A[4];
                          MOSI_B <= MOSI_cmd_B[4];
                          MOSI_C <= MOSI_cmd_C[4];
                          MOSI_D <= MOSI_cmd_D[4];
                          in4x_A1[42] <= MISO_A1; in4x_A2[42] <= MISO_A2;
                          in4x_B1[42] <= MISO_B1; in4x_B2[42] <= MISO_B2;
                          in4x_C1[42] <= MISO_C1; in4x_C2[42] <= MISO_C2;
                          in4x_D1[42] <= MISO_D1; in4x_D2[42] <= MISO_D2;                
                          main_state <= ms_clk12_b;
                      end
      
                      ms_clk12_b: begin
                          in4x_A1[43] <= MISO_A1; in4x_A2[43] <= MISO_A2;
                          in4x_B1[43] <= MISO_B1; in4x_B2[43] <= MISO_B2;
                          in4x_C1[43] <= MISO_C1; in4x_C2[43] <= MISO_C2;
                          in4x_D1[43] <= MISO_D1; in4x_D2[43] <= MISO_D2;                
                          main_state <= ms_clk12_c;
                      end
      
                      ms_clk12_c: begin
                          SCLK <= 1'b1;
                          in4x_A1[44] <= MISO_A1; in4x_A2[44] <= MISO_A2;
                          in4x_B1[44] <= MISO_B1; in4x_B2[44] <= MISO_B2;
                          in4x_C1[44] <= MISO_C1; in4x_C2[44] <= MISO_C2;
                          in4x_D1[44] <= MISO_D1; in4x_D2[44] <= MISO_D2;                    
                          main_state <= ms_clk12_d;
                      end
                      
                      ms_clk12_d: begin
                          SCLK <= 1'b1;
                          in4x_A1[45] <= MISO_A1; in4x_A2[45] <= MISO_A2;
                          in4x_B1[45] <= MISO_B1; in4x_B2[45] <= MISO_B2;
                          in4x_C1[45] <= MISO_C1; in4x_C2[45] <= MISO_C2;
                          in4x_D1[45] <= MISO_D1; in4x_D2[45] <= MISO_D2;                
                          main_state <= ms_clk13_a;
                      end
      
                      ms_clk13_a: begin
                          MOSI_A <= MOSI_cmd_A[3];
                          MOSI_B <= MOSI_cmd_B[3];
                          MOSI_C <= MOSI_cmd_C[3];
                          MOSI_D <= MOSI_cmd_D[3];
                          in4x_A1[46] <= MISO_A1; in4x_A2[46] <= MISO_A2;
                          in4x_B1[46] <= MISO_B1; in4x_B2[46] <= MISO_B2;
                          in4x_C1[46] <= MISO_C1; in4x_C2[46] <= MISO_C2;
                          in4x_D1[46] <= MISO_D1; in4x_D2[46] <= MISO_D2;                
                          main_state <= ms_clk13_b;
                      end
      
                      ms_clk13_b: begin
                          in4x_A1[47] <= MISO_A1; in4x_A2[47] <= MISO_A2;
                          in4x_B1[47] <= MISO_B1; in4x_B2[47] <= MISO_B2;
                          in4x_C1[47] <= MISO_C1; in4x_C2[47] <= MISO_C2;
                          in4x_D1[47] <= MISO_D1; in4x_D2[47] <= MISO_D2;                
                          main_state <= ms_clk13_c;
                      end
      
                      ms_clk13_c: begin
                          SCLK <= 1'b1;
                          in4x_A1[48] <= MISO_A1; in4x_A2[48] <= MISO_A2;
                          in4x_B1[48] <= MISO_B1; in4x_B2[48] <= MISO_B2;
                          in4x_C1[48] <= MISO_C1; in4x_C2[48] <= MISO_C2;
                          in4x_D1[48] <= MISO_D1; in4x_D2[48] <= MISO_D2;                    
                          main_state <= ms_clk13_d;
                      end
                      
                      ms_clk13_d: begin
                          if (data_stream_1_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[49] <= MISO_A1; in4x_A2[49] <= MISO_A2;
                          in4x_B1[49] <= MISO_B1; in4x_B2[49] <= MISO_B2;
                          in4x_C1[49] <= MISO_C1; in4x_C2[49] <= MISO_C2;
                          in4x_D1[49] <= MISO_D1; in4x_D2[49] <= MISO_D2;                
                          main_state <= ms_clk14_a;
                      end
      
                      ms_clk14_a: begin
                          if (data_stream_2_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          MOSI_A <= MOSI_cmd_A[2];
                          MOSI_B <= MOSI_cmd_B[2];
                          MOSI_C <= MOSI_cmd_C[2];
                          MOSI_D <= MOSI_cmd_D[2];
                          in4x_A1[50] <= MISO_A1; in4x_A2[50] <= MISO_A2;
                          in4x_B1[50] <= MISO_B1; in4x_B2[50] <= MISO_B2;
                          in4x_C1[50] <= MISO_C1; in4x_C2[50] <= MISO_C2;
                          in4x_D1[50] <= MISO_D1; in4x_D2[50] <= MISO_D2;                
                          main_state <= ms_clk14_b;
                      end
      
                      ms_clk14_b: begin
                          if (data_stream_3_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          in4x_A1[51] <= MISO_A1; in4x_A2[51] <= MISO_A2;
                          in4x_B1[51] <= MISO_B1; in4x_B2[51] <= MISO_B2;
                          in4x_C1[51] <= MISO_C1; in4x_C2[51] <= MISO_C2;
                          in4x_D1[51] <= MISO_D1; in4x_D2[51] <= MISO_D2;                
                          main_state <= ms_clk14_c;
                      end
      
                      ms_clk14_c: begin
                          if (data_stream_4_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[52] <= MISO_A1; in4x_A2[52] <= MISO_A2;
                          in4x_B1[52] <= MISO_B1; in4x_B2[52] <= MISO_B2;
                          in4x_C1[52] <= MISO_C1; in4x_C2[52] <= MISO_C2;
                          in4x_D1[52] <= MISO_D1; in4x_D2[52] <= MISO_D2;                    
                          main_state <= ms_clk14_d;
                      end
                      
                      ms_clk14_d: begin
                          if (data_stream_5_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[53] <= MISO_A1; in4x_A2[53] <= MISO_A2;
                          in4x_B1[53] <= MISO_B1; in4x_B2[53] <= MISO_B2;
                          in4x_C1[53] <= MISO_C1; in4x_C2[53] <= MISO_C2;
                          in4x_D1[53] <= MISO_D1; in4x_D2[53] <= MISO_D2;                
                          main_state <= ms_clk15_a;
                      end
      
                      ms_clk15_a: begin
                          if (data_stream_6_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          MOSI_A <= MOSI_cmd_A[1];
                          MOSI_B <= MOSI_cmd_B[1];
                          MOSI_C <= MOSI_cmd_C[1];
                          MOSI_D <= MOSI_cmd_D[1];
                          in4x_A1[54] <= MISO_A1; in4x_A2[54] <= MISO_A2;
                          in4x_B1[54] <= MISO_B1; in4x_B2[54] <= MISO_B2;
                          in4x_C1[54] <= MISO_C1; in4x_C2[54] <= MISO_C2;
                          in4x_D1[54] <= MISO_D1; in4x_D2[54] <= MISO_D2;                
                          main_state <= ms_clk15_b;
                      end
      
                      ms_clk15_b: begin
                          if (data_stream_7_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          in4x_A1[55] <= MISO_A1; in4x_A2[55] <= MISO_A2;
                          in4x_B1[55] <= MISO_B1; in4x_B2[55] <= MISO_B2;
                          in4x_C1[55] <= MISO_C1; in4x_C2[55] <= MISO_C2;
                          in4x_D1[55] <= MISO_D1; in4x_D2[55] <= MISO_D2;                
                          main_state <= ms_clk15_c;
                      end
      
                      ms_clk15_c: begin
                          if (data_stream_8_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[56] <= MISO_A1; in4x_A2[56] <= MISO_A2;
                          in4x_B1[56] <= MISO_B1; in4x_B2[56] <= MISO_B2;
                          in4x_C1[56] <= MISO_C1; in4x_C2[56] <= MISO_C2;
                          in4x_D1[56] <= MISO_D1; in4x_D2[56] <= MISO_D2;                    
                          main_state <= ms_clk15_d;
                      end
                      
                      ms_clk15_d: begin
                          if (data_stream_9_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[57] <= MISO_A1; in4x_A2[57] <= MISO_A2;
                          in4x_B1[57] <= MISO_B1; in4x_B2[57] <= MISO_B2;
                          in4x_C1[57] <= MISO_C1; in4x_C2[57] <= MISO_C2;
                          in4x_D1[57] <= MISO_D1; in4x_D2[57] <= MISO_D2;                
                          main_state <= ms_clk16_a;
                      end
      
                      ms_clk16_a: begin
                          if (data_stream_10_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          MOSI_A <= MOSI_cmd_A[0];
                          MOSI_B <= MOSI_cmd_B[0];
                          MOSI_C <= MOSI_cmd_C[0];
                          MOSI_D <= MOSI_cmd_D[0];
                          in4x_A1[58] <= MISO_A1; in4x_A2[58] <= MISO_A2;
                          in4x_B1[58] <= MISO_B1; in4x_B2[58] <= MISO_B2;
                          in4x_C1[58] <= MISO_C1; in4x_C2[58] <= MISO_C2;
                          in4x_D1[58] <= MISO_D1; in4x_D2[58] <= MISO_D2;                
                          main_state <= ms_clk16_b;
                      end
      
                      ms_clk16_b: begin
                          if (data_stream_11_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          in4x_A1[59] <= MISO_A1; in4x_A2[59] <= MISO_A2;
                          in4x_B1[59] <= MISO_B1; in4x_B2[59] <= MISO_B2;
                          in4x_C1[59] <= MISO_C1; in4x_C2[59] <= MISO_C2;
                          in4x_D1[59] <= MISO_D1; in4x_D2[59] <= MISO_D2;                
                          main_state <= ms_clk16_c;
                      end
      
                      ms_clk16_c: begin
                          if (data_stream_12_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[60] <= MISO_A1; in4x_A2[60] <= MISO_A2;
                          in4x_B1[60] <= MISO_B1; in4x_B2[60] <= MISO_B2;
                          in4x_C1[60] <= MISO_C1; in4x_C2[60] <= MISO_C2;
                          in4x_D1[60] <= MISO_D1; in4x_D2[60] <= MISO_D2;                    
                          main_state <= ms_clk16_d;
                      end
                      
                      ms_clk16_d: begin
                          if (data_stream_13_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          SCLK <= 1'b1;
                          in4x_A1[61] <= MISO_A1; in4x_A2[61] <= MISO_A2;
                          in4x_B1[61] <= MISO_B1; in4x_B2[61] <= MISO_B2;
                          in4x_C1[61] <= MISO_C1; in4x_C2[61] <= MISO_C2;
                          in4x_D1[61] <= MISO_D1; in4x_D2[61] <= MISO_D2;                
                          main_state <= ms_clk17_a;
                      end
      
                      ms_clk17_a: begin
                          if (data_stream_14_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          MOSI_A <= 1'b0;
                          MOSI_B <= 1'b0;
                          MOSI_C <= 1'b0;
                          MOSI_D <= 1'b0;
                          in4x_A1[62] <= MISO_A1; in4x_A2[62] <= MISO_A2;
                          in4x_B1[62] <= MISO_B1; in4x_B2[62] <= MISO_B2;
                          in4x_C1[62] <= MISO_C1; in4x_C2[62] <= MISO_C2;
                          in4x_D1[62] <= MISO_D1; in4x_D2[62] <= MISO_D2;                
                          main_state <= ms_clk17_b;
                      end
      
                      ms_clk17_b: begin
                          if (data_stream_15_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          in4x_A1[63] <= MISO_A1; in4x_A2[63] <= MISO_A2;
                          in4x_B1[63] <= MISO_B1; in4x_B2[63] <= MISO_B2;
                          in4x_C1[63] <= MISO_C1; in4x_C2[63] <= MISO_C2;
                          in4x_D1[63] <= MISO_D1; in4x_D2[63] <= MISO_D2;                
                          main_state <= ms_cs_a;
                      end
      
                      ms_cs_a: begin
                          if (data_stream_16_en == 1'b1 && channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_filler;    // Send a 36th 'filler' sample to keep number of samples divisible by four
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end
      
                          CS <= 1'b1;
                          in4x_A1[64] <= MISO_A1; in4x_A2[64] <= MISO_A2;
                          in4x_B1[64] <= MISO_B1; in4x_B2[64] <= MISO_B2;
                          in4x_C1[64] <= MISO_C1; in4x_C2[64] <= MISO_C2;
                          in4x_D1[64] <= MISO_D1; in4x_D2[64] <= MISO_D2;                
                          main_state <= ms_cs_b;
                      end
      
                      ms_cs_b: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_1;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[65] <= MISO_A1; in4x_A2[65] <= MISO_A2;
                          in4x_B1[65] <= MISO_B1; in4x_B2[65] <= MISO_B2;
                          in4x_C1[65] <= MISO_C1; in4x_C2[65] <= MISO_C2;
                          in4x_D1[65] <= MISO_D1; in4x_D2[65] <= MISO_D2;                
                          main_state <= ms_cs_c;
                      end
      
                      ms_cs_c: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_2;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[66] <= MISO_A1; in4x_A2[66] <= MISO_A2;
                          in4x_B1[66] <= MISO_B1; in4x_B2[66] <= MISO_B2;
                          in4x_C1[66] <= MISO_C1; in4x_C2[66] <= MISO_C2;
                          in4x_D1[66] <= MISO_D1; in4x_D2[66] <= MISO_D2;                
                          main_state <= ms_cs_d;
                      end
                      
                      ms_cs_d: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_3;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[67] <= MISO_A1; in4x_A2[67] <= MISO_A2;
                          in4x_B1[67] <= MISO_B1; in4x_B2[67] <= MISO_B2;
                          in4x_C1[67] <= MISO_C1; in4x_C2[67] <= MISO_C2;
                          in4x_D1[67] <= MISO_D1; in4x_D2[67] <= MISO_D2;                
                          main_state <= ms_cs_e;
                      end
                      
                      ms_cs_e: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_4;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[68] <= MISO_A1; in4x_A2[68] <= MISO_A2;
                          in4x_B1[68] <= MISO_B1; in4x_B2[68] <= MISO_B2;
                          in4x_C1[68] <= MISO_C1; in4x_C2[68] <= MISO_C2;
                          in4x_D1[68] <= MISO_D1; in4x_D2[68] <= MISO_D2;                
                          main_state <= ms_cs_f;
                      end
                      
                      ms_cs_f: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_5;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[69] <= MISO_A1; in4x_A2[69] <= MISO_A2;
                          in4x_B1[69] <= MISO_B1; in4x_B2[69] <= MISO_B2;
                          in4x_C1[69] <= MISO_C1; in4x_C2[69] <= MISO_C2;
                          in4x_D1[69] <= MISO_D1; in4x_D2[69] <= MISO_D2;                
                          main_state <= ms_cs_g;
                      end
                      
                      ms_cs_g: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_6;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[70] <= MISO_A1; in4x_A2[70] <= MISO_A2;
                          in4x_B1[70] <= MISO_B1; in4x_B2[70] <= MISO_B2;
                          in4x_C1[70] <= MISO_C1; in4x_C2[70] <= MISO_C2;
                          in4x_D1[70] <= MISO_D1; in4x_D2[70] <= MISO_D2;                
                          main_state <= ms_cs_h;
                      end
                      
                      ms_cs_h: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_7;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[71] <= MISO_A1; in4x_A2[71] <= MISO_A2;
                          in4x_B1[71] <= MISO_B1; in4x_B2[71] <= MISO_B2;
                          in4x_C1[71] <= MISO_C1; in4x_C2[71] <= MISO_C2;
                          in4x_D1[71] <= MISO_D1; in4x_D2[71] <= MISO_D2;                
                          main_state <= ms_cs_i;
                      end
                      
                      ms_cs_i: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_ADC_8;    // Write evaluation-board ADC samples
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[72] <= MISO_A1; in4x_A2[72] <= MISO_A2;
                          in4x_B1[72] <= MISO_B1; in4x_B2[72] <= MISO_B2;
                          in4x_C1[72] <= MISO_C1; in4x_C2[72] <= MISO_C2;
                          in4x_D1[72] <= MISO_D1; in4x_D2[72] <= MISO_D2;                
                          main_state <= ms_cs_j;
                      end
                      
                      ms_cs_j: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_TTL_in;    // Write TTL inputs
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          in4x_A1[73] <= MISO_A1; in4x_A2[73] <= MISO_A2;
                          in4x_B1[73] <= MISO_B1; in4x_B2[73] <= MISO_B2;
                          in4x_C1[73] <= MISO_C1; in4x_C2[73] <= MISO_C2;
                          in4x_D1[73] <= MISO_D1; in4x_D2[73] <= MISO_D2;                
                          main_state <= ms_cs_k;
                      end
                      
                      ms_cs_k: begin
                          if (channel == 34) begin
                              FIFO_DATA_STREAM <= data_stream_TTL_out;    // Write current value of TTL outputs so users can reconstruct exact timings
                              FIFO_DATA_STREAM_WEN <= 1'b1;
                          end                    
      
                          CS <= 1'b1;
                          result_A1 <= in_A1; result_A2 <= in_A2;
                          result_B1 <= in_B1; result_B2 <= in_B2;
                          result_C1 <= in_C1; result_C2 <= in_C2;
                          result_D1 <= in_D1; result_D2 <= in_D2;
                          result_DDR_A1 <= in_DDR_A1; result_DDR_A2 <= in_DDR_A2;
                          result_DDR_B1 <= in_DDR_B1; result_DDR_B2 <= in_DDR_B2;
                          result_DDR_C1 <= in_DDR_C1; result_DDR_C2 <= in_DDR_C2;
                          result_DDR_D1 <= in_DDR_D1; result_DDR_D2 <= in_DDR_D2;
                          main_state <= ms_cs_l;
                      end
                      
                      ms_cs_l: begin
                          if (channel == 34) begin
                              if (aux_cmd_index_1 == max_aux_cmd_index_1) begin
                                  aux_cmd_index_1 <= loop_aux_cmd_index_1;
                                  max_aux_cmd_index_1 <= max_aux_cmd_index_1_in;
                                  aux_cmd_bank_1_A <= aux_cmd_bank_1_A_in;
                                  aux_cmd_bank_1_B <= aux_cmd_bank_1_B_in;
                                  aux_cmd_bank_1_C <= aux_cmd_bank_1_C_in;
                                  aux_cmd_bank_1_D <= aux_cmd_bank_1_D_in;
                              end else begin
                                  aux_cmd_index_1 <= aux_cmd_index_1 + 1;
                              end
                              if (aux_cmd_index_2 == max_aux_cmd_index_2) begin
                                  aux_cmd_index_2 <= loop_aux_cmd_index_2;
                                  max_aux_cmd_index_2 <= max_aux_cmd_index_2_in;
                                  aux_cmd_bank_2_A <= aux_cmd_bank_2_A_in;
                                  aux_cmd_bank_2_B <= aux_cmd_bank_2_B_in;
                                  aux_cmd_bank_2_C <= aux_cmd_bank_2_C_in;
                                  aux_cmd_bank_2_D <= aux_cmd_bank_2_D_in;
                              end else begin
                                  aux_cmd_index_2 <= aux_cmd_index_2 + 1;
                              end
                              if (aux_cmd_index_3 == max_aux_cmd_index_3) begin
                                  aux_cmd_index_3 <= loop_aux_cmd_index_3;
                                  max_aux_cmd_index_3 <= max_aux_cmd_index_3_in;
                                  aux_cmd_bank_3_A <= aux_cmd_bank_3_A_in;
                                  aux_cmd_bank_3_B <= aux_cmd_bank_3_B_in;
                                  aux_cmd_bank_3_C <= aux_cmd_bank_3_C_in;
                                  aux_cmd_bank_3_D <= aux_cmd_bank_3_D_in;
                              end else begin
                                  aux_cmd_index_3 <= aux_cmd_index_3 + 1;
                              end
                          end
              
                          if (channel == 0) begin
                              timestamp <= timestamp + 1;
                          end
                          CS <= 1'b1;            
                          main_state <= ms_cs_m;
                      end
                      
                      ms_cs_m: begin
                          if (channel == 34) begin
                              channel <= 0;
                          end else begin
                              channel <= channel + 1;
                          end
                          if (channel_MISO == 34) begin
                              channel_MISO <= 0;
                          end else begin
                              channel_MISO <= channel_MISO + 1;
                          end
                          CS <= 1'b1;    
                          
                          if (channel == 34) begin
                              if (SPI_run_continuous) begin        // run continuously if SPI_run_continuous == 1
                                  main_state <= ms_cs_n;
                              end else begin
                                  if (timestamp == max_timestep || max_timestep == 32'b0) begin  // stop if max_timestep reached, or if max_timestep == 0
                                      main_state <= ms_wait;
                                  end else begin
                                      main_state <= ms_cs_n;
                                  end
                              end
                          end else begin
                              main_state <= ms_cs_n;
                          end
                      end
                                      
                      default: begin
                          main_state <= ms_wait;
                      end
                      
                  endcase
              end
          end   
          
  MISO_phase_selector_4x MISO_generator (
    .delay_A   (delay_A  ),
    .delay_B   (delay_B  ),
    .delay_C   (delay_C  ),
    .delay_D   (delay_D  ),
    .in4x_A1   (in4x_A1  ),
    .in4x_A2   (in4x_A2  ),
    .in4x_B1   (in4x_B1  ),
    .in4x_B2   (in4x_B2  ),
    .in4x_C1   (in4x_C1  ),
    .in4x_C2   (in4x_C2  ),
    .in4x_D1   (in4x_D1  ),
    .in4x_D2   (in4x_D2  ),
    .out_A1    (in_A1    ),
    .out_A2    (in_A2    ),
    .out_B1    (in_B1    ),
    .out_B2    (in_B2    ),
    .out_C1    (in_C1    ),
    .out_C2    (in_C2    ),
    .out_D1    (in_D1    ),
    .out_D2    (in_D2    ),
    .out_DDR_A1(in_DDR_A1),
    .out_DDR_A2(in_DDR_A2),
    .out_DDR_B1(in_DDR_B1),
    .out_DDR_B2(in_DDR_B2),
    .out_DDR_C1(in_DDR_C1),
    .out_DDR_C2(in_DDR_C2),
    .out_DDR_D1(in_DDR_D1),
    .out_DDR_D2(in_DDR_D2)
  );

  always @(*) begin
    case (data_stream_1_sel)
      0:        data_stream_1 <= result_A1;
      1:        data_stream_1 <= result_A2;
      2:        data_stream_1 <= result_B1;
      3:        data_stream_1 <= result_B2;
      4:        data_stream_1 <= result_C1;
      5:        data_stream_1 <= result_C2;
      6:        data_stream_1 <= result_D1;
      7:        data_stream_1 <= result_D2;
      8:     data_stream_1 <= result_DDR_A1;
      9:     data_stream_1 <= result_DDR_A2;
      10:    data_stream_1 <= result_DDR_B1;
      11:    data_stream_1 <= result_DDR_B2;
      12:    data_stream_1 <= result_DDR_C1;
      13:    data_stream_1 <= result_DDR_C2;
      14:    data_stream_1 <= result_DDR_D1;
      15:    data_stream_1 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_2_sel)
      0:        data_stream_2 <= result_A1;
      1:        data_stream_2 <= result_A2;
      2:        data_stream_2 <= result_B1;
      3:        data_stream_2 <= result_B2;
      4:        data_stream_2 <= result_C1;
      5:        data_stream_2 <= result_C2;
      6:        data_stream_2 <= result_D1;
      7:        data_stream_2 <= result_D2;
      8:     data_stream_2 <= result_DDR_A1;
      9:     data_stream_2 <= result_DDR_A2;
      10:    data_stream_2 <= result_DDR_B1;
      11:    data_stream_2 <= result_DDR_B2;
      12:    data_stream_2 <= result_DDR_C1;
      13:    data_stream_2 <= result_DDR_C2;
      14:    data_stream_2 <= result_DDR_D1;
      15:    data_stream_2 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_3_sel)
      0:        data_stream_3 <= result_A1;
      1:        data_stream_3 <= result_A2;
      2:        data_stream_3 <= result_B1;
      3:        data_stream_3 <= result_B2;
      4:        data_stream_3 <= result_C1;
      5:        data_stream_3 <= result_C2;
      6:        data_stream_3 <= result_D1;
      7:        data_stream_3 <= result_D2;
      8:     data_stream_3 <= result_DDR_A1;
      9:     data_stream_3 <= result_DDR_A2;
      10:    data_stream_3 <= result_DDR_B1;
      11:    data_stream_3 <= result_DDR_B2;
      12:    data_stream_3 <= result_DDR_C1;
      13:    data_stream_3 <= result_DDR_C2;
      14:    data_stream_3 <= result_DDR_D1;
      15:    data_stream_3 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_4_sel)
      0:        data_stream_4 <= result_A1;
      1:        data_stream_4 <= result_A2;
      2:        data_stream_4 <= result_B1;
      3:        data_stream_4 <= result_B2;
      4:        data_stream_4 <= result_C1;
      5:        data_stream_4 <= result_C2;
      6:        data_stream_4 <= result_D1;
      7:        data_stream_4 <= result_D2;
      8:     data_stream_4 <= result_DDR_A1;
      9:     data_stream_4 <= result_DDR_A2;
      10:    data_stream_4 <= result_DDR_B1;
      11:    data_stream_4 <= result_DDR_B2;
      12:    data_stream_4 <= result_DDR_C1;
      13:    data_stream_4 <= result_DDR_C2;
      14:    data_stream_4 <= result_DDR_D1;
      15:    data_stream_4 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_5_sel)
      0:        data_stream_5 <= result_A1;
      1:        data_stream_5 <= result_A2;
      2:        data_stream_5 <= result_B1;
      3:        data_stream_5 <= result_B2;
      4:        data_stream_5 <= result_C1;
      5:        data_stream_5 <= result_C2;
      6:        data_stream_5 <= result_D1;
      7:        data_stream_5 <= result_D2;
      8:     data_stream_5 <= result_DDR_A1;
      9:     data_stream_5 <= result_DDR_A2;
      10:    data_stream_5 <= result_DDR_B1;
      11:    data_stream_5 <= result_DDR_B2;
      12:    data_stream_5 <= result_DDR_C1;
      13:    data_stream_5 <= result_DDR_C2;
      14:    data_stream_5 <= result_DDR_D1;
      15:    data_stream_5 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_6_sel)
      0:        data_stream_6 <= result_A1;
      1:        data_stream_6 <= result_A2;
      2:        data_stream_6 <= result_B1;
      3:        data_stream_6 <= result_B2;
      4:        data_stream_6 <= result_C1;
      5:        data_stream_6 <= result_C2;
      6:        data_stream_6 <= result_D1;
      7:        data_stream_6 <= result_D2;
      8:     data_stream_6 <= result_DDR_A1;
      9:     data_stream_6 <= result_DDR_A2;
      10:    data_stream_6 <= result_DDR_B1;
      11:    data_stream_6 <= result_DDR_B2;
      12:    data_stream_6 <= result_DDR_C1;
      13:    data_stream_6 <= result_DDR_C2;
      14:    data_stream_6 <= result_DDR_D1;
      15:    data_stream_6 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_7_sel)
      0:        data_stream_7 <= result_A1;
      1:        data_stream_7 <= result_A2;
      2:        data_stream_7 <= result_B1;
      3:        data_stream_7 <= result_B2;
      4:        data_stream_7 <= result_C1;
      5:        data_stream_7 <= result_C2;
      6:        data_stream_7 <= result_D1;
      7:        data_stream_7 <= result_D2;
      8:     data_stream_7 <= result_DDR_A1;
      9:     data_stream_7 <= result_DDR_A2;
      10:    data_stream_7 <= result_DDR_B1;
      11:    data_stream_7 <= result_DDR_B2;
      12:    data_stream_7 <= result_DDR_C1;
      13:    data_stream_7 <= result_DDR_C2;
      14:    data_stream_7 <= result_DDR_D1;
      15:    data_stream_7 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_8_sel)
      0:        data_stream_8 <= result_A1;
      1:        data_stream_8 <= result_A2;
      2:        data_stream_8 <= result_B1;
      3:        data_stream_8 <= result_B2;
      4:        data_stream_8 <= result_C1;
      5:        data_stream_8 <= result_C2;
      6:        data_stream_8 <= result_D1;
      7:        data_stream_8 <= result_D2;
      8:     data_stream_8 <= result_DDR_A1;
      9:     data_stream_8 <= result_DDR_A2;
      10:    data_stream_8 <= result_DDR_B1;
      11:    data_stream_8 <= result_DDR_B2;
      12:    data_stream_8 <= result_DDR_C1;
      13:    data_stream_8 <= result_DDR_C2;
      14:    data_stream_8 <= result_DDR_D1;
      15:    data_stream_8 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_9_sel)
      0:        data_stream_9 <= result_A1;
      1:        data_stream_9 <= result_A2;
      2:        data_stream_9 <= result_B1;
      3:        data_stream_9 <= result_B2;
      4:        data_stream_9 <= result_C1;
      5:        data_stream_9 <= result_C2;
      6:        data_stream_9 <= result_D1;
      7:        data_stream_9 <= result_D2;
      8:     data_stream_9 <= result_DDR_A1;
      9:     data_stream_9 <= result_DDR_A2;
      10:    data_stream_9 <= result_DDR_B1;
      11:    data_stream_9 <= result_DDR_B2;
      12:    data_stream_9 <= result_DDR_C1;
      13:    data_stream_9 <= result_DDR_C2;
      14:    data_stream_9 <= result_DDR_D1;
      15:    data_stream_9 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_10_sel)
      0:        data_stream_10 <= result_A1;
      1:        data_stream_10 <= result_A2;
      2:        data_stream_10 <= result_B1;
      3:        data_stream_10 <= result_B2;
      4:        data_stream_10 <= result_C1;
      5:        data_stream_10 <= result_C2;
      6:        data_stream_10 <= result_D1;
      7:        data_stream_10 <= result_D2;
      8:     data_stream_10 <= result_DDR_A1;
      9:     data_stream_10 <= result_DDR_A2;
      10:    data_stream_10 <= result_DDR_B1;
      11:    data_stream_10 <= result_DDR_B2;
      12:    data_stream_10 <= result_DDR_C1;
      13:    data_stream_10 <= result_DDR_C2;
      14:    data_stream_10 <= result_DDR_D1;
      15:    data_stream_10 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_11_sel)
      0:        data_stream_11 <= result_A1;
      1:        data_stream_11 <= result_A2;
      2:        data_stream_11 <= result_B1;
      3:        data_stream_11 <= result_B2;
      4:        data_stream_11 <= result_C1;
      5:        data_stream_11 <= result_C2;
      6:        data_stream_11 <= result_D1;
      7:        data_stream_11 <= result_D2;
      8:     data_stream_11 <= result_DDR_A1;
      9:     data_stream_11 <= result_DDR_A2;
      10:    data_stream_11 <= result_DDR_B1;
      11:    data_stream_11 <= result_DDR_B2;
      12:    data_stream_11 <= result_DDR_C1;
      13:    data_stream_11 <= result_DDR_C2;
      14:    data_stream_11 <= result_DDR_D1;
      15:    data_stream_11 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_12_sel)
      0:        data_stream_12 <= result_A1;
      1:        data_stream_12 <= result_A2;
      2:        data_stream_12 <= result_B1;
      3:        data_stream_12 <= result_B2;
      4:        data_stream_12 <= result_C1;
      5:        data_stream_12 <= result_C2;
      6:        data_stream_12 <= result_D1;
      7:        data_stream_12 <= result_D2;
      8:     data_stream_12 <= result_DDR_A1;
      9:     data_stream_12 <= result_DDR_A2;
      10:    data_stream_12 <= result_DDR_B1;
      11:    data_stream_12 <= result_DDR_B2;
      12:    data_stream_12 <= result_DDR_C1;
      13:    data_stream_12 <= result_DDR_C2;
      14:    data_stream_12 <= result_DDR_D1;
      15:    data_stream_12 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_13_sel)
      0:        data_stream_13 <= result_A1;
      1:        data_stream_13 <= result_A2;
      2:        data_stream_13 <= result_B1;
      3:        data_stream_13 <= result_B2;
      4:        data_stream_13 <= result_C1;
      5:        data_stream_13 <= result_C2;
      6:        data_stream_13 <= result_D1;
      7:        data_stream_13 <= result_D2;
      8:     data_stream_13 <= result_DDR_A1;
      9:     data_stream_13 <= result_DDR_A2;
      10:    data_stream_13 <= result_DDR_B1;
      11:    data_stream_13 <= result_DDR_B2;
      12:    data_stream_13 <= result_DDR_C1;
      13:    data_stream_13 <= result_DDR_C2;
      14:    data_stream_13 <= result_DDR_D1;
      15:    data_stream_13 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_14_sel)
      0:        data_stream_14 <= result_A1;
      1:        data_stream_14 <= result_A2;
      2:        data_stream_14 <= result_B1;
      3:        data_stream_14 <= result_B2;
      4:        data_stream_14 <= result_C1;
      5:        data_stream_14 <= result_C2;
      6:        data_stream_14 <= result_D1;
      7:        data_stream_14 <= result_D2;
      8:     data_stream_14 <= result_DDR_A1;
      9:     data_stream_14 <= result_DDR_A2;
      10:    data_stream_14 <= result_DDR_B1;
      11:    data_stream_14 <= result_DDR_B2;
      12:    data_stream_14 <= result_DDR_C1;
      13:    data_stream_14 <= result_DDR_C2;
      14:    data_stream_14 <= result_DDR_D1;
      15:    data_stream_14 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_15_sel)
      0:        data_stream_15 <= result_A1;
      1:        data_stream_15 <= result_A2;
      2:        data_stream_15 <= result_B1;
      3:        data_stream_15 <= result_B2;
      4:        data_stream_15 <= result_C1;
      5:        data_stream_15 <= result_C2;
      6:        data_stream_15 <= result_D1;
      7:        data_stream_15 <= result_D2;
      8:     data_stream_15 <= result_DDR_A1;
      9:     data_stream_15 <= result_DDR_A2;
      10:    data_stream_15 <= result_DDR_B1;
      11:    data_stream_15 <= result_DDR_B2;
      12:    data_stream_15 <= result_DDR_C1;
      13:    data_stream_15 <= result_DDR_C2;
      14:    data_stream_15 <= result_DDR_D1;
      15:    data_stream_15 <= result_DDR_D2;
    endcase
  end

  always @(*) begin
    case (data_stream_16_sel)
      0:        data_stream_16 <= result_A1;
      1:        data_stream_16 <= result_A2;
      2:        data_stream_16 <= result_B1;
      3:        data_stream_16 <= result_B2;
      4:        data_stream_16 <= result_C1;
      5:        data_stream_16 <= result_C2;
      6:        data_stream_16 <= result_D1;
      7:        data_stream_16 <= result_D2;
      8:     data_stream_16 <= result_DDR_A1;
      9:     data_stream_16 <= result_DDR_A2;
      10:    data_stream_16 <= result_DDR_B1;
      11:    data_stream_16 <= result_DDR_B2;
      12:    data_stream_16 <= result_DDR_C1;
      13:    data_stream_16 <= result_DDR_C2;
      14:    data_stream_16 <= result_DDR_D1;
      15:    data_stream_16 <= result_DDR_D2;
    endcase
  end

endmodule
