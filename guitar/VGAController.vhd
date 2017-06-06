library	ieee;
use	ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;
use	ieee.std_logic_arith.all;
use work.definitions.all;

entity VGAController is
	 port(
			i_kb_clk    :         in std_logic;
			i_note_clk  :         in std_logic;
			i_note_pos  :         in integer range 0 to 5;
			i_triggeredString :   in integer range 0 to 15;
			address		:		  out STD_LOGIC_VECTOR(14 DOWNTO 0);
			reset       :         in STD_LOGIC;
			q		    :		  in STD_LOGIC;
			clk         :         in STD_LOGIC; --25M
			clk_100m    :         in std_logic;
			hs,vs       :         out STD_LOGIC; 
			o_clicked   :         out std_logic;
			r, g, b     :         out STD_LOGIC_vector(2 downto 0)
	  );
end VGAController;

architecture behavior of VGAController is
	signal t_clicked : std_logic := '0';
	signal r1,g1,b1   : std_logic_vector(2 downto 0);					
	signal hs1,vs1    : std_logic;				
	signal x : integer range 0 to 8191;		
	signal y : integer range 0 to 8191;		
	shared variable t_x, t_y : NoteBlocks;
	shared variable t_len : ShiningStripes;
begin
	o_clicked <= t_clicked;
 -----------------------------------------------------------------------
	 process(clk,reset)	--行区间像素数（含消隐区）
	 begin
	  	if reset='0' then
	   		x <= 0;
	  	elsif clk'event and clk='1' then
	   		if x = 799 then
	    		x <= 0;
	   		else
	    		x <= x + 1;
	   		end if;
	  	end if;
	 end process;

  -----------------------------------------------------------------------
	 process(clk,reset)	--场区间行数（含消隐区）
	 begin
	  	if reset = '0' then
			y <= 0;
	  	elsif clk'event and clk='1' then
	   		if x = 799 then
	    		if y = 524 then
	     			y <= 0;
	    		else
	     			y <= y + 1;
	    		end if;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process(clk,reset) --行同步信号产生（同步宽度96，前沿16）
	 begin
		  if reset='0' then
		   hs1 <= '1';
		  elsif clk'event and clk='1' then
		   	if x>=656 and x<752 then
		    	hs1 <= '0';
		   	else
		    	hs1 <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process(clk,reset) --场同步信号产生（同步宽度2，前沿10）
	 begin
	  	if reset='0' then
	   		vs1 <= '1';
	  	elsif clk'event and clk='1' then
	   		if y>=490 and y<492 then
	    		vs1 <= '0';
	   		else
	    		vs1 <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process(clk,reset) --行同步信号输出
	 begin
	  	if reset='0' then
	   		hs <= '0';
	  	elsif clk'event and clk='1' then
	   		hs <=  hs1;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process(clk,reset) --场同步信号输出
	 begin
	  	if reset='0' then
	   		vs <= '0';
	  	elsif clk'event and clk='1' then
	   		vs <=  vs1;
	  	end if;
	 end process;
	 
	process (clk_100m, reset)
		variable i : integer range 0 to 100;
		variable j : integer range 0 to 63 := 0;
		variable cnt : integer range 0 to 250000 := 0;
		variable l_note_clk : std_logic := '0';
	begin
		if reset = '0' then
			i := 0;
			while (i < 64) loop
				t_x(i) := 700;
				t_y(i) := 0;
				i := i + 1;
			end loop;
			cnt := 0;
		elsif clk_100m'event and clk_100m = '1' then
			if l_note_clk = '0' and i_note_clk = '1' then
				t_x(j) := 401 + i_note_pos * 30;
				t_y(j) := 0;
				if j = 63 then
					j := 0;
				else
					j := j + 1;
				end if;
			end if;
			
			l_note_clk := i_note_clk;
			
			if cnt = 200000 then
				cnt := 0;
				i := 0;
				while (i < 64) loop
					if t_y(i) < 480 then
						t_y(i) := t_y(i) + 1;
					else
						t_y(i) := 480;
					end if;
					i := i + 1;
				end loop;
			else	
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	
	process (clk_100m, reset)
		variable cnt : integer range 0 to 500000 := 0;
		variable i : integer range 0 to 7;
		variable l_kb_clk : std_logic := '0';
	begin
		if reset = '0' then
			cnt := 0;
			i := 0;
			while (i < 6) loop
				t_len(i) := 0;
				i := i + 1;
			end loop;
		elsif clk_100m'event and clk_100m = '1' then
			if l_kb_clk = '0' and i_kb_clk = '1' then
				t_clicked <= '1';
				case i_triggeredString is
					when 0 => t_len(5) := 150;
					when 1 => t_len(4) := 150;
					when 2 => t_len(3) := 150;
					when 3 => t_len(2) := 150;
					when 4 => t_len(1) := 150;
					when 5 => t_len(0) := 150;
					when others =>
				end case;
			end if;
		
			if cnt = 100000 then
				cnt := 0;
				i := 0;
				while (i < 6) loop
					if t_len(i) > 0 then
						t_len(i) := t_len(i) - 1;
					else
						t_len(i) := 0;
					end if;
					i := i + 1;
				end loop;
			else
				cnt := cnt + 1;
			end if;
			l_kb_clk := i_kb_clk;
		end if;
	end process;
	
 -----------------------------------------------------------------------	
	process(reset,clk,x,y) -- XY坐标定位控制
		variable cnt : integer range 0 to 32767 := 0;
		variable tmp_c : integer range 0 to 8;
		variable i : integer range 0 to 127;
	begin  
		if reset='0' then
			r1 <= "000";
			g1 <= "000";
			b1 <= "000";	
		elsif clk'event and clk='1' then
			if x <= 640 and y <= 480 then
				r1 <= "000";
				g1 <= "000";
				b1 <= "000";
				
				i := 0;
				while (i < 6) loop
					if 400 + i * 30 < x and x < 429 + i * 30 then
						if y > 386 then
							if i /= 1 and i /= 4 then
								r1 <= "111";
								g1 <= "110";
								b1 <= "111";
							else
								r1 <= "111";
								g1 <= "011";
								b1 <= "110";
							end if;
						elsif y < 379 and y > 379 - t_len(i) then
							tmp_c := 7 - (378 - y) * 7 / t_len(i);
							r1 <= conv_std_logic_vector(tmp_c, 3);
							g1 <= conv_std_logic_vector(tmp_c, 3);
							b1 <= conv_std_logic_vector(tmp_c, 3);
						elsif 379 <= y and y <= 386 then
							r1 <= "011";
							g1 <= "101";
							b1 <= "110";
						else
							r1 <= "001";
							g1 <= "001";
							b1 <= "001";
						end if;
					end if;
					i := i + 1;
				end loop;
				
				i := 0;
				while i < 7 loop		
					if 399 + i * 30 <= x and x <= 400 + i * 30 then
						r1 <= "111";
						g1 <= "111";
						b1 <= "111";
					end if;
					i := i + 1;
				end loop;
				
				i := 0;
				while i < 63 loop
					if y < 386 and t_x(i) <= x and x <= t_x(i) + 27 and t_y(i) <= y and y <= t_y(i) + 7 then
						r1 <= "110";
						g1 <= "110";
						b1 <= "110";
					end if;
					i := i + 1;
				end loop;
			else 
				r1 <= "000";
				g1 <= "000";
				b1 <= "000";
			end if;
		end if;		 
	    end process;	

	-----------------------------------------------------------------------
	process (hs1, vs1, r1, g1, b1)	--色彩输出
	begin
		if hs1 = '1' and vs1 = '1' then
			r <= r1;
			g <= g1;
			b <= b1;
		else
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '0');
		end if;
	end process;

end behavior;

