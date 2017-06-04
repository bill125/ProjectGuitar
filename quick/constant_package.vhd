library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package definitions is
	subtype StringStatus is std_logic_vector(7 downto 0);
	type GuitarStatus is array (0 to 5) of StringStatus;
end package	definitions;