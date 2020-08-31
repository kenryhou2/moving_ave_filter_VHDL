

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;				--for textio
use ieee.std_logic_textio.all;	--for std_logic_vectors in text io

entity moving_ave_filter_2_tb is
end moving_ave_filter_2_tb;
 
architecture behave of moving_ave_filter_2_tb is 
 
  constant c_DEPTH : integer := 128;
  constant c_WIDTH : integer := 8;
  constant c_INPUT_DEPTH : natural := 10;
  signal r_RESET   : std_logic := '0';
  signal r_CLOCK   : std_logic := '0';
  signal r_WR_EN   : std_logic := '0';
  signal r_WR_DATA : std_logic_vector(c_WIDTH-1 downto 0) := X"A5"; --eventually make it contain multiple words.
  signal w_FULL    : std_logic;
  signal w_AFULL  : std_logic;
  signal r_RD_EN   : std_logic := '0';
  signal w_RD_DATA : std_logic_vector(c_WIDTH-1 downto 0);
  signal w_EMPTY   : std_logic;
  signal w_AEMPTY : std_logic;
  signal w_SUM : std_logic_vector(c_WIDTH+c_DEPTH-1 downto 0);
  signal w_DIV : std_logic_vector(c_WIDTH+c_DEPTH-1 downto 0);
  file file_VECTORS : text;
  file file_RESULTS : text;
  --store contents of input text into array of std_logic_vectors
  -- type t_FIFO_DATA is array (0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0); --declaring array data type.
  -- signal r_FIFO_DATA : t_FIFO_DATA := (others=> (others => '0')); --r_FIFO_DATA is the body of the FIFO buffer.
  
  
  component moving_ave_filter is
    generic (
      g_WIDTH : natural := 8;
      g_DEPTH : integer := 128;
      g_A_EMPTY_LEVEL : natural := 2;
      g_A_FULL_LEVEL  : natural := 126
      );
    port (
      i_rst_sync : in std_logic;
      i_clock      : in std_logic;
      o_sum	: out std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0);
      o_div	: out std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0);
      -- FIFO Write Interface
      i_wr_en   : in  std_logic;
      i_wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);
      o_full_flag    : out std_logic;
      o_almost_full_flag : out std_logic;

      -- FIFO Read Interface
      i_rd_en   : in  std_logic;
      o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0);
      o_empty_flag   : out std_logic;
      o_almost_empty_flag : out std_logic
      );
  end component moving_ave_filter;
 
   
begin
 
  MODULE_FIFO_REGS_NO_FLAGS_INST : moving_ave_filter
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
      o_empty_flag    => w_EMPTY,
      o_sum	=> w_SUM,
      o_div	=> w_DIV,
      o_almost_empty_flag => w_AEMPTY,
      o_almost_full_flag => w_AFULL
      );
 
 
  r_CLOCK <= not r_CLOCK after 5 ns; --200MHz clk
 
  p_TEST : process is
  
    variable v_ILINE     : line;
    variable v_OLINE     : line;
    -- variable v_ADD_TERM1 : std_logic_vector(c_WIDTH-1 downto 0);
    -- variable v_ADD_TERM2 : std_logic_vector(c_WIDTH-1 downto 0);
    variable v_SPACE     : character;
	variable v_INPUT_HEX : std_logic_vector (c_WIDTH-1 downto 0);
	variable v_OUTPUT_HEX : std_logic_vector (c_WIDTH+c_DEPTH-1 downto 0);
 
	begin
		file_open(file_VECTORS, "input_stream.txt",  read_mode);
		file_open(file_RESULTS, "output_stream.txt", write_mode);
	 

		
		--feed input hex into the fifo
		--compute the moving average
		-- output the average to a file
		while not endfile(file_VECTORS) loop
		  wait until r_CLOCK = '1';
		  if (w_AEMPTY = '1') then
			report "Buffer almost empty" severity warning;
		  end if;
		  if (w_AFULL = '1') then
			report "Buffer almost full" severity warning;
		  end if;
		  if (w_EMPTY = '1') then
			report "Buffer empty" severity warning;
		  end if;
		  if (w_FULL = '1') then
			report "Buffer full" severity warning;
		  end if;
		  readline(file_VECTORS, v_ILINE);
		  read(v_ILINE, v_INPUT_HEX);
		  r_WR_DATA <= v_INPUT_HEX;
		  if (w_AFULL = '1' and w_EMPTY = '0' and w_FULL = '0' and r_RD_EN = '0') then
			r_RD_EN <= '1';
			r_WR_EN <= '0';
		  else
			r_RD_EN <= '0';
			r_WR_EN <= '1';
		  end if;
		  --r_RD_EN <= '1';
		  v_OUTPUT_HEX := W_DIV; --is this possible
		  write(v_OLINE, v_OUTPUT_HEX, right, c_WIDTH);
		  writeline(file_RESULTS, v_OLINE);
		  
		end loop;




	 
		file_close(file_VECTORS);
		file_close(file_RESULTS);
     
    wait;
	end process;
   
   
end behave;

