with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Ada.Numerics.Float_Random;  use Ada.Numerics.Float_Random;
with user_level_tasks;           use user_level_tasks;

package user_level_schedulers is

   max_user_level_task        : constant Integer := 100;

   type task_status is (task_ready, task_pended);
   type task_criticality is (task_critical_high, task_critical_low);
   subtype task_priority is Integer Range 1 .. max_user_level_task;

   type tcb is record
      the_task       : user_level_task_ptr;
      period         : Integer;
      critical_delay : Integer;
      start          : Integer;
      capacity       : Integer;
      status         : task_status;
      priority       : task_priority;
      critical       : task_criticality;
   end record;

   type tcb_type is array (1 .. max_user_level_task) of tcb;
   type task_history is array (Integer range <>) of Integer;

   protected user_level_scheduler is
      procedure set_task_status (id : Integer; s : task_status);
      procedure set_task_start (id : Integer; t : Integer);
      procedure set_critical_priority;
      function get_tcb (id : Integer) return tcb;
      procedure new_user_level_task
        (id             : in out Integer;
         period         : in Integer;
         capacity       : in Integer;
         critical_delay : in Integer;
         start          : in Integer;
         subprogram     : in run_subprogram);
      function get_number_of_task return Integer;
      function get_current_time return Integer;
      procedure next_time;
      function deadline (a_tcb : tcb) return Integer;
      function laxity (a_tcb : tcb) return Integer;
      function deadline_missed return Boolean;
      procedure print_history (elected_task_history : task_history);
   private
      tcbs              : tcb_type;
      number_of_task    : Integer := 0;
      current_time      : Integer := 0;
   end user_level_scheduler;

   -- Main user level scheduler entry points
   --
   procedure maximum_urgency_first_schedule (duration_in_time_unit : Integer);
   procedure abort_tasks;

end user_level_schedulers;
