LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY DRegister IS
  GENERIC(
      N : Integer := 4
    );
  PORT(
    d: IN std_logic_vector(N-1 downto 0);
    clk: IN std_logic;
    q: OUT std_logic_vector(N-1 downto 0):=(others => '0'));
END DRegister;
ARCHITECTURE behavioural OF DRegister IS
BEGIN
  PROCESS(clk,d)
  BEGIN
    IF (clk='1' and clk'event) THEN
      q<=d;
    END IF;
  END PROCESS;
END behavioural;
