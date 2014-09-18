package mvl is
	type opc5 is ('X', '0', '1', 'Z', 'H');
	type opc5_vector is array (integer range <>) of opc5;

	function resolved(input:opc5_vector) return opc5;

	subtype opc_logic is resolved opc5;
	type opc_logic_vector is array (integer range <>) of opc_logic;
	
	type opc5_LUT is array (opc5, opc5) of opc5;
	type opc5_LUV is array (opc5) of opc5;
	
	constant resolve_table:opc5_LUT := (
		-- 'X', '0', '1', 'Z', 'H'
		 ( 'X', 'X', 'X', 'X', 'X' ), -- X
		 ( 'X', '0', 'X', '0', '0' ), -- 0
		 ( 'X', 'X', '1', '1', '1' ), -- 1
		 ( 'X', '0', '1', 'Z', 'H' ), -- Z
		 ( 'X', '0', '1', 'H', 'H' ));-- H
  
  constant not_table:opc5_LUV := (
       -- 'X', '0', '1', 'Z', 'H'
          'X', '1', '0', 'X', '0' );-- not
  
  function "not" (input: opc5) return opc5;
   	
	constant xor_table:opc5_LUT := (
		-- 'X', '0', '1', 'Z', 'H'
		 ( 'X', 'X', 'X', 'X', 'X' ), -- X
		 ( 'X', '0', '1', 'X', '1' ), -- 0
		 ( 'X', '1', '0', 'X', '0' ), -- 1
		 ( 'X', 'X', 'X', 'X', 'X' ), -- Z
		 ( 'X', '1', '0', 'X', '0' ));-- H
		 function "xor" (in1,in2: opc5) return opc5;
     function "xnor" (in1,in2:opc5) return opc5; 
end mvl;

package body mvl is
	function resolved(input:opc5_vector) return opc5 is
		variable res : opc5 := 'Z';
	begin
		for i in input'range loop
			res := resolve_table(res, input(i));
		end loop;
		return res;
	end resolved;
	
	function "xor" (in1,in2:opc5) return opc5 is
	begin
		return xor_table(in1,in2);
	end "xor";
	
	  
    function "not" (input:opc5) return opc5 is
    begin
      return not_table(input);
    end "not";
    
    function "xnor" (in1,in2:opc5) return opc5 is
    begin
      return not(in1 xor in2);
    end "xnor";
    
end mvl;