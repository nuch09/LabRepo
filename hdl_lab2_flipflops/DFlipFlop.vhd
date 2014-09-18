LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY Dflipflop IS
  PORT(
    d: IN bit;
    clk: IN bit;
    q: OUT bit:='0');
END Dflipflop;
ARCHITECTURE behavioural OF Dflipflop IS
BEGIN
  PROCESS(clk,d)
  BEGIN
    IF (clk'event and clk='1')THEN
      q<=d;
    END IF;
  END PROCESS;
END behavioural;
