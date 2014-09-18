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
  process (CLK, RESET)
    variable COUNT : std_logic_vector(width-1 downto 0);
  begin
    if RESET = '1' then
      COUNT := (others=>'0');
      compare_match <= '0';
		counter_value <= (others=>'0');
    elsif clk'event AND clk='1' then
      if EN ='1' then 
          case UP is
            when '1' => COUNT:=COUNT+1;
            when others=> COUNT:=COUNT-1;
          end case;
          if (UP='1' and COUNT=overflow) then 
            compare_match <= '1';
            COUNT:=(others=>'0');
          elsif (UP='0' and COUNT=0) then
            compare_match <= '1';
            COUNT:=overflow;
          else
            compare_match <= '0';
          end if;
      else
        compare_match <= '0';
      end if;
	 end if;
	 counter_value <= COUNT;
end process;
-----------------------------------------------------
end; -- Arch_counter_var
