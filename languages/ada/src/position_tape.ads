--  Public PositionTape API for deterministic diagnostic tape generation,
--  validation, direct fragment location, and SHA-256 hash-window lookup.
package Position_Tape is
   Default_Search_Length : constant Natural := 100_003;
   SHA256_Hex_Length : constant Natural := 64;

   subtype SHA256_Hex is String (1 .. SHA256_Hex_Length);

   type Position_Array is array (Natural range <>) of Natural;

   type Window_Index_Entry is record
      Hash     : SHA256_Hex;
      Position : Natural := 0;
   end record;

   type Window_Index is array (Natural range <>) of Window_Index_Entry;

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

   --  Return exactly Length characters of PositionTape text. Length is a
   --  character count; positions in the generated tape are 1-indexed.
   function Generate (Length : Natural) return String;

   --  Return the minimal length that completes a marker crossing Length.
   function Get_Marker_Complete_Length (Length : Natural) return Natural;

   --  Return generated tape text extended only when Length cuts a marker.
   function Generate_Marker_Complete (Length : Natural) return String;

   --  Return the 1-indexed first occurrence of Fragment in the default tape
   --  search horizon, or 0 when the fragment is empty or not found.
   function Locate (Fragment : String) return Natural;

   --  Return lowercase SHA-256 hex for the UTF-8/byte contents of Fragment.
   function Hash_Fragment (Fragment : String) return SHA256_Hex;

   --  Build deterministic hash entries for every window start in the default
   --  search horizon. Each entry stores a SHA-256 hash and its 1-indexed start.
   function Build_Window_Index (Window_Size : Natural) return Window_Index;

   --  Return all 1-indexed positions whose Window_Size hash matches
   --  Fragment_Hash in the default search horizon.
   function Locate_By_Hash (Fragment_Hash : SHA256_Hex; Window_Size : Natural) return Position_Array;

   --  Return the first 1-indexed mismatch between Expected and Received.
   function Find_First_Mismatch (Expected, Received : String) return Mismatch;

   --  Return the first mismatch position against generated text, or the next
   --  position after Received_Text when it is an exact prefix.
   function Find_Truncation_Point (Received_Text : String) return Natural;

   --  Validate Received_Text against Expected_Length generated characters.
   function Validate (Received_Text : String; Expected_Length : Natural) return Validation_Result;
end Position_Tape;
