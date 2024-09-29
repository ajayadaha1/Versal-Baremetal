
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
/////// PORT 0
(* DowngradeIPIdentifiedWarnings="yes" *)
module mrmac_0_prbs_gen_crc_check_async_all
   (
  input tx_clk,
  input tx_reset,
  input rx_clk,
  input rx_reset,

  input                   segmented_mode,
  input         [2:0]     number_of_segments,
  input                   ten_gb_mode,
  input [15:0]            DUPLEX_PKT_SIZE,
  input                   start_prbs,
  input                   stop_prbs_tx,
  input  [47:0]           tx_mac_dest_addr,
  input  [47:0]           tx_mac_src_addr,
  input                   tx_axis_ovfout,
  input                   tx_axis_unfout,
  input                   clear_rx_counters,
  input                   clear_tx_counters,
  input [2:0]             ctl_data_rate,
  input                   tx_fcs_compensate,
  input                   rx_fcs_compensate,

  output logic [63:0]          client_tx_axis_tdata0,
  output logic [63:0]          client_tx_axis_tdata1,
  output logic [63:0]          client_tx_axis_tdata2,
  output logic [63:0]          client_tx_axis_tdata3,
  output logic [63:0]          client_tx_axis_tdata4,
  output logic [63:0]          client_tx_axis_tdata5,
  output logic [10:0]          client_tx_axis_tkeep_user0,
  output logic [10:0]          client_tx_axis_tkeep_user1,
  output logic [10:0]          client_tx_axis_tkeep_user2,
  output logic [10:0]          client_tx_axis_tkeep_user3,
  output logic [10:0]          client_tx_axis_tkeep_user4,
  output logic [10:0]          client_tx_axis_tkeep_user5,
  output logic                 tx_axis_tvalid,
  output logic                 tx_axis_tlast,
  input                        tx_axis_tready,

  input                        rx_axis_tvalid,
  input [63:0]                 rx_axis_tdata0,
  input [63:0]                 rx_axis_tdata1,
  input [63:0]                 rx_axis_tdata2,
  input [63:0]                 rx_axis_tdata3,
  input [63:0]                 rx_axis_tdata4,
  input [63:0]                 rx_axis_tdata5,
  input [10:0]                 rx_axis_tkeep_user0,
  input [10:0]                 rx_axis_tkeep_user1,
  input [10:0]                 rx_axis_tkeep_user2,
  input [10:0]                 rx_axis_tkeep_user3,
  input [10:0]                 rx_axis_tkeep_user4,
  input [10:0]                 rx_axis_tkeep_user5,
  input                        rx_axis_tlast,

  input                   crc_fifo_reset,
  output reg [63:0]     client_tx_frames_transmitted_latched,
  output reg  [63:0]    client_tx_bytes_transmitted_latched,
  output logic 	          tx_done_led,
  output logic 	          tx_busy_led,
  output logic [3:0]      state,
  output   reg  [63:0]    client_rx_errored_frames_latched,
  output   reg  [63:0]    client_rx_bytes_received_latched,
  output   reg  [63:0]    client_rx_frames_received_latched,
  output logic [31:0]     crc_error_cnt
);

localparam BYTE_CNT_WIDTH   = 48;

  reg [2:0]          tx_number_of_segments_q1, tx_number_of_segments_q2;
  wire              clear_rx_counters_rising;
  logic [1:0]       clear_rx_counters_rising_q;
  reg                clear_rx_counters_q1, clear_rx_counters_q2, clear_rx_counters_q3;
  logic [1:0]       clear_tx_counters_rising_q;
  wire              clear_tx_counters_rising;
  reg                clear_tx_counters_q1, clear_tx_counters_q2, clear_tx_counters_q3;

  wire tx_done_led_100g;
  wire tx_busy_led_100g;
  wire [63:0] client_tx_axis_tdata0_100g;
  wire [63:0] client_tx_axis_tdata1_100g;
  wire [7:0] client_tx_axis_tkeep_user0_100g;
  wire [7:0] client_tx_axis_tkeep_user1_100g;
  wire [63:0] client_tx_axis_tdata2_100g;
  wire [63:0] client_tx_axis_tdata3_100g;
  wire [7:0] client_tx_axis_tkeep_user2_100g;
  wire [7:0] client_tx_axis_tkeep_user3_100g;
  wire tx_axis_tvalid_100g;
  wire tx_axis_tlast_100g;


  wire tx_done_led_50g;
  wire tx_busy_led_50g;
  wire [63:0] client_tx_axis_tdata0_50g;
  wire [63:0] client_tx_axis_tdata1_50g;
  wire [7:0] client_tx_axis_tkeep_user0_50g;
  wire [7:0] client_tx_axis_tkeep_user1_50g;
  wire [63:0] client_tx_axis_tdata2_50g;
  wire [63:0] client_tx_axis_tdata3_50g;
  wire [7:0] client_tx_axis_tkeep_user2_50g;
  wire [7:0] client_tx_axis_tkeep_user3_50g;
  wire tx_axis_tvalid_50g;
  wire tx_axis_tlast_50g;

  wire tx_done_led_25g;
  wire tx_busy_led_25g;
  wire [63:0] client_tx_axis_tdata0_25g;
  wire [7:0] client_tx_axis_tkeep_user0_25g;
  wire [63:0] client_tx_axis_tdata1_25g;
  wire [7:0] client_tx_axis_tkeep_user1_25g;
  wire tx_axis_tvalid_25g;
  wire tx_axis_tlast_25g;

  wire tx_done_led_10g;
  wire tx_busy_led_10g;
  wire [63:0] client_tx_axis_tdata0_10g;
  wire [7:0] client_tx_axis_tkeep_user0_10g;
  wire tx_axis_tvalid_10g;
  wire tx_axis_tlast_10g;

  logic              rx_errored_frame_cnt_incr;
  logic              rx_frame_cnt_incr;
  logic [35:0]               client_rx_frames_received;
  logic [31:0]               client_rx_errored_frames;
  reg                rx_axis_tlast_r, rx_axis_tlast_r2, rx_axis_tlast_r3, rx_axis_tlast_r4;
  reg                rx_axis_tvalid_r, rx_axis_tvalid_r2, rx_axis_tvalid_r3, rx_axis_tvalid_r4;
  reg [10:0]         rx_axis_tkeep_user0_r, rx_axis_tkeep_user0_r2, rx_axis_tkeep_user0_r3, rx_axis_tkeep_user0_r4;
  reg [10:0]         rx_axis_tkeep_user1_r;
  reg [10:0]         rx_axis_tkeep_user2_r;
  reg [10:0]         rx_axis_tkeep_user3_r;
  reg [10:0]         rx_axis_tkeep_user4_r;
  reg [10:0]         rx_axis_tkeep_user5_r;
  logic [35:0]               client_tx_frames_transmitted;
  logic              tx_frame_cnt_incr;
  reg                tx_axis_tready_r, tx_axis_tready_r2, tx_axis_tready_r3, tx_axis_tready_r4;
  reg                tx_axis_tvalid_r, tx_axis_tvalid_r2, tx_axis_tvalid_r3, tx_axis_tvalid_r4;
  reg                tx_axis_tlast_r, tx_axis_tlast_r2, tx_axis_tlast_r3, tx_axis_tlast_r4;
  wire               tx_axis_valid_edge;

  logic [3:0]        tx_tkeep_user0_sum, tx_tkeep_user0_sum_r;
  logic [3:0]        tx_tkeep_user1_sum, tx_tkeep_user1_sum_r;
  logic [4:0]        tx_tkeep_user2_3_sum, tx_tkeep_user2_3_sum_r;
  logic [4:0]        tx_tkeep_user4_5_sum, tx_tkeep_user4_5_sum_r;
  reg [10:0]         client_tx_axis_tkeep_user0_r;
  reg [10:0]         client_tx_axis_tkeep_user1_r;
  reg [10:0]         client_tx_axis_tkeep_user2_r;
  reg [10:0]         client_tx_axis_tkeep_user3_r;
  reg [10:0]         client_tx_axis_tkeep_user4_r;
  reg [10:0]         client_tx_axis_tkeep_user5_r;
  logic [5:0]        tx_byte_cnt_incr;
  wire [35:0]        tx_fcs_compensation_nonsegmented;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r2;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r3;
  reg                tx_fcs_compensate_q1, tx_fcs_compensate_q2;
  logic [BYTE_CNT_WIDTH-1:0] client_tx_bytes_transmitted;
  logic [5:0]        tx_tkeep_sum_r, tx_tkeep_sum_lt_eq_two_r, tx_tkeep_sum_more_than_two_r;

  logic [BYTE_CNT_WIDTH-1:0] client_rx_bytes_received;
  logic [5:0]        rx_byte_cnt_incr;
  logic [3:0]        rx_tkeep_user0_sum, rx_tkeep_user0_sum_r;
  logic [3:0]        rx_tkeep_user1_sum, rx_tkeep_user1_sum_r;
  logic [4:0]        rx_tkeep_user2_3_sum, rx_tkeep_user2_3_sum_r;
  logic [4:0]        rx_tkeep_user4_5_sum, rx_tkeep_user4_5_sum_r;
  logic [5:0]        rx_tkeep_sum_r, rx_tkeep_sum_lt_eq_two_r, rx_tkeep_sum_more_than_two_r;
  wire [35:0]        rx_fcs_compensation_nonsegmented;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r2;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r3;
  reg                rx_fcs_compensate_q1, rx_fcs_compensate_q2;
  reg [2:0]          rx_number_of_segments_q1, rx_number_of_segments_q2;

assign client_tx_axis_tkeep_user0[10:8] = 3'b0;
assign client_tx_axis_tkeep_user1[10:8] = 3'b0;
assign client_tx_axis_tkeep_user2[10:8] = 3'b0;
assign client_tx_axis_tkeep_user3[10:8] = 3'b0;
assign tx_fcs_compensation_nonsegmented     = (tx_fcs_compensate_q2 && tx_axis_tlast_r) ? 4 : 0;
assign rx_fcs_compensation_nonsegmented  = (rx_fcs_compensate_q2 && rx_axis_tlast_r) ? 4 : 0;

  always @(posedge tx_clk) begin
    if (tx_reset == 1'b1) begin
      clear_tx_counters_q1                     <= 1'b0;
      clear_tx_counters_q2                     <= 1'b0;
      clear_tx_counters_q3                     <= 1'b0;
      tx_number_of_segments_q1                 <= 3'd2;
      tx_number_of_segments_q2                 <= 3'd2;
      clear_tx_counters_rising_q               <= '0;      
      client_tx_frames_transmitted_latched   <= '0;
      client_tx_bytes_transmitted_latched   <= '0;
      tx_frame_cnt_incr                      <= '0;
      tx_axis_tlast_r <= 1'h0;
      tx_axis_tlast_r2 <= 1'h0;
      tx_axis_tlast_r3 <= 1'h0;
      tx_axis_tlast_r4 <= 1'h0;
      tx_axis_tready_r <= 1'h0;
      tx_axis_tready_r2 <= 1'h0;
      tx_axis_tready_r3 <= 1'h0;
      tx_axis_tready_r4 <= 1'h0;
      tx_axis_tvalid_r <= 1'h0;
      tx_axis_tvalid_r2 <= 1'h0;
      tx_axis_tvalid_r3 <= 1'h0;
      tx_axis_tvalid_r4 <= 1'h0;
      tx_tkeep_sum_r                         <= '0;
      tx_tkeep_user0_sum_r                   <= '0;
      tx_tkeep_user1_sum_r                   <= '0;
      tx_tkeep_user2_3_sum_r                 <= '0;
      tx_tkeep_user4_5_sum_r                 <= '0;
      tx_tkeep_sum_more_than_two_r           <= '0;
      tx_tkeep_sum_lt_eq_two_r               <= '0;
      client_tx_bytes_transmitted_latched    <= '0;
      client_tx_axis_tkeep_user0_r           <= '0;
      client_tx_axis_tkeep_user1_r           <= '0;
      client_tx_axis_tkeep_user2_r           <= '0;
      client_tx_axis_tkeep_user3_r           <= '0;
      client_tx_axis_tkeep_user4_r           <= '0;
      client_tx_axis_tkeep_user5_r           <= '0;
      tx_byte_cnt_incr                       <= '0;
      tx_fcs_compensation_nonsegmented_r        <= '0;
      tx_fcs_compensation_nonsegmented_r2       <= '0;
      tx_fcs_compensation_nonsegmented_r3       <= '0;
      tx_fcs_compensate_q1                   <= '0;
      tx_fcs_compensate_q2                   <= '0;
    end else begin
      clear_tx_counters_q1                     <= clear_tx_counters;
      clear_tx_counters_q2                     <= clear_tx_counters_q1;
      clear_tx_counters_q3                     <= clear_tx_counters_q2;
      tx_number_of_segments_q1                 <= number_of_segments;
      tx_number_of_segments_q2                 <= tx_number_of_segments_q1;
      clear_tx_counters_rising_q               <= {clear_tx_counters_rising_q[0],clear_tx_counters_rising};      
      tx_frame_cnt_incr                      <= '0;
      tx_axis_tlast_r  <= tx_axis_tlast;
      tx_axis_tlast_r2 <= tx_axis_tlast_r;
      tx_axis_tlast_r3 <= tx_axis_tlast_r2;
      tx_axis_tlast_r4 <= tx_axis_tlast_r3;
      tx_axis_tready_r  <= tx_axis_tready;
      tx_axis_tready_r2 <= tx_axis_tready_r;
      tx_axis_tready_r3 <= tx_axis_tready_r2;
      tx_axis_tready_r4 <= tx_axis_tready_r3;
      tx_axis_tvalid_r  <= tx_axis_tvalid;
      tx_axis_tvalid_r2 <= tx_axis_tvalid_r;
      tx_axis_tvalid_r3 <= tx_axis_tvalid_r2;
      tx_axis_tvalid_r4 <= tx_axis_tvalid_r3;
      tx_tkeep_user0_sum_r                   <= tx_tkeep_user0_sum;
      tx_tkeep_user1_sum_r                   <= tx_tkeep_user1_sum;
      tx_tkeep_user2_3_sum_r                 <= tx_tkeep_user2_3_sum;
      tx_tkeep_user4_5_sum_r                 <= tx_tkeep_user4_5_sum;
      client_tx_axis_tkeep_user0_r           <= client_tx_axis_tkeep_user0;
      client_tx_axis_tkeep_user1_r           <= client_tx_axis_tkeep_user1;
      client_tx_axis_tkeep_user2_r           <= client_tx_axis_tkeep_user2;
      client_tx_axis_tkeep_user3_r           <= client_tx_axis_tkeep_user3;
      client_tx_axis_tkeep_user4_r           <= client_tx_axis_tkeep_user4;
      client_tx_axis_tkeep_user5_r           <= client_tx_axis_tkeep_user5;
      tx_byte_cnt_incr                       <= '0;
      tx_fcs_compensation_nonsegmented_r        <= tx_fcs_compensation_nonsegmented;
      tx_fcs_compensation_nonsegmented_r2       <= tx_fcs_compensation_nonsegmented_r;
      tx_fcs_compensation_nonsegmented_r3       <= tx_fcs_compensation_nonsegmented_r2;
      tx_fcs_compensate_q1                   <= tx_fcs_compensate;
      tx_fcs_compensate_q2                   <= tx_fcs_compensate_q1;

      if(tx_number_of_segments_q2 <= 2)
        tx_tkeep_sum_more_than_two_r <= '0;
      else if(tx_number_of_segments_q2 < 5)
        tx_tkeep_sum_more_than_two_r <= tx_tkeep_user2_3_sum_r;
      else
        tx_tkeep_sum_more_than_two_r <= tx_tkeep_user2_3_sum_r + tx_tkeep_user4_5_sum_r;

      if(tx_number_of_segments_q2 == 1)
        tx_tkeep_sum_lt_eq_two_r <= tx_tkeep_user0_sum_r;
      else
        tx_tkeep_sum_lt_eq_two_r <= tx_tkeep_user0_sum_r + tx_tkeep_user1_sum_r;

      tx_tkeep_sum_r <= tx_tkeep_sum_lt_eq_two_r + tx_tkeep_sum_more_than_two_r;

      if (clear_tx_counters_rising_q[1]) begin
        client_tx_frames_transmitted_latched <= {28'h0,client_tx_frames_transmitted[35:0]};
        client_tx_bytes_transmitted_latched  <= {{(64-BYTE_CNT_WIDTH){1'b0}},client_tx_bytes_transmitted};
      end
        if (tx_axis_tready_r4 && tx_axis_tvalid_r4 && tx_axis_tlast_r4) begin
              tx_frame_cnt_incr              <= 1'b1;              
        end
        if (tx_axis_tready_r4 && tx_axis_tvalid_r4) begin
            tx_byte_cnt_incr                 <= tx_tkeep_sum_r + tx_fcs_compensation_nonsegmented_r3;
        end
    end
  end

  assign tx_tkeep_user0_sum =
    client_tx_axis_tkeep_user0_r[7] + client_tx_axis_tkeep_user0_r[6] + client_tx_axis_tkeep_user0_r[5] +
    client_tx_axis_tkeep_user0_r[4] + client_tx_axis_tkeep_user0_r[3] + client_tx_axis_tkeep_user0_r[2] +
    client_tx_axis_tkeep_user0_r[1] + client_tx_axis_tkeep_user0_r[0];

  assign tx_tkeep_user1_sum =
    client_tx_axis_tkeep_user1_r[7] + client_tx_axis_tkeep_user1_r[6] + client_tx_axis_tkeep_user1_r[5] +
    client_tx_axis_tkeep_user1_r[4] + client_tx_axis_tkeep_user1_r[3] + client_tx_axis_tkeep_user1_r[2] +
    client_tx_axis_tkeep_user1_r[1] + client_tx_axis_tkeep_user1_r[0];

  assign tx_tkeep_user2_3_sum =
    client_tx_axis_tkeep_user2_r[7] + client_tx_axis_tkeep_user2_r[6] + client_tx_axis_tkeep_user2_r[5] +
    client_tx_axis_tkeep_user2_r[4] + client_tx_axis_tkeep_user2_r[3] + client_tx_axis_tkeep_user2_r[2] +
    client_tx_axis_tkeep_user2_r[1] + client_tx_axis_tkeep_user2_r[0] +
    client_tx_axis_tkeep_user3_r[7] + client_tx_axis_tkeep_user3_r[6] + client_tx_axis_tkeep_user3_r[5] +
    client_tx_axis_tkeep_user3_r[4] + client_tx_axis_tkeep_user3_r[3] + client_tx_axis_tkeep_user3_r[2] +
                                      client_tx_axis_tkeep_user3_r[1] + client_tx_axis_tkeep_user3_r[0];

  assign tx_tkeep_user4_5_sum =
    client_tx_axis_tkeep_user4_r[7] + client_tx_axis_tkeep_user4_r[6] + client_tx_axis_tkeep_user4_r[5] +
    client_tx_axis_tkeep_user4_r[4] + client_tx_axis_tkeep_user4_r[3] + client_tx_axis_tkeep_user4_r[2] +
    client_tx_axis_tkeep_user4_r[1] + client_tx_axis_tkeep_user4_r[0] +
    client_tx_axis_tkeep_user5_r[7] + client_tx_axis_tkeep_user5_r[6] + client_tx_axis_tkeep_user5_r[5] +
    client_tx_axis_tkeep_user5_r[4] + client_tx_axis_tkeep_user5_r[3] + client_tx_axis_tkeep_user5_r[2] +
    client_tx_axis_tkeep_user5_r[1] + client_tx_axis_tkeep_user5_r[0];

  assign rx_tkeep_user0_sum =
    rx_axis_tkeep_user0_r[7] + rx_axis_tkeep_user0_r[6] + rx_axis_tkeep_user0_r[5] +
    rx_axis_tkeep_user0_r[4] + rx_axis_tkeep_user0_r[3] + rx_axis_tkeep_user0_r[2] +
    rx_axis_tkeep_user0_r[1] + rx_axis_tkeep_user0_r[0];

  assign rx_tkeep_user1_sum =
    rx_axis_tkeep_user1_r[7] + rx_axis_tkeep_user1_r[6] + rx_axis_tkeep_user1_r[5] +
    rx_axis_tkeep_user1_r[4] + rx_axis_tkeep_user1_r[3] + rx_axis_tkeep_user1_r[2] +
    rx_axis_tkeep_user1_r[1] + rx_axis_tkeep_user1_r[0];

  assign rx_tkeep_user2_3_sum =
    rx_axis_tkeep_user2_r[7] + rx_axis_tkeep_user2_r[6] + rx_axis_tkeep_user2_r[5] +
    rx_axis_tkeep_user2_r[4] + rx_axis_tkeep_user2_r[3] + rx_axis_tkeep_user2_r[2] +
    rx_axis_tkeep_user2_r[1] + rx_axis_tkeep_user2_r[0] +
    rx_axis_tkeep_user3_r[7] + rx_axis_tkeep_user3_r[6] + rx_axis_tkeep_user3_r[5] +
    rx_axis_tkeep_user3_r[4] + rx_axis_tkeep_user3_r[3] + rx_axis_tkeep_user3_r[2] +
                                      rx_axis_tkeep_user3_r[1] + rx_axis_tkeep_user3_r[0];

  assign rx_tkeep_user4_5_sum =
    rx_axis_tkeep_user4_r[7] + rx_axis_tkeep_user4_r[6] + rx_axis_tkeep_user4_r[5] +
    rx_axis_tkeep_user4_r[4] + rx_axis_tkeep_user4_r[3] + rx_axis_tkeep_user4_r[2] +
    rx_axis_tkeep_user4_r[1] + rx_axis_tkeep_user4_r[0] +
    rx_axis_tkeep_user5_r[7] + rx_axis_tkeep_user5_r[6] + rx_axis_tkeep_user5_r[5] +
    rx_axis_tkeep_user5_r[4] + rx_axis_tkeep_user5_r[3] + rx_axis_tkeep_user5_r[2] +
    rx_axis_tkeep_user5_r[1] + rx_axis_tkeep_user5_r[0];


  always @(posedge rx_clk) begin
    if (rx_reset == 1'b1) begin
      clear_rx_counters_q1                     <= 1'b0;
      clear_rx_counters_q2                     <= 1'b0;
      clear_rx_counters_q3                     <= 1'b0;
      clear_rx_counters_rising_q               <= '0;
      rx_errored_frame_cnt_incr           <= '0;      
      rx_frame_cnt_incr                   <= '0;
      client_rx_errored_frames_latched    <= '0;
      client_rx_bytes_received_latched    <= '0;
      client_rx_frames_received_latched   <= '0;
      rx_axis_tvalid_r                         <= 1'h0;
      rx_axis_tvalid_r2                         <= 1'h0;
      rx_axis_tvalid_r3                         <= 1'h0;
      rx_axis_tvalid_r4                         <= 1'h0;
      rx_axis_tlast_r                         <= 1'h0;
      rx_axis_tlast_r2                         <= 1'h0;
      rx_axis_tlast_r3                         <= 1'h0;
      rx_axis_tlast_r4                         <= 1'h0;
      rx_axis_tkeep_user0_r                   <= 11'h0;
      rx_axis_tkeep_user0_r2                   <= 11'h0;
      rx_axis_tkeep_user0_r3                   <= 11'h0;
      rx_axis_tkeep_user0_r4                   <= 11'h0;
      rx_byte_cnt_incr                    <= '0;
      rx_tkeep_sum_r                      <= '0;
      rx_tkeep_user0_sum_r                <= '0;
      rx_tkeep_user1_sum_r                <= '0;
      rx_tkeep_user2_3_sum_r              <= '0;
      rx_tkeep_user4_5_sum_r              <= '0;
      rx_tkeep_sum_more_than_two_r        <= '0;
      rx_tkeep_sum_lt_eq_two_r            <= '0;
      rx_fcs_compensation_nonsegmented_r  <= '0;
      rx_fcs_compensation_nonsegmented_r2 <= '0;
      rx_fcs_compensation_nonsegmented_r3 <= '0;
      rx_fcs_compensate_q1                     <= 1'b0;
      rx_fcs_compensate_q2                     <= 1'b0;
      rx_number_of_segments_q1                 <= 3'd2;
      rx_number_of_segments_q2                 <= 3'd2;
      rx_axis_tkeep_user1_r                    <= 11'h0;
      rx_axis_tkeep_user2_r                    <= 11'h0;
      rx_axis_tkeep_user3_r                    <= 11'h0;
      rx_axis_tkeep_user4_r                    <= 11'h0;
      rx_axis_tkeep_user5_r                    <= 11'h0;
    end else begin
      rx_errored_frame_cnt_incr           <= '0;
      rx_frame_cnt_incr                   <= '0;
      clear_rx_counters_q1                     <= clear_rx_counters;
      clear_rx_counters_q2                     <= clear_rx_counters_q1;
      clear_rx_counters_q3                     <= clear_rx_counters_q2;
      clear_rx_counters_rising_q               <= {clear_rx_counters_rising_q[0],clear_rx_counters_rising};
      rx_axis_tvalid_r                          <= rx_axis_tvalid;
      rx_axis_tvalid_r2                         <= rx_axis_tvalid_r;
      rx_axis_tvalid_r3                         <= rx_axis_tvalid_r2;
      rx_axis_tvalid_r4                         <= rx_axis_tvalid_r3;
      rx_axis_tlast_r                          <= rx_axis_tlast;
      rx_axis_tlast_r2                         <= rx_axis_tlast_r;
      rx_axis_tlast_r3                         <= rx_axis_tlast_r2;
      rx_axis_tlast_r4                         <= rx_axis_tlast_r3;
      rx_axis_tkeep_user0_r                    <= rx_axis_tkeep_user0;
      rx_axis_tkeep_user0_r2                   <= rx_axis_tkeep_user0_r;
      rx_axis_tkeep_user0_r3                   <= rx_axis_tkeep_user0_r2;
      rx_axis_tkeep_user0_r4                   <= rx_axis_tkeep_user0_r3;
      rx_byte_cnt_incr                    <= '0;
      rx_tkeep_user0_sum_r                <= rx_tkeep_user0_sum;
      rx_tkeep_user1_sum_r                <= rx_tkeep_user1_sum;
      rx_tkeep_user2_3_sum_r              <= rx_tkeep_user2_3_sum;
      rx_tkeep_user4_5_sum_r              <= rx_tkeep_user4_5_sum;
      rx_fcs_compensation_nonsegmented_r  <= rx_fcs_compensation_nonsegmented;
      rx_fcs_compensation_nonsegmented_r2 <= rx_fcs_compensation_nonsegmented_r;
      rx_fcs_compensation_nonsegmented_r3 <= rx_fcs_compensation_nonsegmented_r2;
      rx_fcs_compensate_q1                     <= rx_fcs_compensate;
      rx_fcs_compensate_q2                     <= rx_fcs_compensate_q1;
      rx_number_of_segments_q1                 <= number_of_segments;
      rx_number_of_segments_q2                 <= rx_number_of_segments_q1;
      rx_axis_tkeep_user1_r                    <= rx_axis_tkeep_user1;
      rx_axis_tkeep_user2_r                    <= rx_axis_tkeep_user2;
      rx_axis_tkeep_user3_r                    <= rx_axis_tkeep_user3;
      rx_axis_tkeep_user4_r                    <= rx_axis_tkeep_user4;
      rx_axis_tkeep_user5_r                    <= rx_axis_tkeep_user5;

      if(rx_number_of_segments_q2 <= 2)
        rx_tkeep_sum_more_than_two_r <= '0;
      else if(rx_number_of_segments_q2 < 5)
        rx_tkeep_sum_more_than_two_r <= rx_tkeep_user2_3_sum_r;
      else
        rx_tkeep_sum_more_than_two_r <= rx_tkeep_user2_3_sum_r + rx_tkeep_user4_5_sum_r;

      if(rx_number_of_segments_q2 == 1)
        rx_tkeep_sum_lt_eq_two_r <= rx_tkeep_user0_sum_r;
      else
        rx_tkeep_sum_lt_eq_two_r <= rx_tkeep_user0_sum_r + rx_tkeep_user1_sum_r;

      rx_tkeep_sum_r <= rx_tkeep_sum_lt_eq_two_r + rx_tkeep_sum_more_than_two_r;

      if (rx_axis_tlast_r4 && rx_axis_tvalid_r4) begin
        rx_frame_cnt_incr           <= 1'b1;              
        rx_errored_frame_cnt_incr   <= rx_axis_tkeep_user0_r4[8];              
      end
      if (rx_axis_tvalid_r4) begin
        rx_byte_cnt_incr              <= rx_tkeep_sum_r + rx_fcs_compensation_nonsegmented_r3;
      end
      if (clear_rx_counters_rising_q[1]) begin
        client_rx_errored_frames_latched  <= {32'h0,client_rx_errored_frames[31:0]};
        client_rx_frames_received_latched <= {28'h0,client_rx_frames_received[35:0]};
        client_rx_bytes_received_latched  <= {{(64-BYTE_CNT_WIDTH){1'b0}},client_rx_bytes_received};
      end
    end
  end

  assign clear_rx_counters_rising               = clear_rx_counters_q2 && (!clear_rx_counters_q3);
  assign clear_tx_counters_rising               = clear_tx_counters_q2 && (!clear_tx_counters_q3);

// 100 G
mrmac_0_core_lbus_pkt_gen_384b i_mrmac_0_pkt_gen_100g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && (ctl_data_rate[2] == 1'b1)),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_100g),
  .tx_busy_led         (tx_busy_led_100g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_100g),
  .tx_eopin0           (tx_axis_tlast_100g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_100g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_100g),
  .tx_datain1          (client_tx_axis_tdata1_100g),		
  .tx_mtyin1           (client_tx_axis_tkeep_user1_100g[7:0]),
  .tx_datain2          (client_tx_axis_tdata2_100g),		
  .tx_mtyin2           (client_tx_axis_tkeep_user2_100g[7:0]),
  .tx_datain3          (client_tx_axis_tdata3_100g),		
  .tx_mtyin3           (client_tx_axis_tkeep_user3_100g[7:0]),
  .tx_datain4          (client_tx_axis_tdata4),		
  .tx_mtyin4           (client_tx_axis_tkeep_user4[7:0]),
  .tx_datain5          (client_tx_axis_tdata5),		
  .tx_mtyin5           (client_tx_axis_tkeep_user5[7:0]),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

// 40/50G
mrmac_0_core_lbus_pkt_gen_256b i_mrmac_0_pkt_gen_50g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && (ctl_data_rate[2:1] == 2'b01)),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_50g),
  .tx_busy_led         (tx_busy_led_50g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_50g),
  .tx_eopin0           (tx_axis_tlast_50g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_50g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_50g),
  .tx_datain1          (client_tx_axis_tdata1_50g),		
  .tx_mtyin1           (client_tx_axis_tkeep_user1_50g[7:0]),
  .tx_datain2          (client_tx_axis_tdata2_50g),		
  .tx_mtyin2           (client_tx_axis_tkeep_user2_50g[7:0]),
  .tx_datain3          (client_tx_axis_tdata3_50g),		
  .tx_mtyin3           (client_tx_axis_tkeep_user3_50g[7:0]),
  .tx_ovfout           (tx_axis_ovfout),
  .state               (state),
  .tx_unfout           (tx_axis_unfout)
  );

// 25G
mrmac_0_core_lbus_pkt_gen_128b i_mrmac_0_pkt_gen_25g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && (ctl_data_rate == 3'b001)),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_25g),
  .tx_busy_led         (tx_busy_led_25g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_25g),
  .tx_eopin0           (tx_axis_tlast_25g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_25g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_25g),
  .tx_datain1          (client_tx_axis_tdata1_25g),		
  .tx_mtyin1           (client_tx_axis_tkeep_user1_25g[7:0]),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

// 10G
mrmac_0_core_lbus_pkt_gen_32b i_mrmac_0_pkt_gen_10g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && (ctl_data_rate == 3'b000)),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_10g),
  .tx_busy_led         (tx_busy_led_10g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_10g),
  .tx_eopin0           (tx_axis_tlast_10g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_10g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_10g),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

always@(*) begin
  case (ctl_data_rate)
    3'b000 : begin
      tx_done_led   = tx_done_led_10g;
      tx_busy_led   = tx_busy_led_10g;
      client_tx_axis_tdata0 = client_tx_axis_tdata0_10g;
      client_tx_axis_tkeep_user0[7:0] = client_tx_axis_tkeep_user0_10g;
      tx_axis_tvalid = tx_axis_tvalid_10g;
      tx_axis_tlast  = tx_axis_tlast_10g;
    end
    3'b001 : begin
      tx_done_led   = tx_done_led_25g;
      tx_busy_led   = tx_busy_led_25g;
      client_tx_axis_tdata0 = client_tx_axis_tdata0_25g;
      client_tx_axis_tkeep_user0[7:0] = client_tx_axis_tkeep_user0_25g;
      tx_axis_tvalid = tx_axis_tvalid_25g;
      tx_axis_tlast  = tx_axis_tlast_25g;
    end
    3'b010, 3'b011 : begin
      tx_done_led   = tx_done_led_50g;
      tx_busy_led   = tx_busy_led_50g;
      client_tx_axis_tdata0 = client_tx_axis_tdata0_50g;
      client_tx_axis_tkeep_user0[7:0] = client_tx_axis_tkeep_user0_50g;
      tx_axis_tvalid = tx_axis_tvalid_50g;
      tx_axis_tlast  = tx_axis_tlast_50g;
    end
    default : begin
      tx_done_led   = tx_done_led_100g;
      tx_busy_led   = tx_busy_led_100g;
      client_tx_axis_tdata0 = client_tx_axis_tdata0_100g;
      client_tx_axis_tkeep_user0[7:0] = client_tx_axis_tkeep_user0_100g;
      tx_axis_tvalid = tx_axis_tvalid_100g;
      tx_axis_tlast  = tx_axis_tlast_100g;
    end
  endcase
end

always@(*) begin
  case (ctl_data_rate)
    3'b001 : begin
      client_tx_axis_tdata1 = client_tx_axis_tdata1_25g;
      client_tx_axis_tkeep_user1[7:0] = client_tx_axis_tkeep_user1_25g;
    end
    3'b010, 3'b011 : begin
      client_tx_axis_tdata1 = client_tx_axis_tdata1_50g;
      client_tx_axis_tkeep_user1[7:0] = client_tx_axis_tkeep_user1_50g;
    end
    default : begin
      client_tx_axis_tdata1 = client_tx_axis_tdata1_100g;
      client_tx_axis_tkeep_user1[7:0] = client_tx_axis_tkeep_user1_100g;
    end
  endcase
end

assign client_tx_axis_tdata2 = ctl_data_rate[2] ? client_tx_axis_tdata2_100g : client_tx_axis_tdata2_50g;
assign client_tx_axis_tdata3 = ctl_data_rate[2] ? client_tx_axis_tdata3_100g : client_tx_axis_tdata3_50g;
assign client_tx_axis_tkeep_user2[7:0] = ctl_data_rate[2] ? client_tx_axis_tkeep_user2_100g : client_tx_axis_tkeep_user2_50g;
assign client_tx_axis_tkeep_user3[7:0] = ctl_data_rate[2] ? client_tx_axis_tkeep_user3_100g : client_tx_axis_tkeep_user3_50g;


mrmac_0_crc_wrapper i_mrmac_0_crc_wrapper_inst
  (
   .tx_clk                  (tx_clk),
   .rx_clk                  (rx_clk),
   .tx_reset                (tx_reset),
   .rx_reset                (rx_reset),

   .number_of_segments      (tx_number_of_segments_q2),
   .ten_gb_mode             (ten_gb_mode),

   // TX AXIS
   .tvalid                  (tx_axis_tvalid),
   .tdata                   ({client_tx_axis_tdata5,client_tx_axis_tdata4,client_tx_axis_tdata3,client_tx_axis_tdata2,client_tx_axis_tdata1,client_tx_axis_tdata0}),
   .tkeep                   ({client_tx_axis_tkeep_user5,client_tx_axis_tkeep_user4,client_tx_axis_tkeep_user3,client_tx_axis_tkeep_user2,client_tx_axis_tkeep_user1,client_tx_axis_tkeep_user0}),
   .tlast                   (tx_axis_tlast),
   .tready                  (tx_axis_tready),

   // RX AXIS
   .rvalid                  (rx_axis_tvalid),
   .rdata                   ({rx_axis_tdata5,rx_axis_tdata4,rx_axis_tdata3,rx_axis_tdata2,rx_axis_tdata1,rx_axis_tdata0}),
   .rkeep                   ({rx_axis_tkeep_user5,rx_axis_tkeep_user4,rx_axis_tkeep_user3,rx_axis_tkeep_user2,rx_axis_tkeep_user1,rx_axis_tkeep_user0}),
   .rlast                   (rx_axis_tlast),

   .fifo_reset              (crc_fifo_reset),

   // CRC error count
   .crc_error_cnt_latch_clr (clear_rx_counters_rising_q[0]),
   .crc_error_cnt           (crc_error_cnt)

   );

mrmac_0_hs_counter #(.CNT_WIDTH  (BYTE_CNT_WIDTH),
             .INCR_WIDTH (6),
             .SATURATE   (0))
i_mrmac_0_hs_counter_rx_byte_cnt
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_byte_cnt_incr),
   .cnt   (client_rx_bytes_received)
   );


mrmac_0_hs_counter #(.CNT_WIDTH  (32),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_rx_errored_frame_cnt  
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_errored_frame_cnt_incr),
   .cnt   (client_rx_errored_frames)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (36),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_rx_frame_cnt  
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_frame_cnt_incr),
   .cnt   (client_rx_frames_received)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (36),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_tx_frame_cnt  
  (
   .clk   (tx_clk),
   .reset (tx_reset), // sync reset
   .clear (clear_tx_counters_rising_q[0]),   
   .incr  (tx_frame_cnt_incr),
   .cnt   (client_tx_frames_transmitted)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (BYTE_CNT_WIDTH),
             .INCR_WIDTH (6),
             .SATURATE   (0))
i_mrmac_0_hs_counter_tx_byte_cnt
  (
   .clk   (tx_clk),
   .reset (tx_reset), // sync reset
   .clear (clear_tx_counters_rising_q[0]),
   .incr  (tx_byte_cnt_incr),
   .cnt   (client_tx_bytes_transmitted)
   );


endmodule

////// PORT 2
module mrmac_0_prbs_gen_crc_check_async_50g
   (
  input tx_clk,
  input tx_reset,
  input rx_clk,
  input rx_reset,

  input                   segmented_mode,
  input         [2:0]     number_of_segments,
  input                   ten_gb_mode,
  input [15:0]            DUPLEX_PKT_SIZE,
  input                   start_prbs,
  input                   stop_prbs_tx,
  input  [47:0]           tx_mac_dest_addr,
  input  [47:0]           tx_mac_src_addr,
  input                   tx_axis_ovfout,
  input                   tx_axis_unfout,
  input                   clear_rx_counters,
  input                   clear_tx_counters,
  input [1:0]             ctl_data_rate,
  input                   tx_fcs_compensate,
  input                   rx_fcs_compensate,

  output logic [63:0]          client_tx_axis_tdata0,
  output logic [63:0]          client_tx_axis_tdata1,
  output logic [63:0]          client_tx_axis_tdata2,
  output logic [63:0]          client_tx_axis_tdata3,
  output logic [63:0]          client_tx_axis_tdata4,
  output logic [63:0]          client_tx_axis_tdata5,
  output logic [10:0]          client_tx_axis_tkeep_user0,
  output logic [10:0]          client_tx_axis_tkeep_user1,
  output logic [10:0]          client_tx_axis_tkeep_user2,
  output logic [10:0]          client_tx_axis_tkeep_user3,
  output logic [10:0]          client_tx_axis_tkeep_user4,
  output logic [10:0]          client_tx_axis_tkeep_user5,
  output logic                 tx_axis_tvalid,
  output logic                 tx_axis_tlast,
  input                        tx_axis_tready,

  input                        rx_axis_tvalid,
  input [63:0]                 rx_axis_tdata0,
  input [63:0]                 rx_axis_tdata1,
  input [63:0]                 rx_axis_tdata2,
  input [63:0]                 rx_axis_tdata3,
  input [63:0]                 rx_axis_tdata4,
  input [63:0]                 rx_axis_tdata5,
  input [10:0]                 rx_axis_tkeep_user0,
  input [10:0]                 rx_axis_tkeep_user1,
  input [10:0]                 rx_axis_tkeep_user2,
  input [10:0]                 rx_axis_tkeep_user3,
  input [10:0]                 rx_axis_tkeep_user4,
  input [10:0]                 rx_axis_tkeep_user5,
  input                        rx_axis_tlast,

  input                   crc_fifo_reset,
  output reg [63:0]     client_tx_frames_transmitted_latched,
  output reg  [63:0]    client_tx_bytes_transmitted_latched,
  output logic 	          tx_done_led,
  output logic 	          tx_busy_led,
  output   reg  [63:0]    client_rx_errored_frames_latched,
  output   reg  [63:0]    client_rx_bytes_received_latched,
  output   reg  [63:0]    client_rx_frames_received_latched,
  output logic [31:0]     crc_error_cnt
);

localparam BYTE_CNT_WIDTH   = 48;

  reg [2:0]          tx_number_of_segments_q1, tx_number_of_segments_q2;
  wire              clear_rx_counters_rising;
  logic [1:0]       clear_rx_counters_rising_q;
  reg                clear_rx_counters_q1, clear_rx_counters_q2, clear_rx_counters_q3;
  logic [1:0]       clear_tx_counters_rising_q;
  wire              clear_tx_counters_rising;
  reg                clear_tx_counters_q1, clear_tx_counters_q2, clear_tx_counters_q3;


  wire tx_done_led_50g;
  wire tx_busy_led_50g;
  wire [63:0] client_tx_axis_tdata0_50g;
  wire [63:0] client_tx_axis_tdata1_50g;
  wire [7:0] client_tx_axis_tkeep_user0_50g;
  wire [7:0] client_tx_axis_tkeep_user1_50g;
  wire tx_axis_tvalid_50g;
  wire tx_axis_tlast_50g;

  wire tx_done_led_25g;
  wire tx_busy_led_25g;
  wire [63:0] client_tx_axis_tdata0_25g;
  wire [7:0] client_tx_axis_tkeep_user0_25g;
  wire [63:0] client_tx_axis_tdata1_25g;
  wire [7:0] client_tx_axis_tkeep_user1_25g;
  wire tx_axis_tvalid_25g;
  wire tx_axis_tlast_25g;

  wire tx_done_led_10g;
  wire tx_busy_led_10g;
  wire [63:0] client_tx_axis_tdata0_10g;
  wire [7:0] client_tx_axis_tkeep_user0_10g;
  wire tx_axis_tvalid_10g;
  wire tx_axis_tlast_10g;

  logic              rx_errored_frame_cnt_incr;
  logic              rx_frame_cnt_incr;
  logic [35:0]               client_rx_frames_received;
  logic [31:0]               client_rx_errored_frames;
  reg                rx_axis_tlast_r, rx_axis_tlast_r2, rx_axis_tlast_r3, rx_axis_tlast_r4;
  reg                rx_axis_tvalid_r, rx_axis_tvalid_r2, rx_axis_tvalid_r3, rx_axis_tvalid_r4;
  reg [10:0]         rx_axis_tkeep_user0_r, rx_axis_tkeep_user0_r2, rx_axis_tkeep_user0_r3, rx_axis_tkeep_user0_r4;
  reg [10:0]         rx_axis_tkeep_user1_r;
  reg [10:0]         rx_axis_tkeep_user2_r;
  reg [10:0]         rx_axis_tkeep_user3_r;
  reg [10:0]         rx_axis_tkeep_user4_r;
  reg [10:0]         rx_axis_tkeep_user5_r;
  logic [35:0]               client_tx_frames_transmitted;
  logic              tx_frame_cnt_incr;
  reg                tx_axis_tready_r, tx_axis_tready_r2, tx_axis_tready_r3, tx_axis_tready_r4;
  reg                tx_axis_tvalid_r, tx_axis_tvalid_r2, tx_axis_tvalid_r3, tx_axis_tvalid_r4;
  reg                tx_axis_tlast_r, tx_axis_tlast_r2, tx_axis_tlast_r3, tx_axis_tlast_r4;
  wire               tx_axis_valid_edge;

  logic [3:0]        tx_tkeep_user0_sum, tx_tkeep_user0_sum_r;
  logic [3:0]        tx_tkeep_user1_sum, tx_tkeep_user1_sum_r;
  logic [4:0]        tx_tkeep_user2_3_sum, tx_tkeep_user2_3_sum_r;
  logic [4:0]        tx_tkeep_user4_5_sum, tx_tkeep_user4_5_sum_r;
  reg [10:0]         client_tx_axis_tkeep_user0_r;
  reg [10:0]         client_tx_axis_tkeep_user1_r;
  reg [10:0]         client_tx_axis_tkeep_user2_r;
  reg [10:0]         client_tx_axis_tkeep_user3_r;
  reg [10:0]         client_tx_axis_tkeep_user4_r;
  reg [10:0]         client_tx_axis_tkeep_user5_r;
  logic [5:0]        tx_byte_cnt_incr;
  wire [35:0]        tx_fcs_compensation_nonsegmented;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r2;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r3;
  reg                tx_fcs_compensate_q1, tx_fcs_compensate_q2;
  logic [BYTE_CNT_WIDTH-1:0] client_tx_bytes_transmitted;
  logic [5:0]        tx_tkeep_sum_r, tx_tkeep_sum_lt_eq_two_r, tx_tkeep_sum_more_than_two_r;

  logic [BYTE_CNT_WIDTH-1:0] client_rx_bytes_received;
  logic [5:0]        rx_byte_cnt_incr;
  logic [3:0]        rx_tkeep_user0_sum, rx_tkeep_user0_sum_r;
  logic [3:0]        rx_tkeep_user1_sum, rx_tkeep_user1_sum_r;
  logic [4:0]        rx_tkeep_user2_3_sum, rx_tkeep_user2_3_sum_r;
  logic [4:0]        rx_tkeep_user4_5_sum, rx_tkeep_user4_5_sum_r;
  logic [5:0]        rx_tkeep_sum_r, rx_tkeep_sum_lt_eq_two_r, rx_tkeep_sum_more_than_two_r;
  wire [35:0]        rx_fcs_compensation_nonsegmented;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r2;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r3;
  reg                rx_fcs_compensate_q1, rx_fcs_compensate_q2;
  reg [2:0]          rx_number_of_segments_q1, rx_number_of_segments_q2;

assign client_tx_axis_tkeep_user0[10:8] = 3'b0;
assign client_tx_axis_tkeep_user1[10:8] = 3'b0;
assign client_tx_axis_tkeep_user2[10:8] = 3'b0;
assign client_tx_axis_tkeep_user3[10:8] = 3'b0;
assign tx_fcs_compensation_nonsegmented     = (tx_fcs_compensate_q2 && tx_axis_tlast_r) ? 4 : 0;
assign rx_fcs_compensation_nonsegmented  = (rx_fcs_compensate_q2 && rx_axis_tlast_r) ? 4 : 0;

  always @(posedge tx_clk) begin
    if (tx_reset == 1'b1) begin
      clear_tx_counters_q1                     <= 1'b0;
      clear_tx_counters_q2                     <= 1'b0;
      clear_tx_counters_q3                     <= 1'b0;
      tx_number_of_segments_q1                 <= 3'd2;
      tx_number_of_segments_q2                 <= 3'd2;
      clear_tx_counters_rising_q               <= '0;      
      client_tx_frames_transmitted_latched   <= '0;
      client_tx_bytes_transmitted_latched   <= '0;
      tx_frame_cnt_incr                      <= '0;
      tx_axis_tlast_r <= 1'h0;
      tx_axis_tlast_r2 <= 1'h0;
      tx_axis_tlast_r3 <= 1'h0;
      tx_axis_tlast_r4 <= 1'h0;
      tx_axis_tready_r <= 1'h0;
      tx_axis_tready_r2 <= 1'h0;
      tx_axis_tready_r3 <= 1'h0;
      tx_axis_tready_r4 <= 1'h0;
      tx_axis_tvalid_r <= 1'h0;
      tx_axis_tvalid_r2 <= 1'h0;
      tx_axis_tvalid_r3 <= 1'h0;
      tx_axis_tvalid_r4 <= 1'h0;
      tx_tkeep_sum_r                         <= '0;
      tx_tkeep_user0_sum_r                   <= '0;
      tx_tkeep_user1_sum_r                   <= '0;
      tx_tkeep_user2_3_sum_r                 <= '0;
      tx_tkeep_user4_5_sum_r                 <= '0;
      tx_tkeep_sum_more_than_two_r           <= '0;
      tx_tkeep_sum_lt_eq_two_r               <= '0;
      client_tx_bytes_transmitted_latched    <= '0;
      client_tx_axis_tkeep_user0_r           <= '0;
      client_tx_axis_tkeep_user1_r           <= '0;
      client_tx_axis_tkeep_user2_r           <= '0;
      client_tx_axis_tkeep_user3_r           <= '0;
      client_tx_axis_tkeep_user4_r           <= '0;
      client_tx_axis_tkeep_user5_r           <= '0;
      tx_byte_cnt_incr                       <= '0;
      tx_fcs_compensation_nonsegmented_r        <= '0;
      tx_fcs_compensation_nonsegmented_r2       <= '0;
      tx_fcs_compensation_nonsegmented_r3       <= '0;
      tx_fcs_compensate_q1                   <= '0;
      tx_fcs_compensate_q2                   <= '0;
    end else begin
      clear_tx_counters_q1                     <= clear_tx_counters;
      clear_tx_counters_q2                     <= clear_tx_counters_q1;
      clear_tx_counters_q3                     <= clear_tx_counters_q2;
      tx_number_of_segments_q1                 <= number_of_segments;
      tx_number_of_segments_q2                 <= tx_number_of_segments_q1;
      clear_tx_counters_rising_q               <= {clear_tx_counters_rising_q[0],clear_tx_counters_rising};      
      tx_frame_cnt_incr                      <= '0;
      tx_axis_tlast_r  <= tx_axis_tlast;
      tx_axis_tlast_r2 <= tx_axis_tlast_r;
      tx_axis_tlast_r3 <= tx_axis_tlast_r2;
      tx_axis_tlast_r4 <= tx_axis_tlast_r3;
      tx_axis_tready_r  <= tx_axis_tready;
      tx_axis_tready_r2 <= tx_axis_tready_r;
      tx_axis_tready_r3 <= tx_axis_tready_r2;
      tx_axis_tready_r4 <= tx_axis_tready_r3;
      tx_axis_tvalid_r  <= tx_axis_tvalid;
      tx_axis_tvalid_r2 <= tx_axis_tvalid_r;
      tx_axis_tvalid_r3 <= tx_axis_tvalid_r2;
      tx_axis_tvalid_r4 <= tx_axis_tvalid_r3;
      tx_tkeep_user0_sum_r                   <= tx_tkeep_user0_sum;
      tx_tkeep_user1_sum_r                   <= tx_tkeep_user1_sum;
      tx_tkeep_user2_3_sum_r                 <= tx_tkeep_user2_3_sum;
      tx_tkeep_user4_5_sum_r                 <= tx_tkeep_user4_5_sum;
      client_tx_axis_tkeep_user0_r           <= client_tx_axis_tkeep_user0;
      client_tx_axis_tkeep_user1_r           <= client_tx_axis_tkeep_user1;
      client_tx_axis_tkeep_user2_r           <= client_tx_axis_tkeep_user2;
      client_tx_axis_tkeep_user3_r           <= client_tx_axis_tkeep_user3;
      client_tx_axis_tkeep_user4_r           <= client_tx_axis_tkeep_user4;
      client_tx_axis_tkeep_user5_r           <= client_tx_axis_tkeep_user5;
      tx_byte_cnt_incr                       <= '0;
      tx_fcs_compensation_nonsegmented_r        <= tx_fcs_compensation_nonsegmented;
      tx_fcs_compensation_nonsegmented_r2       <= tx_fcs_compensation_nonsegmented_r;
      tx_fcs_compensation_nonsegmented_r3       <= tx_fcs_compensation_nonsegmented_r2;
      tx_fcs_compensate_q1                   <= tx_fcs_compensate;
      tx_fcs_compensate_q2                   <= tx_fcs_compensate_q1;

      if(tx_number_of_segments_q2 <= 2)
        tx_tkeep_sum_more_than_two_r <= '0;
      else if(tx_number_of_segments_q2 < 5)
        tx_tkeep_sum_more_than_two_r <= tx_tkeep_user2_3_sum_r;
      else
        tx_tkeep_sum_more_than_two_r <= tx_tkeep_user2_3_sum_r + tx_tkeep_user4_5_sum_r;

      if(tx_number_of_segments_q2 == 1)
        tx_tkeep_sum_lt_eq_two_r <= tx_tkeep_user0_sum_r;
      else
        tx_tkeep_sum_lt_eq_two_r <= tx_tkeep_user0_sum_r + tx_tkeep_user1_sum_r;

      tx_tkeep_sum_r <= tx_tkeep_sum_lt_eq_two_r + tx_tkeep_sum_more_than_two_r;

      if (clear_tx_counters_rising_q[1]) begin
        client_tx_frames_transmitted_latched <= {28'h0,client_tx_frames_transmitted[35:0]};
        client_tx_bytes_transmitted_latched  <= {{(64-BYTE_CNT_WIDTH){1'b0}},client_tx_bytes_transmitted};
      end
        if (tx_axis_tready_r4 && tx_axis_tvalid_r4 && tx_axis_tlast_r4) begin
              tx_frame_cnt_incr              <= 1'b1;              
        end
        if (tx_axis_tready_r4 && tx_axis_tvalid_r4) begin
            tx_byte_cnt_incr                 <= tx_tkeep_sum_r + tx_fcs_compensation_nonsegmented_r3;
        end
    end
  end

  assign tx_tkeep_user0_sum =
    client_tx_axis_tkeep_user0_r[7] + client_tx_axis_tkeep_user0_r[6] + client_tx_axis_tkeep_user0_r[5] +
    client_tx_axis_tkeep_user0_r[4] + client_tx_axis_tkeep_user0_r[3] + client_tx_axis_tkeep_user0_r[2] +
    client_tx_axis_tkeep_user0_r[1] + client_tx_axis_tkeep_user0_r[0];

  assign tx_tkeep_user1_sum =
    client_tx_axis_tkeep_user1_r[7] + client_tx_axis_tkeep_user1_r[6] + client_tx_axis_tkeep_user1_r[5] +
    client_tx_axis_tkeep_user1_r[4] + client_tx_axis_tkeep_user1_r[3] + client_tx_axis_tkeep_user1_r[2] +
    client_tx_axis_tkeep_user1_r[1] + client_tx_axis_tkeep_user1_r[0];

  assign tx_tkeep_user2_3_sum =
    client_tx_axis_tkeep_user2_r[7] + client_tx_axis_tkeep_user2_r[6] + client_tx_axis_tkeep_user2_r[5] +
    client_tx_axis_tkeep_user2_r[4] + client_tx_axis_tkeep_user2_r[3] + client_tx_axis_tkeep_user2_r[2] +
    client_tx_axis_tkeep_user2_r[1] + client_tx_axis_tkeep_user2_r[0] +
    client_tx_axis_tkeep_user3_r[7] + client_tx_axis_tkeep_user3_r[6] + client_tx_axis_tkeep_user3_r[5] +
    client_tx_axis_tkeep_user3_r[4] + client_tx_axis_tkeep_user3_r[3] + client_tx_axis_tkeep_user3_r[2] +
                                      client_tx_axis_tkeep_user3_r[1] + client_tx_axis_tkeep_user3_r[0];

  assign tx_tkeep_user4_5_sum =
    client_tx_axis_tkeep_user4_r[7] + client_tx_axis_tkeep_user4_r[6] + client_tx_axis_tkeep_user4_r[5] +
    client_tx_axis_tkeep_user4_r[4] + client_tx_axis_tkeep_user4_r[3] + client_tx_axis_tkeep_user4_r[2] +
    client_tx_axis_tkeep_user4_r[1] + client_tx_axis_tkeep_user4_r[0] +
    client_tx_axis_tkeep_user5_r[7] + client_tx_axis_tkeep_user5_r[6] + client_tx_axis_tkeep_user5_r[5] +
    client_tx_axis_tkeep_user5_r[4] + client_tx_axis_tkeep_user5_r[3] + client_tx_axis_tkeep_user5_r[2] +
    client_tx_axis_tkeep_user5_r[1] + client_tx_axis_tkeep_user5_r[0];

  assign rx_tkeep_user0_sum =
    rx_axis_tkeep_user0_r[7] + rx_axis_tkeep_user0_r[6] + rx_axis_tkeep_user0_r[5] +
    rx_axis_tkeep_user0_r[4] + rx_axis_tkeep_user0_r[3] + rx_axis_tkeep_user0_r[2] +
    rx_axis_tkeep_user0_r[1] + rx_axis_tkeep_user0_r[0];

  assign rx_tkeep_user1_sum =
    rx_axis_tkeep_user1_r[7] + rx_axis_tkeep_user1_r[6] + rx_axis_tkeep_user1_r[5] +
    rx_axis_tkeep_user1_r[4] + rx_axis_tkeep_user1_r[3] + rx_axis_tkeep_user1_r[2] +
    rx_axis_tkeep_user1_r[1] + rx_axis_tkeep_user1_r[0];

  assign rx_tkeep_user2_3_sum =
    rx_axis_tkeep_user2_r[7] + rx_axis_tkeep_user2_r[6] + rx_axis_tkeep_user2_r[5] +
    rx_axis_tkeep_user2_r[4] + rx_axis_tkeep_user2_r[3] + rx_axis_tkeep_user2_r[2] +
    rx_axis_tkeep_user2_r[1] + rx_axis_tkeep_user2_r[0] +
    rx_axis_tkeep_user3_r[7] + rx_axis_tkeep_user3_r[6] + rx_axis_tkeep_user3_r[5] +
    rx_axis_tkeep_user3_r[4] + rx_axis_tkeep_user3_r[3] + rx_axis_tkeep_user3_r[2] +
                                      rx_axis_tkeep_user3_r[1] + rx_axis_tkeep_user3_r[0];

  assign rx_tkeep_user4_5_sum =
    rx_axis_tkeep_user4_r[7] + rx_axis_tkeep_user4_r[6] + rx_axis_tkeep_user4_r[5] +
    rx_axis_tkeep_user4_r[4] + rx_axis_tkeep_user4_r[3] + rx_axis_tkeep_user4_r[2] +
    rx_axis_tkeep_user4_r[1] + rx_axis_tkeep_user4_r[0] +
    rx_axis_tkeep_user5_r[7] + rx_axis_tkeep_user5_r[6] + rx_axis_tkeep_user5_r[5] +
    rx_axis_tkeep_user5_r[4] + rx_axis_tkeep_user5_r[3] + rx_axis_tkeep_user5_r[2] +
    rx_axis_tkeep_user5_r[1] + rx_axis_tkeep_user5_r[0];


  always @(posedge rx_clk) begin
    if (rx_reset == 1'b1) begin
      clear_rx_counters_q1                     <= 1'b0;
      clear_rx_counters_q2                     <= 1'b0;
      clear_rx_counters_q3                     <= 1'b0;
      clear_rx_counters_rising_q               <= '0;
      rx_errored_frame_cnt_incr           <= '0;      
      rx_frame_cnt_incr                   <= '0;
      client_rx_errored_frames_latched    <= '0;
      client_rx_bytes_received_latched    <= '0;
      client_rx_frames_received_latched   <= '0;
      rx_axis_tvalid_r                         <= 1'h0;
      rx_axis_tvalid_r2                         <= 1'h0;
      rx_axis_tvalid_r3                         <= 1'h0;
      rx_axis_tvalid_r4                         <= 1'h0;
      rx_axis_tlast_r                         <= 1'h0;
      rx_axis_tlast_r2                         <= 1'h0;
      rx_axis_tlast_r3                         <= 1'h0;
      rx_axis_tlast_r4                         <= 1'h0;
      rx_axis_tkeep_user0_r                   <= 11'h0;
      rx_axis_tkeep_user0_r2                   <= 11'h0;
      rx_axis_tkeep_user0_r3                   <= 11'h0;
      rx_axis_tkeep_user0_r4                   <= 11'h0;
      rx_byte_cnt_incr                    <= '0;
      rx_tkeep_sum_r                      <= '0;
      rx_tkeep_user0_sum_r                <= '0;
      rx_tkeep_user1_sum_r                <= '0;
      rx_tkeep_user2_3_sum_r              <= '0;
      rx_tkeep_user4_5_sum_r              <= '0;
      rx_tkeep_sum_more_than_two_r        <= '0;
      rx_tkeep_sum_lt_eq_two_r            <= '0;
      rx_fcs_compensation_nonsegmented_r  <= '0;
      rx_fcs_compensation_nonsegmented_r2 <= '0;
      rx_fcs_compensation_nonsegmented_r3 <= '0;
      rx_fcs_compensate_q1                     <= 1'b0;
      rx_fcs_compensate_q2                     <= 1'b0;
      rx_number_of_segments_q1                 <= 3'd2;
      rx_number_of_segments_q2                 <= 3'd2;
      rx_axis_tkeep_user1_r                    <= 11'h0;
      rx_axis_tkeep_user2_r                    <= 11'h0;
      rx_axis_tkeep_user3_r                    <= 11'h0;
      rx_axis_tkeep_user4_r                    <= 11'h0;
      rx_axis_tkeep_user5_r                    <= 11'h0;
    end else begin
      rx_errored_frame_cnt_incr           <= '0;
      rx_frame_cnt_incr                   <= '0;
      clear_rx_counters_q1                     <= clear_rx_counters;
      clear_rx_counters_q2                     <= clear_rx_counters_q1;
      clear_rx_counters_q3                     <= clear_rx_counters_q2;
      clear_rx_counters_rising_q               <= {clear_rx_counters_rising_q[0],clear_rx_counters_rising};
      rx_axis_tvalid_r                          <= rx_axis_tvalid;
      rx_axis_tvalid_r2                         <= rx_axis_tvalid_r;
      rx_axis_tvalid_r3                         <= rx_axis_tvalid_r2;
      rx_axis_tvalid_r4                         <= rx_axis_tvalid_r3;
      rx_axis_tlast_r                          <= rx_axis_tlast;
      rx_axis_tlast_r2                         <= rx_axis_tlast_r;
      rx_axis_tlast_r3                         <= rx_axis_tlast_r2;
      rx_axis_tlast_r4                         <= rx_axis_tlast_r3;
      rx_axis_tkeep_user0_r                    <= rx_axis_tkeep_user0;
      rx_axis_tkeep_user0_r2                   <= rx_axis_tkeep_user0_r;
      rx_axis_tkeep_user0_r3                   <= rx_axis_tkeep_user0_r2;
      rx_axis_tkeep_user0_r4                   <= rx_axis_tkeep_user0_r3;
      rx_byte_cnt_incr                    <= '0;
      rx_tkeep_user0_sum_r                <= rx_tkeep_user0_sum;
      rx_tkeep_user1_sum_r                <= rx_tkeep_user1_sum;
      rx_tkeep_user2_3_sum_r              <= rx_tkeep_user2_3_sum;
      rx_tkeep_user4_5_sum_r              <= rx_tkeep_user4_5_sum;
      rx_fcs_compensation_nonsegmented_r  <= rx_fcs_compensation_nonsegmented;
      rx_fcs_compensation_nonsegmented_r2 <= rx_fcs_compensation_nonsegmented_r;
      rx_fcs_compensation_nonsegmented_r3 <= rx_fcs_compensation_nonsegmented_r2;
      rx_fcs_compensate_q1                     <= rx_fcs_compensate;
      rx_fcs_compensate_q2                     <= rx_fcs_compensate_q1;
      rx_number_of_segments_q1                 <= number_of_segments;
      rx_number_of_segments_q2                 <= rx_number_of_segments_q1;
      rx_axis_tkeep_user1_r                    <= rx_axis_tkeep_user1;
      rx_axis_tkeep_user2_r                    <= rx_axis_tkeep_user2;
      rx_axis_tkeep_user3_r                    <= rx_axis_tkeep_user3;
      rx_axis_tkeep_user4_r                    <= rx_axis_tkeep_user4;
      rx_axis_tkeep_user5_r                    <= rx_axis_tkeep_user5;

      if(rx_number_of_segments_q2 <= 2)
        rx_tkeep_sum_more_than_two_r <= '0;
      else if(rx_number_of_segments_q2 < 5)
        rx_tkeep_sum_more_than_two_r <= rx_tkeep_user2_3_sum_r;
      else
        rx_tkeep_sum_more_than_two_r <= rx_tkeep_user2_3_sum_r + rx_tkeep_user4_5_sum_r;

      if(rx_number_of_segments_q2 == 1)
        rx_tkeep_sum_lt_eq_two_r <= rx_tkeep_user0_sum_r;
      else
        rx_tkeep_sum_lt_eq_two_r <= rx_tkeep_user0_sum_r + rx_tkeep_user1_sum_r;

      rx_tkeep_sum_r <= rx_tkeep_sum_lt_eq_two_r + rx_tkeep_sum_more_than_two_r;

      if (rx_axis_tlast_r4 && rx_axis_tvalid_r4) begin
        rx_frame_cnt_incr           <= 1'b1;              
        rx_errored_frame_cnt_incr   <= rx_axis_tkeep_user0_r4[8];              
      end
      if (rx_axis_tvalid_r4) begin
        rx_byte_cnt_incr              <= rx_tkeep_sum_r + rx_fcs_compensation_nonsegmented_r3;
      end
      if (clear_rx_counters_rising_q[1]) begin
        client_rx_errored_frames_latched  <= {32'h0,client_rx_errored_frames[31:0]};
        client_rx_frames_received_latched <= {28'h0,client_rx_frames_received[35:0]};
        client_rx_bytes_received_latched  <= {{(64-BYTE_CNT_WIDTH){1'b0}},client_rx_bytes_received};
      end
    end
  end

  assign clear_rx_counters_rising               = clear_rx_counters_q2 && (!clear_rx_counters_q3);
  assign clear_tx_counters_rising               = clear_tx_counters_q2 && (!clear_tx_counters_q3);

mrmac_0_core_lbus_pkt_gen_256b i_mrmac_0_pkt_gen_50g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && (ctl_data_rate == 2'b11)),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_50g),
  .tx_busy_led         (tx_busy_led_50g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_50g),
  .tx_eopin0           (tx_axis_tlast_50g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_50g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_50g),
  .tx_datain1          (client_tx_axis_tdata1_50g),		
  .tx_mtyin1           (client_tx_axis_tkeep_user1_50g[7:0]),
  .tx_datain2          (client_tx_axis_tdata2),		
  .tx_mtyin2           (client_tx_axis_tkeep_user2[7:0]),
  .tx_datain3          (client_tx_axis_tdata3),		
  .tx_mtyin3           (client_tx_axis_tkeep_user3[7:0]),
  .state               (),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

mrmac_0_core_lbus_pkt_gen_128b i_mrmac_0_pkt_gen_25g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && (ctl_data_rate == 2'b01)),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_25g),
  .tx_busy_led         (tx_busy_led_25g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_25g),
  .tx_eopin0           (tx_axis_tlast_25g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_25g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_25g),
  .tx_datain1          (client_tx_axis_tdata1_25g),		
  .tx_mtyin1           (client_tx_axis_tkeep_user1_25g[7:0]),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

mrmac_0_core_lbus_pkt_gen_32b i_mrmac_0_pkt_gen_10g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && (ctl_data_rate == 2'b00)),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_10g),
  .tx_busy_led         (tx_busy_led_10g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_10g),
  .tx_eopin0           (tx_axis_tlast_10g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_10g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_10g),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

always@(*) begin
  case (ctl_data_rate)
    2'b00 : begin
      tx_done_led   = tx_done_led_10g;
      tx_busy_led   = tx_busy_led_10g;
      client_tx_axis_tdata0 = client_tx_axis_tdata0_10g;
      client_tx_axis_tkeep_user0[7:0] = client_tx_axis_tkeep_user0_10g;
      tx_axis_tvalid = tx_axis_tvalid_10g;
      tx_axis_tlast  = tx_axis_tlast_10g;
    end
    2'b01 : begin
      tx_done_led   = tx_done_led_25g;
      tx_busy_led   = tx_busy_led_25g;
      client_tx_axis_tdata0 = client_tx_axis_tdata0_25g;
      client_tx_axis_tkeep_user0[7:0] = client_tx_axis_tkeep_user0_25g;
      tx_axis_tvalid = tx_axis_tvalid_25g;
      tx_axis_tlast  = tx_axis_tlast_25g;
    end
    default : begin
      tx_done_led   = tx_done_led_50g;
      tx_busy_led   = tx_busy_led_50g;
      client_tx_axis_tdata0 = client_tx_axis_tdata0_50g;
      client_tx_axis_tkeep_user0[7:0] = client_tx_axis_tkeep_user0_50g;
      tx_axis_tvalid = tx_axis_tvalid_50g;
      tx_axis_tlast  = tx_axis_tlast_50g;
    end
  endcase
end

always@(*) begin
  case (ctl_data_rate)
    2'b01 : begin
      client_tx_axis_tdata1 = client_tx_axis_tdata1_25g;
      client_tx_axis_tkeep_user1[7:0] = client_tx_axis_tkeep_user1_25g;
    end
    default : begin
      client_tx_axis_tdata1 = client_tx_axis_tdata1_50g;
      client_tx_axis_tkeep_user1[7:0] = client_tx_axis_tkeep_user1_50g;
    end
  endcase
end

  mrmac_0_crc_wrapper i_mrmac_0_crc_wrapper_inst
  (
   .tx_clk                  (tx_clk),
   .rx_clk                  (rx_clk),
   .tx_reset                (tx_reset),
   .rx_reset                (rx_reset),

   .number_of_segments      (tx_number_of_segments_q2),
   .ten_gb_mode             (ten_gb_mode),

   // TX AXIS
   .tvalid                  (tx_axis_tvalid),
   .tdata                   ({128'd0,client_tx_axis_tdata3,client_tx_axis_tdata2,client_tx_axis_tdata1,client_tx_axis_tdata0}),
   .tkeep                   ({22'd0,client_tx_axis_tkeep_user3,client_tx_axis_tkeep_user2,client_tx_axis_tkeep_user1,client_tx_axis_tkeep_user0}),
   .tlast                   (tx_axis_tlast),
   .tready                  (tx_axis_tready),

   // RX AXIS
   .rvalid                  (rx_axis_tvalid),
   .rdata                   ({128'd0,rx_axis_tdata3,rx_axis_tdata2,rx_axis_tdata1,rx_axis_tdata0}),
   .rkeep                   ({22'd0,rx_axis_tkeep_user3,rx_axis_tkeep_user2,rx_axis_tkeep_user1,rx_axis_tkeep_user0}),
   .rlast                   (rx_axis_tlast),

   .fifo_reset              (crc_fifo_reset),

   // CRC error count
   .crc_error_cnt_latch_clr (clear_rx_counters_rising_q[0]),
   .crc_error_cnt           (crc_error_cnt)

   );

mrmac_0_hs_counter #(.CNT_WIDTH  (BYTE_CNT_WIDTH),
             .INCR_WIDTH (6),
             .SATURATE   (0))
i_mrmac_0_hs_counter_rx_byte_cnt
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_byte_cnt_incr),
   .cnt   (client_rx_bytes_received)
   );


mrmac_0_hs_counter #(.CNT_WIDTH  (32),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_rx_errored_frame_cnt  
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_errored_frame_cnt_incr),
   .cnt   (client_rx_errored_frames)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (36),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_rx_frame_cnt  
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_frame_cnt_incr),
   .cnt   (client_rx_frames_received)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (36),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_tx_frame_cnt  
  (
   .clk   (tx_clk),
   .reset (tx_reset), // sync reset
   .clear (clear_tx_counters_rising_q[0]),   
   .incr  (tx_frame_cnt_incr),
   .cnt   (client_tx_frames_transmitted)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (BYTE_CNT_WIDTH),
             .INCR_WIDTH (6),
             .SATURATE   (0))
i_mrmac_0_hs_counter_tx_byte_cnt
  (
   .clk   (tx_clk),
   .reset (tx_reset), // sync reset
   .clear (clear_tx_counters_rising_q[0]),
   .incr  (tx_byte_cnt_incr),
   .cnt   (client_tx_bytes_transmitted)
   );


endmodule

////// PORT 1 or 3
module mrmac_0_prbs_gen_crc_check_async_25g
   (
  input tx_clk,
  input tx_reset,
  input rx_clk,
  input rx_reset,

  input                   segmented_mode,
  input         [2:0]     number_of_segments,
  input                   ten_gb_mode,
  input [15:0]            DUPLEX_PKT_SIZE,
  input                   start_prbs,
  input                   stop_prbs_tx,
  input  [47:0]           tx_mac_dest_addr,
  input  [47:0]           tx_mac_src_addr,
  input                   tx_axis_ovfout,
  input                   tx_axis_unfout,
  input                   clear_rx_counters,
  input                   clear_tx_counters,
  input                   ctl_data_rate,
  input                   tx_fcs_compensate,
  input                   rx_fcs_compensate,

  output logic [63:0]          client_tx_axis_tdata0,
  output logic [63:0]          client_tx_axis_tdata1,
  output logic [63:0]          client_tx_axis_tdata2,
  output logic [63:0]          client_tx_axis_tdata3,
  output logic [63:0]          client_tx_axis_tdata4,
  output logic [63:0]          client_tx_axis_tdata5,
  output logic [10:0]          client_tx_axis_tkeep_user0,
  output logic [10:0]          client_tx_axis_tkeep_user1,
  output logic [10:0]          client_tx_axis_tkeep_user2,
  output logic [10:0]          client_tx_axis_tkeep_user3,
  output logic [10:0]          client_tx_axis_tkeep_user4,
  output logic [10:0]          client_tx_axis_tkeep_user5,
  output logic                 tx_axis_tvalid,
  output logic                 tx_axis_tlast,
  input                        tx_axis_tready,

  input                        rx_axis_tvalid,
  input [63:0]                 rx_axis_tdata0,
  input [63:0]                 rx_axis_tdata1,
  input [63:0]                 rx_axis_tdata2,
  input [63:0]                 rx_axis_tdata3,
  input [63:0]                 rx_axis_tdata4,
  input [63:0]                 rx_axis_tdata5,
  input [10:0]                 rx_axis_tkeep_user0,
  input [10:0]                 rx_axis_tkeep_user1,
  input [10:0]                 rx_axis_tkeep_user2,
  input [10:0]                 rx_axis_tkeep_user3,
  input [10:0]                 rx_axis_tkeep_user4,
  input [10:0]                 rx_axis_tkeep_user5,
  input                        rx_axis_tlast,

  input                   crc_fifo_reset,
  output reg [63:0]     client_tx_frames_transmitted_latched,
  output reg  [63:0]    client_tx_bytes_transmitted_latched,
  output logic 	          tx_done_led,
  output logic 	          tx_busy_led,
  output   reg  [63:0]    client_rx_errored_frames_latched,
  output   reg  [63:0]    client_rx_bytes_received_latched,
  output   reg  [63:0]    client_rx_frames_received_latched,
  output logic [31:0]     crc_error_cnt
);

localparam BYTE_CNT_WIDTH   = 48;

  reg [2:0]          tx_number_of_segments_q1, tx_number_of_segments_q2;
  wire              clear_rx_counters_rising;
  logic [1:0]       clear_rx_counters_rising_q;
  reg                clear_rx_counters_q1, clear_rx_counters_q2, clear_rx_counters_q3;
  logic [1:0]       clear_tx_counters_rising_q;
  wire              clear_tx_counters_rising;
  reg                clear_tx_counters_q1, clear_tx_counters_q2, clear_tx_counters_q3;

  wire tx_done_led_25g;
  wire tx_busy_led_25g;
  wire [63:0] client_tx_axis_tdata0_25g;
  wire [7:0] client_tx_axis_tkeep_user0_25g;
  wire tx_axis_tvalid_25g;
  wire tx_axis_tlast_25g;

  wire tx_done_led_10g;
  wire tx_busy_led_10g;
  wire [63:0] client_tx_axis_tdata0_10g;
  wire [7:0] client_tx_axis_tkeep_user0_10g;
  wire tx_axis_tvalid_10g;
  wire tx_axis_tlast_10g;
  logic              rx_errored_frame_cnt_incr;
  logic              rx_frame_cnt_incr;
  logic [35:0]               client_rx_frames_received;
  logic [31:0]               client_rx_errored_frames;
  reg                rx_axis_tlast_r, rx_axis_tlast_r2, rx_axis_tlast_r3, rx_axis_tlast_r4;
  reg                rx_axis_tvalid_r, rx_axis_tvalid_r2, rx_axis_tvalid_r3, rx_axis_tvalid_r4;
  reg [10:0]         rx_axis_tkeep_user0_r, rx_axis_tkeep_user0_r2, rx_axis_tkeep_user0_r3, rx_axis_tkeep_user0_r4;
  reg [10:0]         rx_axis_tkeep_user1_r;
  reg [10:0]         rx_axis_tkeep_user2_r;
  reg [10:0]         rx_axis_tkeep_user3_r;
  reg [10:0]         rx_axis_tkeep_user4_r;
  reg [10:0]         rx_axis_tkeep_user5_r;
  logic [35:0]               client_tx_frames_transmitted;
  logic              tx_frame_cnt_incr;
  reg                tx_axis_tready_r, tx_axis_tready_r2, tx_axis_tready_r3, tx_axis_tready_r4;
  reg                tx_axis_tvalid_r, tx_axis_tvalid_r2, tx_axis_tvalid_r3, tx_axis_tvalid_r4;
  reg                tx_axis_tlast_r, tx_axis_tlast_r2, tx_axis_tlast_r3, tx_axis_tlast_r4;
  wire               tx_axis_valid_edge;

  logic [3:0]        tx_tkeep_user0_sum, tx_tkeep_user0_sum_r;
  logic [3:0]        tx_tkeep_user1_sum, tx_tkeep_user1_sum_r;
  logic [4:0]        tx_tkeep_user2_3_sum, tx_tkeep_user2_3_sum_r;
  logic [4:0]        tx_tkeep_user4_5_sum, tx_tkeep_user4_5_sum_r;
  reg [10:0]         client_tx_axis_tkeep_user0_r;
  reg [10:0]         client_tx_axis_tkeep_user1_r;
  reg [10:0]         client_tx_axis_tkeep_user2_r;
  reg [10:0]         client_tx_axis_tkeep_user3_r;
  reg [10:0]         client_tx_axis_tkeep_user4_r;
  reg [10:0]         client_tx_axis_tkeep_user5_r;
  logic [5:0]        tx_byte_cnt_incr;
  wire [35:0]        tx_fcs_compensation_nonsegmented;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r2;
  logic [35:0]       tx_fcs_compensation_nonsegmented_r3;
  reg                tx_fcs_compensate_q1, tx_fcs_compensate_q2;
  logic [BYTE_CNT_WIDTH-1:0] client_tx_bytes_transmitted;
  logic [5:0]        tx_tkeep_sum_r, tx_tkeep_sum_lt_eq_two_r, tx_tkeep_sum_more_than_two_r;

  logic [BYTE_CNT_WIDTH-1:0] client_rx_bytes_received;
  logic [5:0]        rx_byte_cnt_incr;
  logic [3:0]        rx_tkeep_user0_sum, rx_tkeep_user0_sum_r;
  logic [3:0]        rx_tkeep_user1_sum, rx_tkeep_user1_sum_r;
  logic [4:0]        rx_tkeep_user2_3_sum, rx_tkeep_user2_3_sum_r;
  logic [4:0]        rx_tkeep_user4_5_sum, rx_tkeep_user4_5_sum_r;
  logic [5:0]        rx_tkeep_sum_r, rx_tkeep_sum_lt_eq_two_r, rx_tkeep_sum_more_than_two_r;
  wire [35:0]        rx_fcs_compensation_nonsegmented;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r2;
  logic [35:0]       rx_fcs_compensation_nonsegmented_r3;
  reg                rx_fcs_compensate_q1, rx_fcs_compensate_q2;
  reg [2:0]          rx_number_of_segments_q1, rx_number_of_segments_q2;

assign client_tx_axis_tkeep_user0[10:8] = 3'b0;
assign client_tx_axis_tkeep_user1[10:8] = 3'b0;
assign client_tx_axis_tkeep_user2[10:8] = 3'b0;
assign client_tx_axis_tkeep_user3[10:8] = 3'b0;
assign tx_fcs_compensation_nonsegmented     = (tx_fcs_compensate_q2 && tx_axis_tlast_r) ? 4 : 0;
assign rx_fcs_compensation_nonsegmented  = (rx_fcs_compensate_q2 && rx_axis_tlast_r) ? 4 : 0;

  always @(posedge tx_clk) begin
    if (tx_reset == 1'b1) begin
      clear_tx_counters_q1                     <= 1'b0;
      clear_tx_counters_q2                     <= 1'b0;
      clear_tx_counters_q3                     <= 1'b0;
      tx_number_of_segments_q1                 <= 3'd2;
      tx_number_of_segments_q2                 <= 3'd2;
      clear_tx_counters_rising_q               <= '0;      
      client_tx_frames_transmitted_latched   <= '0;
      client_tx_bytes_transmitted_latched   <= '0;
      tx_frame_cnt_incr                      <= '0;
      tx_axis_tlast_r <= 1'h0;
      tx_axis_tlast_r2 <= 1'h0;
      tx_axis_tlast_r3 <= 1'h0;
      tx_axis_tlast_r4 <= 1'h0;
      tx_axis_tready_r <= 1'h0;
      tx_axis_tready_r2 <= 1'h0;
      tx_axis_tready_r3 <= 1'h0;
      tx_axis_tready_r4 <= 1'h0;
      tx_axis_tvalid_r <= 1'h0;
      tx_axis_tvalid_r2 <= 1'h0;
      tx_axis_tvalid_r3 <= 1'h0;
      tx_axis_tvalid_r4 <= 1'h0;
      tx_tkeep_sum_r                         <= '0;
      tx_tkeep_user0_sum_r                   <= '0;
      tx_tkeep_user1_sum_r                   <= '0;
      tx_tkeep_user2_3_sum_r                 <= '0;
      tx_tkeep_user4_5_sum_r                 <= '0;
      tx_tkeep_sum_more_than_two_r           <= '0;
      tx_tkeep_sum_lt_eq_two_r               <= '0;
      client_tx_bytes_transmitted_latched    <= '0;
      client_tx_axis_tkeep_user0_r           <= '0;
      client_tx_axis_tkeep_user1_r           <= '0;
      client_tx_axis_tkeep_user2_r           <= '0;
      client_tx_axis_tkeep_user3_r           <= '0;
      client_tx_axis_tkeep_user4_r           <= '0;
      client_tx_axis_tkeep_user5_r           <= '0;
      tx_byte_cnt_incr                       <= '0;
      tx_fcs_compensation_nonsegmented_r        <= '0;
      tx_fcs_compensation_nonsegmented_r2       <= '0;
      tx_fcs_compensation_nonsegmented_r3       <= '0;
      tx_fcs_compensate_q1                   <= '0;
      tx_fcs_compensate_q2                   <= '0;
    end else begin
      clear_tx_counters_q1                     <= clear_tx_counters;
      clear_tx_counters_q2                     <= clear_tx_counters_q1;
      clear_tx_counters_q3                     <= clear_tx_counters_q2;
      tx_number_of_segments_q1                 <= number_of_segments;
      tx_number_of_segments_q2                 <= tx_number_of_segments_q1;
      clear_tx_counters_rising_q               <= {clear_tx_counters_rising_q[0],clear_tx_counters_rising};      
      tx_frame_cnt_incr                      <= '0;
      tx_axis_tlast_r  <= tx_axis_tlast;
      tx_axis_tlast_r2 <= tx_axis_tlast_r;
      tx_axis_tlast_r3 <= tx_axis_tlast_r2;
      tx_axis_tlast_r4 <= tx_axis_tlast_r3;
      tx_axis_tready_r  <= tx_axis_tready;
      tx_axis_tready_r2 <= tx_axis_tready_r;
      tx_axis_tready_r3 <= tx_axis_tready_r2;
      tx_axis_tready_r4 <= tx_axis_tready_r3;
      tx_axis_tvalid_r  <= tx_axis_tvalid;
      tx_axis_tvalid_r2 <= tx_axis_tvalid_r;
      tx_axis_tvalid_r3 <= tx_axis_tvalid_r2;
      tx_axis_tvalid_r4 <= tx_axis_tvalid_r3;
      tx_tkeep_user0_sum_r                   <= tx_tkeep_user0_sum;
      tx_tkeep_user1_sum_r                   <= tx_tkeep_user1_sum;
      tx_tkeep_user2_3_sum_r                 <= tx_tkeep_user2_3_sum;
      tx_tkeep_user4_5_sum_r                 <= tx_tkeep_user4_5_sum;
      client_tx_axis_tkeep_user0_r           <= client_tx_axis_tkeep_user0;
      client_tx_axis_tkeep_user1_r           <= client_tx_axis_tkeep_user1;
      client_tx_axis_tkeep_user2_r           <= client_tx_axis_tkeep_user2;
      client_tx_axis_tkeep_user3_r           <= client_tx_axis_tkeep_user3;
      client_tx_axis_tkeep_user4_r           <= client_tx_axis_tkeep_user4;
      client_tx_axis_tkeep_user5_r           <= client_tx_axis_tkeep_user5;
      tx_byte_cnt_incr                       <= '0;
      tx_fcs_compensation_nonsegmented_r        <= tx_fcs_compensation_nonsegmented;
      tx_fcs_compensation_nonsegmented_r2       <= tx_fcs_compensation_nonsegmented_r;
      tx_fcs_compensation_nonsegmented_r3       <= tx_fcs_compensation_nonsegmented_r2;
      tx_fcs_compensate_q1                   <= tx_fcs_compensate;
      tx_fcs_compensate_q2                   <= tx_fcs_compensate_q1;

      if(tx_number_of_segments_q2 <= 2)
        tx_tkeep_sum_more_than_two_r <= '0;
      else if(tx_number_of_segments_q2 < 5)
        tx_tkeep_sum_more_than_two_r <= tx_tkeep_user2_3_sum_r;
      else
        tx_tkeep_sum_more_than_two_r <= tx_tkeep_user2_3_sum_r + tx_tkeep_user4_5_sum_r;

      if(tx_number_of_segments_q2 == 1)
        tx_tkeep_sum_lt_eq_two_r <= tx_tkeep_user0_sum_r;
      else
        tx_tkeep_sum_lt_eq_two_r <= tx_tkeep_user0_sum_r + tx_tkeep_user1_sum_r;

      tx_tkeep_sum_r <= tx_tkeep_sum_lt_eq_two_r + tx_tkeep_sum_more_than_two_r;

      if (clear_tx_counters_rising_q[1]) begin
        client_tx_frames_transmitted_latched <= {28'h0,client_tx_frames_transmitted[35:0]};
        client_tx_bytes_transmitted_latched  <= {{(64-BYTE_CNT_WIDTH){1'b0}},client_tx_bytes_transmitted};
      end
        if (tx_axis_tready_r4 && tx_axis_tvalid_r4 && tx_axis_tlast_r4) begin
              tx_frame_cnt_incr              <= 1'b1;              
        end
        if (tx_axis_tready_r4 && tx_axis_tvalid_r4) begin
            tx_byte_cnt_incr                 <= tx_tkeep_sum_r + tx_fcs_compensation_nonsegmented_r3;
        end
    end
  end

  assign tx_tkeep_user0_sum =
    client_tx_axis_tkeep_user0_r[7] + client_tx_axis_tkeep_user0_r[6] + client_tx_axis_tkeep_user0_r[5] +
    client_tx_axis_tkeep_user0_r[4] + client_tx_axis_tkeep_user0_r[3] + client_tx_axis_tkeep_user0_r[2] +
    client_tx_axis_tkeep_user0_r[1] + client_tx_axis_tkeep_user0_r[0];

  assign tx_tkeep_user1_sum =
    client_tx_axis_tkeep_user1_r[7] + client_tx_axis_tkeep_user1_r[6] + client_tx_axis_tkeep_user1_r[5] +
    client_tx_axis_tkeep_user1_r[4] + client_tx_axis_tkeep_user1_r[3] + client_tx_axis_tkeep_user1_r[2] +
    client_tx_axis_tkeep_user1_r[1] + client_tx_axis_tkeep_user1_r[0];

  assign tx_tkeep_user2_3_sum =
    client_tx_axis_tkeep_user2_r[7] + client_tx_axis_tkeep_user2_r[6] + client_tx_axis_tkeep_user2_r[5] +
    client_tx_axis_tkeep_user2_r[4] + client_tx_axis_tkeep_user2_r[3] + client_tx_axis_tkeep_user2_r[2] +
    client_tx_axis_tkeep_user2_r[1] + client_tx_axis_tkeep_user2_r[0] +
    client_tx_axis_tkeep_user3_r[7] + client_tx_axis_tkeep_user3_r[6] + client_tx_axis_tkeep_user3_r[5] +
    client_tx_axis_tkeep_user3_r[4] + client_tx_axis_tkeep_user3_r[3] + client_tx_axis_tkeep_user3_r[2] +
                                      client_tx_axis_tkeep_user3_r[1] + client_tx_axis_tkeep_user3_r[0];

  assign tx_tkeep_user4_5_sum =
    client_tx_axis_tkeep_user4_r[7] + client_tx_axis_tkeep_user4_r[6] + client_tx_axis_tkeep_user4_r[5] +
    client_tx_axis_tkeep_user4_r[4] + client_tx_axis_tkeep_user4_r[3] + client_tx_axis_tkeep_user4_r[2] +
    client_tx_axis_tkeep_user4_r[1] + client_tx_axis_tkeep_user4_r[0] +
    client_tx_axis_tkeep_user5_r[7] + client_tx_axis_tkeep_user5_r[6] + client_tx_axis_tkeep_user5_r[5] +
    client_tx_axis_tkeep_user5_r[4] + client_tx_axis_tkeep_user5_r[3] + client_tx_axis_tkeep_user5_r[2] +
    client_tx_axis_tkeep_user5_r[1] + client_tx_axis_tkeep_user5_r[0];

  assign rx_tkeep_user0_sum =
    rx_axis_tkeep_user0_r[7] + rx_axis_tkeep_user0_r[6] + rx_axis_tkeep_user0_r[5] +
    rx_axis_tkeep_user0_r[4] + rx_axis_tkeep_user0_r[3] + rx_axis_tkeep_user0_r[2] +
    rx_axis_tkeep_user0_r[1] + rx_axis_tkeep_user0_r[0];

  assign rx_tkeep_user1_sum =
    rx_axis_tkeep_user1_r[7] + rx_axis_tkeep_user1_r[6] + rx_axis_tkeep_user1_r[5] +
    rx_axis_tkeep_user1_r[4] + rx_axis_tkeep_user1_r[3] + rx_axis_tkeep_user1_r[2] +
    rx_axis_tkeep_user1_r[1] + rx_axis_tkeep_user1_r[0];

  assign rx_tkeep_user2_3_sum =
    rx_axis_tkeep_user2_r[7] + rx_axis_tkeep_user2_r[6] + rx_axis_tkeep_user2_r[5] +
    rx_axis_tkeep_user2_r[4] + rx_axis_tkeep_user2_r[3] + rx_axis_tkeep_user2_r[2] +
    rx_axis_tkeep_user2_r[1] + rx_axis_tkeep_user2_r[0] +
    rx_axis_tkeep_user3_r[7] + rx_axis_tkeep_user3_r[6] + rx_axis_tkeep_user3_r[5] +
    rx_axis_tkeep_user3_r[4] + rx_axis_tkeep_user3_r[3] + rx_axis_tkeep_user3_r[2] +
                                      rx_axis_tkeep_user3_r[1] + rx_axis_tkeep_user3_r[0];

  assign rx_tkeep_user4_5_sum =
    rx_axis_tkeep_user4_r[7] + rx_axis_tkeep_user4_r[6] + rx_axis_tkeep_user4_r[5] +
    rx_axis_tkeep_user4_r[4] + rx_axis_tkeep_user4_r[3] + rx_axis_tkeep_user4_r[2] +
    rx_axis_tkeep_user4_r[1] + rx_axis_tkeep_user4_r[0] +
    rx_axis_tkeep_user5_r[7] + rx_axis_tkeep_user5_r[6] + rx_axis_tkeep_user5_r[5] +
    rx_axis_tkeep_user5_r[4] + rx_axis_tkeep_user5_r[3] + rx_axis_tkeep_user5_r[2] +
    rx_axis_tkeep_user5_r[1] + rx_axis_tkeep_user5_r[0];


  always @(posedge rx_clk) begin
    if (rx_reset == 1'b1) begin
      clear_rx_counters_q1                     <= 1'b0;
      clear_rx_counters_q2                     <= 1'b0;
      clear_rx_counters_q3                     <= 1'b0;
      clear_rx_counters_rising_q               <= '0;
      rx_errored_frame_cnt_incr           <= '0;      
      rx_frame_cnt_incr                   <= '0;
      client_rx_errored_frames_latched    <= '0;
      client_rx_bytes_received_latched    <= '0;
      client_rx_frames_received_latched   <= '0;
      rx_axis_tvalid_r                         <= 1'h0;
      rx_axis_tvalid_r2                         <= 1'h0;
      rx_axis_tvalid_r3                         <= 1'h0;
      rx_axis_tvalid_r4                         <= 1'h0;
      rx_axis_tlast_r                         <= 1'h0;
      rx_axis_tlast_r2                         <= 1'h0;
      rx_axis_tlast_r3                         <= 1'h0;
      rx_axis_tlast_r4                         <= 1'h0;
      rx_axis_tkeep_user0_r                   <= 11'h0;
      rx_axis_tkeep_user0_r2                   <= 11'h0;
      rx_axis_tkeep_user0_r3                   <= 11'h0;
      rx_axis_tkeep_user0_r4                   <= 11'h0;
      rx_byte_cnt_incr                    <= '0;
      rx_tkeep_sum_r                      <= '0;
      rx_tkeep_user0_sum_r                <= '0;
      rx_tkeep_user1_sum_r                <= '0;
      rx_tkeep_user2_3_sum_r              <= '0;
      rx_tkeep_user4_5_sum_r              <= '0;
      rx_tkeep_sum_more_than_two_r        <= '0;
      rx_tkeep_sum_lt_eq_two_r            <= '0;
      rx_fcs_compensation_nonsegmented_r  <= '0;
      rx_fcs_compensation_nonsegmented_r2 <= '0;
      rx_fcs_compensation_nonsegmented_r3 <= '0;
      rx_fcs_compensate_q1                     <= 1'b0;
      rx_fcs_compensate_q2                     <= 1'b0;
      rx_number_of_segments_q1                 <= 3'd2;
      rx_number_of_segments_q2                 <= 3'd2;
      rx_axis_tkeep_user1_r                    <= 11'h0;
      rx_axis_tkeep_user2_r                    <= 11'h0;
      rx_axis_tkeep_user3_r                    <= 11'h0;
      rx_axis_tkeep_user4_r                    <= 11'h0;
      rx_axis_tkeep_user5_r                    <= 11'h0;
    end else begin
      rx_errored_frame_cnt_incr           <= '0;
      rx_frame_cnt_incr                   <= '0;
      clear_rx_counters_q1                     <= clear_rx_counters;
      clear_rx_counters_q2                     <= clear_rx_counters_q1;
      clear_rx_counters_q3                     <= clear_rx_counters_q2;
      clear_rx_counters_rising_q               <= {clear_rx_counters_rising_q[0],clear_rx_counters_rising};
      rx_axis_tvalid_r                          <= rx_axis_tvalid;
      rx_axis_tvalid_r2                         <= rx_axis_tvalid_r;
      rx_axis_tvalid_r3                         <= rx_axis_tvalid_r2;
      rx_axis_tvalid_r4                         <= rx_axis_tvalid_r3;
      rx_axis_tlast_r                          <= rx_axis_tlast;
      rx_axis_tlast_r2                         <= rx_axis_tlast_r;
      rx_axis_tlast_r3                         <= rx_axis_tlast_r2;
      rx_axis_tlast_r4                         <= rx_axis_tlast_r3;
      rx_axis_tkeep_user0_r                    <= rx_axis_tkeep_user0;
      rx_axis_tkeep_user0_r2                   <= rx_axis_tkeep_user0_r;
      rx_axis_tkeep_user0_r3                   <= rx_axis_tkeep_user0_r2;
      rx_axis_tkeep_user0_r4                   <= rx_axis_tkeep_user0_r3;
      rx_byte_cnt_incr                    <= '0;
      rx_tkeep_user0_sum_r                <= rx_tkeep_user0_sum;
      rx_tkeep_user1_sum_r                <= rx_tkeep_user1_sum;
      rx_tkeep_user2_3_sum_r              <= rx_tkeep_user2_3_sum;
      rx_tkeep_user4_5_sum_r              <= rx_tkeep_user4_5_sum;
      rx_fcs_compensation_nonsegmented_r  <= rx_fcs_compensation_nonsegmented;
      rx_fcs_compensation_nonsegmented_r2 <= rx_fcs_compensation_nonsegmented_r;
      rx_fcs_compensation_nonsegmented_r3 <= rx_fcs_compensation_nonsegmented_r2;
      rx_fcs_compensate_q1                     <= rx_fcs_compensate;
      rx_fcs_compensate_q2                     <= rx_fcs_compensate_q1;
      rx_number_of_segments_q1                 <= number_of_segments;
      rx_number_of_segments_q2                 <= rx_number_of_segments_q1;
      rx_axis_tkeep_user1_r                    <= rx_axis_tkeep_user1;
      rx_axis_tkeep_user2_r                    <= rx_axis_tkeep_user2;
      rx_axis_tkeep_user3_r                    <= rx_axis_tkeep_user3;
      rx_axis_tkeep_user4_r                    <= rx_axis_tkeep_user4;
      rx_axis_tkeep_user5_r                    <= rx_axis_tkeep_user5;

      if(rx_number_of_segments_q2 <= 2)
        rx_tkeep_sum_more_than_two_r <= '0;
      else if(rx_number_of_segments_q2 < 5)
        rx_tkeep_sum_more_than_two_r <= rx_tkeep_user2_3_sum_r;
      else
        rx_tkeep_sum_more_than_two_r <= rx_tkeep_user2_3_sum_r + rx_tkeep_user4_5_sum_r;

      if(rx_number_of_segments_q2 == 1)
        rx_tkeep_sum_lt_eq_two_r <= rx_tkeep_user0_sum_r;
      else
        rx_tkeep_sum_lt_eq_two_r <= rx_tkeep_user0_sum_r + rx_tkeep_user1_sum_r;

      rx_tkeep_sum_r <= rx_tkeep_sum_lt_eq_two_r + rx_tkeep_sum_more_than_two_r;

      if (rx_axis_tlast_r4 && rx_axis_tvalid_r4) begin
        rx_frame_cnt_incr           <= 1'b1;              
        rx_errored_frame_cnt_incr   <= rx_axis_tkeep_user0_r4[8];              
      end
      if (rx_axis_tvalid_r4) begin
        rx_byte_cnt_incr              <= rx_tkeep_sum_r + rx_fcs_compensation_nonsegmented_r3;
      end
      if (clear_rx_counters_rising_q[1]) begin
        client_rx_errored_frames_latched  <= {32'h0,client_rx_errored_frames[31:0]};
        client_rx_frames_received_latched <= {28'h0,client_rx_frames_received[35:0]};
        client_rx_bytes_received_latched  <= {{(64-BYTE_CNT_WIDTH){1'b0}},client_rx_bytes_received};
      end
    end
  end

  assign clear_rx_counters_rising               = clear_rx_counters_q2 && (!clear_rx_counters_q3);
  assign clear_tx_counters_rising               = clear_tx_counters_q2 && (!clear_tx_counters_q3);

mrmac_0_core_lbus_pkt_gen_128b i_mrmac_0_pkt_gen_25g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && ctl_data_rate),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_25g),
  .tx_busy_led         (tx_busy_led_25g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_25g),
  .tx_eopin0           (tx_axis_tlast_25g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_25g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_25g),
  .tx_datain1          (client_tx_axis_tdata1),
  .tx_mtyin1           (client_tx_axis_tkeep_user1[7:0]),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

  mrmac_0_core_lbus_pkt_gen_32b i_mrmac_0_pkt_gen_10g
  (
  .clk                 (tx_clk),
  .resetn              (!tx_reset && !ctl_data_rate),
  .DUPLEX_PKT_SIZE     (DUPLEX_PKT_SIZE),
  .start_prbs          (start_prbs),
  .stop_prbs           (stop_prbs_tx),
  .tx_mac_dest_addr    (tx_mac_dest_addr),
  .tx_mac_src_addr     (tx_mac_src_addr),
  .tx_done_led         (tx_done_led_10g),
  .tx_busy_led         (tx_busy_led_10g),
  .tx_rdyout           (tx_axis_tready),
  .tx_datain0          (client_tx_axis_tdata0_10g),
  .tx_eopin0           (tx_axis_tlast_10g),
  .tx_mtyin0           (client_tx_axis_tkeep_user0_10g[7:0]),
  .tx_axis_tvalid_0    (tx_axis_tvalid_10g),
  .tx_ovfout           (tx_axis_ovfout),
  .tx_unfout           (tx_axis_unfout)
  );

assign tx_done_led = ctl_data_rate ? tx_done_led_25g : tx_done_led_10g;
assign tx_busy_led = ctl_data_rate ? tx_busy_led_25g : tx_busy_led_10g;

assign client_tx_axis_tdata0 = ctl_data_rate ? client_tx_axis_tdata0_25g : client_tx_axis_tdata0_10g;
assign client_tx_axis_tkeep_user0[7:0] = ctl_data_rate ? client_tx_axis_tkeep_user0_25g : client_tx_axis_tkeep_user0_10g;
assign tx_axis_tvalid = ctl_data_rate ? tx_axis_tvalid_25g : tx_axis_tvalid_10g;
assign tx_axis_tlast = ctl_data_rate ? tx_axis_tlast_25g : tx_axis_tlast_10g;

  mrmac_0_crc_wrapper i_mrmac_0_crc_wrapper_inst
  (
   .tx_clk                  (tx_clk),
   .rx_clk                  (rx_clk),
   .tx_reset                (tx_reset),
   .rx_reset                (rx_reset),

   .number_of_segments      (tx_number_of_segments_q2),
   .ten_gb_mode             (ten_gb_mode),

   // TX AXIS
   .tvalid                  (tx_axis_tvalid),
   .tdata                   ({256'd0,client_tx_axis_tdata1,client_tx_axis_tdata0}),
   .tkeep                   ({44'd0,client_tx_axis_tkeep_user1,client_tx_axis_tkeep_user0}),
   .tlast                   (tx_axis_tlast),
   .tready                  (tx_axis_tready),

   // RX AXIS
   .rvalid                  (rx_axis_tvalid),
   .rdata                   ({256'd0,rx_axis_tdata1,rx_axis_tdata0}),
   .rkeep                   ({44'd0,rx_axis_tkeep_user1,rx_axis_tkeep_user0}),
   .rlast                   (rx_axis_tlast),

   .fifo_reset              (crc_fifo_reset),

   // CRC error count
   .crc_error_cnt_latch_clr (clear_rx_counters_rising_q[0]),
   .crc_error_cnt           (crc_error_cnt)

   );

mrmac_0_hs_counter #(.CNT_WIDTH  (BYTE_CNT_WIDTH),
             .INCR_WIDTH (6),
             .SATURATE   (0))
i_mrmac_0_hs_counter_rx_byte_cnt
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_byte_cnt_incr),
   .cnt   (client_rx_bytes_received)
   );


mrmac_0_hs_counter #(.CNT_WIDTH  (32),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_rx_errored_frame_cnt  
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_errored_frame_cnt_incr),
   .cnt   (client_rx_errored_frames)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (36),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_rx_frame_cnt  
  (
   .clk   (rx_clk),
   .reset (rx_reset), // sync reset
   .clear (clear_rx_counters_rising_q[0]),
   .incr  (rx_frame_cnt_incr),
   .cnt   (client_rx_frames_received)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (36),
             .INCR_WIDTH (1),
             .SATURATE   (0))                         
i_mrmac_0_hs_counter_tx_frame_cnt  
  (
   .clk   (tx_clk),
   .reset (tx_reset), // sync reset
   .clear (clear_tx_counters_rising_q[0]),   
   .incr  (tx_frame_cnt_incr),
   .cnt   (client_tx_frames_transmitted)
   );

mrmac_0_hs_counter #(.CNT_WIDTH  (BYTE_CNT_WIDTH),
             .INCR_WIDTH (6),
             .SATURATE   (0))
i_mrmac_0_hs_counter_tx_byte_cnt
  (
   .clk   (tx_clk),
   .reset (tx_reset), // sync reset
   .clear (clear_tx_counters_rising_q[0]),
   .incr  (tx_byte_cnt_incr),
   .cnt   (client_tx_bytes_transmitted)
   );


endmodule
