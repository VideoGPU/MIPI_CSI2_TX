-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
-- Date        : Tue Apr 11 13:20:13 2023
-- Host        : MichaelDesktopLinux running 64-bit Ubuntu 18.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /media/smishash/shonot/MIPI_CSI2_TX/XilinxIPs/clock_wizard/clock_wizard_stub.vhdl
-- Design      : clock_wizard
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_wizard is
  Port ( 
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

end clock_wizard;

architecture stub of clock_wizard is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_DPHY_100Mhz,clk_200MHz_deg90,clk_50MHz,clk_10MHz,clk_200MHz_serdes,reset,locked,sys_clk_200MHz_in_p,sys_clk_200MHz_in_n";
begin
end;
