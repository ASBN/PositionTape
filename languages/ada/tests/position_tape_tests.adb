with Ada.Text_IO; use Ada.Text_IO;
with Position_Tape; use Position_Tape;

procedure Position_Tape_Tests is
   procedure Assert (Condition : Boolean; Message : String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Assert;

   V : Validation_Result;
   M : Mismatch;
begin
   Assert (Generate (0) = "", "zero length");
   Assert (Generate (11) = "12345678911", "basic generation");
   Assert (Generate (100)'Length = 100, "exact length");
   Assert (Generate_Marker_Complete (100)'Length = 101, "marker complete 100");
   Assert (Generate_Marker_Complete (10000)'Length = 10003, "marker complete 10000");

   V := Validate (Generate (250), 250);
   Assert (V.Is_Valid, "valid tape");

   V := Validate (Generate (40), 50);
   Assert (not V.Is_Valid, "truncated invalid");
   Assert (V.Has_Truncation_Point and then V.Truncation_Point = 41, "truncation point");

   M := Find_First_Mismatch (Generate (20), Generate (19) & "X");
   Assert (M.Has_Value and then M.Position = 20, "mismatch");

   Put_Line ("OK ada");
end Position_Tape_Tests;
