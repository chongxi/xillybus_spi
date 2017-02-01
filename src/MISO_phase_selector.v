//////////////////////////////////////////////////////////////////////////////////
// Company: 		 Intan Technologies, LLC
// 
// Design Name: 	 RHD2000 Rhythm Interface
// Module Name:    MISO_phase_selector, MISO_DDR_phase_selector
// Project Name:   xillybus_spi 
// Target Devices: 
// Tool versions: 
// Description:    Downsamples MISO by factor of 4, with selectable phase lag to
//                 compensate for headstage cable delay.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module MISO_phase_selector_4x (
	// delay
	input  wire [ 3:0] delay_A  ,
	input  wire [ 3:0] delay_B  ,
	input  wire [ 3:0] delay_C  ,
	input  wire [ 3:0] delay_D  ,
	// oversampled MISO input
	input  wire [73:0] in4x_A1  ,
	input  wire [73:0] in4x_A2  ,
	input  wire [73:0] in4x_B1  ,
	input  wire [73:0] in4x_B2  ,
	input  wire [73:0] in4x_C1  ,
	input  wire [73:0] in4x_C2  ,
	input  wire [73:0] in4x_D1  ,
	input  wire [73:0] in4x_D2  ,
	// MISO output
	output wire [15:0] out_A1, 
	output wire [15:0] out_A2,
	output wire [15:0] out_B1, 
	output wire [15:0] out_B2,
	output wire [15:0] out_C1, 
	output wire [15:0] out_C2,
	output wire [15:0] out_D1, 
	output wire [15:0] out_D2,
	output wire [15:0] out_DDR_A1, 
	output wire [15:0] out_DDR_A2,
	output wire [15:0] out_DDR_B1, 
	output wire [15:0] out_DDR_B2,
	output wire [15:0] out_DDR_C1, 
	output wire [15:0] out_DDR_C2,
	output wire [15:0] out_DDR_D1, 
	output wire [15:0] out_DDR_D2
);

  // MISO phase selectors (to compensate for headstage cable delays)
  MISO_phase_selector MISO_phase_selector_1 (
      .phase_select(delay_A), .MISO4x(in4x_A1), .MISO(out_A1));    

  MISO_phase_selector MISO_phase_selector_2 (
      .phase_select(delay_A), .MISO4x(in4x_A2), .MISO(out_A2));    

  MISO_phase_selector MISO_phase_selector_3 (
      .phase_select(delay_B), .MISO4x(in4x_B1), .MISO(out_B1));    

  MISO_phase_selector MISO_phase_selector_4 (
      .phase_select(delay_B), .MISO4x(in4x_B2), .MISO(out_B2));    
  
  MISO_phase_selector MISO_phase_selector_5 (
      .phase_select(delay_C), .MISO4x(in4x_C1), .MISO(out_C1));    

  MISO_phase_selector MISO_phase_selector_6 (
      .phase_select(delay_C), .MISO4x(in4x_C2), .MISO(out_C2));    
  
  MISO_phase_selector MISO_phase_selector_7 (
      .phase_select(delay_D), .MISO4x(in4x_D1), .MISO(out_D1));

  MISO_phase_selector MISO_phase_selector_8 (
      .phase_select(delay_D), .MISO4x(in4x_D2), .MISO(out_D2));    
      
  MISO_DDR_phase_selector MISO_DDR_phase_selector_1 (
      .phase_select(delay_A), .MISO4x(in4x_A1), .MISO(out_DDR_A1));    

  MISO_DDR_phase_selector MISO_DDR_phase_selector_2 (
      .phase_select(delay_A), .MISO4x(in4x_A2), .MISO(out_DDR_A2));    

  MISO_DDR_phase_selector MISO_DDR_phase_selector_3 (
      .phase_select(delay_B), .MISO4x(in4x_B1), .MISO(out_DDR_B1));    

  MISO_DDR_phase_selector MISO_DDR_phase_selector_4 (
      .phase_select(delay_B), .MISO4x(in4x_B2), .MISO(out_DDR_B2));

  MISO_DDR_phase_selector MISO_DDR_phase_selector_5 (
      .phase_select(delay_C), .MISO4x(in4x_C1), .MISO(out_DDR_C1));    

  MISO_DDR_phase_selector MISO_DDR_phase_selector_6 (
      .phase_select(delay_C), .MISO4x(in4x_C2), .MISO(out_DDR_C2));    

  MISO_DDR_phase_selector MISO_DDR_phase_selector_7 (
      .phase_select(delay_D), .MISO4x(in4x_D1), .MISO(out_DDR_D1));    

  MISO_DDR_phase_selector MISO_DDR_phase_selector_8 (
      .phase_select(delay_D), .MISO4x(in4x_D2), .MISO(out_DDR_D2));

endmodule

module MISO_phase_selector(
	input wire [3:0] 	phase_select,	// MISO sampling phase lag to compensate for headstage cable delay
	input wire [73:0] 	MISO4x,			// 4x oversampled MISO input
	output reg [15:0] 	MISO				// 16-bit MISO output
	);

	always @(*) begin
		case (phase_select)
			0:       MISO <= {MISO4x[0],  MISO4x[4],  MISO4x[8],  MISO4x[12], MISO4x[16], MISO4x[20], MISO4x[24], MISO4x[28], MISO4x[32], MISO4x[36], MISO4x[40], MISO4x[44], MISO4x[48], MISO4x[52], MISO4x[56], MISO4x[60]};
			1:       MISO <= {MISO4x[1],  MISO4x[5],  MISO4x[9],  MISO4x[13], MISO4x[17], MISO4x[21], MISO4x[25], MISO4x[29], MISO4x[33], MISO4x[37], MISO4x[41], MISO4x[45], MISO4x[49], MISO4x[53], MISO4x[57], MISO4x[61]};
			2:       MISO <= {MISO4x[2],  MISO4x[6],  MISO4x[10], MISO4x[14], MISO4x[18], MISO4x[22], MISO4x[26], MISO4x[30], MISO4x[34], MISO4x[38], MISO4x[42], MISO4x[46], MISO4x[50], MISO4x[54], MISO4x[58], MISO4x[62]};
			3:       MISO <= {MISO4x[3],  MISO4x[7],  MISO4x[11], MISO4x[15], MISO4x[19], MISO4x[23], MISO4x[27], MISO4x[31], MISO4x[35], MISO4x[39], MISO4x[43], MISO4x[47], MISO4x[51], MISO4x[55], MISO4x[59], MISO4x[63]};
			4:       MISO <= {MISO4x[4],  MISO4x[8],  MISO4x[12], MISO4x[16], MISO4x[20], MISO4x[24], MISO4x[28], MISO4x[32], MISO4x[36], MISO4x[40], MISO4x[44], MISO4x[48], MISO4x[52], MISO4x[56], MISO4x[60], MISO4x[64]};
			5:       MISO <= {MISO4x[5],  MISO4x[9],  MISO4x[13], MISO4x[17], MISO4x[21], MISO4x[25], MISO4x[29], MISO4x[33], MISO4x[37], MISO4x[41], MISO4x[45], MISO4x[49], MISO4x[53], MISO4x[57], MISO4x[61], MISO4x[65]};
			6:       MISO <= {MISO4x[6],  MISO4x[10], MISO4x[14], MISO4x[18], MISO4x[22], MISO4x[26], MISO4x[30], MISO4x[34], MISO4x[38], MISO4x[42], MISO4x[46], MISO4x[50], MISO4x[54], MISO4x[58], MISO4x[62], MISO4x[66]};
			7:       MISO <= {MISO4x[7],  MISO4x[11], MISO4x[15], MISO4x[19], MISO4x[23], MISO4x[27], MISO4x[31], MISO4x[35], MISO4x[39], MISO4x[43], MISO4x[47], MISO4x[51], MISO4x[55], MISO4x[59], MISO4x[63], MISO4x[67]};
			8:       MISO <= {MISO4x[8],  MISO4x[12], MISO4x[16], MISO4x[20], MISO4x[24], MISO4x[28], MISO4x[32], MISO4x[36], MISO4x[40], MISO4x[44], MISO4x[48], MISO4x[52], MISO4x[56], MISO4x[60], MISO4x[64], MISO4x[68]};
			9:       MISO <= {MISO4x[9],  MISO4x[13], MISO4x[17], MISO4x[21], MISO4x[25], MISO4x[29], MISO4x[33], MISO4x[37], MISO4x[41], MISO4x[45], MISO4x[49], MISO4x[53], MISO4x[57], MISO4x[61], MISO4x[65], MISO4x[69]};
			10:      MISO <= {MISO4x[10], MISO4x[14], MISO4x[18], MISO4x[22], MISO4x[26], MISO4x[30], MISO4x[34], MISO4x[38], MISO4x[42], MISO4x[46], MISO4x[50], MISO4x[54], MISO4x[58], MISO4x[62], MISO4x[66], MISO4x[70]};
			11:      MISO <= {MISO4x[11], MISO4x[15], MISO4x[19], MISO4x[23], MISO4x[27], MISO4x[31], MISO4x[35], MISO4x[39], MISO4x[43], MISO4x[47], MISO4x[51], MISO4x[55], MISO4x[59], MISO4x[63], MISO4x[67], MISO4x[71]};
			default: MISO <= {MISO4x[11], MISO4x[15], MISO4x[19], MISO4x[23], MISO4x[27], MISO4x[31], MISO4x[35], MISO4x[39], MISO4x[43], MISO4x[47], MISO4x[51], MISO4x[55], MISO4x[59], MISO4x[63], MISO4x[67], MISO4x[71]};
		endcase
	end
	
endmodule


module MISO_DDR_phase_selector(
	input wire [3:0] 	phase_select,	// MISO sampling phase lag to compensate for headstage cable delay
	input wire [73:0] 	MISO4x,			// 4x oversampled MISO input
	output reg [15:0] 	MISO				// 16-bit MISO output
	);
	
	always @(*) begin
		case (phase_select)
			0:       MISO <= {MISO4x[2],  MISO4x[6],  MISO4x[10], MISO4x[14], MISO4x[18], MISO4x[22], MISO4x[26], MISO4x[30], MISO4x[34], MISO4x[38], MISO4x[42], MISO4x[46], MISO4x[50], MISO4x[54], MISO4x[58], MISO4x[62]};
			1:       MISO <= {MISO4x[3],  MISO4x[7],  MISO4x[11], MISO4x[15], MISO4x[19], MISO4x[23], MISO4x[27], MISO4x[31], MISO4x[35], MISO4x[39], MISO4x[43], MISO4x[47], MISO4x[51], MISO4x[55], MISO4x[59], MISO4x[63]};
			2:       MISO <= {MISO4x[4],  MISO4x[8],  MISO4x[12], MISO4x[16], MISO4x[20], MISO4x[24], MISO4x[28], MISO4x[32], MISO4x[36], MISO4x[40], MISO4x[44], MISO4x[48], MISO4x[52], MISO4x[56], MISO4x[60], MISO4x[64]};
			3:       MISO <= {MISO4x[5],  MISO4x[9],  MISO4x[13], MISO4x[17], MISO4x[21], MISO4x[25], MISO4x[29], MISO4x[33], MISO4x[37], MISO4x[41], MISO4x[45], MISO4x[49], MISO4x[53], MISO4x[57], MISO4x[61], MISO4x[65]};
			4:       MISO <= {MISO4x[6],  MISO4x[10], MISO4x[14], MISO4x[18], MISO4x[22], MISO4x[26], MISO4x[30], MISO4x[34], MISO4x[38], MISO4x[42], MISO4x[46], MISO4x[50], MISO4x[54], MISO4x[58], MISO4x[62], MISO4x[66]};
			5:       MISO <= {MISO4x[7],  MISO4x[11], MISO4x[15], MISO4x[19], MISO4x[23], MISO4x[27], MISO4x[31], MISO4x[35], MISO4x[39], MISO4x[43], MISO4x[47], MISO4x[51], MISO4x[55], MISO4x[59], MISO4x[63], MISO4x[67]};
			6:       MISO <= {MISO4x[8],  MISO4x[12], MISO4x[16], MISO4x[20], MISO4x[24], MISO4x[28], MISO4x[32], MISO4x[36], MISO4x[40], MISO4x[44], MISO4x[48], MISO4x[52], MISO4x[56], MISO4x[60], MISO4x[64], MISO4x[68]};
			7:       MISO <= {MISO4x[9],  MISO4x[13], MISO4x[17], MISO4x[21], MISO4x[25], MISO4x[29], MISO4x[33], MISO4x[37], MISO4x[41], MISO4x[45], MISO4x[49], MISO4x[53], MISO4x[57], MISO4x[61], MISO4x[65], MISO4x[69]};
			8:       MISO <= {MISO4x[10], MISO4x[14], MISO4x[18], MISO4x[22], MISO4x[26], MISO4x[30], MISO4x[34], MISO4x[38], MISO4x[42], MISO4x[46], MISO4x[50], MISO4x[54], MISO4x[58], MISO4x[62], MISO4x[66], MISO4x[70]};
			9:       MISO <= {MISO4x[11], MISO4x[15], MISO4x[19], MISO4x[23], MISO4x[27], MISO4x[31], MISO4x[35], MISO4x[39], MISO4x[43], MISO4x[47], MISO4x[51], MISO4x[55], MISO4x[59], MISO4x[63], MISO4x[67], MISO4x[71]};
			10:      MISO <= {MISO4x[12], MISO4x[16], MISO4x[20], MISO4x[24], MISO4x[28], MISO4x[32], MISO4x[36], MISO4x[40], MISO4x[44], MISO4x[48], MISO4x[52], MISO4x[56], MISO4x[60], MISO4x[64], MISO4x[68], MISO4x[72]};
			11:      MISO <= {MISO4x[13], MISO4x[17], MISO4x[21], MISO4x[25], MISO4x[29], MISO4x[33], MISO4x[37], MISO4x[41], MISO4x[45], MISO4x[49], MISO4x[53], MISO4x[57], MISO4x[61], MISO4x[65], MISO4x[69], MISO4x[73]};
			default: MISO <= {MISO4x[13], MISO4x[17], MISO4x[21], MISO4x[25], MISO4x[29], MISO4x[33], MISO4x[37], MISO4x[41], MISO4x[45], MISO4x[49], MISO4x[53], MISO4x[57], MISO4x[61], MISO4x[65], MISO4x[69], MISO4x[73]};
		endcase
	end
	
endmodule
