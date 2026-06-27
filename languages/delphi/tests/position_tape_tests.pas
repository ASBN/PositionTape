program PositionTapeTests;

{$mode objfpc}
{$H+}

uses
  SysUtils,
  PositionTape;

procedure Check(Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

var
  Validation: TValidationResult;
  Mismatch: TMismatch;
begin
  Check(Generate(0) = '', 'zero length');
  Check(Generate(11) = '12345678911', 'basic generation');
  Check(Length(Generate(100)) = 100, 'exact length');
  Check(Length(GenerateMarkerComplete(100)) = 101, 'marker complete 100');
  Check(Length(GenerateMarkerComplete(10000)) = 10003, 'marker complete 10000');

  Validation := Validate(Generate(250), 250);
  Check(Validation.IsValid, 'valid tape');

  Validation := Validate(Generate(40), 50);
  Check(not Validation.IsValid, 'truncated invalid');
  Check(Validation.HasTruncationPoint and (Validation.TruncationPoint = 41), 'truncation point');

  Mismatch := FindFirstMismatch(Generate(20), Generate(19) + 'X');
  Check(Mismatch.HasValue and (Mismatch.Position = 20), 'mismatch');

  WriteLn('OK delphi');
end.
