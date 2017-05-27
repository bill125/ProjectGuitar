library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.definitions.all;

entity UARTInAdapter is
	port (
		hclk : in std_logic;
		i_Byte : in std_logic_vector(7 downto 0);
		o_strings : out GuitarStatus
	);
end UARTInAdapter;

architecture UARTInAdapter_bhv of UARTInAdapter is
signal t_Guitar : GuitarStatus;
begin
	o_strings <= t_Guitar;
	FSM : process (hclk)
		variable cnt : integer range 0 to 5 := 5;
		variable p_Byte : std_logic_vector(7 downto 0) := "00000000";
	begin
		if (hclk'event and hclk = '1' and i_Byte /= p_Byte) then
			t_Guitar(cnt) <= i_Byte; 
			if cnt = 0 then
				cnt := 5;
			else
				cnt := cnt - 1;
			end if;
			p_Byte := i_Byte;
		end if;
	end process;
end UARTInAdapter_bhv;