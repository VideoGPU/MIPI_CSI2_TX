-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
-- Date        : Tue Apr 11 13:20:13 2023
-- Host        : MichaelDesktopLinux running 64-bit Ubuntu 18.04.6 LTS
-- Command     : write_vhdl -force -mode funcsim
--               /media/smishash/shonot/MIPI_CSI2_TX/XilinxIPs/clock_wizard/clock_wizard_sim_netlist.vhdl
-- Design      : clock_wizard
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity clock_wizard_clock_wizard_clk_wiz is
  port (
    clk_DPHY_100Mhz : out STD_LOGIC;
    clk_200MHz_deg90 : out STD_LOGIC;
    clk_50MHz : out STD_LOGIC;
    clk_10MHz : out STD_LOGIC;
    clk_200MHz_serdes : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    sys_clk_200MHz_in_p : in STD_LOGIC;
    sys_clk_200MHz_in_n : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of clock_wizard_clock_wizard_clk_wiz : entity is "clock_wizard_clk_wiz";
end clock_wizard_clock_wizard_clk_wiz;

architecture STRUCTURE of clock_wizard_clock_wizard_clk_wiz is
  signal clk_10MHz_clock_wizard : STD_LOGIC;
  signal clk_200MHz_deg90_clock_wizard : STD_LOGIC;
  signal clk_200MHz_serdes_clock_wizard : STD_LOGIC;
  signal clk_50MHz_clock_wizard : STD_LOGIC;
  signal clk_DPHY_100Mhz_clock_wizard : STD_LOGIC;
  signal clkfbout_buf_clock_wizard : STD_LOGIC;
  signal clkfbout_clock_wizard : STD_LOGIC;
  signal sys_clk_200MHz_in_clock_wizard : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKFBOUTB_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKFBSTOPPED_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKINSTOPPED_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKOUT0B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKOUT1B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKOUT2B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKOUT3B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKOUT5_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_CLKOUT6_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_DRDY_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_PSDONE_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcm_adv_inst_DO_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of clkf_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkin1_ibufgds : label is "PRIMITIVE";
  attribute CAPACITANCE : string;
  attribute CAPACITANCE of clkin1_ibufgds : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE : string;
  attribute IBUF_DELAY_VALUE of clkin1_ibufgds : label is "0";
  attribute IFD_DELAY_VALUE : string;
  attribute IFD_DELAY_VALUE of clkin1_ibufgds : label is "AUTO";
  attribute BOX_TYPE of clkout1_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout2_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout3_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout4_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout5_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of mmcm_adv_inst : label is "PRIMITIVE";
begin
clkf_buf: unisim.vcomponents.BUFG
     port map (
      I => clkfbout_clock_wizard,
      O => clkfbout_buf_clock_wizard
    );
clkin1_ibufgds: unisim.vcomponents.IBUFDS
    generic map(
      DQS_BIAS => "FALSE",
      IOSTANDARD => "DEFAULT"
    )
        port map (
      I => sys_clk_200MHz_in_p,
      IB => sys_clk_200MHz_in_n,
      O => sys_clk_200MHz_in_clock_wizard
    );
clkout1_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_DPHY_100Mhz_clock_wizard,
      O => clk_DPHY_100Mhz
    );
clkout2_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_200MHz_deg90_clock_wizard,
      O => clk_200MHz_deg90
    );
clkout3_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_50MHz_clock_wizard,
      O => clk_50MHz
    );
clkout4_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_10MHz_clock_wizard,
      O => clk_10MHz
    );
clkout5_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_200MHz_serdes_clock_wizard,
      O => clk_200MHz_serdes
    );
mmcm_adv_inst: unisim.vcomponents.MMCME2_ADV
    generic map(
      BANDWIDTH => "OPTIMIZED",
      CLKFBOUT_MULT_F => 4.000000,
      CLKFBOUT_PHASE => 0.000000,
      CLKFBOUT_USE_FINE_PS => false,
      CLKIN1_PERIOD => 5.000000,
      CLKIN2_PERIOD => 0.000000,
      CLKOUT0_DIVIDE_F => 8.000000,
      CLKOUT0_DUTY_CYCLE => 0.500000,
      CLKOUT0_PHASE => 0.000000,
      CLKOUT0_USE_FINE_PS => false,
      CLKOUT1_DIVIDE => 2,
      CLKOUT1_DUTY_CYCLE => 0.500000,
      CLKOUT1_PHASE => 90.000000,
      CLKOUT1_USE_FINE_PS => false,
      CLKOUT2_DIVIDE => 8,
      CLKOUT2_DUTY_CYCLE => 0.500000,
      CLKOUT2_PHASE => 0.000000,
      CLKOUT2_USE_FINE_PS => false,
      CLKOUT3_DIVIDE => 80,
      CLKOUT3_DUTY_CYCLE => 0.500000,
      CLKOUT3_PHASE => 0.000000,
      CLKOUT3_USE_FINE_PS => false,
      CLKOUT4_CASCADE => false,
      CLKOUT4_DIVIDE => 2,
      CLKOUT4_DUTY_CYCLE => 0.500000,
      CLKOUT4_PHASE => 0.000000,
      CLKOUT4_USE_FINE_PS => false,
      CLKOUT5_DIVIDE => 1,
      CLKOUT5_DUTY_CYCLE => 0.500000,
      CLKOUT5_PHASE => 0.000000,
      CLKOUT5_USE_FINE_PS => false,
      CLKOUT6_DIVIDE => 1,
      CLKOUT6_DUTY_CYCLE => 0.500000,
      CLKOUT6_PHASE => 0.000000,
      CLKOUT6_USE_FINE_PS => false,
      COMPENSATION => "ZHOLD",
      DIVCLK_DIVIDE => 1,
      IS_CLKINSEL_INVERTED => '0',
      IS_PSEN_INVERTED => '0',
      IS_PSINCDEC_INVERTED => '0',
      IS_PWRDWN_INVERTED => '0',
      IS_RST_INVERTED => '0',
      REF_JITTER1 => 0.010000,
      REF_JITTER2 => 0.010000,
      SS_EN => "FALSE",
      SS_MODE => "CENTER_HIGH",
      SS_MOD_PERIOD => 10000,
      STARTUP_WAIT => false
    )
        port map (
      CLKFBIN => clkfbout_buf_clock_wizard,
      CLKFBOUT => clkfbout_clock_wizard,
      CLKFBOUTB => NLW_mmcm_adv_inst_CLKFBOUTB_UNCONNECTED,
      CLKFBSTOPPED => NLW_mmcm_adv_inst_CLKFBSTOPPED_UNCONNECTED,
      CLKIN1 => sys_clk_200MHz_in_clock_wizard,
      CLKIN2 => '0',
      CLKINSEL => '1',
      CLKINSTOPPED => NLW_mmcm_adv_inst_CLKINSTOPPED_UNCONNECTED,
      CLKOUT0 => clk_DPHY_100Mhz_clock_wizard,
      CLKOUT0B => NLW_mmcm_adv_inst_CLKOUT0B_UNCONNECTED,
      CLKOUT1 => clk_200MHz_deg90_clock_wizard,
      CLKOUT1B => NLW_mmcm_adv_inst_CLKOUT1B_UNCONNECTED,
      CLKOUT2 => clk_50MHz_clock_wizard,
      CLKOUT2B => NLW_mmcm_adv_inst_CLKOUT2B_UNCONNECTED,
      CLKOUT3 => clk_10MHz_clock_wizard,
      CLKOUT3B => NLW_mmcm_adv_inst_CLKOUT3B_UNCONNECTED,
      CLKOUT4 => clk_200MHz_serdes_clock_wizard,
      CLKOUT5 => NLW_mmcm_adv_inst_CLKOUT5_UNCONNECTED,
      CLKOUT6 => NLW_mmcm_adv_inst_CLKOUT6_UNCONNECTED,
      DADDR(6 downto 0) => B"0000000",
      DCLK => '0',
      DEN => '0',
      DI(15 downto 0) => B"0000000000000000",
      DO(15 downto 0) => NLW_mmcm_adv_inst_DO_UNCONNECTED(15 downto 0),
      DRDY => NLW_mmcm_adv_inst_DRDY_UNCONNECTED,
      DWE => '0',
      LOCKED => locked,
      PSCLK => '0',
      PSDONE => NLW_mmcm_adv_inst_PSDONE_UNCONNECTED,
      PSEN => '0',
      PSINCDEC => '0',
      PWRDWN => '0',
      RST => reset
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity clock_wizard is
  port (
    clk_DPHY_100Mhz : out STD_LOGIC;
    clk_200MHz_deg90 : out STD_LOGIC;
    clk_50MHz : out STD_LOGIC;
    clk_10MHz : out STD_LOGIC;
    clk_200MHz_serdes : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    sys_clk_200MHz_in_p : in STD_LOGIC;
    sys_clk_200MHz_in_n : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of clock_wizard : entity is true;
end clock_wizard;

architecture STRUCTURE of clock_wizard is
begin
inst: entity work.clock_wizard_clock_wizard_clk_wiz
     port map (
      clk_10MHz => clk_10MHz,
      clk_200MHz_deg90 => clk_200MHz_deg90,
      clk_200MHz_serdes => clk_200MHz_serdes,
      clk_50MHz => clk_50MHz,
      clk_DPHY_100Mhz => clk_DPHY_100Mhz,
      locked => locked,
      reset => reset,
      sys_clk_200MHz_in_n => sys_clk_200MHz_in_n,
      sys_clk_200MHz_in_p => sys_clk_200MHz_in_p
    );
end STRUCTURE;
