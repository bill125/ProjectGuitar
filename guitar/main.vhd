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
		noteLevel : in integer range 0 to 88;
		vel  : in integer range 0 to 127;
		prog : in integer range 0 to 127;
		i_TX_DV : in std_logic;
		o_TX_Byte : out std_logic_vector(7 downto 0)
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
  -- data valid clocks
  signal raw_kb_TX_DV, a_kb_TX_DV : std_logic; -- keyboard
  signal uart_in_TX_DV : std_logic;
  signal note_gen_TX_DV : std_logic;
  signal uart_out_a_TX_DV : std_logic;
  -- guitar properties
  signal triggeredString : integer range 0 to 5;
  signal strings : GuitarStatus;
  signal w_prog : integer range 0 to 127;
  signal w_strings : GuitarStatus;
  signal w_vel : array (0 to 5) of integer;
  signal w_noteLevel : integer range 0 to 88;
  -- uart
  signal w_uart_TX_Serial : std_logic;
  signal r_uart_RX_Serial : std_logic;
  signal uart_out_a_byte : std_logic_vector(7 downto 0);
  signal uart_in_byte : std_logic_vector(7 downto 0);
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
		clk_out => raw_kb_TX_DV
	);
	
	u1 : KeyboardAdapter
	port map (
		i_key => t_key,
		i_clk => raw_kb_TX_DV,
		hclk => clk_100m,
		o_triggeredString => triggeredString,
		o_clk => a_kb_TX_DV
        );

    uart_in : UARTIn
      generic (
        g_CLKS_PER_BIT : 868 -- Needs to be set correctly
        );
      port map (
        i_Clk => clk_100m, -- #TODO: reduce frequency maybe
        i_RX_Serial => r_uart_RX_Serial,
        o_RX_DV => uart_in_TX_DV,
        o_RX_Byte => uart_in_byte
        );
    
    uart_in_adapter : UARTInAdapter
      port map (
        );
    

    note_gen : NoteGen
      port map (
        i_triggeredString => triggeredString,
        i_strings => strings,
        i_RX_DV => uart_in_TX_DV,
        i_clk => clk_100m, -- #TODO: reduce frequency
        o_noteLevel => w_noteLevel,
        o_TX_DV => note_gen_TX_DV
        );
    
    programme : Programme
      port map (
        i_TX_DV => raw_kb_TX_DV,
        i_key => t_key,
        o_prog => w_prog
        );

    velocity : Velocity
      port map (
        i_RX_DV => raw_kb_TX_DV,
        i_key => t_key,
        o_vel => w_vel
        );
    
    uart_out_adapter : UARTOutAdapter
      port map (
        isOn => '1',
        noteLevel => w_noteLevel,
        vel => w_vel,
        prog => w_prog,
        i_TX_DV => note_gen_TX_DV,
        o_TX_Byte => uart_out_a_byte,
        o_TX_DV => uart_out_a_TX_DV
        );
    
    uart_out : UARTOut
      generic map (
        g_CLKS_PER_BIT => 868 -- #TODO: Need to be set correctly
        )
      port map (
        i_Clk => clk_100m,
        i_TX_DV => uart_out_a_TX_DV,
        i_TX_Byte => uart_out_a_byte,
        o_TX_Active => open,
        o_TX_Serial => w_uart_TX_Serial
        --o_TX_Done => #TODO: ???
        );

end architecture main_bhv;
