with Text_IO;                    use Text_IO;
with Ada.Numerics.Float_Random;  use Ada.Numerics.Float_Random;
with GNAT.OS_Lib;                use GNAT.OS_Lib;

package body user_level_schedulers is

   -- Earliest deadline first scheduling
   --
   procedure maximum_urgency_first_schedule (duration_in_time_unit : Integer) is
      a_tcb                   : tcb;
      no_ready_task           : Boolean;
      elected_task            : tcb;
      maximal_critical_level  : task_criticality;
      minimal_laxity          : Integer;
      highest_user_priority   : Integer;
      elected_task_history    : task_history (0 .. duration_in_time_unit);
   begin

      user_level_scheduler.set_critical_priority;

      -- Loop on tcbs, and select tasks which are ready
      -- and which have the earliest deadline
      --
      loop

         -- Find the next task to run
         --
         no_ready_task     := True;
         minimal_laxity    := Integer'Last;
         highest_user_priority   := Integer'First;
         maximal_critical_level  := task_critical_low;
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_ready) then
                no_ready_task := False;
                if (maximal_critical_level < a_tcb.critical) 
                then
                   maximal_critical_level := a_tcb.critical;
                   elected_task_history 
                      (user_level_scheduler.get_current_time) := i;
                   elected_task := a_tcb;
                elsif (maximal_critical_level = a_tcb.critical) 
                then
                  if (user_level_scheduler.laxity (a_tcb) < minimal_laxity) 
                  then
                     minimal_laxity := user_level_scheduler.laxity (a_tcb);
                     elected_task_history 
                      (user_level_scheduler.get_current_time) := i;
                     elected_task := a_tcb;
                  elsif (user_level_scheduler.laxity (a_tcb) = minimal_laxity) 
                  then
                     if (highest_user_priority < a_tcb.user_priority) then
                        highest_user_priority := a_tcb.user_priority;
                        elected_task_history 
                           (user_level_scheduler.get_current_time) := i;
                        elected_task := a_tcb;
                     end if;
                  end if;
                end if;
            end if;
         end loop;

         if (user_level_scheduler.not_enough_cpu_time) then
            exit;
         end if;

         -- Run the task
         --
         if not no_ready_task then
            elected_task.the_task.wait_for_processor;
            elected_task.the_task.release_processor;
         else
            elected_task_history (user_level_scheduler.get_current_time) := 0;
            Put_Line
              ("No task to run at time " &
               Integer'Image (user_level_scheduler.get_current_time));
         end if;

         if (user_level_scheduler.deadline_missed) then
            exit;
         end if;

         -- Go to the next unit of time
         --
         user_level_scheduler.next_time;
         exit when user_level_scheduler.get_current_time >
                   duration_in_time_unit;

         -- Release tasks
         --
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_pended) then
               if user_level_scheduler.get_current_time mod a_tcb.period = 0
               then
                  Put_Line
                    ("Task" &
                     Integer'Image (i) &
                     " is released at time " &
                     Integer'Image (user_level_scheduler.get_current_time));
                  user_level_scheduler.set_task_start  
                     (i, user_level_scheduler.get_current_time);
                  user_level_scheduler.set_task_status (i, task_ready);
               end if;
            end if;
         end loop;
      end loop;

      user_level_scheduler.print_history (elected_task_history);

   end maximum_urgency_first_schedule;

   procedure abort_tasks is
      a_tcb : tcb;
   begin
      if (user_level_scheduler.get_number_of_task = 0) then
         raise Constraint_Error;
      end if;

      for i in 1 .. user_level_scheduler.get_number_of_task loop
         a_tcb := user_level_scheduler.get_tcb (i);
         abort a_tcb.the_task.all;
      end loop;
   end abort_tasks;

   protected body user_level_scheduler is

      procedure set_task_status (id : Integer; s : task_status) is
      begin
         tcbs (id).status := s;
      end set_task_status;

      procedure set_task_start (id : Integer; t : Integer) is
      begin
         tcbs (id).start := t; 
      end set_task_start;

      -- Sets criticality and user priority
      --
      procedure set_critical_priority is
         id                : Integer := 0;
         smallest_period   : Integer := Integer'Last;
         size              : Integer := 0;
         id_array          : array (1 .. max_user_level_task) of Integer;
         id_exist          : array (1 .. max_user_level_task) of Boolean;
         processor_usage   : Integer := 0;
      begin
         -- init id_exist 
         for i in 1 .. number_of_task loop
            id_exist (i) := False;
         end loop;

         while size < number_of_task loop
            -- search for minimum
            smallest_period := Integer'Last;
            for i in 1 .. number_of_task loop
               if (id_exist (i) = False and tcbs (i).period < smallest_period) 
               then
                  id := i;
                  smallest_period := tcbs (i).period;
               end if;
            end loop;
            -- add to array
            size := size + 1;
            id_array (size) := id;
            id_exist (id) := True;
         end loop;

         -- assign critical level
         for i in 1 .. number_of_task loop
            processor_usage := processor_usage + tcbs (id_array (i)).capacity;
            if (processor_usage <= 100) then
               tcbs (i).critical := task_critical_high;
            else
               tcbs (i).critical := task_critical_low;
            end if;
         end loop;
      end set_critical_priority;

      function get_tcb (id : Integer) return tcb is
      begin
         return tcbs (id);
      end get_tcb;

      procedure new_user_level_task
        (id             : in out Integer;
         period         : in Integer;
         capacity       : in Integer;
         critical_delay : in Integer;
         start          : in Integer;
         user_priority  : in Integer;
         subprogram     : in run_subprogram)
      is
         a_tcb : tcb;
      begin
         if (number_of_task + 1 > max_user_level_task) then
            raise Constraint_Error;
         end if;

         if (start = 0) then 
            a_tcb.status := task_ready; 
         else 
            a_tcb.status := task_pended; 
         end if;

         number_of_task        := number_of_task + 1;
         a_tcb.period          := period;
         a_tcb.capacity        := capacity;
         a_tcb.critical_delay  := critical_delay;  
         a_tcb.start           := start;
         a_tcb.user_priority   := user_priority;
         a_tcb.the_task        :=
           new user_level_task (number_of_task, subprogram);
         tcbs (number_of_task) := a_tcb;
         id                    := number_of_task;
      end new_user_level_task;

      function get_number_of_task return Integer is
      begin
         return number_of_task;
      end get_number_of_task;

      function get_current_time return Integer is
      begin
         return current_time;
      end get_current_time;

      procedure next_time is
      begin
         current_time := current_time + 1;
      end next_time;

      -- Computes the deadline
      --
      function deadline (a_tcb : tcb) return Integer is
      begin
         return a_tcb.start + a_tcb.critical_delay;
      end; 

      -- Computes the laxity
      --
      function laxity (a_tcb : tcb) return Integer is
      begin
         return deadline (a_tcb) - get_current_time - a_tcb.capacity;
      end;

      -- Returns true if a deadline was missed
      --
      function deadline_missed return Boolean is
         a_tcb : tcb;
      begin
            for i in 1 .. number_of_task loop
               a_tcb := tcbs(i);
               if (a_tcb.status = task_ready
                  and deadline (a_tcb) <= get_current_time) 
               then
                  Put_Line 
                       ("Task" &
                        Integer'Image (i) &
                        " missed deadline" &
                        Integer'Image (deadline (a_tcb)) &
                        " at time" &
                        Integer'Image (user_level_scheduler.get_current_time));
                  return True;
               end if;
            end loop;

            return False;
      end deadline_missed;

      -- Returns true if not enough CPU time is left to guarantee that 
      -- task finishes before its deadline
      --
      function not_enough_cpu_time return Boolean is
         a_tcb : tcb;
      begin
         for i in 1 .. number_of_task loop
            a_tcb := tcbs (i);
            if (a_tcb.status = task_ready and laxity (a_tcb) < 0)
            then
               Put_Line 
                    ("Task" &
                     Integer'Image (i) &
                     " will miss deadline" &
                     Integer'Image (deadline (a_tcb)) &
                     " because left cpu time is" &
                     Integer'Image (deadline (a_tcb) - get_current_time) &
                     " and required time is" &
                     Integer'Image (a_tcb.capacity));
               return True;
            end if;
         end loop;
         return False;
      end not_enough_cpu_time;

      -- Print task election history
      --
      procedure print_history (elected_task_history : task_history) is
      begin
         Put_Line ("TIME, TASK_ID");
         for i in elected_task_history'Range loop
            -- if program aborted
            exit when i > user_level_scheduler.get_current_time;
            Put_Line(
               Integer'Image (i) & "," 
               & Integer'Image(elected_task_history (i)));
         end loop;
      end print_history;

   end user_level_scheduler;

end user_level_schedulers;
