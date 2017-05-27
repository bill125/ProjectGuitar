library IEEE;
use IEEE.std_logic_1164.all;
entity test is
  port (
	impulse_in, start : in std_logic;
	start_out : out std_logic;
	clk_in : in std_logic;
	test : out integer range 0 to 63;
	clk : out std_logic := '0'
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

component ImpulseGen is
	generic 
	 ( 
	 pausePeriod: integer range 0 to 63 := 10
	 );
	port (
		start : in std_logic;
		hclk : in std_logic;
		test : out integer range 0 to 63;
		clk_out : out std_logic
	);
end component;
begin
	i1: ImpulseGen 
	generic map(3) 
	port map(start, impulse_in, test, clk);
	start_out <= start;
end architecture beh;