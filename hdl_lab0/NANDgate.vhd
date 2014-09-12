entity nandgate is
    port ( A:in bit; B:in bit; Q:out bit); 
end nandgate;

architecture dataflow of nandgate is
begin
	Q <= A nAND B;
end architecture;