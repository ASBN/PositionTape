# PositionTape for Fortran

Status: Level 2 implementation.

This folder provides a dependency-free Fortran module for generation and
validation diagnostics.

Run the local checks with:

```powershell
gfortran languages/fortran/src/position_tape.f90 languages/fortran/tests/position_tape_tests.f90 -o languages/fortran/tests/position_tape_tests.exe
.\languages\fortran\tests\position_tape_tests.exe
```
