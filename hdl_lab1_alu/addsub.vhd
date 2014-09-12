library IEEE;
use IEEE.std_logic_1164.all;
use work.all;

entity addsub is
	generic(
		N: natural := 8
	);
	port (
		a, b: IN std_logic_vector (N-1 downto 0);
		add_sub : IN std_logic;
		sum : OUT std_logic_vector (N-1 downto 0);
		Cout : OUT std_logic
	);
end addsub;

architecture structural of addsub is
	component adder is
		port(
			A,B,Cin : IN std_logic;
			S,Cout  : OUT std_logic
		);
	end component;
	signal carry : std_logic_vector (N downto 0);
	signal b_xor : std_logic_vector (N-1 downto 0);
begin
	adders: for i in N-1 downto 0 generate
		add: adder port map(
			A => a(i),
			B => b_xor(i),
			Cin => carry(i),
			S => sum(i),
			Cout => carry(i+1)
		);
	end generate;
	b_xor <= not b when add_sub='1' else b;
	carry(0) <= add_sub;
	Cout <= carry(N);
end structural;