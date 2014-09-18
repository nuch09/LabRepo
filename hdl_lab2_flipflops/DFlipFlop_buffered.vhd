LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
ENTITY Dflipflop_buffered IS
  PORT(
    d: IN bit;
    clk: IN bit;
    en : IN bit;
    q: OUT std_logic:='0');
function conv_std_logic(val : bit) return std_logic is
begin	
	if val='1' then
		return '1';
	else
		return '0';
	end if;
end conv_std_logic;

END Dflipflop_buffered;
ARCHITECTURE behavioural OF Dflipflop_buffered IS
	signal intermediate : std_logic := '0';
BEGIN
  q <= intermediate when en='1' else 'Z';
  
  PROCESS(clk,d,en)
  BEGIN
	IF (clk'event and clk='1')THEN
		intermediate<= conv_std_logic(d);
	end if;
  END PROCESS;
END behavioural;
