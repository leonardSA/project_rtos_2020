with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Ada.Numerics.Float_Random;  use Ada.Numerics.Float_Random;
with user_level_tasks;           use user_level_tasks;

package user_level_schedulers is

   max_user_level_task        : constant Integer := 100;

   type task_status is (task_ready, task_pended);
   type task_nature is (task_periodic, task_sporadic, task_aperiodic);

   type tcb is record
      the_task       : user_level_task_ptr;
      period         : Integer;  -- only for periodic tasks
      minimal_delay  : Integer;  -- only for sporadic tasks
      next_execution : Integer;  -- only for sporadic tasks
      critical_delay : Integer;
      start          : Integer;
      capacity       : Integer;
      nature         : task_nature;
      status         : task_status;
   end record;

   type tcb_type is array (1 .. max_user_level_task) of tcb;
   type task_history is array (Integer range <>) of Integer;

   protected user_level_scheduler is
      procedure set_task_status (id : Integer; s : task_status);
      procedure set_task_next_execution (id : Integer; t : Integer);
      procedure set_task_start (id : Integer; t : Integer);
      function get_tcb (id : Integer) return tcb;
      procedure new_user_level_task
        (id             : in out Integer;
         nature         : in task_nature;
         period         : in Integer;
         critical_delay : in Integer;
         minimal_delay  : in Integer;  
         start          : in Integer;
         capacity       : in Integer;
         subprogram     : in run_subprogram);
      function get_number_of_task return Integer;
      function get_current_time return Integer;
      procedure next_time;
      function deadline (a_tcb : tcb) return Integer;
      function deadline_missed return Boolean;
      procedure generate_random (rand : out Float);
      procedure print_history (elected_task_history : task_history);
   private
      tcbs              : tcb_type;
      number_of_task    : Integer := 0;
      current_time      : Integer := 0;
      random_generator  : Generator;      -- generator for randomizing sporadic
                                          -- task wake up
   end user_level_scheduler;

   -- Main user level scheduler entry points
   --
   procedure earliest_deadline_first_schedule (duration_in_time_unit : Integer);
   procedure abort_tasks;

end user_level_schedulers;
