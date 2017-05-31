library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

entity looper is
  generic (
    g_looper_index : integer range 0 to 7:= 1;     -- Needs to be set correctly
    record_key : std_logic_vector(7 downto 0);
    play_key : std_logic_vector(7 downto 0)
    );
  port (
    i_RX_DV, i_clk, i_noteGen_RX_DV : in std_logic;
    i_key : in std_logic_vector(7 downto 0);
    i_noteLevel : in integer range 0 to 88;
    o_noteLevel : out integer range 0 to 88;
    stx : out std_logic_vector(1 downto 0);
    notes1 : out Noise;
    o_TX_DV : out std_logic;
    index1 : out integer range 0 to MaxLength;
    cnt1 : out integer;
    cntId1 : out IntArray
	);
end entity looper;
architecture beh of looper is
  type t_SM_Main is (s_Idle, s_Record, s_Play,
                     s_Cleanup);
  signal notes : Noise;
  signal cntId : IntArray;
  signal r_SM_Main : t_SM_Main := s_Idle;
  signal l_i_RX_DV : std_logic := i_RX_DV;
  signal l_i_noteGen_RX_DV : std_logic := i_noteGen_RX_DV;
  --signal o_RX_DV1 : std_logic;
  signal cnt, end_cnt : integer; --TODO: range?
  signal index : integer range 0 to MaxLength;
begin
index1 <= index;
	process (r_SM_Main) is
begin
	case r_SM_Main is
	when s_Idle => stx <= "00";
	when s_Record => stx <= "01";
	when s_Play => stx <= "10";
	when s_Cleanup => stx <= "11";
	end case;
end process;
cnt1 <= cnt;
cntId1 <= cntId;
  process (i_clk) is
  begin
    if rising_edge(i_clk) then
      case r_SM_Main is
        when s_Idle =>
          cnt <= 0;
          o_TX_DV <= '0';
          index <= 0;
          if l_i_RX_DV /= i_RX_DV and i_RX_DV = '1' then
            case i_key is
              when record_key =>
                r_SM_Main <= s_Record;
              when play_key =>
                r_SM_Main <= s_Play;
              when others =>
                r_SM_Main <= s_Idle;
            end case;
          else r_SM_Main <= s_Idle;
          end if;
        when s_Record =>
          if l_i_RX_DV /= i_RX_DV and i_RX_DV = '1' and i_key = record_key then --stop recording
            r_SM_Main <= s_Idle;
            end_cnt <= cnt;
          elsif l_i_noteGen_RX_DV /= i_noteGen_RX_DV then
            notes(index) <= i_noteLevel;
            cntId(index) <= cnt;
            index <= index + 1;
            r_SM_Main <= s_Record;
          end if;       
          if index > 0 or l_i_noteGen_RX_DV /= i_noteGen_RX_DV then
            cnt <= cnt + 1;
          end if;
        when s_Play =>
          if l_i_RX_DV /= i_RX_DV and i_RX_DV = '1' and i_key = play_key then --stop playing
            r_SM_Main <= s_Idle;
          elsif cnt = cntId(index) then
            o_noteLevel <= notes(index);
            index <= index + 1;
            o_TX_DV <= '1';
            r_SM_Main <= s_Play;
          else
            o_TX_DV <= '0';
            r_SM_Main <= s_Play;
          end if;
          if cnt >= end_cnt then 
			cnt <= 0;
			index <= 0;
          else cnt <= cnt + 1;
          end if;
        --when s_Cleanup =>;
        when others =>
          r_SM_Main <= s_Idle;
      end case;
      l_i_RX_DV <= i_RX_DV;
      l_i_noteGen_RX_DV <= i_noteGen_RX_DV;
    end if;    
  end process;  
	notes1 <= notes;
end architecture beh;
