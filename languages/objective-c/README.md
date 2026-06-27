# PositionTape for Objective-C

Status: Level 2 source implementation; local Windows validation is blocked by
runtime/toolchain setup.

This folder provides a small Foundation-based Objective-C implementation of
the generator and validation diagnostics.

Level 3 is intentionally not claimed in the current alpha classification:
`Locate`, `BuildWindowIndex`, and `LocateByHash` are not implemented, and the
available Windows Clang toolchain is not a Foundation-capable Objective-C
runtime for local verification. GEN-PT-027 also tried a no-Foundation
Objective-C translation unit that called the shared C SHA-256 provider, but the
local Clang setup could not find standard C headers (`stdio.h`, `stdlib.h`) for
either the default target or `x86_64-w64-windows-gnu`.

Run the local checks with a Foundation-capable Objective-C toolchain. On macOS:

```bash
clang -fobjc-arc -framework Foundation languages/objective-c/src/PositionTape.m languages/objective-c/tests/PositionTapeTests.m -o languages/objective-c/tests/PositionTapeTests
languages/objective-c/tests/PositionTapeTests
```
