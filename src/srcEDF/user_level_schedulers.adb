with Text_IO; use Text_IO;

package body user_level_schedulers is

   -- Rate monotonic scheduling
   --
   procedure rate_monotonic_schedule (duration_in_time_unit : Integer) is
      a_tcb           : tcb;
      no_ready_task   : Boolean;
      elected_task    : tcb;
      smallest_period : Integer;
   begin

      -- Loop on tcbs, and select tasks which are ready
      -- and which have smallest periods
      --
      loop

        -- Find the next task to run
        --
         no_ready_task   := True;
         smallest_period := Integer'Last;
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_ready) then
               no_ready_task := False;
               if a_tcb.period < smallest_period then
                  smallest_period := a_tcb.period;
                  elected_task    := a_tcb;
               end if;
            end if;
         end loop;

         -- Run the task
         --
         if not no_ready_task then
            elected_task.the_task.wait_for_processor;
            elected_task.the_task.release_processor;
         else
            Put_Line
              ("No task to run at time " &
               Integer'Image (user_level_scheduler.get_current_time));
         end if;

         -- Go to the next unit of time
         --
         user_level_scheduler.next_time;
         exit when user_level_scheduler.get_current_time >
                   duration_in_time_unit;

         -- release periodic tasks
         --
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_pended) then
               if user_level_scheduler.get_current_time mod a_tcb.period =
                  0
               then
                  Put_Line
                    ("Task" &
                     Integer'Image (i) &
                     " is released at time " &
                     Integer'Image (user_level_scheduler.get_current_time));
                  user_level_scheduler.set_task_status (i, task_ready);
               end if;
            end if;
         end loop;

      end loop;

   end rate_monotonic_schedule;

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

      function get_tcb (id : Integer) return tcb is
      begin
         return tcbs (id);
      end get_tcb;

      procedure new_user_level_task
        (id         : in out Integer;
         nature     : in task_nature;
         period     : in Integer;
         capacity   : in Integer;
         subprogram : in run_subprogram)
      is
         a_tcb : tcb;
      begin
         if (number_of_task + 1 > max_user_level_task) then
            raise Constraint_Error;
         end if;

         number_of_task        := number_of_task + 1;
         a_tcb.nature          := nature;
         a_tcb.period          := period;
         a_tcb.capacity        := capacity;
         a_tcb.status          := task_ready;
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

   end user_level_scheduler;

end user_level_schedulers;
