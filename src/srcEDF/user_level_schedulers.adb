with Text_IO;                    use Text_IO;
with Ada.Numerics.Float_Random;  use Ada.Numerics.Float_Random;
with GNAT.OS_Lib;                use GNAT.OS_Lib;

package body user_level_schedulers is

   -- Earliest deadline first scheduling
   --
   procedure earliest_deadline_first_schedule (duration_in_time_unit : Integer) is
      a_tcb                : tcb;
      no_ready_task        : Boolean;
      elected_task         : tcb;
      earliest_deadline    : Integer;
      rand                 : Float;
      elected_task_history : task_history (0 .. duration_in_time_unit);
   begin

      -- Loop on tcbs, and select tasks which are ready
      -- and which have the earliest deadline
      --
      loop

         -- Find the next task to run
         --
         no_ready_task     := True;
         earliest_deadline := Integer'Last;
         for i in 1 .. user_level_scheduler.get_number_of_task loop
            a_tcb := user_level_scheduler.get_tcb (i);
            if (a_tcb.status = task_ready) then
                no_ready_task := False;
                if (user_level_scheduler.deadline (a_tcb) < earliest_deadline) 
                then
                   elected_task_history 
                      (user_level_scheduler.get_current_time) := i;
                   earliest_deadline := user_level_scheduler.get_current_time 
                                      + a_tcb.critical_delay;
                   elected_task      := a_tcb;
                end if;
            end if;
         end loop;

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
               -- Release for periodic
               --
               if (a_tcb.nature = task_periodic) then
                  if user_level_scheduler.get_current_time mod a_tcb.period = 0
                  then
                     Put_Line
                       ("Periodic task" &
                        Integer'Image (i) &
                        " is released at time " &
                        Integer'Image (user_level_scheduler.get_current_time));
                     user_level_scheduler.set_task_start  
                        (i, user_level_scheduler.get_current_time);
                     user_level_scheduler.set_task_status (i, task_ready);
                  end if;
               -- Release for aperiodic
               --
               elsif (a_tcb.nature = task_aperiodic) then
                  if (a_tcb.start = user_level_scheduler.get_current_time) then
                      Put_Line 
                        ("Aperiodic task" &
                        Integer'Image (i) &
                        " is released at time " &
                        Integer'Image (user_level_scheduler.get_current_time));
                     user_level_scheduler.set_task_status (i, task_ready);
                  end if;
               -- Release for sporadic
               --
               elsif (a_tcb.nature = task_sporadic) then
                  user_level_scheduler.generate_random (rand);
                  if (rand < 66.6 and a_tcb.next_execution 
                           = user_level_scheduler.get_current_time) then 
                     Put_Line
                       ("Sporadic task" &
                        Integer'Image (i) &
                        " is released at time " &
                        Integer'Image (user_level_scheduler.get_current_time));

                     user_level_scheduler.set_task_start  
                        (i, user_level_scheduler.get_current_time);
                     user_level_scheduler.set_task_status (i, task_ready);
                     -- Reset next execution
                     user_level_scheduler.set_task_next_execution 
                        (i, user_level_scheduler.get_current_time 
                            + a_tcb.minimal_delay);
                  elsif (a_tcb.start <= user_level_scheduler.get_current_time) 
                  then
                     user_level_scheduler.set_task_next_execution 
                        (i, user_level_scheduler.get_current_time + 1);
                  end if;
               end if;
            end if;
         end loop;
      end loop;

      user_level_scheduler.print_history (elected_task_history);

   end earliest_deadline_first_schedule;

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

      procedure set_task_next_execution (id : Integer; t : Integer) is
      begin
         tcbs (id).next_execution := t;
      end set_task_next_execution;

      procedure set_task_start (id : Integer; t : Integer) is
      begin
         tcbs (id).start := t; 
      end set_task_start;

      function get_tcb (id : Integer) return tcb is
      begin
         return tcbs (id);
      end get_tcb;

      procedure new_user_level_task
        (id             : in out Integer;
         nature         : in task_nature;
         period         : in Integer;
         critical_delay : in Integer;
         minimal_delay  : in Integer;  
         start          : in Integer;
         capacity       : in Integer;
         subprogram     : in run_subprogram)
      is
         a_tcb : tcb;
      begin
         if (number_of_task + 1 > max_user_level_task) then
            raise Constraint_Error;
         end if;

         -- unused by task of given nature => set to -1
         if (nature = task_periodic) then
            a_tcb.period         := period;
            a_tcb.minimal_delay  := -1;
            a_tcb.next_execution := -1;
         elsif (nature = task_aperiodic) then
            a_tcb.period         := -1;
            a_tcb.minimal_delay  := -1;
            a_tcb.next_execution := -1;
         else -- nature = task_sporadic
            a_tcb.period         := -1;
            a_tcb.minimal_delay  := minimal_delay;
            a_tcb.next_execution := start;
         end if;

         if (start = 0) then 
            a_tcb.status := task_ready; 
         else 
            a_tcb.status := task_pended; 
         end if;

         number_of_task        := number_of_task + 1;
         a_tcb.start           := start;
         a_tcb.nature          := nature;
         a_tcb.critical_delay  := critical_delay;  
         a_tcb.capacity        := capacity;
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

      -- Generate random number in [0; 100] assigned to parameter rand
      --
      procedure generate_random (rand : out Float) is
         r : constant Float := Random(random_generator);
      begin
         rand := 100.0 * r;
      end generate_random;

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
