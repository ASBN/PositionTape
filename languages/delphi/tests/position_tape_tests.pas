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
  Fragment: string;
  FragmentHash: TSha256Hex;
  Index: TWindowIndex;
  Positions: TIntegerArray;
  I: Integer;
  Found: Boolean;
  Utf8Text: string;
begin
  Check(Generate(0) = '', 'zero length');
  Check(Generate(11) = '12345678911', 'basic generation');
  Check(Length(Generate(100)) = 100, 'exact length');
  Check(Length(GenerateMarkerComplete(100)) = 101, 'marker complete 100');
  Check(Length(GenerateMarkerComplete(10000)) = 10003, 'marker complete 10000');
  Check(Copy(Generate(101), 100, 2) = '10', 'marker boundary exact');

  Fragment := '3123456789412345';
  Utf8Text := 'Ni' + #$C3 + #$B1 + 'o-posici' + #$C3 + #$B3 + 'n-' + #$E2 + #$9C + #$93;

  Check(HashFragment('') = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'sha256 empty');
  Check(HashFragment('abc') = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad', 'sha256 abc');
  Check(HashFragment('PositionTape') = '55fc0a7c26db83dc2f2aca556e9803ff6d90dcda6c2ad59a69687054ba33abc5', 'sha256 project');
  FragmentHash := HashFragment(Fragment);
  Check(FragmentHash = 'babe07aaad1e1044963518b077f853b6016e6133c960bfd953058f7302d54e5a', 'sha256 canonical fragment');
  Check(HashFragment(Utf8Text) = 'ed95c68f09b2639a60011ca685de6bff3ac13ad7a8fef9a8161c108c6d214bab', 'sha256 utf8');
  Check(Locate(Fragment) = 30, 'locate fragment');

  Found := False;
  Index := BuildWindowIndex(Length(Fragment));
  for I := 0 to High(Index) do
    if (Index[I].Hash = FragmentHash) and (Index[I].Position = 30) then
      Found := True;
  Check(Found, 'build window index');

  Found := False;
  Positions := LocateByHash(UpperCase(FragmentHash), Length(Fragment));
  for I := 0 to High(Positions) do
    if Positions[I] = 30 then
      Found := True;
  Check(Found, 'locate by hash');

  Validation := Validate(Generate(250), 250);
  Check(Validation.IsValid, 'valid tape');

  Validation := Validate(Generate(40), 50);
  Check(not Validation.IsValid, 'truncated invalid');
  Check(Validation.HasTruncationPoint and (Validation.TruncationPoint = 41), 'truncation point');

  Mismatch := FindFirstMismatch(Generate(20), Generate(19) + 'X');
  Check(Mismatch.HasValue and (Mismatch.Position = 20), 'mismatch');

  WriteLn('OK delphi');
end.
