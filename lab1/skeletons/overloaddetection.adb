--pragma Task_Dispatching_Policy(FIFO_Within_Priorities);
pragma Priority_Specific_Dispatching(Round_Robin_Within_Priorities,0,10);

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

procedure overloaddetection is

   Start : Time;
   TimeBaseF : constant Integer := 21*1;
   TimeBaseR : constant Duration := 0.488*1;

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

   task type T(Id: Integer; Period : Integer; Exectime : Integer) is
      pragma Priority(36/Period);
   end;

   task body T is
      Next : Time;
      dummy:integer;
   begin
      Next := Start;
      loop
         Next := Next + To_Time_Span(TimeBaseR*Period);
         -- Some dummy function
         dummy:=F(TimeBaseF*Exectime);
         Duration_IO.Put(To_Duration(Clock - Start), 3, 3);
         Put(" : ");
         Int_IO.Put(Id, 2);
         Put_Line("");
         if Clock > Next then
            Int_IO.Put(Id, 2);
            Put_Line(": Missed Deadline!");
         end if;
         delay until Next;
      end loop;
   end T;
   
   task type watchdog(period : Integer) is
      entry signal;
      pragma Priority(50);
   end;
   
   task body watchdog is
   begin
      loop
         select
            accept signal do null;
            end signal;
         or 
            delay TimeBaseR*period;
            Duration_IO.Put(To_Duration(Clock - Start), 3, 3);
            --Put_Line(" : Watchdog Warning!");
            Put_Line(" Watchdog Warning: Overload detected!");
            exit;
         end select;
      end loop;
   end watchdog;
   
   task type overloaddetect(wd : access watchdog) is
      pragma Priority(0);
   end overloaddetect;
   
   task body overloaddetect is
      Next : Time;
   begin
      Next := Start;
      loop
         Next := Next + To_Time_Span(TimeBaseR*1);
         wd.signal;
         --Duration_IO.Put(To_Duration(Clock - Start), 3, 3);
         --Put_Line(" I am free: OK");
         delay until Next;
      end loop;
   end overloaddetect;
   
   
      

   -- Example Task
   Task_P10 : T(1, 3, 1);
   Task_P12 : T(2, 4, 1);
   Task_P14 : T(3, 6, 1);
   Task_P16 : T(4, 9, 2);
   --Task_P18 : T(18, 500);
   --Task_P20 : T(20, 250);
   
   -- watchdog
   Task_WD : access watchdog := new watchdog(36);
   Task_OD : overloaddetect(Task_WD);
begin
   Start := Clock;
   null;
end overloaddetection;
