with Ada.Text_IO;
use Ada.Text_IO;

with Ada.Real_Time;
use Ada.Real_Time;

with Ada.Numerics.Discrete_Random;

with Semaphores;
use Semaphores;

procedure ProducerConsumer_sem is

   X : Integer; -- Shared Variable
   N : constant Integer := 40; -- Number of produced and comsumed variables

   pragma Volatile(X); -- For a volatile object all reads and updates of
                       -- the object as a whole are performed directly
                       -- to memory (Ada Reference Manual, C.6)

   -- Random Delays
   subtype Delay_Interval is Integer range 50..250;
   package Random_Delay is new Ada.Numerics.Discrete_Random (Delay_Interval);
   use Random_Delay;
   G : Generator;

   pc_semaphore_w : CountingSemaphore(1, 1);
   pc_semaphore_r : CountingSemaphore(1, 0);
   task Producer;

   task Consumer;

   task body Producer is
      Next : Time;
   begin
      Next := Clock;
      for I in 1..N loop

         -- Wait for X to be free for writing
         pc_semaphore_w.Wait;
         -- ####### protected section #####

         -- Write to X
         X := I;
         -- ####### end protected section #####
         
         -- Signal X to be ready for reading
         pc_semaphore_r.Signal;

         -- Next 'Release' in 50..250ms
         Next := Next + Milliseconds(Random(G));
         delay until Next;
      end loop;
   end;

   task body Consumer is
      Next : Time;
   begin
      Next := Clock;
      for I in 1..N loop

         -- Wait for X to be ready for reading
         pc_semaphore_r.Wait;
         -- ####### protected section #####

         -- Read from X
         Put_Line(Integer'Image(X));

         -- builtin self test:
         if X = I then
                Put_Line("OK");
         else
                Put_Line("FAIL!");
                exit;
         end if;

         -- ####### end protected section #####
         -- Signal X to be free for writing
         pc_semaphore_w.Signal;

         Next := Next + Milliseconds(Random(G));
         delay until Next;
      end loop;
   end;

begin -- main task
   null;
end ProducerConsumer_sem;


