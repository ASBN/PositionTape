# SPEC-COMPLIANCE — c

- Language: C99
- Runtime/compiler: MSVC Build Tools via `vcvars64.bat` and `cl`
- Conformance level: 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with pure C SHA-256 fixed-size windows
- Logger integration: not implemented
- Verified locally: yes, 2026-06-25
- Validation command: `cmd /c "vcvars64.bat && cl /nologo /I languages\c\src languages\c\src\position_tape.c languages\c\tests\position_tape_tests.c /Fe:.\toolchain-c-position_tape_tests.exe && .\toolchain-c-position_tape_tests.exe"`
- Known limitations: none for the MSVC validation path
- Fixture SHA-256 verified: exact `Generate(10000)` SHA verified; marker-complete boundary lengths verified
