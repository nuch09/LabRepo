library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity counter_block is
  generic(width:integer:=4);
  port ( UP, CLK, EN, RESET : in std_logic; 
    overflow: in std_logic_vector(width-1 downto 0);  
    compare_match : out std_logic;
    counter_value : out std_logic_vector(width-1  downto 0)
  );
end;

architecture behavioral of counter_block is
begin
-----------------------------------------------------
  process (CLK, RESET, UP, EN, overflow)
    variable COUNT : std_logic_vector(width-1 downto 0);
  begin
    if RESET = '1' then
		COUNT := (others=>'0');
      compare_match <= '0';
		counter_value <= (others=>'0');
    elsif clk'event AND clk='1' then
      if EN ='1' then 
          if (UP='1' and COUNT=overflow) then 
            COUNT:=(others=>'0');
          elsif (UP='0' and COUNT=0) then
            COUNT:=overflow;
          else
                compare_match <= '0';
                case UP is
                        when '1' => COUNT:=COUNT+1;
                        when others=> COUNT:=COUNT-1;
                end case;
           end if;
      else
        compare_match <= '0';
      end if;
	 end if;

	 if EN ='1' then 
		 if (UP='1' and COUNT=overflow) then 
			compare_match <= '1';
		 elsif (UP='0' and COUNT=0) then
			compare_match <= '1';
		 else
			compare_match <= '0';
	 	 end if;
	 else
	   compare_match <= '0';
 	 end if;

    counter_value <= COUNT;
end process;
-----------------------------------------------------
end; -- Arch_counter_var
