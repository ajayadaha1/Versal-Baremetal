
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
module mrmac_0_exdes_imp_top
(
    input  wire       gt_ref_clk_p,
    input  wire       gt_ref_clk_n,
    input  wire [3:0] gt_rxn_in,
    input  wire [3:0] gt_rxp_in,
    output wire [3:0] gt_txn_out,
    output wire [3:0] gt_txp_out
    );
 wire [7 :0]      gt_line_rate;
 wire [2 : 0]     gt_loopback;
 wire [3:0]   gt_reset_tx_datapath_in ;
 wire [3:0]   gt_reset_rx_datapath_in ;
 wire [31 : 0]    s_axi_awaddr;
 wire             s_axi_awvalid;
 wire             s_axi_awready;
 wire [31 : 0]    s_axi_wdata;
 wire             s_axi_wvalid;
 wire             s_axi_wready;
 wire [1 : 0]     s_axi_bresp;
 wire             s_axi_bvalid;
 wire             s_axi_bready;
 wire [31 : 0]    s_axi_araddr;
 wire             s_axi_arvalid;
 wire             s_axi_arready;
 wire [31 : 0]    s_axi_rdata;
 wire [1 : 0]     s_axi_rresp;
 wire             s_axi_rvalid;
 wire             s_axi_rready;
 wire   [2:0]     c0_top_ctl_muxes;
 wire   [2:0]     c0_number_of_segments;
 wire             c0_ten_gb_mode;	
 wire             c0_trig_in;
 wire  [2:0]      c0_top_ctl_data_rate;
 wire             c1_trig_in;
 wire  [2:0]      c1_number_of_segments; 
 wire             c1_ten_gb_mode;
 wire  [2:0]      c1_top_ctl_data_rate;  
 wire             c2_trig_in;
 wire  [2:0]      c2_number_of_segments;
 wire             c2_ten_gb_mode;
 wire  [2:0]      c2_top_ctl_data_rate; 	
 wire             c3_trig_in;
 wire  [2:0]      c3_number_of_segments;
 wire             c3_ten_gb_mode;
 wire             c3_crc_fifo_reset;
 wire  [2:0]      c3_top_ctl_data_rate;	
 wire [3:0]       stat_mst_reset_done;
 wire  [3:0]      gt_reset_all_in;
 wire             pl0_ref_clk_0;
 wire             pl0_resetn_0;   
 	
 
 
  
    
mrmac_0_exdes i_mrmac_0_exdes(
 	
 	
 
 
 
    .gt_line_rate                       (gt_line_rate),				//input  wire [7:0]    gt_line_rate,
    .gt_loopback                        (gt_loopback),				//input  wire [2:0]    gt_loopback,
    .gt_reset_rx_datapath_in 		(gt_reset_rx_datapath_in),
    .gt_reset_tx_datapath_in 		(gt_reset_tx_datapath_in),
    .s_axi_aclk				(pl0_ref_clk_0			),// input wire             s_axi_aclk,
    .s_axi_aresetn			(pl0_resetn_0 			),// input wire             s_axi_aresetn,
    .s_axi_awaddr			(s_axi_awaddr			),// input wire [31 : 0]    s_axi_awaddr,
    .s_axi_awvalid			(s_axi_awvalid			),// input wire             s_axi_awvalid,
    .s_axi_awready			(s_axi_awready			),// output wire            s_axi_awready,
    .s_axi_wdata			(s_axi_wdata			),// input wire [31 : 0]    s_axi_wdata,
    .s_axi_wvalid			(s_axi_wvalid			),// input wire             s_axi_wvalid,
    .s_axi_wready			(s_axi_wready			),// output wire            s_axi_wready,
    .s_axi_bresp			(s_axi_bresp			),// output wire [1 : 0]    s_axi_bresp,
    .s_axi_bvalid			(s_axi_bvalid			),// output wire            s_axi_bvalid,
    .s_axi_bready			(s_axi_bready			),// input wire             s_axi_bready,
    .s_axi_araddr			(s_axi_araddr			),// input wire [31 : 0]    s_axi_araddr,
    .s_axi_arvalid			(s_axi_arvalid			),// input wire             s_axi_arvalid,
    .s_axi_arready			(s_axi_arready			),// output wire            s_axi_arready,
    .s_axi_rdata			(s_axi_rdata			),// output wire [31 : 0]   s_axi_rdata,
    .s_axi_rresp			(s_axi_rresp			),// output wire [1 : 0]    s_axi_rresp,
    .s_axi_rvalid			(s_axi_rvalid			),// output wire            s_axi_rvalid,
    .s_axi_rready			(s_axi_rready			),// input wire             s_axi_rready,
	.c0_top_ctl_muxes		(c0_top_ctl_muxes		),// input wire   [2:0]     c0_top_ctl_muxes,
	.c0_number_of_segments	(c0_number_of_segments	),// input wire   [2:0]     c0_number_of_segments,
    .c0_ten_gb_mode			(c0_ten_gb_mode			),// input wire             c0_ten_gb_mode,	
    .c0_trig_in			    (c0_trig_in  			),// input wire             c0_trig_in,
    .c0_top_ctl_data_rate	(c0_top_ctl_data_rate	),// input wire  [2:0]      c0_top_ctl_data_rate,
    .c1_trig_in			    (c1_trig_in  			),// input wire             c1_trig_in,
	.c1_number_of_segments	(c1_number_of_segments	),// input wire  [2:0]      c1_number_of_segments, 
	.c1_ten_gb_mode			(c1_ten_gb_mode			),// input wire             c1_ten_gb_mode,
	.c1_top_ctl_data_rate	(c1_top_ctl_data_rate	),// input wire  [2:0]      c1_top_ctl_data_rate,  
    .c2_trig_in			    (c2_trig_in  			),// input wire             c2_trig_in,
	.c2_number_of_segments	(c2_number_of_segments	),// input wire  [2:0]      c2_number_of_segments,
	.c2_ten_gb_mode			(c2_ten_gb_mode			),// input wire             c2_ten_gb_mode,
	.c2_top_ctl_data_rate	(c2_top_ctl_data_rate	),// input wire  [2:0]      c2_top_ctl_data_rate, 	
    .c3_trig_in			    (c3_trig_in  			),// input wire             c3_trig_in,
	.c3_number_of_segments	(c3_number_of_segments	),// input wire  [2:0]      c3_number_of_segments,
	.c3_ten_gb_mode			(c3_ten_gb_mode			),// input wire             c3_ten_gb_mode,
	.c3_crc_fifo_reset		(c3_crc_fifo_reset		),// input wire             c3_crc_fifo_reset,
	.c3_top_ctl_data_rate	(c3_top_ctl_data_rate	),// input wire  [2:0]      c3_top_ctl_data_rate,	
    .stat_mst_reset_done	(stat_mst_reset_done	),// output wire [3:0]      stat_mst_reset_done,
    .gt_rxn_in				(gt_rxn_in				),// input  wire [3:0]      gt_rxn_in,
    .gt_rxp_in				(gt_rxp_in				),// input  wire [3:0]      gt_rxp_in,
    .gt_txn_out				(gt_txn_out				),// output wire [3:0]      gt_txn_out,
    .gt_txp_out				(gt_txp_out				),// output wire [3:0]      gt_txp_out,
    .gt_reset_all_in		(gt_reset_all_in		),// input  wire  [3:0]     gt_reset_all_in,
    .gt_ref_clk_p			(gt_ref_clk_p			),// input  wire            gt_ref_clk_p,
    .gt_ref_clk_n			(gt_ref_clk_n			),// input  wire            gt_ref_clk_n,
    .pl_clk					(pl0_ref_clk_0          ),// input  wire            pl_clk,
	.pl_resetn				(pl0_resetn_0           ) // input  wire            pl_resetn
);

mrmac_0_cips_wrapper i_mrmac_0_cips_wrapper(
    .M00_AXI_0_araddr     (s_axi_araddr),  // output [31:0]M00_AXI_0_araddr;
    .M00_AXI_0_arprot     (),// output [2:0]M00_AXI_0_arprot;
    .M00_AXI_0_arready    (s_axi_arready), // input M00_AXI_0_arready;
    .M00_AXI_0_arvalid    (s_axi_arvalid), //// output M00_AXI_0_arvalid;
    .M00_AXI_0_awaddr     (s_axi_awaddr),  //// output [31:0]M00_AXI_0_awaddr;
    .M00_AXI_0_awprot     (),// output [2:0]M00_AXI_0_awprot;
    .M00_AXI_0_awready    (s_axi_awready),// input M00_AXI_0_awready;
    .M00_AXI_0_awvalid    (s_axi_awvalid),// output M00_AXI_0_awvalid;
    .M00_AXI_0_bready     (s_axi_bready),// output M00_AXI_0_bready;
    .M00_AXI_0_bresp      (s_axi_bresp),// input [1:0]M00_AXI_0_bresp;
    .M00_AXI_0_bvalid     (s_axi_bvalid),// input M00_AXI_0_bvalid;
    .M00_AXI_0_rdata      (s_axi_rdata),// input [31:0]M00_AXI_0_rdata;
    .M00_AXI_0_rready     (s_axi_rready),// output M00_AXI_0_rready;
    .M00_AXI_0_rresp      (s_axi_rresp),// input [1:0]M00_AXI_0_rresp;
    .M00_AXI_0_rvalid     (s_axi_rvalid),// input M00_AXI_0_rvalid;
    .M00_AXI_0_wdata      (s_axi_wdata),// output [31:0]M00_AXI_0_wdata;
    .M00_AXI_0_wready     (s_axi_wready),// input M00_AXI_0_wready;
    .M00_AXI_0_wstrb      (),// output [3:0]M00_AXI_0_wstrb;
    .M00_AXI_0_wvalid     (s_axi_wvalid),// output M00_AXI_0_wvalid;
	
    .M00_AXI_1_araddr     (		),	
    .M00_AXI_1_arprot     (		),	
    .M00_AXI_1_arready    (1'b0	),
    .M00_AXI_1_arvalid    (		),	
    .M00_AXI_1_awaddr     (		),	
    .M00_AXI_1_awprot     (		),	
    .M00_AXI_1_awready    (1'b0	),
    .M00_AXI_1_awvalid    (		),	
    .M00_AXI_1_bready     (		),	
    .M00_AXI_1_bresp      (2'b00),
    .M00_AXI_1_bvalid     (1'b0	),
    .M00_AXI_1_rdata      (32'd0),
    .M00_AXI_1_rready     (		),	
    .M00_AXI_1_rresp      (2'b00),
    .M00_AXI_1_rvalid     (1'b0	),
    .M00_AXI_1_wdata      (		),	
    .M00_AXI_1_wready     (1'b0	),
    .M00_AXI_1_wstrb      (		),	
    .M00_AXI_1_wvalid     (		),		
 
	
    .M00_AXI_2_araddr     (		),	
    .M00_AXI_2_arprot     (		),	
    .M00_AXI_2_arready    (1'b0	),
    .M00_AXI_2_arvalid    (		),	
    .M00_AXI_2_awaddr     (		),	
    .M00_AXI_2_awprot     (		),	
    .M00_AXI_2_awready    (1'b0	),
    .M00_AXI_2_awvalid    (		),	
    .M00_AXI_2_bready     (		),	
    .M00_AXI_2_bresp      (2'b00),
    .M00_AXI_2_bvalid     (1'b0	),
    .M00_AXI_2_rdata      (32'd0),
    .M00_AXI_2_rready     (		),	
    .M00_AXI_2_rresp      (2'b00),
    .M00_AXI_2_rvalid     (1'b0	),
    .M00_AXI_2_wdata      (		),	
    .M00_AXI_2_wready     (1'b0	),
    .M00_AXI_2_wstrb      (		),	
    .M00_AXI_2_wvalid     (		),		
 	
	
    .M00_AXI_3_araddr     (		),	
    .M00_AXI_3_arprot     (		),	
    .M00_AXI_3_arready    (1'b0	),
    .M00_AXI_3_arvalid    (		),	
    .M00_AXI_3_awaddr     (		),	
    .M00_AXI_3_awprot     (		),	
    .M00_AXI_3_awready    (1'b0	),
    .M00_AXI_3_awvalid    (		),	
    .M00_AXI_3_bready     (		),	
    .M00_AXI_3_bresp      (2'b00),
    .M00_AXI_3_bvalid     (1'b0	),
    .M00_AXI_3_rdata      (32'd0),
    .M00_AXI_3_rready     (		),	
    .M00_AXI_3_rresp      (2'b00),
    .M00_AXI_3_rvalid     (1'b0	),
    .M00_AXI_3_wdata      (		),	
    .M00_AXI_3_wready     (1'b0	),
    .M00_AXI_3_wstrb      (		),	
    .M00_AXI_3_wvalid     (		),		
 
	
    .M00_AXI_4_araddr     (		),	
    .M00_AXI_4_arprot     (		),	
    .M00_AXI_4_arready    (1'b0	),
    .M00_AXI_4_arvalid    (		),	
    .M00_AXI_4_awaddr     (		),	
    .M00_AXI_4_awprot     (		),	
    .M00_AXI_4_awready    (1'b0	),
    .M00_AXI_4_awvalid    (		),	
    .M00_AXI_4_bready     (		),	
    .M00_AXI_4_bresp      (2'b00),
    .M00_AXI_4_bvalid     (1'b0	),
    .M00_AXI_4_rdata      (32'd0),
    .M00_AXI_4_rready     (		),	
    .M00_AXI_4_rresp      (2'b00),
    .M00_AXI_4_rvalid     (1'b0	),
    .M00_AXI_4_wdata      (		),	
    .M00_AXI_4_wready     (1'b0	),
    .M00_AXI_4_wstrb      (		),	
    .M00_AXI_4_wvalid     (		),		
 	
	
	
	
	
    .c0_number_of_segments(c0_number_of_segments),
    .c0_trig_in			  (c0_trig_in  			),
    .c0_ten_gb_mode       (c0_ten_gb_mode       ),
    .c0_top_ctl_data_rate (c0_top_ctl_data_rate ),
    .c0_top_ctl_muxes     (c0_top_ctl_muxes     ),
    .c1_number_of_segments(c1_number_of_segments),
    .c1_trig_in			  (c1_trig_in  			),
    .c1_ten_gb_mode       (c1_ten_gb_mode       ),
    .c1_top_ctl_data_rate (c1_top_ctl_data_rate ),
    .c2_number_of_segments(c2_number_of_segments),
    .c2_trig_in			  (c2_trig_in  			),
    .c2_ten_gb_mode       (c2_ten_gb_mode       ),
    .c2_top_ctl_data_rate (c2_top_ctl_data_rate ),
    .c3_number_of_segments(c3_number_of_segments),
    .c3_trig_in			  (c3_trig_in  			),
    .c3_ten_gb_mode       (c3_ten_gb_mode       ),
    .c3_top_ctl_data_rate (c3_top_ctl_data_rate ),
    .gt_line_rate         (gt_line_rate         ),
    .gt_reset_all_in      (gt_reset_all_in      ),
    .gt_loopback          (gt_loopback),
    .gt_reset_rx_datapath_in (gt_reset_rx_datapath_in),
    .gt_reset_tx_datapath_in (gt_reset_tx_datapath_in),
    .pl0_ref_clk_0        (pl0_ref_clk_0        ),
    .pl0_resetn_0         (pl0_resetn_0         ),
    .stat_mst_reset_done  (stat_mst_reset_done  )
); 
    
    
endmodule




