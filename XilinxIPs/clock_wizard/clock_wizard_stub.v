// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
// Date        : Tue Apr 11 13:20:12 2023
// Host        : MichaelDesktopLinux running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /media/smishash/shonot/MIPI_CSI2_TX/XilinxIPs/clock_wizard/clock_wizard_stub.v
// Design      : clock_wizard
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clock_wizard(clk_DPHY_100Mhz, clk_200MHz_deg90, clk_50MHz, 
  clk_10MHz, clk_200MHz_serdes, reset, locked, sys_clk_200MHz_in_p, sys_clk_200MHz_in_n)
/* synthesis syn_black_box black_box_pad_pin="clk_DPHY_100Mhz,clk_200MHz_deg90,clk_50MHz,clk_10MHz,clk_200MHz_serdes,reset,locked,sys_clk_200MHz_in_p,sys_clk_200MHz_in_n" */;
  output clk_DPHY_100Mhz;
  output clk_200MHz_deg90;
  output clk_50MHz;
  output clk_10MHz;
  output clk_200MHz_serdes;
  input reset;
  output locked;
  input sys_clk_200MHz_in_p;
  input sys_clk_200MHz_in_n;
endmodule
