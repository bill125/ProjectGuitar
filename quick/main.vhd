library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use work.definitions.all;

entity main is
	port (
		RXD : in std_logic;
		i_KB_Data, clk_100m, clk_in, rst_in, click : in std_logic;
		TXD : out std_logic;
		clk_out : out std_logic;
		o_cnt : out integer range 0 to 4;
		seg0, seg1, seg2 : out std_logic_vector(6 downto 0)
	);
end entity main;

architecture main_bhv of main is
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
	end component FreqDiv;
	
	component UARTIn
		generic (
			g_CLKS_PER_BIT : integer := 217     -- Needs to be set correctly
		);
		port (
			i_Clk       : in  std_logic;
			i_RX_Serial : in  std_logic;
			o_RX_DV     : out std_logic;
			o_RX_Byte   : out std_logic_vector(7 downto 0)
		);
	end component UARTIn;
	
	component UARTInAdapter
		port (
			i_RX_DV : in std_logic;
			i_Byte : in std_logic_vector(7 downto 0);
			o_strings : out GuitarStatus
		);
	end component UARTInAdapter;
	
	component UARTOut
	generic (
		g_CLKS_PER_BIT : integer := 869     -- Needs to be set correctly
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
	
	component UARTOutAdapter
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
	
	component seg7
		port(
			code: in std_logic_vector(3 downto 0);
			seg_out : out std_logic_vector(6 downto 0)
		);
	end component seg7;
	
	component KeyboardInput
		port (
			datain, clkin, fclk, rst_in : in std_logic;
			key_out : out std_logic_vector(7 downto 0);
			clk_out : out std_logic;
			seg0, seg1 : out std_logic_vector(6 downto 0)
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
	
signal clk_1000, clk_25m, clk_1 : std_logic;
	
signal t_Byte : std_logic_vector(7 downto 0); 
signal t_Guitar : GuitarStatus;
signal ui_data_ready : std_logic;
signal t_seg0, t_seg1 : std_logic_vector(6 downto 0);

signal t_key : std_logic_vector(7 downto 0); 
signal raw_kb_clk, a_kb_clk : std_logic;
signal triggeredString : integer range 0 to 15;

signal t_TX_BV : std_logic;
signal t_TX_Byte : std_logic_vector(7 downto 0);
signal t_Byte_done : std_logic;

signal t_cnt : integer range 0 to 4;

begin
	clk_out <= t_TX_BV;
	u0 : KeyboardInput 
	port map (
		datain => i_KB_data,
		clkin => clk_in,
		fclk => clk_25m,
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
		hclk => clk_25m,
		o_triggeredString => triggeredString,
		o_clk => a_kb_clk
	);
	
	u2 : seg7 port map (conv_std_logic_vector(triggeredString, 4), seg2);

    fd_inst1 : FreqDiv
    generic map
    (
        div => 4,
        half => 2
    )
    port map
    (
        CLK => clk_100m,
        RST => '0', 
        O => clk_25m
    );
    
    fd_inst2 : FreqDiv
    generic map
    (
		div => 100000000 / 1000,
		half => 50000000 / 1000
	)
	port map
	(
		CLK => clk_100m,
		RST => '0',
		O => clk_1000
	);
	
	fd_inst3 : FreqDiv
    generic map
    (
		div => 100000000,
		half => 50000000
	)
	port map
	(
		CLK => clk_100m,
		RST => '0',
		O => clk_1
	);
	
--	u2 : UARTIn
--	generic map (
--		g_CLKS_PER_BIT => 868     -- Needs to be set correctly
--	)
--	port map (
--		i_Clk => clk_100m,
--		i_RX_Serial => RXD,
--		o_RX_DV => ui_data_ready,
--		o_RX_Byte => t_Byte
--	);
--	
--	seg2 <= t_Byte(6 downto 0);
--	
--	u3 : UARTInAdapter
--	port map (
--		i_RX_DV => ui_data_ready,
--		i_Byte => t_Byte,
--		o_strings => t_Guitar
--	);
--	
--
--	u6 : UARTOutAdapter
--	port map (
--		i_Clk => clk_100m,
--		i_TX_DV => clk_1,
--		i_Byte_done => t_Byte_done,
--		i_isOn => '1',
--		i_noteLevel => 50,
--		i_vel => 127,
--		i_prog => 25,
--		o_TX_Byte => t_TX_Byte,
--		o_TX_DV => t_TX_BV,
--		
--		o_cnt => t_cnt
--	);
--	
--	u4 : seg7 port map (t_TX_Byte(3 downto 0), seg0);
--	u5 : seg7 port map (t_TX_Byte(7 downto 4), seg1);
--	o_cnt <= t_cnt;
--	
--	u7 : UARTOut
--	generic map (
--		g_CLKS_PER_BIT => 217
--	)
--	port map (
--	    i_Clk => clk_25m,
--		i_TX_DV => t_TX_BV,
--		i_TX_Byte => t_TX_Byte,
--		o_TX_Serial => TXD,
--		o_TX_done => t_Byte_done
--	);
	
end architecture main_bhv;
