entity ImpulseGen is
  generic 
    ( 
      pausePeriod: integer range 0 to 63 := 10
      );
  port (
    start : in std_logic;
    hclk : in std_logic;
    clk_out : out std_logic := '0'
    );
end entity ImpulseGen;

entity NoteGen is
  port (
    i_triggeredString : in integer range 0 to 5;
    i_strings : in GuitarStatus;
    i_RX_DV, i_clk : in std_logic;
    o_noteLevel : out integer range 0 to 88;
    o_TX_DV : out std_logic
    );
end entity NoteGen;

entity Programme is
  port (
    i_RX_DV : in std_logic;
    i_key : in std_logic_vector(7 downto 0);
    o_prog : out integer range 0 to 127
    );
end entity Programme;

entity Velocity is
  port (
    i_RX_DV : in std_logic;
    i_key : in std_logic_vector(7 downto 0);
    o_vel : out integer range 0 to 127
    );
end entity Velocity;

entity KeyboardInput
  port (
    datain, clkin, fclk, rst_in : in std_logic;
    key_out : out std_logic_vector(6 downto 0);
    seg0, seg1 : out std_logic_vector(6 downto 0)
    );
end entity KeyboardInput;

entity KeyboardAdapter
  port (
    i_key : in std_logic_vector(7 downto 0);
    i_clk, hclk : in std_logic;
    o_key : out std_logic_vector(7 downto 0);
    o_triggeredString : out integer range 0 to 5;
    o_clk : out std_logic
    );
end entity KeyboardAdapter;

entity UARTIn is
  generic (
    g_CLKS_PER_BIT : integer := 868     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end entity UARTIn;

entity UARTInAdapter is
  port (
    i_RX_DV : in std_logic;
    Byte : in std_logic_vector(7 downto 0);
    strings : out GuitarStatus
    );
end entity UARTInAdapter;

entity UARTOutAdapter is
  port (
    isOn : in std_logic;
    noteLevel : in integer range 0 to 88;
    vel  : in integer range 0 to 127;
    prog : in integer range 0 to 127;
    i_TX_DV : in std_logic;
    o_TX_Byte : out std_logic_vector(7 downto 0);
    o_TX_DV : out std_logic
    );
end entity UARTOutAdapter;

entity UARTOut is
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
end entity UARTOut;
