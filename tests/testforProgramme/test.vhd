library IEEE;
use IEEE.std_logic_1164.all;
entity test is
  port (
	impulse_in : in std_logic;
	keys_out : out std_logic_vector(7 downto 0);
	cnt_out : out integer range 0 to 3;
   result : out integer range 0 to 127
   );
end entity test;

architecture beh of test is
component Programme is
  port (
	impulse_in : in std_logic;
	key_in : in std_logic_vector(7 downto 0);
   prog : out integer range 0 to 127
   );
end component;
signal cnt : integer range 0 to 3 := 0;
signal keys : std_logic_vector(7 downto 0) := x"4D";
begin
	process (impulse_in) is 
	begin
		if falling_edge(impulse_in) then
		case cnt is 
		when 0 => keys <= x"45";
		when 1 => keys <= x"16";
		when 2 => keys <= x"36";
		when others => keys <= x"46";
		end case;
		if cnt < 2 then
			cnt <= cnt + 1;
		else
			cnt <= 0;
		end if;
		end if;
	end process;
	p1:Programme port map(impulse_in, keys, result);
	keys_out <= keys;
	cnt_out <= cnt;
end architecture beh;