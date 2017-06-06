library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity main is
port(
  clk_50: in std_logic;
  q: out std_logic_VECTOR(23 downto 0);
  address_o: out std_logic_vector(9 downto 0)
);

end entity main;
architecture beh of main is

component rom24 IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
END component;

signal address_tmp : std_logic_vector(9 downto 0);
signal q_tmp: std_logic_VECTOR(23 downto 0);
begin
  address_o <= address_tmp;
  q<=q_tmp;
  process (clk_50) is
  begin
    if rising_edge(clk_50) then
      if q_tmp(0) = '1' then
        address_tmp <= (others => '0');
      else 
        address_tmp <= address_tmp + '1';
      end if;
    end if;
  end process;
u2: rom24 port map(	
						address=>address_tmp, 
						clock=>clk_50, 
						q=>q_tmp
					);
end beh;
