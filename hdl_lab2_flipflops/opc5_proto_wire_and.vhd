library IEEE;

 
use IEEE.std_logic_1164.ALL;    
use work.mvl.all;
use work.all;

use work.bus_wire.all;

package bus_wire is
	function wired_and(inp:bit_vector) return bit;
end bus_wire;

package body bus_wire is
	function wired_and(inp:bit_vector) return bit is
		variable ret: bit := '1';
	begin
		for i in inp'range loop
			ret := ret and inp(i);
		end loop;
		return ret;
	end wired_and;
end bus_wire;

entity opc5_proto_wire is
	generic (
		N : integer := 4
	);
	port(
		port1,port2 : in bit_vector (N-1 downto 0);
		databus : out wired_and bit_vector (N-1 downto 0);
		en1, en2: in std_logic;
		clk : in std_logic
	);
end opc5_proto_wire;

architecture behavioural of opc5_proto_wire is
	signal reg1,reg2:bit_vector (N-1 downto 0);	
begin

	p1: process (clk, port1, port2)
	begin
		if rising_edge(clk) then
			reg1 <= port1;
			reg2 <= port2;
		end if;
	end process;
	
	databus <= reg1;-- when en1='1' else (others => 'Z');
	databus <= reg2;-- when en2='1' else (others => 'Z');
end behavioural;
