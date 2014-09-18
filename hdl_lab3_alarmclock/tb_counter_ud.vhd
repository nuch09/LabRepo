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

architecture tb_counter_ud of test is
  component counter_block is
  generic(width:integer:=4);
  port ( UP, CLK, EN, RESET : in std_logic; 
    overflow: in std_logic_vector(width-1 downto 0);  
    compare_match : out std_logic;
    counter_value : out std_logic_vector(width-1  downto 0)
  );
  end component;
  constant width: integer :=5;
  signal UP : std_logic := '1';
  signal EN : std_logic := '1';
  signal RESET : std_logic := '1';
  signal CLK : std_logic := '0';
  signal compare_match : std_logic := '0';
  signal counter_value : std_logic_vector(width-1 downto 0):=(others=>'0');
  signal overflow : std_logic_vector(width-1 downto 0):=std_logic_vector(to_unsigned(16,width));
--  for U1:counter_ud use entity work.counter_ud(Arch_counter_var);
  signal tmp_rst : std_logic;
begin
  U1: counter_block generic map (width) port map ( UP, CLK, EN, RESET, overflow, compare_match, counter_value);
  RESET <= '1', '0' after 15ns;
  CLK <= not(CLK) after 50 ns;
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
