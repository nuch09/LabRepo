
package body Buffer is
        protected body CircularBuffer is
                entry Write(value : in Item)
                        when Count < N is
                begin
                        A(In_Ptr) := value;
                        In_Ptr    := In_Ptr + 1;
                        Count     := Count + 1;
                end Write;

                entry Read(value : out Item)
                        when Count > 0 is
                begin
                        value   := A(Out_Ptr) ;
                        Out_Ptr := Out_Ptr + 1;
                        Count   := Count - 1;
                end Read;
        end CircularBuffer;
end Buffer;
