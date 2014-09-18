library IEEE;

 
use IEEE.std_logic_1164.ALL;    
use work.mvl.all;
use work.all;

entity opc5_proto is
	generic (
		N : integer := 4
	);
	port(
		port1,port2 : in std_logic_vector (N-1 downto 0);
		databus : out std_logic_vector (N-1 downto 0);
		en1, en2 : in std_logic;
		clk : in std_logic
	);
end opc5_proto;

architecture behavioural of opc5_proto is
	signal reg1,reg2:std_logic_vector (N-1 downto 0);	
begin

	p1: process (clk, port1, port2)
	begin
		if rising_edge(clk) then
			reg1 <= port1;
			reg2 <= port2;
		end if;
	end process;
	
	databus <= reg1 when en1='1' else (others => 'Z');
	databus <= reg2 when en2='1' else (others => 'Z');
end behavioural;
