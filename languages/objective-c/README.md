# PositionTape for Objective-C

Status: Level 2 implementation.

This folder provides a small Foundation-based Objective-C implementation of
the generator and validation diagnostics.

Level 3 is intentionally not claimed in the current alpha classification:
`Locate`, `BuildWindowIndex`, and `LocateByHash` are not implemented, and the
available Windows Clang toolchain is not a Foundation-capable Objective-C
runtime for local verification.

Run the local checks with a Foundation-capable Objective-C toolchain:

```powershell
clang -fobjc-arc -framework Foundation languages/objective-c/src/PositionTape.m languages/objective-c/tests/PositionTapeTests.m -o languages/objective-c/tests/PositionTapeTests
.\languages\objective-c\tests\PositionTapeTests.exe
```
