library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity KeyboardAdapter is
	generic (
		string_0 : std_logic_vector(7 downto 0) := "01001011"; -- 'L' : 4B
		string_1 : std_logic_vector(7 downto 0) := "01000010"; -- 'K' : 42
		string_2 : std_logic_vector(7 downto 0) := "00111011"; -- 'J' : 3B
		string_3 : std_logic_vector(7 downto 0) := "00111010"; -- 'M' : 3A
		string_4 : std_logic_vector(7 downto 0) := "00110001"; -- 'N' : 31
		string_5 : std_logic_vector(7 downto 0) := "00110010"  -- 'B' : 32
	);
	port (
		i_key : in std_logic_vector(7 downto 0);
		i_clk, hclk : in std_logic;
		o_key : out std_logic_vector(7 downto 0);
		o_triggeredString : out integer range 0 to 5;
		o_clk : out std_logic
	);
end KeyboardAdapter;
 
architecture KeyboardAdapter_bhv of KeyboardAdapter is

begin
	o_key <= i_key;
	receive_trigger : process(hclk)
		variable ignore_status : std_logic := '0';
		variable l_clk : std_logic := '0';
		variable wait_times : integer := 0;
	begin
		if (hclk'event and hclk = '1') then 
			if wait_times >= 1 then
				wait_times := wait_times - 1;
				if wait_times <= 5 then
					o_clk <= '1';
				else
					o_clk <= '0';
				end if;
			else
				o_clk <= '0';
			end if;
			
			if l_clk = '0' and i_clk = '1' then
				if ignore_status = '1' then
					ignore_status := '0';
				elsif i_key = "11110000" then 
					ignore_status := '1';
				else
					wait_times := 20;
					case i_key is
						when string_0 => o_triggeredString <= 0;
						when string_1 => o_triggeredString <= 1;
						when string_2 => o_triggeredString <= 2;
						when string_3 => o_triggeredString <= 3;
						when string_4 => o_triggeredString <= 4;
						when string_5 => o_triggeredString <= 5;
						when others => 
							wait_times := 0;
							o_triggeredString <= 0;
					end case;
				end if;
			end if;
			
			l_clk := i_clk;
		end if;
	end process;
end KeyboardAdapter_bhv;
