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

Run the local checks with GNAT:

```powershell
gnatmake -D languages/ada/build -I languages/ada/src languages/ada/tests/position_tape_tests.adb
.\languages\ada\build\position_tape_tests.exe
```
