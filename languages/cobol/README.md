# PositionTape for COBOL

Status: Level 1 implementation.

This folder provides a small GnuCOBOL-oriented generator program. It accepts a
requested length as the first command-line argument and writes the exact-length
tape to standard output with no trailing newline.

Level 3 is intentionally not attempted in this alpha classification. The
current COBOL code is an exact-length generator program. `cobc` is visible on
PATH locally. In native PowerShell, the MSYS2 UCRT64 build needs per-process
configuration variables so POSIX-style `/ucrt64/...` include/config paths
resolve to the installed Windows tree; no package installation is required.
There is no simple tested SHA-256/hash-window path for COBOL in this
repository.

Run the local checks with:

```powershell
$env:COB_CONFIG_DIR = "C:\msys64\ucrt64\share\gnucobol\config"
$env:CPATH = "C:\msys64\ucrt64\include"
$env:LIBRARY_PATH = "C:\msys64\ucrt64\lib"
cobc -free -x -o .tmp-cobol\position_tape_tests.exe languages/cobol/tests/position_tape_tests.cob
.\.tmp-cobol\position_tape_tests.exe
```

Generate a tape directly with:

```powershell
$env:COB_CONFIG_DIR = "C:\msys64\ucrt64\share\gnucobol\config"
$env:CPATH = "C:\msys64\ucrt64\include"
$env:LIBRARY_PATH = "C:\msys64\ucrt64\lib"
cobc -free -x -o .tmp-cobol\position_tape.exe languages/cobol/src/position_tape.cob
.\.tmp-cobol\position_tape.exe 100
```
