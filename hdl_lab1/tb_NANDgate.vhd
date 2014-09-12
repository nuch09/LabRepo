ENTITY test IS END test;

ARCHITECTURE testNand OF test IS
COMPONENT nandgate
PORT (
A: IN BIT;
B: IN BIT;
Q: OUT BIT);
END COMPONENT;
SIGNAL testvector: BIT_VECTOR(1 downto 0);
SIGNAL result : BIT;
BEGIN
C1:nandgate PORT MAP(A => testvector(1), B => testvector(0) , Q => result);
testvector <="00",
"01" AFTER 10 ns,
"11" AFTER 20 ns,
"10" AFTER 30 ns,
"00" AFTER 40 ns;
END testNand;

