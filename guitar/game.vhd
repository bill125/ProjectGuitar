library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.definitions.all;
entity game is
  generic (
    should_send_to_uart : std_logic := '0';
    identifier : std_logic := '0';
    play_key : std_logic_vector(7 downto 0):=x"77";
    delay_intvls : integer := 200;
    g_CLKS_PER_INTERVAl : integer := 10000000     -- Needs to be set correctly. e.g. interval=0.1s, clks=100mhz, 0.1*100m=10m.
    );
  port (
    i_RX_DV, i_clk, i_TX_Done : in std_logic;
    i_key : in std_logic_vector(7 downto 0);
    i_data : in std_logic_vector(DataBits - 1 downto 0);
    i_noteLevel : in integer range 0 to 88;
    o_address : out std_logic_vector(AddressBits - 1 downto 0);
    o_noteLevel : out integer range 0 to 88;
    o_note_pos : out integer range 0 to 5;
    stx, sstx : out integer range 0 to 3;
    o_TX_DV : out std_logic;
    index1 : out integer range 0 to MaxLength;
    cnt1 : out integer;
    wait_times_out : out integer range 0 to 31;
    intvls1 : out integer range 0 to MaxIntervals
    --cntId1 : out IntArray
	);
  function get_note_pos(noteLevel: integer range 0 to 88) return integer is
  begin
    if noteLevel >= 64 then
      return 0;
    elsif noteLevel >= 59 then
      return 1;
    elsif noteLevel >= 55 then
      return 2;
    elsif noteLevel >= 50 then
      return 3;
    elsif noteLevel >= 45 then
      return 4;
    else return 5;
    end if;
  end get_note_pos;

end entity game;
architecture beh of game is
  type t_SM_Main is (s_Idle, s_Record, s_Play, s_Cleanup);
  type ss_Status is (ss_Send_Done, ss_Sending, ss_Waiting);
  constant MaxWaitTimes : integer := 31;
  -- signal notes : Noise;
  -- signal cntId : IntArray;
  signal address : std_logic_vector(AddressBits - 1 downto 0);
  signal noteLevel : integer range 0 to 127;
  signal notePos : integer range 0 to 5;
  signal cntId : integer range 0 to MaxIntervals;
  signal r_SM_Main : t_SM_Main := s_Idle;
  signal ss : ss_Status := ss_Send_Done;
  signal l_i_RX_DV : std_logic := i_RX_DV;
  signal l_i_TX_Done : std_logic := i_TX_Done;
  --signal o_RX_DV1 : std_logic;
  signal index: integer range 0 to MaxLength := 0;
  signal end_index : integer range -1 to MaxLength;
begin
	process (ss) is
begin
	case ss is
	when ss_Send_Done => sstx <= 0;
	when ss_Waiting => sstx <= 1;
	when ss_Sending => sstx <= 2;
	end case;
end process;
process (r_SM_Main) is
begin
	case r_SM_Main is
	when s_Idle => stx <= 0;
	when s_Record => stx <= 1;
	when s_Play => stx <= 2;
	when s_Cleanup => stx <= 3;
	end case;
end process;
--data :
-- note(7bit)
-- interval(10bit)
-- pos(3bit)
-- end(1bit)
--address <= conv_std_logic_vector(index, address_bits);
noteLevel <= to_integer(unsigned(i_data(20 downto 14)));
cntId <= to_integer(unsigned(i_data(13 downto 4)));
notePos <= to_integer(unsigned(i_data(3 downto 1)));
o_address <= address;
  process (i_clk) is
    variable intvls: integer range -MaxIntervals * 2 to MaxIntervals := 0;
    variable pause_times, wait_times : integer range 0 to MaxWaitTimes := 0;
    variable cnt : integer := 0;
  begin
    cnt1 <= cnt;
	intvls1 <= intvls;
    if rising_edge(i_clk) then
      case r_SM_Main is
        when s_Idle =>
		  intvls := -delay_intvls;
          cnt := 0;
          o_TX_DV <= '0';
          -- index <= 0;
          address <= (others => '0');
          if l_i_RX_DV /= i_RX_DV and i_RX_DV = '1' then
            case i_key is
              when play_key =>
                wait_times := 0;
                ss <= ss_Send_Done;
                r_SM_Main <= s_Play;
              when others =>
                r_SM_Main <= s_Idle;
            end case;
          else r_SM_Main <= s_Idle;
          end if;
        when s_Play =>
          if l_i_RX_DV /= i_RX_DV and i_RX_DV = '1' and i_key = play_key then --stop playing
            r_SM_Main <= s_Idle;
          elsif intvls = cntId then
            r_SM_Main <= s_Play;
            case ss is
              when ss_Send_Done =>
                o_TX_DV <= '1';
                o_noteLevel <= noteLevel;
                o_note_pos <= notePos;
                -- index <= index + 1;
                if i_data(0) = '1' then --end
                  address <= (others => '0');
                else
                  address <= address + '1';
                end if;
                pause_times := MaxWaitTimes;
                intvls := 0;
                cnt := 0;
                if should_send_to_uart = '1' then --play
                  ss <= ss_Sending;
                else
                  ss <= ss_Waiting;
                  wait_times := 0;
                end if;
              when ss_Sending =>
                if l_i_TX_Done /= i_TX_Done and i_TX_Done = '0' then
                  ss <= ss_Waiting;
                  wait_times := 0;
                else
                  ss <= ss_Sending;
                end if;
              when ss_Waiting =>
                if wait_times = MaxWaitTimes then
                  ss <= ss_Send_Done;
                  wait_times := 0;
                else
                  wait_times := wait_times + 1;
                  ss <= ss_Waiting;
                end if;
              when others =>
                ss <= ss_Send_Done;
            end case;
          else
            wait_times := 0;
            ss <= ss_Send_Done;
            r_SM_Main <= s_Play;
          end if;
		  if cnt = g_CLKS_PER_INTERVAl - 1 then
			intvls := intvls + 1;
			cnt := 0;
		  else
			cnt := cnt + 1;
		  end if;
        --when s_Cleanup =>;
        when others =>
          r_SM_Main <= s_Idle;
      end case;
      if pause_times > 0 then
        pause_times := pause_times - 1;
        if pause_times = 0 then
          o_TX_DV <= '0';
        end if;
      end if;
      l_i_RX_DV <= i_RX_DV;
      l_i_TX_Done <= i_TX_Done;
    end if;    
  end process;  
end architecture beh;
