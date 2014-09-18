library IEEE;
use IEEE.std_logic_1164.ALL;

entity tristate_buf is
  generic ( size : integer );
  port ( D_in    : in    std_logic_vector (size -1 downto 0);
         Enable  : in    std_logic;
         D_out   : out   std_logic_vector (size -1 downto 0)
        );
end;

architecture behaviour of tristate_buf is
  signal enable_int : std_logic;
begin
  process ( D_in, Enable )
  begin
    if Enable = '1' then
      D_out <= D_in after 7 ns;           --TTL delay in tristate buffer
    else
      D_out <= (others => 'Z') after 7 ns;
    end if;
  end process;
end;
