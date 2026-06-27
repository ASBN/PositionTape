# PositionTape for Ada

Status: Level 3 implementation, verified locally with GNAT.

This folder provides a small dependency-free Ada implementation of the
PositionTape generator and validation diagnostics.

Public package operations:

- `Generate`
- `Generate_Marker_Complete`
- `Find_First_Mismatch`
- `Find_Truncation_Point`
- `Validate`
- `Locate`
- `Hash_Fragment`
- `Build_Window_Index`
- `Locate_By_Hash`

The Level 3 hash APIs use a pure Ada SHA-256 implementation over the byte
contents of `String` values. UTF-8 text is supported when the caller supplies
UTF-8 bytes.

Run the local checks with GNAT:

```powershell
gnatmake -Ilanguages/ada/src languages/ada/tests/position_tape_tests.adb
.\position_tape_tests.exe
```
