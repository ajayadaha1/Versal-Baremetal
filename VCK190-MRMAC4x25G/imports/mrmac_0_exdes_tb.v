
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

module mrmac_0_exdes_tb
(
);
    localparam pclk_cycle = 10000;
    //////////// axi_reg_map address
    parameter  ADDR_CORE_VERSION_REG                    =  32'h00000000;
    ///// For PORT-0
    parameter  ADDR_RESET_REG_0                         =  32'h00000004;
    parameter  ADDR_MODE_REG_0                          =  32'h00000008;
    parameter  ADDR_CONFIG_TX_REG1_0                    =  32'h0000000C;
    parameter  ADDR_CONFIG_RX_REG1_0                    =  32'h00000010;
    parameter  ADDR_TICK_REG_0                          =  32'h0000002C;
    parameter  ADDR_FEC_CONFIGURATION_REG1_0            =  32'h000000D0;
	parameter  ADDR_STAT_RX_STATUS_REG1_0               =  32'h00000744;
	parameter  ADDR_STAT_RX_RT_STATUS_REG1_0            =  32'h0000074C;	
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_LSB_0         =  32'h00000818;
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_MSB_0         =  32'h0000081C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_0    =  32'h00000820;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_0    =  32'h00000824;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_LSB_0           =  32'h00000828;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_MSB_0           =  32'h0000082C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_0      =  32'h00000830;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_0      =  32'h00000834;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_LSB_0         =  32'h00000E30;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_MSB_0         =  32'h00000E34;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_0    =  32'h00000E38;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_0    =  32'h00000E3C;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_LSB_0           =  32'h00000E40;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_MSB_0           =  32'h00000E44;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_0      =  32'h00000E48;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_0      =  32'h00000E4C;
    ///// For PORT-1
    parameter  ADDR_RESET_REG_1                         =  32'h00001004;
    parameter  ADDR_MODE_REG_1                          =  32'h00001008;
    parameter  ADDR_CONFIG_TX_REG1_1                    =  32'h0000100C;
    parameter  ADDR_CONFIG_RX_REG1_1                    =  32'h00001010;
    parameter  ADDR_TICK_REG_1                          =  32'h0000102C;
    parameter  ADDR_FEC_CONFIGURATION_REG1_1            =  32'h000010D0;
	parameter  ADDR_STAT_RX_STATUS_REG1_1               =  32'h00001744;
	parameter  ADDR_STAT_RX_RT_STATUS_REG1_1            =  32'h0000174C;	
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_LSB_1         =  32'h00001818;
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_MSB_1         =  32'h0000181C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_1    =  32'h00001820;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_1    =  32'h00001824;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_LSB_1           =  32'h00001828;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_MSB_1           =  32'h0000182C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_1      =  32'h00001830;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_1      =  32'h00001834;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_LSB_1         =  32'h00001E30;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_MSB_1         =  32'h00001E34;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_1    =  32'h00001E38;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_1    =  32'h00001E3C;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_LSB_1           =  32'h00001E40;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_MSB_1           =  32'h00001E44;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_1      =  32'h00001E48;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_1      =  32'h00001E4C;
    
    ///// For PORT-2
    parameter  ADDR_RESET_REG_2                         =  32'h00002004;
    parameter  ADDR_MODE_REG_2                          =  32'h00002008;
    parameter  ADDR_CONFIG_TX_REG1_2                    =  32'h0000200C;
    parameter  ADDR_CONFIG_RX_REG1_2                    =  32'h00002010;
    parameter  ADDR_TICK_REG_2                          =  32'h0000202C;
    parameter  ADDR_FEC_CONFIGURATION_REG1_2            =  32'h000020D0;
	parameter  ADDR_STAT_RX_STATUS_REG1_2               =  32'h00002744;
	parameter  ADDR_STAT_RX_RT_STATUS_REG1_2            =  32'h0000274C;	
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_LSB_2         =  32'h00002818;
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_MSB_2         =  32'h0000281C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_2    =  32'h00002820;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_2    =  32'h00002824;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_LSB_2           =  32'h00002828;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_MSB_2           =  32'h0000282C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_2      =  32'h00002830;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_2      =  32'h00002834;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_LSB_2         =  32'h00002E30;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_MSB_2         =  32'h00002E34;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_2    =  32'h00002E38;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_2    =  32'h00002E3C;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_LSB_2           =  32'h00002E40;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_MSB_2           =  32'h00002E44;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_2      =  32'h00002E48;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_2      =  32'h00002E4C;
    
    ///// For PORT-3
    parameter  ADDR_RESET_REG_3                         =  32'h00003004;
    parameter  ADDR_MODE_REG_3                          =  32'h00003008;
    parameter  ADDR_CONFIG_TX_REG1_3                    =  32'h0000300C;
    parameter  ADDR_CONFIG_RX_REG1_3                    =  32'h00003010;
    parameter  ADDR_TICK_REG_3                          =  32'h0000302C;
    parameter  ADDR_FEC_CONFIGURATION_REG1_3            =  32'h000030D0;
	parameter  ADDR_STAT_RX_STATUS_REG1_3               =  32'h00003744;
	parameter  ADDR_STAT_RX_RT_STATUS_REG1_3            =  32'h0000374C;	
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_LSB_3         =  32'h00003818;
    parameter  ADDR_STAT_TX_TOTAL_PACKETS_MSB_3         =  32'h0000381C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_3    =  32'h00003820;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_3    =  32'h00003824;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_LSB_3           =  32'h00003828;
    parameter  ADDR_STAT_TX_TOTAL_BYTES_MSB_3           =  32'h0000382C;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_3      =  32'h00003830;
    parameter  ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_3      =  32'h00003834;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_LSB_3         =  32'h00003E30;
    parameter  ADDR_STAT_RX_TOTAL_PACKETS_MSB_3         =  32'h00003E34;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_3    =  32'h00003E38;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_3    =  32'h00003E3C;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_LSB_3           =  32'h00003E40;
    parameter  ADDR_STAT_RX_TOTAL_BYTES_MSB_3           =  32'h00003E44;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_3      =  32'h00003E48;
    parameter  ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_3      =  32'h00003E4C;    
 	  
 	
 
 
 	

    reg             pl_clk;
    reg             gt_ref_clk_p;
    reg             gt_ref_clk_n;
	reg             pl_resetn;
    wire 			s_axi_arready;
    reg [31:0] 		s_axi_araddr;
    reg 			s_axi_arvalid; 
    wire 			s_axi_awready;
    reg [31:0] 		s_axi_awaddr;
    reg 			s_axi_awvalid;  
    reg 			s_axi_bready;
    wire [1:0] 		s_axi_bresp;
    wire 			s_axi_bvalid;
    reg 			s_axi_rready;
    wire [31:0] 	s_axi_rdata;
    wire [1:0] 		s_axi_rresp;
    wire 			s_axi_rvalid;
    wire 			s_axi_wready;
    reg [31:0] 		s_axi_wdata;
    reg 			s_axi_wvalid;
 
    wire [3:0]      gt_loopback_p; 
    wire [3:0]      gt_loopback_n; 
	wire [3:0]      stat_mst_reset_done;
	
	reg [2:0]      c0_top_ctl_muxes; //A value of 0 sets tdata/tkeep[0-5] = client0, tkeep[6-7] = client2 When '1', bit [0] sets tdata[2-3] = client1 ; bit [1] sets tdata[4-5] = client2 ; bit [2] sets tdata[6-7] = client3 Examples: top_ctl_axi_muxes == 0: 100g mode ; == 2: 2x50g mode ; == 7: 4x25g mode	
	reg            c0_trig_in;
	reg [2:0]      c0_number_of_segments; ////(1: 10G, 2: 25G, 4: 40/50G, 5: 100G)
	reg            c0_ten_gb_mode;
	reg [2:0]      c0_top_ctl_data_rate; //// 10G  3'b000 : 25G  3'b001 : 40G  3'b010 : 50G  3'b011 : 100G 3'b100

	reg            c1_trig_in;
	reg [2:0]      c1_number_of_segments; ////(1: 10G, 2: 25G)
	reg            c1_ten_gb_mode;
	reg [2:0]      c1_top_ctl_data_rate; //// 10G  3'b000 : 25G  3'b001 
	

	reg            c2_trig_in;
	reg [2:0]      c2_number_of_segments; ////(1: 10G, 2: 25G, 4:50G)
	reg            c2_ten_gb_mode;
	reg [2:0]      c2_top_ctl_data_rate;//// 10G  3'b000 : 25G  3'b001 : 50G  3'b011 	

	reg            c3_trig_in;
	reg [2:0]      c3_number_of_segments;////(1: 10G, 2: 25G)
	reg            c3_ten_gb_mode;
	reg [2:0]      c3_top_ctl_data_rate;//// 10G  3'b000 : 25G  3'b001 	
	
	reg  [31:0]     axi_read_data;
	reg  [63:0]    tx_total_pkt_0, tx_total_bytes_0, tx_total_good_pkts_0, tx_total_good_bytes_0; // use only lsb 48 bits
    reg  [63:0]    rx_total_pkt_0, rx_total_bytes_0, rx_total_good_pkts_0, rx_total_good_bytes_0; // use only lsb 48 bits
    reg  [63:0]    tx_total_pkt_1, tx_total_bytes_1, tx_total_good_pkts_1, tx_total_good_bytes_1; // use only lsb 48 bits
    reg  [63:0]    rx_total_pkt_1, rx_total_bytes_1, rx_total_good_pkts_1, rx_total_good_bytes_1; // use only lsb 48 bits 
    reg  [63:0]    tx_total_pkt_2, tx_total_bytes_2, tx_total_good_pkts_2, tx_total_good_bytes_2; // use only lsb 48 bits
    reg  [63:0]    rx_total_pkt_2, rx_total_bytes_2, rx_total_good_pkts_2, rx_total_good_bytes_2; // use only lsb 48 bits   
    reg  [63:0]    tx_total_pkt_3, tx_total_bytes_3, tx_total_good_pkts_3, tx_total_good_bytes_3; // use only lsb 48 bits
    reg  [63:0]    rx_total_pkt_3, rx_total_bytes_3, rx_total_good_pkts_3, rx_total_good_bytes_3; // use only lsb 48 bits  
	
    //////// GT Rate port Control.
	// Power on Default gt_line_rate = 8'b00000000;
    // 1x100GE Test     gt_line_rate = 8'b00000010;
    // 1x50GE Test      gt_line_rate = 8'b00000010;	  
    // 1x40GE Test      gt_line_rate = 8'b00000001;	  
    // 4x25GE Test      gt_line_rate = 8'b00000010;	  
    // 4x10GE Test      gt_line_rate = 8'b00000001;
    reg  [7:0]    gt_line_rate;
	reg  [3:0]    gt_reset_all_in;
mrmac_0_exdes EXDES
(
 	  
 	
 
 
 
    .s_axi_aclk(pl_clk),
    .s_axi_aresetn(pl_resetn),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arready(s_axi_arready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awready(s_axi_awready),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rready(s_axi_rready),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wready(s_axi_wready),
    .s_axi_wvalid(s_axi_wvalid),
	.c0_top_ctl_muxes      (c0_top_ctl_muxes),
	.c0_number_of_segments (c0_number_of_segments),
    .c0_ten_gb_mode        (c0_ten_gb_mode ),
    .c0_trig_in         (c0_trig_in),
    .c0_top_ctl_data_rate  (c0_top_ctl_data_rate),		
	
	.c1_number_of_segments (c1_number_of_segments),
    .c1_ten_gb_mode        (c1_ten_gb_mode ),
    .c1_trig_in         (c1_trig_in),
    .c1_top_ctl_data_rate  (c1_top_ctl_data_rate),		
	
	.c2_number_of_segments (c2_number_of_segments),
    .c2_ten_gb_mode        (c2_ten_gb_mode ),
    .c2_trig_in         (c2_trig_in),
    .c2_top_ctl_data_rate  (c2_top_ctl_data_rate),		
	
	.c3_number_of_segments (c3_number_of_segments),
    .c3_ten_gb_mode        (c3_ten_gb_mode ),
    .c3_trig_in         (c3_trig_in),
    .c3_top_ctl_data_rate  (c3_top_ctl_data_rate),		
	
    .stat_mst_reset_done   (stat_mst_reset_done),
	.gt_reset_all_in       (gt_reset_all_in),
    .gt_line_rate 		   (gt_line_rate),	
	.gt_ref_clk_p          (gt_ref_clk_p),
	.gt_ref_clk_n          (gt_ref_clk_n),
        .gt_loopback           (3'b000),
	.gt_rxn_in             (gt_loopback_n),
	.gt_rxp_in             (gt_loopback_p),
	.gt_txn_out            (gt_loopback_n),
	.gt_txp_out            (gt_loopback_p),
        .gt_reset_tx_datapath_in (4'b0000),
        .gt_reset_rx_datapath_in (4'b0000),
 	.pl_resetn             (pl_resetn),
	.pl_clk                (pl_clk)
);




    initial
    begin
	
	
     $display("################################################################- MRMAC Example Design Simulation Started - ##################################################################");
    
    `ifdef SIM_SPEED_UP
    `else
      $display("****************");
      $display("INFO : Simulation time may be longer. For faster simulation, please use SIM_SPEED_UP option. For more information refer product guide.");
      $display("****************");
    `endif

    gt_line_rate=8'h00;
		pl_resetn=1'b1;
 	  
 	
 
 
 	
	    s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
		c0_top_ctl_muxes = 3'b000;
	    c0_number_of_segments= 3'b101;
	    c0_top_ctl_data_rate=3'b100;		
        c0_trig_in= 1'b0;
	    c0_ten_gb_mode = 1'b0;
	    c1_number_of_segments= 3'b010;
	    c1_top_ctl_data_rate=3'b001;	        
        c1_trig_in= 1'b0;
	    c1_ten_gb_mode = 1'b0;
	    c2_number_of_segments= 3'b010;
	    c2_top_ctl_data_rate=3'b001;		
        c2_trig_in= 1'b0;
	    c2_ten_gb_mode = 1'b0;	
	    c3_number_of_segments= 3'b010;
	    c3_top_ctl_data_rate=3'b001;		
        c3_trig_in= 1'b0;
	    c3_ten_gb_mode = 1'b0;

		repeat (10) @(posedge pl_clk);
 		
		repeat (10) @(posedge pl_clk);
 		
        gt_reset_all_in =4'h0;		
      //  	repeat (10) @(posedge pl_clk);
      //  gt_reset_all_in =4'hF;
      //  	repeat (10) @(posedge pl_clk);	
      //  gt_reset_all_in =4'h0;
	
		@(posedge stat_mst_reset_done[0]);	
	
		repeat (400) @(posedge pl_clk);
	
		
		
		
       // 4x25G Test Start
		$display("############ 4x25G TEST STARTED");
		$display("INFO : SET GT RATE PORT");
 
	//	gt_line_rate=8'h01;
	//	@(posedge stat_mst_reset_done[0]);

		repeat (400) @(posedge pl_clk);
		$display("INFO : SYS_RESET APPLIED TO GT and MRMAC IP(AXI4-LIte)");
        pl_resetn=1'b0;
		gt_reset_all_in =4'hF;
        repeat (400) @(posedge pl_clk);
	    $display("INFO : SYS_RESET RELEASED TO GT and MRMAC IP(AXI4-LIte)");
	    pl_resetn=1'b1;
		gt_reset_all_in =4'h0;
		$display("INFO : WAITING FOR MST RESET DONE FROM GT..........");
		@(posedge |stat_mst_reset_done);
		$display("INFO : GT LOCKED..........");		
	    repeat (400) @(posedge pl_clk);
 
 
  
  	     
		
		$display("INFO : START MRMAC CONFIGURATION ..........");	
        axi_write(ADDR_RESET_REG_0, 32'h00000FFF);
		axi_write(ADDR_RESET_REG_1, 32'h00000FFF);
		axi_write(ADDR_RESET_REG_2, 32'h00000FFF);
		axi_write(ADDR_RESET_REG_3, 32'h00000FFF);
		$display("INFO : SET CORE SPEED 4x25GE ..........");
	    axi_write(ADDR_MODE_REG_0, 32'h40000261);
	 
		
        axi_write(ADDR_CONFIG_RX_REG1_0, 32'h00000033);   
		axi_write(ADDR_CONFIG_TX_REG1_0, 32'h00000C03); 
	    axi_write(ADDR_MODE_REG_1, 32'h40000261);
	  	
        axi_write(ADDR_CONFIG_RX_REG1_1, 32'h00000033);   
		axi_write(ADDR_CONFIG_TX_REG1_1, 32'h00000C03); 	
	    axi_write(ADDR_MODE_REG_2, 32'h40000261);
	   	
        axi_write(ADDR_CONFIG_RX_REG1_2, 32'h00000033);   
		axi_write(ADDR_CONFIG_TX_REG1_2, 32'h00000C03); 	
	    axi_write(ADDR_MODE_REG_3, 32'h40000261);
	 	
        axi_write(ADDR_CONFIG_RX_REG1_3, 32'h00000033);   
		axi_write(ADDR_CONFIG_TX_REG1_3, 32'h00000C03);
 
		axi_write(ADDR_FEC_CONFIGURATION_REG1_0, 32'h00000000); 
		axi_write(ADDR_FEC_CONFIGURATION_REG1_1, 32'h00000000); 
		axi_write(ADDR_FEC_CONFIGURATION_REG1_2, 32'h00000000); 
		axi_write(ADDR_FEC_CONFIGURATION_REG1_3, 32'h00000000); 
				
		axi_write(ADDR_RESET_REG_0,32'h00000000);
		axi_write(ADDR_RESET_REG_0,32'h00000000);
		axi_write(ADDR_RESET_REG_1,32'h00000000);
		axi_write(ADDR_RESET_REG_2,32'h00000000);
		axi_write(ADDR_RESET_REG_3,32'h00000000);
		axi_write(ADDR_TICK_REG_0, 32'h00000001);
		axi_write(ADDR_TICK_REG_1, 32'h00000001);	
		axi_write(ADDR_TICK_REG_2, 32'h00000001);	
		axi_write(ADDR_TICK_REG_3, 32'h00000001);		
		
		$display("INFO : WAITING FOR RX ALIGNED ..........");				
	    //////// Wait for Fixed Delay , But in actual Software need to poll for RX status bit
		`ifdef SIM_SPEED_UP
			repeat (12500) @(posedge pl_clk);
		`else
			repeat (200000) @(posedge pl_clk);
		`endif
		axi_write(ADDR_STAT_RX_STATUS_REG1_0, 32'hFFFFFFFF); 
        axi_read(ADDR_STAT_RX_STATUS_REG1_0, axi_read_data); 
        if (axi_read_data[0] ==  1'b0)
		  begin
			  $display("ERROR : RX ALIGN FAILED");
			  $display("INFO  : Test FAILED");
        $display("INFO : PORT0 RX ALIGNED FAILED..........");
		  end
       else begin		
        $display("INFO : PORT0 RX ALIGNED ..........");
            end
		repeat (10) @(posedge pl_clk);
		axi_write(ADDR_STAT_RX_STATUS_REG1_1, 32'hFFFFFFFF); 
        axi_read(ADDR_STAT_RX_STATUS_REG1_1, axi_read_data); 
        if (axi_read_data[0] ==  1'b0)
		  begin
			  $display("ERROR : RX ALIGN FAILED");
			  $display("INFO  : Test FAILED");
        $display("INFO : PORT1 RX ALIGNED FAILED..........");
		  end
       else begin				
        $display("INFO : PORT1 RX ALIGNED ..........");	
            end			
		repeat (10) @(posedge pl_clk);
		axi_write(ADDR_STAT_RX_STATUS_REG1_2, 32'hFFFFFFFF); 
        axi_read(ADDR_STAT_RX_STATUS_REG1_2, axi_read_data); 
        if (axi_read_data[0] ==  1'b0)
		  begin
			  $display("ERROR : RX ALIGN FAILED");
			  $display("INFO  : Test FAILED");
        $display("INFO : PORT2 RX ALIGNED FAILED..........");
		  end
       else begin						
        $display("INFO : PORT2 RX ALIGNED ..........");
            end			
		repeat (10) @(posedge pl_clk);
		axi_write(ADDR_STAT_RX_STATUS_REG1_3, 32'hFFFFFFFF); 
        axi_read(ADDR_STAT_RX_STATUS_REG1_3, axi_read_data); 
        if (axi_read_data[0] ==  1'b0)
		  begin
			  $display("ERROR : RX ALIGN FAILED");
			  $display("INFO  : Test FAILED");
        $display("INFO : PORT3 RX ALIGNED FAILED..........");
		  end
       else begin		
        $display("INFO : PORT3 RX ALIGNED ..........");	
            end			
		/// Data Traffic Start 
		c0_top_ctl_muxes = 3'b111;
	    c0_number_of_segments= 3'b010;
	    c0_top_ctl_data_rate=3'b001;		
        c0_trig_in= 1'b0;
	    c0_ten_gb_mode = 1'b0;
	    c1_number_of_segments= 3'b010;
	    c1_top_ctl_data_rate=3'b001;		
        c1_trig_in= 1'b0;
	    c1_ten_gb_mode = 1'b0;
	    c2_number_of_segments= 3'b010;
	    c2_top_ctl_data_rate=3'b001;		
        c2_trig_in= 1'b0;
	    c2_ten_gb_mode = 1'b0;	
	    c3_number_of_segments= 3'b010;
	    c3_top_ctl_data_rate=3'b001;		
        c3_trig_in= 1'b0;
	    c3_ten_gb_mode = 1'b0;
	
        repeat (20) @(posedge pl_clk);	
		c0_trig_in= 1'b1;
		c1_trig_in= 1'b1;
		c2_trig_in= 1'b1;
		c3_trig_in= 1'b1;
        repeat (1) @(posedge pl_clk);	
		c0_trig_in= 1'b0;
		c1_trig_in= 1'b0;
		c2_trig_in= 1'b0;
		c3_trig_in= 1'b0;		
		repeat (500) @(posedge pl_clk);
		/// Data Traffic complete		
		/// PM tick
		axi_write(ADDR_TICK_REG_0, 32'h00000001);	
        axi_write(ADDR_TICK_REG_1, 32'h00000001);
        axi_write(ADDR_TICK_REG_2, 32'h00000001);
        axi_write(ADDR_TICK_REG_3, 32'h00000001);	
		repeat (10) @(posedge pl_clk);
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_LSB_0, tx_total_pkt_0[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_MSB_0, tx_total_pkt_0[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_0, tx_total_good_pkts_0[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_0, tx_total_good_pkts_0[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_LSB_0, tx_total_bytes_0[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_MSB_0, tx_total_bytes_0[63:32]);		
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_0, tx_total_good_bytes_0[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_0, tx_total_good_bytes_0[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_LSB_0, rx_total_pkt_0[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_MSB_0, rx_total_pkt_0[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_0, rx_total_good_pkts_0[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_0, rx_total_good_pkts_0[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_LSB_0, rx_total_bytes_0[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_MSB_0, rx_total_bytes_0[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_0, rx_total_good_bytes_0[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_0, rx_total_good_bytes_0[63:32]);	
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_LSB_1, tx_total_pkt_1[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_MSB_1, tx_total_pkt_1[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_1, tx_total_good_pkts_1[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_1, tx_total_good_pkts_1[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_LSB_1, tx_total_bytes_1[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_MSB_1, tx_total_bytes_1[63:32]);		
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_1, tx_total_good_bytes_1[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_1, tx_total_good_bytes_1[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_LSB_1, rx_total_pkt_1[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_MSB_1, rx_total_pkt_1[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_1, rx_total_good_pkts_1[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_1, rx_total_good_pkts_1[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_LSB_1, rx_total_bytes_1[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_MSB_1, rx_total_bytes_1[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_1, rx_total_good_bytes_1[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_1, rx_total_good_bytes_1[63:32]);	
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_LSB_2, tx_total_pkt_2[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_MSB_2, tx_total_pkt_2[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_2, tx_total_good_pkts_2[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_2, tx_total_good_pkts_2[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_LSB_2, tx_total_bytes_2[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_MSB_2, tx_total_bytes_2[63:32]);		
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_2, tx_total_good_bytes_2[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_2, tx_total_good_bytes_2[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_LSB_2, rx_total_pkt_2[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_MSB_2, rx_total_pkt_2[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_2, rx_total_good_pkts_2[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_2, rx_total_good_pkts_2[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_LSB_2, rx_total_bytes_2[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_MSB_2, rx_total_bytes_2[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_2, rx_total_good_bytes_2[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_2, rx_total_good_bytes_2[63:32]);	
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_LSB_3, tx_total_pkt_3[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_PACKETS_MSB_3, tx_total_pkt_3[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_LSB_3, tx_total_good_pkts_3[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_PACKETS_MSB_3, tx_total_good_pkts_3[63:32]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_LSB_3, tx_total_bytes_3[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_BYTES_MSB_3, tx_total_bytes_3[63:32]);		
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_LSB_3, tx_total_good_bytes_3[31:0]);
		axi_read(ADDR_STAT_TX_TOTAL_GOOD_BYTES_MSB_3, tx_total_good_bytes_3[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_LSB_3, rx_total_pkt_3[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_PACKETS_MSB_3, rx_total_pkt_3[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_LSB_3, rx_total_good_pkts_3[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_PACKETS_MSB_3, rx_total_good_pkts_3[63:32]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_LSB_3, rx_total_bytes_3[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_BYTES_MSB_3, rx_total_bytes_3[63:32]);		
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_LSB_3, rx_total_good_bytes_3[31:0]);
		axi_read(ADDR_STAT_RX_TOTAL_GOOD_BYTES_MSB_3, rx_total_good_bytes_3[63:32]);	
		
        $display( "  " );
        $display( "          PORT - 0 Statistics           " );
        $display( "               STAT_TX_TOTAL_PACKETS           = %d,     STAT_RX_TOTAL_PACKETS           = %d", tx_total_pkt_0, rx_total_pkt_0 );
        $display( "               STAT_TX_TOTAL_GOOD_PACKETS      = %d,     STAT_RX_TOTAL_GOOD_PACKETS      = %d", tx_total_good_pkts_0, rx_total_good_pkts_0 );
        $display( "               STAT_TX_TOTAL_BYTES             = %d,     STAT_RX_TOTAL_BYTES             = %d", tx_total_bytes_0, rx_total_bytes_0 );
        $display( "               STAT_TX_TOTAL_GOOD_BYTES        = %d,     STAT_RX_TOTAL_GOOD_BYTES        = %d", tx_total_good_bytes_0, rx_total_good_bytes_0 );
        $display( "  " );
        $display( "  " );
        $display( "          PORT - 1 Statistics           " );
        $display( "               STAT_TX_TOTAL_PACKETS           = %d,     STAT_RX_TOTAL_PACKETS           = %d", tx_total_pkt_1, rx_total_pkt_1 );
        $display( "               STAT_TX_TOTAL_GOOD_PACKETS      = %d,     STAT_RX_TOTAL_GOOD_PACKETS      = %d", tx_total_good_pkts_1, rx_total_good_pkts_1 );
        $display( "               STAT_TX_TOTAL_BYTES             = %d,     STAT_RX_TOTAL_BYTES             = %d", tx_total_bytes_1, rx_total_bytes_1 );
        $display( "               STAT_TX_TOTAL_GOOD_BYTES        = %d,     STAT_RX_TOTAL_GOOD_BYTES        = %d", tx_total_good_bytes_1, rx_total_good_bytes_1 );      
        $display( "  " );
        $display( "          PORT - 2 Statistics           " );
        $display( "               STAT_TX_TOTAL_PACKETS           = %d,     STAT_RX_TOTAL_PACKETS           = %d", tx_total_pkt_2, rx_total_pkt_2 );
        $display( "               STAT_TX_TOTAL_GOOD_PACKETS      = %d,     STAT_RX_TOTAL_GOOD_PACKETS      = %d", tx_total_good_pkts_2, rx_total_good_pkts_2 );
        $display( "               STAT_TX_TOTAL_BYTES             = %d,     STAT_RX_TOTAL_BYTES             = %d", tx_total_bytes_2, rx_total_bytes_2 );
        $display( "               STAT_TX_TOTAL_GOOD_BYTES        = %d,     STAT_RX_TOTAL_GOOD_BYTES        = %d", tx_total_good_bytes_2, rx_total_good_bytes_2 ); 
        $display( "  " );
        $display( "          PORT - 3 Statistics           " );
        $display( "               STAT_TX_TOTAL_PACKETS           = %d,     STAT_RX_TOTAL_PACKETS           = %d", tx_total_pkt_3, rx_total_pkt_3 );
        $display( "               STAT_TX_TOTAL_GOOD_PACKETS      = %d,     STAT_RX_TOTAL_GOOD_PACKETS      = %d", tx_total_good_pkts_3, rx_total_good_pkts_3 );
        $display( "               STAT_TX_TOTAL_BYTES             = %d,     STAT_RX_TOTAL_BYTES             = %d", tx_total_bytes_3, rx_total_bytes_3 );
        $display( "               STAT_TX_TOTAL_GOOD_BYTES        = %d,     STAT_RX_TOTAL_GOOD_BYTES        = %d", tx_total_good_bytes_3, rx_total_good_bytes_3 );   
        $display( "  " );	
		if  (((tx_total_pkt_0[47:0] == rx_total_pkt_0[47:0]) && (tx_total_good_pkts_0[47:0]  == rx_total_good_pkts_0[47:0] ) && (tx_total_bytes_0[47:0]  == rx_total_bytes_0[47:0] ) && (tx_total_good_bytes_0[47:0]  == rx_total_good_bytes_0[47:0] ))&&((tx_total_pkt_1[47:0] == rx_total_pkt_1[47:0]) && (tx_total_good_pkts_1[47:0]  == rx_total_good_pkts_1[47:0] ) && (tx_total_bytes_1[47:0]  == rx_total_bytes_1[47:0] ) && (tx_total_good_bytes_1[47:0]  == rx_total_good_bytes_1[47:0] ))&&((tx_total_pkt_2[47:0] == rx_total_pkt_2[47:0]) && (tx_total_good_pkts_2[47:0]  == rx_total_good_pkts_2[47:0] ) && (tx_total_bytes_2[47:0]  == rx_total_bytes_2[47:0] ) && (tx_total_good_bytes_2[47:0]  == rx_total_good_bytes_2[47:0] ))&&((tx_total_pkt_3[47:0] == rx_total_pkt_3[47:0]) && (tx_total_good_pkts_3[47:0]  == rx_total_good_pkts_3[47:0] ) && (tx_total_bytes_3[47:0]  == rx_total_bytes_3[47:0] ) && (tx_total_good_bytes_3[47:0]  == rx_total_good_bytes_3[47:0] )))
		 begin
				$display("INFO : Counters matched in Loopback Mode");
				$display("INFO  : Test PASS");
		 end
		 else
		 begin
				$display("ERROR : Counters not matched in Loopback Mode");
				$display("INFO  : Test FAILED");
				$finish;
		 end
	    repeat (100) @(posedge pl_clk);
		$display("############ 4x25G TEST COMPLETE...");

	
		
           $display("INFO : Test Completed Successfully");
     $display("################################################################- MRMAC Example Design Simulation Finished- ##################################################################");     
     $finish;
    end
 

    initial
    begin
        gt_ref_clk_p =1;
        forever #3200.000   gt_ref_clk_p = ~ gt_ref_clk_p;
    end

    initial
    begin
        gt_ref_clk_n =0;
        forever #3200.000   gt_ref_clk_n = ~ gt_ref_clk_n;
    end

    initial
    begin
        pl_clk =1;
        forever #5000.00 pl_clk = ~pl_clk;
    end
	task axi_write;
        input [31:0] awaddr;
        input [31:0] wdata; 
        begin
            // *** Write address ***
            s_axi_awaddr = awaddr;
			s_axi_wdata = wdata;
            s_axi_awvalid = 1;
			s_axi_wvalid = 1;
			@(posedge s_axi_wready); 
            #pclk_cycle;
			#pclk_cycle;
			s_axi_awvalid = 0;
            s_axi_wvalid = 0;
            s_axi_awaddr = 0;
			s_axi_wdata = 0;			
			@(posedge s_axi_bvalid);
            if (s_axi_bresp !=2'b00)
			begin
				$display("############ AXI4 write error ...");
		    end 
			#pclk_cycle;
            s_axi_bready = 1'b1;
			#pclk_cycle;
			s_axi_bready = 1'b0;
			#pclk_cycle;
        end
    endtask
    
    task axi_read;
        input [31:0] araddr;
		output [31:0] read_data;
        begin
            // *** Write address ***
            s_axi_araddr = araddr;
            s_axi_arvalid = 1;
			@(posedge s_axi_arready);
		    #pclk_cycle;
			#pclk_cycle;
            s_axi_arvalid = 0;
			
			@(posedge s_axi_rvalid);	
            if (s_axi_rresp !=2'b00)
			begin
				$display("############ AXI4 read error ...");
		    end			
            read_data =  s_axi_rdata; 	
			#pclk_cycle;
            s_axi_rready = 1'b1;
			#pclk_cycle;
			s_axi_rready = 1'b0;	
			#pclk_cycle;
        end
    endtask

 	
 	
 	
 		

endmodule


