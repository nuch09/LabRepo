library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use work.all;

entity alarm_clock is 
generic(
	clock_div : integer := 50_000_000
	);
port(
  ref_clk,global_ud,RESET: in std_logic;
  Digit0,Digit1: out std_logic_vector (6 downto 0);
  BCD0,BCD1: out std_logic_vector (3 downto 0)
  );
end entity;


architecture structural of alarm_clock is

component counter_block is
  generic(width:integer:=4);
  port ( UP, CLK, EN, RESET : in std_logic; 
    overflow: in std_logic_vector(width-1 downto 0);  
    compare_match : out std_logic;
    counter_value : out std_logic_vector(width-1  downto 0)
  );
end component;

signal compare_match_1Hz,compare_match_100mHz :std_logic;
signal OnesDig,TensDig: std_logic_vector (3 downto 0);

begin
freq_divider: counter_block generic map (26) 
  port map (
    UP => '1', 
    CLK=>ref_clk,
    EN=>'1',
    RESET=>RESET,
    overflow=>std_logic_vector(to_unsigned(clock_div,26)), 
--    overflow=>std_logic_vector(to_unsigned(16,26)),
    compare_match=>compare_match_1Hz, 
    counter_value=>open);
Ones_counter: counter_block generic map (4) 
  port map (
    UP => global_ud, 
    CLK=>ref_clk,
    EN=> compare_match_1Hz,
    RESET=>RESET,
    overflow=>std_logic_vector(to_unsigned(10,4)), 
    compare_match=>compare_match_100mHz, 
    counter_value=>OnesDig);
Tens_counter: counter_block generic map (4) 
  port map (
    UP => global_ud, 
    CLK=>ref_clk,
    EN=> compare_match_100mHz,
    RESET=>RESET,
    overflow=>std_logic_vector(to_unsigned(6,4)), 
    compare_match=>open, 
    counter_value=>TensDig);

BCD0<=OnesDig;
BCD1<=TensDig;
end; 
