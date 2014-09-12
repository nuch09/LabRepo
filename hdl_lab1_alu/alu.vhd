library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity ALU is
	generic (size: integer := 4);
	port (
	A,B: in bit_vector (size-1	downto 0);
	ctrl: in bit_vector (1 	downto 0);
	Q: out bit_vector (size-1 downto 0);
	cout: out bit
	);
end ALU;

architecture structural of ALU is
	signal addsub_res: std_logic_vector (size-1 downto 0);
	signal nand_res, nor_res: bit_vector (size-1 downto 0);
	signal cout_res: std_logic;
component addsub is
	generic(
		N: natural := 8
	);
	port (
		a, b: IN std_logic_vector (N-1 downto 0);
		add_sub : IN std_logic;
		sum : OUT std_logic_vector (N-1 downto 0);
		Cout : OUT std_logic
	);
end component;

begin 

addsub_inst: addsub 
	generic map (
		N=> size
	)
	port map(
		a=>to_stdlogicvector(A), 
		b=>to_stdlogicvector(B),
		add_sub=> to_stdulogic(ctrl(0)),
		sum=>addsub_res,
		Cout=>cout_res
	);

	nand_res <= A nand B;
	nor_res <= A nor B;
	with ctrl select
			Q<= 		to_bitvector(addsub_res)		when "00",
						to_bitvector(addsub_res)		when "01",
						nand_res								when "10",
						nor_res								when "11";
	with ctrl select
			cout<= 	to_bit(cout_res)					when "00",
						to_bit(cout_res)				 	when "01",
						'0'									when "10",
						'0'									when "11";
end structural; 