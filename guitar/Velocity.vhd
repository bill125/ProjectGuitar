library ieee;
use ieee.std_logic_1164.all;

entity Velocity is
	port (
		i_clk : in std_logic;
		i_key : in std_logic_vector(7 downto 0);
		o_vel : out integer range 0 to 127
	);
end Velocity;

architecture Velocity_bhv of Velocity is
signal vel : integer range 0 to 127 := 64;
begin
	o_vel <= vel;
	monitor : process (i_clk)
	begin
		if (i_clk'event and i_clk = '1') then
			if i_key = "01110010" then -- '8 on pad' : 72
				if vel <= 126 then
					vel <= vel + 1;
				else
					vel <= vel;
				end if;
			elsif i_key = "01110101" then -- '2 on pad' : 75
				if vel >= 1 then
					vel <= vel - 1;
				else
					vel <= vel;
				end if;
			else
				vel <= vel;
			end if;
		end if;
	end process;
end Velocity_bhv;