----------------------------------------------------------------------------------
-- AXI-configurable MIPI TX core logic (no board clocks/serdes glue)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mipi_tx_axi_ip is
  Generic (
    PIXELS_PER_LINE_MAX : integer := 3240;
    ADD_DEBUG_OVERLAY   : integer := 1
  );
  Port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    clk_DPHY_100Mhz : in  std_logic;

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
    irq           : out std_logic;

    -- CSI stream outputs to serdes/board glue logic
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
end mipi_tx_axi_ip;

architecture Behavioral of mipi_tx_axi_ip is

COMPONENT send_single_frame is
  Generic (
    PIXELS_PER_LINE_MAX : integer := 3240;
    ADD_DEBUG_OVERLAY   : integer := 1
  );
  Port (
    clk : in std_logic;
    rst : in  std_logic;
    clk_DPHY_100Mhz : in std_logic;
    send_frame : in std_logic;
    stop_frame : in std_logic;
    cfg_n_mipi_lanes : in std_logic_vector(1 downto 0);
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
    frame_done : out std_logic;
    hs_active : out std_logic;
    hs_data_valid : out std_logic;
    csi_hs_data_1_out : out std_logic_vector(7 downto 0);
    csi_hs_data_2_out : out std_logic_vector(7 downto 0);
    csi_hs_data_3_out : out std_logic_vector(7 downto 0);
    csi_hs_data_4_out : out std_logic_vector(7 downto 0);
    lp_lanes : out std_logic_vector(1 downto 0);
    lp_clk_lane : out std_logic_vector(1 downto 0);
    csi_clk_hs_active : out std_logic
  );
END COMPONENT;

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
constant REG_N_MIPI_LANES_ADDR            : std_logic_vector(7 downto 0) := x"40";
constant DEFAULT_N_MIPI_LANES             : std_logic_vector(1 downto 0) := "10";

signal axi_awready_reg : std_logic := '0';
signal axi_wready_reg  : std_logic := '0';
signal axi_bvalid_reg  : std_logic := '0';
signal axi_arready_reg : std_logic := '0';
signal axi_rvalid_reg  : std_logic := '0';
signal axi_bresp_reg   : std_logic_vector(1 downto 0) := (others => '0');
signal axi_rresp_reg   : std_logic_vector(1 downto 0) := (others => '0');
signal axi_rdata_reg   : std_logic_vector(31 downto 0) := (others => '0');

signal reg_control            : std_logic_vector(31 downto 0) := x"00000028";
signal reg_pixels_per_line    : std_logic_vector(15 downto 0) := x"0CA8";
signal reg_n_lines            : std_logic_vector(15 downto 0) := x"0798";
signal reg_type_vc            : std_logic_vector(31 downto 0) := x"0000002B";
signal reg_frame_end_word     : std_logic_vector(15 downto 0) := x"1753";
signal reg_tlp_sot_delay_clk  : std_logic_vector(15 downto 0) := x"002A";
signal reg_tlpx_delay_clk     : std_logic_vector(15 downto 0) := x"000A";
signal reg_tlp_sot_delay_data : std_logic_vector(15 downto 0) := x"00BB";
signal reg_tlpx_delay_data    : std_logic_vector(15 downto 0) := x"000A";
signal reg_tlp_sot_short      : std_logic_vector(15 downto 0) := x"030F";
signal reg_ths_prepare        : std_logic_vector(15 downto 0) := x"000F";
signal reg_ths_zero           : std_logic_vector(15 downto 0) := x"0050";
signal reg_ths_exit           : std_logic_vector(15 downto 0) := x"000A";
signal reg_n_mipi_lanes       : std_logic_vector(1 downto 0) := DEFAULT_N_MIPI_LANES;

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
signal cfg_n_mipi_lanes_meta, cfg_n_mipi_lanes_sync, cfg_n_mipi_lanes_active : std_logic_vector(1 downto 0) := DEFAULT_N_MIPI_LANES;

signal start_toggle_reg      : std_logic := '0';
signal start_toggle_meta     : std_logic := '0';
signal start_toggle_sync     : std_logic := '0';
signal start_toggle_sync_d   : std_logic := '0';
signal send_frame_axi_pulse  : std_logic := '0';
signal send_frame_core       : std_logic := '0';
signal stop_frame_ctrl       : std_logic := '0';
signal irq_pending           : std_logic := '0';
signal frame_done            : std_logic;
signal frame_done_meta_axi   : std_logic := '0';
signal frame_done_sync_axi   : std_logic := '0';
signal frame_done_sync_d_axi : std_logic := '0';

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
      reg_n_mipi_lanes <= DEFAULT_N_MIPI_LANES;
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
              reg_control(5 downto 1) <= s_axi_wdata(5 downto 1);
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
          when REG_N_MIPI_LANES_ADDR =>
            if s_axi_wstrb(0) = '1' then reg_n_mipi_lanes <= s_axi_wdata(1 downto 0); end if;
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
          when REG_N_MIPI_LANES_ADDR =>
            axi_rdata_reg <= (31 downto 2 => '0') & reg_n_mipi_lanes;
          when others =>
            axi_rdata_reg <= (others => '0');
        end case;
      elsif (axi_rvalid_reg = '1' and s_axi_rready = '1') then
        axi_rvalid_reg <= '0';
      end if;
    end if;
  end if;
end process;

ctrl_sync_and_irq : process(clk)
begin
  if rising_edge(clk) then
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
      cfg_n_mipi_lanes_meta <= DEFAULT_N_MIPI_LANES;
      cfg_n_mipi_lanes_sync <= DEFAULT_N_MIPI_LANES;
      cfg_n_mipi_lanes_active <= DEFAULT_N_MIPI_LANES;
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
      cfg_n_mipi_lanes_meta <= reg_n_mipi_lanes;
      cfg_n_mipi_lanes_sync <= cfg_n_mipi_lanes_meta;

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
        cfg_n_mipi_lanes_active <= cfg_n_mipi_lanes_sync;
      end if;
    end if;
  end if;
end process;

send_frame_core <= send_frame_axi_pulse;
stop_frame_ctrl <= cfg_control_sync(1);

frame_gen: send_single_frame
  GENERIC MAP(
    PIXELS_PER_LINE_MAX => PIXELS_PER_LINE_MAX,
    ADD_DEBUG_OVERLAY => ADD_DEBUG_OVERLAY
  )
  PORT MAP(
    clk => clk,
    rst => rst,
    clk_DPHY_100Mhz => clk_DPHY_100Mhz,
    send_frame => send_frame_core,
    stop_frame => stop_frame_ctrl,
    cfg_n_mipi_lanes => cfg_n_mipi_lanes_active,
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

end Behavioral;
