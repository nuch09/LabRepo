library IEEE;
use IEEE.std_logic_1164.ALL;

entity test is end test;

architecture tb_tristate of test is
  signal In1, In2       : std_logic_vector (1 downto 0) := "00";
  signal Ctrl, Ctrl_inv : std_logic := '0';
  signal Data_bus       : std_logic_vector (1 downto 0);

  component tristate_buf
    generic ( size : integer );
    port ( D_in    : in    std_logic_vector (size -1 downto 0);
           Enable  : in    std_logic;
           D_out   : out   std_logic_vector (size -1 downto 0)
           );
  end component;

begin
  In1  <= "00",
          "01" after 40 ns,
          "00" after 80 ns,
          "01" after 120 ns;
  In2  <= "10",
          "11" after 80 ns;
  Ctrl <= not Ctrl after 20 ns;

  Ctrl_inv <= not Ctrl after 7 ns; --TTL delay in inverter
  
  inst_tristate_1 : tristate_buf
    generic map ( size => 2 )
    port map (
      D_in   => In1,
      Enable => Ctrl,
      D_out  => Data_bus );

  inst_tristate_2 : tristate_buf
    generic map ( size => 2 )
    port map (
      D_in   => In2,
      Enable => Ctrl_inv,
      D_out  => Data_bus );

end;


