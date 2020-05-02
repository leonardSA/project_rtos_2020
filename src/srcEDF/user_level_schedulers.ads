with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with user_level_tasks;      use user_level_tasks;

package user_level_schedulers is

   max_user_level_task : constant Integer := 100;

   type task_status is (task_ready, task_pended);
   type task_nature is (task_periodic, task_sporadic, task_aperiodic);

   type tcb is record
      the_task : user_level_task_ptr;
      period   : Integer;
      capacity : Integer;
      nature   : task_nature;
      status   : task_status;
   end record;

   type tcb_type is array (1 .. max_user_level_task) of tcb;

   protected user_level_scheduler is
      procedure set_task_status (id : Integer; s : task_status);
      function get_tcb (id : Integer) return tcb;
      procedure new_user_level_task
        (id         : in out Integer;
         nature     : in task_nature;
         period     : in Integer;
         capacity   : in Integer;
         subprogram : in run_subprogram);
      function get_number_of_task return Integer;
      function get_current_time return Integer;
      procedure next_time;
   private
      tcbs           : tcb_type;
      number_of_task : Integer := 0;
      current_time   : Integer := 0;
   end user_level_scheduler;

   -- Main user level scheduler entry points
   --
   procedure earliest_deadline_first_schedule (duration_in_time_unit : Integer);
   procedure abort_tasks;

end user_level_schedulers;
