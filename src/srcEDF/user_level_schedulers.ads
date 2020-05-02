with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with user_level_tasks;      use user_level_tasks;

package user_level_schedulers is

   max_user_level_task : constant Integer := 100;

   -- task_done only for aperiodic
   type task_status is (task_ready, task_pended, task_done); 
   type task_nature is (task_periodic, task_sporadic, task_aperiodic);

   type tcb is record
      the_task       : user_level_task_ptr;
      period         : Integer;  -- only for periodic tasks
      minimal_delay  : Integer;  -- only for sporadic tasks
      next_execution : Integer;  -- only for sporadic tasks
      critical_delay : Integer;
      start          : Integer;  -- only for aperiodic tasks
      capacity       : Integer;
      nature         : task_nature;
      status         : task_status;
   end record;

   type tcb_type is array (1 .. max_user_level_task) of tcb;

   protected user_level_scheduler is
      procedure set_task_status (id : Integer; s : task_status);
      function get_tcb (id : Integer) return tcb;
      procedure new_user_level_task
        (id             : in out Integer;
         nature         : in task_nature;
         period         : in Integer;
         critical_delay : in Integer;
         minimal_delay  : in Integer;  
         next_execution : in Integer; 
         start          : in Integer;
         capacity       : in Integer;
         subprogram     : in run_subprogram);
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
