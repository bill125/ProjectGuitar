-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
-- use work.definitions.all;

--entity main is
--  port (
--    i_clk : in std_logic;
--	seg0, seg1 : out integer range 0 to 88
--	);
--end entity main;
--
--architecture beh of main is
--  signal cnt : integer range 0 to 300 := 0;
--  signal cnt1 : integer range 0 to 88 := 0;
--  signal notes : Noise;
--begin
--  process (i_clk) is
--  begin
--    if rising_edge(i_clk) then
--      notes(cnt) <= cnt1;
--      if cnt1 = 88 then cnt1 <= 0;
--      else cnt1 <= cnt1 + 1;
--      end if;
--      if cnt = 300 then cnt <= 0;
--      else cnt <= cnt + 1;
--	  end if;
--    end if;
--  end process;
--  process (i_clk) is
--      variable cnt2 : integer range 0 to 300 := 0;
--	begin
--	if falling_edge(i_clk) then
--      seg0 <= notes(cnt2);
--      cnt2 := cnt;
--      end if;
--      end process;
--  
--end architecture beh;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

entity main is
  port (
    i_KB_Data, clk_100m, clk_in, rst_in, r_uart_RX_Serial : in std_logic;
    w_uart_TX_Serial : out std_logic;
    seg0, seg1, seg2, seg_base : out std_logic_vector(6 downto 0);		
    o_clicked : out std_logic;
    o_hs,o_vs : out std_logic; 
    o_RED,o_GREEN,o_BLUE : out std_logic_vector(2 downto 0);
    o_cnt : out integer range 0 to 4;
    noteLevel : out integer range 0 to 127;
    triggeredString : out integer range 0 to 15;
    strings : out GuitarStatus;
    notegen_RX_DV : out std_logic;
    clk_25m_out,clk_1k : out std_logic;
    note_gen_TX_DV1 : out std_logic;
    uart_out_a_TX_Done1 : out std_logic;
    stx1 : out integer range 0 to 3;
    noteLevel_TX_DV1 : out std_logic;
    clk_out : out std_logic;
    looper_TX_DV1 : out std_logic_vector(0 to MaxLoopers);
    sstx : out integer range 0 to 3;
    wait_times_out : out integer range 0 to 31;
    raw_kb_TX_DV1 : out std_logic
 	);
end entity main;

architecture main_bhv of main is
	component VGAController is
		port(
			i_kb_clk    :         in std_logic;
			i_note_clk  :         in std_logic;
			i_note_pos  :         in integer range 0 to 5;
			i_triggeredString :  in integer range 0 to 15; 
			address		:		  out	STD_LOGIC_VECTOR(14 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			q		    :		  in STD_LOGIC;
			clk         :         in  STD_LOGIC; --25M
			clk_100m    :         in std_logic;
			hs,vs       :         out STD_LOGIC; 
			o_clicked : out std_logic;
			r, g, b       :         out STD_LOGIC_vector(2 downto 0)
		);
	end component VGAController;
  component looper is
    generic (
      g_looper_index : integer range 0 to 7:= 1;     -- Needs to be set correctly
      record_key : std_logic_vector(7 downto 0);
      play_key : std_logic_vector(7 downto 0);
      g_CLKS_PER_INTERVAl : integer := 10000000     -- Needs to be set correctly. e.g. interval=0.1s, clks=100mhz, 0.1*100m=10m.
      );
    port (
      i_RX_DV, i_clk, i_noteGen_RX_DV, i_TX_Done : in std_logic;
      i_key : in std_logic_vector(7 downto 0);
      i_noteLevel : in integer range 0 to 127;
      o_noteLevel : out integer range 0 to 127;
      stx, sstx : out integer range 0 to 3;
      --notes1 : out Noise;
      o_TX_DV : out std_logic;
      index1 : out integer range 0 to MaxLength;
      cnt1 : out integer;
      wait_times_out : out integer range 0 to 31;
      intvls1 : out integer range 0 to MaxIntervals
     --cntId1 : out IntArray
      );
  end component looper;
  component seg7
		port(
			code: in std_logic_vector(3 downto 0);
			seg_out : out std_logic_vector(6 downto 0)
		);
	end component seg7;
    component FreqDiv is
    generic
      (
        div : integer := 50;
        half : integer := 25 
        );
    port
      (
        CLK: in std_logic;
        RST: in std_logic;
        O: out std_logic
        );
  end component;
  
  component ImpulseGen is
    generic 
      ( 
        pausePeriod: integer range 0 to 63 := 10
        );
    port (
      start : in std_logic;
      hclk : in std_logic;
      clk_out : out std_logic := '0'
      );
  end component ImpulseGen;

  component NoteGen is
    port (
      i_triggeredString : in integer range 0 to 15;
      i_strings : in GuitarStatus;
      i_RX_DV, i_clk, i_TX_Done : in std_logic;
      o_noteLevel : out integer range 0 to 127;
      o_TX_DV : out std_logic;
      stx1 : out integer range 0 to 2
      );
  end component NoteGen;

  component Programme is
    port (
      i_RX_DV : in std_logic;
      i_key : in std_logic_vector(7 downto 0);
      o_prog : out Loopers127Array
      );
  end component Programme;

  component Velocity is
    generic (
      up_key : std_logic_vector(7 downto 0) := x"75";
      down_key : std_logic_vector(7 downto 0) := x"72";
      default : integer range 0 to 127 := 64
      );
    port (
      i_RX_DV : in std_logic;
      i_key : in std_logic_vector(7 downto 0);
      o_vel : out integer range 0 to 127
      );
  end component Velocity;

  component KeyboardInput
    port (
      datain, clkin, fclk, rst_in : in std_logic;
      key_out : out std_logic_vector(7 downto 0);
      seg0, seg1 : out std_logic_vector(6 downto 0);
      clk_out : out std_logic
      );
  end component KeyboardInput;

  component KeyboardAdapter
    port (
      i_key : in std_logic_vector(7 downto 0);
      i_clk, hclk : in std_logic;
      o_key : out std_logic_vector(7 downto 0);
      o_triggeredString : out integer range 0 to 15;
      o_clk, o_all_clk : out std_logic
      );
  end component KeyboardAdapter;

  component UARTIn is
    generic (
      g_CLKS_PER_BIT : integer := 868     -- Needs to be set correctly
      );
    port (
      i_Clk       : in  std_logic;
      i_RX_Serial : in  std_logic;
      o_RX_DV     : out std_logic;
      o_RX_Byte   : out std_logic_vector(7 downto 0)
      );
  end component UARTIn;

  component UARTInAdapter is
	port (
          i_RX_DV : in std_logic;
          i_Byte : in std_logic_vector(7 downto 0);
          o_strings : out GuitarStatus
          );
  end component UARTInAdapter;

  component UARTOutAdapter is
	port (
          i_Clk : in std_logic;
          i_TX_DV : in std_logic;
          i_Byte_done : in std_logic;
          i_isOn : in integer range 0 to 15; --channel in fact
          i_noteLevel : in integer range 0 to 127;
          i_vel  : in integer range 0 to 255;
          i_prog : in integer range 0 to 255;
          o_TX_Byte : out std_logic_vector(7 downto 0);
          o_TX_DV : out std_logic
          );
  end component UARTOutAdapter;

  component UARTOut is
    generic (
      g_CLKS_PER_BIT : integer := 868     -- Needs to be set correctly
      );
    port (
      i_Clk       : in  std_logic;
      i_TX_DV     : in  std_logic;
      i_TX_Byte   : in  std_logic_vector(7 downto 0);
      o_TX_Active : out std_logic;
      o_TX_Serial : out std_logic;
      o_TX_Done   : out std_logic
      );
  end component UARTOut;
  component game is
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
    i_noteLevel : in integer range 0 to 127;
    o_address : out std_logic_vector(AddressBits - 1 downto 0);
    o_noteLevel : out integer range 0 to 127;
    o_note_pos : out integer range 0 to 5;
    stx, sstx : out integer range 0 to 3;
    o_TX_DV : out std_logic;
    index1 : out integer range 0 to MaxLength;
    cnt1 : out integer;
    wait_times_out : out integer range 0 to 31;
    intvls1 : out integer range 0 to RomMaxIntervals
    --cntId1 : out IntArray
	);
  end component game;
    
    component bgm1 IS
      PORT
        (
          address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
          clock		: IN STD_LOGIC ;
          q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
          );
    END component;
    component show1 IS
      PORT
        (
          address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
          clock		: IN STD_LOGIC ;
          q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
          );
    END component;
    component bgm2 IS
      PORT
        (
          address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
          clock		: IN STD_LOGIC ;
          q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
          );
    END component;
    component show2 IS
      PORT
        (
          address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
          clock		: IN STD_LOGIC ;
          q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
          );
    END component;

  
  signal t_key : std_logic_vector(7 downto 0);
  signal clk, clk_25m : std_logic;
  -- data valid clocks
  signal raw_kb_TX_DV, a_kb_TX_DV, a_kb_all_TX_DV : std_logic := '0'; -- keyboard
  signal uart_in_TX_DV : std_logic := '0';
  signal looper_TX_DV : std_logic_vector(0 to MaxLoopers) := (others => '0');
  signal note_gen_TX_DV, noteLevel_TX_DV, game_bgm_TX_DV, game_show_TX_DV, game_show_ss_TX_DV : std_logic := '0';
  signal uart_out_a_TX_DV : std_logic := '0';
  signal uart_out_TX_Done : std_logic := '0';
    signal uart_out_a_TX_Done : std_logic := '0';
    -- rom
    signal rom_bgm1_address, rom_show1_address, rom_show1_ss_address : std_logic_vector(AddressBits - 1 downto 0);
    signal rom_bgm2_address, rom_show2_address, rom_show2_ss_address : std_logic_vector(AddressBits - 1 downto 0);
    signal rom_bgm_address, rom_show_address, rom_show_ss_address : std_logic_vector(AddressBits - 1 downto 0);
    signal rom_bgm1_data, rom_show1_data, rom_show1_ss_data : std_logic_vector(DataBits - 1 downto 0);
    signal rom_bgm2_data, rom_show2_data, rom_show2_ss_data : std_logic_vector(DataBits - 1 downto 0);
    signal rom_bgm_data, rom_show_data, rom_show_ss_data : std_logic_vector(DataBits - 1 downto 0);
  -- guitar properties
  signal gu_triggeredString, gu_chn : integer range 0 to 15;
  signal gu_prog : integer range 0 to 127;
  signal gu_progs : Loopers127Array;
  signal gu_strings, uart_in_a_strings : GuitarStatus;
  signal gu_vel : integer range 0 to 127;
  signal gu_base_note : integer range 0 to 127 := 0;
  signal gu_vels : Loopers127Array;
  signal note_gen_noteLevel, gu_noteLevel, game_bgm_noteLevel, game_show_ss_noteLevel, note_gen_noteLevel_plus : integer range 0 to 127;
  signal game_show_note_pos, game_show_ss_note_pos : integer range 0 to 5;
  signal looper_noteLevel : Loopers127Array;
  -- uart
  signal uart_out_a_byte : std_logic_vector(7 downto 0);
  signal uart_in_byte : std_logic_vector(7 downto 0);
  -- debug
  signal t_cnt : integer range 0 to 4;

begin
  raw_kb_TX_DV1 <= raw_kb_TX_DV;
  f_1: FreqDiv
    generic map(100, 50)
    port map(clk_100m, '0', clk);--1m
  f_25: FreqDiv
    generic map(4, 2)
    port map(clk_100m, '0', clk_25m);--1m
  clk_25m_out <= clk_25m;
  -- f_1k: FreqDiv
  --   generic map(1000, 500)
  --   port map(clk_100m, '0', clk_1k);--1m

  -- 9981
  rom_show1_inst : show1
    port map (
      address => rom_show1_address,
      clock => clk_100m,
      q => rom_show1_data
      );
  rom_show1_ss_inst : show1
    port map (
      address => rom_show1_ss_address,
      clock => clk_100m,
      q => rom_show1_ss_data
      );

  rom_bgm1_inst : bgm1
    port map (
      address => rom_bgm1_address,
      clock => clk_100m,
      q => rom_bgm1_data
      );

  -- white album
  rom_show2_inst : show2
    port map (
      address => rom_show2_address,
      clock => clk_100m,
      q => rom_show2_data
      );
  rom_show2_ss_inst : show2
    port map (
      address => rom_show2_ss_address,
      clock => clk_100m,
      q => rom_show2_ss_data
      );

  rom_bgm2_inst : bgm2
    port map (
      address => rom_bgm2_address,
      clock => clk_100m,
      q => rom_bgm2_data
      );

  u0 : KeyboardInput 
 	port map (
      datain => i_KB_data,
      clkin => clk_in,
      fclk => clk_100m,
      rst_in => rst_in,
      key_out => t_key,
      -- seg0 => seg0,
      -- seg1 => seg1,
      clk_out => raw_kb_TX_DV
      );
  
  u1 : KeyboardAdapter
 	port map (
      i_key => t_key,
      i_clk => raw_kb_TX_DV,
      hclk => clk_100m,
      o_triggeredString => gu_triggeredString,
      o_clk => a_kb_TX_DV,
      o_all_clk => a_kb_all_TX_DV
      );

  uart_in : UARTIn
    generic map (
      g_CLKS_PER_BIT => 868-- Needs to be set correctly
      )
    port map (
      i_Clk => clk_100m, -- TODO: reduce frequency maybe
      i_RX_Serial => r_uart_RX_Serial,
      o_RX_DV => uart_in_TX_DV,
      o_RX_Byte => uart_in_byte
      );

  uart_in_adapter : UARTInAdapter
    port map (
      i_RX_DV => uart_in_TX_DV,
      i_Byte => uart_in_byte,
      o_strings => uart_in_a_strings
      );
  

  note_gen : NoteGen
    port map (
      i_triggeredString => gu_triggeredString,
      i_strings => gu_strings,
      i_RX_DV => a_kb_TX_DV,
      i_clk => clk_100m, -- TODO: reduce frequency
      i_TX_Done => uart_out_a_TX_Done,
      o_noteLevel => note_gen_noteLevel,
      o_TX_DV => note_gen_TX_DV
      -- stx1 => stx1
      );

  vga1 : VGAController
    port map ( 
    	i_kb_clk => a_kb_TX_DV,
    	i_note_clk => game_show_TX_DV,
    	i_note_pos => game_show_note_pos,
    	i_triggeredString => gu_triggeredString,
    	reset => '1',  
    	clk => clk_25m, 
    	clk_100m => clk_100m,
    	q => '0',
    	 hs => o_hs, 
    	 vs => o_vs, 
    	 r => o_RED, 
    	 g => o_GREEN, 
    	 b => o_BLUE
    );

  game_bgm : game
    generic map (
      should_send_to_uart => '1',
      play_key => x"21", --C
      identifier => '0',
      delay_intvls => 200, --200(required by drop time) + 450(required by song)
      g_CLKS_PER_INTERVAl => CLKS_PER_INTERVAL -- 25000000 / 100 i.e. 10ms/intvl
      )
    port map (
      i_RX_DV => a_kb_all_TX_DV,
      i_clk => clk_25m,
      i_key => t_key,
      i_data => rom_bgm_data,
      i_TX_Done => uart_out_a_TX_Done,
      i_noteLevel => gu_noteLevel,
      o_address => rom_bgm_address,
      o_noteLevel => game_bgm_noteLevel,
      o_TX_DV => game_bgm_TX_DV
      -- stx => stx1,
      -- sstx => sstx
      -- wait_times_out => wait_times_out
      );
  game_show : game
    generic map (
      should_send_to_uart => '0',
      play_key => x"21", --C
      identifier => '1',
      delay_intvls => 0,
      g_CLKS_PER_INTERVAl => CLKS_PER_INTERVAL -- 4*25000000 / 100 i.e. 10ms/intvl
      )
    port map (
      i_RX_DV => a_kb_all_TX_DV,
      i_clk => clk_25m,
      i_key => t_key,
      i_data => rom_show_data,
      i_TX_Done => uart_out_a_TX_Done,
      i_noteLevel => gu_noteLevel,
      o_TX_DV => game_show_TX_DV,
      o_address => rom_show_address,
      o_note_pos => game_show_note_pos
      -- wait_times_out => wait_times_out
      );
  game_show_set_strings : game
    generic map (
      should_send_to_uart => '0',
      play_key => x"21", --C
      identifier => '1',
      delay_intvls => 180,
      g_CLKS_PER_INTERVAl => CLKS_PER_INTERVAL -- 4*25000000 / 100 i.e. 10ms/intvl
      )
    port map (
      i_RX_DV => a_kb_all_TX_DV,
      i_clk => clk_25m,
      i_key => t_key,
      i_data => rom_show_ss_data,
      i_TX_Done => uart_out_a_TX_Done,
      i_noteLevel => gu_noteLevel,
      o_address => rom_show_ss_address,
      o_noteLevel => game_show_ss_noteLevel,
      o_note_pos => game_show_ss_note_pos,
      o_TX_DV => game_show_ss_TX_DV
      -- wait_times_out => wait_times_out
      );
  note_gen_noteLevel_plus <= note_gen_noteLevel + gu_base_note;
  looper_inst0 : looper
    generic map (
      g_looper_index => 1,
      record_key => x"3A", --M
      play_key => x"1C", --A
      g_CLKS_PER_INTERVAl => 1000000 -- 4*25000000 / 100 i.e. 10ms/intvl
      )
    port map (
      i_RX_DV => a_kb_all_TX_DV,
      i_clk => clk_100m,
      i_noteGen_RX_DV => note_gen_TX_DV,
      i_key => t_key,
      i_TX_Done => uart_out_a_TX_Done,
      i_noteLevel => note_gen_noteLevel_plus,
      o_noteLevel => looper_noteLevel(0),
      o_TX_DV => looper_TX_DV(0)
      -- stx => stx1,
      -- sstx => sstx,
      -- wait_times_out => wait_times_out
      );
  -- looper_inst1 : looper
  --   generic map (
  --     g_looper_index => 1,
  --     record_key => x"41", --,
  --     play_key => x"1B", --S
  --     g_CLKS_PER_INTERVAl => 1000000 -- 4*25000000 / 100
  --     )
  --   port map (
  --     i_RX_DV => a_kb_all_TX_DV,
  --     i_clk => clk_100m,
  --     i_noteGen_RX_DV => note_gen_TX_DV,
  --     i_key => t_key,
  --     i_TX_Done => uart_out_a_TX_Done,
  --     i_noteLevel => note_gen_noteLevel_plus,
  --     o_noteLevel => looper_noteLevel(1),
  --     o_TX_DV => looper_TX_DV(1),
  --     stx => stx1,
  --     sstx => sstx,
  --     wait_times_out => wait_times_out
  --     );
  -- looper_inst2 : looper
  --   generic map (
  --     g_looper_index => 1,
  --     record_key => x"49", --.
  --     play_key => x"23", --D
  --     g_CLKS_PER_INTERVAl => 1000000 -- 4*25000000 / 100
  --     )
  --   port map (
  --     i_RX_DV => a_kb_all_TX_DV,
  --     i_clk => clk_100m,
  --     i_noteGen_RX_DV => note_gen_TX_DV,
  --     i_key => t_key,
  --     i_TX_Done => uart_out_a_TX_Done,
  --     i_noteLevel => note_gen_noteLevel_plus,
  --     o_noteLevel => looper_noteLevel(2),
  --     o_TX_DV => looper_TX_DV(2)
  --     -- stx => stx1,
  --     -- sstx => sstx,
  --     -- wait_times_out => wait_times_out
  --     );

  gu_strings_process: process (clk_100m) is
    variable stx : integer range 0 to 1 := 0;
    variable free_mode_triggeredString : integer range 0 to 5 := 0;
    variable l_a_kb_all_TX_DV : std_logic := a_kb_all_TX_DV;
    variable l_game_show_ss_TX_DV : std_logic := game_show_ss_TX_DV;
  begin
    if rising_edge(clk_100m) then
      if free_mode_triggeredString = 0 then
        rom_show_ss_address <= rom_show1_ss_address;
        rom_show_ss_data <= rom_show1_ss_data;
        rom_bgm_address <= rom_bgm1_address;
        rom_bgm_data <= rom_bgm1_data;
        rom_show_address <= rom_show1_address;
        rom_show_data <= rom_show1_data;
      else
        rom_show_ss_address <= rom_show2_ss_address;
        rom_show_ss_data <= rom_show2_ss_data;
        rom_bgm_address <= rom_bgm2_address;
        rom_bgm_data <= rom_bgm2_data;
        rom_show_address <= rom_show2_address;
        rom_show_data <= rom_show2_data;
      end if;
      if l_a_kb_all_TX_DV = '0' and a_kb_all_TX_DV = '1' then
        if t_key = x"21" then
          stx := stx + 1;
        end if;
      end if;
      case stx is
        when 0 =>
          free_mode_triggeredString := gu_triggeredString;
          gu_strings <= uart_in_a_strings;
        when 1 =>
          if game_show_ss_TX_DV = '1' and l_game_show_ss_TX_DV = '0' then
            gu_strings(5 - game_show_ss_note_pos) <= conv_std_logic_vector(game_show_ss_noteLevel, 8);
          end if;
      end case;
      l_a_kb_all_TX_DV := a_kb_all_TX_DV;
      l_game_show_ss_TX_DV := game_show_ss_TX_DV;
    end if;
  end process;
  
  gu_noteLevel_process: process (clk_25m) is
    variable l_note_gen_TX_DV : std_logic := note_gen_TX_DV;
    variable l_game_bgm_TX_DV : std_logic := game_bgm_TX_DV;
    variable l_looper_TX_DV : std_logic_vector(0 to MaxLoopers) := looper_TX_DV;
  begin
    if rising_edge(clk_25m) then
      if l_note_gen_TX_DV /= note_gen_TX_DV and note_gen_TX_DV = '1' then
        gu_noteLevel <= note_gen_noteLevel + gu_base_note;
        gu_vel <= gu_vels(0);
        gu_prog <= gu_progs(0);
        gu_chn <= 0;
      elsif l_game_bgm_TX_DV /= game_bgm_TX_DV and game_bgm_TX_DV = '1' then
        gu_noteLevel <= game_bgm_noteLevel + gu_base_note;
        gu_vel <= gu_vels(3);
        gu_prog <= gu_progs(3);
        gu_chn <= 4;
      elsif l_looper_TX_DV(0) /= looper_TX_DV(0) and looper_TX_DV(0) = '1' then
        gu_noteLevel <= looper_noteLevel(0);
        gu_vel <= gu_vels(1);
        gu_prog <= gu_progs(1);
        gu_chn <= 1;
      elsif l_looper_TX_DV(1) /= looper_TX_DV(1) and looper_TX_DV(1) = '1' then
        gu_noteLevel <= looper_noteLevel(1);
        gu_vel <= gu_vels(2);
        gu_prog <= gu_progs(2);
        gu_chn <= 2;
      elsif l_looper_TX_DV(2) /= looper_TX_DV(2) and looper_TX_DV(2) = '1' then
        gu_noteLevel <= looper_noteLevel(2);
        gu_vel <= gu_vels(3);
        gu_prog <= gu_progs(3);
        gu_chn <= 3;
      end if;
      l_note_gen_TX_DV := note_gen_TX_DV;
      l_game_bgm_TX_DV := game_bgm_TX_DV;
      l_looper_TX_DV := looper_TX_DV;
      noteLevel_TX_DV <= note_gen_TX_DV or looper_TX_DV(0) or looper_TX_DV(1) or looper_TX_DV(2) or game_bgm_TX_DV;
    end if;
  end process;
  -- debug
  noteLevel_TX_DV1 <= noteLevel_TX_DV;
  looper_TX_DV1 <= looper_TX_DV;
  note_gen_TX_DV1 <= note_gen_TX_DV;
  triggeredString <= gu_triggeredString;
  noteLevel <= gu_noteLevel;
  strings <= gu_strings;
  notegen_RX_DV <= a_kb_TX_DV;
  uart_out_a_TX_Done1 <= uart_out_a_TX_Done;
  
  programme_inst : Programme
    port map (
      i_RX_DV => a_kb_all_TX_DV,
      i_key => t_key,
      o_prog => gu_progs
      );

  velocity_inst0 : Velocity
    generic map (
      up_key => x"74", --6 on pad
      down_key => x"6B" --4 on pad
      )
    port map (
      i_RX_DV => raw_kb_TX_DV,
      i_key => t_key,
      o_vel => gu_vels(0)
      );
  velocity_inst1 : Velocity
    generic map (
      up_key => x"6C", --7 on pad
      down_key => x"69" --1 on pad
      )
    port map (
      i_RX_DV => raw_kb_TX_DV,
      i_key => t_key,
      o_vel => gu_vels(1)
      );
  velocity_inst2 : Velocity
    generic map (
      up_key => x"75", --8 on pad
      down_key => x"72" --2 on pad
      )
    port map (
      i_RX_DV => raw_kb_TX_DV,
      i_key => t_key,
      o_vel => gu_vels(2)
      );
  velocity_inst3 : Velocity
    generic map (
      up_key => x"7D", --9 on pad
      down_key => x"7A" --3 on pad
      )
    port map (
      i_RX_DV => raw_kb_TX_DV,
      i_key => t_key,
      o_vel => gu_vels(3)
      );
  capo_inst3 : Velocity
    generic map (
      up_key => x"1A", --9 on pad
      down_key => x"22", --3 on pad
      default => 0
      )
    port map (
      i_RX_DV => a_kb_all_TX_DV,
      i_key => t_key,
      o_vel => gu_base_note
      );
  
  uart_out_adapter : UARTOutAdapter
    port map (
              i_Clk => clk_100m,
              i_isOn => gu_chn,
              i_noteLevel => gu_noteLevel,
              i_vel => gu_vel,
              i_prog => gu_prog,
              i_Byte_done => uart_out_TX_Done,
              i_TX_DV => noteLevel_TX_DV,
              o_TX_Byte => uart_out_a_byte,
              o_TX_DV => uart_out_a_TX_DV
              );
  u4 : seg7 port map (gu_strings(0)(3 downto 0), seg0);
  u5 : seg7 port map (gu_strings(0)(7 downto 4), seg1);
  u2 : seg7 port map (conv_std_logic_vector(gu_triggeredString, 4), seg2);
  -- o_cnt <= t_cnt;
  -- clk_out <= uart_out_a_TX_DV;
  
  uart_out : UARTOut
    generic map (
      g_CLKS_PER_BIT => 868 -- TODO: Need to be set correctly
      )
    port map (
      i_Clk => clk_100m,
      i_TX_DV => uart_out_a_TX_DV,
      i_TX_Byte => uart_out_a_byte,
      o_TX_Active => open,
      o_TX_Serial => w_uart_TX_Serial,
      o_TX_Done => uart_out_TX_Done
      );

end architecture main_bhv;
