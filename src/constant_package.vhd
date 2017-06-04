library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package definitions is
	subtype StringStatus is std_logic_vector(7 downto 0);
	type GuitarStatus is array (0 to 5) of StringStatus;
	
	type NoteBlocks is array (0 to 63) of integer range 0 to 1023;
	type ShiningStripes is array (0 to 5) of integer range 0 to 1023;
    constant MaxLength : integer := 25; --TODO
    constant MaxIntervals : integer := 511;
    type Noise is array (0 to MaxLength) of integer range 0 to 88;
    type IntArray is array (0 to MaxLength) of integer range 0 to MaxIntervals;--TODO: range?
    function convert_key(i_key: in std_logic_vector(7 downto 0)) return integer;
end package	definitions;

package body definitions is
  function convert_key(i_key: in std_logic_vector(7 downto 0)) return integer is
  begin
   case i_key is
     when x"45" => return 0;
     when x"16" => return 1;
     when x"1E" => return 2;
     when x"26" => return 3;
     when x"25" => return 4;
     when x"2E" => return 5;
     when x"36" => return 6;
     when x"3D" => return 7;
     when x"3E" => return 8;
     when x"46" => return 9;
     when others => return -1;
   end case;
  end convert_key;
  --constant MaxLength : integer := 10;
end package body definitions;
