# PositionTape for Delphi/Object Pascal

Status: Level 3 implementation, verified locally with Free Pascal 3.2.2.

This folder provides a dependency-free Object Pascal unit for PositionTape
generation and validation diagnostics. It is intended for Free Pascal or
Delphi-compatible compilers.

Public unit operations:

- `Generate`
- `GenerateMarkerComplete`
- `FindFirstMismatch`
- `FindTruncationPoint`
- `Validate`
- `Locate`
- `HashFragment`
- `BuildWindowIndex`
- `LocateByHash`

The Level 3 hash APIs use a pure FPC-compatible SHA-256 implementation over
the byte contents of `string` values. UTF-8 text is supported when the caller
supplies UTF-8 bytes.

Run the local checks with Free Pascal:

```powershell
fpc -Fulanguages/delphi/src languages/delphi/tests/position_tape_tests.pas
.\languages\delphi\tests\position_tape_tests.exe
```
