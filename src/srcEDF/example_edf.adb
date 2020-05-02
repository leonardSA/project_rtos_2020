with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO;               use Text_IO;
with user_level_schedulers; use user_level_schedulers;
with user_level_tasks;      use user_level_tasks;

with my_subprograms; use my_subprograms;

procedure example_edf is

begin
   -- Creation des taches
   user_level_scheduler.new_user_level_task (id1, task_periodic, 5, 5, 1, T1'Access);
   user_level_scheduler.new_user_level_task (id2, task_periodic, 10, 10, 3, T2'Access);
   user_level_scheduler.new_user_level_task (id3, task_periodic, 30, 30, 8, T3'Access);

   -- ordonnancement selon RM
   earliest_deadline_first_schedule (29);
   abort_tasks;

end example_edf;
