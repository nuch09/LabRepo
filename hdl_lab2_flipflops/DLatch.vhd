LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY DLatch IS
  PORT(
    d: IN bit;
    clk: IN bit;
    q: OUT bit:='0');
END DLatch;
ARCHITECTURE behavioural OF DLatch IS
BEGIN
  PROCESS(clk,d)
  BEGIN
    IF (clk='1') THEN
      q<=d;
    END IF;
  END PROCESS;
END behavioural;
