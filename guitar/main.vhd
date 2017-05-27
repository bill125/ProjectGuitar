library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

entity main is
	port (
		i_KB_Data, clk_100m, fclk, rst_in : in std_logic;
		seg0, seg1 : out std_logic_vector(6 downto 0)
	);
end entity main;

architecture main_bhv of main is
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
      i_TX_DV, i_clk : in std_logic;
      o_noteLevel : out integer range 0 to 88;
      o_RX_DV : out std_logic
      );
  end component NoteGen;

  component Programme is
    port (
      i_TX_DV : in std_logic;
      i_key : in std_logic_vector(7 downto 0);
      o_prog : out integer range 0 to 127
      );
  end component Programme;
  
  component Velocity is
    port (
      i_TX_DV : in std_logic;
      i_key : in std_logic_vector(7 downto 0);
      o_vel : out integer range 0 to 127
      );
  end component Velocity;

  component KeyboardInput
    port (
      datain, clkin, fclk, rst_in : in std_logic;
      key_out : out std_logic_vector(6 downto 0);
      seg0, seg1 : out std_logic_vector(6 downto 0)
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
		Byte : in std_logic_vector(7 downto 0);
		strings : out GuitarStatus
        );
  end component UARTInAdapter;
  
  component UARTOutAdapter is
    port (
		isOn : in std_logic;
		noteLevel : in integer range 0 to 5;
		vel  : in integer range 0 to 127;
		prog : in integer range 0 to 127;
		clk  : in std_logic;
		o_TX_SERIAL : out std_logic
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

  signal t_key : std_logic_vector(6 downto 0); 
  signal raw_kb_clk, a_kb_clk : std_logic;
  signal triggeredString : integer range 0 to 5;
  signal w_prog : integer range 0 to 127;
  signal w_strings : GuitarStatus;
  signal w_vel : array (0 to 5) of integer;
  signal w_noteLevel : out integer range 0 to 88;
  signal c_notegen_out : std_logic;
begin
	u0 : KeyboardInput 
	port map (
		datain => i_KB_data,
		clkin => clkin,
		filter_clk => clk_100m,
		rst_in => rst_in,
		key_out => t_key,
		seg0 => seg0,
		seg1 => seg1,
		clk_out => raw_kb_clk
	);
	
	u1 : KeyboardAdapter
	port map (
		i_key => t_key,
		i_clk => raw_kb_clk,
		hclk => clk_100m,
		o_triggeredString => triggeredString,
		o_clk => a_kb_clk
        );

    programme : Programme
      port map (
        impulse_in => raw_kb_clk,
        key_in => t_key,
        prog => w_prog
        );

    uartout : UARTOut
      port map (
        isOn => '1',
        noteLevel => w_noteLevel,
        vel => w_vel,
        prog => w_prog,
        clk => c_notegen_out
        );

    --notegen : NoteGen
end architecture main_bhv;
