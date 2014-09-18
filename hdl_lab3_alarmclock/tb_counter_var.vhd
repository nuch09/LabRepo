---------------------------------------------------------
---
-- Test Bench for Four Bit Up-Down Counter
-- File name : counter_sig_tb.vhd
---------------------------------------------------------
---
Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_signed.ALL;
architecture tb_counter_var of test is
  component counter_sig
    port( UP, CLK, RESET : in std_logic;
          OUT1 : out std_logic;
          OUT2 : out std_logic_vector(3 downto 0)
    );
  end component;
  signal UP : std_logic := '1';
  signal RESET : std_logic := '0';
  signal CLK : std_logic := '0';
  signal Out1 : std_logic := '0';
  signal Out2 : std_logic_vector(3 downto 0):=(others=>'0');
  for U1:counter_sig use entity work.counter_sig(Arch_counter_var);
begin
  U1: counter_sig port map ( UP, CLK, RESET, OUT1, OUT2);
  RESET <= '1' after 125 ns;
  CLK <= not(CLK) after 50 ns;
-----------------------------------------------------
  tb: process
      begin
        UP <= transport '0' after 945 ns;
        UP <= transport '1' after 1825 ns;
        UP <= transport '0' after 2025 ns;
        wait;
      end process; --tb
-----------------------------------------------------
end; -- tb_counter_var
