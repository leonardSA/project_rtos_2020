with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO;               use Text_IO;
with user_level_schedulers; use user_level_schedulers;
with user_level_tasks;      use user_level_tasks;

with my_subprograms; use my_subprograms;

procedure example_muf_1 is

begin
   -- Example with each type of task
   -- T1: S=0  P=6   C=2   critD=P  usrP=4
   -- T2: S=0  P=10  C=4   critD=P  usrP=3
   -- T3: S=0  P=12  C=3   critD=P  usrP=2
   -- T4: S=0  P=15  C=4   critD=P  usrP=1
   --

   user_level_scheduler.new_user_level_task 
      (id1,             -- id
       6,               -- period
       2,               -- capacity
       6,               -- critical delay (critD)
       0,               -- start
       4,               -- user priority (usrP)
       T1'Access);      -- subprogram

   user_level_scheduler.new_user_level_task 
      (id2,             -- id
       11,              -- period
       4,               -- capacity
       11,              -- critical delay (critD)
       0,               -- start
       4,               -- user priority (usrP)
       T2'Access);      -- subprogram

   user_level_scheduler.new_user_level_task 
      (id3,             -- id
       12,              -- period
       1,               -- capacity
       12,              -- critical delay (critD)
       0,               -- start
       2,               -- user priority (usrP)
       T3'Access);      -- subprogram

   maximum_urgency_first_schedule (19);
   abort_tasks;

end example_muf_1;
