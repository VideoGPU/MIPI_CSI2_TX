
-- 
-- (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
------------------------------------------------------------------------------
-- User entered comments
------------------------------------------------------------------------------
-- None
--
------------------------------------------------------------------------------
--  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
--   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
------------------------------------------------------------------------------
-- clk_DPHY_100Mhz___100.000______0.000______50.0______114.523_____97.786
-- clk_200MHz_deg90___400.000_____90.000______50.0_______87.396_____97.786
-- clk_50MHz___100.000______0.000______50.0______114.523_____97.786
-- clk_10MHz____10.000______0.000______50.0______181.846_____97.786
-- clk_200MHz_serdes___400.000______0.000______50.0_______87.396_____97.786
--
------------------------------------------------------------------------------
-- Input Clock   Freq (MHz)    Input Jitter (UI)
------------------------------------------------------------------------------
-- __primary_________200.000____________0.010


-- The following code must appear in the VHDL architecture header:
------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
component clock_wizard
port
 (-- Clock in ports
  -- Clock out ports
  clk_DPHY_100Mhz          : out    std_logic;
  clk_200MHz_deg90          : out    std_logic;
  clk_50MHz          : out    std_logic;
  clk_10MHz          : out    std_logic;
  clk_200MHz_serdes          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  sys_clk_200MHz_in_p         : in     std_logic;
  sys_clk_200MHz_in_n         : in     std_logic
 );
end component;

-- COMP_TAG_END ------ End COMPONENT Declaration ------------
-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : clock_wizard
   port map ( 
  -- Clock out ports  
   clk_DPHY_100Mhz => clk_DPHY_100Mhz,
   clk_200MHz_deg90 => clk_200MHz_deg90,
   clk_50MHz => clk_50MHz,
   clk_10MHz => clk_10MHz,
   clk_200MHz_serdes => clk_200MHz_serdes,
  -- Status and control signals                
   reset => reset,
   locked => locked,
   -- Clock in ports
   sys_clk_200MHz_in_p => sys_clk_200MHz_in_p,
   sys_clk_200MHz_in_n => sys_clk_200MHz_in_n
 );
-- INST_TAG_END ------ End INSTANTIATION Template ------------
