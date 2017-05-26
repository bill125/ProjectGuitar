library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

entity main is
	port (
		i_KB_Data, clk_100m, fclk, rst_in : in std_logic;
		seg0, seg1 : out std_logic_vector(6 downto 0)
	);
end entity main;

architecture main_bhv of main is
--	component uart
--		port (
--			i_Clk       : in  std_logic;
--			i_RX_Serial : in  std_logic;
--			o_RX_DV     : out std_logic;
--			o_RX_Byte   : out std_logic_vector(7 downto 0)
--		);
--	end component uart;
--	
--	component uart_adapter
--		port (
--			i_RX_DV   : in std_logic;
--			i_RX_Byte : in std_logic_vector(7 downto 0)		
--		);
--	end component uart_adapter;
--	
	component KeyboardInput
		port (
			datain, clkin, fclk, rst_in : in std_logic;
			key_out : out std_logic_vector(6 downto 0);
			seg0, seg1 : out std_logic_vector(6 downto 0)
		);
	end component KeyboardInput;
			
	component KeyboardAdapter
		port (
			i_key : in std_logic_vector(7 downto 0),
			i_clk, hclk : in std_logic;
			o_key : out std_logic_vector(7 downto 0);
			o_triggeredString : out integer range 0 to 5;
			o_clk : out std_logic;
		);
	end component KeyboardAdapter;

signal t_key : std_logic_vector(6 downto 0); 
signal raw_kb_clk, a_kb_clk : std_logic;
signal triggeredString : integer range 0 to 5;
begin
	u0 : KeyboardInput 
	port map (
		datain => i_KB_data,
		clkin => clkin,
		filter_clk => clk_100m,
		rst_in => rst_in,
		key_out => t_key,
		seg0 => seg0,
		seg1 => seg1,
		clk_out => raw_kb_clk
	);
	
	u1 : KeyboardAdapter
	port map (
		i_key => t_key,
		i_clk => raw_kb_clk,
		hclk => clk_100m,
		o_triggeredString => triggeredString,
		o_clk => a_kb_clk
	);
end architecture main_bhv;