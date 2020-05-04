with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO;               use Text_IO;
with user_level_schedulers; use user_level_schedulers;
with user_level_tasks;      use user_level_tasks;

package body my_subprograms is

   procedure T1 is
   begin
      my_subprograms.message (id1);
   end T1;

   procedure T2 is
   begin
      my_subprograms.message (id2);
   end T2;

   procedure T3 is
   begin
      my_subprograms.message (id3);
   end T3;

   procedure T4 is
   begin
      my_subprograms.message (id4);
   end T4;

   protected body my_subprograms is
      procedure message (id : Integer) is
         a_tcb : constant tcb := user_level_scheduler.get_tcb (id);
      begin
         Put_Line
            ("Task" & 
            Integer'Image (id) &
            " is running at time" &
            Integer'Image (user_level_scheduler.get_current_time));
      end message;
   end my_subprograms;

end my_subprograms;
