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
   Fragment : constant String := "3123456789412345";
   Fragment_Hash : SHA256_Hex;
   Index : Window_Index := Build_Window_Index (Fragment'Length);
   Positions : Position_Array := Locate_By_Hash
     ("babe07aaad1e1044963518b077f853b6016e6133c960bfd953058f7302d54e5a", Fragment'Length);
   Found : Boolean := False;
   Utf8_Text : constant String :=
     "Ni" & Character'Val (16#C3#) & Character'Val (16#B1#) & "o-posici" &
     Character'Val (16#C3#) & Character'Val (16#B3#) & "n-" &
     Character'Val (16#E2#) & Character'Val (16#9C#) & Character'Val (16#93#);
begin
   Assert (Generate (0) = "", "zero length");
   Assert (Generate (11) = "12345678911", "basic generation");
   Assert (Generate (100)'Length = 100, "exact length");
   Assert (Generate_Marker_Complete (100)'Length = 101, "marker complete 100");
   Assert (Generate_Marker_Complete (10000)'Length = 10003, "marker complete 10000");
   Assert (Generate (101)(100 .. 101) = "10", "marker boundary exact");

   Assert
     (Hash_Fragment ("") = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "sha256 empty");
   Assert
     (Hash_Fragment ("abc") = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
      "sha256 abc");
   Assert
     (Hash_Fragment ("PositionTape") = "55fc0a7c26db83dc2f2aca556e9803ff6d90dcda6c2ad59a69687054ba33abc5",
      "sha256 project");
   Fragment_Hash := Hash_Fragment (Fragment);
   Assert
     (Fragment_Hash = "babe07aaad1e1044963518b077f853b6016e6133c960bfd953058f7302d54e5a",
      "sha256 canonical fragment");
   Assert
     (Hash_Fragment (Utf8_Text) = "ed95c68f09b2639a60011ca685de6bff3ac13ad7a8fef9a8161c108c6d214bab",
      "sha256 utf8");
   Assert (Locate (Fragment) = 30, "locate fragment");

   for Item of Index loop
      if Item.Hash = Fragment_Hash and then Item.Position = 30 then
         Found := True;
      end if;
   end loop;
   Assert (Found, "build window index");

   Found := False;
   for Position of Positions loop
      if Position = 30 then
         Found := True;
      end if;
   end loop;
   Assert (Found, "locate by hash");

   V := Validate (Generate (250), 250);
   Assert (V.Is_Valid, "valid tape");

   V := Validate (Generate (40), 50);
   Assert (not V.Is_Valid, "truncated invalid");
   Assert (V.Has_Truncation_Point and then V.Truncation_Point = 41, "truncation point");

   M := Find_First_Mismatch (Generate (20), Generate (19) & "X");
   Assert (M.Has_Value and then M.Position = 20, "mismatch");

   Put_Line ("OK ada");
end Position_Tape_Tests;
