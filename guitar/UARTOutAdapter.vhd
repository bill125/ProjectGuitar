library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.definitions.all;

entity UARTOutAdapter is
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
end UARTOutAdapter;

architecture UARTOutAdapter_bhv of UARTOutAdapter is
	type t_SM_Main is (s_Idle, s_TX_Data_Bytes, s_Cleanup);
	signal r_SM_Main : t_SM_Main := s_Idle;
	
	signal t_Bytes : std_logic_vector(7 downto 0);
	signal t_TX_DV : std_logic := '0';
begin
	o_TX_Byte <= t_Bytes;
	o_TX_DV <= t_TX_DV;
	
	FSM : process (i_Clk)
		variable cnt : integer range 0 to 4;
		variable l_TX_DV : std_logic := '0';
		variable wait_times : integer range 0 to 63;
		variable data_ready : std_logic;
		variable data_sent : std_logic;
	begin
		if rising_edge(i_Clk) then
			case r_SM_Main is
				when s_Idle =>
					if l_TX_DV = '0' and i_TX_DV = '1' then
						cnt := 0;
						data_ready := '1';
						data_sent := '1';
						r_SM_Main <= s_TX_Data_Bytes;
					else
						r_SM_Main <= s_Idle;
					end if;
				
				when s_TX_Data_Bytes =>
					if data_ready = '0' and i_Byte_done = '1' and data_sent = '0' then
						data_ready := '1';
						data_sent := '1';
					end if;
					
					if wait_times > 0 then
						wait_times := wait_times - 1;
					else
						t_TX_DV <= '0';
					end if;
					
					if data_ready = '0' or i_Byte_done = '1' then
						r_SM_Main <= s_TX_Data_Bytes;
					elsif cnt = 4 then
						r_SM_Main <= s_Cleanup;
					else
						case cnt is
							when 0 => 
								t_Bytes(7 downto 1) <= "0000000";
								t_Bytes(0) <= i_isOn;
							when 1 =>
								t_Bytes <= conv_std_logic_vector(i_noteLevel, 8);
							when 2 =>
								t_Bytes <= conv_std_logic_vector(i_vel, 8);
							when 3 =>
								t_Bytes <= conv_std_logic_vector(i_prog, 8);
							when others =>
								t_Bytes <= "00000000";
						end case;
						
						t_TX_DV <= '1';
						
						wait_times := 20;
						data_ready := '0';
						data_sent := '0';
						cnt := cnt + 1;
						r_SM_Main <= s_TX_Data_Bytes;
					end if;
				
				when s_Cleanup =>
					cnt := 0;
					data_ready := '0';
					data_sent := '1';
					r_SM_Main <= s_Idle;
			end case;
			l_TX_DV := i_TX_DV;
		end if;
		o_cnt <= cnt;
	end process;
	
end UARTOutAdapter_bhv;