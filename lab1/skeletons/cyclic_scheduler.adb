with Ada.Text_IO;
use Ada.Text_IO;

with Ada.Real_Time;
use Ada.Real_Time;

with System_Function_Package;
use System_Function_Package;

procedure Cyclic_Scheduler is
   X : Integer := 0; -- Input
   Y : Integer := 0; -- Input

   task Source_X;
   task Source_Y;
   task Scheduler;

   task body Source_X is -- Generates Data for Input X
      Start : Time;
      Next_Release : Time;
      Release : Time_Span := Milliseconds(0);
      Period : Time_Span := Milliseconds(1000);
   begin
      Start := Clock;
      Next_Release := Start + Release;
      loop
         delay until Next_Release;
         Next_Release:= Next_Release + Period;
         X := X + 1;
      end loop;
   end Source_X;

   task body Source_Y is -- Generated Data for Input Y
      Start : Time;
      Next_Release : Time;
      Release: Time_Span := Milliseconds(500);
      Period : Time_Span := Milliseconds(1000);
   begin
      Start := Clock;
      Next_Release := Start + Release;
      loop
         delay until Next_Release;
         Next_Release:= Next_Release + Period;
         Y := Y + 1;
      end loop;
   end Source_Y;

   task body Scheduler is
      Z : Integer; -- Output
      X', Y' : Integer; -- temp
      Start : Time;
   begin
      -- Complete the code for the scheduler...
      loop
              Start := Clock;
              delay until Start+Milliseconds(1);
              X' := System_A(X);
              delay until Start+Milliseconds(501);
              Y' := System_B(Y);
              delay until Start+Milliseconds(701);
              Z := System_C(X', Y');
              delay until Start + Milliseconds(1000);
      end loop;
              
   end Scheduler;

begin
   null;
end Cyclic_Scheduler;

