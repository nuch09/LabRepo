library IEEE;
library mvl;
 
use IEEE.std_logic_1164.ALL;
use mvl.all;

entity test is end test;

architecture tb_opc5 of test is
  variable a,b: opc5;
  signal clk1,clk2: bit:=0;  
  signal bus_wire: opc_logic;
  
begin

	p1: process
	begin
	for i in opc5 loop
		a<=i;
		bus_wire <= i;
		wait on clk1 until clk1='1';
		end loop;
	end process;
	
	p2: process
	begin
	for i in opc5 loop
		b<=i;
		bus_wire <= i;
		wait on clk2 until clk2='1';
		end loop;
	end process;

	clk1<=not(clk1) after 10 ns;
	clk2<=not(clk2) after 50 ns;

end tb_opc5;
