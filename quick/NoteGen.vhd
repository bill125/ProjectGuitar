library IEEE;
use work.definitions.all;
use IEEE.std_logic_1164.all;
entity NoteGen is
	port (
	triggeredString : in integer range 0 to 5;
	strings : in GuitarStatus;
	impulse_in, hclk : in std_logic;
	noteLevel : out integer range 0 to 88;
	impulse_out : out std_logic
	);
End entity NoteGen;

architecture beh of NoteGen is
  signal delay_clk1 : std_logic := impulse_in;
  signal delay_clk2 : std_logic := impulse_in;
  --signal delay_clk3 : std_logic = '0';
begin
  process (hclk) is
  begin
    delay_clk1 <= impulse_in;
    delay_clk2 <= delay_clk1;
    impulse_out <= delay_clk2;
  end process;
  noteLevel <= strings(triggeredString);
  -- process (impulse_in) is
  -- begin
  --   if rising_edge(impulse_in) then
      
  --   end if;
    
  -- end process;
    
end architecture beh;
