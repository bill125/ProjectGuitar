library IEEE;
use IEEE.std_logic_1164.all;
use work.definitions.all;
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity test is
  port (
    i_clk: in std_logic;   
    o_noteLevel : out integer range 0 to 88;
 i_key1 : out std_logic_vector(7 downto 0);
 i_noteLevel1 : out integer range 0 to 88;
 i_RX_DV1, i_noteGen_RX_DV1 : out std_logic;
    stx : out std_logic_vector(1 downto 0);
    --notes : out Noise;
    o_TX_DV : out std_logic;
    index1 : out integer range 0 to MaxLength;
    cnt1 : out integer;
    intvls1 : out integer range 0 to MaxIntervals
   );
end entity test;

architecture beh of test is
--component Programme is
--  port (
--	impulse_in : in std_logic;
--	key_in : in std_logic_vector(7 downto 0);
--   prog : out integer range 0 to 127
--   );
--end component;

component Looper is
  generic (
    g_looper_index : integer range 0 to 7:= 1;     -- Needs to be set correctly
    record_key : std_logic_vector(7 downto 0);
    play_key : std_logic_vector(7 downto 0);
    g_CLKS_PER_INTERVAl : integer := 10000000
    );
  port (
    i_RX_DV, i_clk, i_noteGen_RX_DV : in std_logic;
    i_key : in std_logic_vector(7 downto 0);
    i_noteLevel : in integer range 0 to 88;
    o_noteLevel : out integer range 0 to 88;
    stx : out std_logic_vector(1 downto 0);
    --notes1 : out Noise;
    o_TX_DV : out std_logic;
    index1 : out integer range 0 to MaxLength;
    cnt1 : out integer;
    intvls1 : out integer range 0 to MaxIntervals
	);
end component;
component FreqDiv is
    generic
    (
        div : integer := 50;
        half : integer := 25 
    );
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        O: out std_logic
    );
end component;
signal i_key : std_logic_vector(7 downto 0);
signal i_noteLevel : integer range 0 to 88;
signal i_RX_DV, i_noteGen_RX_DV : std_logic;
signal o_clk : std_logic;
--signal notes : integer range 0 to 88;
begin
f: FreqDiv
generic map(50, 25)
port map(i_clk, '0', o_clk);
	i_key1 <= i_key;
	i_noteLevel1 <= i_noteLevel;
	i_RX_DV1 <= i_RX_DV;
	i_noteGen_RX_DV1 <= i_noteGen_RX_DV;
	process (o_clk) is
	variable cnt : integer := 0;
	begin
		if falling_edge(o_clk) then
			case cnt is 
			when 0 =>
				i_key <= x"15";
				i_RX_DV <= '1';
			when 1 =>
				i_RX_DV <= '0';
			when 40 =>
				i_key <= x"15";
				i_RX_DV <= '1';
			when 41 =>
				i_RX_DV <= '0';
			when 42 =>
				i_RX_DV <= '1';
				i_key <= x"1C";
			when 43 =>
				i_RX_DV <= '0';
			when others =>
				i_noteGen_RX_DV <= not i_noteGen_RX_DV;
				i_noteLevel <= cnt;
			end case;
			cnt := cnt + 1;
		end if;
	end process;
	i1: Looper 
	generic map(1, x"15", x"1C", 9) --Q,A 
	port map(i_RX_DV, i_clk, i_noteGen_RX_DV, i_key, i_noteLevel, o_noteLevel, stx,  o_TX_DV, index1, cnt1, intvls1);
end architecture beh;