library IEEE;
use work.definitions.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity NoteGen is
	port (
	i_triggeredString : in integer range 0 to 5;
	i_strings : in GuitarStatus;
	i_RX_DV, i_clk : in std_logic;
	o_noteLevel : out integer range 0 to 88;
	o_TX_DV : out std_logic
	);
End entity NoteGen;

architecture beh of NoteGen is
  signal delay_clk1 : std_logic := i_RX_DV;
  signal delay_clk2 : std_logic := i_RX_DV;
  --signal delay_clk3 : std_logic = '0';
begin
  -- process (i_clk) is
  -- begin
  --   if rising_edge(i_clk) then
  --   delay_clk1 <= i_RX_DV;
  --   delay_clk2 <= delay_clk1;
  --   o_TX_DV <= delay_clk2;
  --   end if;
  -- end process;
  o_TX_DV <= i_RX_DV;
  process (i_RX_DV) is
  begin
    if rising_edge(i_RX_DV) then
      o_noteLevel <= to_integer(unsigned(i_strings(i_triggeredString)));
    end if;
      
  end process;
  
  -- process (i_RX_DV) is
  -- begin
  --   if rising_edge(i_RX_DV) then
      
  --   end if;
    
  -- end process;
    
end architecture beh;
