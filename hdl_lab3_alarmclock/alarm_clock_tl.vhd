library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use work.all;

entity alarm_clock_tl is
port(
  CLOCK_50: in std_logic;
  KEY : in std_logic_vector (3 downto 0);
  SW  : in std_logic_vector (17 downto 0);
  LEDR: out std_logic_vector (17 downto 0):=(others => '0');
  LEDG: out std_logic_vector (7 downto 0):=(others => '0')
  );
end entity;

architecture structural of alarm_clock_tl is

component alarm_clock is 
generic(
	clock_div : integer := 50_000_000
	);
port(
  ref_clk,global_ud,RESET: in std_logic;
  Digit0,Digit1: out std_logic_vector (6 downto 0);
  BCD0,BCD1: out std_logic_vector (3 downto 0)
  );
end component;



begin
alarm_clock_inst: alarm_clock 
generic map(
	clock_div => 50_000_000
)
port map(
  ref_clk=>   clock_50,
  global_ud=> SW(0),
  RESET=>     not(KEY(0)),
  Digit0=>    open,
  Digit1=>    open,
  BCD0=>      LEDG(7 downto 4),
  BCD1=>      LEDR(3 downto 0)
  );
  
end; 
