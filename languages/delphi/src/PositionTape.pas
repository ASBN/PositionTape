unit PositionTape;

{$mode objfpc}
{$H+}

interface

const
  DefaultSearchLength = 100003;
  Sha256HexLength = 64;

type
  TSha256Hex = string;

  TIntegerArray = array of Integer;

  TWindowIndexEntry = record
    Hash: TSha256Hex;
    Position: Integer;
  end;

  TWindowIndex = array of TWindowIndexEntry;

  TOptionalChar = record
    HasValue: Boolean;
    Value: Char;
  end;

  TMismatch = record
    HasValue: Boolean;
    Position: Integer;
    Expected: TOptionalChar;
    Received: TOptionalChar;
  end;

  TValidationResult = record
    IsValid: Boolean;
    ExpectedLength: Integer;
    ReceivedLength: Integer;
    HasTruncationPoint: Boolean;
    TruncationPoint: Integer;
    FirstMismatch: TMismatch;
  end;

/// <summary>Returns exactly LengthValue bytes of PositionTape text using 1-indexed positions.</summary>
function Generate(LengthValue: Integer): string;
/// <summary>Returns the minimal length that completes a marker crossing LengthValue.</summary>
function GetMarkerCompleteLength(LengthValue: Integer): Integer;
/// <summary>Returns generated tape text extended only when LengthValue cuts a marker.</summary>
function GenerateMarkerComplete(LengthValue: Integer): string;
/// <summary>Returns the 1-indexed first default-horizon occurrence of Fragment, or 0 when absent.</summary>
function Locate(const Fragment: string): Integer;
/// <summary>Returns lowercase SHA-256 hex for the UTF-8/byte contents of Fragment.</summary>
function HashFragment(const Fragment: string): TSha256Hex;
/// <summary>Builds one hash-window entry per 1-indexed start in the default search horizon.</summary>
function BuildWindowIndex(WindowSize: Integer): TWindowIndex;
/// <summary>Returns all 1-indexed positions whose WindowSize hash matches FragmentHash.</summary>
function LocateByHash(const FragmentHash: TSha256Hex; WindowSize: Integer): TIntegerArray;
/// <summary>Returns the first 1-indexed mismatch between Expected and Received.</summary>
function FindFirstMismatch(const Expected, Received: string): TMismatch;
/// <summary>Returns the first mismatch position against generated text, or next position for an exact prefix.</summary>
function FindTruncationPoint(const ReceivedText: string): Integer;
/// <summary>Validates ReceivedText against ExpectedLength generated characters.</summary>
function Validate(const ReceivedText: string; ExpectedLength: Integer): TValidationResult;

implementation

uses
  SysUtils;

type
  TByteArray = array of Byte;
  TDWordArray = array of DWord;

const
  Sha256K: array[0..63] of DWord = (
    $428A2F98, $71374491, $B5C0FBCF, $E9B5DBA5,
    $3956C25B, $59F111F1, $923F82A4, $AB1C5ED5,
    $D807AA98, $12835B01, $243185BE, $550C7DC3,
    $72BE5D74, $80DEB1FE, $9BDC06A7, $C19BF174,
    $E49B69C1, $EFBE4786, $0FC19DC6, $240CA1CC,
    $2DE92C6F, $4A7484AA, $5CB0A9DC, $76F988DA,
    $983E5152, $A831C66D, $B00327C8, $BF597FC7,
    $C6E00BF3, $D5A79147, $06CA6351, $14292967,
    $27B70A85, $2E1B2138, $4D2C6DFC, $53380D13,
    $650A7354, $766A0ABB, $81C2C92E, $92722C85,
    $A2BFE8A1, $A81A664B, $C24B8B70, $C76C51A3,
    $D192E819, $D6990624, $F40E3585, $106AA070,
    $19A4C116, $1E376C08, $2748774C, $34B0BCB5,
    $391C0CB3, $4ED8AA4A, $5B9CCA4F, $682E6FF3,
    $748F82EE, $78A5636F, $84C87814, $8CC70208,
    $90BEFFFA, $A4506CEB, $BEF9A3F7, $C67178F2);

function Add32(A, B: DWord): DWord;
begin
  Result := DWord((QWord(A) + QWord(B)) and $FFFFFFFF);
end;

function Add32(A, B, C: DWord): DWord;
begin
  Result := DWord((QWord(A) + QWord(B) + QWord(C)) and $FFFFFFFF);
end;

function Add32(A, B, C, D: DWord): DWord;
begin
  Result := DWord((QWord(A) + QWord(B) + QWord(C) + QWord(D)) and $FFFFFFFF);
end;

function Add32(A, B, C, D, E: DWord): DWord;
begin
  Result := DWord((QWord(A) + QWord(B) + QWord(C) + QWord(D) + QWord(E)) and $FFFFFFFF);
end;

function RotateRight(Value: DWord; Bits: Byte): DWord;
begin
  Result := (Value shr Bits) or (Value shl (32 - Bits));
end;

function Ch(X, Y, Z: DWord): DWord;
begin
  Result := (X and Y) xor ((not X) and Z);
end;

function Maj(X, Y, Z: DWord): DWord;
begin
  Result := (X and Y) xor (X and Z) xor (Y and Z);
end;

function BigSigma0(X: DWord): DWord;
begin
  Result := RotateRight(X, 2) xor RotateRight(X, 13) xor RotateRight(X, 22);
end;

function BigSigma1(X: DWord): DWord;
begin
  Result := RotateRight(X, 6) xor RotateRight(X, 11) xor RotateRight(X, 25);
end;

function SmallSigma0(X: DWord): DWord;
begin
  Result := RotateRight(X, 7) xor RotateRight(X, 18) xor (X shr 3);
end;

function SmallSigma1(X: DWord): DWord;
begin
  Result := RotateRight(X, 17) xor RotateRight(X, 19) xor (X shr 10);
end;

function Sha256(const Text: string): TSha256Hex;
var
  OriginalLength: Integer;
  Remainder: Integer;
  PaddingZeroes: Integer;
  TotalLength: Integer;
  Padded: TByteArray;
  H: array[0..7] of DWord;
  W: array[0..63] of DWord;
  BitLength: QWord;
  I: Integer;
  ChunkStart: Integer;
  Base: Integer;
  A: DWord;
  B: DWord;
  C: DWord;
  D: DWord;
  E: DWord;
  F: DWord;
  G: DWord;
  HH: DWord;
  T1: DWord;
  T2: DWord;
begin
  OriginalLength := Length(Text);
  Remainder := (OriginalLength + 1 + 8) mod 64;
  if Remainder = 0 then
    PaddingZeroes := 0
  else
    PaddingZeroes := 64 - Remainder;
  TotalLength := OriginalLength + 1 + PaddingZeroes + 8;
  SetLength(Padded, TotalLength);

  for I := 1 to OriginalLength do
    Padded[I - 1] := Byte(Ord(Text[I]) and $FF);
  Padded[OriginalLength] := $80;

  BitLength := QWord(OriginalLength) * 8;
  for I := 0 to 7 do
    Padded[TotalLength - 1 - I] := Byte((BitLength shr (I * 8)) and $FF);

  H[0] := $6A09E667; H[1] := $BB67AE85; H[2] := $3C6EF372; H[3] := $A54FF53A;
  H[4] := $510E527F; H[5] := $9B05688C; H[6] := $1F83D9AB; H[7] := $5BE0CD19;

  ChunkStart := 0;
  while ChunkStart < TotalLength do
  begin
    FillChar(W, SizeOf(W), 0);
    Base := ChunkStart;
    for I := 0 to 15 do
      W[I] := (DWord(Padded[Base + I * 4]) shl 24) or
              (DWord(Padded[Base + I * 4 + 1]) shl 16) or
              (DWord(Padded[Base + I * 4 + 2]) shl 8) or
              DWord(Padded[Base + I * 4 + 3]);
    for I := 16 to 63 do
      W[I] := Add32(SmallSigma1(W[I - 2]), W[I - 7], SmallSigma0(W[I - 15]), W[I - 16]);

    A := H[0]; B := H[1]; C := H[2]; D := H[3];
    E := H[4]; F := H[5]; G := H[6]; HH := H[7];

    for I := 0 to 63 do
    begin
      T1 := Add32(HH, BigSigma1(E), Ch(E, F, G), Sha256K[I], W[I]);
      T2 := Add32(BigSigma0(A), Maj(A, B, C));
      HH := G;
      G := F;
      F := E;
      E := Add32(D, T1);
      D := C;
      C := B;
      B := A;
      A := Add32(T1, T2);
    end;

    H[0] := Add32(H[0], A); H[1] := Add32(H[1], B);
    H[2] := Add32(H[2], C); H[3] := Add32(H[3], D);
    H[4] := Add32(H[4], E); H[5] := Add32(H[5], F);
    H[6] := Add32(H[6], G); H[7] := Add32(H[7], HH);
    Inc(ChunkStart, 64);
  end;

  Result := '';
  for I := 0 to 7 do
    Result := Result + LowerCase(IntToHex(H[I], 8));
end;

function Generate(LengthValue: Integer): string;
var
  Cursor: Integer;
  Marker: string;
  ChunkLength: Integer;
begin
  if LengthValue < 0 then
    raise Exception.Create('length must be non-negative');

  Result := '';
  Cursor := 1;
  while Length(Result) < LengthValue do
  begin
    if Cursor mod 10 = 0 then
    begin
      Marker := IntToStr(Cursor div 10);
      ChunkLength := LengthValue - Length(Result);
      if ChunkLength > Length(Marker) then
        ChunkLength := Length(Marker);
      Result := Result + Copy(Marker, 1, ChunkLength);
      Cursor := Cursor + Length(Marker);
    end
    else
    begin
      Result := Result + IntToStr(Cursor mod 10);
      Inc(Cursor);
    end;
  end;
end;

function GetMarkerCompleteLength(LengthValue: Integer): Integer;
var
  Cursor: Integer;
  MarkerLength: Integer;
  MarkerEnd: Integer;
begin
  if LengthValue < 0 then
    raise Exception.Create('length must be non-negative');

  Cursor := 1;
  while Cursor <= LengthValue do
  begin
    if Cursor mod 10 = 0 then
    begin
      MarkerLength := Length(IntToStr(Cursor div 10));
      MarkerEnd := Cursor + MarkerLength - 1;
      if LengthValue < MarkerEnd then
        Exit(MarkerEnd);
      Cursor := Cursor + MarkerLength;
    end
    else
      Inc(Cursor);
  end;
  Result := LengthValue;
end;

function GenerateMarkerComplete(LengthValue: Integer): string;
begin
  Result := Generate(GetMarkerCompleteLength(LengthValue));
end;

function Locate(const Fragment: string): Integer;
var
  Tape: string;
begin
  Tape := Generate(DefaultSearchLength);
  if (Length(Fragment) = 0) or (Length(Fragment) > Length(Tape)) then
    Exit(0);

  Result := Pos(Fragment, Tape);
end;

function HashFragment(const Fragment: string): TSha256Hex;
begin
  Result := Sha256(Fragment);
end;

function BuildWindowIndex(WindowSize: Integer): TWindowIndex;
var
  Tape: string;
  Position: Integer;
  Count: Integer;
begin
  Result := nil;
  if WindowSize <= 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  Tape := Generate(DefaultSearchLength);
  if WindowSize > Length(Tape) then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  Count := Length(Tape) - WindowSize + 1;
  SetLength(Result, Count);
  for Position := 1 to Count do
  begin
    Result[Position - 1].Hash := HashFragment(Copy(Tape, Position, WindowSize));
    Result[Position - 1].Position := Position;
  end;
end;

function LocateByHash(const FragmentHash: TSha256Hex; WindowSize: Integer): TIntegerArray;
var
  Index: TWindowIndex;
  I: Integer;
  Count: Integer;
begin
  Result := nil;
  Index := BuildWindowIndex(WindowSize);
  Count := 0;
  for I := 0 to High(Index) do
    if SameText(Index[I].Hash, FragmentHash) then
      Inc(Count);

  SetLength(Result, Count);
  Count := 0;
  for I := 0 to High(Index) do
    if SameText(Index[I].Hash, FragmentHash) then
    begin
      Result[Count] := Index[I].Position;
      Inc(Count);
    end;
end;

function FindFirstMismatch(const Expected, Received: string): TMismatch;
var
  I: Integer;
  SharedLength: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  SharedLength := Length(Expected);
  if Length(Received) < SharedLength then
    SharedLength := Length(Received);

  for I := 1 to SharedLength do
  begin
    if Expected[I] <> Received[I] then
    begin
      Result.HasValue := True;
      Result.Position := I;
      Result.Expected.HasValue := True;
      Result.Expected.Value := Expected[I];
      Result.Received.HasValue := True;
      Result.Received.Value := Received[I];
      Exit;
    end;
  end;

  if Length(Expected) <> Length(Received) then
  begin
    Result.HasValue := True;
    Result.Position := SharedLength + 1;
    if Result.Position <= Length(Expected) then
    begin
      Result.Expected.HasValue := True;
      Result.Expected.Value := Expected[Result.Position];
    end;
    if Result.Position <= Length(Received) then
    begin
      Result.Received.HasValue := True;
      Result.Received.Value := Received[Result.Position];
    end;
  end;
end;

function FindTruncationPoint(const ReceivedText: string): Integer;
var
  Mismatch: TMismatch;
begin
  Mismatch := FindFirstMismatch(Generate(Length(ReceivedText)), ReceivedText);
  if Mismatch.HasValue then
    Result := Mismatch.Position
  else
    Result := Length(ReceivedText) + 1;
end;

function Validate(const ReceivedText: string; ExpectedLength: Integer): TValidationResult;
var
  Expected: string;
begin
  Expected := Generate(ExpectedLength);
  FillChar(Result, SizeOf(Result), 0);
  Result.FirstMismatch := FindFirstMismatch(Expected, ReceivedText);
  Result.IsValid := not Result.FirstMismatch.HasValue;
  Result.ExpectedLength := ExpectedLength;
  Result.ReceivedLength := Length(ReceivedText);
  if Result.FirstMismatch.HasValue and (Length(ReceivedText) < ExpectedLength) and
     (Copy(Expected, 1, Length(ReceivedText)) = ReceivedText) then
  begin
    Result.HasTruncationPoint := True;
    Result.TruncationPoint := Length(ReceivedText) + 1;
  end;
end;

end.
