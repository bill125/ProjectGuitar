library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

entity main is
	port (
		i_KB_Data, clkin, fclk, rst_in : in std_logic;
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
	component input_keyboard
		port (
			datain,clkin,fclk,rst_in: in std_logic;
			seg0, seg1:out std_logic_vector(6 downto 0)
		);
	end component input_keyboard;
			
	
begin
--		i_KB_Data, clkin, fclk, rst_in : in std_logic;
--		seg0, seg1 : out std_logic_vector(6 downto 0)
	keyboard_test : input_keyboard 
	port map (
		datain => i_KB_data,
		clkin => clkin,
		fclk => fclk,
		rst_in => rst_in,
		seg0 => seg0,
		seg1 => seg1
	);
end architecture main_bhv;