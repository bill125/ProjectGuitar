library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.definitions.all;

entity UARTOutAdapter is
	port (
		i_Clk : in std_logic;
		i_TX_DV : in std_logic;
		i_Byte_done : in std_logic;
		i_isOn : in integer range 0 to 15;
		i_noteLevel : in integer range 0 to 88;
		i_vel  : in integer range 0 to 255;
		i_prog : in integer range 0 to 255;
		o_TX_Byte : out std_logic_vector(7 downto 0);
		o_TX_DV : out std_logic
	);
end UARTOutAdapter;

architecture UARTOutAdapter_bhv of UARTOutAdapter is
	type t_SM_Main is (s_Idle, s_Loading, s_TX_Data_Bytes, s_Finish, s_Cleanup);
	signal r_SM_Main : t_SM_Main := s_Idle;
	signal r_TX_Main : t_SM_Main := s_Idle;	
	signal t_TX_DV : std_logic := '0';
begin
	o_TX_DV <= t_TX_DV;
	
	FSM : process (i_Clk)
		variable cnt : integer range 0 to 4;
		variable l_TX_DV : std_logic := '0';
		variable wait_times : integer range 0 to 63 := 0;
		variable done_wait_times : integer range 0 to 63;
		variable data_ready : std_logic;
		variable data_sent : std_logic;
		variable t_Bytes : BytesBuffer;
		variable L, R : integer range 0 to 255 := 0;
	begin
		if rising_edge(i_Clk) then
			-- Sending from Buffer
			case r_TX_Main is
				when s_Idle =>
					if L /= R then
						wait_times := 10;
						r_TX_Main <= s_Loading;
					else
						r_TX_Main <= s_Idle; 
					end if;
				
				when s_Loading =>
					if wait_times > 0 then
						wait_times := wait_times - 1;
						r_TX_Main <= s_Loading;
					else
						o_TX_Byte <= t_Bytes(L);
						wait_times := 10;
						r_TX_Main <= s_TX_Data_Bytes;
					end if;
				
				when s_TX_Data_Bytes =>
					if wait_times > 0 then
						wait_times := wait_times - 1;
						r_TX_Main <= s_TX_Data_Bytes;
					else
						t_TX_DV <= '1';
						wait_times := 10;
						r_TX_Main <= s_Finish;
					end if;
				
				when s_Finish =>
					if wait_times > 0 then
						wait_times := wait_times - 1;
						r_TX_Main <= s_Finish;
					elsif i_Byte_done = '1' then
						wait_times := 20;
						r_TX_Main <= s_Cleanup;
					else
						t_TX_DV <= '0';
						r_TX_Main <= s_Finish;
					end if;
				
				when s_Cleanup =>
					if wait_times > 0 then
						wait_times := wait_times - 1;
						r_TX_Main <= s_Cleanup;
					else
						T_TX_DV <= '0';
						L := L + 1;
						r_TX_Main <= s_Idle;
					end if;
					
			end case;
		
			-- Writing into Buffer
			case r_SM_Main is
				when s_Idle =>
					if l_TX_DV = '0' and i_TX_DV = '1' then
						cnt := 0;
						r_SM_Main <= s_TX_Data_Bytes;
					else
						r_SM_Main <= s_Idle;
					end if;
				
				when s_TX_Data_Bytes =>
					if cnt = 4 then
						r_SM_Main <= s_Finish;
					else
						case cnt is
							when 0 =>
								t_Bytes(R) := conv_std_logic_vector(i_isOn, 8);
							when 1 =>
								t_Bytes(R) := conv_std_logic_vector(i_noteLevel, 8);
							when 2 =>
								t_Bytes(R) := conv_std_logic_vector(i_vel, 8);
							when 3 =>
								t_Bytes(R) := conv_std_logic_vector(i_prog, 8);
							when others =>
								t_Bytes(R) := "00000000";
						end case;
						
						R := R + 1;
						cnt := cnt + 1;
						r_SM_Main <= s_TX_Data_Bytes;
					end if;
					
				when s_Finish =>
					r_SM_Main <= s_Cleanup;
				
				when s_Cleanup =>
					cnt := 0;
					r_SM_Main <= s_Idle;
					
				when others =>
					r_SM_Main <= s_Idle;
			end case;
			l_TX_DV := i_TX_DV;
		end if;
	end process;
	
end UARTOutAdapter_bhv;
