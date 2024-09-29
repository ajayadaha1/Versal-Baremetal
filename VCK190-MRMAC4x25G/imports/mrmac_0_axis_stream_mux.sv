
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
module mrmac_0_axis_stream_mux
  (
   input        [3:0]       clk,
   input        [3:0]       reset,

   input        [2:0]       mux_sel,

   // S_AXIS
   input        [3:0]       s_tvalid,
   input        [7:0][63:0] s_tdata,
   input        [7:0][10:0] s_tkeep,
   input        [3:0]       s_tlast,
   output logic [3:0]       s_tready,

   // M_AXIS
   output logic [3:0]       m_tvalid,
   output logic [7:0][63:0] m_tdata,
   output logic [7:0][10:0] m_tkeep,
   output logic [3:0]       m_tlast,
   input        [3:0]       m_tready

   );

  ///////////////////////////////////////////////
  // Control logic and buffer
  ///////////////////////////////////////////////

  // decode m_tready and s_tvalid based on config
  logic [3:0] int_m_tready_c;
  logic [3:0] int_s_tvalid_c;

  always_comb begin
    case(mux_sel)
      3'b000: begin // 100G
        int_m_tready_c = {1'b0,{3{m_tready[0]}}};
        int_s_tvalid_c = {1'b0,{3{s_tvalid[0]}}};
      end

      3'b010: begin // 2x50G
        int_m_tready_c = {m_tready[2],m_tready[2],m_tready[0],m_tready[0]};
        int_s_tvalid_c = {s_tvalid[2],s_tvalid[2],s_tvalid[0],s_tvalid[0]};
      end

      3'b011: begin // 50G + 2x25G/10G
        int_m_tready_c = {m_tready[2],m_tready[2],m_tready[1],m_tready[0]};
        int_s_tvalid_c = {s_tvalid[2],s_tvalid[2],s_tvalid[1],s_tvalid[0]};
      end

      3'b100: begin // 10G/25G + 50G
        int_m_tready_c = {m_tready[3],m_tready[0],m_tready[0],m_tready[0]};
        int_s_tvalid_c = {s_tvalid[3],s_tvalid[0],s_tvalid[0],s_tvalid[0]};
      end

      3'b110: begin // 2x25G/10G + 50G
        int_m_tready_c = {m_tready[3],m_tready[2],m_tready[0],m_tready[0]};
        int_s_tvalid_c = {s_tvalid[3],s_tvalid[2],s_tvalid[0],s_tvalid[0]};
      end

      default: begin  // 4x25G/10G mode
        int_m_tready_c = m_tready;
        int_s_tvalid_c = s_tvalid;
      end
    endcase
  end

  generate
    genvar a;

    for (a=0; a<4; a=a+1) begin: axis_2stg_buff
      (* shreg_extract = "no" *) logic [1:0][63:0]                   tdata_buff0;
      (* shreg_extract = "no" *) logic [1:0][63:0]                   tdata_buff1;
      (* shreg_extract = "no" *) logic [1:0][10:0]                   tkeep_buff0;
      (* shreg_extract = "no" *) logic [1:0][10:0]                   tkeep_buff1;
      (* shreg_extract = "no" *) logic [1:0]                         tlast_buff;
      logic                               tready_buff;
      (* shreg_extract = "no" *) logic [1:0]                         tvalid_buff;

      always_ff @(posedge clk[a]) begin
        if(reset[a]) begin
          tdata_buff0         <= '0;
          tdata_buff1         <= '0;
          tkeep_buff0         <= '0;
          tkeep_buff1         <= '0;
          tlast_buff          <= '0;
          tready_buff         <= '0;
          tvalid_buff         <= '0;
        end
        else begin
          // slave side is ready when second stage of buffer
          // does not have data queued
          tready_buff         <= !tvalid_buff[1];

          // write data to buffer when slave side ready and
          // slave side valid
          if(int_s_tvalid_c[a] && !tvalid_buff[1]) begin
            if(tvalid_buff[0] && !int_m_tready_c[a]) begin
              // write second stage if master side has write pending
              tdata_buff0[1]  <= s_tdata[a*2];
              tkeep_buff0[1]  <= s_tkeep[a*2];
              tdata_buff1[1]  <= s_tdata[a*2 + 1];
              tkeep_buff1[1]  <= s_tkeep[a*2 + 1];
              tlast_buff[1]   <= s_tlast[a];
              tvalid_buff[1]  <= 1'b1;
            end
            else begin
              // else first stage gets new data
              tdata_buff0[0]  <= s_tdata[a*2];
              tkeep_buff0[0]  <= s_tkeep[a*2];
              tdata_buff1[0]  <= s_tdata[a*2 + 1];
              tkeep_buff1[0]  <= s_tkeep[a*2 + 1];
              tlast_buff[0]   <= s_tlast[a];
              tvalid_buff[1]  <= 1'b0;
              tvalid_buff[0]  <= 1'b1;
            end // else: !if(tvalid_buff[1])
          end // if (int_s_tvalid_c[a] & tready_buff)
          else if(int_m_tready_c[a]) begin
            if(tvalid_buff[1]) begin
              // shift buffer 2nd stage to 1st stage
              tvalid_buff[1]  <= 1'b0;
              tdata_buff0[0]  <= tdata_buff0[1];
              tkeep_buff0[0]  <= tkeep_buff0[1];
              tdata_buff1[0]  <= tdata_buff1[1];
              tkeep_buff1[0]  <= tkeep_buff1[1];
              tlast_buff[0]   <= tlast_buff[1];
              tvalid_buff[0]  <= 1'b1;
            end
            else begin
              // deassert master side valid
              // since no new data or queued data from
              // slave side
              tvalid_buff[0]  <= 1'b0;
            end // else: !if(tvalid_buff[1])
          end // else: !if(int_s_tvalid_c[a] & tready_buff)
        end // else: !if(reset)
      end // always_ff @ (posedge clk)

      // outputs
      always_comb begin
        s_tready[a]            = !tvalid_buff[1];
        m_tdata[a*2]           = tdata_buff0[0];
        m_tkeep[a*2]           = tkeep_buff0[0];
        m_tdata[a*2 + 1]       = tdata_buff1[0];
        m_tkeep[a*2 + 1]       = tkeep_buff1[0];
        m_tlast[a]             = tlast_buff[0];
        m_tvalid[a]            = tvalid_buff[0];
      end
    end // block: axis_2stg_buff

  endgenerate

endmodule


