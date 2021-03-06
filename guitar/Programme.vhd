library IEEE;
use IEEE.std_logic_1164.all;
use work.definitions.all;
entity Programme is
  port (
	i_RX_DV : in std_logic;
	i_key : in std_logic_vector(7 downto 0);
    o_prog : out Loopers127Array
   );
end entity Programme;

architecture beh of Programme is
  signal stx : integer range 0 to 4;--0: init, 1: ready to read the first bit, 2,3...
begin
  process(i_RX_DV) is
    variable key_num : integer range 0 to 127;
    variable res : integer range 0 to 127;
    variable looper_id : integer range 0 to MaxLoopers;
  begin
    if rising_edge(i_RX_DV) then
      if i_key = x"4D" then
        if stx = 0 then stx <= stx + 1; res := 0; end if;
      elsif stx > 0 then
        key_num := convert_key(i_key);
        if key_num >= 0 then
          if stx = 1 then
            looper_id := key_num;
            stx <= stx + 1;
          else
            res := res * 10 + key_num;
            if stx >= 4 then
              o_prog(looper_id) <= res;
              stx <= 0;
            else
              stx <= stx + 1;
            end if;          
          end if;
        end if;
      end if;      
    end if;    
  end process;
end architecture beh;
