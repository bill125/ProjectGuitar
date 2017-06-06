library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;

entity UARTInAdapter is
	port (
		i_RX_DV : in std_logic;
		i_Byte : in std_logic_vector(7 downto 0);
		o_strings : out GuitarStatus
	);
end UARTInAdapter;

architecture UARTInAdapter_bhv of UARTInAdapter is
signal t_Guitar : GuitarStatus;
begin
  --o_strings <= t_Guitar;
	FSM : process (i_RX_DV)
		variable cnt : integer range 0 to 5 := 5;
	begin
		if rising_edge(i_RX_DV) then
			o_strings(cnt) <= i_Byte;
			if cnt = 0 then
				cnt := 5;
			else
				cnt := cnt - 1;
			end if;
		end if;
	end process;
end UARTInAdapter_bhv;
