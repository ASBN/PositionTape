# PositionTape for Delphi/Object Pascal

Status: Level 2 implementation.

This folder provides a dependency-free Object Pascal unit for PositionTape
generation and validation diagnostics. It is intended for Free Pascal or
Delphi-compatible compilers.

Level 3 is intentionally not claimed in the current alpha classification:
`Locate`, `BuildWindowIndex`, and `LocateByHash` are not implemented.
Free Pascal 3.2.2 is visible locally and the Level 2 validation test passes.

Run the local checks with Free Pascal:

```powershell
fpc -Fulanguages/delphi/src languages/delphi/tests/position_tape_tests.pas
.\languages\delphi\tests\position_tape_tests.exe
```
