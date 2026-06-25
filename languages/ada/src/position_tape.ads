package Position_Tape is
   type Optional_Character is record
      Has_Value : Boolean := False;
      Value     : Character := Character'Val (0);
   end record;

   type Mismatch is record
      Has_Value : Boolean := False;
      Position  : Natural := 0;
      Expected  : Optional_Character;
      Received  : Optional_Character;
   end record;

   type Validation_Result is record
      Is_Valid              : Boolean := False;
      Expected_Length       : Natural := 0;
      Received_Length       : Natural := 0;
      Has_Truncation_Point  : Boolean := False;
      Truncation_Point      : Natural := 0;
      First_Mismatch        : Mismatch;
   end record;

   function Generate (Length : Natural) return String;
   function Get_Marker_Complete_Length (Length : Natural) return Natural;
   function Generate_Marker_Complete (Length : Natural) return String;
   function Find_First_Mismatch (Expected, Received : String) return Mismatch;
   function Find_Truncation_Point (Received_Text : String) return Natural;
   function Validate (Received_Text : String; Expected_Length : Natural) return Validation_Result;
end Position_Tape;
