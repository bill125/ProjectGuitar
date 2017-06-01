library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use work.definitions.all;

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
    seg0, seg1, seg2 : out std_logic_vector(6 downto 0);
    o_cnt : out integer range 0 to 4;
    noteLevel : out integer range 0 to 88;
      triggeredString : out integer range 0 to 5;
      strings : out GuitarStatus;
      notegen_RX_DV : out std_logic;
    
    clk_out : out std_logic
 	);
end entity main;

architecture main_bhv of main is
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
      i_triggeredString : in integer range 0 to 5;
      i_strings : in GuitarStatus;
      i_RX_DV, i_clk : in std_logic;
      o_noteLevel : out integer range 0 to 88;
      o_TX_DV : out std_logic
      );
  end component NoteGen;

  component Programme is
    port (
      i_RX_DV : in std_logic;
      i_key : in std_logic_vector(7 downto 0);
      o_prog : out integer range 0 to 127
      );
  end component Programme;

  component Velocity is
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
      o_triggeredString : out integer range 0 to 5;
      o_clk : out std_logic
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
          i_isOn : in std_logic;
          i_noteLevel : in integer range 0 to 88;
          i_vel  : in integer range 0 to 255;
          i_prog : in integer range 0 to 255;
          o_TX_Byte : out std_logic_vector(7 downto 0);
          o_TX_DV : out std_logic;	
          o_cnt : out integer
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
  
  signal t_key : std_logic_vector(7 downto 0);
  signal clk, clk_25m : std_logic;
  -- data valid clocks
  signal raw_kb_TX_DV, a_kb_TX_DV : std_logic; -- keyboard
  signal uart_in_TX_DV : std_logic;
  signal note_gen_TX_DV : std_logic;
  signal uart_out_a_TX_DV : std_logic;
    signal uart_out_TX_Done : std_logic;
  -- guitar properties
  signal gu_triggeredString : integer range 0 to 5;
  signal gu_prog : integer range 0 to 127;
  signal gu_strings : GuitarStatus;
  signal gu_vel : integer; -- TODO: to array
  signal gu_noteLevel : integer range 0 to 88;
  -- uart
  signal uart_out_a_byte : std_logic_vector(7 downto 0);
  signal uart_in_byte : std_logic_vector(7 downto 0);
  -- debug
  signal t_cnt : integer range 0 to 4;

begin
  f_1: FreqDiv
    generic map(100, 50)
    port map(clk_100m, '0', clk);--1m
  f_25: FreqDiv
    generic map(4, 2)
    port map(clk_100m, '0', clk_25m);--1m

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
      o_clk => a_kb_TX_DV
      );

  uart_in : UARTIn
    generic map (
      g_CLKS_PER_BIT => 868 -- Needs to be set correctly
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
      o_strings => gu_strings
      );
  

  note_gen : NoteGen
    port map (
      i_triggeredString => gu_triggeredString,
      i_strings => gu_strings,
      i_RX_DV => uart_in_TX_DV,
      i_clk => clk, -- TODO: reduce frequency
      o_noteLevel => gu_noteLevel,
      o_TX_DV => note_gen_TX_DV
      );

  triggeredString <= gu_triggeredString;
  noteLevel <= gu_noteLevel;
  strings <= gu_strings;
  notegen_RX_DV <= uart_in_TX_DV;
  
  programme_inst : Programme
    port map (
      i_RX_DV => raw_kb_TX_DV,
      i_key => t_key,
      o_prog => gu_prog
      );

  velocity_inst : Velocity
    port map (
      i_RX_DV => raw_kb_TX_DV,
      i_key => t_key,
      o_vel => gu_vel
      );
  
  uart_out_adapter : UARTOutAdapter
    port map (
              i_Clk => clk_100m,
              i_isOn => '1',
              i_noteLevel => gu_noteLevel,
              i_vel => gu_vel,
              i_prog => gu_prog,
              i_Byte_done => uart_out_TX_Done,
              i_TX_DV => note_gen_TX_DV,
              o_TX_Byte => uart_out_a_byte,
              o_TX_DV => uart_out_a_TX_DV,
              o_cnt => t_cnt
              );
  u4 : seg7 port map (uart_out_a_byte(3 downto 0), seg0);
  u5 : seg7 port map (uart_out_a_byte(7 downto 4), seg1);
  u2 : seg7 port map (conv_std_logic_vector(gu_triggeredString, 4), seg2);
  o_cnt <= t_cnt;
  clk_out <= uart_out_a_TX_DV;
  
  uart_out : UARTOut
    generic map (
      g_CLKS_PER_BIT => 217 -- TODO: Need to be set correctly
      )
    port map (
      i_Clk => clk_25m,
      i_TX_DV => uart_out_a_TX_DV,
      i_TX_Byte => uart_out_a_byte,
      o_TX_Active => open,
      o_TX_Serial => w_uart_TX_Serial,
      o_TX_Done => uart_out_TX_Done
      );

end architecture main_bhv;
