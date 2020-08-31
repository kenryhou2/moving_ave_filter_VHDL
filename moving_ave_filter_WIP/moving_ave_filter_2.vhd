
--source code for moving average filter VHDL exercise
--Henry Kou 1153814
--06.24.20

--Implementation Notes:
--Circular 32 pt. Register based FIFO Buffer with flags, E,F.
--Further additions: AE, AF flags, burst
--Added summer and divider for all terms inside of FIFO for average functionality.
--Interfacing filter with IO to text files in tb.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--inputs and outputs
entity moving_ave_filter is
	generic ( --scope??
	g_WIDTH : natural := 8;
	g_DEPTH : integer := 128; --128 pt filter
	g_A_EMPTY_LEVEL : natural := 2;
	g_A_FULL_LEVEL  : natural := 126
	);
	port(	
	i_rst_sync : in std_logic;
	i_clock		:in std_logic;
	--write interface --input into FIFO
	i_wr_en		: in std_logic;
	i_wr_data	: in std_logic_vector(g_WIDTH-1 downto 0); --little endian
	o_full_flag	: out std_logic;
	o_almost_full_flag	: out std_logic;

	--read interface --output from FIFO
	i_rd_en		: in std_logic;
	o_rd_data	: out std_logic_vector(g_WIDTH-1 downto 0); --little endian
	o_empty_flag	: out std_logic;
	o_almost_empty_flag : out std_logic;
	o_sum2		: out std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0); 
	o_div		: out std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0); 
	o_sum		: out std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0) 
	
	);
end moving_ave_filter;

architecture rtl of moving_ave_filter is
--declarations
type t_FIFO_DATA is array (0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0); --declaring array data type.
signal r_FIFO_DATA : t_FIFO_DATA := (others=> (others => '0')); --r_FIFO_DATA is the body of the FIFO buffer composed of g_DEPTH registers (4 at the moment)
--constants
--constant c_WR_CLK_100Hz 	: natural := 250000;
--constant c_RD_CLK_100Hz 	: natural := 250000;
--define global clock?

--Read/Write Pointers/Registers (indexers)
signal r_rd_ptr	: integer range 0 to g_DEPTH-1 :=0; --range 0-31, init to 0
signal r_wr_ptr	: integer range 0 to g_DEPTH-1 :=0; --range 0-31, init to 0 //variable?????

--output flags
signal w_FULL_FLAG		: std_logic; 		--initialized to zero....... for a wire???? maybe not.
signal w_EMPTY_FLAG		: std_logic;

signal r_DATA_CNT		: integer range -1 to g_DEPTH+1 := 0; --extra range to detect underflow/overflow of buffer
signal r_temp_sum		: std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0) := (others => '0');
signal w_A_EMPTY_FLAG		: std_logic;
signal w_A_FULL_FLAG		: std_logic;
begin --architecture

--SEQUENTIAL LOGIC
	--controls indexing of read and write pointers, reset condition, and detection of flag events
	P_CONTROL : process(i_clock) is
	begin
		--reset (synchronous)
		if rising_edge(i_clock) then
			if i_rst_sync = '1' then
				r_DATA_CNT <= 0;
				r_rd_ptr <= 0;
				r_wr_ptr <= 0;
			else


   				if (i_wr_en = '1' and i_rd_en = '0') then
					r_DATA_CNT <= r_DATA_CNT + 1; 
				elsif (i_rd_en = '1' and i_wr_en = '0') then
					r_DATA_CNT <= r_DATA_CNT - 1;
				end if;
				--write pointer
				--if rising_edge(i_clock) then --no rising edge clk here
				if (i_wr_en = '1' and w_FULL_FLAG = '0') then
					if r_wr_ptr = g_DEPTH-1 then
						r_wr_ptr <= 0;
					else
						r_wr_ptr <= r_wr_ptr + 1;
					end if;
				end if;
				--end if;
		
				--read pointer
				--if rising_edge(i_clock) then
				if (i_rd_en = '1' and w_EMPTY_FLAG = '0') then
					if r_rd_ptr = g_DEPTH-1 then
						r_rd_ptr <= 0;
					else
						r_rd_ptr <= r_rd_ptr + 1;
						--r_DATA_CNT <= r_DATA_CNT - 1; 
					end if;
				end if;
				if i_wr_en = '1' then
					r_FIFO_DATA(r_wr_ptr) <= i_wr_data;
					--r_DATA_CNT <= r_DATA_CNT + 1; 
				end if;
				--end if;
			end if; -- sync reset
		end if; --rising_edge(i_clock)
	end process P_CONTROL;



--
--o_sum <= std_logic_vector(
--resize(unsigned(r_FIFO_DATA(0)), o_sum'length) + unsigned(r_FIFO_DATA(1)) + unsigned(r_FIFO_DATA(2)) + unsigned(r_FIFO_DATA(3)) 
--+ unsigned(r_FIFO_DATA(4)) + unsigned(r_FIFO_DATA(5)) + unsigned(r_FIFO_DATA(6)) + unsigned(r_FIFO_DATA(7)) 
--+ unsigned(r_FIFO_DATA(8)) + unsigned(r_FIFO_DATA(9)) + unsigned(r_FIFO_DATA(10)) + unsigned(r_FIFO_DATA(11))
--+ unsigned(r_FIFO_DATA(12)) + unsigned(r_FIFO_DATA(13)) + unsigned(r_FIFO_DATA(14)) + unsigned(r_FIFO_DATA(15))
--+ unsigned(r_FIFO_DATA(16)) + unsigned(r_FIFO_DATA(17)) + unsigned(r_FIFO_DATA(18)) + unsigned(r_FIFO_DATA(19))
--+ unsigned(r_FIFO_DATA(20)) + unsigned(r_FIFO_DATA(21)) + unsigned(r_FIFO_DATA(22)) + unsigned(r_FIFO_DATA(23))
--+ unsigned(r_FIFO_DATA(24)) + unsigned(r_FIFO_DATA(25)) + unsigned(r_FIFO_DATA(26)) + unsigned(r_FIFO_DATA(27))
--+ unsigned(r_FIFO_DATA(28)) + unsigned(r_FIFO_DATA(29)) + unsigned(r_FIFO_DATA(30)) + unsigned(r_FIFO_DATA(31))
--);
----:=X"0000000000000000000000000000000000";
p_summer : process(r_FIFO_DATA)

	variable v_temp_sum : std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0) := (others => '0');
	variable v_prev_sum : std_logic_vector(g_WIDTH+g_DEPTH-1 downto 0) := (others => '0');
begin
	v_temp_sum := std_logic_vector(resize(unsigned(r_FIFO_DATA(0)), v_temp_sum'length));
	
	for ii in 1 to g_DEPTH-1 loop
		v_prev_sum := v_temp_sum;
		v_temp_sum := std_logic_vector( resize((unsigned(r_FIFO_DATA(ii))), v_prev_sum'length) + unsigned(v_prev_sum) );
	end loop;
	o_sum <= v_temp_sum;
	r_temp_sum <= v_temp_sum;
	--division
	o_div <= std_logic_vector(shift_right(unsigned(v_temp_sum), 7));
end process;


--COMBINATIONAL LOGIC
o_rd_data <= r_FIFO_DATA(r_rd_ptr); --constantly spouting the value at the read pointer location.

w_FULL_FLAG <= '1' when r_DATA_CNT = g_DEPTH else '0';
w_EMPTY_FLAG <= '1' when r_DATA_CNT = 0 else '0';
w_A_EMPTY_FLAG <= '1' when r_DATA_CNT < g_A_EMPTY_LEVEL else '0';
w_A_FULL_FLAG <= '1' when r_DATA_CNT > g_A_FULL_LEVEL else '0';
o_almost_full_flag <= w_A_FULL_FLAG;
o_almost_empty_flag <= w_A_EMPTY_FLAG;
o_full_flag <= w_FULL_FLAG;
o_empty_flag <= w_EMPTY_FLAG;


	P_ASSERT : process(i_clock) is
	begin
		if rising_edge(i_clock) then
			if (i_wr_en = '1' and w_FULL_FLAG = '1') then
				report "Writing to buffer when full" severity failure;
			end if;
			
			if (i_rd_en = '1' and w_EMPTY_FLAG = '1') then
				report "Reading from empty buffer" severity failure;
			end if;
		end if;
	end process P_ASSERT;


	
end rtl;