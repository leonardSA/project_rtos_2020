with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO;               use Text_IO;
with user_level_schedulers; use user_level_schedulers;
with user_level_tasks;      use user_level_tasks;

with my_subprograms; use my_subprograms;

procedure example_edf_1 is

begin
   -- Example with each type of task
   -- T1: S=0  P=10     C=2   critD=10
   -- T2: S=10          C=4   critD=4
   -- T3: S=5  minD=10  C=8   critD=20
   -- PPCM=20

   user_level_scheduler.new_user_level_task 
      (id1,             -- id
       task_periodic,   -- nature
       10,              -- period
       10,              -- critical delay (critD)
       0,               -- minimal delay (minD)
       0,               -- start
       2,               -- capacity
       T1'Access);      -- subprogram
   user_level_scheduler.new_user_level_task 
      (id2, 
       task_aperiodic, 
       -1, 
       4, 
       -1, 
       10, 
       4, 
       T2'Access);
   user_level_scheduler.new_user_level_task 
      (id3, 
       task_sporadic,  
       -1, 
       20, 
       20, 
       5, 
       8, 
       T3'Access);

   earliest_deadline_first_schedule (19);
   abort_tasks;

end example_edf_1;
