library IEEE;
use IEEE.std_logic_1164.all;
entity ImpulseGen is
	 generic 
	 ( 
	 pausePeriod: integer range 0 to 63 := 10
	 );
	port (
		start : in std_logic;
		hclk : in std_logic;
		clk_out : out std_logic := '0'
	);
end entity ImpulseGen;
	
architecture beh of ImpulseGen is
    signal cnt: integer range 0 to 63 := pausePeriod + 1;
begin
  process (hclk) is
	 variable pre_start: std_logic := start;
  begin
    if rising_edge(hclk) then
      if start /= pre_start then
        cnt <= 0;
		  clk_out <= '0';
      elsif cnt <= pausePeriod then
        cnt <= cnt + 1;
        if cnt = pausePeriod - 1 then
          clk_out <= '1';
		  elsif cnt >= pausePeriod then
			 clk_out <= '0';
        end if;        
      end if;  
		pre_start := start;
	 end if;
  end process;
end architecture beh;
