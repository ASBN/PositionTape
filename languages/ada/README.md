# PositionTape for Ada

Status: Level 2 implementation.

This folder provides a small dependency-free Ada implementation of the
PositionTape generator and validation diagnostics.

Public package operations:

- `Generate`
- `Generate_Marker_Complete`
- `Find_First_Mismatch`
- `Find_Truncation_Point`
- `Validate`

Level 3 is intentionally not claimed in the current alpha classification:
`Locate`, `BuildWindowIndex`, and `LocateByHash` are not implemented. A pure
Ada SHA-256 implementation plus hash-window index remains a separate verified
checkpoint.

Run the local checks with GNAT:

```powershell
gnatmake -Ilanguages/ada/src languages/ada/tests/position_tape_tests.adb
.\position_tape_tests.exe
```
