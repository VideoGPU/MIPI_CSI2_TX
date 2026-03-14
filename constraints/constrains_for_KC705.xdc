# Core clocks and reset
set_property PACKAGE_PIN AB7 [get_ports sys_rst]
set_property IOSTANDARD LVCMOS15 [get_ports sys_rst]

set_property PACKAGE_PIN AD12 [get_ports sys_clk_p]
set_property PACKAGE_PIN AD11 [get_ports sys_clk_n]
set_property IOSTANDARD LVDS [get_ports sys_clk_p]
set_property IOSTANDARD LVDS [get_ports sys_clk_n]

# MIPI CSI C high-speed differential outputs
set_property PACKAGE_PIN C25 [get_ports hs_c_clk_p]
set_property PACKAGE_PIN E28 [get_ports hs_c_d0_p]
set_property PACKAGE_PIN G28 [get_ports hs_c_d1_p]

set_property IOSTANDARD BLVDS_25 [get_ports hs_c_clk_p]
set_property IOSTANDARD BLVDS_25 [get_ports hs_c_clk_n]
set_property IOSTANDARD BLVDS_25 [get_ports hs_c_d0_p]
set_property IOSTANDARD BLVDS_25 [get_ports hs_c_d0_n]
set_property IOSTANDARD BLVDS_25 [get_ports hs_c_d1_p]
set_property IOSTANDARD BLVDS_25 [get_ports hs_c_d1_n]

# MIPI CSI C low-power outputs
set_property PACKAGE_PIN G18 [get_ports lp_c_clk_p]
set_property PACKAGE_PIN F18 [get_ports lp_c_clk_n]
set_property PACKAGE_PIN C24 [get_ports lp_c_d0_p]
set_property PACKAGE_PIN B24 [get_ports lp_c_d0_n]
set_property PACKAGE_PIN G27 [get_ports lp_c_d1_p]
set_property PACKAGE_PIN F27 [get_ports lp_c_d1_n]

set_property IOSTANDARD LVCMOS25 [get_ports lp_c_clk_p]
set_property IOSTANDARD LVCMOS25 [get_ports lp_c_clk_n]
set_property IOSTANDARD LVCMOS25 [get_ports lp_c_d0_p]
set_property IOSTANDARD LVCMOS25 [get_ports lp_c_d0_n]
set_property IOSTANDARD LVCMOS25 [get_ports lp_c_d1_p]
set_property IOSTANDARD LVCMOS25 [get_ports lp_c_d1_n]
