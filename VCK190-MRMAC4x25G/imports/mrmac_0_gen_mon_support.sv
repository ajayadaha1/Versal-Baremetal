
// ------------------------------------------------------------------------------
//   (c) Copyright 2018-2020 Advanced Micro Devices, Inc. All rights reserved.
// 
//   This file contains confidential and proprietary information
//   of Advanced Micro Devices, Inc. and is protected under U.S. and
//   international copyright and other intellectual property
//   laws.
// 
//   DISCLAIMER
//   This disclaimer is not a license and does not grant any
//   rights to the materials distributed herewith. Except as
//   otherwise provided in a valid license issued to you by
//   AMD, and to the maximum extent permitted by applicable
//   law: (1) THESE MATERIALS ARE MADE AVAILABLE \"AS IS\" AND
//   WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
//   AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//   BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//   INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//   (2) AMD shall not be liable (whether in contract or tort,
//   including negligence, or under any other theory of
//   liability) for any loss or damage of any kind or nature
//   related to, arising under or in connection with these
//   materials, including for any direct, or any indirect,
//   special, incidental, or consequential loss or damage
//   (including loss of data, profits, goodwill, or any type of
//   loss or damage suffered as a result of any action brought
//   by a third party) even if such damage or loss was
//   reasonably foreseeable or AMD had been advised of the
//   possibility of the same.
// 
//   CRITICAL APPLICATIONS
//   AMD products are not designed or intended to be fail-
//   safe, or for use in any application requiring fail-safe
//   performance, such as life-support or safety devices or
//   systems, Class III medical devices, nuclear facilities,
//   applications related to the deployment of airbags, or any
//   other applications that could lead to death, personal
//   injury, or severe property or environmental damage
//   (individually and collectively, \"Critical
//   Applications\"). Customer assumes the sole risk and
//   liability of any use of AMD products in Critical
//   Applications, subject only to applicable laws and
//   regulations governing limitations on product liability.
// 
//   THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//   PART OF THIS FILE AT ALL TIMES.
// ------------------------------------------------------------------------------

`timescale 1ps/1ps
///// Syncer
module mrmac_0_synchronizer3
  (
    output q,
    input d, ck, rn
  );
    reg [2:0] sync_reg;
     assign din = d;

    always @(posedge ck or negedge rn) begin
      if (!rn) begin
        sync_reg <= 3'h0;
      end else begin
        sync_reg <= {sync_reg[1],sync_reg[0], din};
      end
    end
 
  assign q = sync_reg[2];
endmodule

module mrmac_0_syncer_level
#(
  parameter WIDTH       = 1,
  parameter RESET_VALUE = 1'b0
 )
(
  input  wire clk,
  input  wire reset,

  input  wire [WIDTH-1:0] datain,
  output wire [WIDTH-1:0] dataout
);

  reg  [WIDTH-1:0] meta_nxt;
  wire [WIDTH-1:0] dataout_nxt;


  always @*
    begin
      meta_nxt = (RESET_VALUE) ? ~datain : datain;
    end


  genvar j;

  generate
    for (j=0; j < WIDTH; j=j+1) begin : syncer_level_loop

mrmac_0_synchronizer3 i_mrmac_0_syncer_level (
        .q  ( dataout_nxt[j] ),
        .d  ( meta_nxt[j] ),
        .ck ( clk ),
        .rn ( reset )
      );
    end
  endgenerate

  assign dataout = (RESET_VALUE) ? ~dataout_nxt : dataout_nxt;


endmodule 


//// Counter
module mrmac_0_hs_counter #(parameter CNT_WIDTH     = 64, // width in bits; use even numbers
                              LSB_CNT_WIDTH = 9,  // width of LSB counter
                              INCR_WIDTH    = 5,
                              SATURATE      = 0)
  (
   input                  clk,
   input                  reset, // sync reset
   input                  clear,

   input [INCR_WIDTH-1:0] incr,
   output [CNT_WIDTH-1:0] cnt
   );

  localparam MSB_CNT_WIDTH = CNT_WIDTH - LSB_CNT_WIDTH;

  // two cascaded counters
  logic [LSB_CNT_WIDTH-1:0] int_cnt_lsb, int_cnt_lsb_q;
  logic [MSB_CNT_WIDTH-1:0] int_cnt_msb;
  logic                     int_incr;
  logic [LSB_CNT_WIDTH:0]   int_cnt_lsb_plus_incr_c;
  logic                    int_cnt_msb_sat;
  logic                    int_cnt_lsb_sat_c;
  logic                    clear_q;

  always_ff @(posedge clk) begin
    clear_q <= clear;
  end

  always_comb begin
    int_cnt_lsb_plus_incr_c = int_cnt_lsb + incr;
    int_cnt_lsb_sat_c = (int_cnt_lsb_plus_incr_c[LSB_CNT_WIDTH]);
  end

  // LSB counter
  always_ff @(posedge clk) begin
    if(reset) begin
      int_cnt_msb_sat <= '0;
      int_cnt_lsb     <= '0;
      int_incr        <= '0;
    end
    else begin
      int_cnt_msb_sat <= &int_cnt_msb;

      if(clear)
        int_cnt_lsb <= incr;
      else if(SATURATE && int_cnt_msb_sat && int_cnt_lsb_sat_c)
        int_cnt_lsb <= {LSB_CNT_WIDTH{1'b1}};
      else
        int_cnt_lsb <= int_cnt_lsb + incr;

      if(int_cnt_lsb_sat_c)
        int_incr <= 1'b1;
      else
        int_incr <= 1'b0;
    end // else: !if(reset)
  end

  // MSB counter
  always_ff @(posedge clk) begin
    if(reset) begin
      int_cnt_lsb_q   <= '0;
      int_cnt_msb     <= '0;
    end
    else begin
      int_cnt_lsb_q   <= int_cnt_lsb;

      if(clear_q)
        int_cnt_msb <= int_incr ? 1 : 0;
      else if(int_incr) begin
        if(SATURATE && &int_cnt_msb)
          int_cnt_msb <= {MSB_CNT_WIDTH{1'b1}};
        else
          int_cnt_msb <= int_cnt_msb + 1;
      end
    end // else: !if(reset)
  end

  // outputs
  assign cnt = {int_cnt_msb, int_cnt_lsb_q};

endmodule
/// BRAM
module mrmac_0_simple_dual_two_clocks
#(
  parameter WIDTH = 32,
  parameter DEPTH = 128,
  parameter DEPTHLOG2 = 7
)

( input wire clka,
  input wire clkb,
  input wire ena,
  input wire enb,
  input wire wea,
  input wire [DEPTHLOG2-1:0] addra,
  input wire [DEPTHLOG2-1:0] addrb,
  input wire [WIDTH-1:0] dia,
  output reg [WIDTH-1:0] dob
);

(* keep = "true" *) reg [WIDTH-1:0] ram [DEPTH-1:0];

always @(posedge clka)
begin
 if (ena)
 begin
 if (wea)
 ram[addra] <= dia;
 end
end
always @(posedge clkb)
begin
 if (enb)
 begin
 dob <= ram[addrb];
 end
end
endmodule
///// FIFO
module mrmac_0_fifo_reg_2clk
#(
  parameter WIDTH = 32,
  parameter DEPTHLOG2 = 4,
  parameter DEPTH = 16
 )
(
  input   wire wclk,
  input   wire rclk,
  input   wire wreset,
  input   wire rreset,
  input   wire [WIDTH-1:0] wdat,
  input   wire we,

  input   wire re,
  output  reg [WIDTH-1:0] rdat
);

reg [DEPTHLOG2-1:0] w_ptr;
reg [DEPTHLOG2-1:0] r_ptr;
wire [WIDTH-1:0] rdat_int;

mrmac_0_simple_dual_two_clocks # (
 .WIDTH (WIDTH),
 .DEPTH (DEPTH),
 .DEPTHLOG2 (DEPTHLOG2) 
)
i_mrmac_0_mem_dual (
  .clka    (wclk),
  .clkb    (rclk),
  .ena     (1'b1),
  .enb     (1'b1),
  .wea     (we),
  .addra   (w_ptr),
  .addrb   (r_ptr),
  .dia     (wdat),
  .dob     (rdat_int)
);

always @(posedge wclk or posedge wreset)
begin
  if (wreset) begin
    w_ptr <= {DEPTHLOG2{1'b0}};
  end else if (we) begin
    w_ptr <= w_ptr + 1;
  end
end

always @(posedge rclk or posedge rreset)
begin
  if (rreset) begin
    r_ptr <= {DEPTHLOG2{1'b0}};
  end else if (re) begin
    r_ptr <= r_ptr + 1;
  end
end

always @(posedge rclk or posedge rreset)
begin
  if (rreset) begin
    rdat <= {WIDTH{1'b0}};
  end else begin
    rdat <= rdat_int;
  end
end



endmodule
//// PRBS

module mrmac_0_prbs_32_2v31_x31_x28_2 (CE, R, C, Q);
input CE;
input R;
input C;
output [31:0] Q;

reg [63:1] PRBS;

assign Q = PRBS[63:32];

always @ (posedge C) begin
    if (R) begin
	PRBS[63:1] <= 63'b0100_1011_1101_0101_0000_0101_1010_1111_1101_0101_0000_0101_1010_1110_0101_110; 

    end else if (CE) begin
      PRBS[63] <= PRBS[31];
      PRBS[62] <= PRBS[30];
      PRBS[61] <= PRBS[29];
      PRBS[60] <= PRBS[28];
      PRBS[59] <= PRBS[27];
      PRBS[58] <= PRBS[26];
      PRBS[57] <= PRBS[25];
      PRBS[56] <= PRBS[24];
      PRBS[55] <= PRBS[23];
      PRBS[54] <= PRBS[22];
      PRBS[53] <= PRBS[21];
      PRBS[52] <= PRBS[20];
      PRBS[51] <= PRBS[19];
      PRBS[50] <= PRBS[18];
      PRBS[49] <= PRBS[17];
      PRBS[48] <= PRBS[16];
      PRBS[47] <= PRBS[15];
      PRBS[46] <= PRBS[14];
      PRBS[45] <= PRBS[13];
      PRBS[44] <= PRBS[12];
      PRBS[43] <= PRBS[11];
      PRBS[42] <= PRBS[10];
      PRBS[41] <= PRBS[ 9];
      PRBS[40] <= PRBS[ 8];
      PRBS[39] <= PRBS[ 7];
      PRBS[38] <= PRBS[ 6];
      PRBS[37] <= PRBS[ 5];
      PRBS[36] <= PRBS[ 4];
      PRBS[35] <= PRBS[ 3];
      PRBS[34] <= PRBS[ 2];
      PRBS[33] <= PRBS[ 1];
      PRBS[32] <= PRBS[28] ~^ PRBS[31];
      PRBS[31] <= PRBS[27] ~^ PRBS[30];
      PRBS[30] <= PRBS[26] ~^ PRBS[29];
      PRBS[29] <= PRBS[25] ~^ PRBS[28];
      PRBS[28] <= PRBS[24] ~^ PRBS[27];
      PRBS[27] <= PRBS[23] ~^ PRBS[26];
      PRBS[26] <= PRBS[22] ~^ PRBS[25];
      PRBS[25] <= PRBS[21] ~^ PRBS[24];
      PRBS[24] <= PRBS[20] ~^ PRBS[23];
      PRBS[23] <= PRBS[19] ~^ PRBS[22];
      PRBS[22] <= PRBS[18] ~^ PRBS[21];
      PRBS[21] <= PRBS[17] ~^ PRBS[20];
      PRBS[20] <= PRBS[16] ~^ PRBS[19];
      PRBS[19] <= PRBS[15] ~^ PRBS[18];
      PRBS[18] <= PRBS[14] ~^ PRBS[17];
      PRBS[17] <= PRBS[13] ~^ PRBS[16];
      PRBS[16] <= PRBS[12] ~^ PRBS[15];
      PRBS[15] <= PRBS[11] ~^ PRBS[14];
      PRBS[14] <= PRBS[10] ~^ PRBS[13];
      PRBS[13] <= PRBS[ 9] ~^ PRBS[12];
      PRBS[12] <= PRBS[ 8] ~^ PRBS[11];
      PRBS[11] <= PRBS[ 7] ~^ PRBS[10];
      PRBS[10] <= PRBS[ 6] ~^ PRBS[ 9];
      PRBS[ 9] <= PRBS[ 5] ~^ PRBS[ 8];
      PRBS[ 8] <= PRBS[ 4] ~^ PRBS[ 7];
      PRBS[ 7] <= PRBS[ 3] ~^ PRBS[ 6];
      PRBS[ 6] <= PRBS[ 2] ~^ PRBS[ 5];
      PRBS[ 5] <= PRBS[ 1] ~^ PRBS[ 4];
      PRBS[ 4] <= PRBS[ 3] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 3] <= PRBS[ 2] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 2] <= PRBS[ 1] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 1] <= PRBS[25] ~^ PRBS[31];
    end
  end
endmodule

module mrmac_0_prbs_128_2v31_x31_x28_2 (CE, R, C, Q);
input CE;
input R;
input C;
output [127:0] Q;

reg [159:1] PRBS;

assign Q = PRBS[159:32];

always @ (posedge C or posedge R) begin
    if (R) begin
      PRBS[159:129] <= 31'b1111111000011101111001000111000;

      PRBS[128:65 ] <= 64'b0000111011110010110001111111000011100101100100111111000011101110;

      PRBS[ 64:1  ] <= 64'b1100100100001100111011110011000100000010110101110010110101110010;

    end else if (CE) begin
      PRBS[159] <= PRBS[31];
      PRBS[158] <= PRBS[30];
      PRBS[157] <= PRBS[29];
      PRBS[156] <= PRBS[28];
      PRBS[155] <= PRBS[27];
      PRBS[154] <= PRBS[26];
      PRBS[153] <= PRBS[25];
      PRBS[152] <= PRBS[24];
      PRBS[151] <= PRBS[23];
      PRBS[150] <= PRBS[22];
      PRBS[149] <= PRBS[21];
      PRBS[148] <= PRBS[20];
      PRBS[147] <= PRBS[19];
      PRBS[146] <= PRBS[18];
      PRBS[145] <= PRBS[17];
      PRBS[144] <= PRBS[16];
      PRBS[143] <= PRBS[15];
      PRBS[142] <= PRBS[14];
      PRBS[141] <= PRBS[13];
      PRBS[140] <= PRBS[12];
      PRBS[139] <= PRBS[11];
      PRBS[138] <= PRBS[10];
      PRBS[137] <= PRBS[ 9];
      PRBS[136] <= PRBS[ 8];
      PRBS[135] <= PRBS[ 7];
      PRBS[134] <= PRBS[ 6];
      PRBS[133] <= PRBS[ 5];
      PRBS[132] <= PRBS[ 4];
      PRBS[131] <= PRBS[ 3];
      PRBS[130] <= PRBS[ 2];
      PRBS[129] <= PRBS[ 1];
      PRBS[128] <= PRBS[28] ^ PRBS[31];
      PRBS[127] <= PRBS[27] ^ PRBS[30];
      PRBS[126] <= PRBS[26] ^ PRBS[29];
      PRBS[125] <= PRBS[25] ^ PRBS[28];
      PRBS[124] <= PRBS[24] ^ PRBS[27];
      PRBS[123] <= PRBS[23] ^ PRBS[26];
      PRBS[122] <= PRBS[22] ^ PRBS[25];
      PRBS[121] <= PRBS[21] ^ PRBS[24];
      PRBS[120] <= PRBS[20] ^ PRBS[23];
      PRBS[119] <= PRBS[19] ^ PRBS[22];
      PRBS[118] <= PRBS[18] ^ PRBS[21];
      PRBS[117] <= PRBS[17] ^ PRBS[20];
      PRBS[116] <= PRBS[16] ^ PRBS[19];
      PRBS[115] <= PRBS[15] ^ PRBS[18];
      PRBS[114] <= PRBS[14] ^ PRBS[17];
      PRBS[113] <= PRBS[13] ^ PRBS[16];
      PRBS[112] <= PRBS[12] ^ PRBS[15];
      PRBS[111] <= PRBS[11] ^ PRBS[14];
      PRBS[110] <= PRBS[10] ^ PRBS[13];
      PRBS[109] <= PRBS[ 9] ^ PRBS[12];
      PRBS[108] <= PRBS[ 8] ^ PRBS[11];
      PRBS[107] <= PRBS[ 7] ^ PRBS[10];
      PRBS[106] <= PRBS[ 6] ^ PRBS[ 9];
      PRBS[105] <= PRBS[ 5] ^ PRBS[ 8];
      PRBS[104] <= PRBS[ 4] ^ PRBS[ 7];
      PRBS[103] <= PRBS[ 3] ^ PRBS[ 6];
      PRBS[102] <= PRBS[ 2] ^ PRBS[ 5];
      PRBS[101] <= PRBS[ 1] ^ PRBS[ 4];
      PRBS[100] <= PRBS[ 3] ^ PRBS[28] ^ PRBS[31];
      PRBS[99] <= PRBS[ 2] ^ PRBS[27] ^ PRBS[30];
      PRBS[98] <= PRBS[ 1] ^ PRBS[26] ^ PRBS[29];
      PRBS[97] <= PRBS[25] ^ PRBS[31];
      PRBS[96] <= PRBS[24] ^ PRBS[30];
      PRBS[95] <= PRBS[23] ^ PRBS[29];
      PRBS[94] <= PRBS[22] ^ PRBS[28];
      PRBS[93] <= PRBS[21] ^ PRBS[27];
      PRBS[92] <= PRBS[20] ^ PRBS[26];
      PRBS[91] <= PRBS[19] ^ PRBS[25];
      PRBS[90] <= PRBS[18] ^ PRBS[24];
      PRBS[89] <= PRBS[17] ^ PRBS[23];
      PRBS[88] <= PRBS[16] ^ PRBS[22];
      PRBS[87] <= PRBS[15] ^ PRBS[21];
      PRBS[86] <= PRBS[14] ^ PRBS[20];
      PRBS[85] <= PRBS[13] ^ PRBS[19];
      PRBS[84] <= PRBS[12] ^ PRBS[18];
      PRBS[83] <= PRBS[11] ^ PRBS[17];
      PRBS[82] <= PRBS[10] ^ PRBS[16];
      PRBS[81] <= PRBS[ 9] ^ PRBS[15];
      PRBS[80] <= PRBS[ 8] ^ PRBS[14];
      PRBS[79] <= PRBS[ 7] ^ PRBS[13];
      PRBS[78] <= PRBS[ 6] ^ PRBS[12];
      PRBS[77] <= PRBS[ 5] ^ PRBS[11];
      PRBS[76] <= PRBS[ 4] ^ PRBS[10];
      PRBS[75] <= PRBS[ 3] ^ PRBS[ 9];
      PRBS[74] <= PRBS[ 2] ^ PRBS[ 8];
      PRBS[73] <= PRBS[ 1] ^ PRBS[ 7];
      PRBS[72] <= PRBS[ 6] ^ PRBS[28] ^ PRBS[31];
      PRBS[71] <= PRBS[ 5] ^ PRBS[27] ^ PRBS[30];
      PRBS[70] <= PRBS[ 4] ^ PRBS[26] ^ PRBS[29];
      PRBS[69] <= PRBS[ 3] ^ PRBS[25] ^ PRBS[28];
      PRBS[68] <= PRBS[ 2] ^ PRBS[24] ^ PRBS[27];
      PRBS[67] <= PRBS[ 1] ^ PRBS[23] ^ PRBS[26];
      PRBS[66] <= PRBS[22] ^ PRBS[25] ^ PRBS[28] ^ PRBS[31];
      PRBS[65] <= PRBS[21] ^ PRBS[24] ^ PRBS[27] ^ PRBS[30];
      PRBS[64] <= PRBS[20] ^ PRBS[23] ^ PRBS[26] ^ PRBS[29];
      PRBS[63] <= PRBS[19] ^ PRBS[22] ^ PRBS[25] ^ PRBS[28];
      PRBS[62] <= PRBS[18] ^ PRBS[21] ^ PRBS[24] ^ PRBS[27];
      PRBS[61] <= PRBS[17] ^ PRBS[20] ^ PRBS[23] ^ PRBS[26];
      PRBS[60] <= PRBS[16] ^ PRBS[19] ^ PRBS[22] ^ PRBS[25];
      PRBS[59] <= PRBS[15] ^ PRBS[18] ^ PRBS[21] ^ PRBS[24];
      PRBS[58] <= PRBS[14] ^ PRBS[17] ^ PRBS[20] ^ PRBS[23];
      PRBS[57] <= PRBS[13] ^ PRBS[16] ^ PRBS[19] ^ PRBS[22];
      PRBS[56] <= PRBS[12] ^ PRBS[15] ^ PRBS[18] ^ PRBS[21];
      PRBS[55] <= PRBS[11] ^ PRBS[14] ^ PRBS[17] ^ PRBS[20];
      PRBS[54] <= PRBS[10] ^ PRBS[13] ^ PRBS[16] ^ PRBS[19];
      PRBS[53] <= PRBS[ 9] ^ PRBS[12] ^ PRBS[15] ^ PRBS[18];
      PRBS[52] <= PRBS[ 8] ^ PRBS[11] ^ PRBS[14] ^ PRBS[17];
      PRBS[51] <= PRBS[ 7] ^ PRBS[10] ^ PRBS[13] ^ PRBS[16];
      PRBS[50] <= PRBS[ 6] ^ PRBS[ 9] ^ PRBS[12] ^ PRBS[15];
      PRBS[49] <= PRBS[ 5] ^ PRBS[ 8] ^ PRBS[11] ^ PRBS[14];
      PRBS[48] <= PRBS[ 4] ^ PRBS[ 7] ^ PRBS[10] ^ PRBS[13];
      PRBS[47] <= PRBS[ 3] ^ PRBS[ 6] ^ PRBS[ 9] ^ PRBS[12];
      PRBS[46] <= PRBS[ 2] ^ PRBS[ 5] ^ PRBS[ 8] ^ PRBS[11];
      PRBS[45] <= PRBS[ 1] ^ PRBS[ 4] ^ PRBS[ 7] ^ PRBS[10];
      PRBS[44] <= PRBS[ 3] ^ PRBS[ 6] ^ PRBS[ 9] ^ PRBS[28] ^ PRBS[31];
      PRBS[43] <= PRBS[ 2] ^ PRBS[ 5] ^ PRBS[ 8] ^ PRBS[27] ^ PRBS[30];
      PRBS[42] <= PRBS[ 1] ^ PRBS[ 4] ^ PRBS[ 7] ^ PRBS[26] ^ PRBS[29];
      PRBS[41] <= PRBS[ 3] ^ PRBS[ 6] ^ PRBS[25] ^ PRBS[31];
      PRBS[40] <= PRBS[ 2] ^ PRBS[ 5] ^ PRBS[24] ^ PRBS[30];
      PRBS[39] <= PRBS[ 1] ^ PRBS[ 4] ^ PRBS[23] ^ PRBS[29];
      PRBS[38] <= PRBS[ 3] ^ PRBS[22] ^ PRBS[31];
      PRBS[37] <= PRBS[ 2] ^ PRBS[21] ^ PRBS[30];
      PRBS[36] <= PRBS[ 1] ^ PRBS[20] ^ PRBS[29];
      PRBS[35] <= PRBS[19] ^ PRBS[31];
      PRBS[34] <= PRBS[18] ^ PRBS[30];
      PRBS[33] <= PRBS[17] ^ PRBS[29];
      PRBS[32] <= PRBS[16] ^ PRBS[28];
      PRBS[31] <= PRBS[15] ^ PRBS[27];
      PRBS[30] <= PRBS[14] ^ PRBS[26];
      PRBS[29] <= PRBS[13] ^ PRBS[25];
      PRBS[28] <= PRBS[12] ^ PRBS[24];
      PRBS[27] <= PRBS[11] ^ PRBS[23];
      PRBS[26] <= PRBS[10] ^ PRBS[22];
      PRBS[25] <= PRBS[ 9] ^ PRBS[21];
      PRBS[24] <= PRBS[ 8] ^ PRBS[20];
      PRBS[23] <= PRBS[ 7] ^ PRBS[19];
      PRBS[22] <= PRBS[ 6] ^ PRBS[18];
      PRBS[21] <= PRBS[ 5] ^ PRBS[17];
      PRBS[20] <= PRBS[ 4] ^ PRBS[16];
      PRBS[19] <= PRBS[ 3] ^ PRBS[15];
      PRBS[18] <= PRBS[ 2] ^ PRBS[14];
      PRBS[17] <= PRBS[ 1] ^ PRBS[13];
      PRBS[16] <= PRBS[12] ^ PRBS[28] ^ PRBS[31];
      PRBS[15] <= PRBS[11] ^ PRBS[27] ^ PRBS[30];
      PRBS[14] <= PRBS[10] ^ PRBS[26] ^ PRBS[29];
      PRBS[13] <= PRBS[ 9] ^ PRBS[25] ^ PRBS[28];
      PRBS[12] <= PRBS[ 8] ^ PRBS[24] ^ PRBS[27];
      PRBS[11] <= PRBS[ 7] ^ PRBS[23] ^ PRBS[26];
      PRBS[10] <= PRBS[ 6] ^ PRBS[22] ^ PRBS[25];
      PRBS[ 9] <= PRBS[ 5] ^ PRBS[21] ^ PRBS[24];
      PRBS[ 8] <= PRBS[ 4] ^ PRBS[20] ^ PRBS[23];
      PRBS[ 7] <= PRBS[ 3] ^ PRBS[19] ^ PRBS[22];
      PRBS[ 6] <= PRBS[ 2] ^ PRBS[18] ^ PRBS[21];
      PRBS[ 5] <= PRBS[ 1] ^ PRBS[17] ^ PRBS[20];
      PRBS[ 4] <= PRBS[16] ^ PRBS[19] ^ PRBS[28] ^ PRBS[31];
      PRBS[ 3] <= PRBS[15] ^ PRBS[18] ^ PRBS[27] ^ PRBS[30];
      PRBS[ 2] <= PRBS[14] ^ PRBS[17] ^ PRBS[26] ^ PRBS[29];
      PRBS[ 1] <= PRBS[13] ^ PRBS[16] ^ PRBS[25] ^ PRBS[28];
    end
  end
endmodule

module mrmac_0_prbs_256_2v31_x31_x28_2 (CE, R, C, Q);
input CE;
input R;
input C;
output [255:0] Q;

reg [287:1] PRBS;

assign Q = PRBS[287:32];

always @ (posedge C) begin
    if (R) begin
//	PRBS[287:1] <= 287'h0;

	PRBS[287:4] <= 284'h46fe_6bb1_1de5_938c_1a6d_e026_6dfa_3dd5_fba8_590b_b22a_dd53_b907_9063_1d89_d908_1c71_dd7;
	PRBS[3:1] <= 3'b110;
    end else if (CE) begin
      PRBS[287] <= PRBS[31];
      PRBS[286] <= PRBS[30];
      PRBS[285] <= PRBS[29];
      PRBS[284] <= PRBS[28];
      PRBS[283] <= PRBS[27];
      PRBS[282] <= PRBS[26];
      PRBS[281] <= PRBS[25];
      PRBS[280] <= PRBS[24];
      PRBS[279] <= PRBS[23];
      PRBS[278] <= PRBS[22];
      PRBS[277] <= PRBS[21];
      PRBS[276] <= PRBS[20];
      PRBS[275] <= PRBS[19];
      PRBS[274] <= PRBS[18];
      PRBS[273] <= PRBS[17];
      PRBS[272] <= PRBS[16];
      PRBS[271] <= PRBS[15];
      PRBS[270] <= PRBS[14];
      PRBS[269] <= PRBS[13];
      PRBS[268] <= PRBS[12];
      PRBS[267] <= PRBS[11];
      PRBS[266] <= PRBS[10];
      PRBS[265] <= PRBS[9];
      PRBS[264] <= PRBS[8];
      PRBS[263] <= PRBS[7];
      PRBS[262] <= PRBS[6];
      PRBS[261] <= PRBS[5];
      PRBS[260] <= PRBS[4];
      PRBS[259] <= PRBS[3];
      PRBS[258] <= PRBS[2];
      PRBS[257] <= PRBS[1];
      PRBS[256] <= PRBS[28] ~^ PRBS[31];
      PRBS[255] <= PRBS[27] ~^ PRBS[30];
      PRBS[254] <= PRBS[26] ~^ PRBS[29];
      PRBS[253] <= PRBS[25] ~^ PRBS[28];
      PRBS[252] <= PRBS[24] ~^ PRBS[27];
      PRBS[251] <= PRBS[23] ~^ PRBS[26];
      PRBS[250] <= PRBS[22] ~^ PRBS[25];
      PRBS[249] <= PRBS[21] ~^ PRBS[24];
      PRBS[248] <= PRBS[20] ~^ PRBS[23];
      PRBS[247] <= PRBS[19] ~^ PRBS[22];
      PRBS[246] <= PRBS[18] ~^ PRBS[21];
      PRBS[245] <= PRBS[17] ~^ PRBS[20];
      PRBS[244] <= PRBS[16] ~^ PRBS[19];
      PRBS[243] <= PRBS[15] ~^ PRBS[18];
      PRBS[242] <= PRBS[14] ~^ PRBS[17];
      PRBS[241] <= PRBS[13] ~^ PRBS[16];
      PRBS[240] <= PRBS[12] ~^ PRBS[15];
      PRBS[239] <= PRBS[11] ~^ PRBS[14];
      PRBS[238] <= PRBS[10] ~^ PRBS[13];
      PRBS[237] <= PRBS[9] ~^ PRBS[12];
      PRBS[236] <= PRBS[8] ~^ PRBS[11];
      PRBS[235] <= PRBS[7] ~^ PRBS[10];
      PRBS[234] <= PRBS[6] ~^ PRBS[9];
      PRBS[233] <= PRBS[5] ~^ PRBS[8];
      PRBS[232] <= PRBS[4] ~^ PRBS[7];
      PRBS[231] <= PRBS[3] ~^ PRBS[6];
      PRBS[230] <= PRBS[2] ~^ PRBS[5];
      PRBS[229] <= PRBS[1] ~^ PRBS[4];
      PRBS[228] <= PRBS[ 3] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[227] <= PRBS[ 2] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[226] <= PRBS[ 1] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[225] <= PRBS[25] ~^ PRBS[31];
      PRBS[224] <= PRBS[24] ~^ PRBS[30];
      PRBS[223] <= PRBS[23] ~^ PRBS[29];
      PRBS[222] <= PRBS[22] ~^ PRBS[28];
      PRBS[221] <= PRBS[21] ~^ PRBS[27];
      PRBS[220] <= PRBS[20] ~^ PRBS[26];
      PRBS[219] <= PRBS[19] ~^ PRBS[25];
      PRBS[218] <= PRBS[18] ~^ PRBS[24];
      PRBS[217] <= PRBS[17] ~^ PRBS[23];
      PRBS[216] <= PRBS[16] ~^ PRBS[22];
      PRBS[215] <= PRBS[15] ~^ PRBS[21];
      PRBS[214] <= PRBS[14] ~^ PRBS[20];
      PRBS[213] <= PRBS[13] ~^ PRBS[19];
      PRBS[212] <= PRBS[12] ~^ PRBS[18];
      PRBS[211] <= PRBS[11] ~^ PRBS[17];
      PRBS[210] <= PRBS[10] ~^ PRBS[16];
      PRBS[209] <= PRBS[9] ~^ PRBS[15];
      PRBS[208] <= PRBS[8] ~^ PRBS[14];
      PRBS[207] <= PRBS[7] ~^ PRBS[13];
      PRBS[206] <= PRBS[6] ~^ PRBS[12];
      PRBS[205] <= PRBS[5] ~^ PRBS[11];
      PRBS[204] <= PRBS[4] ~^ PRBS[10];
      PRBS[203] <= PRBS[3] ~^ PRBS[9];
      PRBS[202] <= PRBS[2] ~^ PRBS[8];
      PRBS[201] <= PRBS[1] ~^ PRBS[7];
      PRBS[200] <= PRBS[ 6] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[199] <= PRBS[ 5] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[198] <= PRBS[ 4] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[197] <= PRBS[ 3] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[196] <= PRBS[ 2] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[195] <= PRBS[ 1] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[194] <= PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[193] <= PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[192] <= PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[191] <= PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[190] <= PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[189] <= PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[188] <= PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[187] <= PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[186] <= PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[185] <= PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[184] <= PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[183] <= PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20];
      PRBS[182] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19];
      PRBS[181] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18];
      PRBS[180] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17];
      PRBS[179] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16];
      PRBS[178] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15];
      PRBS[177] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14];
      PRBS[176] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13];
      PRBS[175] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12];
      PRBS[174] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11];
      PRBS[173] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10];
      PRBS[172] <= PRBS[ 3] ~^ PRBS[ 6] ~^ PRBS[ 9] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[171] <= PRBS[ 2] ~^ PRBS[ 5] ~^ PRBS[ 8] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[170] <= PRBS[ 1] ~^ PRBS[ 4] ~^ PRBS[ 7] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[169] <= PRBS[ 3] ~^ PRBS[ 6] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[168] <= PRBS[ 2] ~^ PRBS[ 5] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[167] <= PRBS[ 1] ~^ PRBS[ 4] ~^ PRBS[23] ~^ PRBS[29];
      PRBS[166] <= PRBS[ 3] ~^ PRBS[22] ~^ PRBS[31];
      PRBS[165] <= PRBS[ 2] ~^ PRBS[21] ~^ PRBS[30];
      PRBS[164] <= PRBS[ 1] ~^ PRBS[20] ~^ PRBS[29];
      PRBS[163] <= PRBS[19] ~^ PRBS[31];
      PRBS[162] <= PRBS[18] ~^ PRBS[30];
      PRBS[161] <= PRBS[17] ~^ PRBS[29];
      PRBS[160] <= PRBS[16] ~^ PRBS[28];
      PRBS[159] <= PRBS[15] ~^ PRBS[27];
      PRBS[158] <= PRBS[14] ~^ PRBS[26];
      PRBS[157] <= PRBS[13] ~^ PRBS[25];
      PRBS[156] <= PRBS[12] ~^ PRBS[24];
      PRBS[155] <= PRBS[11] ~^ PRBS[23];
      PRBS[154] <= PRBS[10] ~^ PRBS[22];
      PRBS[153] <= PRBS[ 9] ~^ PRBS[21];
      PRBS[152] <= PRBS[ 8] ~^ PRBS[20];
      PRBS[151] <= PRBS[ 7] ~^ PRBS[19];
      PRBS[150] <= PRBS[ 6] ~^ PRBS[18];
      PRBS[149] <= PRBS[ 5] ~^ PRBS[17];
      PRBS[148] <= PRBS[ 4] ~^ PRBS[16];
      PRBS[147] <= PRBS[ 3] ~^ PRBS[15];
      PRBS[146] <= PRBS[ 2] ~^ PRBS[14];
      PRBS[145] <= PRBS[ 1] ~^ PRBS[13];
      PRBS[144] <= PRBS[12] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[143] <= PRBS[11] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[142] <= PRBS[10] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[141] <= PRBS[9] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[140] <= PRBS[8] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[139] <= PRBS[7] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[138] <= PRBS[6] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[137] <= PRBS[5] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[136] <= PRBS[4] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[135] <= PRBS[3] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[134] <= PRBS[2] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[133] <= PRBS[1] ~^ PRBS[17] ~^ PRBS[20];
      PRBS[132] <= PRBS[16] ~^ PRBS[19] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[131] <= PRBS[15] ~^ PRBS[18] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[130] <= PRBS[14] ~^ PRBS[17] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[129] <= PRBS[13] ~^ PRBS[16] ~^ PRBS[25] ~^ PRBS[28]; //128
      PRBS[128] <= PRBS[12] ~^ PRBS[15] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[127] <= PRBS[11] ~^ PRBS[14] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[126] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[125] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[124] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[123] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[122] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[121] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[17] ~^ PRBS[20];
      PRBS[120] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[16] ~^ PRBS[19];
      PRBS[119] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[15] ~^ PRBS[18];
      PRBS[118] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[14] ~^ PRBS[17];
      PRBS[117] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[13] ~^ PRBS[16];
      PRBS[116] <= PRBS[3] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[115] <= PRBS[2] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[114] <= PRBS[1] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[113] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[112] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[111] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[23] ~^ PRBS[29];
      PRBS[110] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[22] ~^ PRBS[28];
      PRBS[109] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[21] ~^ PRBS[27];
      PRBS[108] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[20] ~^ PRBS[26];
      PRBS[107] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[19] ~^ PRBS[25];
      PRBS[106] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[18] ~^ PRBS[24];
      PRBS[105] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[17] ~^ PRBS[23];
      PRBS[104] <= PRBS[3] ~^ PRBS[16] ~^ PRBS[22] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[103] <= PRBS[2] ~^ PRBS[15] ~^ PRBS[21] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[102] <= PRBS[1] ~^ PRBS[14] ~^ PRBS[20] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[101] <= PRBS[13] ~^ PRBS[19] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[100] <= PRBS[12] ~^ PRBS[18] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[ 99] <= PRBS[11] ~^ PRBS[17] ~^ PRBS[23] ~^ PRBS[29];
      PRBS[ 98] <= PRBS[10] ~^ PRBS[16] ~^ PRBS[22] ~^ PRBS[28];
      PRBS[ 97] <= PRBS[9] ~^ PRBS[15] ~^ PRBS[21] ~^ PRBS[27]; //160
      PRBS[ 96] <= PRBS[8] ~^ PRBS[14] ~^ PRBS[20] ~^ PRBS[26];
      PRBS[ 95] <= PRBS[7] ~^ PRBS[13] ~^ PRBS[19] ~^ PRBS[25];
      PRBS[ 94] <= PRBS[6] ~^ PRBS[12] ~^ PRBS[18] ~^ PRBS[24];
      PRBS[ 93] <= PRBS[5] ~^ PRBS[11] ~^ PRBS[17] ~^ PRBS[23];
      PRBS[ 92] <= PRBS[4] ~^ PRBS[10] ~^ PRBS[16] ~^ PRBS[22];
      PRBS[ 91] <= PRBS[3] ~^ PRBS[9] ~^ PRBS[15] ~^ PRBS[21];
      PRBS[ 90] <= PRBS[2] ~^ PRBS[8] ~^ PRBS[14] ~^ PRBS[20];
      PRBS[ 89] <= PRBS[1] ~^ PRBS[7] ~^ PRBS[13] ~^ PRBS[19];
      PRBS[ 88] <= PRBS[6] ~^ PRBS[12] ~^ PRBS[18] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 87] <= PRBS[5] ~^ PRBS[11] ~^ PRBS[17] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 86] <= PRBS[4] ~^ PRBS[10] ~^ PRBS[16] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 85] <= PRBS[3] ~^ PRBS[9] ~^ PRBS[15] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 84] <= PRBS[2] ~^ PRBS[8] ~^ PRBS[14] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[ 83] <= PRBS[1] ~^ PRBS[7] ~^ PRBS[13] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[ 82] <= PRBS[6] ~^ PRBS[12] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 81] <= PRBS[5] ~^ PRBS[11] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[ 80] <= PRBS[4] ~^ PRBS[10] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29]; 
      PRBS[ 79] <= PRBS[3] ~^ PRBS[9] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 78] <= PRBS[2] ~^ PRBS[8] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[ 77] <= PRBS[1] ~^ PRBS[7] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26]; 
      PRBS[ 76] <= PRBS[6] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 75] <= PRBS[5] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 74] <= PRBS[4] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 73] <= PRBS[3] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 72] <= PRBS[2] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[ 71] <= PRBS[1] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26]; 
      PRBS[ 70] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[ 69] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 68] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 67] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 66] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[ 65] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[ 64] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[ 63] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[ 62] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[ 61] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22]; 
      PRBS[ 60] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[ 59] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 58] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 57] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[ 56] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[ 55] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[23] ~^ PRBS[29]; 
      PRBS[ 54] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[22] ~^ PRBS[31];
      PRBS[ 53] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[21] ~^ PRBS[30];
      PRBS[ 52] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[20] ~^ PRBS[29];
      PRBS[ 51] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[19] ~^ PRBS[31]; 
      PRBS[ 50] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[18] ~^ PRBS[30]; 
      PRBS[ 49] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[17] ~^ PRBS[29];
      PRBS[ 48] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[16] ~^ PRBS[31];
      PRBS[ 47] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[15] ~^ PRBS[30];
      PRBS[ 46] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[14] ~^ PRBS[29];
      PRBS[ 45] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[13] ~^ PRBS[31];
      PRBS[ 44] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[12] ~^ PRBS[30];
      PRBS[ 43] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[11] ~^ PRBS[29];
      PRBS[ 42] <= PRBS[3] ~^ PRBS[10] ~^ PRBS[31];
      PRBS[ 41] <= PRBS[2] ~^ PRBS[9] ~^ PRBS[30]; 
      PRBS[ 40] <= PRBS[1] ~^ PRBS[8] ~^ PRBS[29]; 
      PRBS[ 39] <= PRBS[7] ~^ PRBS[31];
      PRBS[ 38] <= PRBS[6] ~^ PRBS[30];
      PRBS[ 37] <= PRBS[5] ~^ PRBS[29];
      PRBS[ 36] <= PRBS[4] ~^ PRBS[28];
      PRBS[ 35] <= PRBS[3] ~^ PRBS[27];
      PRBS[ 34] <= PRBS[2] ~^ PRBS[26];
      PRBS[ 33] <= PRBS[1] ~^ PRBS[25];
      PRBS[ 32] <= PRBS[24] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 31] <= PRBS[23] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[ 30] <= PRBS[22] ~^ PRBS[26] ~^ PRBS[29]; 
      PRBS[ 29] <= PRBS[21] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 28] <= PRBS[20] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[ 27] <= PRBS[19] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[ 26] <= PRBS[18] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[ 25] <= PRBS[17] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[ 24] <= PRBS[16] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[ 23] <= PRBS[15] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[ 22] <= PRBS[14] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[ 21] <= PRBS[13] ~^ PRBS[17] ~^ PRBS[20]; 
      PRBS[ 20] <= PRBS[12] ~^ PRBS[16] ~^ PRBS[19]; 
      PRBS[ 19] <= PRBS[11] ~^ PRBS[15] ~^ PRBS[18];
      PRBS[ 18] <= PRBS[10] ~^ PRBS[14] ~^ PRBS[17];
      PRBS[ 17] <= PRBS[9] ~^ PRBS[13] ~^ PRBS[16];
      PRBS[ 16] <= PRBS[8] ~^ PRBS[12] ~^ PRBS[15];
      PRBS[ 15] <= PRBS[7] ~^ PRBS[11] ~^ PRBS[14];
      PRBS[ 14] <= PRBS[6] ~^ PRBS[10] ~^ PRBS[13];
      PRBS[ 13] <= PRBS[5] ~^ PRBS[9] ~^ PRBS[12];
      PRBS[ 12] <= PRBS[4] ~^ PRBS[8] ~^ PRBS[11];
      PRBS[ 11] <= PRBS[3] ~^ PRBS[7] ~^ PRBS[10]; 
      PRBS[ 10] <= PRBS[2] ~^ PRBS[6] ~^ PRBS[9]; 
      PRBS[  9] <= PRBS[1] ~^ PRBS[5] ~^ PRBS[8];
      PRBS[  8] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[  7] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[  6] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[  5] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[  4] <= PRBS[3] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[  3] <= PRBS[2] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[  2] <= PRBS[1] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[  1] <= PRBS[21] ~^ PRBS[24] ~^ PRBS[25] ~^ PRBS[31]; //256
    end
  end
endmodule

module mrmac_0_prbs_384_2v31_x31_x28_2 (CE, R, C, Q);
input CE;
input R;
input C;
output [383:0] Q;

reg [415:1] PRBS;

assign Q = PRBS[415:32];

always @ (posedge C) begin
    if (R) begin
//	PRBS[415:1] <= 415'h0;

	PRBS[415:4] <= 412'h0000_0001_ffff_ffe3_ffff_fe07_ffff_e38f_fffe_001f_fff1_ff1f_ff03_f03f_f1c7_1c7f_0000_00f1_ffff_f103_ffff_0dc7_fff1_000f_ff0d_ff1;
	PRBS[3:1] <= 3'b111;
    end else if (CE) begin
      PRBS[415] <= PRBS[31];
      PRBS[414] <= PRBS[30];
      PRBS[413] <= PRBS[29];
      PRBS[412] <= PRBS[28];
      PRBS[411] <= PRBS[27];
      PRBS[410] <= PRBS[26];
      PRBS[409] <= PRBS[25];
      PRBS[408] <= PRBS[24];
      PRBS[407] <= PRBS[23];
      PRBS[406] <= PRBS[22];
      PRBS[405] <= PRBS[21];
      PRBS[404] <= PRBS[20];
      PRBS[403] <= PRBS[19];
      PRBS[402] <= PRBS[18];
      PRBS[401] <= PRBS[17];
      PRBS[400] <= PRBS[16];
      PRBS[399] <= PRBS[15];
      PRBS[398] <= PRBS[14];
      PRBS[397] <= PRBS[13];
      PRBS[396] <= PRBS[12];
      PRBS[395] <= PRBS[11];
      PRBS[394] <= PRBS[10];
      PRBS[393] <= PRBS[9];
      PRBS[392] <= PRBS[8];
      PRBS[391] <= PRBS[7];
      PRBS[390] <= PRBS[6];
      PRBS[389] <= PRBS[5];
      PRBS[388] <= PRBS[4];
      PRBS[387] <= PRBS[3];
      PRBS[386] <= PRBS[2];
      PRBS[385] <= PRBS[1];
      PRBS[384] <= PRBS[28] ~^ PRBS[31];
      PRBS[383] <= PRBS[27] ~^ PRBS[30];
      PRBS[382] <= PRBS[26] ~^ PRBS[29];
      PRBS[381] <= PRBS[25] ~^ PRBS[28];
      PRBS[380] <= PRBS[24] ~^ PRBS[27];
      PRBS[379] <= PRBS[23] ~^ PRBS[26];
      PRBS[378] <= PRBS[22] ~^ PRBS[25];
      PRBS[377] <= PRBS[21] ~^ PRBS[24];
      PRBS[376] <= PRBS[20] ~^ PRBS[23];
      PRBS[375] <= PRBS[19] ~^ PRBS[22];
      PRBS[374] <= PRBS[18] ~^ PRBS[21];
      PRBS[373] <= PRBS[17] ~^ PRBS[20];
      PRBS[372] <= PRBS[16] ~^ PRBS[19];
      PRBS[371] <= PRBS[15] ~^ PRBS[18];
      PRBS[370] <= PRBS[14] ~^ PRBS[17];
      PRBS[369] <= PRBS[13] ~^ PRBS[16];
      PRBS[368] <= PRBS[12] ~^ PRBS[15];
      PRBS[367] <= PRBS[11] ~^ PRBS[14];
      PRBS[366] <= PRBS[10] ~^ PRBS[13];
      PRBS[365] <= PRBS[9] ~^ PRBS[12];
      PRBS[364] <= PRBS[8] ~^ PRBS[11];
      PRBS[363] <= PRBS[7] ~^ PRBS[10];
      PRBS[362] <= PRBS[6] ~^ PRBS[9];
      PRBS[361] <= PRBS[5] ~^ PRBS[8];
      PRBS[360] <= PRBS[4] ~^ PRBS[7];
      PRBS[359] <= PRBS[3] ~^ PRBS[6];
      PRBS[358] <= PRBS[2] ~^ PRBS[5];
      PRBS[357] <= PRBS[1] ~^ PRBS[4];
      PRBS[356] <= PRBS[ 3] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[355] <= PRBS[ 2] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[354] <= PRBS[ 1] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[353] <= PRBS[25] ~^ PRBS[31];
      PRBS[352] <= PRBS[24] ~^ PRBS[30];
      PRBS[351] <= PRBS[23] ~^ PRBS[29];
      PRBS[350] <= PRBS[22] ~^ PRBS[28];
      PRBS[349] <= PRBS[21] ~^ PRBS[27];
      PRBS[348] <= PRBS[20] ~^ PRBS[26];
      PRBS[347] <= PRBS[19] ~^ PRBS[25];
      PRBS[346] <= PRBS[18] ~^ PRBS[24];
      PRBS[345] <= PRBS[17] ~^ PRBS[23];
      PRBS[344] <= PRBS[16] ~^ PRBS[22];
      PRBS[343] <= PRBS[15] ~^ PRBS[21];
      PRBS[342] <= PRBS[14] ~^ PRBS[20];
      PRBS[341] <= PRBS[13] ~^ PRBS[19];
      PRBS[340] <= PRBS[12] ~^ PRBS[18];
      PRBS[339] <= PRBS[11] ~^ PRBS[17];
      PRBS[338] <= PRBS[10] ~^ PRBS[16];
      PRBS[337] <= PRBS[9] ~^ PRBS[15];
      PRBS[336] <= PRBS[8] ~^ PRBS[14];
      PRBS[335] <= PRBS[7] ~^ PRBS[13];
      PRBS[334] <= PRBS[6] ~^ PRBS[12];
      PRBS[333] <= PRBS[5] ~^ PRBS[11];
      PRBS[332] <= PRBS[4] ~^ PRBS[10];
      PRBS[331] <= PRBS[3] ~^ PRBS[9];
      PRBS[330] <= PRBS[2] ~^ PRBS[8];
      PRBS[329] <= PRBS[1] ~^ PRBS[7];
      PRBS[328] <= PRBS[ 6] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[327] <= PRBS[ 5] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[326] <= PRBS[ 4] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[325] <= PRBS[ 3] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[324] <= PRBS[ 2] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[323] <= PRBS[ 1] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[322] <= PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[321] <= PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[320] <= PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[319] <= PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[318] <= PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[317] <= PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[316] <= PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[315] <= PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[314] <= PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[313] <= PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[312] <= PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[311] <= PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20];
      PRBS[310] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19];
      PRBS[309] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18];
      PRBS[308] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17];
      PRBS[307] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16];
      PRBS[306] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15];
      PRBS[305] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14];
      PRBS[304] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13];
      PRBS[303] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12];
      PRBS[302] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11];
      PRBS[301] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10];
      PRBS[300] <= PRBS[ 3] ~^ PRBS[ 6] ~^ PRBS[ 9] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[299] <= PRBS[ 2] ~^ PRBS[ 5] ~^ PRBS[ 8] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[298] <= PRBS[ 1] ~^ PRBS[ 4] ~^ PRBS[ 7] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[297] <= PRBS[ 3] ~^ PRBS[ 6] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[296] <= PRBS[ 2] ~^ PRBS[ 5] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[295] <= PRBS[ 1] ~^ PRBS[ 4] ~^ PRBS[23] ~^ PRBS[29];
      PRBS[294] <= PRBS[ 3] ~^ PRBS[22] ~^ PRBS[31];
      PRBS[293] <= PRBS[ 2] ~^ PRBS[21] ~^ PRBS[30];
      PRBS[292] <= PRBS[ 1] ~^ PRBS[20] ~^ PRBS[29];
      PRBS[291] <= PRBS[19] ~^ PRBS[31];
      PRBS[290] <= PRBS[18] ~^ PRBS[30];
      PRBS[289] <= PRBS[17] ~^ PRBS[29];
      PRBS[288] <= PRBS[16] ~^ PRBS[28];
      PRBS[287] <= PRBS[15] ~^ PRBS[27];
      PRBS[286] <= PRBS[14] ~^ PRBS[26];
      PRBS[285] <= PRBS[13] ~^ PRBS[25];
      PRBS[284] <= PRBS[12] ~^ PRBS[24];
      PRBS[283] <= PRBS[11] ~^ PRBS[23];
      PRBS[282] <= PRBS[10] ~^ PRBS[22];
      PRBS[281] <= PRBS[ 9] ~^ PRBS[21];
      PRBS[280] <= PRBS[ 8] ~^ PRBS[20];
      PRBS[279] <= PRBS[ 7] ~^ PRBS[19];
      PRBS[278] <= PRBS[ 6] ~^ PRBS[18];
      PRBS[277] <= PRBS[ 5] ~^ PRBS[17];
      PRBS[276] <= PRBS[ 4] ~^ PRBS[16];
      PRBS[275] <= PRBS[ 3] ~^ PRBS[15];
      PRBS[274] <= PRBS[ 2] ~^ PRBS[14];
      PRBS[273] <= PRBS[ 1] ~^ PRBS[13];
      PRBS[272] <= PRBS[12] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[271] <= PRBS[11] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[270] <= PRBS[10] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[269] <= PRBS[9] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[268] <= PRBS[8] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[267] <= PRBS[7] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[266] <= PRBS[6] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[265] <= PRBS[5] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[264] <= PRBS[4] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[263] <= PRBS[3] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[262] <= PRBS[2] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[261] <= PRBS[1] ~^ PRBS[17] ~^ PRBS[20];
      PRBS[260] <= PRBS[16] ~^ PRBS[19] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[259] <= PRBS[15] ~^ PRBS[18] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[258] <= PRBS[14] ~^ PRBS[17] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[257] <= PRBS[13] ~^ PRBS[16] ~^ PRBS[25] ~^ PRBS[28]; //128
      PRBS[256] <= PRBS[12] ~^ PRBS[15] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[255] <= PRBS[11] ~^ PRBS[14] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[254] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[253] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[252] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[251] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[250] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[249] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[17] ~^ PRBS[20];
      PRBS[248] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[16] ~^ PRBS[19];
      PRBS[247] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[15] ~^ PRBS[18];
      PRBS[246] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[14] ~^ PRBS[17];
      PRBS[245] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[13] ~^ PRBS[16];
      PRBS[244] <= PRBS[3] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[243] <= PRBS[2] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[242] <= PRBS[1] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[241] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[240] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[239] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[23] ~^ PRBS[29];
      PRBS[238] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[22] ~^ PRBS[28];
      PRBS[237] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[21] ~^ PRBS[27];
      PRBS[236] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[20] ~^ PRBS[26];
      PRBS[235] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[19] ~^ PRBS[25];
      PRBS[234] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[18] ~^ PRBS[24];
      PRBS[233] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[17] ~^ PRBS[23];
      PRBS[232] <= PRBS[3] ~^ PRBS[16] ~^ PRBS[22] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[231] <= PRBS[2] ~^ PRBS[15] ~^ PRBS[21] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[230] <= PRBS[1] ~^ PRBS[14] ~^ PRBS[20] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[229] <= PRBS[13] ~^ PRBS[19] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[228] <= PRBS[12] ~^ PRBS[18] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[227] <= PRBS[11] ~^ PRBS[17] ~^ PRBS[23] ~^ PRBS[29];
      PRBS[226] <= PRBS[10] ~^ PRBS[16] ~^ PRBS[22] ~^ PRBS[28];
      PRBS[225] <= PRBS[9] ~^ PRBS[15] ~^ PRBS[21] ~^ PRBS[27]; //160
      PRBS[224] <= PRBS[8] ~^ PRBS[14] ~^ PRBS[20] ~^ PRBS[26];
      PRBS[223] <= PRBS[7] ~^ PRBS[13] ~^ PRBS[19] ~^ PRBS[25];
      PRBS[222] <= PRBS[6] ~^ PRBS[12] ~^ PRBS[18] ~^ PRBS[24];
      PRBS[221] <= PRBS[5] ~^ PRBS[11] ~^ PRBS[17] ~^ PRBS[23];
      PRBS[220] <= PRBS[4] ~^ PRBS[10] ~^ PRBS[16] ~^ PRBS[22];
      PRBS[219] <= PRBS[3] ~^ PRBS[9] ~^ PRBS[15] ~^ PRBS[21];
      PRBS[218] <= PRBS[2] ~^ PRBS[8] ~^ PRBS[14] ~^ PRBS[20];
      PRBS[217] <= PRBS[1] ~^ PRBS[7] ~^ PRBS[13] ~^ PRBS[19];
      PRBS[216] <= PRBS[6] ~^ PRBS[12] ~^ PRBS[18] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[215] <= PRBS[5] ~^ PRBS[11] ~^ PRBS[17] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[214] <= PRBS[4] ~^ PRBS[10] ~^ PRBS[16] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[213] <= PRBS[3] ~^ PRBS[9] ~^ PRBS[15] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[212] <= PRBS[2] ~^ PRBS[8] ~^ PRBS[14] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[211] <= PRBS[1] ~^ PRBS[7] ~^ PRBS[13] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[210] <= PRBS[6] ~^ PRBS[12] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[209] <= PRBS[5] ~^ PRBS[11] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[208] <= PRBS[4] ~^ PRBS[10] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29]; 
      PRBS[207] <= PRBS[3] ~^ PRBS[9] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[206] <= PRBS[2] ~^ PRBS[8] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[205] <= PRBS[1] ~^ PRBS[7] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26]; 
      PRBS[204] <= PRBS[6] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[203] <= PRBS[5] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[202] <= PRBS[4] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[201] <= PRBS[3] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[200] <= PRBS[2] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[199] <= PRBS[1] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26]; 
      PRBS[198] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[197] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[196] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[195] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[194] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[193] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[192] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[191] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[190] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[189] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22]; 
      PRBS[188] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[187] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[186] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[185] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[184] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[183] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[23] ~^ PRBS[29]; 
      PRBS[182] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[22] ~^ PRBS[31];
      PRBS[181] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[21] ~^ PRBS[30];
      PRBS[180] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[20] ~^ PRBS[29];
      PRBS[179] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[19] ~^ PRBS[31]; 
      PRBS[178] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[18] ~^ PRBS[30]; 
      PRBS[177] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[17] ~^ PRBS[29];
      PRBS[176] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[16] ~^ PRBS[31];
      PRBS[175] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[15] ~^ PRBS[30];
      PRBS[174] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[14] ~^ PRBS[29];
      PRBS[173] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[13] ~^ PRBS[31];
      PRBS[172] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[12] ~^ PRBS[30];
      PRBS[171] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[11] ~^ PRBS[29];
      PRBS[170] <= PRBS[3] ~^ PRBS[10] ~^ PRBS[31];
      PRBS[169] <= PRBS[2] ~^ PRBS[9] ~^ PRBS[30]; 
      PRBS[168] <= PRBS[1] ~^ PRBS[8] ~^ PRBS[29]; 
      PRBS[167] <= PRBS[7] ~^ PRBS[31];
      PRBS[166] <= PRBS[6] ~^ PRBS[30];
      PRBS[165] <= PRBS[5] ~^ PRBS[29];
      PRBS[164] <= PRBS[4] ~^ PRBS[28];
      PRBS[163] <= PRBS[3] ~^ PRBS[27];
      PRBS[162] <= PRBS[2] ~^ PRBS[26];
      PRBS[161] <= PRBS[1] ~^ PRBS[25];
      PRBS[160] <= PRBS[24] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[159] <= PRBS[23] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[158] <= PRBS[22] ~^ PRBS[26] ~^ PRBS[29]; 
      PRBS[157] <= PRBS[21] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[156] <= PRBS[20] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[155] <= PRBS[19] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[154] <= PRBS[18] ~^ PRBS[22] ~^ PRBS[25];
      PRBS[153] <= PRBS[17] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[152] <= PRBS[16] ~^ PRBS[20] ~^ PRBS[23];
      PRBS[151] <= PRBS[15] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[150] <= PRBS[14] ~^ PRBS[18] ~^ PRBS[21];
      PRBS[149] <= PRBS[13] ~^ PRBS[17] ~^ PRBS[20]; 
      PRBS[148] <= PRBS[12] ~^ PRBS[16] ~^ PRBS[19]; 
      PRBS[147] <= PRBS[11] ~^ PRBS[15] ~^ PRBS[18];
      PRBS[146] <= PRBS[10] ~^ PRBS[14] ~^ PRBS[17];
      PRBS[145] <= PRBS[9] ~^ PRBS[13] ~^ PRBS[16];
      PRBS[144] <= PRBS[8] ~^ PRBS[12] ~^ PRBS[15];
      PRBS[143] <= PRBS[7] ~^ PRBS[11] ~^ PRBS[14];
      PRBS[142] <= PRBS[6] ~^ PRBS[10] ~^ PRBS[13];
      PRBS[141] <= PRBS[5] ~^ PRBS[9] ~^ PRBS[12];
      PRBS[140] <= PRBS[4] ~^ PRBS[8] ~^ PRBS[11];
      PRBS[139] <= PRBS[3] ~^ PRBS[7] ~^ PRBS[10]; 
      PRBS[138] <= PRBS[2] ~^ PRBS[6] ~^ PRBS[9]; 
      PRBS[137] <= PRBS[1] ~^ PRBS[5] ~^ PRBS[8];
      PRBS[136] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[135] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[134] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[133] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[132] <= PRBS[3] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[131] <= PRBS[2] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[130] <= PRBS[1] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[129] <= PRBS[21] ~^ PRBS[24] ~^ PRBS[25] ~^ PRBS[31]; //256
      PRBS[128] <= PRBS[20] ~^ PRBS[23] ~^ PRBS[24] ~^ PRBS[30];
      PRBS[127] <= PRBS[19] ~^ PRBS[22] ~^ PRBS[23] ~^ PRBS[29]; 
      PRBS[126] <= PRBS[18] ~^ PRBS[21] ~^ PRBS[22] ~^ PRBS[28];    
      PRBS[125] <= PRBS[17] ~^ PRBS[20] ~^ PRBS[21] ~^ PRBS[27]; 
      PRBS[124] <= PRBS[16] ~^ PRBS[19] ~^ PRBS[20] ~^ PRBS[26]; 
      PRBS[123] <= PRBS[15] ~^ PRBS[18] ~^ PRBS[19] ~^ PRBS[25]; 
      PRBS[122] <= PRBS[14] ~^ PRBS[17] ~^ PRBS[18] ~^ PRBS[24]; 
      PRBS[121] <= PRBS[13] ~^ PRBS[16] ~^ PRBS[17] ~^ PRBS[23]; 
      PRBS[120] <= PRBS[12] ~^ PRBS[15] ~^ PRBS[16] ~^ PRBS[22];  
      PRBS[119] <= PRBS[11] ~^ PRBS[14] ~^ PRBS[15] ~^ PRBS[21]; 
      PRBS[118] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[14] ~^ PRBS[20];  
      PRBS[117] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[13] ~^ PRBS[19]; 
      PRBS[116] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[12] ~^ PRBS[18]; 
      PRBS[115] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[11] ~^ PRBS[17];  
      PRBS[114] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[10] ~^ PRBS[16]; 
      PRBS[113] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[9] ~^ PRBS[15]; 
      PRBS[112] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[8] ~^ PRBS[14];  
      PRBS[111] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[7] ~^ PRBS[13]; 
      PRBS[110] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[6] ~^ PRBS[12]; 
      PRBS[109] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[5] ~^ PRBS[11]; 
      PRBS[108] <= PRBS[3] ~^ PRBS[4] ~^ PRBS[10] ~^ PRBS[28] ~^ PRBS[31];  
      PRBS[107] <= PRBS[2] ~^ PRBS[3] ~^ PRBS[9] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[106] <= PRBS[1] ~^ PRBS[2] ~^ PRBS[8] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[105] <= PRBS[1] ~^ PRBS[7] ~^ PRBS[25] ~^ PRBS[31]; 
      PRBS[104] <= PRBS[6] ~^ PRBS[24] ~^ PRBS[28] ~^ PRBS[30] ~^ PRBS[31]; 
      PRBS[103] <= PRBS[5] ~^ PRBS[23] ~^ PRBS[27] ~^ PRBS[29] ~^ PRBS[30];
      PRBS[102] <= PRBS[4] ~^ PRBS[22] ~^ PRBS[26] ~^ PRBS[28] ~^ PRBS[29]; 
      PRBS[101] <= PRBS[3] ~^ PRBS[21] ~^ PRBS[25] ~^ PRBS[27] ~^ PRBS[28];
      PRBS[100] <= PRBS[2] ~^ PRBS[20] ~^ PRBS[24] ~^ PRBS[26] ~^ PRBS[27];
      PRBS[ 99] <= PRBS[1] ~^ PRBS[19] ~^ PRBS[23] ~^ PRBS[25] ~^ PRBS[26];
      PRBS[ 98] <= PRBS[18] ~^ PRBS[22] ~^ PRBS[24] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[ 97] <= PRBS[17] ~^ PRBS[21] ~^ PRBS[23] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[ 96] <= PRBS[16] ~^ PRBS[20] ~^ PRBS[22] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 95] <= PRBS[15] ~^ PRBS[19] ~^ PRBS[21] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 94] <= PRBS[14] ~^ PRBS[18] ~^ PRBS[20] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[27];
      PRBS[ 93] <= PRBS[13] ~^ PRBS[17] ~^ PRBS[19] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[ 92] <= PRBS[12] ~^ PRBS[16] ~^ PRBS[18] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[25]; 
      PRBS[ 91] <= PRBS[11] ~^ PRBS[15] ~^ PRBS[17] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[24];
      PRBS[ 90] <= PRBS[10] ~^ PRBS[14] ~^ PRBS[16] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[23];  
      PRBS[ 89] <= PRBS[9] ~^ PRBS[13] ~^ PRBS[15] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[22]; 
      PRBS[ 88] <= PRBS[8] ~^ PRBS[12] ~^ PRBS[14] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[21];  
      PRBS[ 87] <= PRBS[7] ~^ PRBS[11] ~^ PRBS[13] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[20]; 
      PRBS[ 86] <= PRBS[6] ~^ PRBS[10] ~^ PRBS[12] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[19]; 
      PRBS[ 85] <= PRBS[5] ~^ PRBS[9] ~^ PRBS[11] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[18];  
      PRBS[ 84] <= PRBS[4] ~^ PRBS[8] ~^ PRBS[10] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[17]; 
      PRBS[ 83] <= PRBS[3] ~^ PRBS[7] ~^ PRBS[9] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[16]; 
      PRBS[ 82] <= PRBS[2] ~^ PRBS[6] ~^ PRBS[8] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[15];  
      PRBS[ 81] <= PRBS[1] ~^ PRBS[5] ~^ PRBS[7] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[14]; 
      PRBS[ 80] <= PRBS[4] ~^ PRBS[6] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[ 79] <= PRBS[3] ~^ PRBS[5] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[12] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[ 78] <= PRBS[2] ~^ PRBS[4] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[11] ~^ PRBS[26] ~^ PRBS[29];  
      PRBS[ 77] <= PRBS[1] ~^ PRBS[3] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[10] ~^ PRBS[25] ~^ PRBS[28];  
      PRBS[ 76] <= PRBS[2] ~^ PRBS[3] ~^ PRBS[6] ~^ PRBS[9] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[ 75] <= PRBS[1] ~^ PRBS[2] ~^ PRBS[5] ~^ PRBS[8] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[ 74] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[7] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 73] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[ 72] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[24] ~^ PRBS[30]; 
      PRBS[ 71] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[23] ~^ PRBS[29];
      PRBS[ 70] <= PRBS[3] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[22] ~^ PRBS[31];
      PRBS[ 69] <= PRBS[2] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[21] ~^ PRBS[30];
      PRBS[ 68] <= PRBS[1] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[20] ~^ PRBS[29]; 
      PRBS[ 67] <= PRBS[15] ~^ PRBS[18] ~^ PRBS[19] ~^ PRBS[31]; 
      PRBS[ 66] <= PRBS[14] ~^ PRBS[17] ~^ PRBS[18] ~^ PRBS[30];
      PRBS[ 65] <= PRBS[13] ~^ PRBS[16] ~^ PRBS[17] ~^ PRBS[29]; 
      PRBS[ 64] <= PRBS[12] ~^ PRBS[15] ~^ PRBS[16] ~^ PRBS[28];
      PRBS[ 63] <= PRBS[11] ~^ PRBS[14] ~^ PRBS[15] ~^ PRBS[27];
      PRBS[ 62] <= PRBS[10] ~^ PRBS[13] ~^ PRBS[14] ~^ PRBS[26]; 
      PRBS[ 61] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[13] ~^ PRBS[25];
      PRBS[ 60] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[12] ~^ PRBS[24];
      PRBS[ 59] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[11] ~^ PRBS[23];
      PRBS[ 58] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[10] ~^ PRBS[22]; 
      PRBS[ 57] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[9] ~^ PRBS[21];
      PRBS[ 56] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[8] ~^ PRBS[20];
      PRBS[ 55] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[7] ~^ PRBS[19]; 
      PRBS[ 54] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[6] ~^ PRBS[18];
      PRBS[ 53] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[5] ~^ PRBS[17];
      PRBS[ 52] <= PRBS[3] ~^ PRBS[4] ~^ PRBS[16] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 51] <= PRBS[2] ~^ PRBS[3] ~^ PRBS[15] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 50] <= PRBS[1] ~^ PRBS[2] ~^ PRBS[14] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 49] <= PRBS[1] ~^ PRBS[13] ~^ PRBS[25] ~^ PRBS[31];
      PRBS[ 48] <= PRBS[12] ~^ PRBS[24] ~^ PRBS[28] ~^ PRBS[30] ~^ PRBS[31]; 
      PRBS[ 47] <= PRBS[11] ~^ PRBS[23] ~^ PRBS[27] ~^ PRBS[29] ~^ PRBS[30]; 
      PRBS[ 46] <= PRBS[10] ~^ PRBS[22] ~^ PRBS[26] ~^ PRBS[28] ~^ PRBS[29]; 
      PRBS[ 45] <= PRBS[9] ~^ PRBS[21] ~^ PRBS[25] ~^ PRBS[27] ~^ PRBS[28];  
      PRBS[ 44] <= PRBS[8] ~^ PRBS[20] ~^ PRBS[24] ~^ PRBS[26] ~^ PRBS[27]; 
      PRBS[ 43] <= PRBS[7] ~^ PRBS[19] ~^ PRBS[23] ~^ PRBS[25] ~^ PRBS[26]; 
      PRBS[ 42] <= PRBS[6] ~^ PRBS[18] ~^ PRBS[22] ~^ PRBS[24] ~^ PRBS[25];  
      PRBS[ 41] <= PRBS[5] ~^ PRBS[17] ~^ PRBS[21] ~^ PRBS[23] ~^ PRBS[24]; 
      PRBS[ 40] <= PRBS[4] ~^ PRBS[16] ~^ PRBS[20] ~^ PRBS[22] ~^ PRBS[23]; 
      PRBS[ 39] <= PRBS[3] ~^ PRBS[15] ~^ PRBS[19] ~^ PRBS[21] ~^ PRBS[22]; 
      PRBS[ 38] <= PRBS[2] ~^ PRBS[14] ~^ PRBS[18] ~^ PRBS[20] ~^ PRBS[21];  
      PRBS[ 37] <= PRBS[1] ~^ PRBS[13] ~^ PRBS[17] ~^ PRBS[19] ~^ PRBS[20]; 
      PRBS[ 36] <= PRBS[12] ~^ PRBS[16] ~^ PRBS[18] ~^ PRBS[19] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 35] <= PRBS[11] ~^ PRBS[15] ~^ PRBS[17] ~^ PRBS[18] ~^ PRBS[27] ~^ PRBS[30]; 
      PRBS[ 34] <= PRBS[10] ~^ PRBS[14] ~^ PRBS[16] ~^ PRBS[17] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[ 33] <= PRBS[9] ~^ PRBS[13] ~^ PRBS[15] ~^ PRBS[16] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 32] <= PRBS[8] ~^ PRBS[12] ~^ PRBS[14] ~^ PRBS[15] ~^ PRBS[24] ~^ PRBS[27];    
      PRBS[ 31] <= PRBS[7] ~^ PRBS[11] ~^ PRBS[13] ~^ PRBS[14] ~^ PRBS[23] ~^ PRBS[26];
      PRBS[ 30] <= PRBS[6] ~^ PRBS[10] ~^ PRBS[12] ~^ PRBS[13] ~^ PRBS[22] ~^ PRBS[25]; 
      PRBS[ 29] <= PRBS[5] ~^ PRBS[9] ~^ PRBS[11] ~^ PRBS[12] ~^ PRBS[21] ~^ PRBS[24]; 
      PRBS[ 28] <= PRBS[4] ~^ PRBS[8] ~^ PRBS[10] ~^ PRBS[11] ~^ PRBS[20] ~^ PRBS[23];  
      PRBS[ 27] <= PRBS[3] ~^ PRBS[7] ~^ PRBS[9] ~^ PRBS[10] ~^ PRBS[19] ~^ PRBS[22];
      PRBS[ 26] <= PRBS[2] ~^ PRBS[6] ~^ PRBS[8] ~^ PRBS[9] ~^ PRBS[18] ~^ PRBS[21]; 
      PRBS[ 25] <= PRBS[1] ~^ PRBS[5] ~^ PRBS[7] ~^ PRBS[8] ~^ PRBS[17] ~^ PRBS[20];  
      PRBS[ 24] <= PRBS[4] ~^ PRBS[6] ~^ PRBS[7] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[ 23] <= PRBS[3] ~^ PRBS[5] ~^ PRBS[6] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 22] <= PRBS[2] ~^ PRBS[4] ~^ PRBS[5] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[26] ~^ PRBS[29]; 
      PRBS[ 21] <= PRBS[1] ~^ PRBS[3] ~^ PRBS[4] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[25] ~^ PRBS[28];
      PRBS[ 20] <= PRBS[2] ~^ PRBS[3] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[28] ~^ PRBS[31];
      PRBS[ 19] <= PRBS[1] ~^ PRBS[2] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[ 18] <= PRBS[1] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[26] ~^ PRBS[28] ~^ PRBS[29] ~^ PRBS[31];
      PRBS[ 17] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[25] ~^ PRBS[27] ~^ PRBS[30] ~^ PRBS[31];
      PRBS[ 16] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[24] ~^ PRBS[26] ~^ PRBS[29] ~^ PRBS[30];
      PRBS[ 15] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[23] ~^ PRBS[25] ~^ PRBS[28] ~^ PRBS[29];  
      PRBS[ 14] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[22] ~^ PRBS[24] ~^ PRBS[27] ~^ PRBS[28]; 
      PRBS[ 13] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[21] ~^ PRBS[23] ~^ PRBS[26] ~^ PRBS[27]; 
      PRBS[ 12] <= PRBS[4] ~^ PRBS[7] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[20] ~^ PRBS[22] ~^ PRBS[25] ~^ PRBS[26]; 
      PRBS[ 11] <= PRBS[3] ~^ PRBS[6] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[19] ~^ PRBS[21] ~^ PRBS[24] ~^ PRBS[25]; 
      PRBS[ 10] <= PRBS[2] ~^ PRBS[5] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[18] ~^ PRBS[20] ~^ PRBS[23] ~^ PRBS[24]; 
      PRBS[  9] <= PRBS[1] ~^ PRBS[4] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[17] ~^ PRBS[19] ~^ PRBS[22] ~^ PRBS[23]; 
      PRBS[  8] <= PRBS[3] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[16] ~^ PRBS[18] ~^ PRBS[21] ~^ PRBS[22] ~^ PRBS[28] ~^ PRBS[31]; 
      PRBS[  7] <= PRBS[2] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[15] ~^ PRBS[17] ~^ PRBS[20] ~^ PRBS[21] ~^ PRBS[27] ~^ PRBS[30];
      PRBS[  6] <= PRBS[1] ~^ PRBS[10] ~^ PRBS[13] ~^ PRBS[14] ~^ PRBS[16] ~^ PRBS[19] ~^ PRBS[20] ~^ PRBS[26] ~^ PRBS[29];
      PRBS[  5] <= PRBS[9] ~^ PRBS[12] ~^ PRBS[13] ~^ PRBS[15] ~^ PRBS[18] ~^ PRBS[19] ~^ PRBS[25] ~^ PRBS[31]; 
      PRBS[  4] <= PRBS[8] ~^ PRBS[11] ~^ PRBS[12] ~^ PRBS[14] ~^ PRBS[17] ~^ PRBS[18] ~^ PRBS[24] ~^ PRBS[30]; 
      PRBS[  3] <= PRBS[7] ~^ PRBS[10] ~^ PRBS[11] ~^ PRBS[13] ~^ PRBS[16] ~^ PRBS[17] ~^ PRBS[23] ~^ PRBS[29]; 
      PRBS[  2] <= PRBS[6] ~^ PRBS[9] ~^ PRBS[10] ~^ PRBS[12] ~^ PRBS[15] ~^ PRBS[16] ~^ PRBS[22] ~^ PRBS[28];  
      PRBS[  1] <= PRBS[5] ~^ PRBS[8] ~^ PRBS[9] ~^ PRBS[11] ~^ PRBS[14] ~^ PRBS[15] ~^ PRBS[21] ~^ PRBS[27];//384 
    end
  end
endmodule




//// CRC 384
module mrmac_0_crc384b (
   i_eop,
   i_dat,
   i_ena,

   o_crc,
   o_crc_val,

   clk,
   reset
);

localparam DATA_WIDTH = 384;
localparam MTY_WIDTH  = 9;

input  wire i_eop;
input  wire [DATA_WIDTH-1:0] i_dat;
input  wire i_ena;

output reg  [31:0] o_crc;
output reg  o_crc_val;

input  wire clk;
input  wire reset;

reg  [31:0] crc, crc_nxt, crc_d1;


// calculate all of the CRCs in parallel
reg         eop, eop_d1, eop_d2;
reg         ena, ena_d1, ena_d2;
reg  [31:0] datapart_1_of_16;
reg  [31:0] datapart_2_of_16;
reg  [31:0] datapart_3_of_16;
reg  [31:0] datapart_4_of_16;
reg  [31:0] datapart_5_of_16;
reg  [31:0] datapart_6_of_16;
reg  [31:0] datapart_7_of_16;
reg  [31:0] datapart_8_of_16;
reg  [31:0] datapart_9_of_16;
reg  [31:0] datapart_10_of_16;
reg  [31:0] datapart_11_of_16;
reg  [31:0] datapart_12_of_16;
reg  [31:0] datapart_13_of_16;
reg  [31:0] datapart_14_of_16;
reg  [31:0] datapart_15_of_16;
reg  [31:0] datapart_16_of_16;

reg  [31:0] datapart_1_of_16_nxt;
reg  [31:0] datapart_2_of_16_nxt;
reg  [31:0] datapart_3_of_16_nxt;
reg  [31:0] datapart_4_of_16_nxt;
reg  [31:0] datapart_5_of_16_nxt;
reg  [31:0] datapart_6_of_16_nxt;
reg  [31:0] datapart_7_of_16_nxt;
reg  [31:0] datapart_8_of_16_nxt;
reg  [31:0] datapart_9_of_16_nxt;
reg  [31:0] datapart_10_of_16_nxt;
reg  [31:0] datapart_11_of_16_nxt;
reg  [31:0] datapart_12_of_16_nxt;
reg  [31:0] datapart_13_of_16_nxt;
reg  [31:0] datapart_14_of_16_nxt;
reg  [31:0] datapart_15_of_16_nxt;
reg  [31:0] datapart_16_of_16_nxt;
  
wire [31:0] datacomplete;
reg  [31:0] datacomplete_r;
  
assign datacomplete =   datapart_1_of_16  ^ datapart_2_of_16  ^ datapart_3_of_16  ^ datapart_4_of_16
                      ^ datapart_5_of_16  ^ datapart_6_of_16  ^ datapart_7_of_16  ^ datapart_8_of_16
                      ^ datapart_9_of_16  ^ datapart_10_of_16 ^ datapart_11_of_16 ^ datapart_12_of_16
                      ^ datapart_13_of_16 ^ datapart_14_of_16 ^ datapart_15_of_16 ^ datapart_16_of_16;
  
/* -----\/----- EXCLUDED -----\/-----
assign datacomplete =   datapart_1_of_16 ^ datapart_3_of_16  ^ datapart_5_of_16  ^ datapart_7_of_16
                      ^ datapart_9_of_16 ^ datapart_11_of_16 ^ datapart_13_of_16 ^ datapart_15_of_16;
 -----/\----- EXCLUDED -----/\----- */
wire [31:0] crc_384_nxt;


assign crc_384_nxt = fcs_next_c_383_0(crc) ^ datacomplete_r; 


// pick which crc to use
always @* begin
   if (ena_d1)
     begin
       crc_nxt = crc_384_nxt;
     end
   else
     begin
       crc_nxt = crc;
     end
end


// create the final crc result
// need to bit swap and complement
always @* begin
   if (ena_d2 && eop_d2) begin
     o_crc_val = 1'b1;    // only pulsed
   end else begin
     o_crc_val = 1'b0;
   end

      o_crc[0*8+0] = ~crc_d1[0*8+7];
      o_crc[0*8+1] = ~crc_d1[0*8+6];
      o_crc[0*8+2] = ~crc_d1[0*8+5];
      o_crc[0*8+3] = ~crc_d1[0*8+4];
      o_crc[0*8+4] = ~crc_d1[0*8+3];
      o_crc[0*8+5] = ~crc_d1[0*8+2];
      o_crc[0*8+6] = ~crc_d1[0*8+1];
      o_crc[0*8+7] = ~crc_d1[0*8+0];
      o_crc[1*8+0] = ~crc_d1[1*8+7];
      o_crc[1*8+1] = ~crc_d1[1*8+6];
      o_crc[1*8+2] = ~crc_d1[1*8+5];
      o_crc[1*8+3] = ~crc_d1[1*8+4];
      o_crc[1*8+4] = ~crc_d1[1*8+3];
      o_crc[1*8+5] = ~crc_d1[1*8+2];
      o_crc[1*8+6] = ~crc_d1[1*8+1];
      o_crc[1*8+7] = ~crc_d1[1*8+0];
      o_crc[2*8+0] = ~crc_d1[2*8+7];
      o_crc[2*8+1] = ~crc_d1[2*8+6];
      o_crc[2*8+2] = ~crc_d1[2*8+5];
      o_crc[2*8+3] = ~crc_d1[2*8+4];
      o_crc[2*8+4] = ~crc_d1[2*8+3];
      o_crc[2*8+5] = ~crc_d1[2*8+2];
      o_crc[2*8+6] = ~crc_d1[2*8+1];
      o_crc[2*8+7] = ~crc_d1[2*8+0];
      o_crc[3*8+0] = ~crc_d1[3*8+7];
      o_crc[3*8+1] = ~crc_d1[3*8+6];
      o_crc[3*8+2] = ~crc_d1[3*8+5];
      o_crc[3*8+3] = ~crc_d1[3*8+4];
      o_crc[3*8+4] = ~crc_d1[3*8+3];
      o_crc[3*8+5] = ~crc_d1[3*8+2];
      o_crc[3*8+6] = ~crc_d1[3*8+1];
      o_crc[3*8+7] = ~crc_d1[3*8+0];
end


// reverse the incoming data bits
reg   [DATA_WIDTH-1:0] dat_nxt;
integer j, k;
always @* begin
  for (k=0; k<DATA_WIDTH/64; k=k+1) begin
    for (j=0;j<8;j=j+1) begin
      dat_nxt[k*64+j*8+0] = i_dat[k*64+j*8+7];
      dat_nxt[k*64+j*8+1] = i_dat[k*64+j*8+6];
      dat_nxt[k*64+j*8+2] = i_dat[k*64+j*8+5];
      dat_nxt[k*64+j*8+3] = i_dat[k*64+j*8+4];
      dat_nxt[k*64+j*8+4] = i_dat[k*64+j*8+3];
      dat_nxt[k*64+j*8+5] = i_dat[k*64+j*8+2];
      dat_nxt[k*64+j*8+6] = i_dat[k*64+j*8+1];
      dat_nxt[k*64+j*8+7] = i_dat[k*64+j*8+0];
    end
  end

  datapart_1_of_16_nxt  = fcs_next_d_511_0_part_1_of_16(dat_nxt);
  datapart_2_of_16_nxt  = fcs_next_d_511_0_part_2_of_16(dat_nxt);
  datapart_3_of_16_nxt  = fcs_next_d_511_0_part_3_of_16(dat_nxt);
  datapart_4_of_16_nxt  = fcs_next_d_511_0_part_4_of_16(dat_nxt);
  datapart_5_of_16_nxt  = fcs_next_d_511_0_part_5_of_16(dat_nxt);
  datapart_6_of_16_nxt  = fcs_next_d_511_0_part_6_of_16(dat_nxt);
  datapart_7_of_16_nxt  = fcs_next_d_511_0_part_7_of_16(dat_nxt);
  datapart_8_of_16_nxt  = fcs_next_d_511_0_part_8_of_16(dat_nxt);
  datapart_9_of_16_nxt  = fcs_next_d_511_0_part_9_of_16(dat_nxt);
  datapart_10_of_16_nxt = fcs_next_d_511_0_part_10_of_16(dat_nxt);
  datapart_11_of_16_nxt = fcs_next_d_511_0_part_11_of_16(dat_nxt);
  datapart_12_of_16_nxt = fcs_next_d_511_0_part_12_of_16(dat_nxt);
  datapart_13_of_16_nxt = fcs_next_d_511_0_part_13_of_16(dat_nxt);
  datapart_14_of_16_nxt = fcs_next_d_511_0_part_14_of_16(dat_nxt);
  datapart_15_of_16_nxt = fcs_next_d_511_0_part_15_of_16(dat_nxt);
  datapart_16_of_16_nxt = fcs_next_d_511_0_part_16_of_16(dat_nxt);
/* -----\/----- EXCLUDED -----\/-----
  datapart_1_of_16_nxt  = fcs_next_d_511_0_part_1_of_16(dat_nxt) ^ fcs_next_d_511_0_part_2_of_16(dat_nxt);
  datapart_3_of_16_nxt  = fcs_next_d_511_0_part_3_of_16(dat_nxt) ^ fcs_next_d_511_0_part_4_of_16(dat_nxt);
  datapart_5_of_16_nxt  = fcs_next_d_511_0_part_5_of_16(dat_nxt) ^ fcs_next_d_511_0_part_6_of_16(dat_nxt);
  datapart_7_of_16_nxt  = fcs_next_d_511_0_part_7_of_16(dat_nxt) ^ fcs_next_d_511_0_part_8_of_16(dat_nxt);
  datapart_9_of_16_nxt  = fcs_next_d_511_0_part_9_of_16(dat_nxt) ^ fcs_next_d_511_0_part_10_of_16(dat_nxt);
  datapart_11_of_16_nxt = fcs_next_d_511_0_part_11_of_16(dat_nxt) ^ fcs_next_d_511_0_part_12_of_16(dat_nxt);
  datapart_13_of_16_nxt = fcs_next_d_511_0_part_13_of_16(dat_nxt) ^ fcs_next_d_511_0_part_14_of_16(dat_nxt);
  datapart_15_of_16_nxt = fcs_next_d_511_0_part_15_of_16(dat_nxt) ^ fcs_next_d_511_0_part_16_of_16(dat_nxt);
 -----/\----- EXCLUDED -----/\----- */
end

// registers
  always @( posedge clk )
    begin
      if ( reset == 1'b1 )
        begin
          ena         <= 1'b0;
          ena_d1      <= 1'b0;
          ena_d2      <= 1'b0;     
          crc         <= {32 {1'b0}};
        end else begin
          ena         <= i_ena;
          ena_d1      <= ena;
          ena_d2      <= ena_d1;
          
          if(ena_d1 && eop_d1)
            crc <= '0;
          else
            crc  <= crc_nxt;
        end
    end

always @(posedge clk) begin
  eop_d1            <= eop;
  eop_d2            <= eop_d1;  
  crc_d1            <= crc;
  eop               <= i_eop;
  datacomplete_r    <= datacomplete;  
  datapart_1_of_16  <= datapart_1_of_16_nxt;
  datapart_2_of_16  <= datapart_2_of_16_nxt;
  datapart_3_of_16  <= datapart_3_of_16_nxt;
  datapart_4_of_16  <= datapart_4_of_16_nxt;
  datapart_5_of_16  <= datapart_5_of_16_nxt;
  datapart_6_of_16  <= datapart_6_of_16_nxt;
  datapart_7_of_16  <= datapart_7_of_16_nxt;
  datapart_8_of_16  <= datapart_8_of_16_nxt;
  datapart_9_of_16  <= datapart_9_of_16_nxt;
  datapart_10_of_16 <= datapart_10_of_16_nxt;
  datapart_11_of_16 <= datapart_11_of_16_nxt;
  datapart_12_of_16 <= datapart_12_of_16_nxt;
  datapart_13_of_16 <= datapart_13_of_16_nxt;
  datapart_14_of_16 <= datapart_14_of_16_nxt;
  datapart_15_of_16 <= datapart_15_of_16_nxt;
  datapart_16_of_16 <= datapart_16_of_16_nxt;
end


function [31:0] fcs_next_d_511_0_part_1_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[0] ^ din[6] ^ din[9] ^ din[10] ^ din[12] ^ din[16] ^
              din[24] ^ din[25] ^ din[26] ^ din[28] ^ din[29] ^ din[30] ^
              din[31];

    dout[1] = din[0] ^ din[1] ^ din[6] ^ din[7] ^ din[9] ^ din[11] ^
              din[12] ^ din[13] ^ din[16] ^ din[17] ^ din[24] ^ din[27] ^
              din[28];

    dout[2] = din[0] ^ din[1] ^ din[2] ^ din[6] ^ din[7] ^ din[8] ^
              din[9] ^ din[13] ^ din[14] ^ din[16] ^ din[17] ^ din[18] ^
              din[24] ^ din[26] ^ din[30] ^ din[31];

    dout[3] = din[1] ^ din[2] ^ din[3] ^ din[7] ^ din[8] ^ din[9] ^
              din[10] ^ din[14] ^ din[15] ^ din[17] ^ din[18] ^ din[19] ^
              din[25] ^ din[27] ^ din[31];

    dout[4] = din[0] ^ din[2] ^ din[3] ^ din[4] ^ din[6] ^ din[8] ^
              din[11] ^ din[12] ^ din[15] ^ din[18] ^ din[19] ^ din[20] ^
              din[24] ^ din[25] ^ din[29] ^ din[30] ^ din[31];

    dout[5] = din[0] ^ din[1] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^
              din[7] ^ din[10] ^ din[13] ^ din[19] ^ din[20] ^ din[21] ^
              din[24] ^ din[28] ^ din[29];

    dout[6] = din[1] ^ din[2] ^ din[4] ^ din[5] ^ din[6] ^ din[7] ^
              din[8] ^ din[11] ^ din[14] ^ din[20] ^ din[21] ^ din[22] ^
              din[25] ^ din[29] ^ din[30];

    dout[7] = din[0] ^ din[2] ^ din[3] ^ din[5] ^ din[7] ^ din[8] ^
              din[10] ^ din[15] ^ din[16] ^ din[21] ^ din[22] ^ din[23] ^
              din[24] ^ din[25] ^ din[28] ^ din[29];

    dout[8] = din[0] ^ din[1] ^ din[3] ^ din[4] ^ din[8] ^ din[10] ^
              din[11] ^ din[12] ^ din[17] ^ din[22] ^ din[23] ^ din[28] ^
              din[31];

    dout[9] = din[1] ^ din[2] ^ din[4] ^ din[5] ^ din[9] ^ din[11] ^
              din[12] ^ din[13] ^ din[18] ^ din[23] ^ din[24] ^ din[29];

    dout[10] = din[0] ^ din[2] ^ din[3] ^ din[5] ^ din[9] ^ din[13] ^
               din[14] ^ din[16] ^ din[19] ^ din[26] ^ din[28] ^ din[29] ^
               din[31];

    dout[11] = din[0] ^ din[1] ^ din[3] ^ din[4] ^ din[9] ^ din[12] ^
               din[14] ^ din[15] ^ din[16] ^ din[17] ^ din[20] ^ din[24] ^
               din[25] ^ din[26] ^ din[27] ^ din[28] ^ din[31];

    dout[12] = din[0] ^ din[1] ^ din[2] ^ din[4] ^ din[5] ^ din[6] ^
               din[9] ^ din[12] ^ din[13] ^ din[15] ^ din[17] ^ din[18] ^
               din[21] ^ din[24] ^ din[27] ^ din[30] ^ din[31];

    dout[13] = din[1] ^ din[2] ^ din[3] ^ din[5] ^ din[6] ^ din[7] ^
               din[10] ^ din[13] ^ din[14] ^ din[16] ^ din[18] ^ din[19] ^
               din[22] ^ din[25] ^ din[28] ^ din[31];

    dout[14] = din[2] ^ din[3] ^ din[4] ^ din[6] ^ din[7] ^ din[8] ^
               din[11] ^ din[14] ^ din[15] ^ din[17] ^ din[19] ^ din[20] ^
               din[23] ^ din[26] ^ din[29];

    dout[15] = din[3] ^ din[4] ^ din[5] ^ din[7] ^ din[8] ^ din[9] ^
               din[12] ^ din[15] ^ din[16] ^ din[18] ^ din[20] ^ din[21] ^
               din[24] ^ din[27] ^ din[30];

    dout[16] = din[0] ^ din[4] ^ din[5] ^ din[8] ^ din[12] ^ din[13] ^
               din[17] ^ din[19] ^ din[21] ^ din[22] ^ din[24] ^ din[26] ^
               din[29] ^ din[30];

    dout[17] = din[1] ^ din[5] ^ din[6] ^ din[9] ^ din[13] ^ din[14] ^
               din[18] ^ din[20] ^ din[22] ^ din[23] ^ din[25] ^ din[27] ^
               din[30] ^ din[31];

    dout[18] = din[2] ^ din[6] ^ din[7] ^ din[10] ^ din[14] ^ din[15] ^
               din[19] ^ din[21] ^ din[23] ^ din[24] ^ din[26] ^ din[28] ^
               din[31];

    dout[19] = din[3] ^ din[7] ^ din[8] ^ din[11] ^ din[15] ^ din[16] ^
               din[20] ^ din[22] ^ din[24] ^ din[25] ^ din[27] ^ din[29];

    dout[20] = din[4] ^ din[8] ^ din[9] ^ din[12] ^ din[16] ^ din[17] ^
               din[21] ^ din[23] ^ din[25] ^ din[26] ^ din[28] ^ din[30];

    dout[21] = din[5] ^ din[9] ^ din[10] ^ din[13] ^ din[17] ^ din[18] ^
               din[22] ^ din[24] ^ din[26] ^ din[27] ^ din[29] ^ din[31];

    dout[22] = din[0] ^ din[9] ^ din[11] ^ din[12] ^ din[14] ^ din[16] ^
               din[18] ^ din[19] ^ din[23] ^ din[24] ^ din[26] ^ din[27] ^
               din[29] ^ din[31];

    dout[23] = din[0] ^ din[1] ^ din[6] ^ din[9] ^ din[13] ^ din[15] ^
               din[16] ^ din[17] ^ din[19] ^ din[20] ^ din[26] ^ din[27] ^
               din[29] ^ din[31];

    dout[24] = din[1] ^ din[2] ^ din[7] ^ din[10] ^ din[14] ^ din[16] ^
               din[17] ^ din[18] ^ din[20] ^ din[21] ^ din[27] ^ din[28] ^
               din[30];

    dout[25] = din[2] ^ din[3] ^ din[8] ^ din[11] ^ din[15] ^ din[17] ^
               din[18] ^ din[19] ^ din[21] ^ din[22] ^ din[28] ^ din[29] ^
               din[31];

    dout[26] = din[0] ^ din[3] ^ din[4] ^ din[6] ^ din[10] ^ din[18] ^
               din[19] ^ din[20] ^ din[22] ^ din[23] ^ din[24] ^ din[25] ^
               din[26] ^ din[28] ^ din[31];

    dout[27] = din[1] ^ din[4] ^ din[5] ^ din[7] ^ din[11] ^ din[19] ^
               din[20] ^ din[21] ^ din[23] ^ din[24] ^ din[25] ^ din[26] ^
               din[27] ^ din[29];

    dout[28] = din[2] ^ din[5] ^ din[6] ^ din[8] ^ din[12] ^ din[20] ^
               din[21] ^ din[22] ^ din[24] ^ din[25] ^ din[26] ^ din[27] ^
               din[28] ^ din[30];

    dout[29] = din[3] ^ din[6] ^ din[7] ^ din[9] ^ din[13] ^ din[21] ^
               din[22] ^ din[23] ^ din[25] ^ din[26] ^ din[27] ^ din[28] ^
               din[29] ^ din[31];

    dout[30] = din[4] ^ din[7] ^ din[8] ^ din[10] ^ din[14] ^ din[22] ^
               din[23] ^ din[24] ^ din[26] ^ din[27] ^ din[28] ^ din[29] ^
               din[30];

    dout[31] = din[5] ^ din[8] ^ din[9] ^ din[11] ^ din[15] ^ din[23] ^
               din[24] ^ din[25] ^ din[27] ^ din[28] ^ din[29] ^ din[30] ^
               din[31];

    fcs_next_d_511_0_part_1_of_16 = dout;

  end

  /* TOTAL XOR GATES: 420 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_2_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[32] ^ din[34] ^ din[37] ^ din[44] ^ din[45] ^ din[47] ^
              din[48] ^ din[50] ^ din[53] ^ din[54] ^ din[55] ^ din[58] ^
              din[60] ^ din[61] ^ din[63];

    dout[1] = din[33] ^ din[34] ^ din[35] ^ din[37] ^ din[38] ^ din[44] ^
              din[46] ^ din[47] ^ din[49] ^ din[50] ^ din[51] ^ din[53] ^
              din[56] ^ din[58] ^ din[59] ^ din[60] ^ din[62] ^ din[63];

    dout[2] = din[32] ^ din[35] ^ din[36] ^ din[37] ^ din[38] ^ din[39] ^
              din[44] ^ din[51] ^ din[52] ^ din[53] ^ din[55] ^ din[57] ^
              din[58] ^ din[59];

    dout[3] = din[32] ^ din[33] ^ din[36] ^ din[37] ^ din[38] ^ din[39] ^
              din[40] ^ din[45] ^ din[52] ^ din[53] ^ din[54] ^ din[56] ^
              din[58] ^ din[59] ^ din[60];

    dout[4] = din[33] ^ din[38] ^ din[39] ^ din[40] ^ din[41] ^ din[44] ^
              din[45] ^ din[46] ^ din[47] ^ din[48] ^ din[50] ^ din[57] ^
              din[58] ^ din[59] ^ din[63];

    dout[5] = din[37] ^ din[39] ^ din[40] ^ din[41] ^ din[42] ^ din[44] ^
              din[46] ^ din[49] ^ din[50] ^ din[51] ^ din[53] ^ din[54] ^
              din[55] ^ din[59] ^ din[61] ^ din[63];

    dout[6] = din[38] ^ din[40] ^ din[41] ^ din[42] ^ din[43] ^ din[45] ^
              din[47] ^ din[50] ^ din[51] ^ din[52] ^ din[54] ^ din[55] ^
              din[56] ^ din[60] ^ din[62];

    dout[7] = din[32] ^ din[34] ^ din[37] ^ din[39] ^ din[41] ^ din[42] ^
              din[43] ^ din[45] ^ din[46] ^ din[47] ^ din[50] ^ din[51] ^
              din[52] ^ din[54] ^ din[56] ^ din[57] ^ din[58] ^ din[60];

    dout[8] = din[32] ^ din[33] ^ din[34] ^ din[35] ^ din[37] ^ din[38] ^
              din[40] ^ din[42] ^ din[43] ^ din[45] ^ din[46] ^ din[50] ^
              din[51] ^ din[52] ^ din[54] ^ din[57] ^ din[59] ^ din[60] ^
              din[63];

    dout[9] = din[32] ^ din[33] ^ din[34] ^ din[35] ^ din[36] ^ din[38] ^
              din[39] ^ din[41] ^ din[43] ^ din[44] ^ din[46] ^ din[47] ^
              din[51] ^ din[52] ^ din[53] ^ din[55] ^ din[58] ^ din[60] ^
              din[61];

    dout[10] = din[32] ^ din[33] ^ din[35] ^ din[36] ^ din[39] ^ din[40] ^
               din[42] ^ din[50] ^ din[52] ^ din[55] ^ din[56] ^ din[58] ^
               din[59] ^ din[60] ^ din[62] ^ din[63];

    dout[11] = din[33] ^ din[36] ^ din[40] ^ din[41] ^ din[43] ^ din[44] ^
               din[45] ^ din[47] ^ din[48] ^ din[50] ^ din[51] ^ din[54] ^
               din[55] ^ din[56] ^ din[57] ^ din[58] ^ din[59];

    dout[12] = din[41] ^ din[42] ^ din[46] ^ din[47] ^ din[49] ^ din[50] ^
               din[51] ^ din[52] ^ din[53] ^ din[54] ^ din[56] ^ din[57] ^
               din[59] ^ din[61] ^ din[63];

    dout[13] = din[32] ^ din[42] ^ din[43] ^ din[47] ^ din[48] ^ din[50] ^
               din[51] ^ din[52] ^ din[53] ^ din[54] ^ din[55] ^ din[57] ^
               din[58] ^ din[60] ^ din[62];

    dout[14] = din[32] ^ din[33] ^ din[43] ^ din[44] ^ din[48] ^ din[49] ^
               din[51] ^ din[52] ^ din[53] ^ din[54] ^ din[55] ^ din[56] ^
               din[58] ^ din[59] ^ din[61] ^ din[63];

    dout[15] = din[33] ^ din[34] ^ din[44] ^ din[45] ^ din[49] ^ din[50] ^
               din[52] ^ din[53] ^ din[54] ^ din[55] ^ din[56] ^ din[57] ^
               din[59] ^ din[60] ^ din[62];

    dout[16] = din[32] ^ din[35] ^ din[37] ^ din[44] ^ din[46] ^ din[47] ^
               din[48] ^ din[51] ^ din[56] ^ din[57];

    dout[17] = din[33] ^ din[36] ^ din[38] ^ din[45] ^ din[47] ^ din[48] ^
               din[49] ^ din[52] ^ din[57] ^ din[58];

    dout[18] = din[32] ^ din[34] ^ din[37] ^ din[39] ^ din[46] ^ din[48] ^
               din[49] ^ din[50] ^ din[53] ^ din[58] ^ din[59];

    dout[19] = din[32] ^ din[33] ^ din[35] ^ din[38] ^ din[40] ^ din[47] ^
               din[49] ^ din[50] ^ din[51] ^ din[54] ^ din[59] ^ din[60];

    dout[20] = din[33] ^ din[34] ^ din[36] ^ din[39] ^ din[41] ^ din[48] ^
               din[50] ^ din[51] ^ din[52] ^ din[55] ^ din[60] ^ din[61];

    dout[21] = din[34] ^ din[35] ^ din[37] ^ din[40] ^ din[42] ^ din[49] ^
               din[51] ^ din[52] ^ din[53] ^ din[56] ^ din[61] ^ din[62];

    dout[22] = din[34] ^ din[35] ^ din[36] ^ din[37] ^ din[38] ^ din[41] ^
               din[43] ^ din[44] ^ din[45] ^ din[47] ^ din[48] ^ din[52] ^
               din[55] ^ din[57] ^ din[58] ^ din[60] ^ din[61] ^ din[62];

    dout[23] = din[34] ^ din[35] ^ din[36] ^ din[38] ^ din[39] ^ din[42] ^
               din[46] ^ din[47] ^ din[49] ^ din[50] ^ din[54] ^ din[55] ^
               din[56] ^ din[59] ^ din[60] ^ din[62];

    dout[24] = din[32] ^ din[35] ^ din[36] ^ din[37] ^ din[39] ^ din[40] ^
               din[43] ^ din[47] ^ din[48] ^ din[50] ^ din[51] ^ din[55] ^
               din[56] ^ din[57] ^ din[60] ^ din[61] ^ din[63];

    dout[25] = din[33] ^ din[36] ^ din[37] ^ din[38] ^ din[40] ^ din[41] ^
               din[44] ^ din[48] ^ din[49] ^ din[51] ^ din[52] ^ din[56] ^
               din[57] ^ din[58] ^ din[61] ^ din[62];

    dout[26] = din[38] ^ din[39] ^ din[41] ^ din[42] ^ din[44] ^ din[47] ^
               din[48] ^ din[49] ^ din[52] ^ din[54] ^ din[55] ^ din[57] ^
               din[59] ^ din[60] ^ din[61] ^ din[62];

    dout[27] = din[32] ^ din[39] ^ din[40] ^ din[42] ^ din[43] ^ din[45] ^
               din[48] ^ din[49] ^ din[50] ^ din[53] ^ din[55] ^ din[56] ^
               din[58] ^ din[60] ^ din[61] ^ din[62] ^ din[63];

    dout[28] = din[33] ^ din[40] ^ din[41] ^ din[43] ^ din[44] ^ din[46] ^
               din[49] ^ din[50] ^ din[51] ^ din[54] ^ din[56] ^ din[57] ^
               din[59] ^ din[61] ^ din[62] ^ din[63];

    dout[29] = din[34] ^ din[41] ^ din[42] ^ din[44] ^ din[45] ^ din[47] ^
               din[50] ^ din[51] ^ din[52] ^ din[55] ^ din[57] ^ din[58] ^
               din[60] ^ din[62] ^ din[63];

    dout[30] = din[32] ^ din[35] ^ din[42] ^ din[43] ^ din[45] ^ din[46] ^
               din[48] ^ din[51] ^ din[52] ^ din[53] ^ din[56] ^ din[58] ^
               din[59] ^ din[61] ^ din[63];

    dout[31] = din[33] ^ din[36] ^ din[43] ^ din[44] ^ din[46] ^ din[47] ^
               din[49] ^ din[52] ^ din[53] ^ din[54] ^ din[57] ^ din[59] ^
               din[60] ^ din[62];

    fcs_next_d_511_0_part_2_of_16 = dout;

  end

  /* TOTAL XOR GATES: 873 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_3_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[65] ^ din[66] ^ din[67] ^ din[68] ^ din[72] ^ din[73] ^
              din[79] ^ din[81] ^ din[82] ^ din[83] ^ din[84] ^ din[85] ^
              din[87] ^ din[94] ^ din[95];

    dout[1] = din[64] ^ din[65] ^ din[69] ^ din[72] ^ din[74] ^ din[79] ^
              din[80] ^ din[81] ^ din[86] ^ din[87] ^ din[88] ^ din[94];

    dout[2] = din[64] ^ din[67] ^ din[68] ^ din[70] ^ din[72] ^ din[75] ^
              din[79] ^ din[80] ^ din[83] ^ din[84] ^ din[85] ^ din[88] ^
              din[89] ^ din[94];

    dout[3] = din[65] ^ din[68] ^ din[69] ^ din[71] ^ din[73] ^ din[76] ^
              din[80] ^ din[81] ^ din[84] ^ din[85] ^ din[86] ^ din[89] ^
              din[90] ^ din[95];

    dout[4] = din[65] ^ din[67] ^ din[68] ^ din[69] ^ din[70] ^ din[73] ^
              din[74] ^ din[77] ^ din[79] ^ din[83] ^ din[84] ^ din[86] ^
              din[90] ^ din[91] ^ din[94] ^ din[95];

    dout[5] = din[64] ^ din[65] ^ din[67] ^ din[69] ^ din[70] ^ din[71] ^
              din[72] ^ din[73] ^ din[74] ^ din[75] ^ din[78] ^ din[79] ^
              din[80] ^ din[81] ^ din[82] ^ din[83] ^ din[91] ^ din[92] ^
              din[94];

    dout[6] = din[64] ^ din[65] ^ din[66] ^ din[68] ^ din[70] ^ din[71] ^
              din[72] ^ din[73] ^ din[74] ^ din[75] ^ din[76] ^ din[79] ^
              din[80] ^ din[81] ^ din[82] ^ din[83] ^ din[84] ^ din[92] ^
              din[93] ^ din[95];

    dout[7] = din[68] ^ din[69] ^ din[71] ^ din[74] ^ din[75] ^ din[76] ^
              din[77] ^ din[79] ^ din[80] ^ din[87] ^ din[93] ^ din[95];

    dout[8] = din[65] ^ din[66] ^ din[67] ^ din[68] ^ din[69] ^ din[70] ^
              din[73] ^ din[75] ^ din[76] ^ din[77] ^ din[78] ^ din[79] ^
              din[80] ^ din[82] ^ din[83] ^ din[84] ^ din[85] ^ din[87] ^
              din[88] ^ din[95];

    dout[9] = din[64] ^ din[66] ^ din[67] ^ din[68] ^ din[69] ^ din[70] ^
              din[71] ^ din[74] ^ din[76] ^ din[77] ^ din[78] ^ din[79] ^
              din[80] ^ din[81] ^ din[83] ^ din[84] ^ din[85] ^ din[86] ^
              din[88] ^ din[89];

    dout[10] = din[66] ^ din[69] ^ din[70] ^ din[71] ^ din[73] ^ din[75] ^
               din[77] ^ din[78] ^ din[80] ^ din[83] ^ din[86] ^ din[89] ^
               din[90] ^ din[94] ^ din[95];

    dout[11] = din[64] ^ din[65] ^ din[66] ^ din[68] ^ din[70] ^ din[71] ^
               din[73] ^ din[74] ^ din[76] ^ din[78] ^ din[82] ^ din[83] ^
               din[85] ^ din[90] ^ din[91] ^ din[94];

    dout[12] = din[68] ^ din[69] ^ din[71] ^ din[73] ^ din[74] ^ din[75] ^
               din[77] ^ din[81] ^ din[82] ^ din[85] ^ din[86] ^ din[87] ^
               din[91] ^ din[92] ^ din[94];

    dout[13] = din[64] ^ din[69] ^ din[70] ^ din[72] ^ din[74] ^ din[75] ^
               din[76] ^ din[78] ^ din[82] ^ din[83] ^ din[86] ^ din[87] ^
               din[88] ^ din[92] ^ din[93] ^ din[95];

    dout[14] = din[65] ^ din[70] ^ din[71] ^ din[73] ^ din[75] ^ din[76] ^
               din[77] ^ din[79] ^ din[83] ^ din[84] ^ din[87] ^ din[88] ^
               din[89] ^ din[93] ^ din[94];

    dout[15] = din[64] ^ din[66] ^ din[71] ^ din[72] ^ din[74] ^ din[76] ^
               din[77] ^ din[78] ^ din[80] ^ din[84] ^ din[85] ^ din[88] ^
               din[89] ^ din[90] ^ din[94] ^ din[95];

    dout[16] = din[66] ^ din[68] ^ din[75] ^ din[77] ^ din[78] ^ din[82] ^
               din[83] ^ din[84] ^ din[86] ^ din[87] ^ din[89] ^ din[90] ^
               din[91] ^ din[94];

    dout[17] = din[67] ^ din[69] ^ din[76] ^ din[78] ^ din[79] ^ din[83] ^
               din[84] ^ din[85] ^ din[87] ^ din[88] ^ din[90] ^ din[91] ^
               din[92] ^ din[95];

    dout[18] = din[68] ^ din[70] ^ din[77] ^ din[79] ^ din[80] ^ din[84] ^
               din[85] ^ din[86] ^ din[88] ^ din[89] ^ din[91] ^ din[92] ^
               din[93];

    dout[19] = din[69] ^ din[71] ^ din[78] ^ din[80] ^ din[81] ^ din[85] ^
               din[86] ^ din[87] ^ din[89] ^ din[90] ^ din[92] ^ din[93] ^
               din[94];

    dout[20] = din[70] ^ din[72] ^ din[79] ^ din[81] ^ din[82] ^ din[86] ^
               din[87] ^ din[88] ^ din[90] ^ din[91] ^ din[93] ^ din[94] ^
               din[95];

    dout[21] = din[71] ^ din[73] ^ din[80] ^ din[82] ^ din[83] ^ din[87] ^
               din[88] ^ din[89] ^ din[91] ^ din[92] ^ din[94] ^ din[95];

    dout[22] = din[65] ^ din[66] ^ din[67] ^ din[68] ^ din[73] ^ din[74] ^
               din[79] ^ din[82] ^ din[85] ^ din[87] ^ din[88] ^ din[89] ^
               din[90] ^ din[92] ^ din[93] ^ din[94];

    dout[23] = din[65] ^ din[69] ^ din[72] ^ din[73] ^ din[74] ^ din[75] ^
               din[79] ^ din[80] ^ din[81] ^ din[82] ^ din[84] ^ din[85] ^
               din[86] ^ din[87] ^ din[88] ^ din[89] ^ din[90] ^ din[91] ^
               din[93];

    dout[24] = din[66] ^ din[70] ^ din[73] ^ din[74] ^ din[75] ^ din[76] ^
               din[80] ^ din[81] ^ din[82] ^ din[83] ^ din[85] ^ din[86] ^
               din[87] ^ din[88] ^ din[89] ^ din[90] ^ din[91] ^ din[92] ^
               din[94];

    dout[25] = din[64] ^ din[67] ^ din[71] ^ din[74] ^ din[75] ^ din[76] ^
               din[77] ^ din[81] ^ din[82] ^ din[83] ^ din[84] ^ din[86] ^
               din[87] ^ din[88] ^ din[89] ^ din[90] ^ din[91] ^ din[92] ^
               din[93] ^ din[95];

    dout[26] = din[66] ^ din[67] ^ din[73] ^ din[75] ^ din[76] ^ din[77] ^
               din[78] ^ din[79] ^ din[81] ^ din[88] ^ din[89] ^ din[90] ^
               din[91] ^ din[92] ^ din[93] ^ din[95];

    dout[27] = din[67] ^ din[68] ^ din[74] ^ din[76] ^ din[77] ^ din[78] ^
               din[79] ^ din[80] ^ din[82] ^ din[89] ^ din[90] ^ din[91] ^
               din[92] ^ din[93] ^ din[94];

    dout[28] = din[64] ^ din[68] ^ din[69] ^ din[75] ^ din[77] ^ din[78] ^
               din[79] ^ din[80] ^ din[81] ^ din[83] ^ din[90] ^ din[91] ^
               din[92] ^ din[93] ^ din[94] ^ din[95];

    dout[29] = din[64] ^ din[65] ^ din[69] ^ din[70] ^ din[76] ^ din[78] ^
               din[79] ^ din[80] ^ din[81] ^ din[82] ^ din[84] ^ din[91] ^
               din[92] ^ din[93] ^ din[94] ^ din[95];

    dout[30] = din[64] ^ din[65] ^ din[66] ^ din[70] ^ din[71] ^ din[77] ^
               din[79] ^ din[80] ^ din[81] ^ din[82] ^ din[83] ^ din[85] ^
               din[92] ^ din[93] ^ din[94] ^ din[95];

    dout[31] = din[64] ^ din[65] ^ din[66] ^ din[67] ^ din[71] ^ din[72] ^
               din[78] ^ din[80] ^ din[81] ^ din[82] ^ din[83] ^ din[84] ^
               din[86] ^ din[93] ^ din[94] ^ din[95];

    fcs_next_d_511_0_part_3_of_16 = dout;

  end

  /* TOTAL XOR GATES: 1344 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_4_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[96] ^ din[97] ^ din[98] ^ din[99] ^ din[101] ^ din[103] ^
              din[104] ^ din[106] ^ din[110] ^ din[111] ^ din[113] ^ din[114] ^
              din[116] ^ din[117] ^ din[118] ^ din[119] ^ din[123] ^ din[125] ^
              din[126] ^ din[127];

    dout[1] = din[100] ^ din[101] ^ din[102] ^ din[103] ^ din[105] ^ din[106] ^
              din[107] ^ din[110] ^ din[112] ^ din[113] ^ din[115] ^ din[116] ^
              din[120] ^ din[123] ^ din[124] ^ din[125];

    dout[2] = din[96] ^ din[97] ^ din[98] ^ din[99] ^ din[102] ^ din[107] ^
              din[108] ^ din[110] ^ din[118] ^ din[119] ^ din[121] ^ din[123] ^
              din[124] ^ din[127];

    dout[3] = din[97] ^ din[98] ^ din[99] ^ din[100] ^ din[103] ^ din[108] ^
              din[109] ^ din[111] ^ din[119] ^ din[120] ^ din[122] ^ din[124] ^
              din[125];

    dout[4] = din[97] ^ din[100] ^ din[103] ^ din[106] ^ din[109] ^ din[111] ^
              din[112] ^ din[113] ^ din[114] ^ din[116] ^ din[117] ^ din[118] ^
              din[119] ^ din[120] ^ din[121] ^ din[127];

    dout[5] = din[97] ^ din[99] ^ din[103] ^ din[106] ^ din[107] ^ din[111] ^
              din[112] ^ din[115] ^ din[116] ^ din[120] ^ din[121] ^ din[122] ^
              din[123] ^ din[125] ^ din[126] ^ din[127];

    dout[6] = din[98] ^ din[100] ^ din[104] ^ din[107] ^ din[108] ^ din[112] ^
              din[113] ^ din[116] ^ din[117] ^ din[121] ^ din[122] ^ din[123] ^
              din[124] ^ din[126] ^ din[127];

    dout[7] = din[97] ^ din[98] ^ din[103] ^ din[104] ^ din[105] ^ din[106] ^
              din[108] ^ din[109] ^ din[110] ^ din[111] ^ din[116] ^ din[119] ^
              din[122] ^ din[124] ^ din[126];

    dout[8] = din[97] ^ din[101] ^ din[103] ^ din[105] ^ din[107] ^ din[109] ^
              din[112] ^ din[113] ^ din[114] ^ din[116] ^ din[118] ^ din[119] ^
              din[120] ^ din[126];

    dout[9] = din[96] ^ din[98] ^ din[102] ^ din[104] ^ din[106] ^ din[108] ^
              din[110] ^ din[113] ^ din[114] ^ din[115] ^ din[117] ^ din[119] ^
              din[120] ^ din[121] ^ din[127];

    dout[10] = din[96] ^ din[98] ^ din[101] ^ din[104] ^ din[105] ^ din[106] ^
               din[107] ^ din[109] ^ din[110] ^ din[113] ^ din[115] ^ din[117] ^
               din[119] ^ din[120] ^ din[121] ^ din[122] ^ din[123] ^ din[125] ^
               din[126] ^ din[127];

    dout[11] = din[98] ^ din[101] ^ din[102] ^ din[103] ^ din[104] ^ din[105] ^
               din[107] ^ din[108] ^ din[113] ^ din[117] ^ din[119] ^ din[120] ^
               din[121] ^ din[122] ^ din[124] ^ din[125];

    dout[12] = din[96] ^ din[97] ^ din[98] ^ din[101] ^ din[102] ^ din[105] ^
               din[108] ^ din[109] ^ din[110] ^ din[111] ^ din[113] ^ din[116] ^
               din[117] ^ din[119] ^ din[120] ^ din[121] ^ din[122] ^ din[127];

    dout[13] = din[97] ^ din[98] ^ din[99] ^ din[102] ^ din[103] ^ din[106] ^
               din[109] ^ din[110] ^ din[111] ^ din[112] ^ din[114] ^ din[117] ^
               din[118] ^ din[120] ^ din[121] ^ din[122] ^ din[123];

    dout[14] = din[96] ^ din[98] ^ din[99] ^ din[100] ^ din[103] ^ din[104] ^
               din[107] ^ din[110] ^ din[111] ^ din[112] ^ din[113] ^ din[115] ^
               din[118] ^ din[119] ^ din[121] ^ din[122] ^ din[123] ^ din[124];

    dout[15] = din[97] ^ din[99] ^ din[100] ^ din[101] ^ din[104] ^ din[105] ^
               din[108] ^ din[111] ^ din[112] ^ din[113] ^ din[114] ^ din[116] ^
               din[119] ^ din[120] ^ din[122] ^ din[123] ^ din[124] ^ din[125];

    dout[16] = din[97] ^ din[99] ^ din[100] ^ din[102] ^ din[103] ^ din[104] ^
               din[105] ^ din[109] ^ din[110] ^ din[111] ^ din[112] ^ din[115] ^
               din[116] ^ din[118] ^ din[119] ^ din[120] ^ din[121] ^ din[124] ^
               din[127];

    dout[17] = din[98] ^ din[100] ^ din[101] ^ din[103] ^ din[104] ^ din[105] ^
               din[106] ^ din[110] ^ din[111] ^ din[112] ^ din[113] ^ din[116] ^
               din[117] ^ din[119] ^ din[120] ^ din[121] ^ din[122] ^ din[125];

    dout[18] = din[96] ^ din[99] ^ din[101] ^ din[102] ^ din[104] ^ din[105] ^
               din[106] ^ din[107] ^ din[111] ^ din[112] ^ din[113] ^ din[114] ^
               din[117] ^ din[118] ^ din[120] ^ din[121] ^ din[122] ^ din[123] ^
               din[126];

    dout[19] = din[97] ^ din[100] ^ din[102] ^ din[103] ^ din[105] ^ din[106] ^
               din[107] ^ din[108] ^ din[112] ^ din[113] ^ din[114] ^ din[115] ^
               din[118] ^ din[119] ^ din[121] ^ din[122] ^ din[123] ^ din[124] ^
               din[127];

    dout[20] = din[98] ^ din[101] ^ din[103] ^ din[104] ^ din[106] ^ din[107] ^
               din[108] ^ din[109] ^ din[113] ^ din[114] ^ din[115] ^ din[116] ^
               din[119] ^ din[120] ^ din[122] ^ din[123] ^ din[124] ^ din[125];

    dout[21] = din[96] ^ din[99] ^ din[102] ^ din[104] ^ din[105] ^ din[107] ^
               din[108] ^ din[109] ^ din[110] ^ din[114] ^ din[115] ^ din[116] ^
               din[117] ^ din[120] ^ din[121] ^ din[123] ^ din[124] ^ din[125] ^
               din[126];

    dout[22] = din[98] ^ din[99] ^ din[100] ^ din[101] ^ din[104] ^ din[105] ^
               din[108] ^ din[109] ^ din[113] ^ din[114] ^ din[115] ^ din[119] ^
               din[121] ^ din[122] ^ din[123] ^ din[124];

    dout[23] = din[96] ^ din[97] ^ din[98] ^ din[100] ^ din[102] ^ din[103] ^
               din[104] ^ din[105] ^ din[109] ^ din[111] ^ din[113] ^ din[115] ^
               din[117] ^ din[118] ^ din[119] ^ din[120] ^ din[122] ^ din[124] ^
               din[126] ^ din[127];

    dout[24] = din[97] ^ din[98] ^ din[99] ^ din[101] ^ din[103] ^ din[104] ^
               din[105] ^ din[106] ^ din[110] ^ din[112] ^ din[114] ^ din[116] ^
               din[118] ^ din[119] ^ din[120] ^ din[121] ^ din[123] ^ din[125] ^
               din[127];

    dout[25] = din[98] ^ din[99] ^ din[100] ^ din[102] ^ din[104] ^ din[105] ^
               din[106] ^ din[107] ^ din[111] ^ din[113] ^ din[115] ^ din[117] ^
               din[119] ^ din[120] ^ din[121] ^ din[122] ^ din[124] ^ din[126];

    dout[26] = din[97] ^ din[98] ^ din[100] ^ din[104] ^ din[105] ^ din[107] ^
               din[108] ^ din[110] ^ din[111] ^ din[112] ^ din[113] ^ din[117] ^
               din[119] ^ din[120] ^ din[121] ^ din[122] ^ din[126];

    dout[27] = din[96] ^ din[98] ^ din[99] ^ din[101] ^ din[105] ^ din[106] ^
               din[108] ^ din[109] ^ din[111] ^ din[112] ^ din[113] ^ din[114] ^
               din[118] ^ din[120] ^ din[121] ^ din[122] ^ din[123] ^ din[127];

    dout[28] = din[97] ^ din[99] ^ din[100] ^ din[102] ^ din[106] ^ din[107] ^
               din[109] ^ din[110] ^ din[112] ^ din[113] ^ din[114] ^ din[115] ^
               din[119] ^ din[121] ^ din[122] ^ din[123] ^ din[124];

    dout[29] = din[96] ^ din[98] ^ din[100] ^ din[101] ^ din[103] ^ din[107] ^
               din[108] ^ din[110] ^ din[111] ^ din[113] ^ din[114] ^ din[115] ^
               din[116] ^ din[120] ^ din[122] ^ din[123] ^ din[124] ^ din[125];

    dout[30] = din[96] ^ din[97] ^ din[99] ^ din[101] ^ din[102] ^ din[104] ^
               din[108] ^ din[109] ^ din[111] ^ din[112] ^ din[114] ^ din[115] ^
               din[116] ^ din[117] ^ din[121] ^ din[123] ^ din[124] ^ din[125] ^
               din[126];

    dout[31] = din[96] ^ din[97] ^ din[98] ^ din[100] ^ din[102] ^ din[103] ^
               din[105] ^ din[109] ^ din[110] ^ din[112] ^ din[113] ^ din[115] ^
               din[116] ^ din[117] ^ din[118] ^ din[122] ^ din[124] ^ din[125] ^
               din[126] ^ din[127];

    fcs_next_d_511_0_part_4_of_16 = dout;

  end

  /* TOTAL XOR GATES: 1867 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_5_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[128] ^ din[132] ^ din[134] ^ din[135] ^ din[136] ^ din[137] ^
              din[143] ^ din[144] ^ din[149] ^ din[151] ^ din[155] ^ din[156] ^
              din[158];

    dout[1] = din[129] ^ din[132] ^ din[133] ^ din[134] ^ din[138] ^ din[143] ^
              din[145] ^ din[149] ^ din[150] ^ din[151] ^ din[152] ^ din[155] ^
              din[157] ^ din[158] ^ din[159];

    dout[2] = din[128] ^ din[130] ^ din[132] ^ din[133] ^ din[136] ^ din[137] ^
              din[139] ^ din[143] ^ din[146] ^ din[149] ^ din[150] ^ din[152] ^
              din[153] ^ din[155] ^ din[159];

    dout[3] = din[128] ^ din[129] ^ din[131] ^ din[133] ^ din[134] ^ din[137] ^
              din[138] ^ din[140] ^ din[144] ^ din[147] ^ din[150] ^ din[151] ^
              din[153] ^ din[154] ^ din[156];

    dout[4] = din[128] ^ din[129] ^ din[130] ^ din[136] ^ din[137] ^ din[138] ^
              din[139] ^ din[141] ^ din[143] ^ din[144] ^ din[145] ^ din[148] ^
              din[149] ^ din[152] ^ din[154] ^ din[156] ^ din[157] ^ din[158];

    dout[5] = din[129] ^ din[130] ^ din[131] ^ din[132] ^ din[134] ^ din[135] ^
              din[136] ^ din[138] ^ din[139] ^ din[140] ^ din[142] ^ din[143] ^
              din[145] ^ din[146] ^ din[150] ^ din[151] ^ din[153] ^ din[156] ^
              din[157] ^ din[159];

    dout[6] = din[128] ^ din[130] ^ din[131] ^ din[132] ^ din[133] ^ din[135] ^
              din[136] ^ din[137] ^ din[139] ^ din[140] ^ din[141] ^ din[143] ^
              din[144] ^ din[146] ^ din[147] ^ din[151] ^ din[152] ^ din[154] ^
              din[157] ^ din[158];

    dout[7] = din[129] ^ din[131] ^ din[133] ^ din[135] ^ din[138] ^ din[140] ^
              din[141] ^ din[142] ^ din[143] ^ din[145] ^ din[147] ^ din[148] ^
              din[149] ^ din[151] ^ din[152] ^ din[153] ^ din[156] ^ din[159];

    dout[8] = din[128] ^ din[130] ^ din[135] ^ din[137] ^ din[139] ^ din[141] ^
              din[142] ^ din[146] ^ din[148] ^ din[150] ^ din[151] ^ din[152] ^
              din[153] ^ din[154] ^ din[155] ^ din[156] ^ din[157] ^ din[158];

    dout[9] = din[129] ^ din[131] ^ din[136] ^ din[138] ^ din[140] ^ din[142] ^
              din[143] ^ din[147] ^ din[149] ^ din[151] ^ din[152] ^ din[153] ^
              din[154] ^ din[155] ^ din[156] ^ din[157] ^ din[158] ^ din[159];

    dout[10] = din[130] ^ din[134] ^ din[135] ^ din[136] ^ din[139] ^ din[141] ^
               din[148] ^ din[149] ^ din[150] ^ din[151] ^ din[152] ^ din[153] ^
               din[154] ^ din[157] ^ din[159];

    dout[11] = din[131] ^ din[132] ^ din[134] ^ din[140] ^ din[142] ^ din[143] ^
               din[144] ^ din[150] ^ din[152] ^ din[153] ^ din[154] ^ din[156];

    dout[12] = din[128] ^ din[133] ^ din[134] ^ din[136] ^ din[137] ^ din[141] ^
               din[145] ^ din[149] ^ din[153] ^ din[154] ^ din[156] ^ din[157] ^
               din[158];

    dout[13] = din[128] ^ din[129] ^ din[134] ^ din[135] ^ din[137] ^ din[138] ^
               din[142] ^ din[146] ^ din[150] ^ din[154] ^ din[155] ^ din[157] ^
               din[158] ^ din[159];

    dout[14] = din[129] ^ din[130] ^ din[135] ^ din[136] ^ din[138] ^ din[139] ^
               din[143] ^ din[147] ^ din[151] ^ din[155] ^ din[156] ^ din[158] ^
               din[159];

    dout[15] = din[130] ^ din[131] ^ din[136] ^ din[137] ^ din[139] ^ din[140] ^
               din[144] ^ din[148] ^ din[152] ^ din[156] ^ din[157] ^ din[159];

    dout[16] = din[128] ^ din[131] ^ din[134] ^ din[135] ^ din[136] ^ din[138] ^
               din[140] ^ din[141] ^ din[143] ^ din[144] ^ din[145] ^ din[151] ^
               din[153] ^ din[155] ^ din[156] ^ din[157];

    dout[17] = din[128] ^ din[129] ^ din[132] ^ din[135] ^ din[136] ^ din[137] ^
               din[139] ^ din[141] ^ din[142] ^ din[144] ^ din[145] ^ din[146] ^
               din[152] ^ din[154] ^ din[156] ^ din[157] ^ din[158];

    dout[18] = din[129] ^ din[130] ^ din[133] ^ din[136] ^ din[137] ^ din[138] ^
               din[140] ^ din[142] ^ din[143] ^ din[145] ^ din[146] ^ din[147] ^
               din[153] ^ din[155] ^ din[157] ^ din[158] ^ din[159];

    dout[19] = din[130] ^ din[131] ^ din[134] ^ din[137] ^ din[138] ^ din[139] ^
               din[141] ^ din[143] ^ din[144] ^ din[146] ^ din[147] ^ din[148] ^
               din[154] ^ din[156] ^ din[158] ^ din[159];

    dout[20] = din[128] ^ din[131] ^ din[132] ^ din[135] ^ din[138] ^ din[139] ^
               din[140] ^ din[142] ^ din[144] ^ din[145] ^ din[147] ^ din[148] ^
               din[149] ^ din[155] ^ din[157] ^ din[159];

    dout[21] = din[129] ^ din[132] ^ din[133] ^ din[136] ^ din[139] ^ din[140] ^
               din[141] ^ din[143] ^ din[145] ^ din[146] ^ din[148] ^ din[149] ^
               din[150] ^ din[156] ^ din[158];

    dout[22] = din[128] ^ din[130] ^ din[132] ^ din[133] ^ din[135] ^ din[136] ^
               din[140] ^ din[141] ^ din[142] ^ din[143] ^ din[146] ^ din[147] ^
               din[150] ^ din[155] ^ din[156] ^ din[157] ^ din[158] ^ din[159];

    dout[23] = din[128] ^ din[129] ^ din[131] ^ din[132] ^ din[133] ^ din[135] ^
               din[141] ^ din[142] ^ din[147] ^ din[148] ^ din[149] ^ din[155] ^
               din[157] ^ din[159];

    dout[24] = din[128] ^ din[129] ^ din[130] ^ din[132] ^ din[133] ^ din[134] ^
               din[136] ^ din[142] ^ din[143] ^ din[148] ^ din[149] ^ din[150] ^
               din[156] ^ din[158];

    dout[25] = din[128] ^ din[129] ^ din[130] ^ din[131] ^ din[133] ^ din[134] ^
               din[135] ^ din[137] ^ din[143] ^ din[144] ^ din[149] ^ din[150] ^
               din[151] ^ din[157] ^ din[159];

    dout[26] = din[128] ^ din[129] ^ din[130] ^ din[131] ^ din[137] ^ din[138] ^
               din[143] ^ din[145] ^ din[149] ^ din[150] ^ din[152] ^ din[155] ^
               din[156];

    dout[27] = din[129] ^ din[130] ^ din[131] ^ din[132] ^ din[138] ^ din[139] ^
               din[144] ^ din[146] ^ din[150] ^ din[151] ^ din[153] ^ din[156] ^
               din[157];

    dout[28] = din[128] ^ din[130] ^ din[131] ^ din[132] ^ din[133] ^ din[139] ^
               din[140] ^ din[145] ^ din[147] ^ din[151] ^ din[152] ^ din[154] ^
               din[157] ^ din[158];

    dout[29] = din[129] ^ din[131] ^ din[132] ^ din[133] ^ din[134] ^ din[140] ^
               din[141] ^ din[146] ^ din[148] ^ din[152] ^ din[153] ^ din[155] ^
               din[158] ^ din[159];

    dout[30] = din[130] ^ din[132] ^ din[133] ^ din[134] ^ din[135] ^ din[141] ^
               din[142] ^ din[147] ^ din[149] ^ din[153] ^ din[154] ^ din[156] ^
               din[159];

    dout[31] = din[131] ^ din[133] ^ din[134] ^ din[135] ^ din[136] ^ din[142] ^
               din[143] ^ din[148] ^ din[150] ^ din[154] ^ din[155] ^ din[157];

    fcs_next_d_511_0_part_5_of_16 = dout;

  end

  /* TOTAL XOR GATES: 2321 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_6_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[161] ^ din[162] ^ din[166] ^ din[167] ^ din[169] ^ din[170] ^
              din[171] ^ din[172] ^ din[182] ^ din[183] ^ din[186] ^ din[188] ^
              din[190] ^ din[191];

    dout[1] = din[161] ^ din[163] ^ din[166] ^ din[168] ^ din[169] ^ din[173] ^
              din[182] ^ din[184] ^ din[186] ^ din[187] ^ din[188] ^ din[189] ^
              din[190];

    dout[2] = din[160] ^ din[161] ^ din[164] ^ din[166] ^ din[171] ^ din[172] ^
              din[174] ^ din[182] ^ din[185] ^ din[186] ^ din[187] ^ din[189];

    dout[3] = din[160] ^ din[161] ^ din[162] ^ din[165] ^ din[167] ^ din[172] ^
              din[173] ^ din[175] ^ din[183] ^ din[186] ^ din[187] ^ din[188] ^
              din[190];

    dout[4] = din[163] ^ din[167] ^ din[168] ^ din[169] ^ din[170] ^ din[171] ^
              din[172] ^ din[173] ^ din[174] ^ din[176] ^ din[182] ^ din[183] ^
              din[184] ^ din[186] ^ din[187] ^ din[189] ^ din[190];

    dout[5] = din[161] ^ din[162] ^ din[164] ^ din[166] ^ din[167] ^ din[168] ^
              din[173] ^ din[174] ^ din[175] ^ din[177] ^ din[182] ^ din[184] ^
              din[185] ^ din[186] ^ din[187];

    dout[6] = din[160] ^ din[162] ^ din[163] ^ din[165] ^ din[167] ^ din[168] ^
              din[169] ^ din[174] ^ din[175] ^ din[176] ^ din[178] ^ din[183] ^
              din[185] ^ din[186] ^ din[187] ^ din[188];

    dout[7] = din[162] ^ din[163] ^ din[164] ^ din[167] ^ din[168] ^ din[171] ^
              din[172] ^ din[175] ^ din[176] ^ din[177] ^ din[179] ^ din[182] ^
              din[183] ^ din[184] ^ din[187] ^ din[189] ^ din[190] ^ din[191];

    dout[8] = din[160] ^ din[161] ^ din[162] ^ din[163] ^ din[164] ^ din[165] ^
              din[166] ^ din[167] ^ din[168] ^ din[170] ^ din[171] ^ din[173] ^
              din[176] ^ din[177] ^ din[178] ^ din[180] ^ din[182] ^ din[184] ^
              din[185] ^ din[186];

    dout[9] = din[161] ^ din[162] ^ din[163] ^ din[164] ^ din[165] ^ din[166] ^
              din[167] ^ din[168] ^ din[169] ^ din[171] ^ din[172] ^ din[174] ^
              din[177] ^ din[178] ^ din[179] ^ din[181] ^ din[183] ^ din[185] ^
              din[186] ^ din[187];

    dout[10] = din[160] ^ din[161] ^ din[163] ^ din[164] ^ din[165] ^ din[168] ^
               din[171] ^ din[173] ^ din[175] ^ din[178] ^ din[179] ^ din[180] ^
               din[183] ^ din[184] ^ din[187] ^ din[190] ^ din[191];

    dout[11] = din[160] ^ din[164] ^ din[165] ^ din[167] ^ din[170] ^ din[171] ^
               din[174] ^ din[176] ^ din[179] ^ din[180] ^ din[181] ^ din[182] ^
               din[183] ^ din[184] ^ din[185] ^ din[186] ^ din[190];

    dout[12] = din[162] ^ din[165] ^ din[167] ^ din[168] ^ din[169] ^ din[170] ^
               din[175] ^ din[177] ^ din[180] ^ din[181] ^ din[184] ^ din[185] ^
               din[187] ^ din[188] ^ din[190];

    dout[13] = din[163] ^ din[166] ^ din[168] ^ din[169] ^ din[170] ^ din[171] ^
               din[176] ^ din[178] ^ din[181] ^ din[182] ^ din[185] ^ din[186] ^
               din[188] ^ din[189] ^ din[191];

    dout[14] = din[160] ^ din[164] ^ din[167] ^ din[169] ^ din[170] ^ din[171] ^
               din[172] ^ din[177] ^ din[179] ^ din[182] ^ din[183] ^ din[186] ^
               din[187] ^ din[189] ^ din[190];

    dout[15] = din[160] ^ din[161] ^ din[165] ^ din[168] ^ din[170] ^ din[171] ^
               din[172] ^ din[173] ^ din[178] ^ din[180] ^ din[183] ^ din[184] ^
               din[187] ^ din[188] ^ din[190] ^ din[191];

    dout[16] = din[160] ^ din[167] ^ din[170] ^ din[173] ^ din[174] ^ din[179] ^
               din[181] ^ din[182] ^ din[183] ^ din[184] ^ din[185] ^ din[186] ^
               din[189] ^ din[190];

    dout[17] = din[161] ^ din[168] ^ din[171] ^ din[174] ^ din[175] ^ din[180] ^
               din[182] ^ din[183] ^ din[184] ^ din[185] ^ din[186] ^ din[187] ^
               din[190] ^ din[191];

    dout[18] = din[162] ^ din[169] ^ din[172] ^ din[175] ^ din[176] ^ din[181] ^
               din[183] ^ din[184] ^ din[185] ^ din[186] ^ din[187] ^ din[188] ^
               din[191];

    dout[19] = din[160] ^ din[163] ^ din[170] ^ din[173] ^ din[176] ^ din[177] ^
               din[182] ^ din[184] ^ din[185] ^ din[186] ^ din[187] ^ din[188] ^
               din[189];

    dout[20] = din[160] ^ din[161] ^ din[164] ^ din[171] ^ din[174] ^ din[177] ^
               din[178] ^ din[183] ^ din[185] ^ din[186] ^ din[187] ^ din[188] ^
               din[189] ^ din[190];

    dout[21] = din[160] ^ din[161] ^ din[162] ^ din[165] ^ din[172] ^ din[175] ^
               din[178] ^ din[179] ^ din[184] ^ din[186] ^ din[187] ^ din[188] ^
               din[189] ^ din[190] ^ din[191];

    dout[22] = din[163] ^ din[167] ^ din[169] ^ din[170] ^ din[171] ^ din[172] ^
               din[173] ^ din[176] ^ din[179] ^ din[180] ^ din[182] ^ din[183] ^
               din[185] ^ din[186] ^ din[187] ^ din[189];

    dout[23] = din[160] ^ din[161] ^ din[162] ^ din[164] ^ din[166] ^ din[167] ^
               din[168] ^ din[169] ^ din[173] ^ din[174] ^ din[177] ^ din[180] ^
               din[181] ^ din[182] ^ din[184] ^ din[187] ^ din[191];

    dout[24] = din[160] ^ din[161] ^ din[162] ^ din[163] ^ din[165] ^ din[167] ^
               din[168] ^ din[169] ^ din[170] ^ din[174] ^ din[175] ^ din[178] ^
               din[181] ^ din[182] ^ din[183] ^ din[185] ^ din[188];

    dout[25] = din[161] ^ din[162] ^ din[163] ^ din[164] ^ din[166] ^ din[168] ^
               din[169] ^ din[170] ^ din[171] ^ din[175] ^ din[176] ^ din[179] ^
               din[182] ^ din[183] ^ din[184] ^ din[186] ^ din[189];

    dout[26] = din[160] ^ din[161] ^ din[163] ^ din[164] ^ din[165] ^ din[166] ^
               din[176] ^ din[177] ^ din[180] ^ din[182] ^ din[184] ^ din[185] ^
               din[186] ^ din[187] ^ din[188] ^ din[191];

    dout[27] = din[161] ^ din[162] ^ din[164] ^ din[165] ^ din[166] ^ din[167] ^
               din[177] ^ din[178] ^ din[181] ^ din[183] ^ din[185] ^ din[186] ^
               din[187] ^ din[188] ^ din[189];

    dout[28] = din[162] ^ din[163] ^ din[165] ^ din[166] ^ din[167] ^ din[168] ^
               din[178] ^ din[179] ^ din[182] ^ din[184] ^ din[186] ^ din[187] ^
               din[188] ^ din[189] ^ din[190];

    dout[29] = din[163] ^ din[164] ^ din[166] ^ din[167] ^ din[168] ^ din[169] ^
               din[179] ^ din[180] ^ din[183] ^ din[185] ^ din[187] ^ din[188] ^
               din[189] ^ din[190] ^ din[191];

    dout[30] = din[160] ^ din[164] ^ din[165] ^ din[167] ^ din[168] ^ din[169] ^
               din[170] ^ din[180] ^ din[181] ^ din[184] ^ din[186] ^ din[188] ^
               din[189] ^ din[190] ^ din[191];

    dout[31] = din[160] ^ din[161] ^ din[165] ^ din[166] ^ din[168] ^ din[169] ^
               din[170] ^ din[171] ^ din[181] ^ din[182] ^ din[185] ^ din[187] ^
               din[189] ^ din[190] ^ din[191];

    fcs_next_d_511_0_part_6_of_16 = dout;

  end

  /* TOTAL XOR GATES: 2783 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_7_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[192] ^ din[193] ^ din[194] ^ din[197] ^ din[198] ^ din[199] ^
              din[201] ^ din[202] ^ din[203] ^ din[207] ^ din[208] ^ din[209] ^
              din[210] ^ din[212] ^ din[214] ^ din[216];

    dout[1] = din[195] ^ din[197] ^ din[200] ^ din[201] ^ din[204] ^ din[207] ^
              din[211] ^ din[212] ^ din[213] ^ din[214] ^ din[215] ^ din[216] ^
              din[217];

    dout[2] = din[192] ^ din[193] ^ din[194] ^ din[196] ^ din[197] ^ din[199] ^
              din[203] ^ din[205] ^ din[207] ^ din[209] ^ din[210] ^ din[213] ^
              din[215] ^ din[217] ^ din[218];

    dout[3] = din[193] ^ din[194] ^ din[195] ^ din[197] ^ din[198] ^ din[200] ^
              din[204] ^ din[206] ^ din[208] ^ din[210] ^ din[211] ^ din[214] ^
              din[216] ^ din[218] ^ din[219];

    dout[4] = din[192] ^ din[193] ^ din[195] ^ din[196] ^ din[197] ^ din[202] ^
              din[203] ^ din[205] ^ din[208] ^ din[210] ^ din[211] ^ din[214] ^
              din[215] ^ din[216] ^ din[217] ^ din[219] ^ din[220];

    dout[5] = din[192] ^ din[196] ^ din[199] ^ din[201] ^ din[202] ^ din[204] ^
              din[206] ^ din[207] ^ din[208] ^ din[210] ^ din[211] ^ din[214] ^
              din[215] ^ din[217] ^ din[218] ^ din[220] ^ din[221];

    dout[6] = din[193] ^ din[197] ^ din[200] ^ din[202] ^ din[203] ^ din[205] ^
              din[207] ^ din[208] ^ din[209] ^ din[211] ^ din[212] ^ din[215] ^
              din[216] ^ din[218] ^ din[219] ^ din[221] ^ din[222];

    dout[7] = din[192] ^ din[193] ^ din[197] ^ din[199] ^ din[202] ^ din[204] ^
              din[206] ^ din[207] ^ din[213] ^ din[214] ^ din[217] ^ din[219] ^
              din[220] ^ din[222] ^ din[223];

    dout[8] = din[197] ^ din[199] ^ din[200] ^ din[201] ^ din[202] ^ din[205] ^
              din[209] ^ din[210] ^ din[212] ^ din[215] ^ din[216] ^ din[218] ^
              din[220] ^ din[221] ^ din[223];

    dout[9] = din[198] ^ din[200] ^ din[201] ^ din[202] ^ din[203] ^ din[206] ^
              din[210] ^ din[211] ^ din[213] ^ din[216] ^ din[217] ^ din[219] ^
              din[221] ^ din[222];

    dout[10] = din[192] ^ din[193] ^ din[194] ^ din[197] ^ din[198] ^ din[204] ^
               din[208] ^ din[209] ^ din[210] ^ din[211] ^ din[216] ^ din[217] ^
               din[218] ^ din[220] ^ din[222] ^ din[223];

    dout[11] = din[195] ^ din[197] ^ din[201] ^ din[202] ^ din[203] ^ din[205] ^
               din[207] ^ din[208] ^ din[211] ^ din[214] ^ din[216] ^ din[217] ^
               din[218] ^ din[219] ^ din[221] ^ din[223];

    dout[12] = din[192] ^ din[193] ^ din[194] ^ din[196] ^ din[197] ^ din[199] ^
               din[201] ^ din[204] ^ din[206] ^ din[207] ^ din[210] ^ din[214] ^
               din[215] ^ din[216] ^ din[217] ^ din[218] ^ din[219] ^ din[220] ^
               din[222];

    dout[13] = din[193] ^ din[194] ^ din[195] ^ din[197] ^ din[198] ^ din[200] ^
               din[202] ^ din[205] ^ din[207] ^ din[208] ^ din[211] ^ din[215] ^
               din[216] ^ din[217] ^ din[218] ^ din[219] ^ din[220] ^ din[221] ^
               din[223];

    dout[14] = din[192] ^ din[194] ^ din[195] ^ din[196] ^ din[198] ^ din[199] ^
               din[201] ^ din[203] ^ din[206] ^ din[208] ^ din[209] ^ din[212] ^
               din[216] ^ din[217] ^ din[218] ^ din[219] ^ din[220] ^ din[221] ^
               din[222];

    dout[15] = din[193] ^ din[195] ^ din[196] ^ din[197] ^ din[199] ^ din[200] ^
               din[202] ^ din[204] ^ din[207] ^ din[209] ^ din[210] ^ din[213] ^
               din[217] ^ din[218] ^ din[219] ^ din[220] ^ din[221] ^ din[222] ^
               din[223];

    dout[16] = din[193] ^ din[196] ^ din[199] ^ din[200] ^ din[202] ^ din[205] ^
               din[207] ^ din[209] ^ din[211] ^ din[212] ^ din[216] ^ din[218] ^
               din[219] ^ din[220] ^ din[221] ^ din[222] ^ din[223];

    dout[17] = din[194] ^ din[197] ^ din[200] ^ din[201] ^ din[203] ^ din[206] ^
               din[208] ^ din[210] ^ din[212] ^ din[213] ^ din[217] ^ din[219] ^
               din[220] ^ din[221] ^ din[222] ^ din[223];

    dout[18] = din[192] ^ din[195] ^ din[198] ^ din[201] ^ din[202] ^ din[204] ^
               din[207] ^ din[209] ^ din[211] ^ din[213] ^ din[214] ^ din[218] ^
               din[220] ^ din[221] ^ din[222] ^ din[223];

    dout[19] = din[192] ^ din[193] ^ din[196] ^ din[199] ^ din[202] ^ din[203] ^
               din[205] ^ din[208] ^ din[210] ^ din[212] ^ din[214] ^ din[215] ^
               din[219] ^ din[221] ^ din[222] ^ din[223];

    dout[20] = din[193] ^ din[194] ^ din[197] ^ din[200] ^ din[203] ^ din[204] ^
               din[206] ^ din[209] ^ din[211] ^ din[213] ^ din[215] ^ din[216] ^
               din[220] ^ din[222] ^ din[223];

    dout[21] = din[194] ^ din[195] ^ din[198] ^ din[201] ^ din[204] ^ din[205] ^
               din[207] ^ din[210] ^ din[212] ^ din[214] ^ din[216] ^ din[217] ^
               din[221] ^ din[223];

    dout[22] = din[193] ^ din[194] ^ din[195] ^ din[196] ^ din[197] ^ din[198] ^
               din[201] ^ din[203] ^ din[205] ^ din[206] ^ din[207] ^ din[209] ^
               din[210] ^ din[211] ^ din[212] ^ din[213] ^ din[214] ^ din[215] ^
               din[216] ^ din[217] ^ din[218] ^ din[222];

    dout[23] = din[192] ^ din[193] ^ din[195] ^ din[196] ^ din[201] ^ din[203] ^
               din[204] ^ din[206] ^ din[209] ^ din[211] ^ din[213] ^ din[215] ^
               din[217] ^ din[218] ^ din[219] ^ din[223];

    dout[24] = din[192] ^ din[193] ^ din[194] ^ din[196] ^ din[197] ^ din[202] ^
               din[204] ^ din[205] ^ din[207] ^ din[210] ^ din[212] ^ din[214] ^
               din[216] ^ din[218] ^ din[219] ^ din[220];

    dout[25] = din[193] ^ din[194] ^ din[195] ^ din[197] ^ din[198] ^ din[203] ^
               din[205] ^ din[206] ^ din[208] ^ din[211] ^ din[213] ^ din[215] ^
               din[217] ^ din[219] ^ din[220] ^ din[221];

    dout[26] = din[192] ^ din[193] ^ din[195] ^ din[196] ^ din[197] ^ din[201] ^
               din[202] ^ din[203] ^ din[204] ^ din[206] ^ din[208] ^ din[210] ^
               din[218] ^ din[220] ^ din[221] ^ din[222];

    dout[27] = din[192] ^ din[193] ^ din[194] ^ din[196] ^ din[197] ^ din[198] ^
               din[202] ^ din[203] ^ din[204] ^ din[205] ^ din[207] ^ din[209] ^
               din[211] ^ din[219] ^ din[221] ^ din[222] ^ din[223];

    dout[28] = din[193] ^ din[194] ^ din[195] ^ din[197] ^ din[198] ^ din[199] ^
               din[203] ^ din[204] ^ din[205] ^ din[206] ^ din[208] ^ din[210] ^
               din[212] ^ din[220] ^ din[222] ^ din[223];

    dout[29] = din[194] ^ din[195] ^ din[196] ^ din[198] ^ din[199] ^ din[200] ^
               din[204] ^ din[205] ^ din[206] ^ din[207] ^ din[209] ^ din[211] ^
               din[213] ^ din[221] ^ din[223];

    dout[30] = din[192] ^ din[195] ^ din[196] ^ din[197] ^ din[199] ^ din[200] ^
               din[201] ^ din[205] ^ din[206] ^ din[207] ^ din[208] ^ din[210] ^
               din[212] ^ din[214] ^ din[222];

    dout[31] = din[192] ^ din[193] ^ din[196] ^ din[197] ^ din[198] ^ din[200] ^
               din[201] ^ din[202] ^ din[206] ^ din[207] ^ din[208] ^ din[209] ^
               din[211] ^ din[213] ^ din[215] ^ din[223];

    fcs_next_d_511_0_part_7_of_16 = dout;

  end

  /* TOTAL XOR GATES: 3272 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_8_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[224] ^ din[226] ^ din[227] ^ din[228] ^ din[230] ^ din[234] ^
              din[237] ^ din[243] ^ din[248] ^ din[252] ^ din[255];

    dout[1] = din[224] ^ din[225] ^ din[226] ^ din[229] ^ din[230] ^ din[231] ^
              din[234] ^ din[235] ^ din[237] ^ din[238] ^ din[243] ^ din[244] ^
              din[248] ^ din[249] ^ din[252] ^ din[253] ^ din[255];

    dout[2] = din[224] ^ din[225] ^ din[228] ^ din[231] ^ din[232] ^ din[234] ^
              din[235] ^ din[236] ^ din[237] ^ din[238] ^ din[239] ^ din[243] ^
              din[244] ^ din[245] ^ din[248] ^ din[249] ^ din[250] ^ din[252] ^
              din[253] ^ din[254] ^ din[255];

    dout[3] = din[225] ^ din[226] ^ din[229] ^ din[232] ^ din[233] ^ din[235] ^
              din[236] ^ din[237] ^ din[238] ^ din[239] ^ din[240] ^ din[244] ^
              din[245] ^ din[246] ^ din[249] ^ din[250] ^ din[251] ^ din[253] ^
              din[254] ^ din[255];

    dout[4] = din[224] ^ din[228] ^ din[233] ^ din[236] ^ din[238] ^ din[239] ^
              din[240] ^ din[241] ^ din[243] ^ din[245] ^ din[246] ^ din[247] ^
              din[248] ^ din[250] ^ din[251] ^ din[254];

    dout[5] = din[224] ^ din[225] ^ din[226] ^ din[227] ^ din[228] ^ din[229] ^
              din[230] ^ din[239] ^ din[240] ^ din[241] ^ din[242] ^ din[243] ^
              din[244] ^ din[246] ^ din[247] ^ din[249] ^ din[251];

    dout[6] = din[225] ^ din[226] ^ din[227] ^ din[228] ^ din[229] ^ din[230] ^
              din[231] ^ din[240] ^ din[241] ^ din[242] ^ din[243] ^ din[244] ^
              din[245] ^ din[247] ^ din[248] ^ din[250] ^ din[252];

    dout[7] = din[224] ^ din[229] ^ din[231] ^ din[232] ^ din[234] ^ din[237] ^
              din[241] ^ din[242] ^ din[244] ^ din[245] ^ din[246] ^ din[249] ^
              din[251] ^ din[252] ^ din[253] ^ din[255];

    dout[8] = din[225] ^ din[226] ^ din[227] ^ din[228] ^ din[232] ^ din[233] ^
              din[234] ^ din[235] ^ din[237] ^ din[238] ^ din[242] ^ din[245] ^
              din[246] ^ din[247] ^ din[248] ^ din[250] ^ din[253] ^ din[254] ^
              din[255];

    dout[9] = din[224] ^ din[226] ^ din[227] ^ din[228] ^ din[229] ^ din[233] ^
              din[234] ^ din[235] ^ din[236] ^ din[238] ^ din[239] ^ din[243] ^
              din[246] ^ din[247] ^ din[248] ^ din[249] ^ din[251] ^ din[254] ^
              din[255];

    dout[10] = din[224] ^ din[225] ^ din[226] ^ din[229] ^ din[235] ^ din[236] ^
               din[239] ^ din[240] ^ din[243] ^ din[244] ^ din[247] ^ din[249] ^
               din[250];

    dout[11] = din[225] ^ din[228] ^ din[234] ^ din[236] ^ din[240] ^ din[241] ^
               din[243] ^ din[244] ^ din[245] ^ din[250] ^ din[251] ^ din[252] ^
               din[255];

    dout[12] = din[227] ^ din[228] ^ din[229] ^ din[230] ^ din[234] ^ din[235] ^
               din[241] ^ din[242] ^ din[243] ^ din[244] ^ din[245] ^ din[246] ^
               din[248] ^ din[251] ^ din[253] ^ din[255];

    dout[13] = din[228] ^ din[229] ^ din[230] ^ din[231] ^ din[235] ^ din[236] ^
               din[242] ^ din[243] ^ din[244] ^ din[245] ^ din[246] ^ din[247] ^
               din[249] ^ din[252] ^ din[254];

    dout[14] = din[224] ^ din[229] ^ din[230] ^ din[231] ^ din[232] ^ din[236] ^
               din[237] ^ din[243] ^ din[244] ^ din[245] ^ din[246] ^ din[247] ^
               din[248] ^ din[250] ^ din[253] ^ din[255];

    dout[15] = din[225] ^ din[230] ^ din[231] ^ din[232] ^ din[233] ^ din[237] ^
               din[238] ^ din[244] ^ din[245] ^ din[246] ^ din[247] ^ din[248] ^
               din[249] ^ din[251] ^ din[254];

    dout[16] = din[227] ^ din[228] ^ din[230] ^ din[231] ^ din[232] ^ din[233] ^
               din[237] ^ din[238] ^ din[239] ^ din[243] ^ din[245] ^ din[246] ^
               din[247] ^ din[249] ^ din[250];

    dout[17] = din[224] ^ din[228] ^ din[229] ^ din[231] ^ din[232] ^ din[233] ^
               din[234] ^ din[238] ^ din[239] ^ din[240] ^ din[244] ^ din[246] ^
               din[247] ^ din[248] ^ din[250] ^ din[251];

    dout[18] = din[224] ^ din[225] ^ din[229] ^ din[230] ^ din[232] ^ din[233] ^
               din[234] ^ din[235] ^ din[239] ^ din[240] ^ din[241] ^ din[245] ^
               din[247] ^ din[248] ^ din[249] ^ din[251] ^ din[252];

    dout[19] = din[224] ^ din[225] ^ din[226] ^ din[230] ^ din[231] ^ din[233] ^
               din[234] ^ din[235] ^ din[236] ^ din[240] ^ din[241] ^ din[242] ^
               din[246] ^ din[248] ^ din[249] ^ din[250] ^ din[252] ^ din[253];

    dout[20] = din[224] ^ din[225] ^ din[226] ^ din[227] ^ din[231] ^ din[232] ^
               din[234] ^ din[235] ^ din[236] ^ din[237] ^ din[241] ^ din[242] ^
               din[243] ^ din[247] ^ din[249] ^ din[250] ^ din[251] ^ din[253] ^
               din[254];

    dout[21] = din[224] ^ din[225] ^ din[226] ^ din[227] ^ din[228] ^ din[232] ^
               din[233] ^ din[235] ^ din[236] ^ din[237] ^ din[238] ^ din[242] ^
               din[243] ^ din[244] ^ din[248] ^ din[250] ^ din[251] ^ din[252] ^
               din[254] ^ din[255];

    dout[22] = din[225] ^ din[229] ^ din[230] ^ din[233] ^ din[236] ^ din[238] ^
               din[239] ^ din[244] ^ din[245] ^ din[248] ^ din[249] ^ din[251] ^
               din[253];

    dout[23] = din[224] ^ din[227] ^ din[228] ^ din[231] ^ din[239] ^ din[240] ^
               din[243] ^ din[245] ^ din[246] ^ din[248] ^ din[249] ^ din[250] ^
               din[254] ^ din[255];

    dout[24] = din[224] ^ din[225] ^ din[228] ^ din[229] ^ din[232] ^ din[240] ^
               din[241] ^ din[244] ^ din[246] ^ din[247] ^ din[249] ^ din[250] ^
               din[251] ^ din[255];

    dout[25] = din[225] ^ din[226] ^ din[229] ^ din[230] ^ din[233] ^ din[241] ^
               din[242] ^ din[245] ^ din[247] ^ din[248] ^ din[250] ^ din[251] ^
               din[252];

    dout[26] = din[224] ^ din[228] ^ din[231] ^ din[237] ^ din[242] ^ din[246] ^
               din[249] ^ din[251] ^ din[253] ^ din[255];

    dout[27] = din[225] ^ din[229] ^ din[232] ^ din[238] ^ din[243] ^ din[247] ^
               din[250] ^ din[252] ^ din[254];

    dout[28] = din[224] ^ din[226] ^ din[230] ^ din[233] ^ din[239] ^ din[244] ^
               din[248] ^ din[251] ^ din[253] ^ din[255];

    dout[29] = din[224] ^ din[225] ^ din[227] ^ din[231] ^ din[234] ^ din[240] ^
               din[245] ^ din[249] ^ din[252] ^ din[254];

    dout[30] = din[224] ^ din[225] ^ din[226] ^ din[228] ^ din[232] ^ din[235] ^
               din[241] ^ din[246] ^ din[250] ^ din[253] ^ din[255];

    dout[31] = din[225] ^ din[226] ^ din[227] ^ din[229] ^ din[233] ^ din[236] ^
               din[242] ^ din[247] ^ din[251] ^ din[254];

    fcs_next_d_511_0_part_8_of_16 = dout;

  end

  /* TOTAL XOR GATES: 3720 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_9_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[257] ^ din[259] ^ din[261] ^ din[264] ^ din[265] ^ din[268] ^
              din[269] ^ din[273] ^ din[274] ^ din[276] ^ din[277] ^ din[279] ^
              din[283] ^ din[286] ^ din[287];

    dout[1] = din[256] ^ din[257] ^ din[258] ^ din[259] ^ din[260] ^ din[261] ^
              din[262] ^ din[264] ^ din[266] ^ din[268] ^ din[270] ^ din[273] ^
              din[275] ^ din[276] ^ din[278] ^ din[279] ^ din[280] ^ din[283] ^
              din[284] ^ din[286];

    dout[2] = din[256] ^ din[258] ^ din[260] ^ din[262] ^ din[263] ^ din[264] ^
              din[267] ^ din[268] ^ din[271] ^ din[273] ^ din[280] ^ din[281] ^
              din[283] ^ din[284] ^ din[285] ^ din[286];

    dout[3] = din[256] ^ din[257] ^ din[259] ^ din[261] ^ din[263] ^ din[264] ^
              din[265] ^ din[268] ^ din[269] ^ din[272] ^ din[274] ^ din[281] ^
              din[282] ^ din[284] ^ din[285] ^ din[286] ^ din[287];

    dout[4] = din[256] ^ din[258] ^ din[259] ^ din[260] ^ din[261] ^ din[262] ^
              din[266] ^ din[268] ^ din[270] ^ din[274] ^ din[275] ^ din[276] ^
              din[277] ^ din[279] ^ din[282] ^ din[285];

    dout[5] = din[260] ^ din[262] ^ din[263] ^ din[264] ^ din[265] ^ din[267] ^
              din[268] ^ din[271] ^ din[273] ^ din[274] ^ din[275] ^ din[278] ^
              din[279] ^ din[280] ^ din[287];

    dout[6] = din[261] ^ din[263] ^ din[264] ^ din[265] ^ din[266] ^ din[268] ^
              din[269] ^ din[272] ^ din[274] ^ din[275] ^ din[276] ^ din[279] ^
              din[280] ^ din[281];

    dout[7] = din[257] ^ din[259] ^ din[261] ^ din[262] ^ din[266] ^ din[267] ^
              din[268] ^ din[270] ^ din[274] ^ din[275] ^ din[279] ^ din[280] ^
              din[281] ^ din[282] ^ din[283] ^ din[286] ^ din[287];

    dout[8] = din[256] ^ din[257] ^ din[258] ^ din[259] ^ din[260] ^ din[261] ^
              din[262] ^ din[263] ^ din[264] ^ din[265] ^ din[267] ^ din[271] ^
              din[273] ^ din[274] ^ din[275] ^ din[277] ^ din[279] ^ din[280] ^
              din[281] ^ din[282] ^ din[284] ^ din[286];

    dout[9] = din[256] ^ din[257] ^ din[258] ^ din[259] ^ din[260] ^ din[261] ^
              din[262] ^ din[263] ^ din[264] ^ din[265] ^ din[266] ^ din[268] ^
              din[272] ^ din[274] ^ din[275] ^ din[276] ^ din[278] ^ din[280] ^
              din[281] ^ din[282] ^ din[283] ^ din[285] ^ din[287];

    dout[10] = din[256] ^ din[258] ^ din[260] ^ din[262] ^ din[263] ^ din[266] ^
               din[267] ^ din[268] ^ din[274] ^ din[275] ^ din[281] ^ din[282] ^
               din[284] ^ din[287];

    dout[11] = din[263] ^ din[265] ^ din[267] ^ din[273] ^ din[274] ^ din[275] ^
               din[277] ^ din[279] ^ din[282] ^ din[285] ^ din[286] ^ din[287];

    dout[12] = din[256] ^ din[257] ^ din[259] ^ din[261] ^ din[265] ^ din[266] ^
               din[269] ^ din[273] ^ din[275] ^ din[277] ^ din[278] ^ din[279] ^
               din[280];

    dout[13] = din[256] ^ din[257] ^ din[258] ^ din[260] ^ din[262] ^ din[266] ^
               din[267] ^ din[270] ^ din[274] ^ din[276] ^ din[278] ^ din[279] ^
               din[280] ^ din[281];

    dout[14] = din[257] ^ din[258] ^ din[259] ^ din[261] ^ din[263] ^ din[267] ^
               din[268] ^ din[271] ^ din[275] ^ din[277] ^ din[279] ^ din[280] ^
               din[281] ^ din[282];

    dout[15] = din[256] ^ din[258] ^ din[259] ^ din[260] ^ din[262] ^ din[264] ^
               din[268] ^ din[269] ^ din[272] ^ din[276] ^ din[278] ^ din[280] ^
               din[281] ^ din[282] ^ din[283];

    dout[16] = din[260] ^ din[263] ^ din[264] ^ din[268] ^ din[270] ^ din[274] ^
               din[276] ^ din[281] ^ din[282] ^ din[284] ^ din[286] ^ din[287];

    dout[17] = din[261] ^ din[264] ^ din[265] ^ din[269] ^ din[271] ^ din[275] ^
               din[277] ^ din[282] ^ din[283] ^ din[285] ^ din[287];

    dout[18] = din[262] ^ din[265] ^ din[266] ^ din[270] ^ din[272] ^ din[276] ^
               din[278] ^ din[283] ^ din[284] ^ din[286];

    dout[19] = din[263] ^ din[266] ^ din[267] ^ din[271] ^ din[273] ^ din[277] ^
               din[279] ^ din[284] ^ din[285] ^ din[287];

    dout[20] = din[264] ^ din[267] ^ din[268] ^ din[272] ^ din[274] ^ din[278] ^
               din[280] ^ din[285] ^ din[286];

    dout[21] = din[265] ^ din[268] ^ din[269] ^ din[273] ^ din[275] ^ din[279] ^
               din[281] ^ din[286] ^ din[287];

    dout[22] = din[256] ^ din[257] ^ din[259] ^ din[261] ^ din[264] ^ din[265] ^
               din[266] ^ din[268] ^ din[270] ^ din[273] ^ din[277] ^ din[279] ^
               din[280] ^ din[282] ^ din[283] ^ din[286];

    dout[23] = din[258] ^ din[259] ^ din[260] ^ din[261] ^ din[262] ^ din[264] ^
               din[266] ^ din[267] ^ din[268] ^ din[271] ^ din[273] ^ din[276] ^
               din[277] ^ din[278] ^ din[279] ^ din[280] ^ din[281] ^ din[284] ^
               din[286];

    dout[24] = din[256] ^ din[259] ^ din[260] ^ din[261] ^ din[262] ^ din[263] ^
               din[265] ^ din[267] ^ din[268] ^ din[269] ^ din[272] ^ din[274] ^
               din[277] ^ din[278] ^ din[279] ^ din[280] ^ din[281] ^ din[282] ^
               din[285] ^ din[287];

    dout[25] = din[256] ^ din[257] ^ din[260] ^ din[261] ^ din[262] ^ din[263] ^
               din[264] ^ din[266] ^ din[268] ^ din[269] ^ din[270] ^ din[273] ^
               din[275] ^ din[278] ^ din[279] ^ din[280] ^ din[281] ^ din[282] ^
               din[283] ^ din[286];

    dout[26] = din[258] ^ din[259] ^ din[262] ^ din[263] ^ din[267] ^ din[268] ^
               din[270] ^ din[271] ^ din[273] ^ din[277] ^ din[280] ^ din[281] ^
               din[282] ^ din[284] ^ din[286];

    dout[27] = din[256] ^ din[259] ^ din[260] ^ din[263] ^ din[264] ^ din[268] ^
               din[269] ^ din[271] ^ din[272] ^ din[274] ^ din[278] ^ din[281] ^
               din[282] ^ din[283] ^ din[285] ^ din[287];

    dout[28] = din[257] ^ din[260] ^ din[261] ^ din[264] ^ din[265] ^ din[269] ^
               din[270] ^ din[272] ^ din[273] ^ din[275] ^ din[279] ^ din[282] ^
               din[283] ^ din[284] ^ din[286];

    dout[29] = din[256] ^ din[258] ^ din[261] ^ din[262] ^ din[265] ^ din[266] ^
               din[270] ^ din[271] ^ din[273] ^ din[274] ^ din[276] ^ din[280] ^
               din[283] ^ din[284] ^ din[285] ^ din[287];

    dout[30] = din[257] ^ din[259] ^ din[262] ^ din[263] ^ din[266] ^ din[267] ^
               din[271] ^ din[272] ^ din[274] ^ din[275] ^ din[277] ^ din[281] ^
               din[284] ^ din[285] ^ din[286];

    dout[31] = din[256] ^ din[258] ^ din[260] ^ din[263] ^ din[264] ^ din[267] ^
               din[268] ^ din[272] ^ din[273] ^ din[275] ^ din[276] ^ din[278] ^
               din[282] ^ din[285] ^ din[286] ^ din[287];

    fcs_next_d_511_0_part_9_of_16 = dout;

  end

  /* TOTAL XOR GATES: 4174 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_10_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[288] ^ din[290] ^ din[292] ^ din[294] ^ din[295] ^ din[296] ^
              din[297] ^ din[298] ^ din[299] ^ din[300] ^ din[302] ^ din[303] ^
              din[305] ^ din[309] ^ din[310] ^ din[312] ^ din[315] ^ din[317] ^
              din[318] ^ din[319];

    dout[1] = din[289] ^ din[290] ^ din[291] ^ din[292] ^ din[293] ^ din[294] ^
              din[301] ^ din[302] ^ din[304] ^ din[305] ^ din[306] ^ din[309] ^
              din[311] ^ din[312] ^ din[313] ^ din[315] ^ din[316] ^ din[317];

    dout[2] = din[288] ^ din[291] ^ din[293] ^ din[296] ^ din[297] ^ din[298] ^
              din[299] ^ din[300] ^ din[306] ^ din[307] ^ din[309] ^ din[313] ^
              din[314] ^ din[315] ^ din[316] ^ din[319];

    dout[3] = din[289] ^ din[292] ^ din[294] ^ din[297] ^ din[298] ^ din[299] ^
              din[300] ^ din[301] ^ din[307] ^ din[308] ^ din[310] ^ din[314] ^
              din[315] ^ din[316] ^ din[317];

    dout[4] = din[292] ^ din[293] ^ din[294] ^ din[296] ^ din[297] ^ din[301] ^
              din[303] ^ din[305] ^ din[308] ^ din[310] ^ din[311] ^ din[312] ^
              din[316] ^ din[319];

    dout[5] = din[288] ^ din[290] ^ din[292] ^ din[293] ^ din[296] ^ din[299] ^
              din[300] ^ din[303] ^ din[304] ^ din[305] ^ din[306] ^ din[310] ^
              din[311] ^ din[313] ^ din[315] ^ din[318] ^ din[319];

    dout[6] = din[288] ^ din[289] ^ din[291] ^ din[293] ^ din[294] ^ din[297] ^
              din[300] ^ din[301] ^ din[304] ^ din[305] ^ din[306] ^ din[307] ^
              din[311] ^ din[312] ^ din[314] ^ din[316] ^ din[319];

    dout[7] = din[288] ^ din[289] ^ din[296] ^ din[297] ^ din[299] ^ din[300] ^
              din[301] ^ din[303] ^ din[306] ^ din[307] ^ din[308] ^ din[309] ^
              din[310] ^ din[313] ^ din[318] ^ din[319];

    dout[8] = din[289] ^ din[292] ^ din[294] ^ din[295] ^ din[296] ^ din[299] ^
              din[301] ^ din[303] ^ din[304] ^ din[305] ^ din[307] ^ din[308] ^
              din[311] ^ din[312] ^ din[314] ^ din[315] ^ din[317] ^ din[318];

    dout[9] = din[290] ^ din[293] ^ din[295] ^ din[296] ^ din[297] ^ din[300] ^
              din[302] ^ din[304] ^ din[305] ^ din[306] ^ din[308] ^ din[309] ^
              din[312] ^ din[313] ^ din[315] ^ din[316] ^ din[318] ^ din[319];

    dout[10] = din[290] ^ din[291] ^ din[292] ^ din[295] ^ din[299] ^ din[300] ^
               din[301] ^ din[302] ^ din[306] ^ din[307] ^ din[312] ^ din[313] ^
               din[314] ^ din[315] ^ din[316] ^ din[318];

    dout[11] = din[290] ^ din[291] ^ din[293] ^ din[294] ^ din[295] ^ din[297] ^
               din[298] ^ din[299] ^ din[301] ^ din[305] ^ din[307] ^ din[308] ^
               din[309] ^ din[310] ^ din[312] ^ din[313] ^ din[314] ^ din[316] ^
               din[318];

    dout[12] = din[290] ^ din[291] ^ din[297] ^ din[303] ^ din[305] ^ din[306] ^
               din[308] ^ din[311] ^ din[312] ^ din[313] ^ din[314] ^ din[318];

    dout[13] = din[291] ^ din[292] ^ din[298] ^ din[304] ^ din[306] ^ din[307] ^
               din[309] ^ din[312] ^ din[313] ^ din[314] ^ din[315] ^ din[319];

    dout[14] = din[292] ^ din[293] ^ din[299] ^ din[305] ^ din[307] ^ din[308] ^
               din[310] ^ din[313] ^ din[314] ^ din[315] ^ din[316];

    dout[15] = din[293] ^ din[294] ^ din[300] ^ din[306] ^ din[308] ^ din[309] ^
               din[311] ^ din[314] ^ din[315] ^ din[316] ^ din[317];

    dout[16] = din[288] ^ din[290] ^ din[292] ^ din[296] ^ din[297] ^ din[298] ^
               din[299] ^ din[300] ^ din[301] ^ din[302] ^ din[303] ^ din[305] ^
               din[307] ^ din[316] ^ din[319];

    dout[17] = din[288] ^ din[289] ^ din[291] ^ din[293] ^ din[297] ^ din[298] ^
               din[299] ^ din[300] ^ din[301] ^ din[302] ^ din[303] ^ din[304] ^
               din[306] ^ din[308] ^ din[317];

    dout[18] = din[288] ^ din[289] ^ din[290] ^ din[292] ^ din[294] ^ din[298] ^
               din[299] ^ din[300] ^ din[301] ^ din[302] ^ din[303] ^ din[304] ^
               din[305] ^ din[307] ^ din[309] ^ din[318];

    dout[19] = din[289] ^ din[290] ^ din[291] ^ din[293] ^ din[295] ^ din[299] ^
               din[300] ^ din[301] ^ din[302] ^ din[303] ^ din[304] ^ din[305] ^
               din[306] ^ din[308] ^ din[310] ^ din[319];

    dout[20] = din[288] ^ din[290] ^ din[291] ^ din[292] ^ din[294] ^ din[296] ^
               din[300] ^ din[301] ^ din[302] ^ din[303] ^ din[304] ^ din[305] ^
               din[306] ^ din[307] ^ din[309] ^ din[311];

    dout[21] = din[289] ^ din[291] ^ din[292] ^ din[293] ^ din[295] ^ din[297] ^
               din[301] ^ din[302] ^ din[303] ^ din[304] ^ din[305] ^ din[306] ^
               din[307] ^ din[308] ^ din[310] ^ din[312];

    dout[22] = din[293] ^ din[295] ^ din[297] ^ din[299] ^ din[300] ^ din[304] ^
               din[306] ^ din[307] ^ din[308] ^ din[310] ^ din[311] ^ din[312] ^
               din[313] ^ din[315] ^ din[317] ^ din[318] ^ din[319];

    dout[23] = din[288] ^ din[290] ^ din[292] ^ din[295] ^ din[297] ^ din[299] ^
               din[301] ^ din[302] ^ din[303] ^ din[307] ^ din[308] ^ din[310] ^
               din[311] ^ din[313] ^ din[314] ^ din[315] ^ din[316] ^ din[317];

    dout[24] = din[289] ^ din[291] ^ din[293] ^ din[296] ^ din[298] ^ din[300] ^
               din[302] ^ din[303] ^ din[304] ^ din[308] ^ din[309] ^ din[311] ^
               din[312] ^ din[314] ^ din[315] ^ din[316] ^ din[317] ^ din[318];

    dout[25] = din[288] ^ din[290] ^ din[292] ^ din[294] ^ din[297] ^ din[299] ^
               din[301] ^ din[303] ^ din[304] ^ din[305] ^ din[309] ^ din[310] ^
               din[312] ^ din[313] ^ din[315] ^ din[316] ^ din[317] ^ din[318] ^
               din[319];

    dout[26] = din[288] ^ din[289] ^ din[290] ^ din[291] ^ din[292] ^ din[293] ^
               din[294] ^ din[296] ^ din[297] ^ din[299] ^ din[303] ^ din[304] ^
               din[306] ^ din[309] ^ din[311] ^ din[312] ^ din[313] ^ din[314] ^
               din[315] ^ din[316];

    dout[27] = din[289] ^ din[290] ^ din[291] ^ din[292] ^ din[293] ^ din[294] ^
               din[295] ^ din[297] ^ din[298] ^ din[300] ^ din[304] ^ din[305] ^
               din[307] ^ din[310] ^ din[312] ^ din[313] ^ din[314] ^ din[315] ^
               din[316] ^ din[317];

    dout[28] = din[288] ^ din[290] ^ din[291] ^ din[292] ^ din[293] ^ din[294] ^
               din[295] ^ din[296] ^ din[298] ^ din[299] ^ din[301] ^ din[305] ^
               din[306] ^ din[308] ^ din[311] ^ din[313] ^ din[314] ^ din[315] ^
               din[316] ^ din[317] ^ din[318];

    dout[29] = din[289] ^ din[291] ^ din[292] ^ din[293] ^ din[294] ^ din[295] ^
               din[296] ^ din[297] ^ din[299] ^ din[300] ^ din[302] ^ din[306] ^
               din[307] ^ din[309] ^ din[312] ^ din[314] ^ din[315] ^ din[316] ^
               din[317] ^ din[318] ^ din[319];

    dout[30] = din[288] ^ din[290] ^ din[292] ^ din[293] ^ din[294] ^ din[295] ^
               din[296] ^ din[297] ^ din[298] ^ din[300] ^ din[301] ^ din[303] ^
               din[307] ^ din[308] ^ din[310] ^ din[313] ^ din[315] ^ din[316] ^
               din[317] ^ din[318] ^ din[319];

    dout[31] = din[289] ^ din[291] ^ din[293] ^ din[294] ^ din[295] ^ din[296] ^
               din[297] ^ din[298] ^ din[299] ^ din[301] ^ din[302] ^ din[304] ^
               din[308] ^ din[309] ^ din[311] ^ din[314] ^ din[316] ^ din[317] ^
               din[318] ^ din[319];

    fcs_next_d_511_0_part_10_of_16 = dout;

  end

  /* TOTAL XOR GATES: 4681 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_11_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[320] ^ din[321] ^ din[322] ^ din[327] ^ din[328] ^ din[333] ^
              din[334] ^ din[335] ^ din[337] ^ din[338] ^ din[339] ^ din[341] ^
              din[342] ^ din[344] ^ din[345] ^ din[347] ^ din[348] ^ din[349];

    dout[1] = din[323] ^ din[327] ^ din[329] ^ din[333] ^ din[336] ^ din[337] ^
              din[340] ^ din[341] ^ din[343] ^ din[344] ^ din[346] ^ din[347] ^
              din[350];

    dout[2] = din[320] ^ din[321] ^ din[322] ^ din[324] ^ din[327] ^ din[330] ^
              din[333] ^ din[335] ^ din[339] ^ din[349] ^ din[351];

    dout[3] = din[320] ^ din[321] ^ din[322] ^ din[323] ^ din[325] ^ din[328] ^
              din[331] ^ din[334] ^ din[336] ^ din[340] ^ din[350];

    dout[4] = din[320] ^ din[323] ^ din[324] ^ din[326] ^ din[327] ^ din[328] ^
              din[329] ^ din[332] ^ din[333] ^ din[334] ^ din[338] ^ din[339] ^
              din[342] ^ din[344] ^ din[345] ^ din[347] ^ din[348] ^ din[349] ^
              din[351];

    dout[5] = din[322] ^ din[324] ^ din[325] ^ din[329] ^ din[330] ^ din[337] ^
              din[338] ^ din[340] ^ din[341] ^ din[342] ^ din[343] ^ din[344] ^
              din[346] ^ din[347] ^ din[350];

    dout[6] = din[320] ^ din[323] ^ din[325] ^ din[326] ^ din[330] ^ din[331] ^
              din[338] ^ din[339] ^ din[341] ^ din[342] ^ din[343] ^ din[344] ^
              din[345] ^ din[347] ^ din[348] ^ din[351];

    dout[7] = din[322] ^ din[324] ^ din[326] ^ din[328] ^ din[331] ^ din[332] ^
              din[333] ^ din[334] ^ din[335] ^ din[337] ^ din[338] ^ din[340] ^
              din[341] ^ din[343] ^ din[346] ^ din[347];

    dout[8] = din[321] ^ din[322] ^ din[323] ^ din[325] ^ din[328] ^ din[329] ^
              din[332] ^ din[336] ^ din[337] ^ din[345] ^ din[349];

    dout[9] = din[322] ^ din[323] ^ din[324] ^ din[326] ^ din[329] ^ din[330] ^
              din[333] ^ din[337] ^ din[338] ^ din[346] ^ din[350];

    dout[10] = din[321] ^ din[322] ^ din[323] ^ din[324] ^ din[325] ^ din[328] ^
               din[330] ^ din[331] ^ din[333] ^ din[335] ^ din[337] ^ din[341] ^
               din[342] ^ din[344] ^ din[345] ^ din[348] ^ din[349] ^ din[351];

    dout[11] = din[320] ^ din[321] ^ din[323] ^ din[324] ^ din[325] ^ din[326] ^
               din[327] ^ din[328] ^ din[329] ^ din[331] ^ din[332] ^ din[333] ^
               din[335] ^ din[336] ^ din[337] ^ din[339] ^ din[341] ^ din[343] ^
               din[344] ^ din[346] ^ din[347] ^ din[348] ^ din[350];

    dout[12] = din[320] ^ din[324] ^ din[325] ^ din[326] ^ din[329] ^ din[330] ^
               din[332] ^ din[335] ^ din[336] ^ din[339] ^ din[340] ^ din[341] ^
               din[351];

    dout[13] = din[321] ^ din[325] ^ din[326] ^ din[327] ^ din[330] ^ din[331] ^
               din[333] ^ din[336] ^ din[337] ^ din[340] ^ din[341] ^ din[342];

    dout[14] = din[320] ^ din[322] ^ din[326] ^ din[327] ^ din[328] ^ din[331] ^
               din[332] ^ din[334] ^ din[337] ^ din[338] ^ din[341] ^ din[342] ^
               din[343];

    dout[15] = din[321] ^ din[323] ^ din[327] ^ din[328] ^ din[329] ^ din[332] ^
               din[333] ^ din[335] ^ din[338] ^ din[339] ^ din[342] ^ din[343] ^
               din[344];

    dout[16] = din[320] ^ din[321] ^ din[324] ^ din[327] ^ din[329] ^ din[330] ^
               din[335] ^ din[336] ^ din[337] ^ din[338] ^ din[340] ^ din[341] ^
               din[342] ^ din[343] ^ din[347] ^ din[348] ^ din[349];

    dout[17] = din[320] ^ din[321] ^ din[322] ^ din[325] ^ din[328] ^ din[330] ^
               din[331] ^ din[336] ^ din[337] ^ din[338] ^ din[339] ^ din[341] ^
               din[342] ^ din[343] ^ din[344] ^ din[348] ^ din[349] ^ din[350];

    dout[18] = din[321] ^ din[322] ^ din[323] ^ din[326] ^ din[329] ^ din[331] ^
               din[332] ^ din[337] ^ din[338] ^ din[339] ^ din[340] ^ din[342] ^
               din[343] ^ din[344] ^ din[345] ^ din[349] ^ din[350] ^ din[351];

    dout[19] = din[322] ^ din[323] ^ din[324] ^ din[327] ^ din[330] ^ din[332] ^
               din[333] ^ din[338] ^ din[339] ^ din[340] ^ din[341] ^ din[343] ^
               din[344] ^ din[345] ^ din[346] ^ din[350] ^ din[351];

    dout[20] = din[320] ^ din[323] ^ din[324] ^ din[325] ^ din[328] ^ din[331] ^
               din[333] ^ din[334] ^ din[339] ^ din[340] ^ din[341] ^ din[342] ^
               din[344] ^ din[345] ^ din[346] ^ din[347] ^ din[351];

    dout[21] = din[321] ^ din[324] ^ din[325] ^ din[326] ^ din[329] ^ din[332] ^
               din[334] ^ din[335] ^ din[340] ^ din[341] ^ din[342] ^ din[343] ^
               din[345] ^ din[346] ^ din[347] ^ din[348];

    dout[22] = din[320] ^ din[321] ^ din[325] ^ din[326] ^ din[328] ^ din[330] ^
               din[334] ^ din[336] ^ din[337] ^ din[338] ^ din[339] ^ din[343] ^
               din[345] ^ din[346];

    dout[23] = din[326] ^ din[328] ^ din[329] ^ din[331] ^ din[333] ^ din[334] ^
               din[340] ^ din[341] ^ din[342] ^ din[345] ^ din[346] ^ din[348] ^
               din[349];

    dout[24] = din[327] ^ din[329] ^ din[330] ^ din[332] ^ din[334] ^ din[335] ^
               din[341] ^ din[342] ^ din[343] ^ din[346] ^ din[347] ^ din[349] ^
               din[350];

    dout[25] = din[328] ^ din[330] ^ din[331] ^ din[333] ^ din[335] ^ din[336] ^
               din[342] ^ din[343] ^ din[344] ^ din[347] ^ din[348] ^ din[350] ^
               din[351];

    dout[26] = din[321] ^ din[322] ^ din[327] ^ din[328] ^ din[329] ^ din[331] ^
               din[332] ^ din[333] ^ din[335] ^ din[336] ^ din[338] ^ din[339] ^
               din[341] ^ din[342] ^ din[343] ^ din[347] ^ din[351];

    dout[27] = din[322] ^ din[323] ^ din[328] ^ din[329] ^ din[330] ^ din[332] ^
               din[333] ^ din[334] ^ din[336] ^ din[337] ^ din[339] ^ din[340] ^
               din[342] ^ din[343] ^ din[344] ^ din[348];

    dout[28] = din[323] ^ din[324] ^ din[329] ^ din[330] ^ din[331] ^ din[333] ^
               din[334] ^ din[335] ^ din[337] ^ din[338] ^ din[340] ^ din[341] ^
               din[343] ^ din[344] ^ din[345] ^ din[349];

    dout[29] = din[324] ^ din[325] ^ din[330] ^ din[331] ^ din[332] ^ din[334] ^
               din[335] ^ din[336] ^ din[338] ^ din[339] ^ din[341] ^ din[342] ^
               din[344] ^ din[345] ^ din[346] ^ din[350];

    dout[30] = din[320] ^ din[325] ^ din[326] ^ din[331] ^ din[332] ^ din[333] ^
               din[335] ^ din[336] ^ din[337] ^ din[339] ^ din[340] ^ din[342] ^
               din[343] ^ din[345] ^ din[346] ^ din[347] ^ din[351];

    dout[31] = din[320] ^ din[321] ^ din[326] ^ din[327] ^ din[332] ^ din[333] ^
               din[334] ^ din[336] ^ din[337] ^ din[338] ^ din[340] ^ din[341] ^
               din[343] ^ din[344] ^ din[346] ^ din[347] ^ din[348];

    fcs_next_d_511_0_part_11_of_16 = dout;

  end

  /* TOTAL XOR GATES: 5137 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_12_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[353] ^ din[357] ^ din[358] ^ din[359] ^ din[362] ^ din[363] ^
              din[366] ^ din[368] ^ din[369] ^ din[372] ^ din[374] ^ din[376] ^
              din[378] ^ din[381];

    dout[1] = din[353] ^ din[354] ^ din[357] ^ din[360] ^ din[362] ^ din[364] ^
              din[366] ^ din[367] ^ din[368] ^ din[370] ^ din[372] ^ din[373] ^
              din[374] ^ din[375] ^ din[376] ^ din[377] ^ din[378] ^ din[379] ^
              din[381] ^ din[382];

    dout[2] = din[353] ^ din[354] ^ din[355] ^ din[357] ^ din[359] ^ din[361] ^
              din[362] ^ din[365] ^ din[366] ^ din[367] ^ din[371] ^ din[372] ^
              din[373] ^ din[375] ^ din[377] ^ din[379] ^ din[380] ^ din[381] ^
              din[382] ^ din[383];

    dout[3] = din[352] ^ din[354] ^ din[355] ^ din[356] ^ din[358] ^ din[360] ^
              din[362] ^ din[363] ^ din[366] ^ din[367] ^ din[368] ^ din[372] ^
              din[373] ^ din[374] ^ din[376] ^ din[378] ^ din[380] ^ din[381] ^
              din[382] ^ din[383];

    dout[4] = din[355] ^ din[356] ^ din[358] ^ din[361] ^ din[362] ^ din[364] ^
              din[366] ^ din[367] ^ din[372] ^ din[373] ^ din[375] ^ din[376] ^
              din[377] ^ din[378] ^ din[379] ^ din[382] ^ din[383];

    dout[5] = din[352] ^ din[353] ^ din[356] ^ din[358] ^ din[365] ^ din[366] ^
              din[367] ^ din[369] ^ din[372] ^ din[373] ^ din[377] ^ din[379] ^
              din[380] ^ din[381] ^ din[383];

    dout[6] = din[353] ^ din[354] ^ din[357] ^ din[359] ^ din[366] ^ din[367] ^
              din[368] ^ din[370] ^ din[373] ^ din[374] ^ din[378] ^ din[380] ^
              din[381] ^ din[382];

    dout[7] = din[352] ^ din[353] ^ din[354] ^ din[355] ^ din[357] ^ din[359] ^
              din[360] ^ din[362] ^ din[363] ^ din[366] ^ din[367] ^ din[371] ^
              din[372] ^ din[375] ^ din[376] ^ din[378] ^ din[379] ^ din[382] ^
              din[383];

    dout[8] = din[354] ^ din[355] ^ din[356] ^ din[357] ^ din[359] ^ din[360] ^
              din[361] ^ din[362] ^ din[364] ^ din[366] ^ din[367] ^ din[369] ^
              din[373] ^ din[374] ^ din[377] ^ din[378] ^ din[379] ^ din[380] ^
              din[381] ^ din[383];

    dout[9] = din[355] ^ din[356] ^ din[357] ^ din[358] ^ din[360] ^ din[361] ^
              din[362] ^ din[363] ^ din[365] ^ din[367] ^ din[368] ^ din[370] ^
              din[374] ^ din[375] ^ din[378] ^ din[379] ^ din[380] ^ din[381] ^
              din[382];

    dout[10] = din[353] ^ din[356] ^ din[361] ^ din[364] ^ din[371] ^ din[372] ^
               din[374] ^ din[375] ^ din[378] ^ din[379] ^ din[380] ^ din[382] ^
               din[383];

    dout[11] = din[352] ^ din[353] ^ din[354] ^ din[358] ^ din[359] ^ din[363] ^
               din[365] ^ din[366] ^ din[368] ^ din[369] ^ din[373] ^ din[374] ^
               din[375] ^ din[378] ^ din[379] ^ din[380] ^ din[383];

    dout[12] = din[354] ^ din[355] ^ din[357] ^ din[358] ^ din[360] ^ din[362] ^
               din[363] ^ din[364] ^ din[367] ^ din[368] ^ din[370] ^ din[372] ^
               din[375] ^ din[378] ^ din[379] ^ din[380];

    dout[13] = din[352] ^ din[355] ^ din[356] ^ din[358] ^ din[359] ^ din[361] ^
               din[363] ^ din[364] ^ din[365] ^ din[368] ^ din[369] ^ din[371] ^
               din[373] ^ din[376] ^ din[379] ^ din[380] ^ din[381];

    dout[14] = din[353] ^ din[356] ^ din[357] ^ din[359] ^ din[360] ^ din[362] ^
               din[364] ^ din[365] ^ din[366] ^ din[369] ^ din[370] ^ din[372] ^
               din[374] ^ din[377] ^ din[380] ^ din[381] ^ din[382];

    dout[15] = din[354] ^ din[357] ^ din[358] ^ din[360] ^ din[361] ^ din[363] ^
               din[365] ^ din[366] ^ din[367] ^ din[370] ^ din[371] ^ din[373] ^
               din[375] ^ din[378] ^ din[381] ^ din[382] ^ din[383];

    dout[16] = din[353] ^ din[355] ^ din[357] ^ din[361] ^ din[363] ^ din[364] ^
               din[367] ^ din[369] ^ din[371] ^ din[378] ^ din[379] ^ din[381] ^
               din[382] ^ din[383];

    dout[17] = din[354] ^ din[356] ^ din[358] ^ din[362] ^ din[364] ^ din[365] ^
               din[368] ^ din[370] ^ din[372] ^ din[379] ^ din[380] ^ din[382] ^
               din[383];

    dout[18] = din[355] ^ din[357] ^ din[359] ^ din[363] ^ din[365] ^ din[366] ^
               din[369] ^ din[371] ^ din[373] ^ din[380] ^ din[381] ^ din[383];

    dout[19] = din[352] ^ din[356] ^ din[358] ^ din[360] ^ din[364] ^ din[366] ^
               din[367] ^ din[370] ^ din[372] ^ din[374] ^ din[381] ^ din[382];

    dout[20] = din[352] ^ din[353] ^ din[357] ^ din[359] ^ din[361] ^ din[365] ^
               din[367] ^ din[368] ^ din[371] ^ din[373] ^ din[375] ^ din[382] ^
               din[383];

    dout[21] = din[352] ^ din[353] ^ din[354] ^ din[358] ^ din[360] ^ din[362] ^
               din[366] ^ din[368] ^ din[369] ^ din[372] ^ din[374] ^ din[376] ^
               din[383];

    dout[22] = din[354] ^ din[355] ^ din[357] ^ din[358] ^ din[361] ^ din[362] ^
               din[366] ^ din[367] ^ din[368] ^ din[370] ^ din[372] ^ din[373] ^
               din[374] ^ din[375] ^ din[376] ^ din[377] ^ din[378] ^ din[381];

    dout[23] = din[353] ^ din[355] ^ din[356] ^ din[357] ^ din[366] ^ din[367] ^
               din[371] ^ din[372] ^ din[373] ^ din[375] ^ din[377] ^ din[379] ^
               din[381] ^ din[382];

    dout[24] = din[354] ^ din[356] ^ din[357] ^ din[358] ^ din[367] ^ din[368] ^
               din[372] ^ din[373] ^ din[374] ^ din[376] ^ din[378] ^ din[380] ^
               din[382] ^ din[383];

    dout[25] = din[355] ^ din[357] ^ din[358] ^ din[359] ^ din[368] ^ din[369] ^
               din[373] ^ din[374] ^ din[375] ^ din[377] ^ din[379] ^ din[381] ^
               din[383];

    dout[26] = din[352] ^ din[353] ^ din[356] ^ din[357] ^ din[360] ^ din[362] ^
               din[363] ^ din[366] ^ din[368] ^ din[370] ^ din[372] ^ din[375] ^
               din[380] ^ din[381] ^ din[382];

    dout[27] = din[352] ^ din[353] ^ din[354] ^ din[357] ^ din[358] ^ din[361] ^
               din[363] ^ din[364] ^ din[367] ^ din[369] ^ din[371] ^ din[373] ^
               din[376] ^ din[381] ^ din[382] ^ din[383];

    dout[28] = din[353] ^ din[354] ^ din[355] ^ din[358] ^ din[359] ^ din[362] ^
               din[364] ^ din[365] ^ din[368] ^ din[370] ^ din[372] ^ din[374] ^
               din[377] ^ din[382] ^ din[383];

    dout[29] = din[354] ^ din[355] ^ din[356] ^ din[359] ^ din[360] ^ din[363] ^
               din[365] ^ din[366] ^ din[369] ^ din[371] ^ din[373] ^ din[375] ^
               din[378] ^ din[383];

    dout[30] = din[355] ^ din[356] ^ din[357] ^ din[360] ^ din[361] ^ din[364] ^
               din[366] ^ din[367] ^ din[370] ^ din[372] ^ din[374] ^ din[376] ^
               din[379];

    dout[31] = din[352] ^ din[356] ^ din[357] ^ din[358] ^ din[361] ^ din[362] ^
               din[365] ^ din[367] ^ din[368] ^ din[371] ^ din[373] ^ din[375] ^
               din[377] ^ din[380];

    fcs_next_d_511_0_part_12_of_16 = dout;

  end

  /* TOTAL XOR GATES: 5603 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_13_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[386] ^ din[387] ^ din[388] ^ din[390] ^ din[391] ^ din[392] ^
              din[393] ^ din[396] ^ din[398] ^ din[399] ^ din[400] ^ din[404] ^
              din[405] ^ din[407] ^ din[408] ^ din[409] ^ din[412] ^ din[414];

    dout[1] = din[386] ^ din[389] ^ din[390] ^ din[394] ^ din[396] ^ din[397] ^
              din[398] ^ din[401] ^ din[404] ^ din[406] ^ din[407] ^ din[410] ^
              din[412] ^ din[413] ^ din[414] ^ din[415];

    dout[2] = din[386] ^ din[388] ^ din[392] ^ din[393] ^ din[395] ^ din[396] ^
              din[397] ^ din[400] ^ din[402] ^ din[404] ^ din[409] ^ din[411] ^
              din[412] ^ din[413] ^ din[415];

    dout[3] = din[384] ^ din[387] ^ din[389] ^ din[393] ^ din[394] ^ din[396] ^
              din[397] ^ din[398] ^ din[401] ^ din[403] ^ din[405] ^ din[410] ^
              din[412] ^ din[413] ^ din[414];

    dout[4] = din[384] ^ din[385] ^ din[386] ^ din[387] ^ din[391] ^ din[392] ^
              din[393] ^ din[394] ^ din[395] ^ din[396] ^ din[397] ^ din[400] ^
              din[402] ^ din[405] ^ din[406] ^ din[407] ^ din[408] ^ din[409] ^
              din[411] ^ din[412] ^ din[413] ^ din[415];

    dout[5] = din[384] ^ din[385] ^ din[390] ^ din[391] ^ din[394] ^ din[395] ^
              din[397] ^ din[399] ^ din[400] ^ din[401] ^ din[403] ^ din[404] ^
              din[405] ^ din[406] ^ din[410] ^ din[413];

    dout[6] = din[384] ^ din[385] ^ din[386] ^ din[391] ^ din[392] ^ din[395] ^
              din[396] ^ din[398] ^ din[400] ^ din[401] ^ din[402] ^ din[404] ^
              din[405] ^ din[406] ^ din[407] ^ din[411] ^ din[414];

    dout[7] = din[385] ^ din[388] ^ din[390] ^ din[391] ^ din[397] ^ din[398] ^
              din[400] ^ din[401] ^ din[402] ^ din[403] ^ din[404] ^ din[406] ^
              din[409] ^ din[414] ^ din[415];

    dout[8] = din[384] ^ din[387] ^ din[388] ^ din[389] ^ din[390] ^ din[393] ^
              din[396] ^ din[400] ^ din[401] ^ din[402] ^ din[403] ^ din[408] ^
              din[409] ^ din[410] ^ din[412] ^ din[414] ^ din[415];

    dout[9] = din[384] ^ din[385] ^ din[388] ^ din[389] ^ din[390] ^ din[391] ^
              din[394] ^ din[397] ^ din[401] ^ din[402] ^ din[403] ^ din[404] ^
              din[409] ^ din[410] ^ din[411] ^ din[413] ^ din[415];

    dout[10] = din[385] ^ din[387] ^ din[388] ^ din[389] ^ din[393] ^ din[395] ^
               din[396] ^ din[399] ^ din[400] ^ din[402] ^ din[403] ^ din[407] ^
               din[408] ^ din[409] ^ din[410] ^ din[411];

    dout[11] = din[384] ^ din[387] ^ din[389] ^ din[391] ^ din[392] ^ din[393] ^
               din[394] ^ din[397] ^ din[398] ^ din[399] ^ din[401] ^ din[403] ^
               din[405] ^ din[407] ^ din[410] ^ din[411] ^ din[414];

    dout[12] = din[384] ^ din[385] ^ din[386] ^ din[387] ^ din[391] ^ din[394] ^
               din[395] ^ din[396] ^ din[402] ^ din[405] ^ din[406] ^ din[407] ^
               din[409] ^ din[411] ^ din[414] ^ din[415];

    dout[13] = din[385] ^ din[386] ^ din[387] ^ din[388] ^ din[392] ^ din[395] ^
               din[396] ^ din[397] ^ din[403] ^ din[406] ^ din[407] ^ din[408] ^
               din[410] ^ din[412] ^ din[415];

    dout[14] = din[386] ^ din[387] ^ din[388] ^ din[389] ^ din[393] ^ din[396] ^
               din[397] ^ din[398] ^ din[404] ^ din[407] ^ din[408] ^ din[409] ^
               din[411] ^ din[413];

    dout[15] = din[387] ^ din[388] ^ din[389] ^ din[390] ^ din[394] ^ din[397] ^
               din[398] ^ din[399] ^ din[405] ^ din[408] ^ din[409] ^ din[410] ^
               din[412] ^ din[414];

    dout[16] = din[384] ^ din[386] ^ din[387] ^ din[389] ^ din[392] ^ din[393] ^
               din[395] ^ din[396] ^ din[404] ^ din[405] ^ din[406] ^ din[407] ^
               din[408] ^ din[410] ^ din[411] ^ din[412] ^ din[413] ^ din[414] ^
               din[415];

    dout[17] = din[384] ^ din[385] ^ din[387] ^ din[388] ^ din[390] ^ din[393] ^
               din[394] ^ din[396] ^ din[397] ^ din[405] ^ din[406] ^ din[407] ^
               din[408] ^ din[409] ^ din[411] ^ din[412] ^ din[413] ^ din[414] ^
               din[415];

    dout[18] = din[384] ^ din[385] ^ din[386] ^ din[388] ^ din[389] ^ din[391] ^
               din[394] ^ din[395] ^ din[397] ^ din[398] ^ din[406] ^ din[407] ^
               din[408] ^ din[409] ^ din[410] ^ din[412] ^ din[413] ^ din[414] ^
               din[415];

    dout[19] = din[384] ^ din[385] ^ din[386] ^ din[387] ^ din[389] ^ din[390] ^
               din[392] ^ din[395] ^ din[396] ^ din[398] ^ din[399] ^ din[407] ^
               din[408] ^ din[409] ^ din[410] ^ din[411] ^ din[413] ^ din[414] ^
               din[415];

    dout[20] = din[385] ^ din[386] ^ din[387] ^ din[388] ^ din[390] ^ din[391] ^
               din[393] ^ din[396] ^ din[397] ^ din[399] ^ din[400] ^ din[408] ^
               din[409] ^ din[410] ^ din[411] ^ din[412] ^ din[414] ^ din[415];

    dout[21] = din[384] ^ din[386] ^ din[387] ^ din[388] ^ din[389] ^ din[391] ^
               din[392] ^ din[394] ^ din[397] ^ din[398] ^ din[400] ^ din[401] ^
               din[409] ^ din[410] ^ din[411] ^ din[412] ^ din[413] ^ din[415];

    dout[22] = din[384] ^ din[385] ^ din[386] ^ din[389] ^ din[391] ^ din[395] ^
               din[396] ^ din[400] ^ din[401] ^ din[402] ^ din[404] ^ din[405] ^
               din[407] ^ din[408] ^ din[409] ^ din[410] ^ din[411] ^ din[413];

    dout[23] = din[385] ^ din[388] ^ din[391] ^ din[393] ^ din[397] ^ din[398] ^
               din[399] ^ din[400] ^ din[401] ^ din[402] ^ din[403] ^ din[404] ^
               din[406] ^ din[407] ^ din[410] ^ din[411];

    dout[24] = din[386] ^ din[389] ^ din[392] ^ din[394] ^ din[398] ^ din[399] ^
               din[400] ^ din[401] ^ din[402] ^ din[403] ^ din[404] ^ din[405] ^
               din[407] ^ din[408] ^ din[411] ^ din[412];

    dout[25] = din[384] ^ din[387] ^ din[390] ^ din[393] ^ din[395] ^ din[399] ^
               din[400] ^ din[401] ^ din[402] ^ din[403] ^ din[404] ^ din[405] ^
               din[406] ^ din[408] ^ din[409] ^ din[412] ^ din[413];

    dout[26] = din[384] ^ din[385] ^ din[386] ^ din[387] ^ din[390] ^ din[392] ^
               din[393] ^ din[394] ^ din[398] ^ din[399] ^ din[401] ^ din[402] ^
               din[403] ^ din[406] ^ din[408] ^ din[410] ^ din[412] ^ din[413];

    dout[27] = din[385] ^ din[386] ^ din[387] ^ din[388] ^ din[391] ^ din[393] ^
               din[394] ^ din[395] ^ din[399] ^ din[400] ^ din[402] ^ din[403] ^
               din[404] ^ din[407] ^ din[409] ^ din[411] ^ din[413] ^ din[414];

    dout[28] = din[384] ^ din[386] ^ din[387] ^ din[388] ^ din[389] ^ din[392] ^
               din[394] ^ din[395] ^ din[396] ^ din[400] ^ din[401] ^ din[403] ^
               din[404] ^ din[405] ^ din[408] ^ din[410] ^ din[412] ^ din[414] ^
               din[415];

    dout[29] = din[384] ^ din[385] ^ din[387] ^ din[388] ^ din[389] ^ din[390] ^
               din[393] ^ din[395] ^ din[396] ^ din[397] ^ din[401] ^ din[402] ^
               din[404] ^ din[405] ^ din[406] ^ din[409] ^ din[411] ^ din[413] ^
               din[415];

    dout[30] = din[384] ^ din[385] ^ din[386] ^ din[388] ^ din[389] ^ din[390] ^
               din[391] ^ din[394] ^ din[396] ^ din[397] ^ din[398] ^ din[402] ^
               din[403] ^ din[405] ^ din[406] ^ din[407] ^ din[410] ^ din[412] ^
               din[414];

    dout[31] = din[385] ^ din[386] ^ din[387] ^ din[389] ^ din[390] ^ din[391] ^
               din[392] ^ din[395] ^ din[397] ^ din[398] ^ din[399] ^ din[403] ^
               din[404] ^ din[406] ^ din[407] ^ din[408] ^ din[411] ^ din[413] ^
               din[415];

    fcs_next_d_511_0_part_13_of_16 = dout;

  end

  /* TOTAL XOR GATES: 6122 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_14_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[416] ^ din[418] ^ din[419] ^ din[422] ^ din[424] ^ din[433] ^
              din[434] ^ din[436] ^ din[437] ^ din[444];

    dout[1] = din[416] ^ din[417] ^ din[418] ^ din[420] ^ din[422] ^ din[423] ^
              din[424] ^ din[425] ^ din[433] ^ din[435] ^ din[436] ^ din[438] ^
              din[444] ^ din[445];

    dout[2] = din[417] ^ din[421] ^ din[422] ^ din[423] ^ din[425] ^ din[426] ^
              din[433] ^ din[439] ^ din[444] ^ din[445] ^ din[446];

    dout[3] = din[416] ^ din[418] ^ din[422] ^ din[423] ^ din[424] ^ din[426] ^
              din[427] ^ din[434] ^ din[440] ^ din[445] ^ din[446] ^ din[447];

    dout[4] = din[416] ^ din[417] ^ din[418] ^ din[422] ^ din[423] ^ din[425] ^
              din[427] ^ din[428] ^ din[433] ^ din[434] ^ din[435] ^ din[436] ^
              din[437] ^ din[441] ^ din[444] ^ din[446] ^ din[447];

    dout[5] = din[417] ^ din[422] ^ din[423] ^ din[426] ^ din[428] ^ din[429] ^
              din[433] ^ din[435] ^ din[438] ^ din[442] ^ din[444] ^ din[445] ^
              din[447];

    dout[6] = din[418] ^ din[423] ^ din[424] ^ din[427] ^ din[429] ^ din[430] ^
              din[434] ^ din[436] ^ din[439] ^ din[443] ^ din[445] ^ din[446];

    dout[7] = din[416] ^ din[418] ^ din[422] ^ din[425] ^ din[428] ^ din[430] ^
              din[431] ^ din[433] ^ din[434] ^ din[435] ^ din[436] ^ din[440] ^
              din[446] ^ din[447];

    dout[8] = din[417] ^ din[418] ^ din[422] ^ din[423] ^ din[424] ^ din[426] ^
              din[429] ^ din[431] ^ din[432] ^ din[433] ^ din[435] ^ din[441] ^
              din[444] ^ din[447];

    dout[9] = din[416] ^ din[418] ^ din[419] ^ din[423] ^ din[424] ^ din[425] ^
              din[427] ^ din[430] ^ din[432] ^ din[433] ^ din[434] ^ din[436] ^
              din[442] ^ din[445];

    dout[10] = din[417] ^ din[418] ^ din[420] ^ din[422] ^ din[425] ^ din[426] ^
               din[428] ^ din[431] ^ din[435] ^ din[436] ^ din[443] ^ din[444] ^
               din[446];

    dout[11] = din[416] ^ din[421] ^ din[422] ^ din[423] ^ din[424] ^ din[426] ^
               din[427] ^ din[429] ^ din[432] ^ din[433] ^ din[434] ^ din[445] ^
               din[447];

    dout[12] = din[416] ^ din[417] ^ din[418] ^ din[419] ^ din[423] ^ din[425] ^
               din[427] ^ din[428] ^ din[430] ^ din[435] ^ din[436] ^ din[437] ^
               din[444] ^ din[446];

    dout[13] = din[416] ^ din[417] ^ din[418] ^ din[419] ^ din[420] ^ din[424] ^
               din[426] ^ din[428] ^ din[429] ^ din[431] ^ din[436] ^ din[437] ^
               din[438] ^ din[445] ^ din[447];

    dout[14] = din[416] ^ din[417] ^ din[418] ^ din[419] ^ din[420] ^ din[421] ^
               din[425] ^ din[427] ^ din[429] ^ din[430] ^ din[432] ^ din[437] ^
               din[438] ^ din[439] ^ din[446];

    dout[15] = din[417] ^ din[418] ^ din[419] ^ din[420] ^ din[421] ^ din[422] ^
               din[426] ^ din[428] ^ din[430] ^ din[431] ^ din[433] ^ din[438] ^
               din[439] ^ din[440] ^ din[447];

    dout[16] = din[416] ^ din[420] ^ din[421] ^ din[423] ^ din[424] ^ din[427] ^
               din[429] ^ din[431] ^ din[432] ^ din[433] ^ din[436] ^ din[437] ^
               din[439] ^ din[440] ^ din[441] ^ din[444];

    dout[17] = din[416] ^ din[417] ^ din[421] ^ din[422] ^ din[424] ^ din[425] ^
               din[428] ^ din[430] ^ din[432] ^ din[433] ^ din[434] ^ din[437] ^
               din[438] ^ din[440] ^ din[441] ^ din[442] ^ din[445];

    dout[18] = din[416] ^ din[417] ^ din[418] ^ din[422] ^ din[423] ^ din[425] ^
               din[426] ^ din[429] ^ din[431] ^ din[433] ^ din[434] ^ din[435] ^
               din[438] ^ din[439] ^ din[441] ^ din[442] ^ din[443] ^ din[446];

    dout[19] = din[416] ^ din[417] ^ din[418] ^ din[419] ^ din[423] ^ din[424] ^
               din[426] ^ din[427] ^ din[430] ^ din[432] ^ din[434] ^ din[435] ^
               din[436] ^ din[439] ^ din[440] ^ din[442] ^ din[443] ^ din[444] ^
               din[447];

    dout[20] = din[416] ^ din[417] ^ din[418] ^ din[419] ^ din[420] ^ din[424] ^
               din[425] ^ din[427] ^ din[428] ^ din[431] ^ din[433] ^ din[435] ^
               din[436] ^ din[437] ^ din[440] ^ din[441] ^ din[443] ^ din[444] ^
               din[445];

    dout[21] = din[416] ^ din[417] ^ din[418] ^ din[419] ^ din[420] ^ din[421] ^
               din[425] ^ din[426] ^ din[428] ^ din[429] ^ din[432] ^ din[434] ^
               din[436] ^ din[437] ^ din[438] ^ din[441] ^ din[442] ^ din[444] ^
               din[445] ^ din[446];

    dout[22] = din[417] ^ din[420] ^ din[421] ^ din[424] ^ din[426] ^ din[427] ^
               din[429] ^ din[430] ^ din[434] ^ din[435] ^ din[436] ^ din[438] ^
               din[439] ^ din[442] ^ din[443] ^ din[444] ^ din[445] ^ din[446] ^
               din[447];

    dout[23] = din[416] ^ din[419] ^ din[421] ^ din[424] ^ din[425] ^ din[427] ^
               din[428] ^ din[430] ^ din[431] ^ din[433] ^ din[434] ^ din[435] ^
               din[439] ^ din[440] ^ din[443] ^ din[445] ^ din[446] ^ din[447];

    dout[24] = din[417] ^ din[420] ^ din[422] ^ din[425] ^ din[426] ^ din[428] ^
               din[429] ^ din[431] ^ din[432] ^ din[434] ^ din[435] ^ din[436] ^
               din[440] ^ din[441] ^ din[444] ^ din[446] ^ din[447];

    dout[25] = din[418] ^ din[421] ^ din[423] ^ din[426] ^ din[427] ^ din[429] ^
               din[430] ^ din[432] ^ din[433] ^ din[435] ^ din[436] ^ din[437] ^
               din[441] ^ din[442] ^ din[445] ^ din[447];

    dout[26] = din[416] ^ din[418] ^ din[427] ^ din[428] ^ din[430] ^ din[431] ^
               din[438] ^ din[442] ^ din[443] ^ din[444] ^ din[446];

    dout[27] = din[417] ^ din[419] ^ din[428] ^ din[429] ^ din[431] ^ din[432] ^
               din[439] ^ din[443] ^ din[444] ^ din[445] ^ din[447];

    dout[28] = din[418] ^ din[420] ^ din[429] ^ din[430] ^ din[432] ^ din[433] ^
               din[440] ^ din[444] ^ din[445] ^ din[446];

    dout[29] = din[416] ^ din[419] ^ din[421] ^ din[430] ^ din[431] ^ din[433] ^
               din[434] ^ din[441] ^ din[445] ^ din[446] ^ din[447];

    dout[30] = din[416] ^ din[417] ^ din[420] ^ din[422] ^ din[431] ^ din[432] ^
               din[434] ^ din[435] ^ din[442] ^ din[446] ^ din[447];

    dout[31] = din[417] ^ din[418] ^ din[421] ^ din[423] ^ din[432] ^ din[433] ^
               din[435] ^ din[436] ^ din[443] ^ din[447];

    fcs_next_d_511_0_part_14_of_16 = dout;

  end

  /* TOTAL XOR GATES: 6549 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_15_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[448] ^ din[449] ^ din[450] ^ din[452] ^ din[458] ^ din[461] ^
              din[462] ^ din[464] ^ din[465] ^ din[468] ^ din[470] ^ din[472] ^
              din[476] ^ din[477] ^ din[479];

    dout[1] = din[448] ^ din[451] ^ din[452] ^ din[453] ^ din[458] ^ din[459] ^
              din[461] ^ din[463] ^ din[464] ^ din[466] ^ din[468] ^ din[469] ^
              din[470] ^ din[471] ^ din[472] ^ din[473] ^ din[476] ^ din[478] ^
              din[479];

    dout[2] = din[448] ^ din[450] ^ din[453] ^ din[454] ^ din[458] ^ din[459] ^
              din[460] ^ din[461] ^ din[467] ^ din[468] ^ din[469] ^ din[471] ^
              din[473] ^ din[474] ^ din[476];

    dout[3] = din[449] ^ din[451] ^ din[454] ^ din[455] ^ din[459] ^ din[460] ^
              din[461] ^ din[462] ^ din[468] ^ din[469] ^ din[470] ^ din[472] ^
              din[474] ^ din[475] ^ din[477];

    dout[4] = din[449] ^ din[455] ^ din[456] ^ din[458] ^ din[460] ^ din[463] ^
              din[464] ^ din[465] ^ din[468] ^ din[469] ^ din[471] ^ din[472] ^
              din[473] ^ din[475] ^ din[477] ^ din[478] ^ din[479];

    dout[5] = din[449] ^ din[452] ^ din[456] ^ din[457] ^ din[458] ^ din[459] ^
              din[462] ^ din[466] ^ din[468] ^ din[469] ^ din[473] ^ din[474] ^
              din[477] ^ din[478];

    dout[6] = din[448] ^ din[450] ^ din[453] ^ din[457] ^ din[458] ^ din[459] ^
              din[460] ^ din[463] ^ din[467] ^ din[469] ^ din[470] ^ din[474] ^
              din[475] ^ din[478] ^ din[479];

    dout[7] = din[448] ^ din[450] ^ din[451] ^ din[452] ^ din[454] ^ din[459] ^
              din[460] ^ din[462] ^ din[465] ^ din[471] ^ din[472] ^ din[475] ^
              din[477];

    dout[8] = din[450] ^ din[451] ^ din[453] ^ din[455] ^ din[458] ^ din[460] ^
              din[462] ^ din[463] ^ din[464] ^ din[465] ^ din[466] ^ din[468] ^
              din[470] ^ din[473] ^ din[477] ^ din[478] ^ din[479];

    dout[9] = din[448] ^ din[451] ^ din[452] ^ din[454] ^ din[456] ^ din[459] ^
              din[461] ^ din[463] ^ din[464] ^ din[465] ^ din[466] ^ din[467] ^
              din[469] ^ din[471] ^ din[474] ^ din[478] ^ din[479];

    dout[10] = din[448] ^ din[450] ^ din[453] ^ din[455] ^ din[457] ^ din[458] ^
               din[460] ^ din[461] ^ din[466] ^ din[467] ^ din[475] ^ din[476] ^
               din[477];

    dout[11] = din[448] ^ din[450] ^ din[451] ^ din[452] ^ din[454] ^ din[456] ^
               din[459] ^ din[464] ^ din[465] ^ din[467] ^ din[470] ^ din[472] ^
               din[478] ^ din[479];

    dout[12] = din[450] ^ din[451] ^ din[453] ^ din[455] ^ din[457] ^ din[458] ^
               din[460] ^ din[461] ^ din[462] ^ din[464] ^ din[466] ^ din[470] ^
               din[471] ^ din[472] ^ din[473] ^ din[476] ^ din[477];

    dout[13] = din[451] ^ din[452] ^ din[454] ^ din[456] ^ din[458] ^ din[459] ^
               din[461] ^ din[462] ^ din[463] ^ din[465] ^ din[467] ^ din[471] ^
               din[472] ^ din[473] ^ din[474] ^ din[477] ^ din[478];

    dout[14] = din[448] ^ din[452] ^ din[453] ^ din[455] ^ din[457] ^ din[459] ^
               din[460] ^ din[462] ^ din[463] ^ din[464] ^ din[466] ^ din[468] ^
               din[472] ^ din[473] ^ din[474] ^ din[475] ^ din[478] ^ din[479];

    dout[15] = din[449] ^ din[453] ^ din[454] ^ din[456] ^ din[458] ^ din[460] ^
               din[461] ^ din[463] ^ din[464] ^ din[465] ^ din[467] ^ din[469] ^
               din[473] ^ din[474] ^ din[475] ^ din[476] ^ din[479];

    dout[16] = din[449] ^ din[452] ^ din[454] ^ din[455] ^ din[457] ^ din[458] ^
               din[459] ^ din[466] ^ din[472] ^ din[474] ^ din[475] ^ din[479];

    dout[17] = din[450] ^ din[453] ^ din[455] ^ din[456] ^ din[458] ^ din[459] ^
               din[460] ^ din[467] ^ din[473] ^ din[475] ^ din[476];

    dout[18] = din[451] ^ din[454] ^ din[456] ^ din[457] ^ din[459] ^ din[460] ^
               din[461] ^ din[468] ^ din[474] ^ din[476] ^ din[477];

    dout[19] = din[452] ^ din[455] ^ din[457] ^ din[458] ^ din[460] ^ din[461] ^
               din[462] ^ din[469] ^ din[475] ^ din[477] ^ din[478];

    dout[20] = din[448] ^ din[453] ^ din[456] ^ din[458] ^ din[459] ^ din[461] ^
               din[462] ^ din[463] ^ din[470] ^ din[476] ^ din[478] ^ din[479];

    dout[21] = din[449] ^ din[454] ^ din[457] ^ din[459] ^ din[460] ^ din[462] ^
               din[463] ^ din[464] ^ din[471] ^ din[477] ^ din[479];

    dout[22] = din[448] ^ din[449] ^ din[452] ^ din[455] ^ din[460] ^ din[462] ^
               din[463] ^ din[468] ^ din[470] ^ din[476] ^ din[477] ^ din[478] ^
               din[479];

    dout[23] = din[452] ^ din[453] ^ din[456] ^ din[458] ^ din[462] ^ din[463] ^
               din[465] ^ din[468] ^ din[469] ^ din[470] ^ din[471] ^ din[472] ^
               din[476] ^ din[478];

    dout[24] = din[448] ^ din[453] ^ din[454] ^ din[457] ^ din[459] ^ din[463] ^
               din[464] ^ din[466] ^ din[469] ^ din[470] ^ din[471] ^ din[472] ^
               din[473] ^ din[477] ^ din[479];

    dout[25] = din[448] ^ din[449] ^ din[454] ^ din[455] ^ din[458] ^ din[460] ^
               din[464] ^ din[465] ^ din[467] ^ din[470] ^ din[471] ^ din[472] ^
               din[473] ^ din[474] ^ din[478];

    dout[26] = din[452] ^ din[455] ^ din[456] ^ din[458] ^ din[459] ^ din[462] ^
               din[464] ^ din[466] ^ din[470] ^ din[471] ^ din[473] ^ din[474] ^
               din[475] ^ din[476] ^ din[477];

    dout[27] = din[453] ^ din[456] ^ din[457] ^ din[459] ^ din[460] ^ din[463] ^
               din[465] ^ din[467] ^ din[471] ^ din[472] ^ din[474] ^ din[475] ^
               din[476] ^ din[477] ^ din[478];

    dout[28] = din[448] ^ din[454] ^ din[457] ^ din[458] ^ din[460] ^ din[461] ^
               din[464] ^ din[466] ^ din[468] ^ din[472] ^ din[473] ^ din[475] ^
               din[476] ^ din[477] ^ din[478] ^ din[479];

    dout[29] = din[449] ^ din[455] ^ din[458] ^ din[459] ^ din[461] ^ din[462] ^
               din[465] ^ din[467] ^ din[469] ^ din[473] ^ din[474] ^ din[476] ^
               din[477] ^ din[478] ^ din[479];

    dout[30] = din[448] ^ din[450] ^ din[456] ^ din[459] ^ din[460] ^ din[462] ^
               din[463] ^ din[466] ^ din[468] ^ din[470] ^ din[474] ^ din[475] ^
               din[477] ^ din[478] ^ din[479];

    dout[31] = din[448] ^ din[449] ^ din[451] ^ din[457] ^ din[460] ^ din[461] ^
               din[463] ^ din[464] ^ din[467] ^ din[469] ^ din[471] ^ din[475] ^
               din[476] ^ din[478] ^ din[479];

    fcs_next_d_511_0_part_15_of_16 = dout;

  end

  /* TOTAL XOR GATES: 6986 */

endfunction // fcs_next_d_511_0

function [31:0] fcs_next_d_511_0_part_16_of_16;

  input [511:0] din;
  reg   [31:0] dout;
  begin

    dout[0] = din[480] ^ din[481] ^ din[482] ^ din[483] ^ din[486] ^ din[488] ^
              din[489] ^ din[490] ^ din[491] ^ din[492] ^ din[493] ^ din[494] ^
              din[495] ^ din[500] ^ din[501] ^ din[502] ^ din[506] ^ din[507] ^
              din[508] ^ din[510] ^ din[511];

    dout[1] = din[484] ^ din[486] ^ din[487] ^ din[488] ^ din[496] ^ din[500] ^
              din[503] ^ din[506] ^ din[509] ^ din[510];

    dout[2] = din[481] ^ din[482] ^ din[483] ^ din[485] ^ din[486] ^ din[487] ^
              din[490] ^ din[491] ^ din[492] ^ din[493] ^ din[494] ^ din[495] ^
              din[497] ^ din[500] ^ din[502] ^ din[504] ^ din[506] ^ din[508];

    dout[3] = din[482] ^ din[483] ^ din[484] ^ din[486] ^ din[487] ^ din[488] ^
              din[491] ^ din[492] ^ din[493] ^ din[494] ^ din[495] ^ din[496] ^
              din[498] ^ din[501] ^ din[503] ^ din[505] ^ din[507] ^ din[509];

    dout[4] = din[480] ^ din[481] ^ din[482] ^ din[484] ^ din[485] ^ din[486] ^
              din[487] ^ din[490] ^ din[491] ^ din[496] ^ din[497] ^ din[499] ^
              din[500] ^ din[501] ^ din[504] ^ din[507] ^ din[511];

    dout[5] = din[485] ^ din[487] ^ din[489] ^ din[490] ^ din[493] ^ din[494] ^
              din[495] ^ din[497] ^ din[498] ^ din[505] ^ din[506] ^ din[507] ^
              din[510] ^ din[511];

    dout[6] = din[486] ^ din[488] ^ din[490] ^ din[491] ^ din[494] ^ din[495] ^
              din[496] ^ din[498] ^ din[499] ^ din[506] ^ din[507] ^ din[508] ^
              din[511];

    dout[7] = din[481] ^ din[482] ^ din[483] ^ din[486] ^ din[487] ^ din[488] ^
              din[490] ^ din[493] ^ din[494] ^ din[496] ^ din[497] ^ din[499] ^
              din[501] ^ din[502] ^ din[506] ^ din[509] ^ din[510] ^ din[511];

    dout[8] = din[480] ^ din[481] ^ din[484] ^ din[486] ^ din[487] ^ din[490] ^
              din[492] ^ din[493] ^ din[497] ^ din[498] ^ din[501] ^ din[503] ^
              din[506] ^ din[508];

    dout[9] = din[480] ^ din[481] ^ din[482] ^ din[485] ^ din[487] ^ din[488] ^
              din[491] ^ din[493] ^ din[494] ^ din[498] ^ din[499] ^ din[502] ^
              din[504] ^ din[507] ^ din[509];

    dout[10] = din[490] ^ din[491] ^ din[493] ^ din[499] ^ din[501] ^ din[502] ^
               din[503] ^ din[505] ^ din[506] ^ din[507] ^ din[511];

    dout[11] = din[480] ^ din[481] ^ din[482] ^ din[483] ^ din[486] ^ din[488] ^
               din[489] ^ din[490] ^ din[493] ^ din[495] ^ din[501] ^ din[503] ^
               din[504] ^ din[510] ^ din[511];

    dout[12] = din[484] ^ din[486] ^ din[487] ^ din[488] ^ din[492] ^ din[493] ^
               din[495] ^ din[496] ^ din[500] ^ din[501] ^ din[504] ^ din[505] ^
               din[506] ^ din[507] ^ din[508] ^ din[510];

    dout[13] = din[485] ^ din[487] ^ din[488] ^ din[489] ^ din[493] ^ din[494] ^
               din[496] ^ din[497] ^ din[501] ^ din[502] ^ din[505] ^ din[506] ^
               din[507] ^ din[508] ^ din[509] ^ din[511];

    dout[14] = din[486] ^ din[488] ^ din[489] ^ din[490] ^ din[494] ^ din[495] ^
               din[497] ^ din[498] ^ din[502] ^ din[503] ^ din[506] ^ din[507] ^
               din[508] ^ din[509] ^ din[510];

    dout[15] = din[480] ^ din[487] ^ din[489] ^ din[490] ^ din[491] ^ din[495] ^
               din[496] ^ din[498] ^ din[499] ^ din[503] ^ din[504] ^ din[507] ^
               din[508] ^ din[509] ^ din[510] ^ din[511];

    dout[16] = din[482] ^ din[483] ^ din[486] ^ din[489] ^ din[493] ^ din[494] ^
               din[495] ^ din[496] ^ din[497] ^ din[499] ^ din[501] ^ din[502] ^
               din[504] ^ din[505] ^ din[506] ^ din[507] ^ din[509];

    dout[17] = din[480] ^ din[483] ^ din[484] ^ din[487] ^ din[490] ^ din[494] ^
               din[495] ^ din[496] ^ din[497] ^ din[498] ^ din[500] ^ din[502] ^
               din[503] ^ din[505] ^ din[506] ^ din[507] ^ din[508] ^ din[510];

    dout[18] = din[481] ^ din[484] ^ din[485] ^ din[488] ^ din[491] ^ din[495] ^
               din[496] ^ din[497] ^ din[498] ^ din[499] ^ din[501] ^ din[503] ^
               din[504] ^ din[506] ^ din[507] ^ din[508] ^ din[509] ^ din[511];

    dout[19] = din[482] ^ din[485] ^ din[486] ^ din[489] ^ din[492] ^ din[496] ^
               din[497] ^ din[498] ^ din[499] ^ din[500] ^ din[502] ^ din[504] ^
               din[505] ^ din[507] ^ din[508] ^ din[509] ^ din[510];

    dout[20] = din[483] ^ din[486] ^ din[487] ^ din[490] ^ din[493] ^ din[497] ^
               din[498] ^ din[499] ^ din[500] ^ din[501] ^ din[503] ^ din[505] ^
               din[506] ^ din[508] ^ din[509] ^ din[510] ^ din[511];

    dout[21] = din[480] ^ din[484] ^ din[487] ^ din[488] ^ din[491] ^ din[494] ^
               din[498] ^ din[499] ^ din[500] ^ din[501] ^ din[502] ^ din[504] ^
               din[506] ^ din[507] ^ din[509] ^ din[510] ^ din[511];

    dout[22] = din[482] ^ din[483] ^ din[485] ^ din[486] ^ din[490] ^ din[491] ^
               din[493] ^ din[494] ^ din[499] ^ din[503] ^ din[505] ^ din[506];

    dout[23] = din[481] ^ din[482] ^ din[484] ^ din[487] ^ din[488] ^ din[489] ^
               din[490] ^ din[493] ^ din[501] ^ din[502] ^ din[504] ^ din[508] ^
               din[510] ^ din[511];

    dout[24] = din[482] ^ din[483] ^ din[485] ^ din[488] ^ din[489] ^ din[490] ^
               din[491] ^ din[494] ^ din[502] ^ din[503] ^ din[505] ^ din[509] ^
               din[511];

    dout[25] = din[480] ^ din[483] ^ din[484] ^ din[486] ^ din[489] ^ din[490] ^
               din[491] ^ din[492] ^ din[495] ^ din[503] ^ din[504] ^ din[506] ^
               din[510];

    dout[26] = din[480] ^ din[482] ^ din[483] ^ din[484] ^ din[485] ^ din[486] ^
               din[487] ^ din[488] ^ din[489] ^ din[494] ^ din[495] ^ din[496] ^
               din[500] ^ din[501] ^ din[502] ^ din[504] ^ din[505] ^ din[506] ^
               din[508] ^ din[510];

    dout[27] = din[481] ^ din[483] ^ din[484] ^ din[485] ^ din[486] ^ din[487] ^
               din[488] ^ din[489] ^ din[490] ^ din[495] ^ din[496] ^ din[497] ^
               din[501] ^ din[502] ^ din[503] ^ din[505] ^ din[506] ^ din[507] ^
               din[509] ^ din[511];

    dout[28] = din[482] ^ din[484] ^ din[485] ^ din[486] ^ din[487] ^ din[488] ^
               din[489] ^ din[490] ^ din[491] ^ din[496] ^ din[497] ^ din[498] ^
               din[502] ^ din[503] ^ din[504] ^ din[506] ^ din[507] ^ din[508] ^
               din[510];

    dout[29] = din[480] ^ din[483] ^ din[485] ^ din[486] ^ din[487] ^ din[488] ^
               din[489] ^ din[490] ^ din[491] ^ din[492] ^ din[497] ^ din[498] ^
               din[499] ^ din[503] ^ din[504] ^ din[505] ^ din[507] ^ din[508] ^
               din[509] ^ din[511];

    dout[30] = din[480] ^ din[481] ^ din[484] ^ din[486] ^ din[487] ^ din[488] ^
               din[489] ^ din[490] ^ din[491] ^ din[492] ^ din[493] ^ din[498] ^
               din[499] ^ din[500] ^ din[504] ^ din[505] ^ din[506] ^ din[508] ^
               din[509] ^ din[510];

    dout[31] = din[480] ^ din[481] ^ din[482] ^ din[485] ^ din[487] ^ din[488] ^
               din[489] ^ din[490] ^ din[491] ^ din[492] ^ din[493] ^ din[494] ^
               din[499] ^ din[500] ^ din[501] ^ din[505] ^ din[506] ^ din[507] ^
               din[509] ^ din[510] ^ din[511];

    fcs_next_d_511_0_part_16_of_16 = dout;

  end

  /* TOTAL XOR GATES: 7477 */

endfunction // fcs_next_d_511_0


function [31:0] fcs_next_c_383_0;

  input [31:0] cin;
  reg   [31:0] cout;
  begin

    cout[0] = cin[1] ^ cin[5] ^ cin[6] ^ cin[7] ^ cin[10] ^ cin[11] ^
              cin[14] ^ cin[16] ^ cin[17] ^ cin[20] ^ cin[22] ^ cin[24] ^
              cin[26] ^ cin[29];

    cout[1] = cin[1] ^ cin[2] ^ cin[5] ^ cin[8] ^ cin[10] ^ cin[12] ^
              cin[14] ^ cin[15] ^ cin[16] ^ cin[18] ^ cin[20] ^ cin[21] ^
              cin[22] ^ cin[23] ^ cin[24] ^ cin[25] ^ cin[26] ^ cin[27] ^
              cin[29] ^ cin[30];

    cout[2] = cin[1] ^ cin[2] ^ cin[3] ^ cin[5] ^ cin[7] ^ cin[9] ^
              cin[10] ^ cin[13] ^ cin[14] ^ cin[15] ^ cin[19] ^ cin[20] ^
              cin[21] ^ cin[23] ^ cin[25] ^ cin[27] ^ cin[28] ^ cin[29] ^
              cin[30] ^ cin[31];

    cout[3] = cin[0] ^ cin[2] ^ cin[3] ^ cin[4] ^ cin[6] ^ cin[8] ^
              cin[10] ^ cin[11] ^ cin[14] ^ cin[15] ^ cin[16] ^ cin[20] ^
              cin[21] ^ cin[22] ^ cin[24] ^ cin[26] ^ cin[28] ^ cin[29] ^
              cin[30] ^ cin[31];

    cout[4] = cin[3] ^ cin[4] ^ cin[6] ^ cin[9] ^ cin[10] ^ cin[12] ^
              cin[14] ^ cin[15] ^ cin[20] ^ cin[21] ^ cin[23] ^ cin[24] ^
              cin[25] ^ cin[26] ^ cin[27] ^ cin[30] ^ cin[31];

    cout[5] = cin[0] ^ cin[1] ^ cin[4] ^ cin[6] ^ cin[13] ^ cin[14] ^
              cin[15] ^ cin[17] ^ cin[20] ^ cin[21] ^ cin[25] ^ cin[27] ^
              cin[28] ^ cin[29] ^ cin[31];

    cout[6] = cin[1] ^ cin[2] ^ cin[5] ^ cin[7] ^ cin[14] ^ cin[15] ^
              cin[16] ^ cin[18] ^ cin[21] ^ cin[22] ^ cin[26] ^ cin[28] ^
              cin[29] ^ cin[30];

    cout[7] = cin[0] ^ cin[1] ^ cin[2] ^ cin[3] ^ cin[5] ^ cin[7] ^
              cin[8] ^ cin[10] ^ cin[11] ^ cin[14] ^ cin[15] ^ cin[19] ^
              cin[20] ^ cin[23] ^ cin[24] ^ cin[26] ^ cin[27] ^ cin[30] ^
              cin[31];

    cout[8] = cin[2] ^ cin[3] ^ cin[4] ^ cin[5] ^ cin[7] ^ cin[8] ^
              cin[9] ^ cin[10] ^ cin[12] ^ cin[14] ^ cin[15] ^ cin[17] ^
              cin[21] ^ cin[22] ^ cin[25] ^ cin[26] ^ cin[27] ^ cin[28] ^
              cin[29] ^ cin[31];

    cout[9] = cin[3] ^ cin[4] ^ cin[5] ^ cin[6] ^ cin[8] ^ cin[9] ^
              cin[10] ^ cin[11] ^ cin[13] ^ cin[15] ^ cin[16] ^ cin[18] ^
              cin[22] ^ cin[23] ^ cin[26] ^ cin[27] ^ cin[28] ^ cin[29] ^
              cin[30];

    cout[10] = cin[1] ^ cin[4] ^ cin[9] ^ cin[12] ^ cin[19] ^ cin[20] ^
               cin[22] ^ cin[23] ^ cin[26] ^ cin[27] ^ cin[28] ^ cin[30] ^
               cin[31];

    cout[11] = cin[0] ^ cin[1] ^ cin[2] ^ cin[6] ^ cin[7] ^ cin[11] ^
               cin[13] ^ cin[14] ^ cin[16] ^ cin[17] ^ cin[21] ^ cin[22] ^
               cin[23] ^ cin[26] ^ cin[27] ^ cin[28] ^ cin[31];

    cout[12] = cin[2] ^ cin[3] ^ cin[5] ^ cin[6] ^ cin[8] ^ cin[10] ^
               cin[11] ^ cin[12] ^ cin[15] ^ cin[16] ^ cin[18] ^ cin[20] ^
               cin[23] ^ cin[26] ^ cin[27] ^ cin[28];

    cout[13] = cin[0] ^ cin[3] ^ cin[4] ^ cin[6] ^ cin[7] ^ cin[9] ^
               cin[11] ^ cin[12] ^ cin[13] ^ cin[16] ^ cin[17] ^ cin[19] ^
               cin[21] ^ cin[24] ^ cin[27] ^ cin[28] ^ cin[29];

    cout[14] = cin[1] ^ cin[4] ^ cin[5] ^ cin[7] ^ cin[8] ^ cin[10] ^
               cin[12] ^ cin[13] ^ cin[14] ^ cin[17] ^ cin[18] ^ cin[20] ^
               cin[22] ^ cin[25] ^ cin[28] ^ cin[29] ^ cin[30];

    cout[15] = cin[2] ^ cin[5] ^ cin[6] ^ cin[8] ^ cin[9] ^ cin[11] ^
               cin[13] ^ cin[14] ^ cin[15] ^ cin[18] ^ cin[19] ^ cin[21] ^
               cin[23] ^ cin[26] ^ cin[29] ^ cin[30] ^ cin[31];

    cout[16] = cin[1] ^ cin[3] ^ cin[5] ^ cin[9] ^ cin[11] ^ cin[12] ^
               cin[15] ^ cin[17] ^ cin[19] ^ cin[26] ^ cin[27] ^ cin[29] ^
               cin[30] ^ cin[31];

    cout[17] = cin[2] ^ cin[4] ^ cin[6] ^ cin[10] ^ cin[12] ^ cin[13] ^
               cin[16] ^ cin[18] ^ cin[20] ^ cin[27] ^ cin[28] ^ cin[30] ^
               cin[31];

    cout[18] = cin[3] ^ cin[5] ^ cin[7] ^ cin[11] ^ cin[13] ^ cin[14] ^
               cin[17] ^ cin[19] ^ cin[21] ^ cin[28] ^ cin[29] ^ cin[31];

    cout[19] = cin[0] ^ cin[4] ^ cin[6] ^ cin[8] ^ cin[12] ^ cin[14] ^
               cin[15] ^ cin[18] ^ cin[20] ^ cin[22] ^ cin[29] ^ cin[30];

    cout[20] = cin[0] ^ cin[1] ^ cin[5] ^ cin[7] ^ cin[9] ^ cin[13] ^
               cin[15] ^ cin[16] ^ cin[19] ^ cin[21] ^ cin[23] ^ cin[30] ^
               cin[31];

    cout[21] = cin[0] ^ cin[1] ^ cin[2] ^ cin[6] ^ cin[8] ^ cin[10] ^
               cin[14] ^ cin[16] ^ cin[17] ^ cin[20] ^ cin[22] ^ cin[24] ^
               cin[31];

    cout[22] = cin[2] ^ cin[3] ^ cin[5] ^ cin[6] ^ cin[9] ^ cin[10] ^
               cin[14] ^ cin[15] ^ cin[16] ^ cin[18] ^ cin[20] ^ cin[21] ^
               cin[22] ^ cin[23] ^ cin[24] ^ cin[25] ^ cin[26] ^ cin[29];

    cout[23] = cin[1] ^ cin[3] ^ cin[4] ^ cin[5] ^ cin[14] ^ cin[15] ^
               cin[19] ^ cin[20] ^ cin[21] ^ cin[23] ^ cin[25] ^ cin[27] ^
               cin[29] ^ cin[30];

    cout[24] = cin[2] ^ cin[4] ^ cin[5] ^ cin[6] ^ cin[15] ^ cin[16] ^
               cin[20] ^ cin[21] ^ cin[22] ^ cin[24] ^ cin[26] ^ cin[28] ^
               cin[30] ^ cin[31];

    cout[25] = cin[3] ^ cin[5] ^ cin[6] ^ cin[7] ^ cin[16] ^ cin[17] ^
               cin[21] ^ cin[22] ^ cin[23] ^ cin[25] ^ cin[27] ^ cin[29] ^
               cin[31];

    cout[26] = cin[0] ^ cin[1] ^ cin[4] ^ cin[5] ^ cin[8] ^ cin[10] ^
               cin[11] ^ cin[14] ^ cin[16] ^ cin[18] ^ cin[20] ^ cin[23] ^
               cin[28] ^ cin[29] ^ cin[30];

    cout[27] = cin[0] ^ cin[1] ^ cin[2] ^ cin[5] ^ cin[6] ^ cin[9] ^
               cin[11] ^ cin[12] ^ cin[15] ^ cin[17] ^ cin[19] ^ cin[21] ^
               cin[24] ^ cin[29] ^ cin[30] ^ cin[31];

    cout[28] = cin[1] ^ cin[2] ^ cin[3] ^ cin[6] ^ cin[7] ^ cin[10] ^
               cin[12] ^ cin[13] ^ cin[16] ^ cin[18] ^ cin[20] ^ cin[22] ^
               cin[25] ^ cin[30] ^ cin[31];

    cout[29] = cin[2] ^ cin[3] ^ cin[4] ^ cin[7] ^ cin[8] ^ cin[11] ^
               cin[13] ^ cin[14] ^ cin[17] ^ cin[19] ^ cin[21] ^ cin[23] ^
               cin[26] ^ cin[31];

    cout[30] = cin[3] ^ cin[4] ^ cin[5] ^ cin[8] ^ cin[9] ^ cin[12] ^
               cin[14] ^ cin[15] ^ cin[18] ^ cin[20] ^ cin[22] ^ cin[24] ^
               cin[27];

    cout[31] = cin[0] ^ cin[4] ^ cin[5] ^ cin[6] ^ cin[9] ^ cin[10] ^
               cin[13] ^ cin[15] ^ cin[16] ^ cin[19] ^ cin[21] ^ cin[23] ^
               cin[25] ^ cin[28];

    fcs_next_c_383_0 = cout;

  end

  /* TOTAL XOR GATES: 466 */

endfunction // fcs_next_c_383_0

endmodule
///// CRC Wrapper
module mrmac_0_crc_wrapper
  (
   input                    tx_clk,
   input                    rx_clk,
   input                    tx_reset,
   input                    rx_reset,

   input        [2:0]       number_of_segments,
   input                    ten_gb_mode,

   // TX AXIS
   input                    tvalid,
   input        [5:0][63:0] tdata,
   input        [5:0][10:0] tkeep,
   input                    tlast,
   input                    tready,

   // RX AXIS
   input                    rvalid,
   input        [5:0][63:0] rdata,
   input        [5:0][10:0] rkeep,
   input                    rlast,

   input                    fifo_reset,

   // CRC error count
   input                    crc_error_cnt_latch_clr,
   output logic [31:0]      crc_error_cnt

   );

//=================================================
// Input stage
//=================================================

  // reset synchronization
  logic                     sync_fifo_reset_tx_clk_w, sync_fifo_reset_rx_clk_w;

mrmac_0_syncer_level
    #(.WIDTH       (1),
      .RESET_VALUE (1))
i_mrmac_0_syncer_level_reset_tx_sync
    (
     .clk     (tx_clk),
     .reset   (!(fifo_reset | tx_reset | rx_reset)),

     .datain  (1'b0),
     .dataout (sync_fifo_reset_tx_clk_w)
     );

mrmac_0_syncer_level
    #(.WIDTH       (1),
      .RESET_VALUE (1))
i_mrmac_0_syncer_level_reset_rx_sync
    (
     .clk     (rx_clk),
     .reset   (!(fifo_reset | tx_reset | rx_reset)),

     .datain  (1'b0),
     .dataout (sync_fifo_reset_rx_clk_w)
     );


  logic                     tvalid_q, tvalid_mux;
  logic [5:0][63:0]         tdata_q, tdata_mux_c, tdata_mux;
  logic [5:0][10:0]         tkeep_q;
  logic                     tready_q;
  logic                     tlast_q, tlast_mux;

  always_comb begin
    // set invalid bytes to zero
    // during tlast cycle
    for(int a=0; a<6; a++) begin
      for(int b=0; b<8; b++) begin
        if(tkeep_q[a][b])
          tdata_mux_c[a][b*8+:8] = tdata_q[a][b*8+:8];
        else
          tdata_mux_c[a][b*8+:8] = '0;
      end
    end

    // zero unused segments
    if(ten_gb_mode) begin
      tdata_mux_c[5:1]      = '0;
      tdata_mux_c[0][63:32] = '0;
    end
    else if(number_of_segments == 3'd1)
      tdata_mux_c[5:1] = '0;
    else if(number_of_segments == 3'd2)
      tdata_mux_c[5:2] = '0;
    else if(number_of_segments == 3'd4)
      tdata_mux_c[5:4] = '0;
  end

  always_ff @(posedge tx_clk) begin
    if(tx_reset) begin
      tvalid_q   <= '0;
      tready_q   <= '0;
      tvalid_mux <= '0;
    end
    else begin
      tvalid_q   <= tvalid;
      tready_q   <= tready;
      tvalid_mux <= tvalid_q && tready_q;
    end
  end // always_ff @ (posedge rx_clk)

  always_ff @(posedge tx_clk) begin
    tdata_q    <= tdata;
    tkeep_q    <= tkeep;
    tlast_q    <= tlast;
    tdata_mux  <= tdata_mux_c;
    tlast_mux  <= tlast_q;
  end


  logic                     rvalid_q, rvalid_mux;
  logic [5:0][63:0]         rdata_q, rdata_mux_c, rdata_mux;
  logic [5:0][10:0]         rkeep_q;
  logic                     rlast_q, rlast_mux;

  always_comb begin
    // set invalid bytes to zero
    for(int a=0; a<6; a++) begin
      for(int b=0; b<8; b++) begin
        if(rkeep_q[a][b])
          rdata_mux_c[a][b*8+:8] = rdata_q[a][b*8+:8];
        else
          rdata_mux_c[a][b*8+:8] = '0;
      end
    end

    // zero unused segments
    if(ten_gb_mode) begin
      rdata_mux_c[5:1]      = '0;
      rdata_mux_c[0][63:32] = '0;
    end
    else if(number_of_segments == 3'd1)
      rdata_mux_c[5:1] = '0;
    else if(number_of_segments == 3'd2)
      rdata_mux_c[5:2] = '0;
    else if(number_of_segments == 3'd4)
      rdata_mux_c[5:4] = '0;
  end

  always_ff @(posedge rx_clk) begin
    if(rx_reset) begin
      rvalid_q   <= '0;
      rvalid_mux <= '0;
    end
    else begin
      rvalid_q   <= rvalid;
      rvalid_mux <= rvalid_q;
    end
  end // always_ff @ (posedge rx_clk)

  always_ff @(posedge rx_clk) begin
    rdata_q    <= rdata;
    rkeep_q    <= rkeep;
    rlast_q    <= rlast;
    rdata_mux  <= rdata_mux_c;
    rlast_mux  <= rlast_q;
  end


//=================================================
// TX FCS generators
// - always calculate full word CRC for simplicity
// - assume invalid bytes in tlast word are zero
//=================================================
  logic         tx_fcs_384b_vld_w, tx_fcs_384b_vld;
  logic [31:0]  tx_fcs_384b_w, tx_fcs_384b;

mrmac_0_crc384b i_mrmac_0_crc384b_tx_inst (
   .i_eop     (tlast_mux),
   .i_dat     (tdata_mux[5:0]),
   .i_ena     (tvalid_mux),

   .o_crc_val (tx_fcs_384b_vld_w),
   .o_crc     (tx_fcs_384b_w),

   .clk       (tx_clk),
   .reset     (sync_fifo_reset_tx_clk_w)
);

  always @(posedge tx_clk) begin
    if(tx_reset)
      tx_fcs_384b_vld <= '0;
    else
      tx_fcs_384b_vld <= tx_fcs_384b_vld_w;
  end

  always @(posedge tx_clk) begin
    tx_fcs_384b <= tx_fcs_384b_w;
  end
//=================================================
// RX FCS generators
// - always calculate full word CRC for simplicity
// - assume invalid bytes in tlast word are zero
//=================================================

  logic        rx_fcs_384b_vld;
  logic [31:0] rx_fcs_384b;

mrmac_0_crc384b i_mrmac_0_crc384b_rx_inst (
   .i_eop     (rlast_mux),
   .i_dat     (rdata_mux[5:0]),
   .i_ena     (rvalid_mux),

   .o_crc_val (rx_fcs_384b_vld),
   .o_crc     (rx_fcs_384b),

   .clk       (rx_clk),
   .reset     (sync_fifo_reset_rx_clk_w)
);


//=================================================
// FIFO and comparator (two clocks must be synchronous)
//=================================================
  logic        fifo_we_c, fifo_rd_enb_c;
  logic        fifo_empty_w, fifo_almost_empty_w, fifo_almost_full_w, fifo_full_w;
  logic [31:0] fifo_wdata_c, fifo_rdata_w;

  always_comb begin
    fifo_we_c     = tx_fcs_384b_vld;
    fifo_rd_enb_c = rx_fcs_384b_vld;
    fifo_wdata_c  = tx_fcs_384b;
  end

//  fifo_reg_1clk #(
//    .WIDTH        (32),
//    .REG          (1),
//    .DEPTHLOG2    ($clog2(64)),
//    .DEPTH        (64),
//    .ALMOSTFULL   (48),
//    .ALMOSTEMPTY  (8)
//  ) fifo_reg_1clk_inst (
//    .clk                    (tx_clk),
//    .reset                  (!sync_fifo_reset_tx_clk_w),
//    .we                     (fifo_we_c),
//    .wdat                   (fifo_wdata_c),
//    .re                     (fifo_rd_enb_c),
//    .rdat                   (fifo_rdata_w),
//    .rdat_unreg             (),
//    .almost_empty_threshold (),
//    .almost_full_threshold  (),
//    .empty                  (fifo_empty_w),
//    .almost_empty           (fifo_almost_empty_w),
//    .almost_full            (fifo_almost_full_w),
//    .fill_level             (),
//    .full                   (fifo_full_w)
//  );
mrmac_0_fifo_reg_2clk
#(
  .WIDTH     (32),
  .DEPTHLOG2 (7),
  .DEPTH     (128)
 )
i_mrmac_0_fifo_inst (
  .wclk   (tx_clk),
  .rclk   (rx_clk),
  .wreset (sync_fifo_reset_tx_clk_w),
  .rreset (sync_fifo_reset_rx_clk_w),
  .wdat   (fifo_wdata_c),
  .we     (fifo_we_c),
  .re     (fifo_rd_enb_c),
  .rdat   (fifo_rdata_w)
);


//fifo_2clk fifo_reg_2clk_inst(
//
//      .wclk        (tx_clk),
//      .wclk_resetn (~tx_reset),
//      .rclk        (rx_clk),
//      .rclk_resetn (~rx_reset),
//
//      .we          (fifo_we_c),
//      .wdata       (fifo_wdata_c),
//      .almostfull  (),
//      .overflow    (),
//
//      .rd          (fifo_rd_enb_c),
//      .rdata       (fifo_rdata_w),
//      .avail       (),
//      .valid       (),
//      .underflow   ()
//);

  logic comp_ena;
  logic crc_error;
  logic [31:0] rx_fcs_384b_q;

  always_ff @(posedge rx_clk) begin
    if(rx_reset) begin
      rx_fcs_384b_q <= '0;
      comp_ena      <= '0;
      crc_error     <= '0;
    end
    else begin
      rx_fcs_384b_q <= rx_fcs_384b;
      comp_ena      <= fifo_rd_enb_c;
      crc_error     <= comp_ena && (fifo_rdata_w != rx_fcs_384b_q);
    end
  end


//=================================================
// Error Counter
//=================================================
  logic [15:0] int_crc_cnt_w;
  logic crc_error_cnt_latch_clr_q;

mrmac_0_hs_counter #(.CNT_WIDTH  (16),
             .INCR_WIDTH (1),
             .SATURATE   (1))
i_mrmac_0_hs_counter_rx_byte_cnt
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (crc_error_cnt_latch_clr),
   .incr  (crc_error),
   .cnt   (int_crc_cnt_w)
   );

  always_ff @(posedge rx_clk) begin
    if(rx_reset) begin
      crc_error_cnt             <= '0;
      crc_error_cnt_latch_clr_q <= '0;
    end
    else begin
      crc_error_cnt_latch_clr_q <= crc_error_cnt_latch_clr;

      if(crc_error_cnt_latch_clr_q)
        crc_error_cnt <= {16'h0,int_crc_cnt_w};
    end
  end

endmodule // crc_wrapper


//// 32Bit Gen
module mrmac_0_core_lbus_pkt_gen_32b
   (
     input 		 clk,
     input 		 resetn,

     // VIO controls
     input  [15:0] DUPLEX_PKT_SIZE,
     input wire [47:0]   tx_mac_dest_addr,
     input wire [47:0]   tx_mac_src_addr,

     output reg 	 tx_done_led,
     output reg 	 tx_busy_led,
     // VIO proc I/F

     input wire 	 tx_rdyout,
     output reg [64-1:0] tx_datain0,
     output reg 	 tx_eopin0,
     output reg [7:0]    tx_mtyin0,
     input wire 	 tx_ovfout,
     input wire 	 tx_unfout,
     input wire    start_prbs,
     input wire    stop_prbs,

     //AXI additional signals
     output reg 	 tx_axis_tvalid_0
    );

    // pkt_gen States
    parameter STATE_TX_IDLE             = 0;
    parameter STATE_PKT_TRANSFER_INIT   = 1;
    parameter STATE_LBUS_TX_ENABLE      = 2;
    parameter STATE_LBUS_TX_HALT        = 3;
    parameter STATE_LBUS_TX_DONE        = 4;

    //State Registers for TX
    reg [3:0] tx_prestate, tx_nxtstate;

    reg [15:0] pending_pkt_size;
    reg [15:0] pending_pkt_4size;
    reg        first_pkt, second_pkt, third_pkt, fourth_pkt, tx_fsm_en;
    reg        tx_done_reg, tx_done_reg_c, tx_done_reg_d, rx_fail_reg;
    reg        tx_rdyout_d, tx_ovfout_d, tx_unfout_d;
    reg        start_prbs_1d, start_prbs_2d, start_prbs_3d, start_prbs_4d;
    reg        stop_prbs_1d, stop_prbs_2d, stop_prbs_3d, stop_prbs_4d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_1d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_2d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_3d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_4d;
    reg        segment0_eop;
    reg        nxt_eopin0, nxt_valid0;

    reg [ 7:0] mtyin0_loc;
    wire [31:0] payload_byte;
    reg [64-1:0] nxt_datain0;
    reg [7:0] 	 nxt_mtyin0;
    reg [15:0] lbus_pkt_size_proc;
    reg        init_done;
    reg        stop_prbs_edge;
    reg [15:0] LEN_TYPE_FIELD;
(* ASYNC_REG = "TRUE" *)    reg        tx_done, tx_core_busy_led;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_1d, tx_core_busy_led_1d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_2d, tx_core_busy_led_2d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_3d, tx_core_busy_led_3d;

    ////////////////////////////////////////////////
    //registering input signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_rdyout_d            <= 1'b0;
            tx_ovfout_d            <= 1'b0;
            tx_unfout_d            <= 1'b0;
            start_prbs_1d          <= 1'b0; 
            start_prbs_2d          <= 1'b0; 
            start_prbs_3d          <= 1'b0; 
            start_prbs_4d          <= 1'b0; 
            stop_prbs_1d          <= 1'b0; 
            stop_prbs_2d          <= 1'b0; 
            stop_prbs_3d          <= 1'b0; 
            stop_prbs_4d          <= 1'b0; 
            DUPLEX_PKT_SIZE_1d      <= 16'd0; 
            DUPLEX_PKT_SIZE_2d      <= 16'd0; 
            DUPLEX_PKT_SIZE_3d      <= 16'd0; 
            DUPLEX_PKT_SIZE_4d      <= 16'd0; 
            pending_pkt_4size     <= 16'd0;

        end
        else
        begin
            tx_rdyout_d            <= tx_rdyout;
            tx_ovfout_d            <= tx_ovfout;
            tx_unfout_d            <= tx_unfout;
            start_prbs_1d          <= start_prbs;
            start_prbs_2d          <= start_prbs_1d;
            start_prbs_3d          <= start_prbs_2d;
            start_prbs_4d          <= start_prbs_3d;
            stop_prbs_1d          <= stop_prbs;
            stop_prbs_2d          <= stop_prbs_1d;
            stop_prbs_3d          <= stop_prbs_2d;
            stop_prbs_4d          <= stop_prbs_3d;
            DUPLEX_PKT_SIZE_1d     <= DUPLEX_PKT_SIZE; 
            DUPLEX_PKT_SIZE_2d     <= DUPLEX_PKT_SIZE_1d; 
            DUPLEX_PKT_SIZE_3d     <= DUPLEX_PKT_SIZE_2d; 
            DUPLEX_PKT_SIZE_4d     <= DUPLEX_PKT_SIZE_3d; 
            pending_pkt_4size     <= lbus_pkt_size_proc - 16'd4;

        end
    end

    ////////////////////////////////////////////////
    //generating the start prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        init_done   <= 1'b0; 
        else
        begin
            if  (start_prbs_3d && ~start_prbs_4d) 
	            init_done <= 1'b1;
	    else 
	            init_done <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the stop prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        stop_prbs_edge   <= 1'b0; 
        else
        begin
            if  (stop_prbs_3d && ~stop_prbs_4d) 
	            stop_prbs_edge <= 1'b1;
	    else 
	            stop_prbs_edge <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the len type edge signal 
    ////////////////////////////////////////////////
    always @(posedge clk) begin
        LEN_TYPE_FIELD <= 16'h0800; //IPv4
    end
    ////////////////////////////////////////////////
    //State Machine Combo logic
    ////////////////////////////////////////////////
    always @( * )
    begin
        case (tx_prestate)
	    STATE_TX_IDLE            : begin
                                      tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                 end

	    STATE_PKT_TRANSFER_INIT  : begin
                                       tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                       if  ((init_done == 1'b1) && (tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if (DUPLEX_PKT_SIZE_4d == 16'd0) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                           tx_nxtstate = STATE_LBUS_TX_ENABLE;   
                                         end 
                                       end
                                  end

	    STATE_LBUS_TX_ENABLE     : begin
                                     tx_nxtstate = STATE_LBUS_TX_ENABLE;
	                                   if ((tx_rdyout ==1'b1) && (tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                     end else if ((tx_rdyout == 1'b0) || (tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_HALT;
                                     end
                                end

	    STATE_LBUS_TX_HALT       : begin
                                       tx_nxtstate = STATE_LBUS_TX_HALT;
                                       if ((tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if ((tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                            tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                            tx_nxtstate = STATE_LBUS_TX_ENABLE;
                                         end
                                       end else if ((tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                       end
                                  end

	    STATE_LBUS_TX_DONE       : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end

	    default                  : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end
        endcase
    end

    ////////////////////////////////////////////////
    //Present State registers
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_prestate <= STATE_TX_IDLE;
        else
            tx_prestate <= tx_nxtstate;
    end

    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            nxt_eopin0             <= 1'b0;
            nxt_valid0             <= 1'b0;
            nxt_mtyin0             <= 8'd0;
            nxt_datain0            <= 64'd0;
            pending_pkt_size       <= 16'd0;
            tx_done_reg            <= 1'b0;
            tx_done_reg_d          <= 1'b0;
            tx_fsm_en              <= 1'b0;
            segment0_eop           <= 1'b0;
            first_pkt              <= 1'b0;
            second_pkt             <= 1'b0;
            third_pkt              <= 1'b0;
            fourth_pkt              <= 1'b0;
            tx_core_busy_led       <= 1'b0;
        end
        else
        begin
        case (tx_nxtstate)
            STATE_TX_IDLE            : 
                                     begin
                                         tx_core_busy_led       <= 1'b0;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop           <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b0;
                                         second_pkt             <= 1'b0;
                                         third_pkt              <= 1'b0;
                                         fourth_pkt              <= 1'b0;

                                     end
            STATE_PKT_TRANSFER_INIT  : 
	                             begin
                                         tx_core_busy_led       <= 1'b0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop             <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b1;
                                         second_pkt             <= 1'b0;
                                         third_pkt              <= 1'b0;
                                         fourth_pkt              <= 1'b0;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         pending_pkt_size      <= lbus_pkt_size_proc;
	                             end
            STATE_LBUS_TX_ENABLE     : 
	                             begin
                                         tx_core_busy_led       <= 1'b1;
					                              nxt_valid0      <= 1'b1;

                                         if (pending_pkt_size <= 16'd4)
                                         begin
                                             segment0_eop     <= 1'd1;    
                                         end
                                         else
                                         begin
                                             segment0_eop <= 1'd0;      
                                         end 

                                         if (first_pkt || nxt_eopin0)
                                         begin
                                             first_pkt        <= 1'b0;
                                             second_pkt       <= 1'b1;
                                             third_pkt       <= 1'b0;
                                             fourth_pkt       <= 1'b0;
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {32'd0,tx_mac_dest_addr[23:16],tx_mac_dest_addr[31:24],tx_mac_dest_addr[39:32],tx_mac_dest_addr[47:40]}; //DA SA
                                             nxt_mtyin0       <= 8'h0f;
                                             pending_pkt_size <= pending_pkt_size ;
                                         end

                                         else if (second_pkt)
                                         begin
                                             first_pkt        <= 1'b0;
                                             second_pkt       <= 1'b0;
                                             third_pkt        <= 1'b1;
                                             fourth_pkt       <= 1'b0;
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {32'd0,tx_mac_src_addr[39:32],tx_mac_src_addr[47:40],tx_mac_dest_addr[7:0],tx_mac_dest_addr[15:8]}; //DA SA
                                             nxt_mtyin0       <= 8'h0f;
                                             pending_pkt_size <= pending_pkt_size ;
                                         end

                                         else if (third_pkt)
                                         begin
                                             first_pkt        <= 1'b0;
                                             second_pkt       <= 1'b0;
                                             third_pkt        <= 1'b0;
                                             fourth_pkt       <= 1'b1;
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {32'd0,tx_mac_src_addr[7:0],tx_mac_src_addr[15:8],tx_mac_src_addr[23:16],tx_mac_src_addr[31:24]}; // SA LT
                                             nxt_mtyin0       <= 8'h0f;
                                             pending_pkt_size <= pending_pkt_size ;
                                         end

                                         else if (fourth_pkt)
                                         begin
                                             first_pkt        <= 1'b0;
                                             second_pkt       <= 1'b0;
                                             third_pkt        <= 1'b0;
                                             fourth_pkt       <= 1'b0;
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {32'd0,16'h0123,LEN_TYPE_FIELD[7:0],LEN_TYPE_FIELD[15:8]}; // SA LT
                                             nxt_mtyin0       <= 8'h0f;
	                                             if (pending_pkt_size > 4)
                                               pending_pkt_size <= pending_pkt_4size;
                                             else
                                               pending_pkt_size <= pending_pkt_size ;
                                         end

	                                          // EOP in Segment 0 
                                         else if (segment0_eop == 1'b1) 
                                         begin
                                             nxt_eopin0       <= 1'b1;
                                             nxt_datain0      <= {32'h0,payload_byte[31:0]};
                                             nxt_mtyin0       <= mtyin0_loc;

                                         
					                                   tx_done_reg      <= tx_done_reg_c;
                                             pending_pkt_size <= lbus_pkt_size_proc;
                                         end

				         // Default 64 byte packet
                                         else
                                         begin
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {32'h0,payload_byte[31:0]};
                                             nxt_mtyin0       <= 8'h0f;

					     if (pending_pkt_size <= 16'd4)
					       pending_pkt_size <= pending_pkt_4size; 
					     else
                                               pending_pkt_size <= pending_pkt_size - 16'd4; 
                                         end
                                   
                                         if (tx_done_reg== 1'b1)
                                             tx_fsm_en <= 1'b0;
                                         else
                                             tx_fsm_en <= 1'b1;
	                             end
            STATE_LBUS_TX_HALT       : 
	                             begin
					 nxt_valid0      <= 1'b1;
                                         tx_core_busy_led       <= 1'b1;
	                             end
					
            STATE_LBUS_TX_DONE       : 
	                             begin
		                         tx_done_reg_d          <= 1'b1;
		                         tx_fsm_en              <= 1'b0;
		                         first_pkt              <= 1'b0;
                                             second_pkt       <= 1'b0;
                                             third_pkt        <= 1'b0;
                                             fourth_pkt       <= 1'b0;
                                         nxt_valid0             <= 1'b0;
                                         tx_core_busy_led       <= 1'b0;
				         nxt_eopin0             <= 1'b0;

	                             end
            default                  : 
	                             begin


                                         tx_core_busy_led       <= 1'b0;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop           <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b0;
                                         second_pkt              <= 1'b0;
                                         third_pkt              <= 1'b0;
                                         fourth_pkt              <= 1'b0;
                                         pending_pkt_size       <= 16'd0;

	                             end
            endcase		    
	end
    end

mrmac_0_prbs_32_2v31_x31_x28_2 i_mrmac_0_prbs_tx1 (
        .CE (tx_axis_tvalid_0 && tx_rdyout && !nxt_eopin0 && !second_pkt && !third_pkt && !fourth_pkt),
        .R (~resetn),
        .C (clk),
        .Q (payload_byte[31:0])
        );



    ////////////////////////////////////////////////
    // mtyin signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 ) begin
            mtyin0_loc    <= 8'h00;
        end else begin
          if (tx_rdyout) begin 
           case (pending_pkt_size[2:0])
             3'd1: begin
               mtyin0_loc <= 8'h01;
             end
             3'd2: begin
               mtyin0_loc <= 8'h03;
             end
             3'd3: begin
               mtyin0_loc <= 8'h07;
             end
             default: begin
		           mtyin0_loc <= 8'h0f;
             end
           endcase
	      end
      end
    end

    ////////////////////////////////////////////////
    //tx_done_reg_c signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done_reg_c <= 1'b0;
        else
	        if (init_done)
        	    tx_done_reg_c <= 1'b0;
	        //else if  ((tx_fsm_en == 1'b1) & (number_pkt_tx == lbus_number_pkt_proc_1))
	        else if  (tx_fsm_en && stop_prbs_edge)
                    tx_done_reg_c <= 1'b1;
    end
    ////////////////////////////////////////////////
    //tx_done signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done <= 1'b0;
        else
        begin
            if (init_done)
                tx_done <= 1'b0;            
            else if  (tx_done_reg_d == 1'b1) 
                tx_done <= 1'b1;
        end
    end    
    /////////////////////////////////////////////////////////
    //lbus_number_pkt_proc signal generation 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            lbus_pkt_size_proc   <= 16'd0;
        end
        else
        begin
                lbus_pkt_size_proc   <= DUPLEX_PKT_SIZE_4d;
        end
    end       

    //Assign LBUS TX Output ports
    ////////////////////////////////////////////////

always @(*)
  begin
     tx_datain0  = nxt_datain0; 
     tx_eopin0   = nxt_eopin0;
     tx_axis_tvalid_0  = tx_eopin0 ? nxt_eopin0 : nxt_valid0;

     tx_mtyin0   = nxt_mtyin0;
  end

    ////////////////////////////////////////////////
    //Assign TX Output ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led          <= 1'b0;
            tx_busy_led          <= 1'b0;

        end
        else
        begin
            tx_done_led          <= tx_done_led_3d;
            tx_busy_led          <= tx_core_busy_led_3d;
        end
    end

    ////////////////////////////////////////////////
    //Registering the LED ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led_1d          <= 1'b0;
            tx_done_led_2d          <= 1'b0;
            tx_done_led_3d          <= 1'b0;
            tx_core_busy_led_1d     <= 1'b0;
            tx_core_busy_led_2d     <= 1'b0;
            tx_core_busy_led_3d     <= 1'b0;
        end
        else
        begin
            tx_done_led_1d          <= tx_done;
            tx_done_led_2d          <= tx_done_led_1d;
            tx_done_led_3d          <= tx_done_led_2d;
            tx_core_busy_led_1d     <= tx_core_busy_led;
            tx_core_busy_led_2d     <= tx_core_busy_led_1d;
            tx_core_busy_led_3d     <= tx_core_busy_led_2d;
	end
    end

    //----------------------------------------END TX Module-----------------------//
    

endmodule
/// 128 bit Gen
module mrmac_0_core_lbus_pkt_gen_128b
  (
     input 		 clk,
     input 		 resetn,

     // VIO controls
     input  [15:0] DUPLEX_PKT_SIZE,
     input wire [47:0]   tx_mac_dest_addr,
     input wire [47:0]   tx_mac_src_addr,

     output reg 	 tx_done_led,
     output reg 	 tx_busy_led,
     // VIO proc I/F

     input wire 	 tx_rdyout,
     output reg [64-1:0] tx_datain0,
     output reg 	 tx_eopin0,
     output reg [7:0]    tx_mtyin0,
     output reg [64-1:0] tx_datain1,
     output reg [7:0]    tx_mtyin1,

     input wire 	 tx_ovfout,
     input wire 	 tx_unfout,
     input wire    start_prbs,
     input wire    stop_prbs,

     //AXI additional signals
     output reg 	 tx_axis_tvalid_0
    );

    // pkt_gen States
    parameter STATE_TX_IDLE             = 0;
    parameter STATE_PKT_TRANSFER_INIT   = 1;
    parameter STATE_LBUS_TX_ENABLE      = 2;
    parameter STATE_LBUS_TX_HALT        = 3;
    parameter STATE_LBUS_TX_DONE        = 4;

    //State Registers for TX
    reg [3:0] tx_prestate, tx_nxtstate;

    reg [15:0] pending_pkt_size;
    reg [15:0] pending_pkt_16size;
    reg        first_pkt, tx_fsm_en;
    reg        tx_done_reg, tx_done_reg_c, tx_done_reg_d, rx_fail_reg;
    reg        tx_rdyout_d, tx_ovfout_d, tx_unfout_d;
    reg        start_prbs_1d, start_prbs_2d, start_prbs_3d, start_prbs_4d;
    reg        stop_prbs_1d, stop_prbs_2d, stop_prbs_3d, stop_prbs_4d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_1d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_2d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_3d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_4d;
    reg        segment0_eop;
    reg        nxt_eopin0, nxt_valid0;

    reg [ 7:0] mtyin0_loc;
    reg [ 7:0] mtyin1_loc;
    reg [64-1:0] nxt_datain0, nxt_datain1;
    reg [7:0] 	 nxt_mtyin0, nxt_mtyin1;
    wire [127:0] payload_byte;

    reg [15:0] lbus_pkt_size_proc;
    reg        init_done;
    reg        stop_prbs_edge;
    reg [15:0] LEN_TYPE_FIELD;
(* ASYNC_REG = "TRUE" *)    reg        tx_done, tx_core_busy_led;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_1d, tx_core_busy_led_1d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_2d, tx_core_busy_led_2d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_3d, tx_core_busy_led_3d;


    ////////////////////////////////////////////////
    //registering input signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_rdyout_d            <= 1'b0;
            tx_ovfout_d            <= 1'b0;
            tx_unfout_d            <= 1'b0;
            start_prbs_1d          <= 1'b0; 
            start_prbs_2d          <= 1'b0; 
            start_prbs_3d          <= 1'b0; 
            start_prbs_4d          <= 1'b0; 
            stop_prbs_1d          <= 1'b0; 
            stop_prbs_2d          <= 1'b0; 
            stop_prbs_3d          <= 1'b0; 
            stop_prbs_4d          <= 1'b0; 
            DUPLEX_PKT_SIZE_1d      <= 16'd0; 
            DUPLEX_PKT_SIZE_2d      <= 16'd0; 
            DUPLEX_PKT_SIZE_3d      <= 16'd0; 
            DUPLEX_PKT_SIZE_4d      <= 16'd0; 
            pending_pkt_16size     <= 16'd0;

        end
        else
        begin
            tx_rdyout_d            <= tx_rdyout;
            tx_ovfout_d            <= tx_ovfout;
            tx_unfout_d            <= tx_unfout;
            start_prbs_1d          <= start_prbs;
            start_prbs_2d          <= start_prbs_1d;
            start_prbs_3d          <= start_prbs_2d;
            start_prbs_4d          <= start_prbs_3d;
            stop_prbs_1d          <= stop_prbs;
            stop_prbs_2d          <= stop_prbs_1d;
            stop_prbs_3d          <= stop_prbs_2d;
            stop_prbs_4d          <= stop_prbs_3d;
            DUPLEX_PKT_SIZE_1d     <= DUPLEX_PKT_SIZE; 
            DUPLEX_PKT_SIZE_2d     <= DUPLEX_PKT_SIZE_1d; 
            DUPLEX_PKT_SIZE_3d     <= DUPLEX_PKT_SIZE_2d; 
            DUPLEX_PKT_SIZE_4d     <= DUPLEX_PKT_SIZE_3d; 
            pending_pkt_16size     <= lbus_pkt_size_proc - 16'd16;

        end
    end


    ////////////////////////////////////////////////
    //generating the start prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        init_done   <= 1'b0; 
        else
        begin
            if  (start_prbs_3d && ~start_prbs_4d) 
	            init_done <= 1'b1;
	    else 
	            init_done <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the stop prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        stop_prbs_edge   <= 1'b0; 
        else
        begin
            if  (stop_prbs_3d && ~stop_prbs_4d) 
	            stop_prbs_edge <= 1'b1;
	    else 
	            stop_prbs_edge <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the len type edge signal 
    ////////////////////////////////////////////////
    always @(posedge clk) begin
        LEN_TYPE_FIELD <= 16'h0800; //IPv4
    end
    ////////////////////////////////////////////////
    //State Machine Combo logic
    ////////////////////////////////////////////////
    always @( * )
    begin
        case (tx_prestate)
	    STATE_TX_IDLE            : begin
                                      tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                 end

	    STATE_PKT_TRANSFER_INIT  : begin
                                       tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                       if  ((init_done == 1'b1) && (tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if (DUPLEX_PKT_SIZE_4d == 16'd0) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                           tx_nxtstate = STATE_LBUS_TX_ENABLE;   
                                         end 
                                       end
                                  end

	    STATE_LBUS_TX_ENABLE     : begin
                                     tx_nxtstate = STATE_LBUS_TX_ENABLE;
	                                   if ((tx_rdyout ==1'b1) && (tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                     end else if ((tx_rdyout == 1'b0) || (tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_HALT;
                                     end
                                end

	    STATE_LBUS_TX_HALT       : begin
                                       tx_nxtstate = STATE_LBUS_TX_HALT;
                                       if ((tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if ((tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                            tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                            tx_nxtstate = STATE_LBUS_TX_ENABLE;
                                         end
                                       end else if ((tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                       end
                                  end

	    STATE_LBUS_TX_DONE       : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end

	    default                  : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end
        endcase
    end

    ////////////////////////////////////////////////
    //Present State registers
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_prestate <= STATE_TX_IDLE;
        else
            tx_prestate <= tx_nxtstate;
    end

    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            nxt_eopin0             <= 1'b0;
            nxt_valid0             <= 1'b0;
            nxt_mtyin0             <= 8'd0;
            nxt_mtyin1             <= 8'd0;
            nxt_datain0            <= 64'd0;
            nxt_datain1            <= 64'd0;
            pending_pkt_size       <= 16'd0;
            tx_done_reg            <= 1'b0;
            tx_done_reg_d          <= 1'b0;
            tx_fsm_en              <= 1'b0;
            segment0_eop           <= 1'b0;
            first_pkt              <= 1'b0;
            tx_core_busy_led       <= 1'b0;
        end
        else
        begin
        case (tx_nxtstate)
            STATE_TX_IDLE            : 
                                     begin
                                         tx_core_busy_led       <= 1'b0;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_mtyin1             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         nxt_datain1            <= 64'd0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop           <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b0;
                                         pending_pkt_size       <= 16'd0;
                                     end

            STATE_PKT_TRANSFER_INIT  : 
	                             begin
                                         tx_core_busy_led       <= 1'b0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop             <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b1;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_mtyin1             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         nxt_datain1            <= 64'd0;
                                         pending_pkt_size      <= lbus_pkt_size_proc;
	                             end
            STATE_LBUS_TX_ENABLE     : 
	                             begin
                                         tx_core_busy_led       <= 1'b1;
					                              nxt_valid0      <= 1'b1;

                                         if (pending_pkt_size <= 16'd16)
                                         begin
                                             segment0_eop     <= 1'd1;    
                                         end
                                         else
                                         begin
                                             segment0_eop <= 1'd0;      
                                         end 


	                                       if (first_pkt == 1'b1)
                                         begin
                                             first_pkt        <= 1'b0;
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {tx_mac_src_addr[39:32],tx_mac_src_addr[47:40],tx_mac_dest_addr[7:0],tx_mac_dest_addr[15:8],tx_mac_dest_addr[23:16],tx_mac_dest_addr[31:24],tx_mac_dest_addr[39:32],tx_mac_dest_addr[47:40]}; //DA SA
                                             nxt_mtyin0       <= 8'hff;
                  
                                             nxt_datain1      <= { 16'h0123,LEN_TYPE_FIELD[7:0],LEN_TYPE_FIELD[15:8],tx_mac_src_addr[7:0],tx_mac_src_addr[15:8],tx_mac_src_addr[23:16],tx_mac_src_addr[31:24]}; // SA LT  
                                             nxt_mtyin1       <= 8'hff;

                                             if (pending_pkt_size > 16)
                                               pending_pkt_size <= pending_pkt_16size;
                                             else
                                               pending_pkt_size <= pending_pkt_size ;
                                         end	            

                                         else if (nxt_eopin0 == 1'b1)  //new packet
                                         begin
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {tx_mac_src_addr[39:32],tx_mac_src_addr[47:40],tx_mac_dest_addr[7:0],tx_mac_dest_addr[15:8],tx_mac_dest_addr[23:16],tx_mac_dest_addr[31:24],tx_mac_dest_addr[39:32],tx_mac_dest_addr[47:40]}; //DA SA
                                             nxt_mtyin0       <= 8'hff;
                                              
                                             nxt_datain1      <= { 16'h0123,LEN_TYPE_FIELD[7:0],LEN_TYPE_FIELD[15:8],tx_mac_src_addr[7:0],tx_mac_src_addr[15:8],tx_mac_src_addr[23:16],tx_mac_src_addr[31:24]}; // SA LT
                                             nxt_mtyin1       <= 8'hff;

                                             if (pending_pkt_size > 16)
                                               pending_pkt_size <= pending_pkt_16size;
                                             else
                                               pending_pkt_size <= pending_pkt_size ;
                                           
                                         end

                                         else if (segment0_eop == 1'b1) 
                                         begin
                                             nxt_eopin0       <= 1'b1;
                                             nxt_datain0      <= payload_byte[63:0];
                                             nxt_mtyin0       <= mtyin0_loc;

                                             nxt_datain1      <= payload_byte[127:64];
                                             nxt_mtyin1       <= mtyin1_loc;

                                         
					                                   tx_done_reg      <= tx_done_reg_c;
                                             pending_pkt_size <= lbus_pkt_size_proc;
                                         end

				         // Default 64 byte packet
                                         else
                                         begin
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= payload_byte[63:0];
                                             nxt_mtyin0       <= 8'hff;

                                             nxt_datain1      <= payload_byte[127:64];
                                             nxt_mtyin1       <= 8'hff;

					                                   if (pending_pkt_size <= 16'd16)
                              					       pending_pkt_size <= pending_pkt_16size; 
					                                   else
                                               pending_pkt_size <= pending_pkt_size - 16'd16; 
                                         end
                                   
                                         if (tx_done_reg== 1'b1)
                                             tx_fsm_en <= 1'b0;
                                         else
                                             tx_fsm_en <= 1'b1;
	                             end
            STATE_LBUS_TX_HALT       : 
	                             begin
					                       nxt_valid0      <= 1'b1;
                                         tx_core_busy_led       <= 1'b1;
                               end
					
            STATE_LBUS_TX_DONE       : 
	                             begin
		                         tx_done_reg_d          <= 1'b1;
		                         tx_fsm_en              <= 1'b0;
		                         first_pkt              <= 1'b0;
                                         nxt_valid0             <= 1'b0;
                                         tx_core_busy_led       <= 1'b0;
				         nxt_eopin0             <= 1'b0;

	                             end
            default                  : 
	                             begin
                                         tx_core_busy_led       <= 1'b0;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_mtyin1             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         nxt_datain1            <= 64'd0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop           <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b0;
                                         pending_pkt_size       <= 16'd0;

	                             end
            endcase		    
	end
    end

mrmac_0_prbs_128_2v31_x31_x28_2 i_mrmac_0_prbs_tx (
        .CE (tx_axis_tvalid_0 && tx_rdyout && !nxt_eopin0),
        .R (~resetn),
        .C (clk),
        .Q (payload_byte[127:0])
        );



    ////////////////////////////////////////////////
    // mtyin signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 ) begin
            mtyin0_loc    <= 8'h00;
            mtyin1_loc    <= 8'h00;
        end else begin
          if (tx_rdyout) begin 
           case (pending_pkt_size[4:0])
             5'd1: begin
               mtyin0_loc <= 8'h01;
		           mtyin1_loc <= 8'h00;
             end
             5'd2: begin
               mtyin0_loc <= 8'h03;
		           mtyin1_loc <= 8'h00;
             end
             5'd3: begin
               mtyin0_loc <= 8'h07;
		           mtyin1_loc <= 8'h00;
             end
             5'd4: begin
               mtyin0_loc <= 8'h0f;
		           mtyin1_loc <= 8'h00;
             end
             5'd5: begin
               mtyin0_loc <= 8'h1f;
		           mtyin1_loc <= 8'h00;
             end
             5'd6: begin
               mtyin0_loc <= 8'h3f;
		           mtyin1_loc <= 8'h00;
             end
             5'd7: begin
               mtyin0_loc <= 8'h7f;
		           mtyin1_loc <= 8'h00;
             end
             5'd8: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h00;
             end
             5'd9: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h01;
             end
             5'd10: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h03;
             end
             5'd11: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h07;
             end
             5'd12: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h0f;
             end
             5'd13: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h1f;
             end
             5'd14: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'h3f;
             end
             5'd15: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'h7f;
             end
             default: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
             end
           endcase
	      end
      end
    end

    ////////////////////////////////////////////////
    //tx_done_reg_c signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done_reg_c <= 1'b0;
        else
	        if (init_done)
        	    tx_done_reg_c <= 1'b0;
	        //else if  ((tx_fsm_en == 1'b1) & (number_pkt_tx == lbus_number_pkt_proc_1))
	        else if  (tx_fsm_en && stop_prbs_edge)
                    tx_done_reg_c <= 1'b1;
    end
    ////////////////////////////////////////////////
    //tx_done signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done <= 1'b0;
        else
        begin
            if (init_done)
                tx_done <= 1'b0;            
            else if  (tx_done_reg_d == 1'b1) 
                tx_done <= 1'b1;
        end
    end    

    /////////////////////////////////////////////////////////
    //lbus_number_pkt_proc signal generation 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            lbus_pkt_size_proc   <= 16'd0;
        end
        else
        begin
           lbus_pkt_size_proc   <= DUPLEX_PKT_SIZE_4d;
        end
    end       

    //Assign LBUS TX Output ports
    ////////////////////////////////////////////////

always @(*)
  begin
     tx_datain0  = nxt_datain0; 
     tx_eopin0   = nxt_eopin0;
     tx_axis_tvalid_0  = tx_eopin0 ? nxt_eopin0 : nxt_valid0;

     tx_mtyin0   = nxt_mtyin0;
     tx_mtyin1   = nxt_mtyin1;
     
     tx_datain1  = nxt_datain1;
  end

    ////////////////////////////////////////////////
    //Assign TX Output ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led          <= 1'b0;
            tx_busy_led          <= 1'b0;

        end
        else
        begin
            tx_done_led          <= tx_done_led_3d;
            tx_busy_led          <= tx_core_busy_led_3d;
        end
    end

    ////////////////////////////////////////////////
    //Registering the LED ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led_1d          <= 1'b0;
            tx_done_led_2d          <= 1'b0;
            tx_done_led_3d          <= 1'b0;
            tx_core_busy_led_1d     <= 1'b0;
            tx_core_busy_led_2d     <= 1'b0;
            tx_core_busy_led_3d     <= 1'b0;
        end
        else
        begin
            tx_done_led_1d          <= tx_done;
            tx_done_led_2d          <= tx_done_led_1d;
            tx_done_led_3d          <= tx_done_led_2d;
            tx_core_busy_led_1d     <= tx_core_busy_led;
            tx_core_busy_led_2d     <= tx_core_busy_led_1d;
            tx_core_busy_led_3d     <= tx_core_busy_led_2d;
	end
    end

    //----------------------------------------END TX Module-----------------------//
    

endmodule


//// 256b
module mrmac_0_core_lbus_pkt_gen_256b
   (
     input 		 clk,
     input 		 resetn,

     // VIO controls
     input  [15:0] DUPLEX_PKT_SIZE,
     input wire [47:0]   tx_mac_dest_addr,
     input wire [47:0]   tx_mac_src_addr,

     output reg 	 tx_done_led,
     output reg 	 tx_busy_led,
     // VIO proc I/F

     input wire 	 tx_rdyout,
     output reg [64-1:0] tx_datain0,
     output reg 	 tx_eopin0,
     output reg [7:0]    tx_mtyin0,
     output reg [64-1:0] tx_datain1,
     output reg [7:0]    tx_mtyin1,
     output reg [64-1:0] tx_datain2,
     output reg [7:0]    tx_mtyin2,
     output reg [64-1:0] tx_datain3,
     output reg [7:0]    tx_mtyin3,
     output wire [3:0]    state,

     input wire 	 tx_ovfout,
     input wire 	 tx_unfout,
     input wire    start_prbs,
     input wire    stop_prbs,

     //AXI additional signals
     output reg 	 tx_axis_tvalid_0
    );

    // pkt_gen States
    parameter STATE_TX_IDLE             = 0;
    parameter STATE_PKT_TRANSFER_INIT   = 1;
    parameter STATE_LBUS_TX_ENABLE      = 2;
    parameter STATE_LBUS_TX_HALT        = 3;
    parameter STATE_LBUS_TX_DONE        = 4;

    //State Registers for TX
    reg [3:0] tx_prestate, tx_nxtstate;

    reg [15:0] pending_pkt_size;
    reg [15:0] pending_pkt_32size;
    reg        first_pkt, tx_fsm_en;
    reg        tx_done_reg, tx_done_reg_c, tx_done_reg_d, rx_fail_reg;
    reg        tx_rdyout_d, tx_ovfout_d, tx_unfout_d;
    reg        start_prbs_1d, start_prbs_2d, start_prbs_3d, start_prbs_4d;
    reg        stop_prbs_1d, stop_prbs_2d, stop_prbs_3d, stop_prbs_4d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_1d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_2d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_3d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_4d;
    reg        segment0_eop;
    reg        nxt_eopin0, nxt_valid0;

    reg [ 7:0] mtyin0_loc;
    reg [ 7:0] mtyin1_loc;
    reg [ 7:0] mtyin2_loc;
    reg [ 7:0] mtyin3_loc;

    reg [64-1:0] nxt_datain0, nxt_datain1, nxt_datain2, nxt_datain3;
    reg [7:0] 	 nxt_mtyin0, nxt_mtyin1, nxt_mtyin2, nxt_mtyin3;

    reg [15:0] lbus_pkt_size_proc;
    reg        init_done;
    reg        stop_prbs_edge;
    reg [15:0] LEN_TYPE_FIELD;
    wire [255:0]  payload_byte;
(* ASYNC_REG = "TRUE" *)    reg        tx_done, tx_core_busy_led;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_1d, tx_core_busy_led_1d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_2d, tx_core_busy_led_2d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_3d, tx_core_busy_led_3d;


assign state = tx_prestate;
    ////////////////////////////////////////////////
    //registering input signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_rdyout_d            <= 1'b0;
            tx_ovfout_d            <= 1'b0;
            tx_unfout_d            <= 1'b0;
            start_prbs_1d          <= 1'b0; 
            start_prbs_2d          <= 1'b0; 
            start_prbs_3d          <= 1'b0; 
            start_prbs_4d          <= 1'b0; 
            stop_prbs_1d          <= 1'b0; 
            stop_prbs_2d          <= 1'b0; 
            stop_prbs_3d          <= 1'b0; 
            stop_prbs_4d          <= 1'b0; 
            DUPLEX_PKT_SIZE_1d      <= 16'd0; 
            DUPLEX_PKT_SIZE_2d      <= 16'd0; 
            DUPLEX_PKT_SIZE_3d      <= 16'd0; 
            DUPLEX_PKT_SIZE_4d      <= 16'd0; 
            pending_pkt_32size     <= 16'd0;

        end
        else
        begin
            tx_rdyout_d            <= tx_rdyout;
            tx_ovfout_d            <= tx_ovfout;
            tx_unfout_d            <= tx_unfout;
            start_prbs_1d          <= start_prbs;
            start_prbs_2d          <= start_prbs_1d;
            start_prbs_3d          <= start_prbs_2d;
            start_prbs_4d          <= start_prbs_3d;
            stop_prbs_1d          <= stop_prbs;
            stop_prbs_2d          <= stop_prbs_1d;
            stop_prbs_3d          <= stop_prbs_2d;
            stop_prbs_4d          <= stop_prbs_3d;
            DUPLEX_PKT_SIZE_1d     <= DUPLEX_PKT_SIZE; 
            DUPLEX_PKT_SIZE_2d     <= DUPLEX_PKT_SIZE_1d; 
            DUPLEX_PKT_SIZE_3d     <= DUPLEX_PKT_SIZE_2d; 
            DUPLEX_PKT_SIZE_4d     <= DUPLEX_PKT_SIZE_3d; 
            pending_pkt_32size     <= lbus_pkt_size_proc - 16'd32;

        end
    end


    ////////////////////////////////////////////////
    //generating the start prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        init_done   <= 1'b0; 
        else
        begin
            if  (start_prbs_3d && ~start_prbs_4d) 
	            init_done <= 1'b1;
	    else 
	            init_done <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the stop prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        stop_prbs_edge   <= 1'b0; 
        else
        begin
            if  (stop_prbs_3d && ~stop_prbs_4d) 
	            stop_prbs_edge <= 1'b1;
	    else 
	            stop_prbs_edge <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the len type edge signal 
    ////////////////////////////////////////////////
    always @(posedge clk) begin
        LEN_TYPE_FIELD <= 16'h0800; //IPv4
    end
    ////////////////////////////////////////////////
    //State Machine Combo logic
    ////////////////////////////////////////////////
    always @( * )
    begin
        case (tx_prestate)
	    STATE_TX_IDLE            : begin
                                      tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                 end

	    STATE_PKT_TRANSFER_INIT  : begin
                                       tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                       if  ((init_done == 1'b1) && (tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if (DUPLEX_PKT_SIZE_4d == 16'd0) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                           tx_nxtstate = STATE_LBUS_TX_ENABLE;   
                                         end 
                                       end
                                  end

	    STATE_LBUS_TX_ENABLE     : begin
                                     tx_nxtstate = STATE_LBUS_TX_ENABLE;
	                                   if ((tx_rdyout ==1'b1) && (tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                     end else if ((tx_rdyout == 1'b0) || (tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_HALT;
                                     end
                                end

	    STATE_LBUS_TX_HALT       : begin
                                       tx_nxtstate = STATE_LBUS_TX_HALT;
                                       if ((tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if ((tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                            tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                            tx_nxtstate = STATE_LBUS_TX_ENABLE;
                                         end
                                       end else if ((tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                       end
                                  end

	    STATE_LBUS_TX_DONE       : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end

	    default                  : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end
        endcase
    end

    ////////////////////////////////////////////////
    //Present State registers
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_prestate <= STATE_TX_IDLE;
        else
            tx_prestate <= tx_nxtstate;
    end

    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            nxt_eopin0             <= 1'b0;
            nxt_valid0             <= 1'b0;
            nxt_mtyin0             <= 8'd0;
            nxt_mtyin1             <= 8'd0;
            nxt_mtyin2             <= 8'd0;
            nxt_mtyin3             <= 8'd0;
            nxt_datain0            <= 64'd0;
            nxt_datain1            <= 64'd0;
            nxt_datain2            <= 64'd0;
            nxt_datain3            <= 64'd0;
            pending_pkt_size       <= 16'd0;
            tx_done_reg            <= 1'b0;
            tx_done_reg_d          <= 1'b0;
            tx_fsm_en              <= 1'b0;
            segment0_eop           <= 1'b0;
            first_pkt              <= 1'b0;
            tx_core_busy_led       <= 1'b0;
        end
        else
        begin
        case (tx_nxtstate)
            STATE_TX_IDLE            : 
                                     begin
                                         tx_core_busy_led       <= 1'b0;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_mtyin1             <= 8'd0;
                                         nxt_mtyin2             <= 8'd0;
                                         nxt_mtyin3             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         nxt_datain1            <= 64'd0;
                                         nxt_datain2            <= 64'd0;
                                         nxt_datain3            <= 64'd0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop           <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b0;
                                         pending_pkt_size       <= 16'd0;
                                     end

            STATE_PKT_TRANSFER_INIT  : 
	                             begin
                                         tx_core_busy_led       <= 1'b0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop             <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b1;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_mtyin1             <= 8'd0;
                                         nxt_mtyin2             <= 8'd0;
                                         nxt_mtyin3             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         nxt_datain1            <= 64'd0;
                                         nxt_datain2            <= 64'd0;
                                         nxt_datain3            <= 64'd0;
                                         pending_pkt_size      <= lbus_pkt_size_proc;
	                             end
            STATE_LBUS_TX_ENABLE     : 
	                             begin
                                         tx_core_busy_led       <= 1'b1;
					                              nxt_valid0      <= 1'b1;

                                         if (pending_pkt_size <= 16'd32)
                                         begin
                                             segment0_eop     <= 1'd1;    
                                         end
                                         else
                                         begin
                                             segment0_eop <= 1'd0;      
                                         end 


	                                       if (first_pkt == 1'b1)
                                         begin
                                             first_pkt        <= 1'b0;
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {tx_mac_src_addr[39:32],tx_mac_src_addr[47:40],tx_mac_dest_addr[7:0],tx_mac_dest_addr[15:8],tx_mac_dest_addr[23:16],tx_mac_dest_addr[31:24],tx_mac_dest_addr[39:32],tx_mac_dest_addr[47:40]}; //DA SA
                                             nxt_mtyin0       <= 8'hff;
                  
                                             nxt_datain1      <= { 16'h0123,LEN_TYPE_FIELD[7:0],LEN_TYPE_FIELD[15:8],tx_mac_src_addr[7:0],tx_mac_src_addr[15:8],tx_mac_src_addr[23:16],tx_mac_src_addr[31:24]}; // SA LT  
                                             nxt_mtyin1       <= 8'hff;

                                             nxt_datain2      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin2       <= 8'hff;

                                             nxt_datain3      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin3       <= 8'hff;

                                             if (pending_pkt_size > 32)
                                               pending_pkt_size <= pending_pkt_32size;
                                             else
                                               pending_pkt_size <= pending_pkt_size ;
                                         end	                                  

                                         else if (nxt_eopin0 == 1'b1)  //new packet
                                         begin
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {tx_mac_src_addr[39:32],tx_mac_src_addr[47:40],tx_mac_dest_addr[7:0],tx_mac_dest_addr[15:8],tx_mac_dest_addr[23:16],tx_mac_dest_addr[31:24],tx_mac_dest_addr[39:32],tx_mac_dest_addr[47:40]}; //DA SA
                                             nxt_mtyin0       <= 8'hff;
                                              
                                             nxt_datain1      <= { 16'h0123,LEN_TYPE_FIELD[7:0],LEN_TYPE_FIELD[15:8],tx_mac_src_addr[7:0],tx_mac_src_addr[15:8],tx_mac_src_addr[23:16],tx_mac_src_addr[31:24]}; // SA LT
                                             nxt_mtyin1       <= 8'hff;

                                             nxt_datain2      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin2       <= 8'hff;

                                             nxt_datain3      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin3       <= 8'hff;
                                             if (pending_pkt_size > 32)
                                               pending_pkt_size <= pending_pkt_32size;
                                             else
                                               pending_pkt_size <= pending_pkt_size ;
                                           
                                         end

                                         else if (segment0_eop == 1'b1) 
                                         begin
                                             nxt_eopin0       <= 1'b1;
                                             nxt_datain0      <= payload_byte[63:0];
                                             nxt_mtyin0       <= mtyin0_loc;

                                             nxt_datain1      <= payload_byte[127:64];
                                             nxt_mtyin1       <= mtyin1_loc;

                                             nxt_datain2      <= payload_byte[191:128];
                                             nxt_mtyin2       <= mtyin2_loc;

                                             nxt_datain3      <= payload_byte[255:192];
                                             nxt_mtyin3       <= mtyin3_loc;

					                                   tx_done_reg      <= tx_done_reg_c;
                                             pending_pkt_size <= lbus_pkt_size_proc;
                                         end

				         // Default 64 byte packet
                                         else
                                         begin
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= payload_byte[63:0];
                                             nxt_mtyin0       <= 8'hff;

                                             nxt_datain1      <= payload_byte[127:64];
                                             nxt_mtyin1       <= 8'hff;

                                             nxt_datain2      <= payload_byte[191:128];
                                             nxt_mtyin2       <= 8'hff;

                                             nxt_datain3      <= payload_byte[255:192];
                                             nxt_mtyin3       <= 8'hff;

					     if (pending_pkt_size <= 16'd32)
					       pending_pkt_size <= pending_pkt_32size; 
					     else
                                               pending_pkt_size <= pending_pkt_size - 16'd32; 
                                         end
                                   
                                         if (tx_done_reg== 1'b1)
                                             tx_fsm_en <= 1'b0;
                                         else
                                             tx_fsm_en <= 1'b1;
	                             end
            STATE_LBUS_TX_HALT       : 
	                             begin
					                       nxt_valid0      <= 1'b1;
                                         tx_core_busy_led       <= 1'b1;
                               end
					
            STATE_LBUS_TX_DONE       : 
	                             begin
		                         tx_done_reg_d          <= 1'b1;
		                         tx_fsm_en              <= 1'b0;
		                         first_pkt              <= 1'b0;
                                         nxt_valid0             <= 1'b0;
				         nxt_eopin0             <= 1'b0;
                                         tx_core_busy_led       <= 1'b0;

	                             end

            default                  : 
	                             begin
                                         tx_core_busy_led       <= 1'b0;
                                         nxt_eopin0             <= 1'b0;
					                               nxt_valid0             <= 1'b0;
                                         nxt_mtyin0             <= 8'd0;
                                         nxt_mtyin1             <= 8'd0;
                                         nxt_mtyin2             <= 8'd0;
                                         nxt_mtyin3             <= 8'd0;
                                         nxt_datain0            <= 64'd0;
                                         nxt_datain1            <= 64'd0;
                                         nxt_datain2            <= 64'd0;
                                         nxt_datain3            <= 64'd0;
                                         tx_fsm_en              <= 1'b0;
                                         segment0_eop           <= 1'b0;  
                                         tx_done_reg            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         first_pkt              <= 1'b0;
                                         pending_pkt_size       <= 16'd0;
	                             end
            endcase		    
	end
    end

 mrmac_0_prbs_256_2v31_x31_x28_2  mrmac_0_prbs_tx (
        .CE (tx_axis_tvalid_0 && tx_rdyout && !nxt_eopin0),
        .R (~resetn),
        .C (clk),
        .Q (payload_byte[255:0])
        );



    ////////////////////////////////////////////////
    // mtyin signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 ) begin
            mtyin0_loc    <= 8'h00;
            mtyin1_loc    <= 8'h00;
            mtyin2_loc    <= 8'h00;
            mtyin3_loc    <= 8'h00;
        end else begin
          if (tx_rdyout) begin 
           case (pending_pkt_size[5:0])
             6'd1: begin
               mtyin0_loc <= 8'h01;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd2: begin
               mtyin0_loc <= 8'h03;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd3: begin
               mtyin0_loc <= 8'h07;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd4: begin
               mtyin0_loc <= 8'h0f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd5: begin
               mtyin0_loc <= 8'h1f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd6: begin
               mtyin0_loc <= 8'h3f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd7: begin
               mtyin0_loc <= 8'h7f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd8: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd9: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h01;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd10: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h03;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd11: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h07;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd12: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h0f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd13: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h1f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd14: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'h3f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd15: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'h7f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd16: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
             end
             6'd17: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h01;
		           mtyin3_loc <= 8'h00;
             end
             6'd18: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h03;
		           mtyin3_loc <= 8'h00;
             end
             6'd19: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h07;
		           mtyin3_loc <= 8'h00;
             end
             6'd20: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h0f;
		           mtyin3_loc <= 8'h00;
             end
             6'd21: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h1f;
		           mtyin3_loc <= 8'h00;
             end
             6'd22: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h3f;
		           mtyin3_loc <= 8'h00;
             end
             6'd23: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h7f;
		           mtyin3_loc <= 8'h00;
             end
             6'd24: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h00;
             end
             6'd25: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h01;
             end
             6'd26: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h03;
             end
             6'd27: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h07;
             end
             6'd28: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h0f;
             end
             6'd29: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h1f;
             end
             6'd30: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h3f;
             end
             6'd31: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h7f;
             end
             default: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
             end
           endcase
	      end
      end
    end

    ////////////////////////////////////////////////
    //tx_done_reg_c signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done_reg_c <= 1'b0;
        else
	        if (init_done)
        	    tx_done_reg_c <= 1'b0;
	        //else if  ((tx_fsm_en == 1'b1) & (number_pkt_tx == lbus_number_pkt_proc_1))
	        else if  (tx_fsm_en && stop_prbs_edge)
                    tx_done_reg_c <= 1'b1;
    end
    ////////////////////////////////////////////////
    //tx_done signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done <= 1'b0;
        else
        begin
            if (init_done)
                tx_done <= 1'b0;            
            else if  (tx_done_reg_d == 1'b1) 
                tx_done <= 1'b1;
        end
    end    

    /////////////////////////////////////////////////////////
    //lbus_number_pkt_proc signal generation 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            lbus_pkt_size_proc   <= 16'd0;
        end
        else
        begin
            lbus_pkt_size_proc   <= DUPLEX_PKT_SIZE_4d;
        end
    end       

    //Assign LBUS TX Output ports
    ////////////////////////////////////////////////

always @(*)
  begin
     tx_datain0  = nxt_datain0; 
     tx_eopin0   = nxt_eopin0;
     tx_axis_tvalid_0  = tx_eopin0 ? nxt_eopin0 : nxt_valid0;

     tx_mtyin0   = nxt_mtyin0;
     tx_mtyin1   = nxt_mtyin1;
     tx_mtyin2   = nxt_mtyin2;
     tx_mtyin3   = nxt_mtyin3;
     
     tx_datain1  = nxt_datain1;
     tx_datain2  = nxt_datain2;
     tx_datain3  = nxt_datain3;
  end

    ////////////////////////////////////////////////
    //Assign TX Output ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led          <= 1'b0;
            tx_busy_led          <= 1'b0;

        end
        else
        begin
            tx_done_led          <= tx_done_led_3d;
            tx_busy_led          <= tx_core_busy_led_3d;
        end
    end

    ////////////////////////////////////////////////
    //Registering the LED ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led_1d          <= 1'b0;
            tx_done_led_2d          <= 1'b0;
            tx_done_led_3d          <= 1'b0;
            tx_core_busy_led_1d     <= 1'b0;
            tx_core_busy_led_2d     <= 1'b0;
            tx_core_busy_led_3d     <= 1'b0;
        end
        else
        begin
            tx_done_led_1d          <= tx_done;
            tx_done_led_2d          <= tx_done_led_1d;
            tx_done_led_3d          <= tx_done_led_2d;
            tx_core_busy_led_1d     <= tx_core_busy_led;
            tx_core_busy_led_2d     <= tx_core_busy_led_1d;
            tx_core_busy_led_3d     <= tx_core_busy_led_2d;
	end
    end

    //----------------------------------------END TX Module-----------------------//
    

endmodule

/// 384b
module mrmac_0_core_lbus_pkt_gen_384b
   (
     input 		 clk,
     input 		 resetn,

     // VIO controls
     input  [15:0] DUPLEX_PKT_SIZE,
     input wire [47:0]   tx_mac_dest_addr,
     input wire [47:0]   tx_mac_src_addr,
     
     output reg 	 tx_done_led,
     output reg 	 tx_busy_led,
     // VIO proc I/F

     input wire 	 tx_rdyout,
     output reg [64-1:0] tx_datain0,
     output reg 	 tx_eopin0,
     output reg [7:0]    tx_mtyin0,
     output reg [64-1:0] tx_datain1,
     output reg [7:0]    tx_mtyin1,
     output reg [64-1:0] tx_datain2,
     output reg [7:0]    tx_mtyin2,
     output reg [64-1:0] tx_datain3,
     output reg [7:0]    tx_mtyin3,
     output reg [64-1:0] tx_datain4,
     output reg [7:0]    tx_mtyin4,
     output reg [64-1:0] tx_datain5,
     output reg [7:0]    tx_mtyin5,

     input wire 	 tx_ovfout,
     input wire 	 tx_unfout,
     input wire    start_prbs,
     input wire    stop_prbs,

     //AXI additional signals
     output reg 	 tx_axis_tvalid_0
    );
   
    // pkt_gen States
    parameter STATE_TX_IDLE             = 0;
    parameter STATE_PKT_TRANSFER_INIT   = 1;
    parameter STATE_LBUS_TX_ENABLE      = 2;
    parameter STATE_LBUS_TX_HALT        = 3;
    parameter STATE_LBUS_TX_DONE        = 4;

    //State Registers for TX
    reg [3:0] tx_prestate, tx_nxtstate;

    reg [15:0] pending_pkt_size;
    reg [15:0] pending_pkt_48size;
    reg        first_pkt, tx_fsm_en;
    reg        tx_done_reg, tx_done_reg_c, tx_done_reg_d, rx_fail_reg;
    reg        tx_rdyout_d, tx_ovfout_d, tx_unfout_d;
    reg        start_prbs_1d, start_prbs_2d, start_prbs_3d, start_prbs_4d;
    reg        stop_prbs_1d, stop_prbs_2d, stop_prbs_3d, stop_prbs_4d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_1d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_2d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_3d;
(* ASYNC_REG = "TRUE" *)    reg [15:0] DUPLEX_PKT_SIZE_4d;

    reg        segment0_eop;
    reg        nxt_eopin0, nxt_valid0;

    reg [ 7:0] mtyin0_loc;
    reg [ 7:0] mtyin1_loc;
    reg [ 7:0] mtyin2_loc;
    reg [ 7:0] mtyin3_loc;
    reg [ 7:0] mtyin4_loc;
    reg [ 7:0] mtyin5_loc;

    reg [15:0] lbus_pkt_size_proc;
    reg        init_done;
    reg        stop_prbs_edge;
    reg [15:0] LEN_TYPE_FIELD;
    reg [64-1:0] nxt_datain0, nxt_datain1, nxt_datain2, nxt_datain3, nxt_datain4, nxt_datain5;
    wire [383:0] payload_byte;
    reg [7:0] 	 nxt_mtyin0, nxt_mtyin1, nxt_mtyin2, nxt_mtyin3, nxt_mtyin4, nxt_mtyin5;
(* ASYNC_REG = "TRUE" *)    reg        tx_done, tx_core_busy_led;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_1d, tx_core_busy_led_1d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_2d, tx_core_busy_led_2d;
(* ASYNC_REG = "TRUE" *)    reg        tx_done_led_3d, tx_core_busy_led_3d;

    ////////////////////////////////////////////////
    //registering input signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_rdyout_d            <= 1'b0;
            tx_ovfout_d            <= 1'b0;
            tx_unfout_d            <= 1'b0;
            start_prbs_1d          <= 1'b0; 
            start_prbs_2d          <= 1'b0; 
            start_prbs_3d          <= 1'b0; 
            start_prbs_4d          <= 1'b0; 
            stop_prbs_1d          <= 1'b0; 
            stop_prbs_2d          <= 1'b0; 
            stop_prbs_3d          <= 1'b0; 
            stop_prbs_4d          <= 1'b0; 
            DUPLEX_PKT_SIZE_1d      <= 16'd0; 
            DUPLEX_PKT_SIZE_2d      <= 16'd0; 
            DUPLEX_PKT_SIZE_3d      <= 16'd0; 
            DUPLEX_PKT_SIZE_4d      <= 16'd0; 
            pending_pkt_48size     <= 16'd0;
        end
        else
        begin
            tx_rdyout_d            <= tx_rdyout;
            tx_ovfout_d            <= tx_ovfout;
            tx_unfout_d            <= tx_unfout;
            start_prbs_1d          <= start_prbs;
            start_prbs_2d          <= start_prbs_1d;
            start_prbs_3d          <= start_prbs_2d;
            start_prbs_4d          <= start_prbs_3d;
            stop_prbs_1d          <= stop_prbs;
            stop_prbs_2d          <= stop_prbs_1d;
            stop_prbs_3d          <= stop_prbs_2d;
            stop_prbs_4d          <= stop_prbs_3d;
            DUPLEX_PKT_SIZE_1d     <= DUPLEX_PKT_SIZE; 
            DUPLEX_PKT_SIZE_2d     <= DUPLEX_PKT_SIZE_1d; 
            DUPLEX_PKT_SIZE_3d     <= DUPLEX_PKT_SIZE_2d; 
            DUPLEX_PKT_SIZE_4d     <= DUPLEX_PKT_SIZE_3d; 
            pending_pkt_48size     <= lbus_pkt_size_proc - 16'd48;
        end
    end

    ////////////////////////////////////////////////
    //generating the start prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        init_done   <= 1'b0; 
        else
        begin
            if  (start_prbs_3d && ~start_prbs_4d) 
	            init_done <= 1'b1;
	    else 
	            init_done <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the stop prbs edge signal 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if  ( resetn == 1'b0 )
	        stop_prbs_edge   <= 1'b0; 
        else
        begin
            if  (stop_prbs_3d && ~stop_prbs_4d) 
	            stop_prbs_edge <= 1'b1;
	    else 
	            stop_prbs_edge <= 1'b0;
        end
    end

    ////////////////////////////////////////////////
    //generating the len type edge signal 
    ////////////////////////////////////////////////
    always @(posedge clk) begin
        LEN_TYPE_FIELD <= 16'h0800; //IPv4
    end


    ////////////////////////////////////////////////
    //State Machine Combo logic
    ////////////////////////////////////////////////
    always @( * )
    begin
        case (tx_prestate)
	    STATE_TX_IDLE            : begin
                                      tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                 end
	    STATE_PKT_TRANSFER_INIT  : begin
                                       tx_nxtstate = STATE_PKT_TRANSFER_INIT;
                                       if  ((init_done == 1'b1) && (tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if (DUPLEX_PKT_SIZE_4d == 16'd0) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                           tx_nxtstate = STATE_LBUS_TX_ENABLE;   
                                         end 
                                       end
                                  end

	    STATE_LBUS_TX_ENABLE     : begin
                                     tx_nxtstate = STATE_LBUS_TX_ENABLE;
	                                   if ((tx_rdyout ==1'b1) && (tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                     end else if ((tx_rdyout == 1'b0) || (tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_HALT;
                                     end
                                end

	    STATE_LBUS_TX_HALT       : begin
                                       tx_nxtstate = STATE_LBUS_TX_HALT;
                                       if ((tx_rdyout == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0)) begin
                                         if ((tx_done_reg_c == 1'b1) && (nxt_eopin0 == 1'b1)) begin
                                            tx_nxtstate = STATE_LBUS_TX_DONE;
                                         end else begin
                                            tx_nxtstate = STATE_LBUS_TX_ENABLE;
                                         end
                                       end else if ((tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1)) begin
                                           tx_nxtstate = STATE_LBUS_TX_DONE;
                                       end
                                  end

	    STATE_LBUS_TX_DONE       : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end

	    default                  : begin
                                           tx_nxtstate = STATE_TX_IDLE;
                                 end
        endcase
    end

    ////////////////////////////////////////////////
    //Present State registers
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_prestate <= STATE_TX_IDLE;
        else
            tx_prestate <= tx_nxtstate;
    end

    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            nxt_eopin0             <= 1'b0;
            nxt_valid0             <= 1'b0;
            nxt_mtyin0             <= 8'd0;
            nxt_mtyin1             <= 8'd0;
            nxt_mtyin2             <= 8'd0;
            nxt_mtyin3             <= 8'd0;
	          nxt_mtyin4             <= 8'd0;
	          nxt_mtyin5             <= 8'd0;
            nxt_datain0            <= 64'd0;
            nxt_datain1            <= 64'd0;
            nxt_datain2            <= 64'd0;
            nxt_datain3            <= 64'd0;
	          nxt_datain4            <= 64'd0;
	          nxt_datain5            <= 64'd0;
            pending_pkt_size       <= 16'd0;
            tx_done_reg            <= 1'b0;
            tx_done_reg_d          <= 1'b0;
            tx_fsm_en              <= 1'b0;
            segment0_eop           <= 1'b0;
            first_pkt              <= 1'b0;
            tx_core_busy_led       <= 1'b0;
        end
        else
        begin
        case (tx_nxtstate)
            STATE_TX_IDLE            : 
                                     begin
                                        nxt_eopin0             <= 1'b0;
                                        nxt_valid0             <= 1'b0;
                                        nxt_mtyin0             <= 8'd0;
                                        nxt_mtyin1             <= 8'd0;
                                        nxt_mtyin2             <= 8'd0;
                                        nxt_mtyin3             <= 8'd0;
                            	          nxt_mtyin4             <= 8'd0;
                            	          nxt_mtyin5             <= 8'd0;
                                        nxt_datain0            <= 64'd0;
                                        nxt_datain1            <= 64'd0;
                                        nxt_datain2            <= 64'd0;
                                        nxt_datain3            <= 64'd0;
                            	          nxt_datain4            <= 64'd0;
                            	          nxt_datain5            <= 64'd0;
                                        pending_pkt_size       <= 16'd0;
                                        tx_done_reg            <= 1'b0;
                                        tx_done_reg_d          <= 1'b0;
                                        tx_fsm_en              <= 1'b0;
                                        segment0_eop           <= 1'b0;
                                        first_pkt              <= 1'b0;
                                        tx_core_busy_led       <= 1'b0;

                                     end
            STATE_PKT_TRANSFER_INIT  : 
	                             begin
                                        nxt_eopin0             <= 1'b0;
                                        nxt_valid0             <= 1'b0;
                                        nxt_mtyin0             <= 8'd0;
                                        nxt_mtyin1             <= 8'd0;
                                        nxt_mtyin2             <= 8'd0;
                                        nxt_mtyin3             <= 8'd0;
                            	          nxt_mtyin4             <= 8'd0;
                            	          nxt_mtyin5             <= 8'd0;
                                        nxt_datain0            <= 64'd0;
                                        nxt_datain1            <= 64'd0;
                                        nxt_datain2            <= 64'd0;
                                        nxt_datain3            <= 64'd0;
                            	          nxt_datain4            <= 64'd0;
                            	          nxt_datain5            <= 64'd0;
                                        pending_pkt_size       <= lbus_pkt_size_proc;
                                        tx_done_reg            <= 1'b0;
                                        tx_done_reg_d          <= 1'b0;
                                        tx_fsm_en              <= 1'b0;
                                        segment0_eop           <= 1'b0;
                                        first_pkt              <= 1'b1;
                                        tx_core_busy_led       <= 1'b0;
 	                             end
            STATE_LBUS_TX_ENABLE     : 
	                             begin
                                         tx_core_busy_led       <= 1'b1;
					                               nxt_valid0      <= 1'b1;

                                         if (pending_pkt_size <= 8'd48)
                                         begin
                                             segment0_eop     <= 1'd1;    
                                         end
                                         else
                                         begin
                                             segment0_eop <= 1'd0;      
                                         end 


                                         if (first_pkt == 1'b1)
                                         begin
                                             first_pkt        <= 1'b0;
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {tx_mac_src_addr[39:32],tx_mac_src_addr[47:40],tx_mac_dest_addr[7:0],tx_mac_dest_addr[15:8],tx_mac_dest_addr[23:16],tx_mac_dest_addr[31:24],tx_mac_dest_addr[39:32],tx_mac_dest_addr[47:40]}; //DA SA
                                             nxt_mtyin0       <= 8'hff;
                  
                                             nxt_datain1      <= { 16'h0123,LEN_TYPE_FIELD[7:0],LEN_TYPE_FIELD[15:8],tx_mac_src_addr[7:0],tx_mac_src_addr[15:8],tx_mac_src_addr[23:16],tx_mac_src_addr[31:24]}; // SA LT  
                                             nxt_mtyin1       <= 8'hff;

                                             nxt_datain2      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin2       <= 8'hff;

                                             nxt_datain3      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin3       <= 8'hff;
                                             
                                             nxt_datain4      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin4       <= 8'hff;
                                             
                                             nxt_datain5      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin5       <= 8'hff;

                                             if (pending_pkt_size > 48)
                                               pending_pkt_size <= pending_pkt_48size;
                                             else
                                               pending_pkt_size <= pending_pkt_size ;

                                         end

                                         else if (nxt_eopin0 == 1'b1)  //new packet
                                         begin
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= {tx_mac_src_addr[39:32],tx_mac_src_addr[47:40],tx_mac_dest_addr[7:0],tx_mac_dest_addr[15:8],tx_mac_dest_addr[23:16],tx_mac_dest_addr[31:24],tx_mac_dest_addr[39:32],tx_mac_dest_addr[47:40]}; //DA SA
                                             nxt_mtyin0       <= 8'hff;
                                              
                                             nxt_datain1      <= { 16'h0123,LEN_TYPE_FIELD[7:0],LEN_TYPE_FIELD[15:8],tx_mac_src_addr[7:0],tx_mac_src_addr[15:8],tx_mac_src_addr[23:16],tx_mac_src_addr[31:24]}; // SA LT
                                             nxt_mtyin1       <= 8'hff;

                                             nxt_datain2      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin2       <= 8'hff;

                                             nxt_datain3      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin3       <= 8'hff;
                                             
                                             nxt_datain4      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin4       <= 8'hff;
                                             
                                             nxt_datain5      <= 64'h0123_0123_0123_0123;
                                             nxt_mtyin5       <= 8'hff;
                                             if (pending_pkt_size > 48)
                                               pending_pkt_size <= pending_pkt_48size;
                                             else
                                               pending_pkt_size <= pending_pkt_size ;
                                           
                                         end

                                         else if (segment0_eop == 1'b1) 
                                         begin
                                             nxt_eopin0       <= 1'b1;
                                             nxt_datain0      <= payload_byte[63:0];
                                             nxt_mtyin0       <= mtyin0_loc;

                                             nxt_datain1      <= payload_byte[127:64];
                                             nxt_mtyin1       <= mtyin1_loc;

                                             nxt_datain2      <= payload_byte[191:128];
                                             nxt_mtyin2       <= mtyin2_loc;

                                             nxt_datain3      <= payload_byte[255:192];
                                             nxt_mtyin3       <= mtyin3_loc;

                                             nxt_datain4    <= payload_byte[319:256];
                                             nxt_mtyin4     <= mtyin4_loc;

                                             nxt_datain5    <= payload_byte[383:320];
                                             nxt_mtyin5     <= mtyin5_loc;
					                                   
                                             tx_done_reg      <= tx_done_reg_c;
                                             pending_pkt_size <= lbus_pkt_size_proc;
                                         end
				         // Default 64 byte packet
                                         else
                                         begin
                                             nxt_eopin0       <= 1'b0;
                                             nxt_datain0      <= payload_byte[63:0];
                                             nxt_mtyin0       <= 8'hff;

                                             nxt_datain1      <= payload_byte[127:64];
                                             nxt_mtyin1       <= 8'hff;

                                             nxt_datain2      <= payload_byte[191:128];
                                             nxt_mtyin2       <= 8'hff;

                                             nxt_datain3      <= payload_byte[255:192];
                                             nxt_mtyin3       <= 8'hff;

                                             nxt_datain4    <= payload_byte[319:256];
                                             nxt_mtyin4     <= 8'hff;

                                             nxt_datain5    <= payload_byte[383:320];
                                             nxt_mtyin5     <= 8'hff;

					     if (pending_pkt_size <= 8'd48)
					       pending_pkt_size <= pending_pkt_48size; 
					     else
                                               pending_pkt_size <= pending_pkt_size - 8'd48; 
                                         end
                                   
                                         if (tx_done_reg== 1'b1)
                                             tx_fsm_en <= 1'b0;
                                         else
                                             tx_fsm_en <= 1'b1;
	                             end
            STATE_LBUS_TX_HALT       : 
	                             begin
					 nxt_valid0      <= 1'b1;
                                         tx_core_busy_led       <= 1'b1;
	                             end
            STATE_LBUS_TX_DONE       : 
	                             begin
		                         tx_done_reg_d          <= 1'b1;
		                         tx_fsm_en              <= 1'b0;
		                         first_pkt              <= 1'b0;
                                         nxt_valid0             <= 1'b0;
                                         nxt_eopin0             <= 1'b0; 		                         
                                         tx_core_busy_led       <= 1'b0;
	                             end
            default                  : 
	                             begin
                                        nxt_eopin0             <= 1'b0;
                                        nxt_valid0             <= 1'b0;
                                        nxt_mtyin0             <= 8'd0;
                                        nxt_mtyin1             <= 8'd0;
                                        nxt_mtyin2             <= 8'd0;
                                        nxt_mtyin3             <= 8'd0;
                            	          nxt_mtyin4             <= 8'd0;
                            	          nxt_mtyin5             <= 8'd0;
                                        nxt_datain0            <= 64'd0;
                                        nxt_datain1            <= 64'd0;
                                        nxt_datain2            <= 64'd0;
                                        nxt_datain3            <= 64'd0;
                            	          nxt_datain4            <= 64'd0;
                            	          nxt_datain5            <= 64'd0;
                                        pending_pkt_size       <= 16'd0;
                                        tx_done_reg            <= 1'b0;
                                        tx_done_reg_d          <= 1'b0;
                                        tx_fsm_en              <= 1'b0;
                                        segment0_eop           <= 1'b0;
                                        first_pkt              <= 1'b0;
                                        tx_core_busy_led       <= 1'b0;

                       	       end
            endcase		    
	end
    end


mrmac_0_prbs_384_2v31_x31_x28_2 i_mrmac_0_prbs_tx (
        .CE (tx_axis_tvalid_0 && tx_rdyout && !nxt_eopin0),
        .R (~resetn),
        .C (clk),
        .Q (payload_byte[383:0])
        );



    ////////////////////////////////////////////////
    // mtyin signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 ) begin
            mtyin0_loc    <= 8'h00;
            mtyin1_loc    <= 8'h00;
            mtyin2_loc    <= 8'h00;
            mtyin3_loc    <= 8'h00;
            mtyin4_loc    <= 8'h00;
            mtyin5_loc    <= 8'h00;
        end else begin
          if (tx_rdyout) begin 
           case (pending_pkt_size[5:0])
             6'd1: begin
               mtyin0_loc <= 8'h01;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd2: begin
               mtyin0_loc <= 8'h03;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd3: begin
               mtyin0_loc <= 8'h07;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd4: begin
               mtyin0_loc <= 8'h0f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd5: begin
               mtyin0_loc <= 8'h1f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd6: begin
               mtyin0_loc <= 8'h3f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd7: begin
               mtyin0_loc <= 8'h7f;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd8: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h00;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd9: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h01;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd10: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h03;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd11: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h07;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd12: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h0f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd13: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'h1f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd14: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'h3f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd15: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'h7f;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd16: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h00;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd17: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h01;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd18: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h03;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd19: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h07;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd20: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h0f;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd21: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h1f;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd22: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h3f;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd23: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'h7f;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd24: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h00;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd25: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h01;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd26: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h03;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd27: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h07;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd28: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h0f;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd29: begin
               mtyin0_loc <= 8'hff;
		           mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h1f;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd30: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h3f;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd31: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'h7f;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd32: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h00;
               mtyin5_loc <= 8'h00;
             end
             6'd33: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h01;
               mtyin5_loc <= 8'h00;
             end
             6'd34: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h03;
               mtyin5_loc <= 8'h00;
             end
             6'd35: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h07;
               mtyin5_loc <= 8'h00;
             end
             6'd36: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h0f;
               mtyin5_loc <= 8'h00;
             end
             6'd37: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h1f;
               mtyin5_loc <= 8'h00;
             end
             6'd38: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h3f;
               mtyin5_loc <= 8'h00;
             end
             6'd39: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'h7f;
               mtyin5_loc <= 8'h00;
             end
             6'd40: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h00;
             end
             6'd41: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h01;
             end
             6'd42: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h03;
             end
             6'd43: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h07;
             end
             6'd44: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h0f;
             end
             6'd45: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h1f;
             end
             6'd46: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h3f;
             end
             6'd47: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'h7f;
             end
             default: begin
		           mtyin0_loc <= 8'hff;
               mtyin1_loc <= 8'hff;
		           mtyin2_loc <= 8'hff;
		           mtyin3_loc <= 8'hff;
               mtyin4_loc <= 8'hff;
               mtyin5_loc <= 8'hff;
             end
           endcase
	      end
      end
    end

    ////////////////////////////////////////////////
    //tx_done_reg_c signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done_reg_c <= 1'b0;
        else
	        if (init_done)
        	    tx_done_reg_c <= 1'b0;
	        else if  (tx_fsm_en && stop_prbs_edge)
                    tx_done_reg_c <= 1'b1;
    end
    ////////////////////////////////////////////////
    //tx_done signal generation
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
            tx_done <= 1'b0;
        else
        begin
            if (init_done)
                tx_done <= 1'b0;            
            else if  (tx_done_reg_d == 1'b1) 
                tx_done <= 1'b1;
        end
    end    

    /////////////////////////////////////////////////////////
    //lbus_number_pkt_proc signal generation 
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            lbus_pkt_size_proc   <= 16'd0;
        end
        else
        begin
            lbus_pkt_size_proc   <= DUPLEX_PKT_SIZE_4d;
        end
    end       


    ////////////////////////////////////////////////
    //Assign LBUS TX Output ports
    ////////////////////////////////////////////////

always @(*)
  begin
     tx_datain0  = nxt_datain0; 
     tx_eopin0   = nxt_eopin0;
     tx_axis_tvalid_0  = tx_eopin0 ? nxt_eopin0 : nxt_valid0;

     tx_mtyin0   = nxt_mtyin0;
     tx_mtyin1   = nxt_mtyin1;
     tx_mtyin2   = nxt_mtyin2;
     tx_mtyin3   = nxt_mtyin3;
     tx_mtyin4	 = nxt_mtyin4;
     tx_mtyin5   = nxt_mtyin5;
     
     tx_datain1  = nxt_datain1;
     tx_datain2  = nxt_datain2;
     tx_datain3  = nxt_datain3;
     tx_datain4  = nxt_datain4;
     tx_datain5  = nxt_datain5;
  end

    ////////////////////////////////////////////////
    //Assign TX Output ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led          <= 1'b0;
            tx_busy_led          <= 1'b0;

        end
        else
        begin
            tx_done_led          <= tx_done_led_3d;
            tx_busy_led          <= tx_core_busy_led_3d;
        end
    end

    ////////////////////////////////////////////////
    //Registering the LED ports
    ////////////////////////////////////////////////
    always @( posedge clk or negedge resetn )
    begin
        if ( resetn == 1'b0 )
        begin
            tx_done_led_1d          <= 1'b0;
            tx_done_led_2d          <= 1'b0;
            tx_done_led_3d          <= 1'b0;
            tx_core_busy_led_1d     <= 1'b0;
            tx_core_busy_led_2d     <= 1'b0;
            tx_core_busy_led_3d     <= 1'b0;
        end
        else
        begin
            tx_done_led_1d          <= tx_done;
            tx_done_led_2d          <= tx_done_led_1d;
            tx_done_led_3d          <= tx_done_led_2d;
            tx_core_busy_led_1d     <= tx_core_busy_led;
            tx_core_busy_led_2d     <= tx_core_busy_led_1d;
            tx_core_busy_led_3d     <= tx_core_busy_led_2d;
	end
    end

    //----------------------------------------END TX Module-----------------------//
    

endmodule



