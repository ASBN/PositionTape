unit PositionTape;

{$mode objfpc}
{$H+}

interface

type
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

function Generate(LengthValue: Integer): string;
function GetMarkerCompleteLength(LengthValue: Integer): Integer;
function GenerateMarkerComplete(LengthValue: Integer): string;
function FindFirstMismatch(const Expected, Received: string): TMismatch;
function FindTruncationPoint(const ReceivedText: string): Integer;
function Validate(const ReceivedText: string; ExpectedLength: Integer): TValidationResult;

implementation

uses
  SysUtils;

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
