# PositionTape for COBOL

Status: Level 1 implementation.

This folder provides a small GnuCOBOL-oriented generator program. It accepts a
requested length as the first command-line argument and writes the exact-length
tape to standard output with no trailing newline.

Level 3 is intentionally not attempted in this alpha classification. The
current COBOL code is an exact-length generator program, `cobc` is not on PATH
locally, and there is no simple tested SHA-256/hash-window path for COBOL in
this repository.

Run the local checks with:

```powershell
cobc -x -o languages/cobol/tests/position_tape_tests.exe languages/cobol/tests/position_tape_tests.cob
.\languages\cobol\tests\position_tape_tests.exe
```

Generate a tape directly with:

```powershell
cobc -x -o languages/cobol/position_tape.exe languages/cobol/src/position_tape.cob
.\languages\cobol\position_tape.exe 100
```
