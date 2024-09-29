###--------------------------------------------------------------------------------
###  (c) Copyright 2013 Advanced Micro Devices, Inc. All rights reserved.
###
###  This file contains confidential and proprietary information
###  of Advanced Micro Devices, Inc. and is protected under U.S. and
###  international copyright and other intellectual property
###  laws.
###
###  DISCLAIMER
###  This disclaimer is not a license and does not grant any
###  rights to the materials distributed herewith. Except as
###  otherwise provided in a valid license issued to you by
###  AMD, and to the maximum extent permitted by applicable
###  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
###  WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
###  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
###  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
###  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
###  (2) AMD shall not be liable (whether in contract or tort,
###  including negligence, or under any other theory of
###  liability) for any loss or damage of any kind or nature
###  related to, arising under or in connection with these
###  materials, including for any direct, or any indirect,
###  special, incidental, or consequential loss or damage
###  (including loss of data, profits, goodwill, or any type of
###  loss or damage suffered as a result of any action brought
###  by a third party) even if such damage or loss was
###  reasonably foreseeable or AMD had been advised of the
###  possibility of the same.
###
###  CRITICAL APPLICATIONS
###  AMD products are not designed or intended to be fail-
###  safe, or for use in any application requiring fail-safe
###  performance, such as life-support or safety devices or
###  systems, Class III medical devices, nuclear facilities,
###  applications related to the deployment of airbags, or any
###  other applications that could lead to death, personal
###  injury, or severe property or environmental damage
###  (individually and collectively, "Critical
###  Applications"). Customer assumes the sole risk and
###  liability of any use of AMD products in Critical
###  Applications, subject only to applicable laws and
###  regulations governing limitations on product liability.
###
###  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
###  PART OF THIS FILE AT ALL TIMES.
###--------------------------------------------------------------------------------

### -----------------------------------------------------------------------------
### MRMAC example design-level XDC file
### -----------------------------------------------------------------------------
## User can update the GT_QUAD location based on the MRMAC hard IP location with appropriate GT mapping to avoid implementation failures
## MRMAC hard IP LOC constraint is available in core xdc
## The design must meet the following rules when connecting the Versal MRMAC Hard IP core to the transceivers. 
##-	GTs have to be contiguous.
##-	For MRMAC operating in wide SerDes mode (CTL_SERDES_WIDTH_[0..3]<2> == 1), the MRMAC and connected GTME5_QUAD instance should be placed within the same horizontal Clock Region.
##-	For MRMAC operating in narrow SerDes mode (CTL_SERDES_WIDTH_[0..3]<2> == 0), the MRMAC and connected GTME5_QUAD instance should be placed either within the same horizontal Clock Region, or one horizontal Clock Regions above or below the MRMAC instance.
###--GT Location Constraints - These are default constraints , user need to update as per requirement---
set_property LOC GTY_QUAD_X1Y0 [get_cells -hier -filter {name =~ */gt_quad_base*/inst/quad_inst}]
set_property LOC GTY_REFCLK_X9Y1 [get_cells -hier -filter {name =~ */USE_IBUFDS_GTE5.GEN_IBUFDS_GTE5[0].IBUFDS_GTE5_I}]

###----
create_clock -period 6.400 -name gt_ref_clk_p -waveform {0.000 3.200} [get_ports gt_ref_clk_p]


############# Sample Location Contraints - Please uncomment as per your requirement ######
## User can update the GT_QUAD location based on the MRMAC hard IP location with appropriate GT mapping to avoid implementation failures

## Sample GTM constriants for VPK120 Board xcvp1202-vsva2785-2MP-e-S-es1
#set_property LOC GTM_QUAD_X0Y4      [get_cells -hier -filter {name =~ */gt_quad_base*/inst/quad_inst}]
#set_property LOC GTM_REFCLK_X0Y8    [get_cells -hier -filter {name =~ */util_ds_buf*/U0/USE_IBUFDS_GTME5.GEN_IBUFDS_GTME5[0].IBUFDS_GTME5_U}]
##### GTM Bank 206
#set_property PACKAGE_PIN V45 [get_ports gt_ref_clk_p]
#set_property PACKAGE_PIN AC52 [get_ports {gt_rxp_in[0]}]
#set_property LOC GTY_REFCLK_X1Y9 [get_cells -hier -filter {name =~ */util_ds_buf*/U0/USE_IBUFDS_GTE5.GEN_IBUFDS_GTE5[0].IBUFDS_GTE5_I}]
#set_property LOC GTY_QUAD_X1Y4 [get_cells -hier -filter {name =~ */gt_quad_base*/inst/quad_inst}]
###### Below is the constraints for VCK190/VMK180 Board(xcvc1902-vsva2197-2MP-e-S-es1) example design MRMAC_X0Y0-GTY Bank 200 . Comment the above two lines then Uncomment below to use.
##### GTY Bank 200
set_property PACKAGE_PIN AF2 [get_ports {gt_rxp_in[0]}]
set_property PACKAGE_PIN AF1 [get_ports {gt_rxn_in[0]}]
set_property PACKAGE_PIN AF7 [get_ports {gt_txp_out[0]}]
set_property PACKAGE_PIN AF6 [get_ports {gt_txn_out[0]}]
set_property PACKAGE_PIN AE4 [get_ports {gt_rxp_in[1]}]
set_property PACKAGE_PIN AE3 [get_ports {gt_rxn_in[1]}]
set_property PACKAGE_PIN AE9 [get_ports {gt_txp_out[1]}]
set_property PACKAGE_PIN AE8 [get_ports {gt_txn_out[1]}]
set_property PACKAGE_PIN AD2 [get_ports {gt_rxp_in[2]}]
set_property PACKAGE_PIN AD1 [get_ports {gt_rxn_in[2]}]
set_property PACKAGE_PIN AD7 [get_ports {gt_txp_out[2]}]
set_property PACKAGE_PIN AD6 [get_ports {gt_txn_out[2]}]
set_property PACKAGE_PIN AC4 [get_ports {gt_rxp_in[3]}]
set_property PACKAGE_PIN AC3 [get_ports {gt_rxn_in[3]}]
set_property PACKAGE_PIN AC9 [get_ports {gt_txp_out[3]}]
set_property PACKAGE_PIN AC8 [get_ports {gt_txn_out[3]}]
# GTREFCLK 0 Configured as Output (Recovered Clock) which connects to 8A34001 CLK1_IN
# GTREFCLK 1 ( Driven by 8A34001 Q1 )
set_property PACKAGE_PIN AD11 [get_ports {gt_ref_clk_p}]
set_property PACKAGE_PIN AD10 [get_ports {gt_ref_clk_n}]

###### Below is the constraints for xcvc1902-viva1596-2LP-e-S-es1  example design MRMAC_X0Y0-GTY Bank 202 . Comment the above two lines then Uncomment below to use.
##### GTY Bank 202
##set_property IOSTANDARD LVDS15 [get_ports {gt_rxp_in[3]}]
##set_property IOSTANDARD LVDS15 [get_ports {gt_rxp_in[2]}]
##set_property IOSTANDARD LVDS15 [get_ports {gt_rxp_in[1]}]
##set_property IOSTANDARD LVDS15 [get_ports {gt_rxp_in[0]}]
##set_property PACKAGE_PIN AA2 [get_ports {gt_rxp_in[3]}]
##set_property IOSTANDARD LVDS15 [get_ports gt_ref_clk_p]
##set_property PACKAGE_PIN AD9 [get_ports gt_ref_clk_p]


set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */gt_quad_base/inst/quad_inst/CH0_TXOUTCLK}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */i_*_axis_clk_wiz_*/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0}]] 2.8
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */i_*_axis_clk_wiz_*/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */gt_quad_base/inst/quad_inst/CH0_TXOUTCLK}]] 2.8
set_max_delay -datapath_only -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */mbufg_gt_*/U0/USE_MBUFG_GT*.GEN_MBUFG_GT*.MBUFG_GT_U/O*}]] 2.8
set_max_delay -datapath_only -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *_axis_clk_wiz_*/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0}]] 2.8






#### TX0
### ###set_property CLOCK_DELAY_GROUP SERDES_TX0 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/MBUFG_GT_O1*}]]
### ###set_property CLOCK_DELAY_GROUP SERDES_TX0 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/MBUFG_GT_O2*}]]
#### TX2
### ###set_property CLOCK_DELAY_GROUP SERDES_TX2 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/MBUFG_GT_O1*}]]
### ###set_property CLOCK_DELAY_GROUP SERDES_TX2 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/MBUFG_GT_O2*}]]
#### RX0
### ###set_property CLOCK_DELAY_GROUP SERDES_RX0 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1/MBUFG_GT_O1*}]]
### ###set_property CLOCK_DELAY_GROUP SERDES_RX0 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1/MBUFG_GT_O2*}]]
#### RX1
### ###set_property CLOCK_DELAY_GROUP SERDES_RX1 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_1/MBUFG_GT_O1*}]]
### ###set_property CLOCK_DELAY_GROUP SERDES_RX1 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_1/MBUFG_GT_O2*}]]
#### RX2
### ###set_property CLOCK_DELAY_GROUP SERDES_RX2 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_2/MBUFG_GT_O1*}]]
### ###set_property CLOCK_DELAY_GROUP SERDES_RX2 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_2/MBUFG_GT_O2*}]]
#### RX3
### ###set_property CLOCK_DELAY_GROUP SERDES_RX3 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_3/MBUFG_GT_O1*}]]
### ###set_property CLOCK_DELAY_GROUP SERDES_RX3 [get_nets [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_3/MBUFG_GT_O2*}]]

set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */quad_inst/CH0_TXOUTCLK}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] 2.56
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/MBUFG_GT_O2*}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] 2.56
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */quad_inst/CH2_TXOUTCLK}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] 2.56

set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/MBUFG_GT_O2*}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] 2.56
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/MBUFG_GT_O2*}]] 2.56

set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */quad_inst/CH0_TXOUTCLK}]] 2.56
set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/MBUFG_GT_O2*}]] 2.56

set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */quad_inst/CH2_TXOUTCLK}]] 2.56




set_max_delay -datapath_only -from [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */MMCME5_inst/CLKOUT0}]] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ */mbufg_gt_*/U0/USE_MBUFG_GT*.GEN_MBUFG_GT[0].MBUFG_GT_U/O1*}]] 1.552






set_clock_groups -name pl0_ref_clk_0 -asynchronous -group [get_clocks -of_objects [get_pins i_mrmac_0_cips_wrapper/mrmac_0_cips_i/pl0_ref_clk_0]]

create_waiver -quiet -type CDC -id {CDC-13} -user "mrmac" -desc "The CDC-13 warning is waived, this is a level signal and this is safe to ignore" -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter { name =~ *_cips_wrapper/*_cips_i/axi_gpio_gt_prbs_comm_ctl/*/gpio_core_*/Dual.gpio_Data_Out_reg*}] -filter { name =~ *C } ]\
-to [get_pins -hier -filter {name =~ */*_gt_wrapper/gt_quad_base/inst/quad_inst/CH*_RXRATE*}]  

create_waiver -quiet -type CDC -id {CDC-13} -user "mrmac" -desc "The CDC-13 warning is waived, this is a level signal and this is safe to ignore" -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter { name =~ *_cips_wrapper/*_cips_i/axi_gpio_gt_prbs_comm_ctl/*/gpio_core_*/Dual.gpio_Data_Out_reg*}] -filter { name =~ *C } ]\
-to [get_pins -hier -filter {name =~ */*_gt_wrapper/gt_quad_base/inst/quad_inst/CH*_TXRATE*}]  

create_waiver -quiet -type CDC -id {CDC-1} -user "mrmac" -desc "This register drives multiple destination path and all are registered on the destination clocks " -tags "1101959"\
-from [get_pins -hier -filter { name =~ */*_exdes_support_i/*_core/inst/*_top/*/TX_CORE_CLK*}]\
-to [list [get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tdata_buff*_reg*}] -filter { name =~ *CE } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tkeep_buff*_reg*}] -filter { name =~ *CE } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tlast_buff*_reg*}] -filter { name =~ *CE } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tlast_buff*_reg*}] -filter { name =~ *D } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tvalid_buff*_reg*}] -filter { name =~ *D } ]]

create_waiver -quiet -type CDC -id {CDC-1} -user "mrmac" -desc "This register drives multiple destination path and all are registered on the destination clocks " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter { name =~ *_cips_wrapper/*_cips_i/*/gpio_core_*/*_Data_Out_reg*}] -filter { name =~ *C } ]\
-to [list [get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tdata_buff*_reg*}] -filter { name =~ *CE } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tdata_buff*_reg*}] -filter { name =~ *D } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tkeep_buff*_reg*}] -filter { name =~ *CE } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tkeep_buff*_reg*}] -filter { name =~ *D } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tlast_buff*_reg*}] -filter { name =~ *CE } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tlast_buff*_reg*}] -filter { name =~ *R } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tlast_buff*_reg*}] -filter { name =~ *D } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tvalid_buff*_reg*}] -filter { name =~ *D } ]]

create_waiver -quiet -type CDC -id {CDC-1} -user "mrmac" -desc "This register drives multiple destination path and all are registered on the destination clocks" -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter { name =~ *_cips_wrapper/*_cips_i/proc_sys_reset_*/*/ACTIVE_LOW_PR_OUT_DFF*.FDRE_PER_*}] -filter { name =~ *C } ]\
-to [list [get_pins -of [get_cells -hier -filter {name =~ *_exdes/CLIENT*_FSM_r_reg*}] -filter { name =~ *S } ]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/CLIENT*_FSM_r_reg*}] -filter { name =~ *R }]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/client*_prbs_reg*}] -filter { name =~ *R }]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.*_buff*_reg*}] -filter {name =~ *R}]\
[get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.*_buff*_reg*}] -filter {name =~ *D}]]

create_waiver  -quiet -type CDC -id {CDC-10} -user "mrmac" -desc "This is a level signal and safe to ignore " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter {name =~ *_cips_wrapper/*_cips_i/axi_gpio_prbs_ctl/*/gpio_core_*/Dual.gpio*_Data_Out_reg*}] -filter { name =~ *C } ]\
-to [get_pins -hier -filter {name =~ */*_pkt_gen_mon_*/*_pkt_gen_*/DUPLEX_PKT_SIZE_*_reg*/CLR}]

create_waiver -quiet -type CDC -id {CDC-13} -user "mrmac" -desc "The CDC-13 is safe to ignore " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tlast_buff_reg*}] -filter { name =~ *C } ]\
-to [get_pins -hier -filter { name =~ */*_support_wrapper/*_exdes_support_i/*_core/*/*_core_0_top/*/TX_AXIS_TLAST_*}]

create_waiver -quiet -type CDC -id {CDC-13} -user "mrmac" -desc "The CDC-13 is safe to ignore " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*.tvalid_buff_reg*}] -filter { name =~ *C } ]\
-to [get_pins -hier -filter { name =~ */*_support_wrapper/*_exdes_support_i/*_core/*/*_core_0_top/*/TX_AXIS_TVALID_*}]

create_waiver -quiet -type CDC -id {CDC-11} -user "mrmac" -desc "This is a level signal and safe to ignore " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter {name =~ *_cips_wrapper/*_cips_i/*/gpio_core_*/Dual.gpio*_Data_Out_reg*}]  -filter { name =~ *C } ]\
-to [get_pins -hier -filter { name =~ *_exdes/*_pkt_gen_mon_*/*_pkt_gen_*/DUPLEX_PKT_SIZE_*_reg*/CLR}]

create_waiver -quiet -type CDC -id {CDC-7} -user "mrmac" -desc "This is a level signal and safe to ignore " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter {name =~ *_cips_wrapper/*_cips_i/*/gpio_core_*/Dual.gpio*_Data_Out_reg*}]  -filter { name =~ *C } ]\
-to [get_pins  -hier -filter { name =~ *_exdes/*_pkt_gen_mon_*/*_pkt_gen_*/*_reg*/CLR}] 

 create_waiver -quiet -type CDC -id {CDC-7} -user "mrmac" -desc "This is a level signal and safe to ignore " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter  {name =~ *_cips_wrapper/*_cips_i/proc_sys_reset_*/*/ACTIVE_LOW_PR_OUT_DFF*.FDRE_PER_*}]  -filter { name =~ *C } ]\
-to [get_pins  -hier -filter { name =~ *_exdes/*_trig_in_edge_detect_reg/CLR}] 

create_waiver -quiet -type CDC -id {CDC-14} -user "mrmac" -desc "The CDC-14 is safe to ignore" -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter  {name =~ *_exdes/*_axis_stream_mux/axis_2stg_buff*_buff*_reg* }]  -filter { name =~ *C } ]\
-to [get_pins -hier -filter {name =~ *_exdes/*_exdes_support_wrapper/*/*_core/*/*_top/*/TX_AXIS_*}] 


 create_waiver -quiet -type CDC -id {CDC-7} -user "mrmac" -desc "This is a level signal and safe to ignore " -tags "1101959"\
-from [get_pins -of [get_cells -hier -filter  {name =~ *_cips_wrapper/*_cips_i/*/gpio_core_*/Dual.gpio*_Data_Out_reg*}]  -filter { name =~ *C } ]\
-to [get_pins  -hier -filter { name =~ *_exdes/*_pkt_gen_mon_*/*_pkt_gen_*/*_reg*/PRE}]
 

create_waiver -quiet -type DRC -id {REQP-2057} -user "mrmac" -desc "REQP-2057 is waived as the MBUFG_GT CLR and CLRBLEAF pins are connected with the GT Reset IP" -tags "1138767" -objects [get_cells -hier -filter {REF_NAME==MBUFG_GT && NAME=~ */*_exdes_support*/*gt_wrapper*/*}]




		
###################  .XDC to disable extra timing arc for following configuration with respect to example design.



######### 10GE OR 25GE

### Wide
##### TX CH0
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
##### TX CH1
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
##### TX CH2
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
##### TX CH3
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_0_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]

##### RX CH0
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
##### RX CH1
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
##### RX CH2
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
##### RX CH3
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O1}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_false_path -from [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_2/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]] -to [get_clocks -of_objects [get_pins -hier -filter { name =~ */*_exdes_support_wrapper/*_exdes_support_i/*_gt_wrapper/mbufg_gt_1_3/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
### Narrow
##### TX CH0
##### TX CH1
##### TX CH2
##### TX CH3



