//////////////////////////////////////////////////////////////////////////////////
// Company:  HHMI Janelia
// Engineer: Chongxi Lai
// 
// Create Date: 03/15/2016 05:03:55 PM
// Design Name: mem_reg_16
// Module Name: mem_reg_16
// Project Name: Xike
// Target Devices: KC705
// Tool Versions: Vivado 2015.4
// Description: 
// This is a distributed RAM that transimit commands between host and FPGA
// There are three types of command:
// 1. Feedback command to intervene experiment (Host to FPGA)
// 2. Control the behaviour of data processing (Host to FPGA)
// 3. Report the counter of number of samples, spikes detect etc. (FPGA to Host)
//
// Dependencies: 
// 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
// 
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////
// mem_reg mem_reg_16 (
//   .clk   (bus_clk                    ),
//   .din   (user_w_control_regs_16_data),
//   .we    (user_w_control_regs_16_wren),
//   .re    (user_r_control_regs_16_rden),
//   .addr  (user_control_regs_16_addr  ), 
//   .dout  (user_r_control_regs_16_data),
//   .thr_en(thr_en                     ),
//   .eof   (eof                        )
// );
//////////////////////////////////////////////////////////////////////////////////

module mem_reg_16 (
    input             clk     ,
    input      [15:0] din     ,
    input             we      ,
    input             re      ,
    input      [ 4:0] addr    ,
    output reg [15:0] dout    ,
    
    input             SPI_on  ,
    input             mua_open,
    input             mua_eof ,
    input             sync_in ,

    output reg [15:0] target_unit_id 
);

(* ram_style = "distributed" *)
reg [15:0] mem_reg_16[0:31];

always @(posedge clk) begin
    if (we) 
        mem_reg_16[addr] <= din;
    if (re)
        dout <= mem_reg_16[addr];
end

always @(posedge clk) begin
//    mem_reg_16[0] <= mua_open;
//    mem_reg_16[1] <= SPI_on;
//    mem_reg_16[2] <= sync_in;
//    mem_reg_16[3] <= mua_eof;
    target_unit_id <= mem_reg_16[8];
end


endmodule // mem_cmd