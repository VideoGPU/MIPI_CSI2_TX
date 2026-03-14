----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/08/2017 09:57:14 AM
-- Design Name:
-- Module Name: fmc_mipi_top - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
-- Board-level glue: clocks, serdes, and pin mapping.
-- AXI/config + frame generation is implemented in mipi_tx_axi_ip.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity fmc_mipi_top is
  Generic (
    SERDES_DATA_WIDTH : integer := 8;
    ADD_DEBUG_OVERLAY : integer := 1
  );
  Port (
    sys_clk_p : in std_logic;
    sys_clk_n : in std_logic;
    sys_rst   : in std_logic;

    -- CSI related
    hs_c_d1_p : out std_logic;
    hs_c_d1_n : out std_logic;
    hs_c_d0_p : out std_logic;
    hs_c_d0_n : out std_logic;
    hs_c_d2_p : out std_logic;
    hs_c_d2_n : out std_logic;
    hs_c_d3_p : out std_logic;
    hs_c_d3_n : out std_logic;

    lp_c_d1_p : out std_logic;
    lp_c_d1_n : out std_logic;
    lp_c_d0_p : out std_logic;
    lp_c_d0_n : out std_logic;
    lp_c_d2_p : out std_logic;
    lp_c_d2_n : out std_logic;
    lp_c_d3_p : out std_logic;
    lp_c_d3_n : out std_logic;

    lp_c_clk_p : out std_logic;
    lp_c_clk_n : out std_logic;
    hs_c_clk_p : out std_logic;
    hs_c_clk_n : out std_logic;

    -- AXI4-Lite control interface (32-bit data)
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    s_axi_awaddr  : in  std_logic_vector(7 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in  std_logic_vector(31 downto 0);
    s_axi_wstrb   : in  std_logic_vector(3 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;
    s_axi_araddr  : in  std_logic_vector(7 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;
    irq           : out std_logic
  );
end fmc_mipi_top;

architecture Behavioral of fmc_mipi_top is

COMPONENT clock_wizard is
  Port (
    sys_clk_200MHz_in_p : in std_logic;
    sys_clk_200MHz_in_n : in std_logic;
    clk_DPHY_100Mhz     : out std_logic;
    clk_200MHz_deg90    : out std_logic;
    clk_50MHz           : out std_logic;
    clk_10MHz           : out std_logic;
    clk_200MHz_serdes   : out std_logic;
    reset               : in std_logic;
    locked              : out std_logic
  );
END COMPONENT;

COMPONENT selectio_serdes is
  Port (
    data_out_from_device : in STD_LOGIC_VECTOR (15 downto 0);
    data_out_to_pins_p   : out STD_LOGIC_VECTOR (1 downto 0);
    data_out_to_pins_n   : out STD_LOGIC_VECTOR (1 downto 0);
    clk_in               : in STD_LOGIC;
    clk_div_in           : in STD_LOGIC;
    clock_enable         : in STD_LOGIC;
    io_reset             : in STD_LOGIC
  );
END COMPONENT;

COMPONENT mipi_tx_axi_ip is
  Generic (
    PIXELS_PER_LINE_MAX : integer := 3240;
    ADD_DEBUG_OVERLAY   : integer := 1
  );
  Port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    clk_DPHY_100Mhz : in  std_logic;
    s_axi_aclk      : in  std_logic;
    s_axi_aresetn   : in  std_logic;
    s_axi_awaddr    : in  std_logic_vector(7 downto 0);
    s_axi_awvalid   : in  std_logic;
    s_axi_awready   : out std_logic;
    s_axi_wdata     : in  std_logic_vector(31 downto 0);
    s_axi_wstrb     : in  std_logic_vector(3 downto 0);
    s_axi_wvalid    : in  std_logic;
    s_axi_wready    : out std_logic;
    s_axi_bresp     : out std_logic_vector(1 downto 0);
    s_axi_bvalid    : out std_logic;
    s_axi_bready    : in  std_logic;
    s_axi_araddr    : in  std_logic_vector(7 downto 0);
    s_axi_arvalid   : in  std_logic;
    s_axi_arready   : out std_logic;
    s_axi_rdata     : out std_logic_vector(31 downto 0);
    s_axi_rresp     : out std_logic_vector(1 downto 0);
    s_axi_rvalid    : out std_logic;
    s_axi_rready    : in  std_logic;
    irq             : out std_logic;
    csi_hs_data_1_out : out std_logic_vector(7 downto 0);
    csi_hs_data_2_out : out std_logic_vector(7 downto 0);
    csi_hs_data_3_out : out std_logic_vector(7 downto 0);
    csi_hs_data_4_out : out std_logic_vector(7 downto 0);
    lp_lanes          : out std_logic_vector(1 downto 0);
    lp_clk_lane       : out std_logic_vector(1 downto 0);
    hs_active         : out std_logic;
    hs_data_valid     : out std_logic;
    csi_clk_hs_active : out std_logic
  );
END COMPONENT;

signal clk_DPHY_100Mhz, clk_50MHz, clk_200MHz_deg90, clk_10MHz, clk_200MHz_serdes : std_logic;
signal locked, rst : std_logic;

signal hs_active, hs_data_valid, csi_clk_hs_active : std_logic;
signal csi_hs_data_1_out, csi_hs_data_2_out, csi_hs_data_3_out, csi_hs_data_4_out : std_logic_vector(7 downto 0);
signal lp_lanes, lp_clk_lane : std_logic_vector(1 downto 0);

signal parallel_data_to_serdes : STD_LOGIC_VECTOR(31 downto 0);

signal data_out_to_pins_p_01, data_out_to_pins_n_01 : STD_LOGIC_VECTOR(1 downto 0);
signal data_out_from_device_01 : STD_LOGIC_VECTOR(15 downto 0);
signal data_out_to_pins_p_23, data_out_to_pins_n_23 : STD_LOGIC_VECTOR(1 downto 0);
signal data_out_from_device_23 : STD_LOGIC_VECTOR(15 downto 0);

begin

clock_network : clock_wizard
  PORT MAP (
    sys_clk_200MHz_in_p => sys_clk_p,
    sys_clk_200MHz_in_n => sys_clk_n,
    clk_DPHY_100Mhz     => clk_DPHY_100Mhz,
    clk_200MHz_deg90    => clk_200MHz_deg90,
    clk_50MHz           => clk_50MHz,
    clk_10MHz           => clk_10MHz,
    clk_200MHz_serdes   => clk_200MHz_serdes,
    reset               => sys_rst,
    locked              => locked
  );

rst <= not locked;

mipi_axi_core : mipi_tx_axi_ip
  GENERIC MAP (
    PIXELS_PER_LINE_MAX => 3240,
    ADD_DEBUG_OVERLAY   => ADD_DEBUG_OVERLAY
  )
  PORT MAP (
    clk             => clk_50MHz,
    rst             => rst,
    clk_DPHY_100Mhz => clk_DPHY_100Mhz,
    s_axi_aclk      => s_axi_aclk,
    s_axi_aresetn   => s_axi_aresetn,
    s_axi_awaddr    => s_axi_awaddr,
    s_axi_awvalid   => s_axi_awvalid,
    s_axi_awready   => s_axi_awready,
    s_axi_wdata     => s_axi_wdata,
    s_axi_wstrb     => s_axi_wstrb,
    s_axi_wvalid    => s_axi_wvalid,
    s_axi_wready    => s_axi_wready,
    s_axi_bresp     => s_axi_bresp,
    s_axi_bvalid    => s_axi_bvalid,
    s_axi_bready    => s_axi_bready,
    s_axi_araddr    => s_axi_araddr,
    s_axi_arvalid   => s_axi_arvalid,
    s_axi_arready   => s_axi_arready,
    s_axi_rdata     => s_axi_rdata,
    s_axi_rresp     => s_axi_rresp,
    s_axi_rvalid    => s_axi_rvalid,
    s_axi_rready    => s_axi_rready,
    irq             => irq,
    csi_hs_data_1_out => csi_hs_data_1_out,
    csi_hs_data_2_out => csi_hs_data_2_out,
    csi_hs_data_3_out => csi_hs_data_3_out,
    csi_hs_data_4_out => csi_hs_data_4_out,
    lp_lanes          => lp_lanes,
    lp_clk_lane       => lp_clk_lane,
    hs_active         => hs_active,
    hs_data_valid     => hs_data_valid,
    csi_clk_hs_active => csi_clk_hs_active
  );

inst_selectio : selectio_serdes
  PORT MAP (
    data_out_from_device => data_out_from_device_01,
    data_out_to_pins_p   => data_out_to_pins_p_01,
    data_out_to_pins_n   => data_out_to_pins_n_01,
    clk_in               => clk_200MHz_serdes,
    clk_div_in           => clk_50MHz,
    clock_enable         => '1',
    io_reset             => rst
  );

inst_selectio_23 : selectio_serdes
  PORT MAP (
    data_out_from_device => data_out_from_device_23,
    data_out_to_pins_p   => data_out_to_pins_p_23,
    data_out_to_pins_n   => data_out_to_pins_n_23,
    clk_in               => clk_200MHz_serdes,
    clk_div_in           => clk_50MHz,
    clock_enable         => '1',
    io_reset             => rst
  );

-- Serializer lane packing for data lanes 0/1.
data_out_from_device_01(1)  <= parallel_data_to_serdes(0);
data_out_from_device_01(3)  <= parallel_data_to_serdes(1);
data_out_from_device_01(5)  <= parallel_data_to_serdes(2);
data_out_from_device_01(7)  <= parallel_data_to_serdes(3);
data_out_from_device_01(9)  <= parallel_data_to_serdes(4);
data_out_from_device_01(11) <= parallel_data_to_serdes(5);
data_out_from_device_01(13) <= parallel_data_to_serdes(6);
data_out_from_device_01(15) <= parallel_data_to_serdes(7);
data_out_from_device_01(0)  <= parallel_data_to_serdes(8);
data_out_from_device_01(2)  <= parallel_data_to_serdes(9);
data_out_from_device_01(4)  <= parallel_data_to_serdes(10);
data_out_from_device_01(6)  <= parallel_data_to_serdes(11);
data_out_from_device_01(8)  <= parallel_data_to_serdes(12);
data_out_from_device_01(10) <= parallel_data_to_serdes(13);
data_out_from_device_01(12) <= parallel_data_to_serdes(14);
data_out_from_device_01(14) <= parallel_data_to_serdes(15);

-- Serializer lane packing for data lanes 2/3.
data_out_from_device_23(1)  <= parallel_data_to_serdes(16);
data_out_from_device_23(3)  <= parallel_data_to_serdes(17);
data_out_from_device_23(5)  <= parallel_data_to_serdes(18);
data_out_from_device_23(7)  <= parallel_data_to_serdes(19);
data_out_from_device_23(9)  <= parallel_data_to_serdes(20);
data_out_from_device_23(11) <= parallel_data_to_serdes(21);
data_out_from_device_23(13) <= parallel_data_to_serdes(22);
data_out_from_device_23(15) <= parallel_data_to_serdes(23);
data_out_from_device_23(0)  <= parallel_data_to_serdes(24);
data_out_from_device_23(2)  <= parallel_data_to_serdes(25);
data_out_from_device_23(4)  <= parallel_data_to_serdes(26);
data_out_from_device_23(6)  <= parallel_data_to_serdes(27);
data_out_from_device_23(8)  <= parallel_data_to_serdes(28);
data_out_from_device_23(10) <= parallel_data_to_serdes(29);
data_out_from_device_23(12) <= parallel_data_to_serdes(30);
data_out_from_device_23(14) <= parallel_data_to_serdes(31);

parallel_data_to_serdes(7 downto 0)   <= csi_hs_data_1_out;
parallel_data_to_serdes(15 downto 8)  <= csi_hs_data_2_out;
parallel_data_to_serdes(23 downto 16) <= csi_hs_data_3_out;
parallel_data_to_serdes(31 downto 24) <= csi_hs_data_4_out;

hs_c_d0_p <= data_out_to_pins_p_01(1);
hs_c_d0_n <= data_out_to_pins_n_01(1);
hs_c_d1_p <= data_out_to_pins_p_01(0);
hs_c_d1_n <= data_out_to_pins_n_01(0);
hs_c_d2_p <= data_out_to_pins_p_23(1);
hs_c_d2_n <= data_out_to_pins_n_23(1);
hs_c_d3_p <= data_out_to_pins_p_23(0);
hs_c_d3_n <= data_out_to_pins_n_23(0);

out_HS_C_clk : unisim.vcomponents.OBUFDS
  PORT MAP (
    I  => clk_200MHz_deg90,
    O  => hs_c_clk_p,
    OB => hs_c_clk_n
  );

lp_c_d0_p  <= lp_lanes(1);
lp_c_d0_n  <= lp_lanes(0);
lp_c_d1_p  <= lp_lanes(1);
lp_c_d1_n  <= lp_lanes(0);
lp_c_d2_p  <= lp_lanes(1);
lp_c_d2_n  <= lp_lanes(0);
lp_c_d3_p  <= lp_lanes(1);
lp_c_d3_n  <= lp_lanes(0);
lp_c_clk_p <= lp_clk_lane(1);
lp_c_clk_n <= lp_clk_lane(0);

end Behavioral;
