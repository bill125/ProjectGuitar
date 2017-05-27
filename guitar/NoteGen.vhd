library IEEE;
use work.definitions.all;
use IEEE.std_logic_1164.all;
entity NoteGen is
	port (
	i_triggeredString : in integer range 0 to 5;
	i_strings : in GuitarStatus;
	i_RX_DV, i_clk : in std_logic;
	i_noteLevel : out integer range 0 to 88;
	o_TX_DV : out std_logic
	);
End entity NoteGen;

architecture beh of NoteGen is
  signal delay_clk1 : std_logic := i_RX_DV;
  signal delay_clk2 : std_logic := i_RX_DV;
  --signal delay_clk3 : std_logic = '0';
begin
  process (i_clk) is
  begin
    delay_clk1 <= i_RX_DV;
    delay_clk2 <= delay_clk1;
    o_TX_DV <= delay_clk2;
  end process;
  i_noteLevel <= i_strings(i_triggeredString);
  -- process (i_RX_DV) is
  -- begin
  --   if rising_edge(i_RX_DV) then
      
  --   end if;
    
  -- end process;
    
end architecture beh;
