# PositionTape for Fortran

Status: Level 3 implementation.

This folder provides a Fortran module for generation, validation diagnostics,
direct locate, and SHA-256 hash-window lookup. The generator and validation
logic are dependency-free; hash-window APIs use the installed Perl
`Digest::SHA` module for SHA-256.

Run the local checks with:

```powershell
gfortran languages/fortran/src/position_tape.f90 languages/fortran/tests/position_tape_tests.f90 -o languages/fortran/tests/position_tape_tests.exe
.\languages\fortran\tests\position_tape_tests.exe
```
