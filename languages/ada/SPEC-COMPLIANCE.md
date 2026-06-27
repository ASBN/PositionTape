# SPEC-COMPLIANCE - Ada

- Language: Ada
- Runtime/compiler: GNAT 16.1.0 available on PATH and verified locally.
- Conformance level: Level 3
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `Generate_Marker_Complete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: implemented as `Locate` over the default search horizon.
- Hash index: implemented as pure Ada SHA-256 `Hash_Fragment`, `Build_Window_Index`, and `Locate_By_Hash`.
- Logger integration: not implemented.
- Verified locally: Level 3 test command passed with `gnatmake -Ilanguages/ada/src languages/ada/tests/position_tape_tests.adb`; `.\position_tape_tests.exe`.
- Known limitations: No Level 4 logger integration is implemented.
- Fixture SHA-256 verified: shared vectors for empty string, `abc`, `PositionTape`, canonical fragment start 30 length 16, and UTF-8 non-ASCII text are covered by the Ada test runner.
