
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

(* DowngradeIPIdentifiedWarnings="yes" *)
module mrmac_0_exdes
(
	input  wire [7:0] gt_line_rate,
	input wire            s_axi_aclk,
	input wire            s_axi_aresetn,
	input wire [31 : 0]   s_axi_awaddr,
	input wire            s_axi_awvalid,
	output wire           s_axi_awready,
	input wire [31 : 0]   s_axi_wdata,
	input wire            s_axi_wvalid,
	output wire           s_axi_wready,
	output wire [1 : 0]   s_axi_bresp,
	output wire           s_axi_bvalid,
	input wire            s_axi_bready,
	input wire [31 : 0]   s_axi_araddr,
	input wire            s_axi_arvalid,
	output wire           s_axi_arready,
	output wire [31 : 0]  s_axi_rdata,
	output wire [1 : 0]   s_axi_rresp,
	output wire           s_axi_rvalid,
	input wire            s_axi_rready,
 	  
 	
 
 
 	
	
	
	input wire   [2:0]     c0_top_ctl_muxes,
	input wire   [2:0]     c0_number_of_segments,
    input wire             c0_ten_gb_mode,	
    input wire             c0_trig_in,
    input wire  [2:0]      c0_top_ctl_data_rate,
	input wire             c1_trig_in,

	input wire  [2:0]      c1_number_of_segments,  ////(1: 10G, 2: 25G)
	input wire             c1_ten_gb_mode,
	input wire  [2:0]      c1_top_ctl_data_rate,   //// 10G  3'b000 : 25G  3'b001 
	input wire             c2_trig_in,

	input wire  [2:0]      c2_number_of_segments, ////(1: 10G, 2: 25G, 4:50G)
	input wire             c2_ten_gb_mode,
	input wire  [2:0]      c2_top_ctl_data_rate,  //// 10G  3'b000 : 25G  3'b001 : 50G  3'b011 	
	input wire             c3_trig_in,

	input wire  [2:0]      c3_number_of_segments, ////(1: 10G, 2: 25G)
	input wire             c3_ten_gb_mode,
	input wire             c3_crc_fifo_reset,
	input wire  [2:0]      c3_top_ctl_data_rate,  ////// 10G  3'b000 : 25G  3'b001 		
    output wire [3:0] stat_mst_reset_done,

    input  wire [3:0] gt_rxn_in,
    input  wire [3:0] gt_rxp_in,
    output wire [3:0] gt_txn_out,
    output wire [3:0] gt_txp_out,

    input  wire  [3:0] gt_reset_all_in,
    input  wire [2:0] gt_loopback,
    input wire [3:0] gt_reset_tx_datapath_in,
    input wire [3:0] gt_reset_rx_datapath_in,
    input  wire       gt_ref_clk_p,
    input  wire       gt_ref_clk_n,
    input  wire       pl_clk,
	input  wire       pl_resetn
);


  
  wire [3:0] pm_rdy;
  wire [63:0] rx_axis_tdata0;
  wire [63:0] rx_axis_tdata1;
  wire [63:0] rx_axis_tdata2;
  wire [63:0] rx_axis_tdata3;
  wire [63:0] rx_axis_tdata4;
  wire [63:0] rx_axis_tdata5;
  wire [63:0] rx_axis_tdata6;
  wire [63:0] rx_axis_tdata7;
  wire [10:0] rx_axis_tkeep_user0;
  wire [10:0] rx_axis_tkeep_user1;
  wire [10:0] rx_axis_tkeep_user2;
  wire [10:0] rx_axis_tkeep_user3;
  wire [10:0] rx_axis_tkeep_user4;
  wire [10:0] rx_axis_tkeep_user5;
  wire [10:0] rx_axis_tkeep_user6;
  wire [10:0] rx_axis_tkeep_user7;
  wire rx_axis_tlast_0;
  wire rx_axis_tlast_1;
  wire rx_axis_tlast_2;
  wire rx_axis_tlast_3;
  wire rx_axis_tvalid_0;
  wire rx_axis_tvalid_1;
  wire rx_axis_tvalid_2;
  wire rx_axis_tvalid_3;
  wire rx_flex_almarker0;
  wire rx_flex_almarker1;
  wire rx_flex_almarker2;
  wire rx_flex_almarker3;
  wire rx_flex_almarker4;
  wire rx_flex_almarker5;
  wire rx_flex_almarker6;
  wire rx_flex_almarker7;
  wire [7:0] rx_flex_bip80;
  wire [7:0] rx_flex_bip81;
  wire [7:0] rx_flex_bip82;
  wire [7:0] rx_flex_bip83;
  wire [7:0] rx_flex_bip84;
  wire [7:0] rx_flex_bip85;
  wire [7:0] rx_flex_bip86;
  wire [7:0] rx_flex_bip87;
  wire rx_flex_cm_stallout_0;
  wire rx_flex_cm_stallout_1;
  wire rx_flex_cm_stallout_2;
  wire rx_flex_cm_stallout_3;
  wire [65:0] rx_flex_data0;
  wire [65:0] rx_flex_data1;
  wire [65:0] rx_flex_data2;
  wire [65:0] rx_flex_data3;
  wire [65:0] rx_flex_data4;
  wire [65:0] rx_flex_data5;
  wire [65:0] rx_flex_data6;
  wire [65:0] rx_flex_data7;
  wire rx_flex_ena_0;
  wire rx_flex_ena_1;
  wire rx_flex_ena_2;
  wire rx_flex_ena_3;
  wire rx_flex_lane0;
  wire [7:0] rx_lane_aligner_fill_0;
  wire [7:0] rx_lane_aligner_fill_1;
  wire [7:0] rx_lane_aligner_fill_10;
  wire [7:0] rx_lane_aligner_fill_11;
  wire [7:0] rx_lane_aligner_fill_12;
  wire [7:0] rx_lane_aligner_fill_13;
  wire [7:0] rx_lane_aligner_fill_14;
  wire [7:0] rx_lane_aligner_fill_15;
  wire [7:0] rx_lane_aligner_fill_16;
  wire [7:0] rx_lane_aligner_fill_17;
  wire [7:0] rx_lane_aligner_fill_18;
  wire [7:0] rx_lane_aligner_fill_19;
  wire [7:0] rx_lane_aligner_fill_2;
  wire [7:0] rx_lane_aligner_fill_3;
  wire [7:0] rx_lane_aligner_fill_4;
  wire [7:0] rx_lane_aligner_fill_5;
  wire [7:0] rx_lane_aligner_fill_6;
  wire [7:0] rx_lane_aligner_fill_7;
  wire [7:0] rx_lane_aligner_fill_8;
  wire [7:0] rx_lane_aligner_fill_9;
  wire [55:0] rx_preambleout_0;
  wire [55:0] rx_preambleout_1;
  wire [55:0] rx_preambleout_2;
  wire [55:0] rx_preambleout_3;
  wire [54:0] rx_ptp_tstamp_out_0;
  wire [54:0] rx_ptp_tstamp_out_1;
  wire [54:0] rx_ptp_tstamp_out_2;
  wire [54:0] rx_ptp_tstamp_out_3;

  wire stat_rx_aligned_0;
  wire stat_rx_aligned_2;
  wire stat_rx_aligned_err_0;
  wire stat_rx_aligned_err_2;
  wire stat_rx_axis_err_0;
  wire stat_rx_axis_err_1;
  wire stat_rx_axis_err_2;
  wire stat_rx_axis_err_3;
  wire stat_rx_axis_fifo_overflow_0;
  wire stat_rx_axis_fifo_overflow_1;
  wire stat_rx_axis_fifo_overflow_2;
  wire stat_rx_axis_fifo_overflow_3;
  wire stat_rx_bad_code_0;
  wire stat_rx_bad_code_1;
  wire stat_rx_bad_code_2;
  wire stat_rx_bad_code_3;
  wire stat_rx_bad_fcs_0;
  wire stat_rx_bad_fcs_1;
  wire stat_rx_bad_fcs_2;
  wire stat_rx_bad_fcs_3;
  wire stat_rx_bad_preamble_0;
  wire stat_rx_bad_preamble_1;
  wire stat_rx_bad_preamble_2;
  wire stat_rx_bad_preamble_3;
  wire stat_rx_bad_sfd_0;
  wire stat_rx_bad_sfd_1;
  wire stat_rx_bad_sfd_2;
  wire stat_rx_bad_sfd_3;
  wire [19:0] stat_rx_bip_err_0;
  wire [3:0] stat_rx_bip_err_2;
  wire [19:0] stat_rx_block_lock_0;
  wire stat_rx_block_lock_1;
  wire [3:0] stat_rx_block_lock_2;
  wire stat_rx_block_lock_3;
  wire stat_rx_cl49_82_convert_err_0;
  wire stat_rx_cl49_82_convert_err_1;
  wire stat_rx_cl49_82_convert_err_2;
  wire stat_rx_cl49_82_convert_err_3;
  wire [1:0] stat_rx_ecc_err_0;
  wire [1:0] stat_rx_ecc_err_1;
  wire [1:0] stat_rx_ecc_err_2;
  wire [1:0] stat_rx_ecc_err_3;
  wire stat_rx_flexif_err_0;
  wire stat_rx_flexif_err_1;
  wire stat_rx_flexif_err_2;
  wire stat_rx_flexif_err_3;
  wire stat_rx_flex_fifo_ovf_0;
  wire stat_rx_flex_fifo_ovf_1;
  wire stat_rx_flex_fifo_ovf_2;
  wire stat_rx_flex_fifo_ovf_3;
  wire stat_rx_flex_fifo_udf_0;
  wire stat_rx_flex_fifo_udf_1;
  wire stat_rx_flex_fifo_udf_2;
  wire stat_rx_flex_fifo_udf_3;
  wire stat_rx_flex_mon_fifo_ovf_0;
  wire stat_rx_flex_mon_fifo_ovf_1;
  wire stat_rx_flex_mon_fifo_ovf_2;
  wire stat_rx_flex_mon_fifo_ovf_3;
  wire stat_rx_flex_mon_fifo_udf_0;
  wire stat_rx_flex_mon_fifo_udf_1;
  wire stat_rx_flex_mon_fifo_udf_2;
  wire stat_rx_flex_mon_fifo_udf_3;
  wire [19:0] stat_rx_framing_err_0;
  wire stat_rx_framing_err_1;
  wire [3:0] stat_rx_framing_err_2;
  wire stat_rx_framing_err_3;
  wire stat_rx_got_signal_os_0;
  wire stat_rx_got_signal_os_1;
  wire stat_rx_got_signal_os_2;
  wire stat_rx_got_signal_os_3;
  wire stat_rx_hi_ber_0;
  wire stat_rx_hi_ber_1;
  wire stat_rx_hi_ber_2;
  wire stat_rx_hi_ber_3;
  wire stat_rx_internal_local_fault_0;
  wire stat_rx_internal_local_fault_1;
  wire stat_rx_internal_local_fault_2;
  wire stat_rx_internal_local_fault_3;
  wire stat_rx_invalid_start_0;
  wire stat_rx_invalid_start_1;
  wire stat_rx_invalid_start_2;
  wire stat_rx_invalid_start_3;
  wire [7:0] stat_rx_lane0_vlm_bip7_0;
  wire [7:0] stat_rx_lane0_vlm_bip7_2;
  wire stat_rx_lane0_vlm_bip7_valid_0;
  wire stat_rx_lane0_vlm_bip7_valid_2;
  wire stat_rx_local_fault_0;
  wire stat_rx_local_fault_1;
  wire stat_rx_local_fault_2;
  wire stat_rx_local_fault_3;
  wire [19:0] stat_rx_mf_err_0;
  wire [3:0] stat_rx_mf_err_2;
  wire stat_rx_misaligned_0;
  wire stat_rx_misaligned_2;
  wire stat_rx_pcs_bad_code_0;
  wire stat_rx_pcs_bad_code_1;
  wire stat_rx_pcs_bad_code_2;
  wire stat_rx_pcs_bad_code_3;
  wire stat_rx_received_local_fault_0;
  wire stat_rx_received_local_fault_1;
  wire stat_rx_received_local_fault_2;
  wire stat_rx_received_local_fault_3;
  wire stat_rx_remote_fault_0;
  wire stat_rx_remote_fault_1;
  wire stat_rx_remote_fault_2;
  wire stat_rx_remote_fault_3;
  wire stat_rx_status_0;
  wire stat_rx_status_1;
  wire stat_rx_status_2;
  wire stat_rx_status_3;
  wire [19:0] stat_rx_synced_0;
  wire [3:0] stat_rx_synced_2;
  wire [19:0] stat_rx_synced_err_0;
  wire [3:0] stat_rx_synced_err_2;
  wire stat_rx_test_pattern_mismatch_0;
  wire stat_rx_test_pattern_mismatch_1;
  wire stat_rx_test_pattern_mismatch_2;
  wire stat_rx_test_pattern_mismatch_3;
  wire stat_rx_truncated_0;
  wire stat_rx_truncated_1;
  wire stat_rx_truncated_2;
  wire stat_rx_truncated_3;
  wire stat_rx_valid_ctrl_code_0;
  wire stat_rx_valid_ctrl_code_1;
  wire stat_rx_valid_ctrl_code_2;
  wire stat_rx_valid_ctrl_code_3;
  wire stat_rx_vl_demuxed_0;
  wire stat_rx_vl_demuxed_2;
  wire stat_tx_axis_err_0;
  wire stat_tx_axis_err_1;
  wire stat_tx_axis_err_2;
  wire stat_tx_axis_err_3;
  wire stat_tx_axis_unf_0;
  wire stat_tx_axis_unf_1;
  wire stat_tx_axis_unf_2;
  wire stat_tx_axis_unf_3;
  wire stat_tx_bad_fcs_0;
  wire stat_tx_bad_fcs_1;
  wire stat_tx_bad_fcs_2;
  wire stat_tx_bad_fcs_3;
  wire stat_tx_cl82_49_convert_err_0;
  wire stat_tx_cl82_49_convert_err_1;
  wire stat_tx_cl82_49_convert_err_2;
  wire stat_tx_cl82_49_convert_err_3;
  wire [1:0] stat_tx_ecc_err_0;
  wire [1:0] stat_tx_ecc_err_1;
  wire [1:0] stat_tx_ecc_err_2;
  wire [1:0] stat_tx_ecc_err_3;
  wire stat_tx_flexif_err_0;
  wire stat_tx_flexif_err_1;
  wire stat_tx_flexif_err_2;
  wire stat_tx_flexif_err_3;
  wire stat_tx_flex_fifo_ovf_0;
  wire stat_tx_flex_fifo_ovf_1;
  wire stat_tx_flex_fifo_ovf_2;
  wire stat_tx_flex_fifo_ovf_3;
  wire stat_tx_flex_fifo_udf_0;
  wire stat_tx_flex_fifo_udf_1;
  wire stat_tx_flex_fifo_udf_2;
  wire stat_tx_flex_fifo_udf_3;
  wire stat_tx_frame_error_0;
  wire stat_tx_frame_error_1;
  wire stat_tx_frame_error_2;
  wire stat_tx_frame_error_3;
  wire stat_tx_local_fault_0;
  wire stat_tx_local_fault_1;
  wire stat_tx_local_fault_2;
  wire stat_tx_local_fault_3;
  wire [2:0] stat_tx_pcs_bad_code_0;
  wire [2:0] stat_tx_pcs_bad_code_1;
  wire [2:0] stat_tx_pcs_bad_code_2;
  wire [2:0] stat_tx_pcs_bad_code_3;
  wire tx_axis_tready_0;
  wire tx_axis_tready_1;
  wire tx_axis_tready_2;
  wire tx_axis_tready_3;
  wire tx_flex_stall_0;
  wire tx_flex_stall_1;
  wire tx_flex_stall_2;
  wire tx_flex_stall_3;

  wire ctl_tx_lane0_vlm_bip7_override_01;
  wire ctl_tx_lane0_vlm_bip7_override_23=1'b0;
  wire [7:0] ctl_tx_lane0_vlm_bip7_override_value_01;
  wire [7:0] ctl_tx_lane0_vlm_bip7_override_value_23=8'd0;
  wire ctl_tx_send_idle_in_0;
  wire ctl_tx_send_idle_in_1;
  wire ctl_tx_send_idle_in_2;
  wire ctl_tx_send_idle_in_3;
  wire ctl_tx_send_lfi_in_0;
  wire ctl_tx_send_lfi_in_1;
  wire ctl_tx_send_lfi_in_2;
  wire ctl_tx_send_lfi_in_3;
  wire ctl_tx_send_rfi_in_0;
  wire ctl_tx_send_rfi_in_1;
  wire ctl_tx_send_rfi_in_2;
  wire ctl_tx_send_rfi_in_3;
  wire [3:0] pm_tick_core = {4{1'b0}};

  wire [65:0] rx_flex_cm_data0=66'd0;
  wire [65:0] rx_flex_cm_data1=66'd0;
  wire [65:0] rx_flex_cm_data2=66'd0;
  wire [65:0] rx_flex_cm_data3=66'd0;
  wire [65:0] rx_flex_cm_data4=66'd0;
  wire [65:0] rx_flex_cm_data5=66'd0;
  wire [65:0] rx_flex_cm_data6=66'd0;
  wire [65:0] rx_flex_cm_data7=66'd0;
  wire rx_flex_cm_ena_0=1'b0;
  wire rx_flex_cm_ena_1=1'b0;
  wire rx_flex_cm_ena_2=1'b0;
  wire rx_flex_cm_ena_3=1'b0;
  wire [79:0] rx_serdes_data0;
  wire [79:0] rx_serdes_data1;
  wire [79:0] rx_serdes_data2;
  wire [79:0] rx_serdes_data3;

  wire [63:0] tx_axis_tdata0;
  wire [63:0] tx_axis_tdata1;
  wire [63:0] tx_axis_tdata2;
  wire [63:0] tx_axis_tdata3;
  wire [63:0] tx_axis_tdata4;
  wire [63:0] tx_axis_tdata5;
  wire [63:0] tx_axis_tdata6;
  wire [63:0] tx_axis_tdata7;
  wire [10:0] tx_axis_tkeep_user0;
  wire [10:0] tx_axis_tkeep_user1;
  wire [10:0] tx_axis_tkeep_user2;
  wire [10:0] tx_axis_tkeep_user3;
  wire [10:0] tx_axis_tkeep_user4;
  wire [10:0] tx_axis_tkeep_user5;
  wire [10:0] tx_axis_tkeep_user6;
  wire [10:0] tx_axis_tkeep_user7;
  wire tx_axis_tlast_0;
  wire tx_axis_tlast_1;
  wire tx_axis_tlast_2;
  wire tx_axis_tlast_3;
  wire tx_axis_tvalid_0;
  wire tx_axis_tvalid_1;
  wire tx_axis_tvalid_2;
  wire tx_axis_tvalid_3;

  wire tx_flex_almarker0=1'b0;
  wire tx_flex_almarker1=1'b0;
  wire tx_flex_almarker2=1'b0;
  wire tx_flex_almarker3=1'b0;
  wire tx_flex_almarker4=1'b0;
  wire tx_flex_almarker5=1'b0;
  wire tx_flex_almarker6=1'b0;
  wire tx_flex_almarker7=1'b0;
  wire [65:0] tx_flex_data0=66'd0;
  wire [65:0] tx_flex_data1=66'd0;
  wire [65:0] tx_flex_data2=66'd0;
  wire [65:0] tx_flex_data3=66'd0;
  wire [65:0] tx_flex_data4=66'd0;
  wire [65:0] tx_flex_data5=66'd0;
  wire [65:0] tx_flex_data6=66'd0;
  wire [65:0] tx_flex_data7=66'd0;
  wire tx_flex_ena_0=1'b0;
  wire tx_flex_ena_1=1'b0;
  wire tx_flex_ena_2=1'b0;
  wire tx_flex_ena_3=1'b0;
  wire [55:0] tx_preamblein_0=56'h555555555555d5;
  wire [55:0] tx_preamblein_1=56'h555555555555d5;
  wire [55:0] tx_preamblein_2=56'h555555555555d5;
  wire [55:0] tx_preamblein_3=56'h555555555555d5;
  logic [63:0]          client0_tx_axis_tdata0;
  logic [63:0]          client0_tx_axis_tdata1;
  logic [63:0]          client0_tx_axis_tdata2;
  logic [63:0]          client0_tx_axis_tdata3;
  logic [63:0]          client0_tx_axis_tdata4;
  logic [63:0]          client0_tx_axis_tdata5;
  logic [10:0]          client0_tx_axis_tkeep_user0;
  logic [10:0]          client0_tx_axis_tkeep_user1;
  logic [10:0]          client0_tx_axis_tkeep_user2;
  logic [10:0]          client0_tx_axis_tkeep_user3;
  logic [10:0]          client0_tx_axis_tkeep_user4;
  logic [10:0]          client0_tx_axis_tkeep_user5;
  logic [63:0]          client1_tx_axis_tdata0; 
  logic [63:0]          client1_tx_axis_tdata1; 
  logic [10:0]          client1_tx_axis_tkeep_user0;
  logic [10:0]          client1_tx_axis_tkeep_user1;
  logic [63:0]          client2_tx_axis_tdata0; 
  logic [63:0]          client2_tx_axis_tdata1; 
  logic [63:0]          client2_tx_axis_tdata2; 
  logic [63:0]          client2_tx_axis_tdata3; 
  logic [10:0]          client2_tx_axis_tkeep_user0;
  logic [10:0]          client2_tx_axis_tkeep_user1;
  logic [10:0]          client2_tx_axis_tkeep_user2;
  logic [10:0]          client2_tx_axis_tkeep_user3;
  logic [63:0]          client3_tx_axis_tdata0; 
  logic [63:0]          client3_tx_axis_tdata1; 
  logic [10:0]          client3_tx_axis_tkeep_user0;
  logic [10:0]          client3_tx_axis_tkeep_user1;
 
  logic         rx_client0_axi_rstn;
  logic         rx_client1_axi_rstn;
  logic         rx_client2_axi_rstn;
  logic         rx_client3_axi_rstn;
  logic         tx_client0_axi_rstn;
  logic         tx_client1_axi_rstn;
  logic         tx_client2_axi_rstn;
  logic         tx_client3_axi_rstn;
  logic [3:0] axis_buffer_tx_tready;
  logic [3:0] axis_buffer_tx_tvalid;
  logic [7:0][63:0] axis_buffer_tx_tdata;
  logic [7:0][10:0] axis_buffer_tx_tkeep;
  logic [3:0] axis_buffer_tx_tlast;
  //// Wires between MRMAC and GT
  wire  [3:0] txuserrdy_out;
  wire  [3:0] rxuserrdy_out;
  wire  [3:0] mst_tx_reset_out;
  wire  [3:0] mst_rx_reset_out;

  wire  [3:0] tx_pma_resetdone_in;
  wire  [3:0] rx_pma_resetdone_in;
  wire  [3:0] mst_tx_resetdone_in;
  wire  [3:0] mst_rx_resetdone_in;
  wire        gtpowergood_in     ;

  /////// Clock and Resets
  wire         tx_axi_clk_mmcm;
 
  reg ch0_rxmstresetdone_dly;
  reg ch1_rxmstresetdone_dly;
  reg ch2_rxmstresetdone_dly;
  reg ch3_rxmstresetdone_dly;
  reg [15:0] ch0_rxmstresetdone_dlycnt;
  reg [15:0] ch1_rxmstresetdone_dlycnt;
  reg [15:0] ch2_rxmstresetdone_dlycnt;
  reg [15:0] ch3_rxmstresetdone_dlycnt;
  wire [3:0]  rx_axi_rst;
  wire [3:0]  tx_axi_rst;  
  

    wire             c1_tx_done_led;
    wire             c1_tx_busy_led;	
    wire [63:0]      c1_client_tx_frames_transmitted_latched;
    wire [63:0]      c1_client_rx_errored_frames_latched;  
    wire [63:0]      c1_client_rx_frames_received_latched;  
    wire [63:0]      c1_client_rx_bytes_received_latched;  
    wire [63:0]      c1_client_tx_bytes_transmitted_latched;
    wire [31:0]      c1_crc_error_cnt;		

    wire             c2_tx_done_led;
    wire             c2_tx_busy_led;	
    wire [63:0]      c2_client_tx_frames_transmitted_latched;
    wire [63:0]      c2_client_rx_errored_frames_latched;  
    wire [63:0]      c2_client_rx_frames_received_latched;  
    wire [63:0]      c2_client_rx_bytes_received_latched;  
    wire [63:0]      c2_client_tx_bytes_transmitted_latched;
    wire [31:0]      c2_crc_error_cnt;		

    wire             c3_tx_done_led;
    wire             c3_tx_busy_led;	
    wire [63:0]      c3_client_tx_frames_transmitted_latched;
    wire [63:0]      c3_client_rx_errored_frames_latched;  
    wire [63:0]      c3_client_rx_frames_received_latched;  
    wire [63:0]      c3_client_rx_bytes_received_latched;  
    wire [63:0]      c3_client_tx_bytes_transmitted_latched;
    wire [31:0]      c3_crc_error_cnt;		

    wire [31:0]    SW_REG_GT_LINE_RATE;

    wire       ch0_tx_usr_clk; 
    wire       ch1_tx_usr_clk; 
    wire       ch2_tx_usr_clk; 
    wire       ch3_tx_usr_clk; 

    wire       ch0_rx_usr_clk; 
    wire       ch1_rx_usr_clk; 
    wire       ch2_rx_usr_clk; 
    wire       ch3_rx_usr_clk;
 
    wire       ch0_tx_usr_clk2;
    wire       ch1_tx_usr_clk2; 
    wire       ch2_tx_usr_clk2; 
    wire       ch3_tx_usr_clk2; 
    wire       ch0_rx_usr_clk2; 
    wire       ch1_rx_usr_clk2; 
    wire       ch2_rx_usr_clk2; 
    wire       ch3_rx_usr_clk2;
 
    wire  [3:0] mst_tx_dp_reset_out;
    wire  [3:0] mst_rx_dp_reset_out;
    wire  [3:0] gt_tx_reset_done_out;  
    wire  [3:0] gt_rx_reset_done_out;
  
    wire [3:0] rx_core_reset;
    
    wire [3:0] tx_flexif_clk = 4'b0000;
    wire [3:0] rx_flexif_clk = 4'b0000;

    wire [3:0] rx_flexif_reset = {4{~pl_resetn}};
    wire [3:0] rx_serdes_reset;
    wire [3:0] rx_ts_clk;
    wire [3:0] tx_core_reset;
    wire [3:0] tx_serdes_reset;
    wire [3:0] tx_ts_clk;
    wire       axis_clk_0;
    wire       axis_int_reset;
    wire [3:0] tx_axi_clk;
    wire [3:0] rx_axi_clk;
    wire [3:0] tx_core_clk;
    wire [3:0] rx_core_clk;
    wire [3:0] tx_alt_serdes_clk;
    wire [3:0] rx_alt_serdes_clk;  
    wire [3:0] rx_serdes_clk;
    localparam [47:0] dest_addr   = 48'hFF_FF_FF_FF_FF_FF;            // Broadcast
    localparam [47:0] source_addr = 48'h14_FE_B5_DD_9A_82;            // Hardware address of xowjcoppens40	
    localparam [15:0] prbs_pkt_size = 16'h0100;
 /////////////////////////////////////////////////////////////////////////////
//Clocks
/////////////////////////////////////////////////////////////////////////////
// For exact tx/rx axi clock sources and frequencies, Please refer the PG.
// The clock source and architecture for the axi interface, in this example design is for Independent moode only. User has to change as per the AXI mode selected. please refer MRMAC PG314. 
mrmac_0_axis_clk_wiz_0 i_mrmac_0_axis_clk_wiz_0 (
  .clk_in1	(pl_clk),    
  .clk_out1	(tx_axi_clk_mmcm)   
);
  
    ///////  Core Clocking

  assign rx_core_clk       = {ch3_rx_usr_clk,ch2_rx_usr_clk,ch1_rx_usr_clk,ch0_rx_usr_clk};
  assign rx_serdes_clk     = {ch3_rx_usr_clk,ch2_rx_usr_clk,ch1_rx_usr_clk,ch0_rx_usr_clk}; 
  assign tx_core_clk       = {ch3_tx_usr_clk,ch2_tx_usr_clk,ch1_tx_usr_clk,ch0_tx_usr_clk};
  assign rx_alt_serdes_clk = {ch3_rx_usr_clk2,ch2_rx_usr_clk2,ch1_rx_usr_clk2,ch0_rx_usr_clk2};
  assign tx_alt_serdes_clk = {ch3_tx_usr_clk2,ch2_tx_usr_clk2,ch1_tx_usr_clk2,ch0_tx_usr_clk2};

    assign tx_ts_clk=4'b0000;
    assign rx_ts_clk=4'b0000;
  
  //// AXI-4 Lite 


  ///// Core and Serdes Resets
  assign rx_core_reset     = {~gt_rx_reset_done_out[3],~gt_rx_reset_done_out[2],~gt_rx_reset_done_out[1],~gt_rx_reset_done_out[0]};
  assign rx_serdes_reset   = {~gt_rx_reset_done_out[3],~gt_rx_reset_done_out[2],~gt_rx_reset_done_out[1],~gt_rx_reset_done_out[0]};
  assign tx_core_reset     = {~gt_tx_reset_done_out[3],~gt_tx_reset_done_out[2],~gt_tx_reset_done_out[1],~gt_tx_reset_done_out[0]};   
  assign tx_serdes_reset   = {~gt_tx_reset_done_out[3],~gt_tx_reset_done_out[2],~gt_tx_reset_done_out[1],~gt_tx_reset_done_out[0]}; 
 
  ///// AXIS Clocks
  assign tx_axi_clk        = {4{tx_axi_clk_mmcm}};
  assign rx_axi_clk        = {4{tx_axi_clk_mmcm}};
  
assign tx_axi_rst = {4{~pl_resetn}};
assign rx_axi_rst = {4{~pl_resetn}};

  
  assign tx_client0_axi_clk = tx_axi_clk[0];
  assign tx_client1_axi_clk = tx_axi_clk[1];
  assign tx_client2_axi_clk = tx_axi_clk[2];
  assign tx_client3_axi_clk = tx_axi_clk[3];

  assign tx_client0_axi_rst = tx_axi_rst[0];
  assign tx_client1_axi_rst = tx_axi_rst[1];
  assign tx_client2_axi_rst = tx_axi_rst[2];
  assign tx_client3_axi_rst = tx_axi_rst[3];

  assign rx_client0_axi_clk = rx_axi_clk[0];
  assign rx_client1_axi_clk = rx_axi_clk[1];
  assign rx_client2_axi_clk = rx_axi_clk[2];
  assign rx_client3_axi_clk = rx_axi_clk[3];

  assign rx_client0_axi_rst = rx_axi_rst[0];
  assign rx_client1_axi_rst = rx_axi_rst[1];
  assign rx_client2_axi_rst = rx_axi_rst[2];
  assign rx_client3_axi_rst = rx_axi_rst[3];
  assign rx_client0_axi_rstn =~rx_axi_rst[0];
  assign rx_client1_axi_rstn =~rx_axi_rst[1];
  assign rx_client2_axi_rstn =~rx_axi_rst[2];
  assign rx_client3_axi_rstn =~rx_axi_rst[3];
  assign tx_client0_axi_rstn =~tx_axi_rst[0];
  assign tx_client1_axi_rstn =~tx_axi_rst[1];
  assign tx_client2_axi_rstn =~tx_axi_rst[2];
  assign tx_client3_axi_rstn =~tx_axi_rst[3];
  (* ASYNC_REG = "TRUE" *) reg c0_trig_in_d0;
  (* ASYNC_REG = "TRUE" *) reg c0_trig_in_d1;
  (* ASYNC_REG = "TRUE" *) reg c0_trig_in_d2;
  (* ASYNC_REG = "TRUE" *) reg c0_trig_in_edge_detect;
  (* ASYNC_REG = "TRUE" *) reg c1_trig_in_d0;
  (* ASYNC_REG = "TRUE" *) reg c1_trig_in_d1;
  (* ASYNC_REG = "TRUE" *) reg c1_trig_in_d2;
  (* ASYNC_REG = "TRUE" *) reg c1_trig_in_edge_detect;
  (* ASYNC_REG = "TRUE" *) reg c2_trig_in_d0;
  (* ASYNC_REG = "TRUE" *) reg c2_trig_in_d1;
  (* ASYNC_REG = "TRUE" *) reg c2_trig_in_d2;
  (* ASYNC_REG = "TRUE" *) reg c2_trig_in_edge_detect;
  (* ASYNC_REG = "TRUE" *) reg c3_trig_in_d0;
  (* ASYNC_REG = "TRUE" *) reg c3_trig_in_d1;
  (* ASYNC_REG = "TRUE" *) reg c3_trig_in_d2;
  (* ASYNC_REG = "TRUE" *) reg c3_trig_in_edge_detect;
  reg	         client0_start_prbs ;
  reg	         client0_stop_prbs ;
  reg	[15:0]   client0_count      ;
  reg	         client1_start_prbs ;
  reg	         client1_stop_prbs ;
  reg	[15:0]   client1_count      ;
  reg	         client2_start_prbs ;
  reg	         client2_stop_prbs ;
  reg	[15:0]   client2_count      ;
  reg	         client3_start_prbs ;
  reg	         client3_stop_prbs ;
  reg	[15:0]   client3_count      ;  
  reg   [3:0]    CLIENT0_FSM_r ;
  reg   [3:0]    CLIENT1_FSM_r ;
  reg   [3:0]    CLIENT2_FSM_r ;
  reg   [3:0]    CLIENT3_FSM_r ;

 localparam CLIENT0_IDLE_STATE       =4'b0001;
 localparam CLIENT0_START_PRBS_STATE =4'b0010;
 localparam CLIENT0_WAIT_PRBS_STATE  =4'b0100;
 localparam CLIENT0_STOP_PRBS_STATE  =4'b1000;
 localparam CLIENT1_IDLE_STATE       =4'b0001;
 localparam CLIENT1_START_PRBS_STATE =4'b0010;
 localparam CLIENT1_WAIT_PRBS_STATE  =4'b0100;
 localparam CLIENT1_STOP_PRBS_STATE  =4'b1000;
 localparam CLIENT2_IDLE_STATE       =4'b0001;
 localparam CLIENT2_START_PRBS_STATE =4'b0010;
 localparam CLIENT2_WAIT_PRBS_STATE  =4'b0100;
 localparam CLIENT2_STOP_PRBS_STATE  =4'b1000;
 localparam CLIENT3_IDLE_STATE       =4'b0001;
 localparam CLIENT3_START_PRBS_STATE =4'b0010;
 localparam CLIENT3_WAIT_PRBS_STATE  =4'b0100;
 localparam CLIENT3_STOP_PRBS_STATE  =4'b1000;
 
always @(posedge tx_client0_axi_clk or negedge tx_client0_axi_rstn)
begin
   if ( tx_client0_axi_rstn == 1'b0 )
   begin
        c0_trig_in_d0 <= 1'b0;
        c0_trig_in_d1 <= 1'b0;
        c0_trig_in_d2 <= 1'b0;
	    c0_trig_in_edge_detect     <= 1'b0;
   end
   else
   begin
         c0_trig_in_d0 <= c0_trig_in;
         c0_trig_in_d1 <= c0_trig_in_d0;
         c0_trig_in_d2 <= c0_trig_in_d1;
         c0_trig_in_edge_detect <= c0_trig_in_d1 && !c0_trig_in_d2;
   end
end
always @(posedge tx_client0_axi_clk) 
begin
    if (tx_client0_axi_rstn == 1'b0) 
    begin 
        CLIENT0_FSM_r 	    <= CLIENT0_IDLE_STATE;
		client0_start_prbs  <= 1'b0;
		client0_stop_prbs   <= 1'b0;
		client0_count       <= 16'h0000;
    end 
    else 
    begin
        case (CLIENT0_FSM_r)
            CLIENT0_IDLE_STATE:
                begin 
					client0_start_prbs  <= 1'b0;
					client0_stop_prbs   <= 1'b0;
					client0_count       <= 16'h0000;
				   if (c0_trig_in_edge_detect == 1'b1) 
                    begin
						CLIENT0_FSM_r       <= CLIENT0_START_PRBS_STATE;
					end
                    else 
                    begin 
						CLIENT0_FSM_r 	    <= CLIENT0_IDLE_STATE;
                    end 
                end
            CLIENT0_START_PRBS_STATE:
				begin
					client0_start_prbs  <= 1'b1;
					client0_stop_prbs   <= 1'b0;
  					CLIENT0_FSM_r   <= CLIENT0_WAIT_PRBS_STATE;
				end				
			CLIENT0_WAIT_PRBS_STATE:
				begin
					client0_start_prbs  <= 1'b0;
					client0_stop_prbs   <= 1'b0;
					client0_count       <= client0_count + 1;
                    if (client0_count >= 16'h0100)
                        begin
                           CLIENT0_FSM_r         <= CLIENT0_STOP_PRBS_STATE;
                        end
                    else 
                        begin
                            CLIENT0_FSM_r 	  	 <= CLIENT0_WAIT_PRBS_STATE;
                        end
				end
            CLIENT0_STOP_PRBS_STATE: 
                    begin
						client0_start_prbs  <= 1'b0;
						client0_stop_prbs   <= 1'b1;
                         CLIENT0_FSM_r      <= CLIENT0_IDLE_STATE;                                 
                    end				
			default: 
                begin
					client0_start_prbs  <= 1'b0;
					client0_stop_prbs   <= 1'b0;
					client0_count       <= 16'h0000;
					CLIENT0_FSM_r 	     <= CLIENT0_IDLE_STATE;
                end
        endcase		
	end
end	


always @(posedge tx_client1_axi_clk or negedge tx_client1_axi_rstn)
begin
   if ( tx_client1_axi_rstn == 1'b0 )
   begin
        c1_trig_in_d0 <= 1'b0;
        c1_trig_in_d1 <= 1'b0;
        c1_trig_in_d2 <= 1'b0;
	    c1_trig_in_edge_detect     <= 1'b0;
   end
   else
   begin
         c1_trig_in_d0 <= c1_trig_in;
         c1_trig_in_d1 <= c1_trig_in_d0;
         c1_trig_in_d2 <= c1_trig_in_d1;
         c1_trig_in_edge_detect <= c1_trig_in_d1 && !c1_trig_in_d2;
   end
end
always @(posedge tx_client1_axi_clk) 
begin
    if (tx_client1_axi_rstn == 1'b0) 
    begin 
        CLIENT1_FSM_r 	    <= CLIENT1_IDLE_STATE;
		client1_start_prbs  <= 1'b0;
		client1_stop_prbs   <= 1'b0;
		client1_count       <= 16'h0000;
    end 
    else 
    begin
        case (CLIENT1_FSM_r)
            CLIENT1_IDLE_STATE:
                begin 
					client1_start_prbs  <= 1'b0;
					client1_stop_prbs   <= 1'b0;
					client1_count       <= 16'h0000;
				   if (c1_trig_in_edge_detect == 1'b1) 
                    begin
						CLIENT1_FSM_r       <= CLIENT1_START_PRBS_STATE;
					end
                    else 
                    begin 
						CLIENT1_FSM_r 	    <= CLIENT1_IDLE_STATE;
                    end 
                end
            CLIENT1_START_PRBS_STATE:
				begin
					client1_start_prbs  <= 1'b1;
					client1_stop_prbs   <= 1'b0;
  					CLIENT1_FSM_r   <= CLIENT1_WAIT_PRBS_STATE;
				end				
			CLIENT1_WAIT_PRBS_STATE:
				begin
					client1_start_prbs  <= 1'b0;
					client1_stop_prbs   <= 1'b0;
					client1_count       <= client1_count + 1;
                    if (client1_count >= 16'h0100)
                        begin
                           CLIENT1_FSM_r         <= CLIENT1_STOP_PRBS_STATE;
                        end
                    else 
                        begin
                            CLIENT1_FSM_r 	  	 <= CLIENT1_WAIT_PRBS_STATE;
                        end
				end
            CLIENT1_STOP_PRBS_STATE: 
                    begin
					     client1_start_prbs  <= 1'b0;
					     client1_stop_prbs   <= 1'b1;
                         CLIENT1_FSM_r      <= CLIENT1_IDLE_STATE;                                 
                    end				
			default: 
                begin
					client1_start_prbs  <= 1'b0;
					client1_stop_prbs   <= 1'b0;
					client1_count       <= 16'h0000;
					CLIENT1_FSM_r 	     <= CLIENT1_IDLE_STATE;
                end
        endcase		
	end
end	


always @(posedge tx_client2_axi_clk or negedge tx_client2_axi_rstn)
begin
   if ( tx_client2_axi_rstn == 1'b0 )
   begin
        c2_trig_in_d0 <= 1'b0;
        c2_trig_in_d1 <= 1'b0;
        c2_trig_in_d2 <= 1'b0;
	    c2_trig_in_edge_detect     <= 1'b0;
   end
   else
   begin
         c2_trig_in_d0 <= c2_trig_in;
         c2_trig_in_d1 <= c2_trig_in_d0;
         c2_trig_in_d2 <= c2_trig_in_d1;
         c2_trig_in_edge_detect <= c2_trig_in_d1 && !c2_trig_in_d2;
   end
end
always @(posedge tx_client2_axi_clk) 
begin
    if (tx_client2_axi_rstn == 1'b0) 
    begin 
        CLIENT2_FSM_r 	    <= CLIENT2_IDLE_STATE;
		client2_start_prbs  <= 1'b0;
		client2_stop_prbs   <= 1'b0;
		client2_count       <= 16'h0000;
    end 
    else 
    begin
        case (CLIENT2_FSM_r)
            CLIENT2_IDLE_STATE:
                begin 
					client2_start_prbs  <= 1'b0;
					client2_stop_prbs   <= 1'b0;
					client2_count       <= 16'h0000;
				   if (c2_trig_in_edge_detect == 1'b1) 
                    begin
						CLIENT2_FSM_r       <= CLIENT2_START_PRBS_STATE;
					end
                    else 
                    begin 
						CLIENT2_FSM_r 	    <= CLIENT2_IDLE_STATE;
                    end 
                end
            CLIENT2_START_PRBS_STATE:
				begin
					client2_start_prbs  <= 1'b1;
					client2_stop_prbs   <= 1'b0;
  					CLIENT2_FSM_r   <= CLIENT2_WAIT_PRBS_STATE;
				end				
			CLIENT2_WAIT_PRBS_STATE:
				begin
					client2_start_prbs  <= 1'b0;
					client2_stop_prbs   <= 1'b0;
					client2_count       <= client2_count + 1;
                    if (client2_count >= 16'h0100)
                        begin
                           CLIENT2_FSM_r         <= CLIENT2_STOP_PRBS_STATE;
                        end
                    else 
                        begin
                            CLIENT2_FSM_r 	  	 <= CLIENT2_WAIT_PRBS_STATE;
                        end
				end
            CLIENT2_STOP_PRBS_STATE: 
                    begin
					     client2_start_prbs  <= 1'b0;
					     client2_stop_prbs   <= 1'b1;
                         CLIENT2_FSM_r      <= CLIENT2_IDLE_STATE;                                 
                    end				
			default: 
                begin
					client2_start_prbs  <= 1'b0;
					client2_stop_prbs   <= 1'b0;
					client2_count       <= 16'h0000;
					CLIENT2_FSM_r 	     <= CLIENT2_IDLE_STATE;
                end
        endcase		
	end
end	


always @(posedge tx_client3_axi_clk or negedge tx_client3_axi_rstn)
begin
   if ( tx_client3_axi_rstn == 1'b0 )
   begin
        c3_trig_in_d0 <= 1'b0;
        c3_trig_in_d1 <= 1'b0;
        c3_trig_in_d2 <= 1'b0;
	    c3_trig_in_edge_detect     <= 1'b0;
   end
   else
   begin
         c3_trig_in_d0 <= c3_trig_in;
         c3_trig_in_d1 <= c3_trig_in_d0;
         c3_trig_in_d2 <= c3_trig_in_d1;
         c3_trig_in_edge_detect <= c3_trig_in_d1 && !c3_trig_in_d2;
   end
end
always @(posedge tx_client3_axi_clk) 
begin
    if (tx_client3_axi_rstn == 1'b0) 
    begin 
        CLIENT3_FSM_r 	    <= CLIENT3_IDLE_STATE;
		client3_start_prbs  <= 1'b0;
		client3_stop_prbs   <= 1'b0;
		client3_count       <= 16'h0000;
    end 
    else 
    begin
        case (CLIENT3_FSM_r)
            CLIENT3_IDLE_STATE:
                begin 
					client3_start_prbs  <= 1'b0;
					client3_stop_prbs   <= 1'b0;
					client3_count       <= 16'h0000;
				   if (c3_trig_in_edge_detect == 1'b1) 
                    begin
						CLIENT3_FSM_r       <= CLIENT3_START_PRBS_STATE;
					end
                    else 
                    begin 
						CLIENT3_FSM_r 	    <= CLIENT3_IDLE_STATE;
                    end 
                end
            CLIENT3_START_PRBS_STATE:
				begin
					client3_start_prbs  <= 1'b1;
					client3_stop_prbs   <= 1'b0;
  					CLIENT3_FSM_r   <= CLIENT3_WAIT_PRBS_STATE;
				end				
			CLIENT3_WAIT_PRBS_STATE:
				begin
					client3_start_prbs  <= 1'b0;
					client3_stop_prbs   <= 1'b0;
					client3_count       <= client3_count + 1;
                    if (client3_count >= 16'h0100)
                        begin
                           CLIENT3_FSM_r         <= CLIENT3_STOP_PRBS_STATE;
                        end
                    else 
                        begin
                            CLIENT3_FSM_r 	  	 <= CLIENT3_WAIT_PRBS_STATE;
                        end
				end
            CLIENT3_STOP_PRBS_STATE: 
                    begin
					     client3_start_prbs  <= 1'b0;
					     client3_stop_prbs   <= 1'b1;
                         CLIENT3_FSM_r      <= CLIENT3_IDLE_STATE;                                 
                    end				
			default: 
                begin
					client3_start_prbs  <= 1'b0;
					client3_stop_prbs   <= 1'b0;
					client3_count       <= 16'h0000;
					CLIENT3_FSM_r 	     <= CLIENT3_IDLE_STATE;
                end
        endcase		
	end
end	


  // For other GT loopback options, please program the value thru CIPS appropriately.
  // For GT Near-end PCS loopback, update the GT loopback value to 3'd1. Drive gt_loopback = 3'b001.
  // For GT External loopback, update the GT loopback value to 3'd0. Drive gt_loopback = 3'b000.
  // For more information & settings on loopback, refer versal GT Transceivers user guide.
  assign SW_REG_GT_LINE_RATE = {gt_line_rate,gt_line_rate,gt_line_rate,gt_line_rate};
 

mrmac_0_exdes_support_wrapper i_mrmac_0_exdes_support_wrapper
(
  /// GT 
  .APB3_INTF_paddr   (16'd0),
  .APB3_INTF_penable (1'b0),
  .APB3_INTF_prdata  (),
  .APB3_INTF_pready  (),
  .APB3_INTF_psel    (1'b0),
  .APB3_INTF_pslverr (),
  .APB3_INTF_pwdata  (32'd0),
  .APB3_INTF_pwrite  (1'b0),
  .apb3clk_quad (s_axi_aclk), 
  .CLK_IN_D_clk_n (gt_ref_clk_n),
  .CLK_IN_D_clk_p (gt_ref_clk_p),
  .gt_rxn_in_0 (gt_rxn_in),
  .gt_rxp_in_0 (gt_rxp_in),
  .gt_txn_out_0 (gt_txn_out),
  .gt_txp_out_0 (gt_txp_out),
//input to quad
  .ch0_txusrclk (ch0_tx_usr_clk2),
  .ch1_txusrclk (ch1_tx_usr_clk2),
  .ch2_txusrclk (ch2_tx_usr_clk2),
  .ch3_txusrclk (ch3_tx_usr_clk2),
  .ch0_rxusrclk (ch0_rx_usr_clk2),
  .ch1_rxusrclk (ch1_rx_usr_clk2),
  .ch2_rxusrclk (ch2_rx_usr_clk2),
  .ch3_rxusrclk (ch3_rx_usr_clk2),

//Output from bufg
  .ch0_tx_usr_clk(ch0_tx_usr_clk),
  .ch1_tx_usr_clk(ch1_tx_usr_clk),
  .ch3_tx_usr_clk(ch3_tx_usr_clk),
  .ch2_tx_usr_clk(ch2_tx_usr_clk),
  .ch0_rx_usr_clk(ch0_rx_usr_clk), 
  .ch2_rx_usr_clk(ch2_rx_usr_clk),
  .ch1_rx_usr_clk(ch1_rx_usr_clk),
  .ch3_rx_usr_clk(ch3_rx_usr_clk),

  .ch0_tx_usr_clk2(ch0_tx_usr_clk2),
  .ch1_tx_usr_clk2(ch1_tx_usr_clk2),
  .ch3_tx_usr_clk2(ch3_tx_usr_clk2),
  .ch2_tx_usr_clk2(ch2_tx_usr_clk2),
  .ch0_rx_usr_clk2(ch0_rx_usr_clk2),
  .ch2_rx_usr_clk2(ch2_rx_usr_clk2),
 
  .ch1_rx_usr_clk2(ch1_rx_usr_clk2),
  .ch3_rx_usr_clk2(ch3_rx_usr_clk2),
  
/////
  .gtpowergood (gtpowergood_in),
  .ch0_loopback	(gt_loopback),
  .ch0_rxrate	(SW_REG_GT_LINE_RATE[7:0]),
  .ch0_txrate	(SW_REG_GT_LINE_RATE[7:0]),
  .ch1_loopback	(gt_loopback),
  .ch1_rxrate	(SW_REG_GT_LINE_RATE[15:8]),
  .ch1_txrate	(SW_REG_GT_LINE_RATE[15:8]),
  .ch2_loopback	(gt_loopback),
  .ch2_rxrate	(SW_REG_GT_LINE_RATE[23:16]),
  .ch2_txrate	(SW_REG_GT_LINE_RATE[23:16]),
  .ch3_loopback	(gt_loopback),
  .ch3_rxrate	(SW_REG_GT_LINE_RATE[31:24]),
  .ch3_txrate	(SW_REG_GT_LINE_RATE[31:24]),

  //// MRMAC 
  .pm_rdy  (pm_rdy), 
  .pm_tick (pm_tick_core),
  .tx_core_clk 		(tx_core_clk),
  .rx_core_clk 		(rx_core_clk),  
  .tx_alt_serdes_clk (tx_alt_serdes_clk),  
  .rx_alt_serdes_clk (rx_alt_serdes_clk),
  .rx_serdes_clk 	(rx_serdes_clk),  
  .tx_axi_clk 		(tx_axi_clk),   
  .rx_axi_clk 		(rx_axi_clk),
  .tx_flexif_clk 	(tx_flexif_clk),
  .rx_flexif_clk 	(rx_flexif_clk),

  .tx_ts_clk 		(tx_ts_clk),
  .rx_ts_clk 		(rx_ts_clk),
   
  .tx_core_reset 	(tx_core_reset),
  .rx_core_reset 	(rx_core_reset),
  .tx_serdes_reset 	(tx_serdes_reset),  
  .rx_serdes_reset  (rx_serdes_reset),
  .rx_flexif_reset 	(rx_flexif_reset),    

  .ctl_tx_port0_ctl_tx_lane0_vlm_bip7_override (ctl_tx_lane0_vlm_bip7_override_01),
  .ctl_tx_port0_ctl_tx_lane0_vlm_bip7_override_value (ctl_tx_lane0_vlm_bip7_override_value_01),
  .ctl_tx_port0_ctl_tx_send_idle_in (1'b0),
  .ctl_tx_port0_ctl_tx_send_lfi_in (1'b0),
  .ctl_tx_port0_ctl_tx_send_rfi_in (1'b0),
  .ctl_tx_port1_ctl_tx_send_idle_in (1'b0),
  .ctl_tx_port1_ctl_tx_send_lfi_in (1'b0),
  .ctl_tx_port1_ctl_tx_send_rfi_in (1'b0),
  .ctl_tx_port2_ctl_tx_lane0_vlm_bip7_override (ctl_tx_lane0_vlm_bip7_override_23),
  .ctl_tx_port2_ctl_tx_lane0_vlm_bip7_override_value (ctl_tx_lane0_vlm_bip7_override_value_23),
  .ctl_tx_port2_ctl_tx_send_idle_in (1'b0),
  .ctl_tx_port2_ctl_tx_send_lfi_in (1'b0),
  .ctl_tx_port2_ctl_tx_send_rfi_in (1'b0),
  .ctl_tx_port3_ctl_tx_send_idle_in (1'b0),
  .ctl_tx_port3_ctl_tx_send_lfi_in (1'b0),
  .ctl_tx_port3_ctl_tx_send_rfi_in (1'b0),
  .rx_axis_tdata0 (rx_axis_tdata0[63:0]),
  .rx_axis_tkeep_user0 (rx_axis_tkeep_user0[10:0]),
  .rx_axis_tdata2 (rx_axis_tdata2[63:0]),
  .rx_axis_tkeep_user2 (rx_axis_tkeep_user2[10:0]),
  .rx_axis_tdata4 (rx_axis_tdata4[63:0]),
  .rx_axis_tkeep_user4 (rx_axis_tkeep_user4[10:0]),
  .rx_axis_tdata6 (rx_axis_tdata6[63:0]),
  .rx_axis_tkeep_user6 (rx_axis_tkeep_user6[10:0]),
  .rx_axis_tlast_0 (rx_axis_tlast_0),
  .rx_axis_tvalid_0 (rx_axis_tvalid_0),
  .rx_axis_tlast_1 (rx_axis_tlast_1),
  .rx_axis_tvalid_1 (rx_axis_tvalid_1),
  .rx_axis_tlast_2 (rx_axis_tlast_2),
  .rx_axis_tvalid_2 (rx_axis_tvalid_2),
  .rx_axis_tlast_3 (rx_axis_tlast_3),
  .rx_axis_tvalid_3 (rx_axis_tvalid_3),

  .rx_preambleout_rx_preambleout_0 (rx_preambleout_0),
  .rx_preambleout_rx_preambleout_1 (rx_preambleout_1),
  .rx_preambleout_rx_preambleout_2 (rx_preambleout_2),
  .rx_preambleout_rx_preambleout_3 (rx_preambleout_3),
  .s_axi_araddr (s_axi_araddr),
  .s_axi_arready (s_axi_arready),
  .s_axi_arvalid (s_axi_arvalid),
  .s_axi_awaddr (s_axi_awaddr),
  .s_axi_awready (s_axi_awready),
  .s_axi_awvalid (s_axi_awvalid),
  .s_axi_bready (s_axi_bready),
  .s_axi_bresp (s_axi_bresp),
  .s_axi_bvalid (s_axi_bvalid),
  .s_axi_rdata (s_axi_rdata),
  .s_axi_rready (s_axi_rready),
  .s_axi_rresp (s_axi_rresp),
  .s_axi_rvalid (s_axi_rvalid),
  .s_axi_wdata (s_axi_wdata),
  .s_axi_wready (s_axi_wready),
  .s_axi_wvalid (s_axi_wvalid),
  .s_axi_aclk (s_axi_aclk),
  .s_axi_aresetn (s_axi_aresetn),
  .stat_rx_port0_stat_rx_aligned (stat_rx_aligned_0),
  .stat_rx_port0_stat_rx_aligned_err (stat_rx_aligned_err_0),
  .stat_rx_port0_stat_rx_axis_err (),
  .stat_rx_port0_stat_rx_axis_fifo_overflow (),
  .stat_rx_port0_stat_rx_bad_code (),
  .stat_rx_port0_stat_rx_bad_fcs (),
  .stat_rx_port0_stat_rx_bad_preamble (),
  .stat_rx_port0_stat_rx_bad_sfd (),
  .stat_rx_port0_stat_rx_bip_err (),
  .stat_rx_port0_stat_rx_block_lock (stat_rx_block_lock_0),
  .stat_rx_port0_stat_rx_cl49_82_convert_err (),
  .stat_rx_port0_stat_rx_ecc_err (),
  .stat_rx_port0_stat_rx_flex_fifo_ovf (),
  .stat_rx_port0_stat_rx_flex_fifo_udf (),
  .stat_rx_port0_stat_rx_flex_mon_fifo_ovf (),
  .stat_rx_port0_stat_rx_flex_mon_fifo_udf (),
  .stat_rx_port0_stat_rx_flexif_err (),
  .stat_rx_port1_stat_rx_flex_fifo_ovf (),
  .stat_rx_port1_stat_rx_flex_fifo_udf (),
  .stat_rx_port1_stat_rx_flex_mon_fifo_ovf (),
  .stat_rx_port1_stat_rx_flex_mon_fifo_udf (),
  .stat_rx_port1_stat_rx_flexif_err (),
  .stat_rx_port2_stat_rx_flex_fifo_ovf (),
  .stat_rx_port2_stat_rx_flex_fifo_udf (),
  .stat_rx_port2_stat_rx_flex_mon_fifo_ovf (),
  .stat_rx_port2_stat_rx_flex_mon_fifo_udf (),
  .stat_rx_port2_stat_rx_flexif_err (),
  .stat_rx_port3_stat_rx_flex_fifo_ovf (),
  .stat_rx_port3_stat_rx_flex_fifo_udf (),
  .stat_rx_port3_stat_rx_flex_mon_fifo_ovf (),
  .stat_rx_port3_stat_rx_flex_mon_fifo_udf (),
  .stat_rx_port3_stat_rx_flexif_err (),
  .stat_rx_port0_stat_rx_framing_err_0 (),
  .stat_rx_port0_stat_rx_got_signal_os (),
  .stat_rx_port0_stat_rx_hi_ber (),
  .stat_rx_port0_stat_rx_internal_local_fault (),
  .stat_rx_port0_stat_rx_invalid_start (),
  .stat_rx_port0_stat_rx_lane0_vlm_bip7 (),
  .stat_rx_port0_stat_rx_lane0_vlm_bip7_valid (),
  .stat_rx_port0_stat_rx_local_fault (),
  .stat_rx_port0_stat_rx_mf_err_0 (),
  .stat_rx_port0_stat_rx_misaligned (),
  .stat_rx_port0_stat_rx_pcs_bad_code (),
  .stat_rx_port0_stat_rx_received_local_fault (),
  .stat_rx_port0_stat_rx_remote_fault (),
  .stat_rx_port0_stat_rx_status (stat_rx_status_0),
  .stat_rx_port0_stat_rx_synced (),
  .stat_rx_port0_stat_rx_synced_err (),
  .stat_rx_port0_stat_rx_test_pattern_mismatch (),
  .stat_rx_port0_stat_rx_truncated (),
  .stat_rx_port0_stat_rx_valid_ctrl_code (),
  .stat_rx_port0_stat_rx_vl_demuxed (),
  .stat_rx_port1_stat_rx_axis_err (),
  .stat_rx_port1_stat_rx_axis_fifo_overflow (),
  .stat_rx_port1_stat_rx_bad_code (),
  .stat_rx_port1_stat_rx_bad_fcs (),
  .stat_rx_port1_stat_rx_bad_preamble (),
  .stat_rx_port1_stat_rx_bad_sfd (),
  .stat_rx_port1_stat_rx_block_lock (stat_rx_block_lock_1),
  .stat_rx_port1_stat_rx_cl49_82_convert_err (),
  .stat_rx_port1_stat_rx_ecc_err (),
  .stat_rx_port1_stat_rx_framing_err_1 (),
  .stat_rx_port1_stat_rx_got_signal_os (),
  .stat_rx_port1_stat_rx_hi_ber (),
  .stat_rx_port1_stat_rx_internal_local_fault (),
  .stat_rx_port1_stat_rx_invalid_start (),
  .stat_rx_port1_stat_rx_local_fault (),
  .stat_rx_port1_stat_rx_pcs_bad_code (),
  .stat_rx_port1_stat_rx_received_local_fault (),
  .stat_rx_port1_stat_rx_remote_fault (),
  .stat_rx_port1_stat_rx_status (stat_rx_status_1),
  .stat_rx_port1_stat_rx_test_pattern_mismatch (),
  .stat_rx_port1_stat_rx_truncated (),
  .stat_rx_port1_stat_rx_valid_ctrl_code (),
  .stat_rx_port2_stat_rx_aligned (stat_rx_aligned_2),
  .stat_rx_port2_stat_rx_aligned_err (stat_rx_aligned_err_2),
  .stat_rx_port2_stat_rx_axis_err (),
  .stat_rx_port2_stat_rx_axis_fifo_overflow (),
  .stat_rx_port2_stat_rx_bad_code (),
  .stat_rx_port2_stat_rx_bad_fcs (),
  .stat_rx_port2_stat_rx_bad_preamble (),
  .stat_rx_port2_stat_rx_bad_sfd (),
  .stat_rx_port2_stat_rx_bip_err (),
  .stat_rx_port2_stat_rx_block_lock (stat_rx_block_lock_2),
  .stat_rx_port2_stat_rx_cl49_82_convert_err (),
  .stat_rx_port2_stat_rx_ecc_err (),
  .stat_rx_port2_stat_rx_framing_err_2 (),
  .stat_rx_port2_stat_rx_got_signal_os (),
  .stat_rx_port2_stat_rx_hi_ber (),
  .stat_rx_port2_stat_rx_internal_local_fault (),
  .stat_rx_port2_stat_rx_invalid_start (),
  .stat_rx_port2_stat_rx_lane0_vlm_bip7 (),
  .stat_rx_port2_stat_rx_lane0_vlm_bip7_valid (),
  .stat_rx_port2_stat_rx_local_fault (),
  .stat_rx_port2_stat_rx_mf_err_2 (),
  .stat_rx_port2_stat_rx_misaligned (),
  .stat_rx_port2_stat_rx_pcs_bad_code (),
  .stat_rx_port2_stat_rx_received_local_fault (),
  .stat_rx_port2_stat_rx_remote_fault (),
  .stat_rx_port2_stat_rx_status (stat_rx_status_2),
  .stat_rx_port2_stat_rx_synced (),
  .stat_rx_port2_stat_rx_synced_err (),
  .stat_rx_port2_stat_rx_test_pattern_mismatch (),
  .stat_rx_port2_stat_rx_truncated (),
  .stat_rx_port2_stat_rx_valid_ctrl_code (),
  .stat_rx_port2_stat_rx_vl_demuxed (),
  .stat_rx_port3_stat_rx_axis_err (),
  .stat_rx_port3_stat_rx_axis_fifo_overflow (),
  .stat_rx_port3_stat_rx_bad_code (),
  .stat_rx_port3_stat_rx_bad_fcs (),
  .stat_rx_port3_stat_rx_bad_preamble (),
  .stat_rx_port3_stat_rx_bad_sfd (),
  .stat_rx_port3_stat_rx_block_lock (stat_rx_block_lock_3),
  .stat_rx_port3_stat_rx_cl49_82_convert_err (),
  .stat_rx_port3_stat_rx_ecc_err (),
  .stat_rx_port3_stat_rx_framing_err_3 (),
  .stat_rx_port3_stat_rx_got_signal_os (),
  .stat_rx_port3_stat_rx_hi_ber (),
  .stat_rx_port3_stat_rx_internal_local_fault (),
  .stat_rx_port3_stat_rx_invalid_start (),
  .stat_rx_port3_stat_rx_local_fault (),
  .stat_rx_port3_stat_rx_pcs_bad_code (),
  .stat_rx_port3_stat_rx_received_local_fault (),
  .stat_rx_port3_stat_rx_remote_fault (),
  .stat_rx_port3_stat_rx_status (stat_rx_status_3),
  .stat_rx_port3_stat_rx_test_pattern_mismatch (),
  .stat_rx_port3_stat_rx_truncated (),
  .stat_rx_port3_stat_rx_valid_ctrl_code (),
  .stat_tx_port0_stat_tx_axis_err (),
  .stat_tx_port0_stat_tx_axis_unf (),
  .stat_tx_port0_stat_tx_bad_fcs (),
  .stat_tx_port0_stat_tx_cl82_49_convert_err (),
  .stat_tx_port0_stat_tx_ecc_err (),
  .stat_tx_port0_stat_tx_flex_fifo_ovf (),
  .stat_tx_port0_stat_tx_flex_fifo_udf (),
  .stat_tx_port0_stat_tx_flexif_err (),
  .stat_tx_port1_stat_tx_flex_fifo_ovf (),
  .stat_tx_port1_stat_tx_flex_fifo_udf (),
  .stat_tx_port1_stat_tx_flexif_err (),
  .stat_tx_port2_stat_tx_flex_fifo_ovf (),
  .stat_tx_port2_stat_tx_flex_fifo_udf (),
  .stat_tx_port2_stat_tx_flexif_err (),
  .stat_tx_port3_stat_tx_flex_fifo_ovf (),
  .stat_tx_port3_stat_tx_flex_fifo_udf (),
  .stat_tx_port3_stat_tx_flexif_err (),
  .stat_tx_port0_stat_tx_frame_error (),
  .stat_tx_port0_stat_tx_local_fault (),
  .stat_tx_port0_stat_tx_pcs_bad_code (),
  .stat_tx_port1_stat_tx_axis_err (),
  .stat_tx_port1_stat_tx_axis_unf (),
  .stat_tx_port1_stat_tx_bad_fcs (),
  .stat_tx_port1_stat_tx_cl82_49_convert_err (),
  .stat_tx_port1_stat_tx_ecc_err (),
  .stat_tx_port1_stat_tx_frame_error (),
  .stat_tx_port1_stat_tx_local_fault (),
  .stat_tx_port1_stat_tx_pcs_bad_code (),
  .stat_tx_port2_stat_tx_axis_err (),
  .stat_tx_port2_stat_tx_axis_unf (),
  .stat_tx_port2_stat_tx_bad_fcs (),
  .stat_tx_port2_stat_tx_cl82_49_convert_err (),
  .stat_tx_port2_stat_tx_ecc_err (),
  .stat_tx_port2_stat_tx_frame_error (),
  .stat_tx_port2_stat_tx_local_fault (),
  .stat_tx_port2_stat_tx_pcs_bad_code (),
  .stat_tx_port3_stat_tx_axis_err (),
  .stat_tx_port3_stat_tx_axis_unf (),
  .stat_tx_port3_stat_tx_bad_fcs (),
  .stat_tx_port3_stat_tx_cl82_49_convert_err (),
  .stat_tx_port3_stat_tx_ecc_err (),
  .stat_tx_port3_stat_tx_frame_error (),
  .stat_tx_port3_stat_tx_local_fault (),
  .stat_tx_port3_stat_tx_pcs_bad_code (),

  .tx_axis_tdata0 (axis_buffer_tx_tdata[0][63:0]),
  .tx_axis_tkeep_user0 (axis_buffer_tx_tkeep[0][10:0]),
  .tx_axis_tdata2 (axis_buffer_tx_tdata[2][63:0]),
  .tx_axis_tkeep_user2 (axis_buffer_tx_tkeep[2][10:0]),
  .tx_axis_tdata4 (axis_buffer_tx_tdata[4][63:0]),
  .tx_axis_tkeep_user4 (axis_buffer_tx_tkeep[4][10:0]),
  .tx_axis_tdata6 (axis_buffer_tx_tdata[6][63:0]),
  .tx_axis_tkeep_user6 (axis_buffer_tx_tkeep[6][10:0]),
  .tx_axis_tlast_0 (axis_buffer_tx_tlast[0]),
  .tx_axis_tready_0 (tx_axis_tready_0),
  .tx_axis_tvalid_0 (axis_buffer_tx_tvalid[0]),
  .tx_axis_tlast_1 (axis_buffer_tx_tlast[1]),
  .tx_axis_tready_1 (tx_axis_tready_1),
  .tx_axis_tvalid_1 (axis_buffer_tx_tvalid[1]),
  .tx_axis_tlast_2 (axis_buffer_tx_tlast[2]),
  .tx_axis_tready_2 (tx_axis_tready_2),
  .tx_axis_tvalid_2 (axis_buffer_tx_tvalid[2]),
  .tx_axis_tlast_3 (axis_buffer_tx_tlast[3]),
  .tx_axis_tready_3 (tx_axis_tready_3),
  .tx_axis_tvalid_3 (axis_buffer_tx_tvalid[3]),
  .tx_preamblein_tx_preamblein_0 (tx_preamblein_0),
  .tx_preamblein_tx_preamblein_1 (tx_preamblein_1),
  .tx_preamblein_tx_preamblein_2 (tx_preamblein_2),
  .tx_preamblein_tx_preamblein_3 (tx_preamblein_3),
  
  .gt_tx_reset_done_out      (gt_tx_reset_done_out),  
  .gt_rx_reset_done_out      (gt_rx_reset_done_out),
  .gt_reset_all_in		(gt_reset_all_in		),
  .gt_reset_tx_datapath_in	(gt_reset_tx_datapath_in),
  .gt_reset_rx_datapath_in	(gt_reset_rx_datapath_in),
  .gtpowergood_in 		(gtpowergood_in 		)
);


/////////////////////////////////////////////////////////////////////////////
//////////////////////// ASYNC PRBS /////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
  localparam RX_AXIS_RT_STAGES  = 3; // minimum 2 stages

  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tlast_0_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tlast_1_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tlast_2_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tlast_3_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tvalid_0_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tvalid_1_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tvalid_2_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0]       rx_axis_tvalid_3_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][55:0] rx_preambleout_0_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][55:0] rx_preambleout_1_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][55:0] rx_preambleout_2_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][55:0] rx_preambleout_3_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata0_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata1_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata2_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata3_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata4_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata5_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata6_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][63:0] rx_axis_tdata7_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user0_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user1_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user2_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user3_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user4_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user5_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user6_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][10:0] rx_axis_tkeep_user7_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][54:0] rx_ptp_tstamp_out_0_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][54:0] rx_ptp_tstamp_out_1_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][54:0] rx_ptp_tstamp_out_2_q;
  (* shreg_extract = "no" *) reg [RX_AXIS_RT_STAGES-1:0][54:0] rx_ptp_tstamp_out_3_q;


  always_ff @(posedge rx_client0_axi_clk or negedge rx_client0_axi_rstn) begin
    if(!rx_client0_axi_rstn) begin
      rx_axis_tvalid_0_q <= '0;
    end
    else begin
      rx_axis_tvalid_0_q <= {rx_axis_tvalid_0_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tvalid_0};
    end
  end

  always_ff @(posedge rx_client0_axi_clk) begin
    rx_axis_tlast_0_q       <= {rx_axis_tlast_0_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tlast_0};
    rx_preambleout_0_q      <= {rx_preambleout_0_q[RX_AXIS_RT_STAGES-2:0],rx_preambleout_0};
    rx_ptp_tstamp_out_0_q   <= {rx_ptp_tstamp_out_0_q[RX_AXIS_RT_STAGES-2:0],rx_ptp_tstamp_out_0};
  end


  always_ff @(posedge rx_client1_axi_clk or negedge rx_client1_axi_rstn) begin
    if(!rx_client1_axi_rstn) begin
      rx_axis_tvalid_1_q <= '0;
    end
    else begin
      rx_axis_tvalid_1_q <= {rx_axis_tvalid_1_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tvalid_1};
    end
  end

  always_ff @(posedge rx_client1_axi_clk) begin
    rx_axis_tlast_1_q       <= {rx_axis_tlast_1_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tlast_1};
    rx_preambleout_1_q      <= {rx_preambleout_1_q[RX_AXIS_RT_STAGES-2:0],rx_preambleout_1};
    rx_ptp_tstamp_out_1_q   <= {rx_ptp_tstamp_out_1_q[RX_AXIS_RT_STAGES-2:0],rx_ptp_tstamp_out_1};
  end


  always_ff @(posedge rx_client2_axi_clk or negedge rx_client2_axi_rstn) begin
    if(!rx_client2_axi_rstn) begin
      rx_axis_tvalid_2_q <= '0;
    end
    else begin
      rx_axis_tvalid_2_q <= {rx_axis_tvalid_2_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tvalid_2};
    end
  end

  always_ff @(posedge rx_client2_axi_clk) begin
    rx_axis_tlast_2_q       <= {rx_axis_tlast_2_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tlast_2};
    rx_preambleout_2_q      <= {rx_preambleout_2_q[RX_AXIS_RT_STAGES-2:0],rx_preambleout_2};
    rx_ptp_tstamp_out_2_q   <= {rx_ptp_tstamp_out_2_q[RX_AXIS_RT_STAGES-2:0],rx_ptp_tstamp_out_2};
  end


  always_ff @(posedge rx_client3_axi_clk or negedge rx_client3_axi_rstn) begin
    if(!rx_client3_axi_rstn) begin
      rx_axis_tvalid_3_q <= '0;
    end
    else begin
      rx_axis_tvalid_3_q <= {rx_axis_tvalid_3_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tvalid_3};
    end
  end

  always_ff @(posedge rx_client3_axi_clk) begin
    rx_axis_tlast_3_q       <= {rx_axis_tlast_3_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tlast_3};
    rx_preambleout_3_q      <= {rx_preambleout_3_q[RX_AXIS_RT_STAGES-2:0],rx_preambleout_3};
    rx_ptp_tstamp_out_3_q   <= {rx_ptp_tstamp_out_3_q[RX_AXIS_RT_STAGES-2:0],rx_ptp_tstamp_out_3};
  end



  always_ff @(posedge rx_client0_axi_clk) begin
    rx_axis_tdata0_q      <= {rx_axis_tdata0_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata0};
    rx_axis_tkeep_user0_q <= {rx_axis_tkeep_user0_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user0};
  end

  always_ff @(posedge rx_client0_axi_clk) begin
    rx_axis_tdata1_q      <= {rx_axis_tdata1_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata1};
    rx_axis_tkeep_user1_q <= {rx_axis_tkeep_user1_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user1};
  end

  always_ff @(posedge rx_client1_axi_clk) begin
    rx_axis_tdata2_q      <= {rx_axis_tdata2_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata2};
    rx_axis_tkeep_user2_q <= {rx_axis_tkeep_user2_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user2};
  end

  always_ff @(posedge rx_client1_axi_clk) begin
    rx_axis_tdata3_q      <= {rx_axis_tdata3_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata3};
    rx_axis_tkeep_user3_q <= {rx_axis_tkeep_user3_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user3};
  end

  always_ff @(posedge rx_client2_axi_clk) begin
    rx_axis_tdata4_q      <= {rx_axis_tdata4_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata4};
    rx_axis_tkeep_user4_q <= {rx_axis_tkeep_user4_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user4};
  end

  always_ff @(posedge rx_client2_axi_clk) begin
    rx_axis_tdata5_q      <= {rx_axis_tdata5_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata5};
    rx_axis_tkeep_user5_q <= {rx_axis_tkeep_user5_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user5};
  end

  always_ff @(posedge rx_client3_axi_clk) begin
    rx_axis_tdata6_q      <= {rx_axis_tdata6_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata6};
    rx_axis_tkeep_user6_q <= {rx_axis_tkeep_user6_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user6};
  end

  always_ff @(posedge rx_client3_axi_clk) begin
    rx_axis_tdata7_q      <= {rx_axis_tdata7_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tdata7};
    rx_axis_tkeep_user7_q <= {rx_axis_tkeep_user7_q[RX_AXIS_RT_STAGES-2:0],rx_axis_tkeep_user7};
  end

  assign tx_axis_tdata0      = client0_tx_axis_tdata0;
  assign tx_axis_tdata1      = client0_tx_axis_tdata1;
  assign tx_axis_tdata2      = !c0_top_ctl_muxes[0] ? client0_tx_axis_tdata2      : client1_tx_axis_tdata0;
  assign tx_axis_tdata3      = !c0_top_ctl_muxes[0] ? client0_tx_axis_tdata3      : client1_tx_axis_tdata1;
  assign tx_axis_tdata4      = !c0_top_ctl_muxes[1] ? client0_tx_axis_tdata4      : client2_tx_axis_tdata0;
  assign tx_axis_tdata5      = !c0_top_ctl_muxes[1] ? client0_tx_axis_tdata5      : client2_tx_axis_tdata1;
  assign tx_axis_tdata6      = !c0_top_ctl_muxes[2] ? client2_tx_axis_tdata2      : client3_tx_axis_tdata0;
  assign tx_axis_tdata7      = !c0_top_ctl_muxes[2] ? client2_tx_axis_tdata3      : client3_tx_axis_tdata1;
  assign tx_axis_tkeep_user0 = client0_tx_axis_tkeep_user0;
  assign tx_axis_tkeep_user1 = client0_tx_axis_tkeep_user1;
  assign tx_axis_tkeep_user2 = !c0_top_ctl_muxes[0] ? client0_tx_axis_tkeep_user2 : client1_tx_axis_tkeep_user0;
  assign tx_axis_tkeep_user3 = !c0_top_ctl_muxes[0] ? client0_tx_axis_tkeep_user3 : client1_tx_axis_tkeep_user1;
  assign tx_axis_tkeep_user4 = !c0_top_ctl_muxes[1] ? client0_tx_axis_tkeep_user4 : client2_tx_axis_tkeep_user0;
  assign tx_axis_tkeep_user5 = !c0_top_ctl_muxes[1] ? client0_tx_axis_tkeep_user5 : client2_tx_axis_tkeep_user1;
  assign tx_axis_tkeep_user6 = !c0_top_ctl_muxes[2] ? client2_tx_axis_tkeep_user2 : client3_tx_axis_tkeep_user0;
  assign tx_axis_tkeep_user7 = !c0_top_ctl_muxes[2] ? client2_tx_axis_tkeep_user3 : client3_tx_axis_tkeep_user1;

mrmac_0_axis_stream_mux i_mrmac_0_axis_stream_mux
  (
   .clk      ({tx_client3_axi_clk,tx_client2_axi_clk,tx_client1_axi_clk,tx_client0_axi_clk}),
   .reset    (~{tx_client3_axi_rstn,tx_client2_axi_rstn,tx_client1_axi_rstn,tx_client0_axi_rstn}),

   .mux_sel  (c0_top_ctl_muxes[2:0]),

   // S_AXIS
   .s_tvalid ({tx_axis_tvalid_3,tx_axis_tvalid_2,tx_axis_tvalid_1,tx_axis_tvalid_0}),
   .s_tdata  ({tx_axis_tdata7,tx_axis_tdata6,tx_axis_tdata5,tx_axis_tdata4,
               tx_axis_tdata3,tx_axis_tdata2,tx_axis_tdata1,tx_axis_tdata0}),
   .s_tkeep  ({tx_axis_tkeep_user7,tx_axis_tkeep_user6,tx_axis_tkeep_user5,tx_axis_tkeep_user4,
               tx_axis_tkeep_user3,tx_axis_tkeep_user2,tx_axis_tkeep_user1,tx_axis_tkeep_user0}),
   .s_tlast  ({tx_axis_tlast_3,tx_axis_tlast_2,tx_axis_tlast_1,tx_axis_tlast_0}),
   .s_tready (axis_buffer_tx_tready),

   // M_AXIS
   .m_tvalid (axis_buffer_tx_tvalid),
   .m_tdata  (axis_buffer_tx_tdata),
   .m_tkeep  (axis_buffer_tx_tkeep),
   .m_tlast  (axis_buffer_tx_tlast),
   .m_tready    ({tx_axis_tready_3,tx_axis_tready_2,tx_axis_tready_1,tx_axis_tready_0})
   );


mrmac_0_prbs_gen_crc_check_async_all i_mrmac_0_pkt_gen_mon_all_0
   (
   .tx_clk                         (tx_client0_axi_clk),
   .tx_reset                       (!tx_client0_axi_rstn),
   .rx_clk                         (rx_client0_axi_clk),
   .rx_reset                       (!rx_client0_axi_rstn),

   .segmented_mode                 (1'b0),
   .number_of_segments             (c0_number_of_segments),
   .ten_gb_mode                    (c0_ten_gb_mode),
   .DUPLEX_PKT_SIZE                (prbs_pkt_size),
   .start_prbs                     (client0_start_prbs),
   .stop_prbs_tx                   (client0_stop_prbs),
   .tx_mac_dest_addr               (dest_addr),
   .tx_mac_src_addr                (source_addr),
   .tx_axis_ovfout                 (1'b0),
   .tx_axis_unfout                 (1'b0),
   .clear_rx_counters              (1'b0),
   .clear_tx_counters              (1'b0),
   .ctl_data_rate                  (c0_top_ctl_data_rate),
  .tx_fcs_compensate                        (c0_tx_fcs_compensate),
  .rx_fcs_compensate                        (c0_rx_fcs_compensate),

   .client_tx_axis_tdata0          (client0_tx_axis_tdata0),
   .client_tx_axis_tdata1          (client0_tx_axis_tdata1),
   .client_tx_axis_tdata2          (client0_tx_axis_tdata2),
   .client_tx_axis_tdata3          (client0_tx_axis_tdata3),
   .client_tx_axis_tdata4          (client0_tx_axis_tdata4),
   .client_tx_axis_tdata5          (client0_tx_axis_tdata5),
   .client_tx_axis_tkeep_user0     (client0_tx_axis_tkeep_user0),
   .client_tx_axis_tkeep_user1     (client0_tx_axis_tkeep_user1),
   .client_tx_axis_tkeep_user2     (client0_tx_axis_tkeep_user2),
   .client_tx_axis_tkeep_user3     (client0_tx_axis_tkeep_user3),
   .client_tx_axis_tkeep_user4     (client0_tx_axis_tkeep_user4),
   .client_tx_axis_tkeep_user5     (client0_tx_axis_tkeep_user5),
   .tx_axis_tvalid                      (tx_axis_tvalid_0),
   .tx_axis_tlast                       (tx_axis_tlast_0),
   .tx_axis_tready                      (axis_buffer_tx_tready[0]),

   .rx_axis_tvalid                      (rx_axis_tvalid_0_q[RX_AXIS_RT_STAGES-1]),
   .rx_axis_tdata0                      (rx_axis_tdata0_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata1                      (rx_axis_tdata1_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata2                      (rx_axis_tdata2_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata3                      (rx_axis_tdata3_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata4                      (rx_axis_tdata4_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata5                      (rx_axis_tdata5_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tkeep_user0                 (rx_axis_tkeep_user0_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user1                 (rx_axis_tkeep_user1_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user2                 (rx_axis_tkeep_user2_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user3                 (rx_axis_tkeep_user3_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user4                 (rx_axis_tkeep_user4_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user5                 (rx_axis_tkeep_user5_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tlast                       (rx_axis_tlast_0_q[RX_AXIS_RT_STAGES-1]),

   .crc_fifo_reset                      (1'b0),
   .client_tx_frames_transmitted_latched  (),
   .tx_done_led                         (),
   .tx_busy_led                         (),
   .client_rx_errored_frames_latched    (),
   .client_rx_frames_received_latched   (),
   .client_rx_bytes_received_latched    (),
  .client_tx_bytes_transmitted_latched  (),
   .crc_error_cnt                       ()
);

mrmac_0_prbs_gen_crc_check_async_25g i_mrmac_0_pkt_gen_mon_25_10g_1
   (
   .tx_clk                         (tx_client1_axi_clk),
   .tx_reset                       (!tx_client1_axi_rstn),
   .rx_clk                         (rx_client1_axi_clk),
   .rx_reset                       (!rx_client1_axi_rstn),

   .segmented_mode                 (c1_segmented_mode),
   .number_of_segments             (c1_number_of_segments),
   .ten_gb_mode                    (c1_ten_gb_mode),
   .DUPLEX_PKT_SIZE                (prbs_pkt_size),
   .start_prbs                     (client1_start_prbs),
   .stop_prbs_tx                   (client1_stop_prbs),
   .tx_mac_dest_addr               (dest_addr),
   .tx_mac_src_addr                (source_addr),
   .tx_axis_ovfout                 (1'b0),
   .tx_axis_unfout                 (1'b0),
   .clear_rx_counters              (1'b0),
   .clear_tx_counters              (1'b0),
   .ctl_data_rate                  (c1_top_ctl_data_rate[0]),
  .tx_fcs_compensate                        (c1_tx_fcs_compensate),
  .rx_fcs_compensate                        (c1_rx_fcs_compensate),

   .client_tx_axis_tdata0          (client1_tx_axis_tdata0),
   .client_tx_axis_tdata1          (client1_tx_axis_tdata1),
   .client_tx_axis_tdata2          (),
   .client_tx_axis_tdata3          (),
   .client_tx_axis_tdata4          (),
   .client_tx_axis_tdata5          (),
   .client_tx_axis_tkeep_user0     (client1_tx_axis_tkeep_user0),
   .client_tx_axis_tkeep_user1     (client1_tx_axis_tkeep_user1),
   .client_tx_axis_tkeep_user2     (),
   .client_tx_axis_tkeep_user3     (),
   .client_tx_axis_tkeep_user4     (),
   .client_tx_axis_tkeep_user5     (),
   .tx_axis_tvalid                      (tx_axis_tvalid_1),
   .tx_axis_tlast                       (tx_axis_tlast_1),
   .tx_axis_tready                      (axis_buffer_tx_tready[1]),

   .rx_axis_tvalid                      (rx_axis_tvalid_1_q[RX_AXIS_RT_STAGES-1]),
   .rx_axis_tdata0                      (rx_axis_tdata2_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata1                      (rx_axis_tdata3_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata2                      ({64{1'b0}}),
   .rx_axis_tdata3                      ({64{1'b0}}),
   .rx_axis_tdata4                      ({64{1'b0}}),
   .rx_axis_tdata5                      ({64{1'b0}}),
   .rx_axis_tkeep_user0                 (rx_axis_tkeep_user2_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user1                 (rx_axis_tkeep_user3_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user2                 ({11{1'b0}}),
   .rx_axis_tkeep_user3                 ({11{1'b0}}),
   .rx_axis_tkeep_user4                 ({11{1'b0}}),
   .rx_axis_tkeep_user5                 ({11{1'b0}}),
   .rx_axis_tlast                       (rx_axis_tlast_1_q[RX_AXIS_RT_STAGES-1]),

   .crc_fifo_reset                      (1'b0),
   .client_tx_frames_transmitted_latched  (),
   .tx_done_led                         (),
   .tx_busy_led                         (),
   .client_rx_errored_frames_latched    (),
   .client_rx_frames_received_latched   (),
   .client_rx_bytes_received_latched    (),
  .client_tx_bytes_transmitted_latched  (),
   .crc_error_cnt                       ()
);

mrmac_0_prbs_gen_crc_check_async_50g i_mrmac_0_pkt_gen_mon_50g_2
   (
   .tx_clk                         (tx_client2_axi_clk),
   .tx_reset                       (!tx_client2_axi_rstn),
   .rx_clk                         (rx_client2_axi_clk),
   .rx_reset                       (!rx_client2_axi_rstn),

   .segmented_mode                 (c2_segmented_mode),
   .number_of_segments             (c2_number_of_segments),
   .ten_gb_mode                    (c2_ten_gb_mode),
   .DUPLEX_PKT_SIZE                (prbs_pkt_size),
   .start_prbs                     (client2_start_prbs),
   .stop_prbs_tx                   (client2_stop_prbs),
   .tx_mac_dest_addr               (dest_addr),
   .tx_mac_src_addr                (source_addr),
   .tx_axis_ovfout                 (1'b0),
   .tx_axis_unfout                 (1'b0),
   .clear_rx_counters              (1'b0),
   .clear_tx_counters              (1'b0),
   .ctl_data_rate                  (c2_top_ctl_data_rate[1:0]),
  .tx_fcs_compensate                        (c2_tx_fcs_compensate),
  .rx_fcs_compensate                        (c2_rx_fcs_compensate),

   .client_tx_axis_tdata0          (client2_tx_axis_tdata0),
   .client_tx_axis_tdata1          (client2_tx_axis_tdata1),
   .client_tx_axis_tdata2          (client2_tx_axis_tdata2),
   .client_tx_axis_tdata3          (client2_tx_axis_tdata3),
   .client_tx_axis_tdata4          (),
   .client_tx_axis_tdata5          (),
   .client_tx_axis_tkeep_user0     (client2_tx_axis_tkeep_user0),
   .client_tx_axis_tkeep_user1     (client2_tx_axis_tkeep_user1),
   .client_tx_axis_tkeep_user2     (client2_tx_axis_tkeep_user2),
   .client_tx_axis_tkeep_user3     (client2_tx_axis_tkeep_user3),
   .client_tx_axis_tkeep_user4     (),
   .client_tx_axis_tkeep_user5     (),
   .tx_axis_tvalid                      (tx_axis_tvalid_2),
   .tx_axis_tlast                       (tx_axis_tlast_2),
   .tx_axis_tready                      (axis_buffer_tx_tready[2]),

   .rx_axis_tvalid                      (rx_axis_tvalid_2_q[RX_AXIS_RT_STAGES-1]),
   .rx_axis_tdata0                      (rx_axis_tdata4_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata1                      (rx_axis_tdata5_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata2                      (rx_axis_tdata6_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata3                      (rx_axis_tdata7_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata4                      ({64{1'b0}}),
   .rx_axis_tdata5                      ({64{1'b0}}),
   .rx_axis_tkeep_user0                 (rx_axis_tkeep_user4_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user1                 (rx_axis_tkeep_user5_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user2                 (rx_axis_tkeep_user6_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user3                 (rx_axis_tkeep_user7_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user4                 ({11{1'b0}}),
   .rx_axis_tkeep_user5                 ({11{1'b0}}),
   .rx_axis_tlast                       (rx_axis_tlast_2_q[RX_AXIS_RT_STAGES-1]),

   .crc_fifo_reset                      (1'b0),
   .client_tx_frames_transmitted_latched    (),
   .tx_done_led                         (),
   .tx_busy_led                         (),
   .client_rx_errored_frames_latched    (),
   .client_rx_frames_received_latched   (),
   .client_rx_bytes_received_latched    (),
  .client_tx_bytes_transmitted_latched  (),
   .crc_error_cnt                       ()
);

mrmac_0_prbs_gen_crc_check_async_25g i_mrmac_0_pkt_gen_mon_25_10g_3
   (
   .tx_clk                         (tx_client3_axi_clk),
   .tx_reset                       (!tx_client3_axi_rstn),
   .rx_clk                         (rx_client3_axi_clk),
   .rx_reset                       (!rx_client3_axi_rstn),

   .segmented_mode                 (c3_segmented_mode),
   .number_of_segments             (c3_number_of_segments),
   .ten_gb_mode                    (c3_ten_gb_mode),
   .DUPLEX_PKT_SIZE                (prbs_pkt_size),
   .start_prbs                     (client3_start_prbs),
   .stop_prbs_tx                   (client3_stop_prbs),
   .tx_mac_dest_addr               (dest_addr),
   .tx_mac_src_addr                (source_addr),
   .tx_axis_ovfout                 (1'b0),
   .tx_axis_unfout                 (1'b0),
   .clear_rx_counters              (1'b0),
   .clear_tx_counters              (1'b0),
   .ctl_data_rate                  (c3_top_ctl_data_rate[0]),
  .tx_fcs_compensate                        (c3_tx_fcs_compensate),
  .rx_fcs_compensate                        (c3_rx_fcs_compensate),

   .client_tx_axis_tdata0          (client3_tx_axis_tdata0),
   .client_tx_axis_tdata1          (client3_tx_axis_tdata1),
   .client_tx_axis_tdata2          (),
   .client_tx_axis_tdata3          (),
   .client_tx_axis_tdata4          (),
   .client_tx_axis_tdata5          (),
   .client_tx_axis_tkeep_user0     (client3_tx_axis_tkeep_user0),
   .client_tx_axis_tkeep_user1     (client3_tx_axis_tkeep_user1),
   .client_tx_axis_tkeep_user2     (),
   .client_tx_axis_tkeep_user3     (),
   .client_tx_axis_tkeep_user4     (),
   .client_tx_axis_tkeep_user5     (),
   .tx_axis_tvalid                      (tx_axis_tvalid_3),
   .tx_axis_tlast                       (tx_axis_tlast_3),
   .tx_axis_tready                      (axis_buffer_tx_tready[3]),

   .rx_axis_tvalid                      (rx_axis_tvalid_3_q[RX_AXIS_RT_STAGES-1]),
   .rx_axis_tdata0                      (rx_axis_tdata6_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata1                      (rx_axis_tdata7_q[RX_AXIS_RT_STAGES-1][63:0]),
   .rx_axis_tdata2                      ({64{1'b0}}),
   .rx_axis_tdata3                      ({64{1'b0}}),
   .rx_axis_tdata4                      ({64{1'b0}}),
   .rx_axis_tdata5                      ({64{1'b0}}),
   .rx_axis_tkeep_user0                 (rx_axis_tkeep_user6_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user1                 (rx_axis_tkeep_user7_q[RX_AXIS_RT_STAGES-1][10:0]),
   .rx_axis_tkeep_user2                 ({11{1'b0}}),
   .rx_axis_tkeep_user3                 ({11{1'b0}}),
   .rx_axis_tkeep_user4                 ({11{1'b0}}),
   .rx_axis_tkeep_user5                 ({11{1'b0}}),
   .rx_axis_tlast                       (rx_axis_tlast_3_q[RX_AXIS_RT_STAGES-1]),

   .crc_fifo_reset                      (1'b0),
   .client_tx_frames_transmitted_latched  (),
   .tx_done_led                         (),
   .tx_busy_led                         (),
   .client_rx_errored_frames_latched    (),
   .client_rx_frames_received_latched   (),
   .client_rx_bytes_received_latched    (),
  .client_tx_bytes_transmitted_latched  (),
   .crc_error_cnt                       ()
);





	assign SW_REG_GT_LOOPBACK = 32'd0;
	assign SW_REG_GT_LINE_RATE = {gt_line_rate,gt_line_rate,gt_line_rate,gt_line_rate};
    assign stat_mst_reset_done = gt_rx_reset_done_out;
endmodule




