---------------------------------------------------------
---
-- Test Bench for Four Bit Up-Down Counter
-- File name : counter_sig_tb.vhd
---------------------------------------------------------
---
Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_signed.ALL;
use IEEE.numeric_std.all;

architecture tb_alarm_clock of test is
  component alarm_clock is
	 generic(
			clock_div : integer := 50_000_000
		);
		port(
			ref_clk,global_ud,RESET: in std_logic;
			BCD0,BCD1: out std_logic_vector (3 downto 0);
			Digit0,Digit1: out std_logic_vector (6 downto 0)
	);
  end component;
  
  signal UP : std_logic := '1';
  signal RESET : std_logic := '1';
  signal CLK : std_logic := '0';
  signal BCD0,BCD1: std_logic_vector (3 downto 0);

begin
  U1: alarm_clock generic map (16) port map ( CLK, UP, RESET, BCD0,BCD1,open,open);
  RESET <= '1', '0' after 50 ns;
  CLK <= not(CLK) after 20 ns;
-----------------------------------------------------
  tb: process
      begin
        --UP <= transport '0' after 945 ns;
        --UP <= transport '1' after 1825 ns;
        --UP <= transport '0' after 2025 ns;
        wait;
      end process; --tb
-----------------------------------------------------
end; -- tb_counter_var
