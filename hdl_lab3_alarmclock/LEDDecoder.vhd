Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LEDDecoder is
	port (
		binary : in std_logic_vector (3 downto 0);
		sevenSeg : out std_logic_vector (6 downto 0)
	);
end LEDDecoder;

architecture structural of LEDDecoder is
	type SevenSegLUT is array (0 to 15) of std_logic_vector (7 downto 0);
	constant lut : SevenSegLUT := (
        X"40",   -- 0
        X"F9",   -- 1
        X"24",   -- 2
        X"b0",   -- 3
        X"19",   -- 4
        X"12",   -- 5
        X"02",   -- 6
        X"78",   -- 7
        X"00",   -- 8
        X"10",   -- 9
        X"04",   -- A
        X"03",   -- B
        X"07",   -- C
        X"21",   -- D
        X"06",   -- E
        X"0d"    -- F
	);
begin
	sevenSeg <= lut(to_integer(unsigned(binary)))(6 downto 0);
end structural;