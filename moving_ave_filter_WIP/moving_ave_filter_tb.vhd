

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity fifo_buffer_tb is
end fifo_buffer_tb;
 
architecture behave of fifo_buffer_tb is
 
  constant c_DEPTH : integer := 32;--4;
  constant c_WIDTH : integer := 8;--8;
   
  signal r_RESET   : std_logic := '0';
  signal r_CLOCK   : std_logic := '0';
  signal r_WR_EN   : std_logic := '0';
  signal r_WR_DATA : std_logic_vector(c_WIDTH-1 downto 0) := X"A5";
  signal w_FULL    : std_logic;
  signal r_RD_EN   : std_logic := '0';
  signal w_RD_DATA : std_logic_vector(c_WIDTH-1 downto 0);
  signal w_EMPTY   : std_logic;
   
  component fifo_buffer is
    generic (
      g_WIDTH : natural := 8;
      g_DEPTH : integer := 32
      );
    port (
      i_rst_sync : in std_logic;
      i_clock      : in std_logic;
 
      -- FIFO Write Interface
      i_wr_en   : in  std_logic;
      i_wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);
      o_full_flag    : out std_logic;
 
      -- FIFO Read Interface
      i_rd_en   : in  std_logic;
      o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0);
      o_empty_flag   : out std_logic
      );
  end component fifo_buffer;
 
   
begin
 
  MODULE_FIFO_REGS_NO_FLAGS_INST : fifo_buffer
    generic map (
      g_WIDTH => c_WIDTH,
      g_DEPTH => c_DEPTH
      )
    port map (
      i_rst_sync => r_RESET,
      i_clock      => r_CLOCK,
      i_wr_en    => r_WR_EN,
      i_wr_data  => r_WR_DATA,
      o_full_flag     => w_FULL,
      i_rd_en    => r_RD_EN,
      o_rd_data  => w_RD_DATA,
      o_empty_flag    => w_EMPTY
      );
 
 
  r_CLOCK <= not r_CLOCK after 5 ns; --200MHz clk
 
  p_TEST : process is
  begin
    wait until r_CLOCK = '1'; -- 5 ns
    r_WR_EN <= '1';
    wait until r_CLOCK = '1'; --data_cnt = 1 
    wait until r_CLOCK = '1'; --data_cnt = 2
    wait until r_CLOCK = '1'; --data_cnt = 3
    wait until r_CLOCK = '1'; --45 ns --data_cnt = 4
    r_WR_EN <= '0';
    r_RD_EN <= '1';
    wait until r_CLOCK = '1'; -- 55 ns --read word comes out instantly (data cnt = 3)
    wait until r_CLOCK = '1'; --next word fills, data_cnt = 2
    wait until r_CLOCK = '1'; --data cnt = 1
    wait until r_CLOCK = '1'; --85 ns -- data cnt = 0
    r_RD_EN <= '0';
    r_WR_EN <= '1';
    wait until r_CLOCK = '1'; --95 ns --data_cnt = 1
    wait until r_CLOCK = '1'; --105 ns -- data_cnt = 2
    r_RD_EN <= '1'; --both write and read are simulataneous
    wait until r_CLOCK = '1'; --115 ns --data_cnt = 2
    wait until r_CLOCK = '1';  --data_cnt = 2
    wait until r_CLOCK = '1';  --data_cnt = 2
    wait until r_CLOCK = '1';  --data_cnt = 2
    wait until r_CLOCK = '1';  --data_cnt = 2
    wait until r_CLOCK = '1';  --data_cnt = 2
    wait until r_CLOCK = '1';  --data_cnt = 2
    wait until r_CLOCK = '1'; --185 ns  --data_cnt = 2
    r_WR_EN <= '0';
    wait until r_CLOCK = '1'; --195 ns --data_cnt = 1
    wait until r_CLOCK = '1'; --data_cnt = 0
    wait until r_CLOCK = '1'; --data_cnt = -1
    wait until r_CLOCK = '1'; --225 ns -- error here --data_cnt = -2
 
  end process;
   
   
end behave;
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity fifo_buffer_tb is
--end fifo_buffer_tb;
--
--architecture behave of fifo_buffer_tb is
--
--constant c_DEPTH : integer := 32; --4; --??
--constant c_WIDTH : integer := 8; --8; --??
--
--signal r_RESET	: std_logic := '0';
--signal r_CLOCK	: std_logic := '0';
--signal r_WR_EN	: std_logic := '0';
--signal r_WR_DATA: std_logic_vector(c_WIDTH-1 downto 0) := X"A5";
--signal w_FULL	: std_logic;
--signal r_RD_EN	: std_logic := '0';
--signal r_RD_DATA	: std_logic_vector(c_WIDTH-1 downto 0);
--signal w_EMPTY	: std_logic;
--
--component fifo_buffer is
--	generic (
--		g_WIDTH	: natural := 8;
--		g_DEPTH	: integer := 32
--	);
--	port(
--		i_rst_sync : in std_logic;
--		i_clock	   : in std_logic;
--	--FIFO Write interface
--		i_wr_en	   : in std_logic;
--		i_wr_data  : in std_logic_vector(g_WIDTH-1 downto 0);
--		o_full_flag	   : out std_logic;
--
--	--FIFO READ Interface
--		i_rd_en	   : in std_logic;
--		o_rd_data  : out std_logic_vector(g_WIDTH-1 downto 0);
--		o_empty_flag	   : out std_logic
--	);
--end component fifo_buffer;
--
--begin
--
--	MODULE_FIFO_REGS_NO_FLAGS_INST	: fifo_buffer
--		generic map(
--			g_WIDTH => c_WIDTH,
--			g_DEPTH => c_DEPTH
--		)
--		port map(
--			i_rst_sync 	=> r_RESET,
--			i_clock	   	=> r_CLOCK,
--			i_wr_en		=> r_WR_EN,
--			i_wr_data	=> r_WR_DATA,
--			o_full_flag	=> w_FULL,
--			i_rd_en		=> r_RD_EN,
--			o_rd_data	=> r_RD_DATA,
--			o_empty_flag	=> w_EMPTy
--		);
--
--		r_CLOCK <= not r_CLOCK after 5 ns; --non-synthesizeable code
--		
--		P_TEST	: process is
--		begin
--			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1';
--			r_RESET <= '1';
--			wait until r_CLOCK = '1';
--			r_RESET	<= '0';
--			wait until r_CLOCK = '1';
--			r_WR_EN <= '1';
--			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1'; --set write enable high for 4 clk cycles.
--			r_WR_EN <= '0'; --occurs on same clock cycle as rd en
--			
--			r_RD_EN <= '1'; --occurs on same clock cycle as wr_en
--			wait until r_CLOCK = '1';
--   			wait until r_CLOCK = '1';
--    			wait until r_CLOCK = '1';
--    			wait until r_CLOCK = '1';
--			wait until r_CLOCK = '1';
--   			wait until r_CLOCK = '1';
--    			wait until r_CLOCK = '1';
--    			wait until r_CLOCK = '1';
--    			r_RD_EN <= '0';
--    			
--		end process;
--end behave;
--		