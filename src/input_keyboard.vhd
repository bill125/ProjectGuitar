library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity input_keyboard is
port(
	datain,clkin,fclk,rst_in: in std_logic;
	seg0, seg1:out std_logic_vector(6 downto 0)
);
end input_keyboard;

architecture behave of input_keyboard is
component Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
--	fok : out std_logic ;  -- data output enable signal
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end component ;

component seg7 is
port(
	code: in std_logic_vector(3 downto 0);
	seg_out : out std_logic_vector(6 downto 0)
);
end component;

signal scancode : std_logic_vector(7 downto 0);
signal rst : std_logic;
signal clk_f: std_logic;
begin
rst<=not rst_in;

u0: Keyboard port map(datain,clkin,fclk,rst,scancode);
u1: seg7 port map(scancode(3 downto 0),seg0);
u2: seg7 port map(scancode(7 downto 4),seg1);

end behave;

