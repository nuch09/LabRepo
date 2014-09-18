------------------------------------------------------
-- Four Bit Up-Down Counter
-- File Name : counter_sig.vhd
-- Data Type : std_logic_vector
-- Reset : Asynchronous
-- Active : Low
------------------------------------------------------
Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_signed.ALL;
entity counter_sig is
  port ( UP, CLK, RESET : in std_logic;
    OUT1 : out std_logic;
    OUT2 : out std_logic_vector(3 downto 0)
  );
end counter_sig;
architecture Arch_counter_sig of counter_sig is
  signal COUNT : std_logic_vector(3 downto 0);
begin
-----------------------------------------------------
  process (CLK, RESET)
  begin
    if RESET = '0' then
      COUNT <= (others=>'0');
    elsif clk'event AND clk='1' then
      case UP is
        when '1' => COUNT<=COUNT+1;
        when others => COUNT<=COUNT-1;
      end case;
    end if;
  end process;
-----------------------------------------------------
  OUT1 <= '1' when (UP='1' and COUNT=15) or
                   (UP='0' and COUNT=0)
		  else '0';
  OUT2 <= COUNT;
-----------------------------------------------------
end; -- Arch_counter_sig
