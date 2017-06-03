library IEEE;
use work.definitions.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity NoteGen is
	port (
	i_triggeredString : in integer range 0 to 15;
	i_strings : in GuitarStatus;
	i_RX_DV, i_clk, i_TX_Done : in std_logic;
	o_noteLevel : out integer range 0 to 88;
	o_TX_DV : out std_logic;
    stx1 : out integer range 0 to 2
	);
end entity NoteGen;

architecture beh of NoteGen is
  constant MaxWaitTimes : integer := 31;
  constant HalfMaxWaitTimes : integer := 15;
  signal cnt : integer range -1 to 5 := 0;
  signal l_i_RX_DV : std_logic := i_RX_DV;
  signal l_i_TX_Done : std_logic := i_TX_Done;  
  type t_SM_Main is (s_Idle, s_Datas, s_Wait_For_DV);
  signal stx : t_SM_Main := s_Idle;
  --signal delay_clk3 : std_logic = '0';
begin
  process (i_clk) is
    variable wait_times : integer range 0 to MaxWaitTimes := 0;
    variable pause_times : integer range 0 to MaxWaitTimes := 0;
  begin
    if rising_edge(i_clk) then
  case stx is
when s_Idle=>
  stx1 <= 0;
  when s_Datas=>
  stx1 <= 1;
  when s_Wait_For_DV=>
  stx1 <= 2;
  end case;
  if pause_times > 0 then
    pause_times := pause_times - 1;
  else
      case stx is
        when s_Idle =>
          if l_i_RX_DV /= i_RX_DV and i_RX_DV = '1' then
            if i_triggeredString >= 6 then
              cnt <= i_triggeredString - 3;
              stx <= s_Datas;
            else
              o_TX_DV <= '1';
              wait_times := MaxWaitTimes;
              o_noteLevel <= to_integer(unsigned(i_strings(i_triggeredString)));
              stx <= s_Idle;
            end if;
          end if;
        when s_Datas =>
          o_TX_DV <= '1';
          wait_times := MaxWaitTimes;
          o_noteLevel <= to_integer(unsigned(i_strings(cnt)));
          cnt <= cnt - 1;
          stx <= s_Wait_For_DV;
        when s_Wait_For_DV =>
          if l_i_TX_Done /= i_TX_Done and i_TX_Done = '0' then
            if cnt < 0 then
              stx <= s_Idle;
            else
              stx <= s_Datas;
              pause_times := MaxWaitTimes;
            end if;
          else
            stx <= s_Wait_For_DV;
          end if;
        when others =>
          stx <= s_Idle;
      end case;
      if wait_times = 0 then
        o_TX_DV <= '0';
      else
        wait_times := wait_times - 1;
      end if;
      l_i_RX_DV <= i_RX_DV;
      l_i_TX_Done <= i_TX_Done;
  end if;
    end if;
  end process;
  -- o_TX_DV <= i_RX_DV;
  -- process (i_RX_DV) is
  -- begin
  --   if rising_edge(i_RX_DV) then
  --     o_noteLevel <= to_integer(unsigned(i_strings(i_triggeredString)));
  --   end if;
      
  -- end process;
  
  -- process (i_RX_DV) is
  -- begin
  --   if rising_edge(i_RX_DV) then
      
  --   end if;
    
  -- end process;
    
end architecture beh;
