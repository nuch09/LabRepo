ARCHITECTURE tb_mux OF test IS
  COMPONENT mux
  PORT (
    a:IN STD_LOGIC;
    b:IN STD_LOGIC;
    address:IN STD_LOGIC;
    q:OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL test_vector: std_logic_vector(2 downto 0);
  -- a, b, address
  SIGNAL gateResult,dataflowResult:STD_LOGIC;

  FOR c1:mux USE ENTITY work.mux(dataflow);
  FOR c2:mux USE ENTITY work.mux(behavioural);
BEGIN
  C1:mux PORT MAP(test_vector(2), test_vector(1),test_vector(0),dataflowResult);
  C2:mux PORT MAP(test_vector(2), test_vector(1),test_vector(0),gateResult);
  test_vector<=
    "000",
--    "100" AFTER 10 ns,
--    "110" AFTER 15 ns,
    "111" AFTER 20 ns,
    "110" AFTER 25 ns,
    "010" AFTER 27 ns,
    "101" AFTER 30 ns;
END tb_mux;
