ARCHITECTURE tb_Dreg OF test IS
COMPONENT DRegister IS
  GENERIC(
      N : Integer := 4
    );
  PORT(
    d: IN std_logic_vector(N-1 downto 0);
    clk: IN std_logic;
    q: OUT std_logic_vector(N-1 downto 0):=(others => '0'));
END COMPONENT;
  CONSTANT N : Integer := 4;
  SIGNAL clk : std_logic := '0';
  SIGNAL test,qReg:std_logic_vector(N-1 downto 0) :=(others => '0');
BEGIN
  test<= (others => '0'),
         (others => '1') AFTER 15 ns,
         (others => '0') AFTER 65 ns,
         (others => '1') AFTER 70 ns,
         (others => '0') AFTER 75 ns,
         (others => '1') AFTER 125 ns;
U1:DRegister GENERIC MAP(N) PORT MAP(test, clk, qReg);
  clk<='0',
       '1' AFTER 20 NS,
       '0' AFTER 40 NS,
       '1' AFTER 60 ns,
       '0' AFTER 80 ns,
       '1' AFTER 100 ns,
       '0' AFTER 120 ns;
  -- This assignment can also be used but then you cannot type
  -- run -all in the simulation
  -- clk <= not(clk) after 20 ns;
END tb_DReg;
