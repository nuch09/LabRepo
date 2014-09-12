library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity test is end;

architecture tb_addsub of test is
	constant w : natural := 4;
	component addsub is
		generic(
			N: natural := w
		);
		port (
			a, b: IN std_logic_vector (N-1 downto 0);
			add_sub : IN std_logic;
			sum : OUT std_logic_vector (N-1 downto 0);
			Cout : OUT std_logic
		);
	end component;
	signal a,b,sum : std_logic_vector (w-1 downto 0);
	signal cout, add_sub : std_logic;
begin
	UUT : addsub generic map(
		N => w
	)
	port map(
		a => a,
		b => b,
		add_sub => add_sub,
		sum => sum,
		Cout => cout
	);
	
	process
	begin
		-- adding behaviour
		add_sub <= '0';
		for x in 2**(w-1)-1 downto -2**(w-1) loop
			for y in 2**(w-1)-1 downto -2**(w-1) loop
				a <= std_logic_vector(to_signed(x, w));
				b <= std_logic_vector(to_signed(y, w));
				wait for 10 ns;
				assert
					-- raises warning: conversion to signed -> truncated vector
					-- happens on wrap-around of result
					sum = std_logic_vector(to_signed((x+y), w))
					severity Failure;
				assert
					-- cout has inverse meaning when working with an odd number of negative operands
					-- therefore we xor the MSBs of the operands together with cout, taking into account, 
					-- the internal inversion for subtraction
					(a(w-1) xor b(w-1) xor add_sub xor Cout)&sum = std_logic_vector(to_signed((x+y), w+1)) --or (y<10 or x<0)
					severity failure;
			end loop;
		end loop;
		
		-- subtraction behaviour
		add_sub <= '1';
		for x in 2**(w-1)-1 downto -2**(w-1) loop
			for y in 2**(w-1)-1 downto -2**(w-1) loop
				a <= std_logic_vector(to_signed(x, w));
				b <= std_logic_vector(to_signed(y, w));
				wait for 10 ns;
				assert 
					-- raises warning: conversion to signed -> truncated vector
					-- happens on wrap-around of result
					sum = std_logic_vector(to_signed((x-y), w)) 
					severity Failure;
				assert 
					-- cout has inverse meaning when working with an odd number of negative operands
					-- therefore we xor the MSBs of the operands together with cout, taking into account, 
					-- the internal inversion for subtraction
					(a(w-1) xor b(w-1) xor add_sub xor Cout)&sum = std_logic_vector(to_signed((x-y), w+1)) -- or (y<0 or x<0) 
					severity Failure;
			end loop;
		end loop;
		wait;
	end process;
end tb_addsub;