# PositionTape for COBOL

Status: Level 1 implementation with a verified hybrid SHA-256 binding probe.

This folder provides a small GnuCOBOL-oriented generator program. It accepts a
requested length as the first command-line argument and writes the exact-length
tape to standard output with no trailing newline.

Level 3 is not claimed in this alpha classification. The current COBOL code is
an exact-length generator program, and the folder does not yet expose the full
Level 3 public API surface (`Locate`, `BuildWindowIndex`, and `LocateByHash`).

GEN-PT-027 proved that GnuCOBOL can call a repo-owned C SHA-256 provider. The
hybrid test hashes the empty string, `abc`, `PositionTape`, and the canonical
fragment `3123456789412345` through `position_tape_sha256_hex_cobol`. This is
binding evidence only; it is not a full COBOL hash-window implementation.

Run the local checks with:

```powershell
$env:COB_CONFIG_DIR = "C:\msys64\ucrt64\share\gnucobol\config"
$env:CPATH = "C:\msys64\ucrt64\include"
$env:LIBRARY_PATH = "C:\msys64\ucrt64\lib"
cobc -free -x -o .tmp-cobol\position_tape_tests.exe languages/cobol/tests/position_tape_tests.cob
.\.tmp-cobol\position_tape_tests.exe
```

Run the hybrid SHA-256 binding probe with:

```powershell
$env:COB_CONFIG_DIR = "C:\msys64\ucrt64\share\gnucobol\config"
$env:CPATH = "C:\msys64\ucrt64\include"
$env:LIBRARY_PATH = "C:\msys64\ucrt64\lib"
cobc -free -x -I tools/native/sha256 -o .tmp-cobol\cobol_sha256_hybrid.exe languages/cobol/tests/sha256_hybrid_tests.cob tools/native/sha256/position_tape_sha256.c
.\.tmp-cobol\cobol_sha256_hybrid.exe
```

Generate a tape directly with:

```powershell
$env:COB_CONFIG_DIR = "C:\msys64\ucrt64\share\gnucobol\config"
$env:CPATH = "C:\msys64\ucrt64\include"
$env:LIBRARY_PATH = "C:\msys64\ucrt64\lib"
cobc -free -x -o .tmp-cobol\position_tape.exe languages/cobol/src/position_tape.cob
.\.tmp-cobol\position_tape.exe 100
```
