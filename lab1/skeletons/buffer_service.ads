package buffer_service is
   N: constant Integer := 4;
   subtype Item is Integer;
   type Index is mod N;
   type Item_Array is array(Index) of Item;

   task type CircularBuffer is
    
      
      entry Write(value : in  Item);
      entry Read(value : out Item);


   end CircularBuffer;
end buffer_service;

