library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

entity looper is
  generic (
    g_looper_index : integer range 0 to 7:= 1;     -- Needs to be set correctly
    record_key : std_logic_vector(7 downto 0);
    play_key : std_logic_vector(7 downto 0);
    g_CLKS_PER_INTERVAl : integer := 10000000     -- Needs to be set correctly. e.g. interval=0.1s, clks=100mhz, 0.1*100m=10m.
    );
  port (
    i_RX_DV, i_clk, i_noteGen_RX_DV : in std_logic;
    i_key : in std_logic_vector(7 downto 0);
    i_noteLevel : in integer range 0 to 88;
    o_noteLevel : out integer range 0 to 88;
    stx : out integer range 0 to 3;
    --notes1 : out Noise;
    o_TX_DV : out std_logic;
    index1 : out integer range 0 to MaxLength;
    cnt1 : out integer;
    intvls1 : out integer range 0 to MaxIntervals
    --cntId1 : out IntArray
	);
end entity looper;
architecture beh of looper is
  type t_SM_Main is (s_Idle, s_Record, s_Play,
                     s_Cleanup);
  constant MaxWaitTimes : integer := 31;
  signal notes : Noise;
  signal cntId : IntArray;
  signal r_SM_Main : t_SM_Main := s_Idle;
  signal l_i_RX_DV : std_logic := i_RX_DV;
  signal l_i_noteGen_RX_DV : std_logic := i_noteGen_RX_DV;
  --signal o_RX_DV1 : std_logic;
  signal cnt : integer; --TODO: range?
  signal index, end_index : integer range 0 to MaxLength;
begin
index1 <= index;
cnt1 <= cnt;
--cntId1 <= cntId;
	-- notes1 <= notes;
	process (r_SM_Main) is
begin
	case r_SM_Main is
	when s_Idle => stx <= 0;
	when s_Record => stx <= 1;
	when s_Play => stx <= 2;
	when s_Cleanup => stx <= 3;
	end case;
end process;
  process (i_clk) is
    variable intvls : integer range 0 to MaxIntervals;
    variable pause_times : integer range 0 to MaxWaitTimes := 0;
  begin
	intvls1 <= intvls;
    if rising_edge(i_clk) then
      case r_SM_Main is
        when s_Idle =>
		  intvls := 0;
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
            end_index <= index - 1;
			cntId(0) <= intvls;
          elsif l_i_noteGen_RX_DV /= i_noteGen_RX_DV and i_noteGen_RX_DV = '1' then
            notes(index) <= i_noteLevel;
            if index > 0 then
				cntId(index) <= intvls;
			end if;
            index <= index + 1;
            r_SM_Main <= s_Record;
            intvls := 0;
          end if;       
          if index > 0 or (l_i_noteGen_RX_DV /= i_noteGen_RX_DV and i_noteGen_RX_DV = '1') then
			if cnt = g_CLKS_PER_INTERVAl - 1 then
				intvls := intvls + 1;
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
          end if;
        when s_Play =>
          if l_i_RX_DV /= i_RX_DV and i_RX_DV = '1' and i_key = play_key then --stop playing
            r_SM_Main <= s_Idle;
          elsif intvls = cntId(index) then
            o_noteLevel <= notes(index);
            if index >= end_index then index <= 0;
            else index <= index + 1;
            end if;
            pause_times := MaxWaitTimes;
            o_TX_DV <= '1';
            r_SM_Main <= s_Play;
            intvls := 0;
          else
            r_SM_Main <= s_Play;
          end if;
		  if cnt = g_CLKS_PER_INTERVAl - 1 then
			intvls := intvls + 1;
			cnt <= 0;
		  else
			cnt <= cnt + 1;
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
      l_i_noteGen_RX_DV <= i_noteGen_RX_DV;
    end if;    
  end process;  
end architecture beh;
