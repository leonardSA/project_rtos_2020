with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO;               use Text_IO;
with user_level_schedulers; use user_level_schedulers;
with user_level_tasks;      use user_level_tasks;

with my_subprograms; use my_subprograms;

procedure example_edf_2 is

begin
   -- Example with only periodic tasks 100% CPU usage
   -- T1: S=0 P=10 C=2
   -- T2: S=0 P=10 C=4
   -- T3: S=0 P=20 C=8
   -- 2/10 + 4/10 + 8/20 = 1.0
   -- PPCM=20
   user_level_scheduler.new_user_level_task (id1, task_periodic, 10, 10, 0, 0, 2, T1'Access);
   user_level_scheduler.new_user_level_task (id2, task_periodic, 10, 10, 0, 0, 4, T2'Access);
   user_level_scheduler.new_user_level_task (id3, task_periodic, 20, 20, 0, 0, 8, T3'Access);

   earliest_deadline_first_schedule (19);
   abort_tasks;

end example_edf_2;
