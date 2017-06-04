library ieee;
use ieee.std_logic_1164.all;

entity Velocity is
  generic (
    up_key : std_logic_vector(7 downto 0) := x"75";
    down_key : std_logic_vector(7 downto 0) := x"72";
    default : integer range 0 to 127 := 64
    );
	port (
		i_RX_DV : in std_logic;
		i_key : in std_logic_vector(7 downto 0);
		o_vel : out integer range 0 to 127
	);
end Velocity;

architecture Velocity_bhv of Velocity is
signal vel : integer range 0 to 127 := default;
begin
	o_vel <= vel;
	monitor : process (i_RX_DV)
	begin
		if (i_RX_DV'event and i_RX_DV = '1') then
			if i_key = up_key then -- '8 on pad' : 75
				if vel <= 126 then
					vel <= vel + 1;
				else
					vel <= vel;
				end if;
			elsif i_key = down_key then -- '2 on pad' : 72
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
