entity ImpulseGen is
	 generic 
	 ( 
	 pausePeriod: integer := 10
	 );
	port (
		start : inout std_logic;
		hclk : in std_logic;
		clk : inout std_logic
	);
end entity ImpulseGen;
	
architecture beh of ImpulseGen is
begin
  process (hclk) is
    variable cnt: integer := 0;
  begin
    if rising_edge(hclk) then
      if start = '1' then
        start <= '0';
        cnt := 0;
      elsif cnt <= pausePeriod then
        cnt := cnt + 1;
        if cnt >= pausePeriod then
          clk <= not clk;
        end if;        
      end if;      
  end process;
  
end architecture beh;
