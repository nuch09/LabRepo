LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY mux IS
  PORT (
    a:IN STD_LOGIC;
    b:IN STD_LOGIC;
    address:IN STD_LOGIC;
    q:OUT STD_LOGIC
  );
END mux;

ARCHITECTURE behavioural OF mux IS
BEGIN
  q <= a WHEN address = '0' ELSE b;
END behavioural;

ARCHITECTURE dataflow OF mux IS
  SIGNAL int1,int2,aa,bb,addressaddress,int_adress: STD_LOGIC;
BEGIN
  addressaddress <= address and address;
  int_adress <= NOT address;
  bb <= b and b;
  int1 <= bb and addressaddress;
  aa <= a and a;
  int2 <= int_adress AND aa;
  q <= int1 OR int2;
END dataflow;