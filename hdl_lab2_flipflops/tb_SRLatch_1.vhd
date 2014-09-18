LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.all;
ENTITY test IS END test;

ARCHITECTURE test_SRLatch_1 of test IS
  COMPONENT SRLatch
    PORT (
      s:IN std_logic;
      r:IN std_logic;
      qPrim:OUT std_logic;
      q:OUT std_logic);
  END COMPONENT;
  SIGNAL q,qPrim:std_logic:='0';
  SIGNAL testvector:std_logic_vector(1 downto 0);
BEGIN
  testvector <=
    -- a,b
    "10",
    "11" AFTER 5 ns,
    "01" AFTER 10 ns,
    "11" AFTER 15 ns,
    "10" AFTER 20 ns,
    "11" AFTER 25 ns,
    "00" AFTER 30 ns;
    T1:SRLatch PORT MAP(testvector(1), testvector(0),qPrim,q);
END test_SRLatch_1;
