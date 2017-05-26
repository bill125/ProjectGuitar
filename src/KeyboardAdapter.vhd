library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity KeyboardAdapter is
	generic (
		string_0 : logic_vector(7 downto 0) := "01001011"; -- 'L' : 4B
		string_1 : logic_vector(7 downto 0) := "01000010"; -- 'K' : 42
		string_2 : logic_vector(7 downto 0) := "00111011"; -- 'J' : 3B
		string_3 : logic_vector(7 downto 0) := "00110010"; -- 'B' : 32
		string_4 : logic_vector(7 downto 0) := "00110001"; -- 'N' : 31
		string_5 : logic_vector(7 downto 0) := "00110110"; -- 'M' : 3A
	);
	port (
		i_key : in std_logic_vector(7 downto 0),
		i_clk, hclk : in std_logic;
		o_key : out std_logic_vector(7 downto 0);
		o_triggeredString : out integer range 0 to 5;
		o_clk : out std_logic;
	);
end KeyboardAdapter;
 
architecture KeyboardAdapter_bhv of KeyboardAdapter is
variable ignore_status : std_logic := '0';
begin
	o_key <= i_key;
	receive_trigger : process(clk_in)
	begin
		if (clk_in'event and clk_in = '1') then begin
			if ignore_status = '1' then
				ignore_status = '0';
			elsif i_key = "11110000" then begin
				ignore_status = '1';
			else
				case i_key is
					when string_0 => o_triggeredString <= 0;
					when string_1 => o_triggeredString <= 1;
					when string_2 => o_triggeredString <= 2;
					when string_3 => o_triggeredString <= 3;
					when string_4 => o_triggeredString <= 4;
					when string_5 => o_triggeredString <= 5;
					when others => o_triggeredString <= 0;
				end case;
				-- generate impulse
			end;
		end;
	end;
end KeyboardAdapter_bhv;