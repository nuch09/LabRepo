entity nandgate is
    port ( A:in bit; B:in bit; Q:out bit); 
end nandgate;

architecture dataflow of nandgate is
begin
	Q <= NOT (A AND B);
end architecture;