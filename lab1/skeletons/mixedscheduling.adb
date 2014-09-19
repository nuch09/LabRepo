pragma Priority_Specific_Dispatching(FIFO_Within_Priorities,2,30);
pragma Priority_Specific_Dispatching(Round_Robin_Within_Priorities,1,1);

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

procedure mixedscheduling is

   Start : Time;
   TimeBaseF : constant Integer := 44;
   TimeBaseR : constant Duration := 0.497 ;

   package Duration_IO is new Ada.Text_IO.Fixed_IO(Duration);
   package Int_IO is new Ada.Text_IO.Integer_IO(Integer);
   
   function F(N : Integer) return Integer is
      X : Integer := 0;
   begin
      for Index in 1..N loop
         for I in 1..5000000 loop
            X := I;
         end loop;
      end loop;
      return X;
   end F;

   task type T(Id: Integer; Period : Integer) is
      pragma Priority(24/Period);
   end;
   
   task type T_bkg(Id: Integer) is
      pragma Priority(1);
   end;

   task body T is
      Next : Time;
      dummy:integer;
   begin
      Next := Start;
      loop
         Next := Next + To_Time_Span(TimeBaseR*Period);
         -- Some dummy function
         dummy:=F(TimeBaseF);
         Duration_IO.Put(To_Duration(Clock - Start), 3, 3);
         Put(" : ");
         Int_IO.Put(Id, 2);
         Put_Line("");
         delay until Next;
      end loop;
   end T;

   task body T_bkg is
      dummy:integer;
   begin
      loop
         dummy:=F(TimeBaseF);
         Duration_IO.Put(To_Duration(Clock - Start), 3, 3);
         Put(" : Background Task ");
         Int_IO.Put(Id, 2);
         Put_Line("");
      end loop;
   end T_bkg;

   -- Example Task
   Task1 : T(1, 3);
   Task2 : T(2, 4);
   Task3 : T(3, 6);
   Task_bkg1 : T_bkg(4);
   Task_bkg2 : T_bkg(5);
   Task_bkg3 : T_bkg(6);
begin
   Start := Clock;
   null;
end mixedscheduling;
