library IEEE;
use IEEE.std_logic_1164.all;
entity Programme is
  port (
	impulse_in : in std_logic;
	key_in : in std_logic_vector(7 downto 0);
   prog : out integer range 0 to 127
   );
  function convert_key(key_in: in std_logic_vector(7 downto 0)) return integer is
  begin
   case key_in is
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
end entity Programme;

architecture beh of Programme is
  signal stx : integer range 0 to 3;--0: init, 1: ready to read the first bit, 2,3...
begin
  process(impulse_in) is
    variable key_num : integer;
    variable res : integer;
  begin
    if rising_edge(impulse_in) then
      if key_in = x"4D" then
        if stx = 0 then stx <= stx + 1; res := 0; end if;
      elsif stx > 0 then
        key_num := convert_key(key_in);
        if key_num >= 0 then
          res := res * 10 + key_num;
          if stx >= 3 then
            prog <= res;
            stx <= 0;
          else
            stx <= stx + 1;
          end if;          
        end if;
      end if;      
    end if;    
  end process;
end architecture beh;
