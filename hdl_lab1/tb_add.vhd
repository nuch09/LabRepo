Library IEEE;
use work.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test is end;
architecture tb_add of test is
component adder is
	port(
		A,B,Cin : IN std_logic;
		S,Cout  : OUT std_logic
	);
end component;
signal A,B,S,Cin,Cout : std_logic;
begin

UUT : adder port map(A,B,Cin,S,Cout);

tproc: process
begin
	for i in 0 to 7 loop
		(A,B,Cin) <= std_logic_vector(to_unsigned(i, 3));
		wait for 10 ns;
		--assert to_unsigned(A+B+Cin, 2) = Cout&S;
	end loop;
end process;

end tb_add;