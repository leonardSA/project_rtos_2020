package my_subprograms is

   id1, id2, id3 : Integer;

   procedure T1;
   procedure T2;
   procedure T3;

   protected my_subprograms is
      procedure message (id : Integer);
   end my_subprograms;

end my_subprograms;
