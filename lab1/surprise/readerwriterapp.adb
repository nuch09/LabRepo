--pragma Task_Dispatching_Policy(FIFO_Within_Priorities);

with Ada.Text_IO;
use Ada.Text_IO;

with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;

--with Ada.Real_Time;
--use Ada.Real_Time;

with readerwriter;

procedure ReaderWriterApp is

   N : Integer := 10;
   SharedVariable : Integer := 0;
   monitor : readerwriter.mon;
   shmem : readerwriter.wrapper(0);

   task type Reader(Id: Integer) is
--      pragma Priority(2);
   end Reader;

   task body Reader is
      Temp : Integer;
   begin
      for I in 1..N loop
         monitor.StartRead;
         Temp := SharedVariable;
         -- Temp := shmem.read;
         Put_Line("Reader "&Integer'Image(Id)&" reads " & Integer'Image(Temp));
         monitor.EndRead;
         delay 0.1;
      end loop;
   end Reader;

   task type Writer(Id: Integer) is
--      pragma Priority(3);
   end Writer;

   task body Writer is
   begin
      for I in 1..N loop
         monitor.StartWrite;
         SharedVariable := I*Id;
         Put_Line("Writer "&Integer'Image(Id)&" writes " & Integer'Image(SharedVariable));
         --shmem.write(I*Id);
         monitor.EndWrite;
         delay 0.1;
      end loop;
   end Writer;

    Reader1: Reader(1);
    Reader2: Reader(2);
    Reader3: Reader(3);
    Writer1: Writer(1);
    Writer2: Writer(2);

begin
   delay 0.1; 
               -- All task should have completed by now
end ReaderWriterApp;
