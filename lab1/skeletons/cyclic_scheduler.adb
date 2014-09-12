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
      -- Variables introduced for cyclic scheduling
      A_TEMP: integer;
      B_TEMP: integer;
      cnt: integer:=1;
      Start : Time;
      Period : Time_Span := Milliseconds(1000);
      Next_A: Time;
      Next_B: Time;
      A_TimeSpan: Time_Span;
      B_TimeSpan: Time_Span;
      C_Timespan: Time_Span;
   begin
      -- Complete the code for the scheduler below...
     -- timestamp for starting scheduling
      Start :=Clock;
    
     --timestamps of A and B starting for the first period
      Next_A:= Start+Milliseconds(10);                     --Adding an arbitrary delay of 10ms to give enough time for X to be incremented.
      Next_B:= Start+Milliseconds(500)+Milliseconds(10);   --Adding an arbitrary delay of 10ms to give enough time for Y to be incremented.
    
      
      --Cyclic scheduling starts
      loop
      --Wait until the period starts again (i.e. after 0ms, 1000ms, 2000ms and so on)
      delay until Next_A;
      --Executing subsystem A and storing the result in variable A_TEMP
      A_TEMP:=System_A(X);
      A_TimeSpan:= Clock-Next_A;             --Finding the time elapsed while executing subsystem A
      Put(Duration'Image(To_Duration(A_TimeSpan)));
      Put_Line(": A executed");              --A has been executed
      
      delay until Next_B;
      B_TEMP:=System_B(Y);                   --Executing subsystem B and storing the result in variable B_TEMP
      B_TimeSpan:= Clock-Next_B;             --Finding the time elapsed while executing subsystem B
      Put(Duration'Image(To_Duration(B_TimeSpan)));
      Put_Line(": B executed");              --B has been executed
      
     
      Z:=System_C(A_TEMP,B_TEMP);            --Executing system C and storing the result in output Z
      C_TimeSpan:= Clock-Next_B-B_Timespan;  --Finding the time elapsed while executing subsystem C
      Put(Duration'Image(To_Duration(C_TimeSpan)));
      Put_Line(": C executed");              --C has been executed

      --Verifying that output Z is correct
      if(Z=(cnt+1)*(cnt*2)) then
      Put_Line("Z: "& Integer'Image(Z)& "  Things are correct so far");
      end if;
      
      
      cnt:=cnt+1;                            -- Incrementing cnt to mimic X and Y in the verifying process
      --Updating timestamps of A,B and C so that they are ready for the future cycle of scheduling.
      Next_A:= Next_A+Period;
      Next_B:= Next_B+Period;
      
      end loop;
   end Scheduler;

begin
   null;
end Cyclic_Scheduler;

