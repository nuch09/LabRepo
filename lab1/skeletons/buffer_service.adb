
package body buffer_service is
       task body CircularBuffer is
        
      A: Item_Array;
      In_Ptr, Out_Ptr: Index := 0;
      Count: Integer range 0..N := 0;
begin
       loop
			select
				when Count < N =>
				
                accept Write(value : in Item) do
    
                        A(In_Ptr) := value;
                        In_Ptr    := In_Ptr + 1;
                        Count     := Count + 1;
                end Write;
		or

				when Count > 0 =>
                accept Read(value : out Item) do
     
                        value   := A(Out_Ptr) ;
                        Out_Ptr := Out_Ptr + 1;
                        Count   := Count - 1;
				end Read;
		or
		
				terminate;
             end select;
        end loop;
          
               
        end CircularBuffer;
end buffer_service;
