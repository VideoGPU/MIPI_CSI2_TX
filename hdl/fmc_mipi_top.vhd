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
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity fmc_mipi_top is     Generic (	
        N_MIPI_LANES : integer := 2;
        SERDES_DATA_WIDTH : integer := 8;
        ADD_DEBUG_OVERLAY : integer := 1 --If 1 , adds a vertical line overly across the frame, to indicate line numbers on display
    );
   Port ( 
   sys_clk_p : in std_logic;  --AD12 SYSCLK_P;
   sys_clk_n : in std_logic;  --AD11 SYSCLK_N;
   sys_rst : in std_logic; -- AB7 use CPU_RESET button
   
   --start of V2 board, in the commments pinout for KC705 board, HPC connector
                                --FMC pin number, HPC name, KC705 FPGA pin
   monitor_1p2v : in std_logic; --H8, HPC_LA02_N; H25
   
   switch_data_lanes_vadj  : out std_logic; --G12, HPC_LA08_P; E29
   switch_clock_lanes_vadj : out std_logic; --G13, HPC_LA08_N; E30
   
   monitor_1p8v : in std_logic; --G27, HPC_LA25_P; G17
   cam0_rst     : in std_logic; --G28, HPC_LA25_N; F17
   
   cam0_pwr     : in std_logic;  --G30, HPC_LA29_P; C17
   
   cam0_mclk    : in std_logic;  --G33, HPC_LA31_P; G22
   
   monitor_2p8v : in std_logic;  --D8, HPC_LA01_CC_P; D26                           
   monitor_3p3v : in std_logic;  --D9, HPC_LA01_CC_N; C26
   
   en_mipi_out_data_vadj  :  out std_logic := '1'; --D14, HPC_LA09_P; B30 --CSI C
   en_mipi_out_clock_vadj :  out std_logic := '0'; --D15, HPC_LA09_N; A30 --CSI D
   
   enn_jt_gpio_input : out std_logic := '1'; --D17, HPC_LA13_P; A25
   
   gpio17_out : out std_logic := '0'; --D26, HPC_LA26_P; B18
   gpio9_out  : out std_logic := '0'; --D27, HPC_LA26_N; A18
   
   --CSI related
   
    hs_c_d1_p  : out std_logic; --H10, HPC_LA04_P; G28
    hs_c_d1_n  : out std_logic; --H11, HPC_LA04_N; F28

    hs_c_d0_p  : out std_logic; --H13, HPC_LA07_P; E28
    hs_c_d0_n  : out std_logic; --H14, HPC_LA07_N; D28

    lp_c_d1_p  : out std_logic; --H16, HPC_LA11_P; G27
    lp_c_d1_n  : out std_logic; --H17, HPC_LA11_N; F27

    lp_c_d0_p  : out std_logic; --H19, HPC_LA15_P; C24
    lp_c_d0_n  : out std_logic; --H20, HPC_LA15_N; B24

    lp_c_clk_p : out std_logic; --H22, HPC_LA19_P; G18
    lp_c_clk_n : out std_logic; --H23, HPC_LA19_N; F18
 
    hs_d_d1_p  : out std_logic; --H31, HPC_LA28_P; D16
    hs_d_d1_n  : out std_logic; --H32, HPC_LA28_N; C16

    hs_d_d0_p  : out std_logic; --H34, HPC_LA30_P; D22
    hs_d_d0_n  : out std_logic; --H35, HPC_LA30_N; C22

    hs_d_clk_p : out std_logic; --H37, HPC_LA32_P; D21
    hs_d_clk_n : out std_logic; --H38, HPC_LA32_N; C21
   
   
    hs_c_clk_p : out std_logic; --G6, HPC_LA00_CC_P; C25
    hs_c_clk_n : out std_logic; --G7, HPC_LA00_CC_N; B25

    lp_d_d1_p  : out std_logic; --G15, HPC_LA12_P; C29
    lp_d_d1_n  : out std_logic; --G16, HPC_LA12_N; B29

    lp_d_d0_p  : out std_logic; --G18, HPC_LA16_P; B27
    lp_d_d0_n  : out std_logic; --G19, HPC_LA16_N; A27

    lp_d_clk_p : out std_logic; --G21, HPC_LA20_P; E19
    lp_d_clk_n : out std_logic; --G22, HPC_LA20_N; D19
     
   
   --debug IO              
   leds_debug : out std_logic_vector(7 downto 0) := (others => '1'); --debug
   dbg_io_1   : out std_logic; --G34,HPC_LA31_N; F22
   dbg_io_2   : out std_logic; --G37,HPC_LA33_N; H22
   dbg_io_3   : out std_logic; --G36,HPC_LA33_P; H21
   GPIO_SW_N  : in std_logic; -- AA12   up button
   GPIO_SW_E  : in std_logic; -- AG5    right button 
   GPIO_SW_S  : in std_logic; -- AB12   down button
   GPIO_SW_W  : in std_logic; -- AC6    left button
  GPIO_SW_C  : in std_logic; -- G12    Center button

  --AXI4-Lite control interface (32-bit data)
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


COMPONENT   clock_wizard is
  Port (
    --Clock in ports
    sys_clk_200MHz_in_p : in std_logic;
    sys_clk_200MHz_in_n : in std_logic;
    --Clock out ports
    clk_DPHY_100Mhz          : out std_logic;
    clk_200MHz_deg90     : out std_logic;
    clk_50MHz         : out std_logic;
    clk_10MHz           : out std_logic;
    clk_200MHz_serdes       : out std_logic;
    --Status and control signals
    reset              : in std_logic;
    locked             : out std_logic
    );
END COMPONENT;

COMPONENT send_single_frame is
    Generic (	
        N_MIPI_LANES : integer := N_MIPI_LANES;
    PIXELS_PER_LINE_MAX : integer := 3240;
        ADD_DEBUG_OVERLAY : integer := ADD_DEBUG_OVERLAY
    );
    Port (
        clk : in std_logic; --data in/out clock HS clock, ~100 MHZ
        rst : in  std_logic;
        clk_DPHY_100Mhz : in std_logic;
        send_frame : in std_logic; --triggers frame sending, one clock cycle is enough  
    stop_frame : in std_logic;
    cfg_pixels_per_line : in std_logic_vector(15 downto 0);
    cfg_n_lines : in std_logic_vector(15 downto 0);
    cfg_vc_num : in std_logic_vector(1 downto 0);
    cfg_data_type : in std_logic_vector(5 downto 0);
    cfg_frame_end_word : in std_logic_vector(15 downto 0);
    cfg_tLP_SOT_Delay_clock : in std_logic_vector(15 downto 0);
    cfg_tLPX_Delay_clock : in std_logic_vector(15 downto 0);
    cfg_tLP_SOT_Delay_data : in std_logic_vector(15 downto 0);
    cfg_tLPX_Delay_data : in std_logic_vector(15 downto 0);
    cfg_tLP_SOT_short_packet_delay : in std_logic_vector(15 downto 0);
    cfg_tHSprepare : in std_logic_vector(15 downto 0);
    cfg_tHSzero : in std_logic_vector(15 downto 0);
    cfg_tHSexit : in std_logic_vector(15 downto 0);
    cfg_debug_overlay_en : in std_logic;
        frame_done : out std_logic; --indicates that frame was sent successfully
        hs_active : out std_logic; -- ON when entrering HS mode, it is a good time to switch mixer lines and activate HS clock
        hs_data_valid : out std_logic; -- when ON, csi_hs_data_out is valid to transmit 
        csi_hs_data_1_out : out std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializersignal
        csi_hs_data_2_out : out std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializersignal 
        csi_hs_data_3_out : out std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializersignal
        csi_hs_data_4_out : out std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializersignal
        lp_lanes : out std_logic_vector(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line        
        lp_clk_lane  : out std_logic_vector(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line
        csi_clk_hs_active : out std_logic -- ON when entrering HS mode in clock lane, it is a good time to switch mixer lines and activate HS 
    );
END COMPONENT;

         

COMPONENT selectio_serdes is
  port (
    data_out_from_device : in STD_LOGIC_VECTOR ( 15 downto 0 );
    data_out_to_pins_p : out STD_LOGIC_VECTOR ( 1 downto 0 );
    data_out_to_pins_n : out STD_LOGIC_VECTOR ( 1 downto 0 );
    clk_in : in STD_LOGIC;
    clk_div_in : in STD_LOGIC;
    clock_enable : in STD_LOGIC;
    io_reset : in STD_LOGIC
  );
END COMPONENT;  


constant COUNTER_WIDTH : integer := 11; --max 2047*10ns(100Mhz clock) = 204.7 us delay
constant SLOW_COUNTER_WIDTH: integer := 11;
COMPONENT counter is GENERIC(n: natural :=COUNTER_WIDTH);
PORT(clk :	in std_logic;
	rst:	in std_logic;
	counter_out :	out std_logic_vector(COUNTER_WIDTH-1 downto 0)
);
END COMPONENT;


signal clk_DPHY_100Mhz,clk_50MHz,clk_200MHz_deg90,clk_10MHz,clk_200MHz_serdes : std_logic;
signal locked,rst : std_logic;
signal hs_clk,hs_d0,hs_d1,hs_d2,hs_d3 : std_logic;


signal send_frame         :  std_logic := '0'; --triggers frame sending, one clock cycle is enough  
signal frame_done         : std_logic;
signal hs_active          :  std_logic; -- ON when entrering HS mode, it is a good time to switch mixer lines and activate HS clock
signal csi_clk_hs_active  :  std_logic; -- ON when entrering HS mode in clock lane, it is a good time to switch mixer lines and activate HS 
signal hs_data_valid      :  std_logic; -- when ON, csi_hs_data_out is valid to transmit  

signal csi_hs_data_1_out,csi_hs_data_2_out,csi_hs_data_3_out,csi_hs_data_4_out : std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializer
signal lp_lanes     :  std_logic_vector(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line 
signal lp_clk_lane  :  std_logic_vector(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line


signal counter_value :  STD_LOGIC_VECTOR (COUNTER_WIDTH - 1 downto 0) := (others => '0');
signal slow_counter_value :  STD_LOGIC_VECTOR (COUNTER_WIDTH - 1 downto 0) := (others => '0');
signal clk_slow_counter :std_logic;

--For serdes
signal parallel_data_to_serdes :  STD_LOGIC_VECTOR ( 31 downto 0 ); --parallel data in

--For SelectIO
signal data_out_to_pins_p : STD_LOGIC_VECTOR ( 1 downto 0 );
signal data_out_to_pins_n :  STD_LOGIC_VECTOR ( 1 downto 0 );
signal data_out_from_device : STD_LOGIC_VECTOR (15 downto 0 );

--AXI control/status
constant REG_CONTROL_ADDR                 : std_logic_vector(7 downto 0) := x"00";
constant REG_STATUS_ADDR                  : std_logic_vector(7 downto 0) := x"04";
constant REG_PIXELS_PER_LINE_ADDR         : std_logic_vector(7 downto 0) := x"10";
constant REG_N_LINES_ADDR                 : std_logic_vector(7 downto 0) := x"14";
constant REG_TYPE_VC_ADDR                 : std_logic_vector(7 downto 0) := x"18";
constant REG_FRAME_END_WORD_ADDR          : std_logic_vector(7 downto 0) := x"1C";
constant REG_TLP_SOT_DELAY_CLOCK_ADDR     : std_logic_vector(7 downto 0) := x"20";
constant REG_TLPX_DELAY_CLOCK_ADDR        : std_logic_vector(7 downto 0) := x"24";
constant REG_TLP_SOT_DELAY_DATA_ADDR      : std_logic_vector(7 downto 0) := x"28";
constant REG_TLPX_DELAY_DATA_ADDR         : std_logic_vector(7 downto 0) := x"2C";
constant REG_TLP_SOT_SHORT_DELAY_ADDR     : std_logic_vector(7 downto 0) := x"30";
constant REG_THS_PREPARE_ADDR             : std_logic_vector(7 downto 0) := x"34";
constant REG_THS_ZERO_ADDR                : std_logic_vector(7 downto 0) := x"38";
constant REG_THS_EXIT_ADDR                : std_logic_vector(7 downto 0) := x"3C";

signal axi_awready_reg : std_logic := '0';
signal axi_wready_reg  : std_logic := '0';
signal axi_bvalid_reg  : std_logic := '0';
signal axi_arready_reg : std_logic := '0';
signal axi_rvalid_reg  : std_logic := '0';
signal axi_bresp_reg   : std_logic_vector(1 downto 0) := (others => '0');
signal axi_rresp_reg   : std_logic_vector(1 downto 0) := (others => '0');
signal axi_rdata_reg   : std_logic_vector(31 downto 0) := (others => '0');

signal reg_control            : std_logic_vector(31 downto 0) := x"00000028"; --legacy_trig_en=1, debug_overlay_en=1
signal reg_pixels_per_line    : std_logic_vector(15 downto 0) := x"0CA8"; --3240
signal reg_n_lines            : std_logic_vector(15 downto 0) := x"0798"; --1944
signal reg_type_vc            : std_logic_vector(31 downto 0) := x"0000002B"; --RAW10, VC=0
signal reg_frame_end_word     : std_logic_vector(15 downto 0) := x"1753";
signal reg_tlp_sot_delay_clk  : std_logic_vector(15 downto 0) := x"002A"; --42
signal reg_tlpx_delay_clk     : std_logic_vector(15 downto 0) := x"000A"; --10
signal reg_tlp_sot_delay_data : std_logic_vector(15 downto 0) := x"00BB"; --187
signal reg_tlpx_delay_data    : std_logic_vector(15 downto 0) := x"000A"; --10
signal reg_tlp_sot_short      : std_logic_vector(15 downto 0) := x"030F"; --783
signal reg_ths_prepare        : std_logic_vector(15 downto 0) := x"000F"; --15
signal reg_ths_zero           : std_logic_vector(15 downto 0) := x"0050"; --80
signal reg_ths_exit           : std_logic_vector(15 downto 0) := x"000A"; --10

--CDC (AXI clock -> clk_50MHz) and active runtime config snapshot
signal cfg_control_meta, cfg_control_sync, cfg_control_active : std_logic_vector(31 downto 0) := x"00000028";
signal cfg_pixels_per_line_meta, cfg_pixels_per_line_sync, cfg_pixels_per_line_active : std_logic_vector(15 downto 0) := x"0CA8";
signal cfg_n_lines_meta, cfg_n_lines_sync, cfg_n_lines_active : std_logic_vector(15 downto 0) := x"0798";
signal cfg_type_vc_meta, cfg_type_vc_sync, cfg_type_vc_active : std_logic_vector(31 downto 0) := x"0000002B";
signal cfg_frame_end_word_meta, cfg_frame_end_word_sync, cfg_frame_end_word_active : std_logic_vector(15 downto 0) := x"1753";
signal cfg_tlp_sot_delay_clk_meta, cfg_tlp_sot_delay_clk_sync, cfg_tlp_sot_delay_clk_active : std_logic_vector(15 downto 0) := x"002A";
signal cfg_tlpx_delay_clk_meta, cfg_tlpx_delay_clk_sync, cfg_tlpx_delay_clk_active : std_logic_vector(15 downto 0) := x"000A";
signal cfg_tlp_sot_delay_data_meta, cfg_tlp_sot_delay_data_sync, cfg_tlp_sot_delay_data_active : std_logic_vector(15 downto 0) := x"00BB";
signal cfg_tlpx_delay_data_meta, cfg_tlpx_delay_data_sync, cfg_tlpx_delay_data_active : std_logic_vector(15 downto 0) := x"000A";
signal cfg_tlp_sot_short_meta, cfg_tlp_sot_short_sync, cfg_tlp_sot_short_active : std_logic_vector(15 downto 0) := x"030F";
signal cfg_ths_prepare_meta, cfg_ths_prepare_sync, cfg_ths_prepare_active : std_logic_vector(15 downto 0) := x"000F";
signal cfg_ths_zero_meta, cfg_ths_zero_sync, cfg_ths_zero_active : std_logic_vector(15 downto 0) := x"0050";
signal cfg_ths_exit_meta, cfg_ths_exit_sync, cfg_ths_exit_active : std_logic_vector(15 downto 0) := x"000A";

signal start_toggle_reg       : std_logic := '0';
signal start_toggle_meta      : std_logic := '0';
signal start_toggle_sync      : std_logic := '0';
signal start_toggle_sync_d    : std_logic := '0';
signal send_frame_axi_pulse   : std_logic := '0';
signal send_frame_legacy_pulse: std_logic := '0';
signal stop_frame_ctrl        : std_logic := '0';
signal irq_pending            : std_logic := '0';
signal frame_done_meta_axi    : std_logic := '0';
signal frame_done_sync_axi    : std_logic := '0';
signal frame_done_sync_d_axi  : std_logic := '0';

begin

s_axi_awready <= axi_awready_reg;
s_axi_wready  <= axi_wready_reg;
s_axi_bvalid  <= axi_bvalid_reg;
s_axi_bresp   <= axi_bresp_reg;
s_axi_arready <= axi_arready_reg;
s_axi_rvalid  <= axi_rvalid_reg;
s_axi_rresp   <= axi_rresp_reg;
s_axi_rdata   <= axi_rdata_reg;
irq <= irq_pending and reg_control(2);

axi_lite_regs : process(s_axi_aclk)
begin
  if rising_edge(s_axi_aclk) then
    if s_axi_aresetn = '0' then
      axi_awready_reg <= '0';
      axi_wready_reg <= '0';
      axi_bvalid_reg <= '0';
      axi_bresp_reg <= (others => '0');
      axi_arready_reg <= '0';
      axi_rvalid_reg <= '0';
      axi_rresp_reg <= (others => '0');
      axi_rdata_reg <= (others => '0');
            reg_control <= x"00000028";
      reg_pixels_per_line <= x"0CA8";
      reg_n_lines <= x"0798";
      reg_type_vc <= x"0000002B";
      reg_frame_end_word <= x"1753";
      reg_tlp_sot_delay_clk <= x"002A";
      reg_tlpx_delay_clk <= x"000A";
      reg_tlp_sot_delay_data <= x"00BB";
      reg_tlpx_delay_data <= x"000A";
      reg_tlp_sot_short <= x"030F";
      reg_ths_prepare <= x"000F";
      reg_ths_zero <= x"0050";
      reg_ths_exit <= x"000A";
      start_toggle_reg <= '0';
      irq_pending <= '0';
    else
      frame_done_meta_axi <= frame_done;
      frame_done_sync_axi <= frame_done_meta_axi;
      frame_done_sync_d_axi <= frame_done_sync_axi;

      if (frame_done_sync_axi = '1' and frame_done_sync_d_axi = '0') then
        irq_pending <= '1';
      end if;

      axi_awready_reg <= '0';
      axi_wready_reg <= '0';
      axi_arready_reg <= '0';

      if (s_axi_awvalid = '1' and s_axi_wvalid = '1' and axi_bvalid_reg = '0') then
        axi_awready_reg <= '1';
        axi_wready_reg <= '1';
        axi_bvalid_reg <= '1';
        axi_bresp_reg <= "00";

        case s_axi_awaddr is
          when REG_CONTROL_ADDR =>
            if s_axi_wstrb(0) = '1' then
              reg_control(5 downto 1) <= s_axi_wdata(5 downto 1); --stop, irq_en, legacy_trig_en, debug_overlay_en
              reg_control(4) <= '0';
              if s_axi_wdata(0) = '1' then
                start_toggle_reg <= not start_toggle_reg;
              end if;
              if s_axi_wdata(4) = '1' then
                irq_pending <= '0';
              end if;
            end if;
          when REG_PIXELS_PER_LINE_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_pixels_per_line(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_pixels_per_line(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_N_LINES_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_n_lines(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_n_lines(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_TYPE_VC_ADDR =>
            for i in 0 to 3 loop
              if s_axi_wstrb(i) = '1' then
                reg_type_vc((8*i)+7 downto (8*i)) <= s_axi_wdata((8*i)+7 downto (8*i));
              end if;
            end loop;
          when REG_FRAME_END_WORD_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_frame_end_word(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_frame_end_word(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_TLP_SOT_DELAY_CLOCK_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_tlp_sot_delay_clk(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_tlp_sot_delay_clk(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_TLPX_DELAY_CLOCK_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_tlpx_delay_clk(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_tlpx_delay_clk(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_TLP_SOT_DELAY_DATA_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_tlp_sot_delay_data(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_tlp_sot_delay_data(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_TLPX_DELAY_DATA_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_tlpx_delay_data(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_tlpx_delay_data(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_TLP_SOT_SHORT_DELAY_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_tlp_sot_short(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_tlp_sot_short(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_THS_PREPARE_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_ths_prepare(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_ths_prepare(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_THS_ZERO_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_ths_zero(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_ths_zero(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when REG_THS_EXIT_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_ths_exit(7 downto 0) <= s_axi_wdata(7 downto 0); end if;
            if s_axi_wstrb(1) = '1' then reg_ths_exit(15 downto 8) <= s_axi_wdata(15 downto 8); end if;
          when others =>
            null;
        end case;
      elsif (axi_bvalid_reg = '1' and s_axi_bready = '1') then
        axi_bvalid_reg <= '0';
      end if;

      if (s_axi_arvalid = '1' and axi_rvalid_reg = '0') then
        axi_arready_reg <= '1';
        axi_rvalid_reg <= '1';
        axi_rresp_reg <= "00";

        case s_axi_araddr is
          when REG_CONTROL_ADDR =>
            axi_rdata_reg <= reg_control;
          when REG_STATUS_ADDR =>
            axi_rdata_reg <= (31 downto 4 => '0') & irq_pending & frame_done & hs_data_valid & hs_active;
          when REG_PIXELS_PER_LINE_ADDR =>
            axi_rdata_reg <= x"0000" & reg_pixels_per_line;
          when REG_N_LINES_ADDR =>
            axi_rdata_reg <= x"0000" & reg_n_lines;
          when REG_TYPE_VC_ADDR =>
            axi_rdata_reg <= reg_type_vc;
          when REG_FRAME_END_WORD_ADDR =>
            axi_rdata_reg <= x"0000" & reg_frame_end_word;
          when REG_TLP_SOT_DELAY_CLOCK_ADDR =>
            axi_rdata_reg <= x"0000" & reg_tlp_sot_delay_clk;
          when REG_TLPX_DELAY_CLOCK_ADDR =>
            axi_rdata_reg <= x"0000" & reg_tlpx_delay_clk;
          when REG_TLP_SOT_DELAY_DATA_ADDR =>
            axi_rdata_reg <= x"0000" & reg_tlp_sot_delay_data;
          when REG_TLPX_DELAY_DATA_ADDR =>
            axi_rdata_reg <= x"0000" & reg_tlpx_delay_data;
          when REG_TLP_SOT_SHORT_DELAY_ADDR =>
            axi_rdata_reg <= x"0000" & reg_tlp_sot_short;
          when REG_THS_PREPARE_ADDR =>
            axi_rdata_reg <= x"0000" & reg_ths_prepare;
          when REG_THS_ZERO_ADDR =>
            axi_rdata_reg <= x"0000" & reg_ths_zero;
          when REG_THS_EXIT_ADDR =>
            axi_rdata_reg <= x"0000" & reg_ths_exit;
          when others =>
            axi_rdata_reg <= (others => '0');
        end case;
      elsif (axi_rvalid_reg = '1' and s_axi_rready = '1') then
        axi_rvalid_reg <= '0';
      end if;
    end if;
  end if;
end process;

ctrl_sync_and_irq : process(clk_50MHz)
begin
  if rising_edge(clk_50MHz) then
    if rst = '1' then
      cfg_control_meta <= x"00000028";
      cfg_control_sync <= x"00000028";
      cfg_control_active <= x"00000028";
      cfg_pixels_per_line_meta <= x"0CA8";
      cfg_pixels_per_line_sync <= x"0CA8";
      cfg_pixels_per_line_active <= x"0CA8";
      cfg_n_lines_meta <= x"0798";
      cfg_n_lines_sync <= x"0798";
      cfg_n_lines_active <= x"0798";
      cfg_type_vc_meta <= x"0000002B";
      cfg_type_vc_sync <= x"0000002B";
      cfg_type_vc_active <= x"0000002B";
      cfg_frame_end_word_meta <= x"1753";
      cfg_frame_end_word_sync <= x"1753";
      cfg_frame_end_word_active <= x"1753";
      cfg_tlp_sot_delay_clk_meta <= x"002A";
      cfg_tlp_sot_delay_clk_sync <= x"002A";
      cfg_tlp_sot_delay_clk_active <= x"002A";
      cfg_tlpx_delay_clk_meta <= x"000A";
      cfg_tlpx_delay_clk_sync <= x"000A";
      cfg_tlpx_delay_clk_active <= x"000A";
      cfg_tlp_sot_delay_data_meta <= x"00BB";
      cfg_tlp_sot_delay_data_sync <= x"00BB";
      cfg_tlp_sot_delay_data_active <= x"00BB";
      cfg_tlpx_delay_data_meta <= x"000A";
      cfg_tlpx_delay_data_sync <= x"000A";
      cfg_tlpx_delay_data_active <= x"000A";
      cfg_tlp_sot_short_meta <= x"030F";
      cfg_tlp_sot_short_sync <= x"030F";
      cfg_tlp_sot_short_active <= x"030F";
      cfg_ths_prepare_meta <= x"000F";
      cfg_ths_prepare_sync <= x"000F";
      cfg_ths_prepare_active <= x"000F";
      cfg_ths_zero_meta <= x"0050";
      cfg_ths_zero_sync <= x"0050";
      cfg_ths_zero_active <= x"0050";
      cfg_ths_exit_meta <= x"000A";
      cfg_ths_exit_sync <= x"000A";
      cfg_ths_exit_active <= x"000A";
      start_toggle_meta <= '0';
      start_toggle_sync <= '0';
      start_toggle_sync_d <= '0';
      send_frame_axi_pulse <= '0';
    else
      cfg_control_meta <= reg_control;
      cfg_control_sync <= cfg_control_meta;
      cfg_pixels_per_line_meta <= reg_pixels_per_line;
      cfg_pixels_per_line_sync <= cfg_pixels_per_line_meta;
      cfg_n_lines_meta <= reg_n_lines;
      cfg_n_lines_sync <= cfg_n_lines_meta;
      cfg_type_vc_meta <= reg_type_vc;
      cfg_type_vc_sync <= cfg_type_vc_meta;
      cfg_frame_end_word_meta <= reg_frame_end_word;
      cfg_frame_end_word_sync <= cfg_frame_end_word_meta;
      cfg_tlp_sot_delay_clk_meta <= reg_tlp_sot_delay_clk;
      cfg_tlp_sot_delay_clk_sync <= cfg_tlp_sot_delay_clk_meta;
      cfg_tlpx_delay_clk_meta <= reg_tlpx_delay_clk;
      cfg_tlpx_delay_clk_sync <= cfg_tlpx_delay_clk_meta;
      cfg_tlp_sot_delay_data_meta <= reg_tlp_sot_delay_data;
      cfg_tlp_sot_delay_data_sync <= cfg_tlp_sot_delay_data_meta;
      cfg_tlpx_delay_data_meta <= reg_tlpx_delay_data;
      cfg_tlpx_delay_data_sync <= cfg_tlpx_delay_data_meta;
      cfg_tlp_sot_short_meta <= reg_tlp_sot_short;
      cfg_tlp_sot_short_sync <= cfg_tlp_sot_short_meta;
      cfg_ths_prepare_meta <= reg_ths_prepare;
      cfg_ths_prepare_sync <= cfg_ths_prepare_meta;
      cfg_ths_zero_meta <= reg_ths_zero;
      cfg_ths_zero_sync <= cfg_ths_zero_meta;
      cfg_ths_exit_meta <= reg_ths_exit;
      cfg_ths_exit_sync <= cfg_ths_exit_meta;

      -- Start edge is synchronized and used as atomic config commit point.
      start_toggle_meta <= start_toggle_reg;
      start_toggle_sync <= start_toggle_meta;
      start_toggle_sync_d <= start_toggle_sync;
      send_frame_axi_pulse <= start_toggle_sync xor start_toggle_sync_d;

      if (start_toggle_sync xor start_toggle_sync_d) = '1' then
        cfg_control_active <= cfg_control_sync;
        cfg_pixels_per_line_active <= cfg_pixels_per_line_sync;
        cfg_n_lines_active <= cfg_n_lines_sync;
        cfg_type_vc_active <= cfg_type_vc_sync;
        cfg_frame_end_word_active <= cfg_frame_end_word_sync;
        cfg_tlp_sot_delay_clk_active <= cfg_tlp_sot_delay_clk_sync;
        cfg_tlpx_delay_clk_active <= cfg_tlpx_delay_clk_sync;
        cfg_tlp_sot_delay_data_active <= cfg_tlp_sot_delay_data_sync;
        cfg_tlpx_delay_data_active <= cfg_tlpx_delay_data_sync;
        cfg_tlp_sot_short_active <= cfg_tlp_sot_short_sync;
        cfg_ths_prepare_active <= cfg_ths_prepare_sync;
        cfg_ths_zero_active <= cfg_ths_zero_sync;
        cfg_ths_exit_active <= cfg_ths_exit_sync;
      end if;
    end if;
  end if;
end process;
  

inst_selectio: selectio_serdes PORT MAP (
    data_out_from_device => data_out_from_device,
    data_out_to_pins_p => data_out_to_pins_p,
    data_out_to_pins_n => data_out_to_pins_n,
    clk_in => clk_200MHz_serdes,
    clk_div_in => clk_50MHz,
    clock_enable => '1',--hs_active,
    io_reset => rst
  );

data_out_from_device(1) <= parallel_data_to_serdes(0);
data_out_from_device(3) <= parallel_data_to_serdes(1);
data_out_from_device(5) <= parallel_data_to_serdes(2);
data_out_from_device(7) <= parallel_data_to_serdes(3);
data_out_from_device(9) <= parallel_data_to_serdes(4);
data_out_from_device(11) <= parallel_data_to_serdes(5);
data_out_from_device(13) <= parallel_data_to_serdes(6);
data_out_from_device(15) <= parallel_data_to_serdes(7);

data_out_from_device(0) <= parallel_data_to_serdes(8);
data_out_from_device(2) <= parallel_data_to_serdes(9);
data_out_from_device(4) <= parallel_data_to_serdes(10);
data_out_from_device(6) <= parallel_data_to_serdes(11);
data_out_from_device(8) <= parallel_data_to_serdes(12);
data_out_from_device(10) <= parallel_data_to_serdes(13);
data_out_from_device(12) <= parallel_data_to_serdes(14);
data_out_from_device(14) <= parallel_data_to_serdes(15);

 
hs_c_d0_p <= data_out_to_pins_p(1);
hs_c_d0_n  <= data_out_to_pins_n(1);
hs_c_d1_p <= data_out_to_pins_p(0);
hs_c_d1_n <= data_out_to_pins_n(0);


--Instantinate differential outputs

out_HS_C_clk: unisim.vcomponents.OBUFDS
port map (
  I  => clk_200MHz_deg90,
  O => hs_c_clk_p,
  OB  => hs_c_clk_n
);


--set D camera HS to zero
out_HS_D_clk: unisim.vcomponents.OBUFDS
port map (
  I  => '0',
  O => hs_d_clk_p,
  OB  => hs_d_clk_n
);

out_HS_D_D0: unisim.vcomponents.OBUFDS
port map (
  I  => '0',
  O => hs_d_d0_p,
  OB  => hs_d_d0_n
);

out_HS_D_D1: unisim.vcomponents.OBUFDS
port map (
  I  => '0',
  O => hs_d_d1_p,
  OB  => hs_d_d1_n
);

--Instantinate 200 MHz main clock in
--clck_in_IBUFDS: unisim.vcomponents.IBUFDS
--port map (
--  I  => sys_clk_p,
--  IB => sys_clk_n,
--  O  => clk_200Mhz
--);

clock_network :  clock_wizard
  PORT MAP (
    --Clock in ports
    sys_clk_200MHz_in_p  => sys_clk_p,
    sys_clk_200MHz_in_n  => sys_clk_n,
    --Clock out ports
    clk_DPHY_100Mhz          => clk_DPHY_100Mhz,
    clk_200MHz_deg90     => clk_200MHz_deg90,
    clk_50MHz         => clk_50MHz,
    clk_10MHz           => clk_10MHz,
    clk_200MHz_serdes   => clk_200MHz_serdes,
    --Status and control signals
    reset              => sys_rst,
    locked             => locked
    );

delay_counter: counter 
GENERIC MAP(n => COUNTER_WIDTH)
PORT MAP(clk => clk_DPHY_100Mhz,
         rst => rst,
         counter_out => counter_value); 


clk_slow_counter <= '1' when (counter_value > "0111111111") else '0'; 
delay_slow_counter: counter 
GENERIC MAP(n => SLOW_COUNTER_WIDTH)
PORT MAP(clk =>  clk_slow_counter,
         rst => (not monitor_1p8v),
         counter_out => slow_counter_value); 



--Instantiate the Frame stream generator 
frame_gen: send_single_frame  
     GENERIC MAP(    
       N_MIPI_LANES => N_MIPI_LANES, --number of MIPI CSI lanes currently only 2 implemented
       PIXELS_PER_LINE_MAX => 3240,
       ADD_DEBUG_OVERLAY => ADD_DEBUG_OVERLAY
     )
     PORT MAP(
     clk => clk_50MHz,
     rst => rst,
     clk_DPHY_100Mhz => clk_DPHY_100Mhz,
     send_frame =>  send_frame,
     stop_frame => stop_frame_ctrl,
    cfg_pixels_per_line => cfg_pixels_per_line_active,
    cfg_n_lines => cfg_n_lines_active,
    cfg_vc_num => cfg_type_vc_active(9 downto 8),
    cfg_data_type => cfg_type_vc_active(5 downto 0),
    cfg_frame_end_word => cfg_frame_end_word_active,
    cfg_tLP_SOT_Delay_clock => cfg_tlp_sot_delay_clk_active,
    cfg_tLPX_Delay_clock => cfg_tlpx_delay_clk_active,
    cfg_tLP_SOT_Delay_data => cfg_tlp_sot_delay_data_active,
    cfg_tLPX_Delay_data => cfg_tlpx_delay_data_active,
    cfg_tLP_SOT_short_packet_delay => cfg_tlp_sot_short_active,
    cfg_tHSprepare => cfg_ths_prepare_active,
    cfg_tHSzero => cfg_ths_zero_active,
    cfg_tHSexit => cfg_ths_exit_active,
    cfg_debug_overlay_en => cfg_control_active(5),
     frame_done => frame_done,
     hs_active => hs_active,
     hs_data_valid => hs_data_valid,
     csi_hs_data_1_out => csi_hs_data_1_out,
     csi_hs_data_2_out => csi_hs_data_2_out,
     csi_hs_data_3_out => csi_hs_data_3_out,
     csi_hs_data_4_out => csi_hs_data_4_out,
     lp_lanes => lp_lanes,
     lp_clk_lane => lp_clk_lane,
     csi_clk_hs_active => csi_clk_hs_active
     ); 
     
            
rst <= not locked; --hold all the system on reset while clocks are not locked 
  send_frame_legacy_pulse <= '1' when (counter_value < "0000000011" and rst = '0' and (GPIO_SW_C = '1' or slow_counter_value > "0111111111")) else '0';
  send_frame <= send_frame_axi_pulse or (send_frame_legacy_pulse and cfg_control_sync(3));
  stop_frame_ctrl <= cfg_control_sync(1);
--send_frame <=  '1' when (counter_value < "0000001100" and rst = '0') else '0'; --400 MHz

leds_debug(0) <= send_frame_axi_pulse;
leds_debug(1) <= irq;
leds_debug(2) <= cfg_control_sync(3);
leds_debug(3) <= '1';
leds_debug(4) <= monitor_1p2v;
leds_debug(5) <= monitor_1p8v;
leds_debug(6) <= monitor_2p8v;
leds_debug(7) <= monitor_3p3v;

dbg_io_1   <= monitor_1p8v;
dbg_io_2   <= send_frame;
dbg_io_3   <= frame_done;
           
--HS Lanes

parallel_data_to_serdes(7  downto 0)  <= csi_hs_data_1_out;
parallel_data_to_serdes(15 downto 8)  <= csi_hs_data_2_out;
parallel_data_to_serdes(23 downto 16) <= csi_hs_data_3_out;
parallel_data_to_serdes(31 downto 24) <= csi_hs_data_4_out;


------------------------------------------LP Lanes-----------------------------
--CSI_C
lp_c_d0_p  <= lp_lanes(1);
lp_c_d0_n  <= lp_lanes(0);
lp_c_d1_p  <= lp_lanes(1);
lp_c_d1_n  <= lp_lanes(0);
lp_c_clk_p <= lp_clk_lane(1);
lp_c_clk_n <= lp_clk_lane(0);
--CSI_D
lp_d_d0_p  <= '0'; --TODO check if need to switch (1) <-> (0)
lp_d_d0_n  <= '0'; --TODO check if need to switch (1) <-> (0)
lp_d_d1_p  <= '0'; --TODO check if need to switch (1) <-> (0)
lp_d_d1_n  <= '0'; --TODO check if need to switch (1) <-> (0)
lp_d_clk_p <= '0'; --TODO check if need to switch (1) <-> (0)
lp_d_clk_n <= '0'; --TODO check if need to switch (1) <-> (0)

------------------------------------------SWITCH LP/HS ---------------------------
switch_data_lanes_vadj <= lp_lanes(0); -- switch LP and HS mode
switch_clock_lanes_vadj <= lp_clk_lane(0); -- switch LP and HS mode

  
end Behavioral;
