structure PositionTape =
struct
  val defaultSearchLength = 100003

  datatype mismatch = Mismatch of { position : int, expected : char option, received : char option }
  datatype validation_result =
    ValidationResult of {
      is_valid : bool,
      expected_length : int,
      received_length : int,
      truncation_point : int option,
      first_mismatch : mismatch option
    }

  fun generate length =
    if length < 0 then raise Domain
    else
      let
        fun loop cursor remaining parts =
          if remaining = 0 then String.concat (List.rev parts)
          else if cursor mod 10 = 0 then
            let
              val marker = Int.toString (cursor div 10)
              val chunkLength = Int.min (String.size marker, remaining)
              val chunk = String.substring (marker, 0, chunkLength)
            in
              loop (cursor + String.size marker) (remaining - chunkLength) (chunk :: parts)
            end
          else
            loop (cursor + 1) (remaining - 1) (Int.toString (cursor mod 10) :: parts)
      in
        loop 1 length []
      end

  fun getMarkerCompleteLength length =
    if length < 0 then raise Domain
    else
      let
        fun loop cursor =
          if cursor > length then length
          else if cursor mod 10 = 0 then
            let
              val markerLength = String.size (Int.toString (cursor div 10))
              val markerEnd = cursor + markerLength - 1
            in
              if length < markerEnd then markerEnd else loop (cursor + markerLength)
            end
          else loop (cursor + 1)
      in
        loop 1
      end

  fun generateMarkerComplete length = generate (getMarkerCompleteLength length)

  fun findFirstMismatch (expected, received) =
    let
      val expectedLength = String.size expected
      val receivedLength = String.size received
      val sharedLength = Int.min (expectedLength, receivedLength)
      fun scan index =
        if index >= sharedLength then NONE
        else
          let
            val expectedChar = String.sub (expected, index)
            val receivedChar = String.sub (received, index)
          in
            if expectedChar <> receivedChar then
              SOME (Mismatch { position = index + 1, expected = SOME expectedChar, received = SOME receivedChar })
            else scan (index + 1)
          end
    in
      case scan 0 of
        SOME mismatch => SOME mismatch
      | NONE =>
          if expectedLength = receivedLength then NONE
          else
            let
              val position = sharedLength + 1
              val expectedChar = if position <= expectedLength then SOME (String.sub (expected, position - 1)) else NONE
              val receivedChar = if position <= receivedLength then SOME (String.sub (received, position - 1)) else NONE
            in
              SOME (Mismatch { position = position, expected = expectedChar, received = receivedChar })
            end
    end

  fun startsWith (text, prefix) =
    String.size prefix <= String.size text andalso String.substring (text, 0, String.size prefix) = prefix

  fun validate (receivedText, expectedLength) =
    let
      val expected = generate expectedLength
      val mismatch = findFirstMismatch (expected, receivedText)
      val truncationPoint =
        if Option.isSome mismatch andalso String.size receivedText < expectedLength andalso startsWith (expected, receivedText)
        then SOME (String.size receivedText + 1)
        else NONE
    in
      ValidationResult {
        is_valid = Option.isNone mismatch,
        expected_length = expectedLength,
        received_length = String.size receivedText,
        truncation_point = truncationPoint,
        first_mismatch = mismatch
      }
    end

  fun findTruncationPoint receivedText =
    case findFirstMismatch (generate (String.size receivedText), receivedText) of
      SOME (Mismatch { position, ... }) => position
    | NONE => String.size receivedText + 1

  fun locate fragment =
    if fragment = "" then 1
    else
      let
        val haystack = generate defaultSearchLength
        val fragmentLength = String.size fragment
        fun scan index =
          if index + fragmentLength > String.size haystack then ~1
          else if String.substring (haystack, index, fragmentLength) = fragment then index + 1
          else scan (index + 1)
      in
        scan 0
      end

  fun rotr (value, count) =
    Word32.orb (Word32.>> (value, Word.fromInt count), Word32.<< (value, Word.fromInt (32 - count)))

  fun word32FromBytes (a, b, c, d) =
    Word32.orb (
      Word32.orb (Word32.<< (Word32.fromInt a, 0w24), Word32.<< (Word32.fromInt b, 0w16)),
      Word32.orb (Word32.<< (Word32.fromInt c, 0w8), Word32.fromInt d)
    )

  fun byteAt bytes index = List.nth (bytes, index)

  fun w32 hex =
    case StringCvt.scanString (IntInf.scan StringCvt.HEX) hex of
      SOME value => Word32.fromLargeInt value
    | NONE => 0w0

  val k : Word32.word vector = Vector.fromList (List.map w32 [
    "428a2f98", "71374491", "b5c0fbcf", "e9b5dba5", "3956c25b", "59f111f1", "923f82a4", "ab1c5ed5",
    "d807aa98", "12835b01", "243185be", "550c7dc3", "72be5d74", "80deb1fe", "9bdc06a7", "c19bf174",
    "e49b69c1", "efbe4786", "0fc19dc6", "240ca1cc", "2de92c6f", "4a7484aa", "5cb0a9dc", "76f988da",
    "983e5152", "a831c66d", "b00327c8", "bf597fc7", "c6e00bf3", "d5a79147", "06ca6351", "14292967",
    "27b70a85", "2e1b2138", "4d2c6dfc", "53380d13", "650a7354", "766a0abb", "81c2c92e", "92722c85",
    "a2bfe8a1", "a81a664b", "c24b8b70", "c76c51a3", "d192e819", "d6990624", "f40e3585", "106aa070",
    "19a4c116", "1e376c08", "2748774c", "34b0bcb5", "391c0cb3", "4ed8aa4a", "5b9cca4f", "682e6ff3",
    "748f82ee", "78a5636f", "84c87814", "8cc70208", "90befffa", "a4506ceb", "bef9a3f7", "c67178f2"
  ])

  fun padLeft8 text =
    String.implode (List.tabulate (8 - String.size text, fn _ => #"0")) ^ text

  fun hexWord word =
    String.map Char.toLower (padLeft8 (Word32.fmt StringCvt.HEX word))

  fun hashFragment fragment =
    let
      val bytes = List.tabulate (String.size fragment, fn index => Char.ord (String.sub (fragment, index)))
      val bitLength = String.size fragment * 8
      fun pad current =
        if List.length current mod 64 = 56 then current
        else pad (current @ [0])
      val paddedWithoutLength = pad (bytes @ [128])
      val lengthBytes = [0, 0, 0, 0, (bitLength div 0x1000000) mod 256, (bitLength div 0x10000) mod 256, (bitLength div 0x100) mod 256, bitLength mod 256]
      val message = paddedWithoutLength @ lengthBytes
      fun chunk start = List.tabulate (64, fn offset => byteAt message (start + offset))
      fun initialWords bytes64 =
        Array.tabulate (64, fn index =>
          if index < 16 then
            word32FromBytes (
              byteAt bytes64 (index * 4),
              byteAt bytes64 (index * 4 + 1),
              byteAt bytes64 (index * 4 + 2),
              byteAt bytes64 (index * 4 + 3)
            )
          else 0w0)
      fun prepareSchedule w index =
        if index = 64 then ()
        else
          let
            val w15 = Array.sub (w, index - 15)
            val w2 = Array.sub (w, index - 2)
            val s0 = Word32.xorb (Word32.xorb (rotr (w15, 7), rotr (w15, 18)), Word32.>> (w15, 0w3))
            val s1 = Word32.xorb (Word32.xorb (rotr (w2, 17), rotr (w2, 19)), Word32.>> (w2, 0w10))
            val value = Array.sub (w, index - 16) + s0 + Array.sub (w, index - 7) + s1
          in
            Array.update (w, index, value);
            prepareSchedule w (index + 1)
          end
      fun compress (w, index, a, b, c, d, e, f, g, h) =
        if index = 64 then (a, b, c, d, e, f, g, h)
        else
          let
            val s1 = Word32.xorb (Word32.xorb (rotr (e, 6), rotr (e, 11)), rotr (e, 25))
            val ch = Word32.xorb (Word32.andb (e, f), Word32.andb (Word32.notb e, g))
            val temp1 = h + s1 + ch + Vector.sub (k, index) + Array.sub (w, index)
            val s0 = Word32.xorb (Word32.xorb (rotr (a, 2), rotr (a, 13)), rotr (a, 22))
            val maj = Word32.xorb (Word32.xorb (Word32.andb (a, b), Word32.andb (a, c)), Word32.andb (b, c))
            val temp2 = s0 + maj
          in
            compress (w, index + 1, temp1 + temp2, a, b, c, d + temp1, e, f, g)
          end
      fun process start (h0, h1, h2, h3, h4, h5, h6, h7) =
        if start >= List.length message then (h0, h1, h2, h3, h4, h5, h6, h7)
        else
          let
            val w = initialWords (chunk start)
            val _ = prepareSchedule w 16
            val (a, b, c, d, e, f, g, h) = compress (w, 0, h0, h1, h2, h3, h4, h5, h6, h7)
          in
            process (start + 64) (h0 + a, h1 + b, h2 + c, h3 + d, h4 + e, h5 + f, h6 + g, h7 + h)
          end
      val (h0, h1, h2, h3, h4, h5, h6, h7) =
        process 0 (w32 "6a09e667", w32 "bb67ae85", w32 "3c6ef372", w32 "a54ff53a", w32 "510e527f", w32 "9b05688c", w32 "1f83d9ab", w32 "5be0cd19")
    in
      String.concat (List.map hexWord [h0, h1, h2, h3, h4, h5, h6, h7])
    end

  fun buildWindowIndex windowSize =
    if windowSize <= 0 orelse windowSize > defaultSearchLength then raise Domain
    else
      let
        val tape = generate defaultSearchLength
        fun addPosition hash position [] = [(hash, [position])]
          | addPosition hash position ((existingHash, positions) :: rest) =
              if existingHash = hash then (existingHash, position :: positions) :: rest
              else (existingHash, positions) :: addPosition hash position rest
        fun loop offset index =
          if offset + windowSize > String.size tape then index
          else
            let
              val fragment = String.substring (tape, offset, windowSize)
              val hash = hashFragment fragment
            in
              loop (offset + 1) (addPosition hash (offset + 1) index)
            end
      in
        loop 0 []
      end

  fun locateByHash (fragmentHash, windowSize) =
    let
      val normalized = String.map Char.toLower fragmentHash
      val tape = generate defaultSearchLength
      fun loop offset positions =
        if offset + windowSize > String.size tape then List.rev positions
        else
          let
            val fragment = String.substring (tape, offset, windowSize)
            val hash = hashFragment fragment
          in
            loop (offset + 1) (if hash = normalized then offset + 1 :: positions else positions)
          end
    in
      loop 0 []
    end
end
