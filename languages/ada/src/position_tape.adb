package body Position_Tape is
   function Digit_Char (Value : Natural) return Character is
   begin
      return Character'Val (Character'Pos ('0') + Value);
   end Digit_Char;

   function Generate (Length : Natural) return String is
      Output : String (1 .. Length);
      Written : Natural := 0;
      Cursor : Natural := 1;
   begin
      while Written < Length loop
         if Cursor mod 10 = 0 then
            declare
               Marker : constant String := Natural'Image (Cursor / 10);
            begin
               for I in Marker'First + 1 .. Marker'Last loop
                  exit when Written = Length;
                  Written := Written + 1;
                  Output (Written) := Marker (I);
               end loop;
               Cursor := Cursor + Marker'Length - 1;
            end;
         else
            Written := Written + 1;
            Output (Written) := Digit_Char (Cursor mod 10);
            Cursor := Cursor + 1;
         end if;
      end loop;
      return Output;
   end Generate;

   function Get_Marker_Complete_Length (Length : Natural) return Natural is
      Cursor : Natural := 1;
   begin
      while Cursor <= Length loop
         if Cursor mod 10 = 0 then
            declare
               Marker : constant String := Natural'Image (Cursor / 10);
               Marker_Length : constant Natural := Marker'Length - 1;
               Marker_End : constant Natural := Cursor + Marker_Length - 1;
            begin
               if Length < Marker_End then
                  return Marker_End;
               end if;
               Cursor := Cursor + Marker_Length;
            end;
         else
            Cursor := Cursor + 1;
         end if;
      end loop;
      return Length;
   end Get_Marker_Complete_Length;

   function Generate_Marker_Complete (Length : Natural) return String is
   begin
      return Generate (Get_Marker_Complete_Length (Length));
   end Generate_Marker_Complete;

   function Find_First_Mismatch (Expected, Received : String) return Mismatch is
      Shared : constant Natural := Natural'Min (Expected'Length, Received'Length);
      Result : Mismatch;
   begin
      if Shared > 0 then
         for Offset in 0 .. Shared - 1 loop
            if Expected (Expected'First + Offset) /= Received (Received'First + Offset) then
               Result.Has_Value := True;
               Result.Position := Offset + 1;
               Result.Expected := (True, Expected (Expected'First + Offset));
               Result.Received := (True, Received (Received'First + Offset));
               return Result;
            end if;
         end loop;
      end if;

      if Expected'Length /= Received'Length then
         Result.Has_Value := True;
         Result.Position := Shared + 1;
         if Result.Position <= Expected'Length then
            Result.Expected := (True, Expected (Expected'First + Shared));
         end if;
         if Result.Position <= Received'Length then
            Result.Received := (True, Received (Received'First + Shared));
         end if;
      end if;
      return Result;
   end Find_First_Mismatch;

   function Find_Truncation_Point (Received_Text : String) return Natural is
      M : constant Mismatch := Find_First_Mismatch (Generate (Received_Text'Length), Received_Text);
   begin
      if M.Has_Value then
         return M.Position;
      end if;
      return Received_Text'Length + 1;
   end Find_Truncation_Point;

   function Validate (Received_Text : String; Expected_Length : Natural) return Validation_Result is
      Expected : constant String := Generate (Expected_Length);
      M : constant Mismatch := Find_First_Mismatch (Expected, Received_Text);
      Result : Validation_Result;
      Prefix_Matches : Boolean := True;
   begin
      Result.Is_Valid := not M.Has_Value;
      Result.Expected_Length := Expected_Length;
      Result.Received_Length := Received_Text'Length;
      Result.First_Mismatch := M;
      if M.Has_Value and then Received_Text'Length < Expected_Length then
         if Received_Text'Length > 0 then
            Prefix_Matches :=
              Expected (Expected'First .. Expected'First + Received_Text'Length - 1) = Received_Text;
         end if;
         if Prefix_Matches then
            Result.Has_Truncation_Point := True;
            Result.Truncation_Point := Received_Text'Length + 1;
         end if;
      end if;
      return Result;
   end Validate;
end Position_Tape;
