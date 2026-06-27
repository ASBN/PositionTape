with Interfaces;

package body Position_Tape is
   use Interfaces;

   type Byte_Array is array (Natural range <>) of Unsigned_8;
   type Word_Array is array (Natural range <>) of Unsigned_32;

   K : constant Word_Array (0 .. 63) :=
     (16#428A2F98#, 16#71374491#, 16#B5C0FBCF#, 16#E9B5DBA5#,
      16#3956C25B#, 16#59F111F1#, 16#923F82A4#, 16#AB1C5ED5#,
      16#D807AA98#, 16#12835B01#, 16#243185BE#, 16#550C7DC3#,
      16#72BE5D74#, 16#80DEB1FE#, 16#9BDC06A7#, 16#C19BF174#,
      16#E49B69C1#, 16#EFBE4786#, 16#0FC19DC6#, 16#240CA1CC#,
      16#2DE92C6F#, 16#4A7484AA#, 16#5CB0A9DC#, 16#76F988DA#,
      16#983E5152#, 16#A831C66D#, 16#B00327C8#, 16#BF597FC7#,
      16#C6E00BF3#, 16#D5A79147#, 16#06CA6351#, 16#14292967#,
      16#27B70A85#, 16#2E1B2138#, 16#4D2C6DFC#, 16#53380D13#,
      16#650A7354#, 16#766A0ABB#, 16#81C2C92E#, 16#92722C85#,
      16#A2BFE8A1#, 16#A81A664B#, 16#C24B8B70#, 16#C76C51A3#,
      16#D192E819#, 16#D6990624#, 16#F40E3585#, 16#106AA070#,
      16#19A4C116#, 16#1E376C08#, 16#2748774C#, 16#34B0BCB5#,
      16#391C0CB3#, 16#4ED8AA4A#, 16#5B9CCA4F#, 16#682E6FF3#,
      16#748F82EE#, 16#78A5636F#, 16#84C87814#, 16#8CC70208#,
      16#90BEFFFA#, 16#A4506CEB#, 16#BEF9A3F7#, 16#C67178F2#);

   function Ch (X, Y, Z : Unsigned_32) return Unsigned_32 is
   begin
      return (X and Y) xor ((not X) and Z);
   end Ch;

   function Maj (X, Y, Z : Unsigned_32) return Unsigned_32 is
   begin
      return (X and Y) xor (X and Z) xor (Y and Z);
   end Maj;

   function Big_Sigma0 (X : Unsigned_32) return Unsigned_32 is
   begin
      return Rotate_Right (X, 2) xor Rotate_Right (X, 13) xor Rotate_Right (X, 22);
   end Big_Sigma0;

   function Big_Sigma1 (X : Unsigned_32) return Unsigned_32 is
   begin
      return Rotate_Right (X, 6) xor Rotate_Right (X, 11) xor Rotate_Right (X, 25);
   end Big_Sigma1;

   function Small_Sigma0 (X : Unsigned_32) return Unsigned_32 is
   begin
      return Rotate_Right (X, 7) xor Rotate_Right (X, 18) xor Shift_Right (X, 3);
   end Small_Sigma0;

   function Small_Sigma1 (X : Unsigned_32) return Unsigned_32 is
   begin
      return Rotate_Right (X, 17) xor Rotate_Right (X, 19) xor Shift_Right (X, 10);
   end Small_Sigma1;

   function Hex_Nibble (Value : Unsigned_32) return Character is
      N : constant Natural := Natural (Value and 16#F#);
   begin
      if N < 10 then
         return Character'Val (Character'Pos ('0') + N);
      end if;
      return Character'Val (Character'Pos ('a') + N - 10);
   end Hex_Nibble;

   function To_Hex (Words : Word_Array) return SHA256_Hex is
      Result : SHA256_Hex;
      Out_Pos : Natural := Result'First;
   begin
      for W of Words loop
         for Shift in reverse 0 .. 7 loop
            Result (Out_Pos) := Hex_Nibble (Shift_Right (W, Shift * 4));
            Out_Pos := Out_Pos + 1;
         end loop;
      end loop;
      return Result;
   end To_Hex;

   function SHA256 (Text : String) return SHA256_Hex is
      Original_Length : constant Natural := Text'Length;
      Remainder : constant Natural := (Original_Length + 1 + 8) mod 64;
      Padding_Zeroes : constant Natural := (if Remainder = 0 then 0 else 64 - Remainder);
      Total_Length : constant Natural := Original_Length + 1 + Padding_Zeroes + 8;
      Padded : Byte_Array (0 .. Total_Length - 1) := (others => 0);
      H : Word_Array (0 .. 7) :=
        (16#6A09E667#, 16#BB67AE85#, 16#3C6EF372#, 16#A54FF53A#,
         16#510E527F#, 16#9B05688C#, 16#1F83D9AB#, 16#5BE0CD19#);
      Bit_Length : constant Unsigned_64 := Unsigned_64 (Original_Length) * 8;
   begin
      if Original_Length > 0 then
         for I in 0 .. Original_Length - 1 loop
            Padded (I) := Unsigned_8 (Character'Pos (Text (Text'First + I)));
         end loop;
      end if;
      Padded (Original_Length) := 16#80#;
      for I in 0 .. 7 loop
         Padded (Total_Length - 1 - I) := Unsigned_8 (Shift_Right (Bit_Length, I * 8) and 16#FF#);
      end loop;

      for Chunk_Start in 0 .. (Total_Length / 64) - 1 loop
         declare
            W : Word_Array (0 .. 63) := (others => 0);
            A : Unsigned_32 := H (0);
            B : Unsigned_32 := H (1);
            C : Unsigned_32 := H (2);
            D : Unsigned_32 := H (3);
            E : Unsigned_32 := H (4);
            F : Unsigned_32 := H (5);
            G : Unsigned_32 := H (6);
            HH : Unsigned_32 := H (7);
            Base : constant Natural := Chunk_Start * 64;
         begin
            for I in 0 .. 15 loop
               W (I) :=
                 Shift_Left (Unsigned_32 (Padded (Base + I * 4)), 24) or
                 Shift_Left (Unsigned_32 (Padded (Base + I * 4 + 1)), 16) or
                 Shift_Left (Unsigned_32 (Padded (Base + I * 4 + 2)), 8) or
                 Unsigned_32 (Padded (Base + I * 4 + 3));
            end loop;
            for I in 16 .. 63 loop
               W (I) := Small_Sigma1 (W (I - 2)) + W (I - 7) + Small_Sigma0 (W (I - 15)) + W (I - 16);
            end loop;
            for I in 0 .. 63 loop
               declare
                  T1 : constant Unsigned_32 := HH + Big_Sigma1 (E) + Ch (E, F, G) + K (I) + W (I);
                  T2 : constant Unsigned_32 := Big_Sigma0 (A) + Maj (A, B, C);
               begin
                  HH := G;
                  G := F;
                  F := E;
                  E := D + T1;
                  D := C;
                  C := B;
                  B := A;
                  A := T1 + T2;
               end;
            end loop;
            H (0) := H (0) + A;
            H (1) := H (1) + B;
            H (2) := H (2) + C;
            H (3) := H (3) + D;
            H (4) := H (4) + E;
            H (5) := H (5) + F;
            H (6) := H (6) + G;
            H (7) := H (7) + HH;
         end;
      end loop;

      return To_Hex (H);
   end SHA256;

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

   function Locate (Fragment : String) return Natural is
      Tape : constant String := Generate (Default_Search_Length);
   begin
      if Fragment'Length = 0 or else Fragment'Length > Tape'Length then
         return 0;
      end if;

      for Position in 1 .. Tape'Length - Fragment'Length + 1 loop
         if Tape (Position .. Position + Fragment'Length - 1) = Fragment then
            return Position;
         end if;
      end loop;
      return 0;
   end Locate;

   function Hash_Fragment (Fragment : String) return SHA256_Hex is
   begin
      return SHA256 (Fragment);
   end Hash_Fragment;

   function Build_Window_Index (Window_Size : Natural) return Window_Index is
      Tape : constant String := Generate (Default_Search_Length);
   begin
      if Window_Size = 0 or else Window_Size > Tape'Length then
         return Empty : Window_Index (1 .. 0) do
            null;
         end return;
      end if;

      return Result : Window_Index (1 .. Tape'Length - Window_Size + 1) do
         for Position in Result'Range loop
            Result (Position).Hash := Hash_Fragment (Tape (Position .. Position + Window_Size - 1));
            Result (Position).Position := Position;
         end loop;
      end return;
   end Build_Window_Index;

   function Locate_By_Hash (Fragment_Hash : SHA256_Hex; Window_Size : Natural) return Position_Array is
      Index : constant Window_Index := Build_Window_Index (Window_Size);
      Count : Natural := 0;
   begin
      for Item of Index loop
         if Item.Hash = Fragment_Hash then
            Count := Count + 1;
         end if;
      end loop;

      return Result : Position_Array (1 .. Count) do
         declare
            Out_Pos : Natural := Result'First;
         begin
            for Item of Index loop
               if Item.Hash = Fragment_Hash then
                  Result (Out_Pos) := Item.Position;
                  Out_Pos := Out_Pos + 1;
               end if;
            end loop;
         end;
      end return;
   end Locate_By_Hash;

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
