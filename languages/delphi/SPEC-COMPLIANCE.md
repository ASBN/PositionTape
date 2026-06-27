# SPEC-COMPLIANCE - Delphi/Object Pascal

- Language: Delphi/Object Pascal
- Runtime/compiler: Free Pascal 3.2.2 is on PATH as an i386 Win32 compiler.
- Conformance level: Level 3
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `GenerateMarkerComplete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: implemented as `Locate` over the default search horizon.
- Hash index: implemented as pure FPC-compatible SHA-256 `HashFragment`, `BuildWindowIndex`, and `LocateByHash`.
- Logger integration: not implemented.
- Verified locally: yes, 2026-06-27; `fpc -Fulanguages\delphi\src languages\delphi\tests\position_tape_tests.pas` compiled and `languages\delphi\tests\position_tape_tests.exe` passed.
- Known limitations: FPC defaults to short strings without `{$H+}`; the unit preserves `{$mode objfpc}` and `{$H+}`. No Level 4 logger integration is implemented.
- Fixture SHA-256 verified: shared vectors for empty string, `abc`, `PositionTape`, canonical fragment start 30 length 16, and UTF-8 non-ASCII text are covered by the Object Pascal test runner.
