-- Laboration 0, Modern Digital Design 2001
--
-- Test bench for a 2:1 multiplexer component
ENTITY test IS END test;
ARCHITECTURE testMux OF test IS
COMPONENT mux
PORT (

D0: IN BIT;
D1: IN BIT;
S: IN BIT;
Z: OUT BIT);
END COMPONENT;
SIGNAL testvector:BIT_VECTOR (2 downto 0); -- D0, D1 and S.
SIGNAL result:BIT;
BEGIN
C1: mux PORT MAP(D0 => testvector(2), D1 => testvector(1), S => testvector(0), Z => result);
testvector<=
"001",
"101" AFTER 10 ns,
"011" AFTER 20 ns,
"111" AFTER 30 ns,
"000" AFTER 40 ns,
"100" AFTER 50 ns,
"010" AFTER 60 ns,
"110" AFTER 70 ns;
END testMux;
