library IEEE;
use IEEE.std_logic_1164.all;

entity adder is
	port(
		A,B,Cin : IN std_logic;
		S,Cout  : OUT std_logic
	);
end adder;

architecture dataflow of adder is
begin
	S <= A xor B xor Cin;
	Cout <= (Cin and (B or A)) or (A and B);
end dataflow;