/******************************************************************************
*
* Copyright (C) 2018 - 2020 Advanced Micro Devices, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a AMD device, or
* (b) that interact with a AMD device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* AMD  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the AMD shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from AMD.
*
******************************************************************************/

#include <stdio.h>
#include <xil_printf.h>
#include <xparameters.h>
#include "xil_exception.h"
#include "xstatus.h"
#include "xil_types.h"
#include "xgpio.h"
#include "sleep.h"
#define MRMAC_0_BASEADDR                 	0xA4090000
#define MRMAC_0_GENMON_CTL_BASEADDR      	XPAR_AXI_GPIO_PRBS_CTL_BASEADDR
#define MRMAC_0_COMMON_CTL_STAT_BASEADDR 	XPAR_AXI_GPIO_GT_PRBS_COMM_CTL_BASEADDR
#define MRMAC_0_GPIO_DEBUG_BASEADDR 		XPAR_AXI_GPIO_DEBUG_BASEADDR
/* Contents from Header file*/
#define CONFIGURATION_REVISION_REG_OFFSET 		0x00000000
//// Port 0
#define RESET_REG_0_OFFSET 				0x00000004
#define MODE_REG_0_OFFSET 				0x00000008
#define CONFIGURATION_TX_REG1_0_OFFSET 			0x0000000C
#define CONFIGURATION_RX_REG1_0_OFFSET 			0x00000010
#define TICK_REG_0_OFFSET 				0x0000002C
#define FEC_CONFIGURATION_REG1_0_OFFSET 		0x000000D0
#define STAT_RX_STATUS_REG1_0_OFFSET 			0x00000744
#define STAT_RX_RT_STATUS_REG1_0_OFFSET 		0x0000074C
#define STAT_STATISTICS_READY_0_OFFSET 			0x000007D8
#define STAT_TX_TOTAL_PACKETS_0_LSB_OFFSET 		0x00000818
#define STAT_TX_TOTAL_PACKETS_0_MSB_OFFSET 		0x0000081C
#define STAT_TX_TOTAL_GOOD_PACKETS_0_LSB_OFFSET 	0x00000820
#define STAT_TX_TOTAL_GOOD_PACKETS_0_MSB_OFFSET 	0x00000824
#define STAT_TX_TOTAL_BYTES_0_LSB_OFFSET 		0x00000828
#define STAT_TX_TOTAL_BYTES_0_MSB_OFFSET 		0x0000082C
#define STAT_TX_TOTAL_GOOD_BYTES_0_LSB_OFFSET 		0x00000830
#define STAT_TX_TOTAL_GOOD_BYTES_0_MSB_OFFSET 		0x00000834
#define STAT_RX_TOTAL_PACKETS_0_LSB_OFFSET 		0x00000E30
#define STAT_RX_TOTAL_PACKETS_0_MSB_OFFSET 		0x00000E34
#define STAT_RX_TOTAL_GOOD_PACKETS_0_LSB_OFFSET 	0x00000E38
#define STAT_RX_TOTAL_GOOD_PACKETS_0_MSB_OFFSET 	0x00000E3C
#define STAT_RX_TOTAL_BYTES_0_LSB_OFFSET 		0x00000E40
#define STAT_RX_TOTAL_BYTES_0_MSB_OFFSET 		0x00000E44
#define STAT_RX_TOTAL_GOOD_BYTES_0_LSB_OFFSET 		0x00000E48
#define STAT_RX_TOTAL_GOOD_BYTES_0_MSB_OFFSET 		0x00000E4C
//// Port 1
#define RESET_REG_1_OFFSET 				0x00001004
#define MODE_REG_1_OFFSET 				0x00001008
#define CONFIGURATION_TX_REG1_1_OFFSET 			0x0000100C
#define CONFIGURATION_RX_REG1_1_OFFSET 			0x00001010
#define TICK_REG_1_OFFSET 				0x0000102C
#define FEC_CONFIGURATION_REG1_1_OFFSET 		0x000010D0
#define STAT_RX_STATUS_REG1_1_OFFSET 			0x00001744
#define STAT_RX_RT_STATUS_REG1_1_OFFSET 		0x0000174C
#define STAT_STATISTICS_READY_1_OFFSET 			0x000017D8
#define STAT_TX_TOTAL_PACKETS_1_LSB_OFFSET 		0x00001818
#define STAT_TX_TOTAL_PACKETS_1_MSB_OFFSET 		0x0000181C
#define STAT_TX_TOTAL_GOOD_PACKETS_1_LSB_OFFSET         0x00001820
#define STAT_TX_TOTAL_GOOD_PACKETS_1_MSB_OFFSET         0x00001824
#define STAT_TX_TOTAL_BYTES_1_LSB_OFFSET 		0x00001828
#define STAT_TX_TOTAL_BYTES_1_MSB_OFFSET 		0x0000182C
#define STAT_TX_TOTAL_GOOD_BYTES_1_LSB_OFFSET 	        0x00001830
#define STAT_TX_TOTAL_GOOD_BYTES_1_MSB_OFFSET 	        0x00001834
#define STAT_RX_TOTAL_PACKETS_1_LSB_OFFSET 	        0x00001E30
#define STAT_RX_TOTAL_PACKETS_1_MSB_OFFSET 	        0x00001E34
#define STAT_RX_TOTAL_GOOD_PACKETS_1_LSB_OFFSET         0x00001E38
#define STAT_RX_TOTAL_GOOD_PACKETS_1_MSB_OFFSET         0x00001E3C
#define STAT_RX_TOTAL_BYTES_1_LSB_OFFSET 	        0x00001E40
#define STAT_RX_TOTAL_BYTES_1_MSB_OFFSET 	        0x00001E44
#define STAT_RX_TOTAL_GOOD_BYTES_1_LSB_OFFSET 	        0x00001E48
#define STAT_RX_TOTAL_GOOD_BYTES_1_MSB_OFFSET 	        0x00001E4C
//// Port 2
#define RESET_REG_2_OFFSET 				0x00002004
#define MODE_REG_2_OFFSET 				0x00002008
#define CONFIGURATION_TX_REG1_2_OFFSET 			0x0000200C
#define CONFIGURATION_RX_REG1_2_OFFSET 			0x00002010
#define TICK_REG_2_OFFSET 				0x0000202C
#define FEC_CONFIGURATION_REG1_2_OFFSET 		0x000020D0
#define STAT_RX_STATUS_REG1_2_OFFSET 			0x00002744
#define STAT_RX_RT_STATUS_REG1_2_OFFSET 		0x0000274C
#define STAT_STATISTICS_READY_2_OFFSET 			0x000027D8
#define STAT_TX_TOTAL_PACKETS_2_LSB_OFFSET 		0x00002818
#define STAT_TX_TOTAL_PACKETS_2_MSB_OFFSET 		0x0000281C
#define STAT_TX_TOTAL_GOOD_PACKETS_2_LSB_OFFSET         0x00002820
#define STAT_TX_TOTAL_GOOD_PACKETS_2_MSB_OFFSET 	0x00002824
#define STAT_TX_TOTAL_BYTES_2_LSB_OFFSET 		0x00002828
#define STAT_TX_TOTAL_BYTES_2_MSB_OFFSET 		0x0000282C
#define STAT_TX_TOTAL_GOOD_BYTES_2_LSB_OFFSET 		0x00002830
#define STAT_TX_TOTAL_GOOD_BYTES_2_MSB_OFFSET 		0x00002834
#define STAT_RX_TOTAL_PACKETS_2_LSB_OFFSET 		0x00002E30
#define STAT_RX_TOTAL_PACKETS_2_MSB_OFFSET 		0x00002E34
#define STAT_RX_TOTAL_GOOD_PACKETS_2_LSB_OFFSET 	0x00002E38
#define STAT_RX_TOTAL_GOOD_PACKETS_2_MSB_OFFSET 	0x00002E3C
#define STAT_RX_TOTAL_BYTES_2_LSB_OFFSET 		0x00002E40
#define STAT_RX_TOTAL_BYTES_2_MSB_OFFSET 		0x00002E44
#define STAT_RX_TOTAL_GOOD_BYTES_2_LSB_OFFSET 		0x00002E48
#define STAT_RX_TOTAL_GOOD_BYTES_2_MSB_OFFSET 		0x00002E4C
//// Port 3
#define RESET_REG_3_OFFSET 				0x00003004
#define MODE_REG_3_OFFSET 				0x00003008
#define CONFIGURATION_TX_REG1_3_OFFSET 			0x0000300C
#define CONFIGURATION_RX_REG1_3_OFFSET 			0x00003010
#define TICK_REG_3_OFFSET 				0x0000302C
#define FEC_CONFIGURATION_REG1_3_OFFSET 		0x000030D0
#define STAT_RX_STATUS_REG1_3_OFFSET 			0x00003744
#define STAT_RX_RT_STATUS_REG1_3_OFFSET 		0x0000374C
#define STAT_STATISTICS_READY_3_OFFSET 			0x000037D8
#define STAT_TX_TOTAL_PACKETS_3_LSB_OFFSET 		0x00003818
#define STAT_TX_TOTAL_PACKETS_3_MSB_OFFSET 		0x0000381C
#define STAT_TX_TOTAL_GOOD_PACKETS_3_LSB_OFFSET 	0x00003820
#define STAT_TX_TOTAL_GOOD_PACKETS_3_MSB_OFFSET 	0x00003824
#define STAT_TX_TOTAL_BYTES_3_LSB_OFFSET 		0x00003828
#define STAT_TX_TOTAL_BYTES_3_MSB_OFFSET 		0x0000382C
#define STAT_TX_TOTAL_GOOD_BYTES_3_LSB_OFFSET 		0x00003830
#define STAT_TX_TOTAL_GOOD_BYTES_3_MSB_OFFSET 		0x00003834
#define STAT_RX_TOTAL_PACKETS_3_LSB_OFFSET 		0x00003E30
#define STAT_RX_TOTAL_PACKETS_3_MSB_OFFSET 		0x00003E34
#define STAT_RX_TOTAL_GOOD_PACKETS_3_LSB_OFFSET 	0x00003E38
#define STAT_RX_TOTAL_GOOD_PACKETS_3_MSB_OFFSET 	0x00003E3C
#define STAT_RX_TOTAL_BYTES_3_LSB_OFFSET 		0x00003E40
#define STAT_RX_TOTAL_BYTES_3_MSB_OFFSET 		0x00003E44
#define STAT_RX_TOTAL_GOOD_BYTES_3_LSB_OFFSET 		0x00003E48
#define STAT_RX_TOTAL_GOOD_BYTES_3_MSB_OFFSET 		0x00003E4C
/* Create MAP */

#define MRMAC_0_CONFIGURATION_REVISION_REG        	MRMAC_0_BASEADDR + CONFIGURATION_REVISION_REG_OFFSET
////// Port 0
#define MRMAC_0_RESET_REG_0        			MRMAC_0_BASEADDR + RESET_REG_0_OFFSET
#define MRMAC_0_MODE_REG_0        			MRMAC_0_BASEADDR + MODE_REG_0_OFFSET
#define MRMAC_0_CONFIGURATION_TX_REG1_0        		MRMAC_0_BASEADDR + CONFIGURATION_TX_REG1_0_OFFSET
#define MRMAC_0_CONFIGURATION_RX_REG1_0        		MRMAC_0_BASEADDR + CONFIGURATION_RX_REG1_0_OFFSET
#define MRMAC_0_TICK_REG_0        			MRMAC_0_BASEADDR + TICK_REG_0_OFFSET
#define MRMAC_0_FEC_CONFIGURATION_REG1_0        	MRMAC_0_BASEADDR + FEC_CONFIGURATION_REG1_0_OFFSET
#define MRMAC_0_STAT_RX_STATUS_REG1_0        		MRMAC_0_BASEADDR + STAT_RX_STATUS_REG1_0_OFFSET
#define MRMAC_0_STAT_RX_RT_STATUS_REG1_0        	MRMAC_0_BASEADDR + STAT_RX_RT_STATUS_REG1_0_OFFSET
#define MRMAC_0_STAT_STATISTICS_READY_0        		MRMAC_0_BASEADDR + STAT_STATISTICS_READY_0_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_0_LSB     	MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_0_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_0_MSB     	MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_0_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_0_LSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_0_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_0_MSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_0_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_0_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_0_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_0_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_0_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_0_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_0_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_0_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_0_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_0_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_0_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_0_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_0_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_0_LSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_0_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_0_MSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_0_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_0_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_0_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_0_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_0_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_0_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_0_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_0_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_0_MSB_OFFSET
////// Port 1
#define MRMAC_0_RESET_REG_1        			MRMAC_0_BASEADDR + RESET_REG_1_OFFSET
#define MRMAC_0_MODE_REG_1        			MRMAC_0_BASEADDR + MODE_REG_1_OFFSET
#define MRMAC_0_CONFIGURATION_TX_REG1_1        		MRMAC_0_BASEADDR + CONFIGURATION_TX_REG1_1_OFFSET
#define MRMAC_0_CONFIGURATION_RX_REG1_1        		MRMAC_0_BASEADDR + CONFIGURATION_RX_REG1_1_OFFSET
#define MRMAC_0_TICK_REG_1        			MRMAC_0_BASEADDR + TICK_REG_1_OFFSET
#define MRMAC_0_FEC_CONFIGURATION_REG1_1                MRMAC_0_BASEADDR + FEC_CONFIGURATION_REG1_1_OFFSET
#define MRMAC_0_STAT_RX_STATUS_REG1_1        	        MRMAC_0_BASEADDR + STAT_RX_STATUS_REG1_1_OFFSET
#define MRMAC_0_STAT_RX_RT_STATUS_REG1_1                MRMAC_0_BASEADDR + STAT_RX_RT_STATUS_REG1_1_OFFSET
#define MRMAC_0_STAT_STATISTICS_READY_1        	        MRMAC_0_BASEADDR + STAT_STATISTICS_READY_1_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_1_LSB             MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_1_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_1_MSB             MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_1_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_1_LSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_1_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_1_MSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_1_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_1_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_1_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_1_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_1_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_1_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_1_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_1_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_1_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_1_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_1_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_1_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_1_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_1_LSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_1_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_1_MSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_1_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_1_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_1_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_1_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_1_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_1_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_1_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_1_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_1_MSB_OFFSET
//// Port 2
#define MRMAC_0_RESET_REG_2        			MRMAC_0_BASEADDR + RESET_REG_2_OFFSET
#define MRMAC_0_MODE_REG_2        			MRMAC_0_BASEADDR + MODE_REG_2_OFFSET
#define MRMAC_0_CONFIGURATION_TX_REG1_2        		MRMAC_0_BASEADDR + CONFIGURATION_TX_REG1_2_OFFSET
#define MRMAC_0_CONFIGURATION_RX_REG1_2        		MRMAC_0_BASEADDR + CONFIGURATION_RX_REG1_2_OFFSET
#define MRMAC_0_TICK_REG_2        			MRMAC_0_BASEADDR + TICK_REG_2_OFFSET
#define MRMAC_0_FEC_CONFIGURATION_REG1_2         	MRMAC_0_BASEADDR + FEC_CONFIGURATION_REG1_2_OFFSET
#define MRMAC_0_STAT_RX_STATUS_REG1_2        		MRMAC_0_BASEADDR + STAT_RX_STATUS_REG1_2_OFFSET
#define MRMAC_0_STAT_RX_RT_STATUS_REG1_2        	MRMAC_0_BASEADDR + STAT_RX_RT_STATUS_REG1_2_OFFSET
#define MRMAC_0_STAT_STATISTICS_READY_2        		MRMAC_0_BASEADDR + STAT_STATISTICS_READY_2_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_2_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_2_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_2_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_2_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_2_LSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_2_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_2_MSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_2_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_2_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_2_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_2_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_2_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_2_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_2_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_2_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_2_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_2_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_2_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_2_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_2_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_2_LSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_2_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_2_MSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_2_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_2_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_2_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_2_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_2_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_2_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_2_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_2_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_2_MSB_OFFSET
//// Port 3
#define MRMAC_0_RESET_REG_3        			MRMAC_0_BASEADDR + RESET_REG_3_OFFSET
#define MRMAC_0_MODE_REG_3        			MRMAC_0_BASEADDR + MODE_REG_3_OFFSET
#define MRMAC_0_CONFIGURATION_TX_REG1_3        		MRMAC_0_BASEADDR + CONFIGURATION_TX_REG1_3_OFFSET
#define MRMAC_0_CONFIGURATION_RX_REG1_3        		MRMAC_0_BASEADDR + CONFIGURATION_RX_REG1_3_OFFSET
#define MRMAC_0_TICK_REG_3        			MRMAC_0_BASEADDR + TICK_REG_3_OFFSET
#define MRMAC_0_FEC_CONFIGURATION_REG1_3                MRMAC_0_BASEADDR + FEC_CONFIGURATION_REG1_3_OFFSET
#define MRMAC_0_STAT_RX_STATUS_REG1_3        	        MRMAC_0_BASEADDR + STAT_RX_STATUS_REG1_3_OFFSET
#define MRMAC_0_STAT_RX_RT_STATUS_REG1_3                MRMAC_0_BASEADDR + STAT_RX_RT_STATUS_REG1_3_OFFSET
#define MRMAC_0_STAT_STATISTICS_READY_3        	        MRMAC_0_BASEADDR + STAT_STATISTICS_READY_3_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_3_LSB             MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_3_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_PACKETS_3_MSB             MRMAC_0_BASEADDR + STAT_TX_TOTAL_PACKETS_3_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_3_LSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_3_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_3_MSB        MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_PACKETS_3_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_3_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_3_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_BYTES_3_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_BYTES_3_MSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_3_LSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_3_LSB_OFFSET
#define MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_3_MSB        	MRMAC_0_BASEADDR + STAT_TX_TOTAL_GOOD_BYTES_3_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_3_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_3_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_PACKETS_3_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_PACKETS_3_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_3_LSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_3_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_3_MSB        MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_PACKETS_3_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_3_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_3_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_BYTES_3_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_BYTES_3_MSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_3_LSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_3_LSB_OFFSET
#define MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_3_MSB        	MRMAC_0_BASEADDR + STAT_RX_TOTAL_GOOD_BYTES_3_MSB_OFFSET

#define MRMAC_0_GT_DATAPATH_RESET                       MRMAC_0_GPIO_DEBUG_BASEADDR + 0x00000000
#define MRMAC_0_GT_LINERATE_RESET        	        MRMAC_0_COMMON_CTL_STAT_BASEADDR + 0x00000000
#define MRMAC_0_GT_STATUS               	        MRMAC_0_COMMON_CTL_STAT_BASEADDR + 0x00000008
#define MRMAC_0_GENMON_CTL_BASEADDR_LSB                 MRMAC_0_GENMON_CTL_BASEADDR + 0x00000000
#define MRMAC_0_GENMON_CTL_BASEADDR_LSB2                MRMAC_0_GENMON_CTL_BASEADDR + 0x00000004
#define MRMAC_0_GENMON_CTL_BASEADDR_MSB                 MRMAC_0_GENMON_CTL_BASEADDR + 0x00000008
#define MRMAC_0_GENMON_CTL_BASEADDR_MSB2                MRMAC_0_GENMON_CTL_BASEADDR + 0x0000000C


typedef uint32_t U32;
typedef uint64_t U64;


int wait (uint32_t delay)
{
	while (delay > 0){
		delay --;
	}
	return 1;
}	

int cal_rst_val(int k)
{
	int val=0;
	for(int i=0;i<k;i++)
	{
		val |= (1<<i);
	}
	//printf("%x",val);
	return val;
}

int print_port0_statistics() {
	int stat_match_flag_port0;
	uint32_t tx_total_pkt_0_MSB, tx_total_pkt_0_LSB, tx_total_bytes_0_MSB, tx_total_bytes_0_LSB, tx_total_good_pkts_0_MSB, tx_total_good_pkts_0_LSB, tx_total_good_bytes_0_MSB, tx_total_good_bytes_0_LSB;
	uint32_t rx_total_pkt_0_MSB, rx_total_pkt_0_LSB, rx_total_bytes_0_MSB, rx_total_bytes_0_LSB, rx_total_good_pkts_0_MSB, rx_total_good_pkts_0_LSB, rx_total_good_bytes_0_MSB, rx_total_good_bytes_0_LSB;
	uint64_t tx_total_pkt_0, tx_total_bytes_0, tx_total_good_bytes_0, tx_total_good_pkts_0, rx_total_pkt_0, rx_total_bytes_0, rx_total_good_bytes_0, rx_total_good_pkts_0;
    tx_total_pkt_0_MSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_0_MSB);
	tx_total_pkt_0_LSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_0_LSB);
	tx_total_good_pkts_0_MSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_0_MSB);
	tx_total_good_pkts_0_LSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_0_LSB);
	tx_total_bytes_0_MSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_0_MSB);
	tx_total_bytes_0_LSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_0_LSB);
	tx_total_good_bytes_0_LSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_0_LSB);
	tx_total_good_bytes_0_MSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_0_LSB);

	rx_total_pkt_0_MSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_0_MSB);
	rx_total_pkt_0_LSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_0_LSB);
	rx_total_good_pkts_0_MSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_0_MSB);
	rx_total_good_pkts_0_LSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_0_LSB);
	rx_total_bytes_0_MSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_0_MSB);
	rx_total_bytes_0_LSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_0_LSB);
	rx_total_good_bytes_0_LSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_0_LSB);
	rx_total_good_bytes_0_MSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_0_LSB);
	xil_printf( "\n\rPORT - 0 Statistics           \n\r\n\r" );
    tx_total_pkt_0 = (uint64_t) tx_total_pkt_0_MSB << 32 | tx_total_pkt_0_LSB;
	tx_total_bytes_0 = (uint64_t) tx_total_bytes_0_MSB << 32 | tx_total_bytes_0_LSB;
	tx_total_good_pkts_0 = (uint64_t) tx_total_good_pkts_0_MSB << 32 | tx_total_good_pkts_0_LSB;
	rx_total_pkt_0 = (uint64_t) rx_total_pkt_0_MSB << 32 | rx_total_pkt_0_LSB;
	rx_total_bytes_0 = (uint64_t) rx_total_bytes_0_MSB << 32 | rx_total_bytes_0_LSB;
	rx_total_good_pkts_0 = (uint64_t) rx_total_good_pkts_0_MSB << 32 | rx_total_good_pkts_0_LSB;
	tx_total_good_bytes_0 =(uint64_t) tx_total_good_bytes_0_MSB << 32 | tx_total_good_bytes_0_LSB;
	rx_total_good_bytes_0 =(uint64_t) rx_total_good_bytes_0_MSB << 32 | rx_total_good_bytes_0_LSB;

	xil_printf("  STAT_TX_TOTAL_PACKETS           = %d,     \t STAT_RX_TOTAL_PACKETS           = %d\n\r\n\r", tx_total_pkt_0,rx_total_pkt_0);
	xil_printf("  STAT_TX_TOTAL_GOOD_PACKETS      = %d,     \t STAT_RX_TOTAL_GOOD_PACKETS      = %d\n\r\n\r", tx_total_good_pkts_0,rx_total_good_pkts_0);
	xil_printf("  STAT_TX_TOTAL_BYTES             = %d,     \t STAT_RX_BYTES                   = %d\n\r\n\r", tx_total_bytes_0,rx_total_bytes_0);
	xil_printf("  STAT_TX_TOTAL_GOOD_BYTES        = %d,     \t STAT_RX_TOTAL_GOOD_BYTES        = %d\n\r\n\r", tx_total_good_bytes_0,rx_total_good_bytes_0);
	if ((tx_total_pkt_0 != 0) && (tx_total_pkt_0 == rx_total_pkt_0) && (tx_total_bytes_0 == rx_total_bytes_0) && (tx_total_good_pkts_0 == rx_total_good_pkts_0) && (tx_total_good_bytes_0 == rx_total_good_bytes_0) )
	    {
		stat_match_flag_port0 = 1;
	    } else {
	    stat_match_flag_port0 = 0;
	    }
	return stat_match_flag_port0;
}

int print_port1_statistics() {
	int stat_match_flag_port_1;
	uint32_t tx_total_pkt_1_MSB, tx_total_pkt_1_LSB, tx_total_bytes_1_MSB, tx_total_bytes_1_LSB, tx_total_good_pkts_1_MSB, tx_total_good_pkts_1_LSB, tx_total_good_bytes_1_MSB, tx_total_good_bytes_1_LSB;
	uint32_t rx_total_pkt_1_MSB, rx_total_pkt_1_LSB, rx_total_bytes_1_MSB, rx_total_bytes_1_LSB, rx_total_good_pkts_1_MSB, rx_total_good_pkts_1_LSB, rx_total_good_bytes_1_MSB, rx_total_good_bytes_1_LSB;
	uint64_t tx_total_pkt_1, tx_total_bytes_1, tx_total_good_bytes_1, tx_total_good_pkts_1, rx_total_pkt_1, rx_total_bytes_1, rx_total_good_bytes_1, rx_total_good_pkts_1;
    tx_total_pkt_1_MSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_1_MSB);
	tx_total_pkt_1_LSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_1_LSB);
	tx_total_good_pkts_1_MSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_1_MSB);
	tx_total_good_pkts_1_LSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_1_LSB);
	tx_total_bytes_1_MSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_1_MSB);
	tx_total_bytes_1_LSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_1_LSB);
	tx_total_good_bytes_1_LSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_1_LSB);
	tx_total_good_bytes_1_MSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_1_LSB);

	rx_total_pkt_1_MSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_1_MSB);
	rx_total_pkt_1_LSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_1_LSB);
	rx_total_good_pkts_1_MSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_1_MSB);
	rx_total_good_pkts_1_LSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_1_LSB);
	rx_total_bytes_1_MSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_1_MSB);
	rx_total_bytes_1_LSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_1_LSB);
	rx_total_good_bytes_1_LSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_1_LSB);
	rx_total_good_bytes_1_MSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_1_LSB);
	xil_printf( "\n\rPORT - 1 Statistics           \n\r\n\r" );
    tx_total_pkt_1 = (uint64_t) tx_total_pkt_1_MSB << 32 | tx_total_pkt_1_LSB;
	tx_total_bytes_1 = (uint64_t) tx_total_bytes_1_MSB << 32 | tx_total_bytes_1_LSB;
	tx_total_good_pkts_1 = (uint64_t) tx_total_good_pkts_1_MSB << 32 | tx_total_good_pkts_1_LSB;
	rx_total_pkt_1 = (uint64_t) rx_total_pkt_1_MSB << 32 | rx_total_pkt_1_LSB;
	rx_total_bytes_1 = (uint64_t) rx_total_bytes_1_MSB << 32 | rx_total_bytes_1_LSB;
	rx_total_good_pkts_1 = (uint64_t) rx_total_good_pkts_1_MSB << 32 | rx_total_good_pkts_1_LSB;
	tx_total_good_bytes_1 =(uint64_t) tx_total_good_bytes_1_MSB << 32 | tx_total_good_bytes_1_LSB;
	rx_total_good_bytes_1 =(uint64_t) rx_total_good_bytes_1_MSB << 32 | rx_total_good_bytes_1_LSB;

	xil_printf("  STAT_TX_TOTAL_PACKETS           = %d,     \t STAT_RX_TOTAL_PACKETS           = %d\n\r\n\r", tx_total_pkt_1,rx_total_pkt_1);
	xil_printf("  STAT_TX_TOTAL_GOOD_PACKETS      = %d,     \t STAT_RX_TOTAL_GOOD_PACKETS      = %d\n\r\n\r", tx_total_good_pkts_1,rx_total_good_pkts_1);
	xil_printf("  STAT_TX_TOTAL_BYTES             = %d,     \t STAT_RX_BYTES                   = %d\n\r\n\r", tx_total_bytes_1,rx_total_bytes_1);
	xil_printf("  STAT_TX_TOTAL_GOOD_BYTES        = %d,     \t STAT_RX_TOTAL_GOOD_BYTES        = %d\n\r\n\r", tx_total_good_bytes_1,rx_total_good_bytes_1);
	if ((tx_total_pkt_1 != 0) && (tx_total_pkt_1 == rx_total_pkt_1) && (tx_total_bytes_1 == rx_total_bytes_1) && (tx_total_good_pkts_1 == rx_total_good_pkts_1) && (tx_total_good_bytes_1 == rx_total_good_bytes_1) )
	    {
		stat_match_flag_port_1 = 1;
	    } else {
	    stat_match_flag_port_1 = 0;
	    }
	return stat_match_flag_port_1;
}

int print_port2_statistics() {
	int stat_match_flag_port_2;
	uint32_t tx_total_pkt_2_MSB, tx_total_pkt_2_LSB, tx_total_bytes_2_MSB, tx_total_bytes_2_LSB, tx_total_good_pkts_2_MSB, tx_total_good_pkts_2_LSB, tx_total_good_bytes_2_MSB, tx_total_good_bytes_2_LSB;
	uint32_t rx_total_pkt_2_MSB, rx_total_pkt_2_LSB, rx_total_bytes_2_MSB, rx_total_bytes_2_LSB, rx_total_good_pkts_2_MSB, rx_total_good_pkts_2_LSB, rx_total_good_bytes_2_MSB, rx_total_good_bytes_2_LSB;
	uint64_t tx_total_pkt_2, tx_total_bytes_2, tx_total_good_bytes_2, tx_total_good_pkts_2, rx_total_pkt_2, rx_total_bytes_2, rx_total_good_bytes_2, rx_total_good_pkts_2;
    tx_total_pkt_2_MSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_2_MSB);
	tx_total_pkt_2_LSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_2_LSB);
	tx_total_good_pkts_2_MSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_2_MSB);
	tx_total_good_pkts_2_LSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_2_LSB);
	tx_total_bytes_2_MSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_2_MSB);
	tx_total_bytes_2_LSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_2_LSB);
	tx_total_good_bytes_2_LSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_2_LSB);
	tx_total_good_bytes_2_MSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_2_LSB);

	rx_total_pkt_2_MSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_2_MSB);
	rx_total_pkt_2_LSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_2_LSB);
	rx_total_good_pkts_2_MSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_2_MSB);
	rx_total_good_pkts_2_LSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_2_LSB);
	rx_total_bytes_2_MSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_2_MSB);
	rx_total_bytes_2_LSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_2_LSB);
	rx_total_good_bytes_2_LSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_2_LSB);
	rx_total_good_bytes_2_MSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_2_LSB);
	xil_printf( "\n\rPORT - 2 Statistics           \n\r\n\r" );
    tx_total_pkt_2 = (uint64_t) tx_total_pkt_2_MSB << 32 | tx_total_pkt_2_LSB;
	tx_total_bytes_2 = (uint64_t) tx_total_bytes_2_MSB << 32 | tx_total_bytes_2_LSB;
	tx_total_good_pkts_2 = (uint64_t) tx_total_good_pkts_2_MSB << 32 | tx_total_good_pkts_2_LSB;
	rx_total_pkt_2 = (uint64_t) rx_total_pkt_2_MSB << 32 | rx_total_pkt_2_LSB;
	rx_total_bytes_2 = (uint64_t) rx_total_bytes_2_MSB << 32 | rx_total_bytes_2_LSB;
	rx_total_good_pkts_2 = (uint64_t) rx_total_good_pkts_2_MSB << 32 | rx_total_good_pkts_2_LSB;
	tx_total_good_bytes_2 =(uint64_t) tx_total_good_bytes_2_MSB << 32 | tx_total_good_bytes_2_LSB;
	rx_total_good_bytes_2 =(uint64_t) rx_total_good_bytes_2_MSB << 32 | rx_total_good_bytes_2_LSB;

	xil_printf("  STAT_TX_TOTAL_PACKETS           = %d,     \t STAT_RX_TOTAL_PACKETS           = %d\n\r\n\r", tx_total_pkt_2,rx_total_pkt_2);
	xil_printf("  STAT_TX_TOTAL_GOOD_PACKETS      = %d,     \t STAT_RX_TOTAL_GOOD_PACKETS      = %d\n\r\n\r", tx_total_good_pkts_2,rx_total_good_pkts_2);
	xil_printf("  STAT_TX_TOTAL_BYTES             = %d,     \t STAT_RX_BYTES                   = %d\n\r\n\r", tx_total_bytes_2,rx_total_bytes_2);
	xil_printf("  STAT_TX_TOTAL_GOOD_BYTES        = %d,     \t STAT_RX_TOTAL_GOOD_BYTES        = %d\n\r\n\r", tx_total_good_bytes_2,rx_total_good_bytes_2);
	if ((tx_total_pkt_2 != 0) && (tx_total_pkt_2 == rx_total_pkt_2) && (tx_total_bytes_2 == rx_total_bytes_2) && (tx_total_good_pkts_2 == rx_total_good_pkts_2) && (tx_total_good_bytes_2 == rx_total_good_bytes_2) )
	    {
		stat_match_flag_port_2 = 1;
	    } else {
	    stat_match_flag_port_2 = 0;
	    }
	return stat_match_flag_port_2;
}

int print_port3_statistics() {
	int stat_match_flag_port_3;
	uint32_t tx_total_pkt_3_MSB, tx_total_pkt_3_LSB, tx_total_bytes_3_MSB, tx_total_bytes_3_LSB, tx_total_good_pkts_3_MSB, tx_total_good_pkts_3_LSB, tx_total_good_bytes_3_MSB, tx_total_good_bytes_3_LSB;
	uint32_t rx_total_pkt_3_MSB, rx_total_pkt_3_LSB, rx_total_bytes_3_MSB, rx_total_bytes_3_LSB, rx_total_good_pkts_3_MSB, rx_total_good_pkts_3_LSB, rx_total_good_bytes_3_MSB, rx_total_good_bytes_3_LSB;
	uint64_t tx_total_pkt_3, tx_total_bytes_3, tx_total_good_bytes_3, tx_total_good_pkts_3, rx_total_pkt_3, rx_total_bytes_3, rx_total_good_bytes_3, rx_total_good_pkts_3;
    tx_total_pkt_3_MSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_3_MSB);
	tx_total_pkt_3_LSB        = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_PACKETS_3_LSB);
	tx_total_good_pkts_3_MSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_3_MSB);
	tx_total_good_pkts_3_LSB  = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_PACKETS_3_LSB);
	tx_total_bytes_3_MSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_3_MSB);
	tx_total_bytes_3_LSB      = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_BYTES_3_LSB);
	tx_total_good_bytes_3_LSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_3_LSB);
	tx_total_good_bytes_3_MSB = *(U32 *) (MRMAC_0_STAT_TX_TOTAL_GOOD_BYTES_3_LSB);

	rx_total_pkt_3_MSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_3_MSB);
	rx_total_pkt_3_LSB        = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_PACKETS_3_LSB);
	rx_total_good_pkts_3_MSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_3_MSB);
	rx_total_good_pkts_3_LSB  = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_PACKETS_3_LSB);
	rx_total_bytes_3_MSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_3_MSB);
	rx_total_bytes_3_LSB      = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_BYTES_3_LSB);
	rx_total_good_bytes_3_LSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_3_LSB);
	rx_total_good_bytes_3_MSB = *(U32 *) (MRMAC_0_STAT_RX_TOTAL_GOOD_BYTES_3_LSB);
	xil_printf( "\n\rPORT - 3 Statistics           \n\r\n\r" );
    tx_total_pkt_3 = (uint64_t) tx_total_pkt_3_MSB << 32 | tx_total_pkt_3_LSB;
	tx_total_bytes_3 = (uint64_t) tx_total_bytes_3_MSB << 32 | tx_total_bytes_3_LSB;
	tx_total_good_pkts_3 = (uint64_t) tx_total_good_pkts_3_MSB << 32 | tx_total_good_pkts_3_LSB;
	rx_total_pkt_3 = (uint64_t) rx_total_pkt_3_MSB << 32 | rx_total_pkt_3_LSB;
	rx_total_bytes_3 = (uint64_t) rx_total_bytes_3_MSB << 32 | rx_total_bytes_3_LSB;
	rx_total_good_pkts_3 = (uint64_t) rx_total_good_pkts_3_MSB << 32 | rx_total_good_pkts_3_LSB;
	tx_total_good_bytes_3 =(uint64_t) tx_total_good_bytes_3_MSB << 32 | tx_total_good_bytes_3_LSB;
	rx_total_good_bytes_3 =(uint64_t) rx_total_good_bytes_3_MSB << 32 | rx_total_good_bytes_3_LSB;

	xil_printf("  STAT_TX_TOTAL_PACKETS           = %d,     \t STAT_RX_TOTAL_PACKETS           = %d\n\r\n\r", tx_total_pkt_3,rx_total_pkt_3);
	xil_printf("  STAT_TX_TOTAL_GOOD_PACKETS      = %d,     \t STAT_RX_TOTAL_GOOD_PACKETS      = %d\n\r\n\r", tx_total_good_pkts_3,rx_total_good_pkts_3);
	xil_printf("  STAT_TX_TOTAL_BYTES             = %d,     \t STAT_RX_BYTES                   = %d\n\r\n\r", tx_total_bytes_3,rx_total_bytes_3);
	xil_printf("  STAT_TX_TOTAL_GOOD_BYTES        = %d,     \t STAT_RX_TOTAL_GOOD_BYTES        = %d\n\r\n\r", tx_total_good_bytes_3,rx_total_good_bytes_3);
	if ((tx_total_pkt_3 != 0) && (tx_total_pkt_3 == rx_total_pkt_3) && (tx_total_bytes_3 == rx_total_bytes_3) && (tx_total_good_pkts_3 == rx_total_good_pkts_3) && (tx_total_good_bytes_3 == rx_total_good_bytes_3) )
	    {
		stat_match_flag_port_3 = 1;
	    } else {
	    stat_match_flag_port_3 = 0;
	    }
	return stat_match_flag_port_3;
} 


int wait_gt_rxresetdone (int lane_cnt) {

	int time_out;
	uint32_t ReadData_GT_RX;

       // Check for GT RX RESET DONE and wait for 10000000 cycles, if not "DONE"
       xil_printf("INFO : Waiting for GT RX Reset done... \n\r");
	time_out =0;
   	do
	{
		ReadData_GT_RX = *(U32 *)(MRMAC_0_GT_STATUS);
		ReadData_GT_RX =   (((1 << 4) - 1) & (ReadData_GT_RX >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_GT_RX!= cal_rst_val(lane_cnt) && time_out < 10000000);
	if (time_out>= 10000000)
	{
		xil_printf("INFO : GT Lock Failed        (Read GT Status  = 0x%x)\n\r\n\r", ReadData_GT_RX);
	} else {
		xil_printf("INFO : GT Locked             (Read GT Status  = 0x%x)\n\r\n\r", ReadData_GT_RX);
	}
}


int gt_rx_datapath_reset(int lane_cnt) {
        
       xil_printf("INFO : Toggle GT RXDATAPATH Reset  \n\r");
       *(U32 *) (MRMAC_0_GT_DATAPATH_RESET) = 0xF0;
       wait(5000);
       //xil_printf("INFO : Toggle MRMAC RX Reset  \n\r");
       *(U32 *) (MRMAC_0_GT_DATAPATH_RESET) = 0x00;
       //*(U32 *) (MRMAC_0_CORE_SERDES_RESET) = 0x0000;
      wait_gt_rxresetdone (lane_cnt);
}


int test_100GE()
{
	
	int stat_match_flag_port0_100g=0;
	int time_out;
	uint32_t ReadData_100G;
    	int gt_lanes = 4;

    xil_printf("\n*******1x100GE Test START        \n\r");
    xil_printf("INFO : Start MRMAC Configuration\n\r");
 	
	
	
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	xil_printf("INFO : SET Port 0 1x100GE\n\r");
	
		*(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000A64;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;

	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;

    *(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
	xil_printf("INFO : Switching GT Line Rate          \n\r" );
	xil_printf("INFO : Reset GT \n\r");

	//Assert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00001F02;  //For External: 0x00000F02; Near-End PCS: 0x00001F02

      /*
      [11:8]: gt_reset_all = 4'hF
      [7:0]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b000 (External: 3'b000; Near-End PCS: 3'b001)
      */
	//De-Assert GT Reset all      
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00001002;//0x00001002; //For External: 0x00000002; Near-End PCS: 0x00001002

		sleep(2);

		
    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

	// Wait for RX aligned 
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_100G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_100G =   (((1 << 3) - 1) & (ReadData_100G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_100G!= 0x7 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_100G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_100G);
	}	
        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	

	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
    // Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x00004501;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x00004500;
	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
    // Wait for Statistics ready 
	time_out =0;
	do
	{
		ReadData_100G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_100G =   (((1 << 2) - 1) & (ReadData_100G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_100G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_100G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_100G);
	}	
    stat_match_flag_port0_100g=print_port0_statistics();
    if (stat_match_flag_port0_100g==1)
    {
    	xil_printf( "INFO : 1x100GE Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : 1x100GE Test Fail          \n\r" );
	    return 0;
    }
	xil_printf("\n*******1x100GE Test Complete        \n\r");
	return 1;	
}
int test_50GE()
{
	int stat_match_flag_port0_50g=0;
	int time_out;
	uint32_t ReadData_50G;
    	int gt_lanes = 4;

	 xil_printf("\n*******1x50GE Test START        \n\r");
	xil_printf("INFO : Start MRMAC Configuration\n\r");
 	
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	xil_printf("INFO : SET Port 0 1x50GE\n\r");
	
		*(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000A63;
 	
		
		
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;

	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;
	
    *(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
	xil_printf("\nINFO : Switching GT Line Rate          \n\r" );
	xil_printf("INFO : Reset GT \n\r");

	//Asert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00001F02;//0x00001F00;  //For External: 0x00000F02; Near-End PCS: 0x00001F02
      /*
      [11:8]: gt_reset_all = 4'hF
      [8:1]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b001 (External: 3'b000; Near-End PCS: 3'b001)
      */
	//De-Assert GT Reset all      
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00001002;//0x00001000; //For External: 0x00000002; Near-End PCS: 0x00001002
		sleep(2);

    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

	
	// Wait for RX aligned 
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_50G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_50G =   (((1 << 3) - 1) & (ReadData_50G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_50G!= 0x7 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_50G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_50G);
	}
        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	

		sleep(2);
		
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	// Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x00003401;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x00003400;
	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
    // Wait for Statistics ready 
	time_out =0;
	do
	{
		ReadData_50G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_50G =   (((1 << 2) - 1) & (ReadData_50G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_50G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_50G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_50G);
	}	
    stat_match_flag_port0_50g=print_port0_statistics();
    if (stat_match_flag_port0_50g==1)
    {
    	xil_printf( "INFO : 1x50GE Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : 1x50GE Test Fail          \n\r" );
    	return 0;
    }
	xil_printf("\n*******1x50GE Test Complete        \n\r");
	return 1;
	
}

int test_40GE()
{
	int stat_match_flag_port0_40g=0;
	int time_out;
	uint32_t ReadData_40G;
    	int gt_lanes = 4;

	 xil_printf("\n*******1x40GE Test START        \n\r");
	xil_printf("INFO : Start MRMAC Configuration\n\r");
 	
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	xil_printf("INFO : SET Port 0 1x40GE\n\r");
	
	
		*(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000A42;
 		
		
		
		
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;	
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;	
    *(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
	xil_printf("\nINFO : Switching GT Line Rate          \n\r" );
	xil_printf("INFO : Reset GT \n\r");

	//Asert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00001F01;  //For External: 0x00000F01; Near-End PCS: 0x4B001F01 
      /*
      [11:8]: gt_reset_all = 4'hF
      [8:1]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b000 (External: 3'b000; Near-End PCS: 3'b001)
      */
       //DE-Assert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00001001; //For External: 0x00000001; Near-End PCS: 0x00001001

		sleep(2);


    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

		
	// Wait for RX aligned 
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_40G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_40G =   (((1 << 3) - 1) & (ReadData_40G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_40G!= 0x7 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_40G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_40G);
	}	
        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	
	
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	// Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x00002401;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x00002400;
	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
    // Wait for Statistics ready 
	time_out =0;
	do
	{
		ReadData_40G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_40G =   (((1 << 2) - 1) & (ReadData_40G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_40G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_40G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_40G);
	}	
    stat_match_flag_port0_40g=print_port0_statistics();
    if (stat_match_flag_port0_40g==1)
    {
    	xil_printf( "INFO : 1x40GE Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : 1x40GE Test Fail          \n\r" );
    	return 0;
    }
	xil_printf("\n*******1x40GE Test Complete        \n\r");
	return 1;
}
int test_25GE()
{
	int stat_match_flag_port0_25G=0;
	int stat_match_flag_port1_25G=0;
	int stat_match_flag_port2_25G=0;
	int stat_match_flag_port3_25G=0;
	int time_out;
	uint32_t ReadData_25G;
    	int gt_lanes = 4;

	xil_printf("\n*******4x25GE Test START        \n\r");
	xil_printf("INFO : Start MRMAC Configuration\n\r");
 
 
 
 
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_1) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0xFFFFFFFF;

    xil_printf("INFO : SET Port 0 1x25GE\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000261;
 		
		
		
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;
    *(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;	

	xil_printf("INFO : SET Port 1 1x25GE\n\r");	
         *(U32 *) (MRMAC_0_MODE_REG_1)  = 0x40000261;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_1) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_1) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_1) = 0x00000000;


	
	xil_printf("INFO : SET Port 2 1x25GE\n\r");	
         *(U32 *) (MRMAC_0_MODE_REG_2)  = 0x40000261;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_2) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_2) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_2) = 0x00000000;
	
	xil_printf("INFO : SET Port 3 1x25GE\n\r");	
         *(U32 *) (MRMAC_0_MODE_REG_3)  = 0x40000261;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_3) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_3) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_3) = 0x00000000;
	
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
    *(U32 *) (MRMAC_0_RESET_REG_1) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0x00000000;
	xil_printf("\nINFO : Switching GT Line Rate          \n\r\n\r" );

	//Asert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F02;//0x00071F00;  //For External: 0x00070F02; Near-End PCS: 0x00071F02
      /*
      [11:8]: gt_reset_all = 4'hF
      [8:1]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b000 (External: 3'b000; Near-End PCS: 3'b001)
      */
       //DE-Assert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071002;//0x00071000; //For External: 0x00070002; Near-End PCS: 0x00071002

		sleep(2);

    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

		
	// Wait for RX aligned 
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_25G =   (((1 << 3) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000*1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
	}	

	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1) = 0xFFFFFFFF;
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1);
		ReadData_25G =   (((1 << 3) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
	}

	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2) = 0xFFFFFFFF;
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2);
		ReadData_25G =   (((1 << 3) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
	}	
    time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3) = 0xFFFFFFFF;
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3);
		ReadData_25G =   (((1 << 3) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_25G);
	}
        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	

    // Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;
	// Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x12011201;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x12011201;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x12001200;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x12001200;
	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;


	time_out =0;
	do
	{
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_25G =   (((1 << 2) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_25G);
	}

	time_out =0;
	do
	{
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_1);
		ReadData_25G =   (((1 << 2) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - Statistics ready (Status  = 0x%x)\n\r", ReadData_25G);
	}

	
	time_out =0;
	do
	{
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_2);
		ReadData_25G =   (((1 << 2) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - Statistics ready (Status  = 0x%x)\n\r", ReadData_25G);
	}	
	time_out =0;
	do
	{
		ReadData_25G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_3);
		ReadData_25G =   (((1 << 2) - 1) & (ReadData_25G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_25G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_25G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - Statistics ready (Status  = 0x%x)\n\r", ReadData_25G);
	}	
    stat_match_flag_port0_25G=print_port0_statistics();
	stat_match_flag_port1_25G=print_port1_statistics();
	stat_match_flag_port2_25G=print_port2_statistics();
	stat_match_flag_port3_25G=print_port3_statistics();


    if ((stat_match_flag_port0_25G==1) && (stat_match_flag_port1_25G==1) && (stat_match_flag_port2_25G==1) && (stat_match_flag_port3_25G==1) )
    {
    	xil_printf( "INFO : 4x25GE Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : 4x25GE Test Fail          \n\r" );
    	return 0;
    }
	xil_printf("\n*******4x25GE Test Complete        \n\r");
	return 1;
	
}
int test_10GE()
{
	int stat_match_flag_port0_10G=0;
	int stat_match_flag_port1_10G=0;
	int stat_match_flag_port2_10G=0;
	int stat_match_flag_port3_10G=0;
	int time_out;
	uint32_t ReadData_10G;
    	int gt_lanes = 4;

	xil_printf("\n*******4x10GE Test START        \n\r");
	xil_printf("INFO : Start MRMAC Configuration\n\r");
 
 
 
 	
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_1) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0xFFFFFFFF;


    xil_printf("INFO : SET Port 0 1x10GE\n\r");	
	
	
         *(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000240;
 	
 		
		
		
		
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;
    *(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;	

	xil_printf("INFO : SET Port 1 1x10GE\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_1)  = 0x40000240;
 	
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_1) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_1) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_1) = 0x00000000;
	
	xil_printf("INFO : SET Port 2 1x10GE\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_2)  = 0x40000240;
 	
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_2) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_2) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_2) = 0x00000000;
	
	xil_printf("INFO : SET Port 3 1x10GE\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_3)  = 0x40000240;
 	
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_3) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_3) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_3) = 0x00000000;
	
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
    *(U32 *) (MRMAC_0_RESET_REG_1) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0x00000000;
	xil_printf("\nINFO : Switching GT Line Rate          \n\r\n\r" );
	//Apply GT Reset all
	xil_printf("INFO : Reset GT \n\r");
	//*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F01;

	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071000;

	//Asert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F01;//0x00071F00;  //For External: 0x00070F01; Near-End PCS: 0x00071F01
       //DE-Assert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071001;//0x00071000; //For External: 0x00070001; Near-End PCS: 0x00071001
      /*
      [11:8]: gt_reset_all = 4'hF
      [8:1]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b000 (External: 3'b000; Near-End PCS: 3'b001)
      */

		sleep(2);


    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

		
	// Wait for RX aligned 

	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}
	
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}

	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}
	
    time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}

        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	

    // Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;
	// Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x01050105;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x01050105;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x01040104;
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x01040104;
	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;


	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}

	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_1);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}
	
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_2);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}
	
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_3);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	
    stat_match_flag_port0_10G=print_port0_statistics();
	stat_match_flag_port1_10G=print_port1_statistics();
	stat_match_flag_port2_10G=print_port2_statistics();
	stat_match_flag_port3_10G=print_port3_statistics();


    if ((stat_match_flag_port0_10G==1) && (stat_match_flag_port1_10G==1) && (stat_match_flag_port2_10G==1) && (stat_match_flag_port3_10G==1) )
    {
    	xil_printf( "INFO : 4x10GE Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : 4x10GE Test Fail          \n\r" );
    	return 0;
    }
	xil_printf("\n*******4x10GE Test Complete        \n\r");
	return 1;
	
}
int test_10GE_25GE()
{
	int stat_match_flag_port0_10G=0;
	int stat_match_flag_port1_10G=0;
	int stat_match_flag_port2_10G=0;
	int stat_match_flag_port3_10G=0;
	int time_out;
	uint32_t ReadData_10G;
    	int gt_lanes = 4;

	xil_printf("\n*******2x10GE 2x25GE Test START        \n\r");
	xil_printf("INFO : Start MRMAC Configuration\n\r");
 
 
 
 	
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_1) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0xFFFFFFFF;
    xil_printf("INFO : SET Port 0 1x10GE\n\r");	
	
	
         *(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000240;
 	
 		
		
		
		
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;
    *(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;	
	xil_printf("INFO : SET Port 1 1x10GE\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_1)  = 0x40000240;
 	
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_1) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_1) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_1) = 0x00000000;	
	xil_printf("INFO : SET Port 2 1x25GE\n\r");	
         *(U32 *) (MRMAC_0_MODE_REG_2)  = 0x40000261;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_2) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_2) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_2) = 0x00000000;	
	xil_printf("INFO : SET Port 3 1x25GE\n\r");	
         *(U32 *) (MRMAC_0_MODE_REG_3)  = 0x40000261;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_3) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_3) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_3) = 0x00000000;	
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
    *(U32 *) (MRMAC_0_RESET_REG_1) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0x00000000;
	xil_printf("\nINFO : Switching GT Line Rate          \n\r\n\r" );
	//Apply GT Reset all
	xil_printf("INFO : Reset GT \n\r");
	//*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F00;
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071000;

	//Asert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F01;//0x00071F00;  //For External: 0x00070F01; Near-End PCS: 0x00071F01
       //DE-Assert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071001;//0x00071000; //For External: 0x00070001; Near-End PCS: 0x00071001
      /*
      [11:8]: gt_reset_all = 4'hF
      [8:1]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b000 (External: 3'b000; Near-End PCS: 3'b001)
      */

		sleep(2);

    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

	
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}	
    time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}
        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	

    // Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;
	// Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");

	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x01050105; //10G 10G
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x12011201; //25G 25G
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x01040104; //10G 10G
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x12001200; //25G 25G
	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_1);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_2);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_3);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	

    stat_match_flag_port0_10G=print_port0_statistics();
	stat_match_flag_port1_10G=print_port1_statistics();
	stat_match_flag_port2_10G=print_port2_statistics();
	stat_match_flag_port3_10G=print_port3_statistics();
    if ((stat_match_flag_port0_10G==1) && (stat_match_flag_port1_10G==1) && (stat_match_flag_port2_10G==1) && (stat_match_flag_port3_10G==1) )
    {
    	xil_printf( "INFO : 2x10GE 2x25GE Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : 2x10GE 2x25GE Test Fail          \n\r" );
    	return 0;
    }
	xil_printf("\n*******2x10GE 2x25GE Test Complete        \n\r");
	return 1;
	
}
int test_25GE_10GE()
{
	int stat_match_flag_port0_25G=0;
	int stat_match_flag_port1_25G=0;
	int stat_match_flag_port2_10G=0;
	int stat_match_flag_port3_10G=0;
	int time_out;
	uint32_t ReadData_10G;
    	int gt_lanes = 4;

	xil_printf("\n*******2x25GE 2x10GE Test START        \n\r");
	xil_printf("INFO : Start MRMAC Configuration\n\r");
 
 
 
 	
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_1) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0xFFFFFFFF;
    xil_printf("INFO : SET Port 0 1x25GE\n\r");	
	
	
         *(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000261;
 		
		
		
		
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;
    *(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;	
	xil_printf("INFO : SET Port 1 1x25GE\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_1)  = 0x40000261;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_1) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_1) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_1) = 0x00000000;	
	xil_printf("INFO : SET Port 2 1x10GE\n\r");	
         *(U32 *) (MRMAC_0_MODE_REG_2)  = 0x40000240;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_2) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_2) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_2) = 0x00000000;	
	xil_printf("INFO : SET Port 3 1x10GE\n\r");	
         *(U32 *) (MRMAC_0_MODE_REG_3)  = 0x40000240;
 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_3) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_3) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_3) = 0x00000000;	
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
    *(U32 *) (MRMAC_0_RESET_REG_1) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0x00000000;
	xil_printf("\nINFO : Switching GT Line Rate          \n\r\n\r" );
	//Apply GT Reset all
	xil_printf("INFO : Reset GT \n\r");
	//*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F00;
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071000;

	//Asert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F01;//0x00071001;//0x00071F00;  //For External: 0x00070F01; Near-End PCS: 0x00071F01
       //DE-Assert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071001;//0x00071000; //For External: 0x00070001; Near-End PCS: 0x00071001
      /*
      [11:8]: gt_reset_all = 4'hF
      [8:1]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b000 (External: 3'b000; Near-End PCS: 3'b001)
      */

		sleep(2);

    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

		
	// Wait for RX aligned 
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}	
    time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}
        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	

    // Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;
	// Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");

	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x12011201; //25G 25G
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x01050105; //10G 10G
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x12001200; //25G 25G
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x01040104; //10G 10G
	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_1);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_2);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_3);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	

    stat_match_flag_port0_25G=print_port0_statistics();
	stat_match_flag_port1_25G=print_port1_statistics();
	stat_match_flag_port2_10G=print_port2_statistics();
	stat_match_flag_port3_10G=print_port3_statistics();
    if ((stat_match_flag_port0_25G==1) && (stat_match_flag_port1_25G==1) && (stat_match_flag_port2_10G==1) && (stat_match_flag_port3_10G==1) )
    {
    	xil_printf( "INFO : 2x25GE 2x10GE Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : 2x25GE 2x10GE Test Fail          \n\r" );
    	return 0;
    }
	xil_printf("\n*******2x25GE 2x10GE Test Complete        \n\r");
	return 1;
	
}

int test_mixed()
{
	int stat_match_flag_port0=0;
	int stat_match_flag_port1=0;
	int stat_match_flag_port2=0;
	int stat_match_flag_port3=0;
	int time_out;
	uint32_t ReadData_10G;
    	int gt_lanes = 4;

	xil_printf("\n*******MIXED/CUSTOM Test START        \n\r");
	xil_printf("INFO : Start MRMAC Configuration\n\r");
 
 
 
 	
	// Reset and Config MRMAC
	xil_printf("INFO : Reset MRMAC \n\r");
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_1) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0xFFFFFFFF;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0xFFFFFFFF;


		
		
 
    xil_printf("INFO : SET CORE SPEED 1x25GE on Port-0\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_0)  = 0x40000261;
 		
	

	
		
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_0) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_0) = 0x00000C03;
    *(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_0) = 0x00000000;


	
		
		
 
    xil_printf("INFO : SET CORE SPEED 1x25GE on Port-1\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_1)  = 0x40000261;
 		
	

	
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_1) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_1) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_1) = 0x00000000;


	
		
		
 
    xil_printf("INFO : SET CORE SPEED 1x25GE on Port-2\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_2)  = 0x40000261;
 		
	

	 
	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_2) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_2) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_2) = 0x00000000;


	
		
		
 
    xil_printf("INFO : SET CORE SPEED 1x25GE on Port-3\n\r");	
	
         *(U32 *) (MRMAC_0_MODE_REG_3)  = 0x40000261;
 		
	

	 

	*(U32 *) (MRMAC_0_CONFIGURATION_RX_REG1_3) = 0x00000033;
	*(U32 *) (MRMAC_0_CONFIGURATION_TX_REG1_3) = 0x00000C03;
	*(U32 *) (MRMAC_0_FEC_CONFIGURATION_REG1_3) = 0x00000000;

	
	*(U32 *) (MRMAC_0_RESET_REG_0) = 0x00000000;
    *(U32 *) (MRMAC_0_RESET_REG_1) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_2) = 0x00000000;
	*(U32 *) (MRMAC_0_RESET_REG_3) = 0x00000000;
	//xil_printf("\nINFO : Switching GT Line Rate          \n\r\n\r" );

	//Apply GT Reset all
	xil_printf("INFO : Reset GT \n\r");
	//*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F00;
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071000;

	//Asert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071F01;//0x00071F00;  //For External: 0x00070F01; Near-End PCS: 0x00071F01
       //DE-Assert GT Reset all
	*(U32 *) (MRMAC_0_GT_LINERATE_RESET) = 0x00071001;//0x00071000; //For External: 0x00070001; Near-End PCS: 0x00071001
      /*
      [11:8]: gt_reset_all = 4'hF
      [8:1]: gt_line_rate = 8'h0
      [14:12]: gt_loopback = 3'b000 (External: 3'b000; Near-End PCS: 3'b001)
      */

		sleep(2);


    // Wait for GT MST Reset Done
        wait_gt_rxresetdone(gt_lanes);
    // Toggle GT RX datapath reset
        gt_rx_datapath_reset(gt_lanes);

	

	
	// Wait for RX aligned 
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_0);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}


	
	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_1);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}


	time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_2);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}

	
    time_out =0;
	do
	{
		*(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3) = 0xFFFFFFFF;
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_RX_STATUS_REG1_3);
		ReadData_10G =   (((1 << 3) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);	
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - RX ALIGN FAILED     (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - RX ALIGNED      (Stat RX Status  = 0x%x)\n\r", ReadData_10G);
	}
        // NOTE: If RX alignment failed, it is advised to toggle the GT RX datapath reset and check RX alignment again.	

    // Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;
	// Trigger PRBS
	xil_printf("INFO : Start PRBS Data \n\r");

 
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x12011201; //25G 25G

 
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x12011201; //25G 25G

 
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_LSB) = 0x12001200; //25G 25G

 
	*(U32 *) (MRMAC_0_GENMON_CTL_BASEADDR_MSB) = 0x12001200; //25G 25G

	xil_printf("INFO : Stop PRBS Data \n\r");
	// Apply PMtick
	xil_printf("INFO : Write Port 0 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_0) = 0x00000001;
	xil_printf("INFO : Write Port 1 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_1) = 0x00000001;
	xil_printf("INFO : Write Port 2 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_2) = 0x00000001;
	xil_printf("INFO : Write Port 3 TICK REG \n\r");
	*(U32 *) (MRMAC_0_TICK_REG_3) = 0x00000001;


	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_0);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 0 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 0 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}

	time_out =0;
	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_1);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 1 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 1 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;

	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_2);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 2 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 2 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	
	time_out =0;


	do
	{
		ReadData_10G = *(U32 *) (MRMAC_0_STAT_STATISTICS_READY_3);
		ReadData_10G =   (((1 << 2) - 1) & (ReadData_10G >> (1 - 1)));
		time_out = time_out + 1;
	}
	while (ReadData_10G!= 0x3 && time_out<1000);
	if (time_out>= 1000)
	{
		xil_printf("INFO : Port 3 - Statistics ready Failed (Status  = 0x%x)\n\r", ReadData_10G);
		return 0;
	} else {
		xil_printf("INFO : Port 3 - Statistics ready (Status  = 0x%x)\n\r", ReadData_10G);
	}	

        stat_match_flag_port0=print_port0_statistics();
	stat_match_flag_port1=print_port1_statistics();
	stat_match_flag_port2=print_port2_statistics();
	stat_match_flag_port3=print_port3_statistics();

    if ((stat_match_flag_port0==1) && (stat_match_flag_port1==1) && (stat_match_flag_port2==1) && (stat_match_flag_port3==1) )
    {
    	xil_printf( "INFO : Mixed/Custom Test Pass          \n\r" );
    } else {
    	xil_printf( "INFO : Mixed/Custom  Test Fail          \n\r" );
    	return 0;
    }



	xil_printf("\n*******Mixed/Custom Test Complete        \n\r");
	return 1;
	
}
int main()
{
    int test_status_100GE=0;
    int test_status_50GE=0;
    int test_status_40GE=0;
    int test_status_25GE=0;
    int test_status_10GE=0;
    int test_status_10GE_25GE = 0;
    int test_status_25GE_10GE = 0;
    int test_status_mixed = 0;

	uint32_t ReadData;
    xil_printf("\n\r*********************************************************************************\n\r");
	xil_printf("\t       MRMAC Validation on Versal Evaluation Board    \n\r");
	xil_printf( "*********************************************************************************\n\r\n\r");
	ReadData = *(U32 *)(MRMAC_0_CONFIGURATION_REVISION_REG);
    xil_printf("MRMAC Core Version is  = 0x%x\n\r", ReadData);
	
	
	test_status_25GE=test_25GE();
		sleep(1);
    if (test_status_25GE==1)
    {
		xil_printf( "Test PASS : All Test Completed Successfully \n\r" );
	} else {
		
		xil_printf( "Test FAILED : One or more Sub-Tests failed \n\r" );
	}
		
	

    return 0;
}


