# SPEC-COMPLIANCE - Delphi/Object Pascal

- Language: Delphi/Object Pascal
- Runtime/compiler: Free Pascal 3.2.2 is on PATH as an i386 Win32 compiler.
- Conformance level: Level 2
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `GenerateMarkerComplete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 index is included.
- Logger integration: not implemented.
- Verified locally: yes, 2026-06-27; `fpc -Fulanguages\delphi\src languages\delphi\tests\position_tape_tests.pas` compiled in about 0.4 seconds and `languages\delphi\tests\position_tape_tests.exe` passed in about 1.6 seconds.
- Known limitations: FPC defaults to short strings without `{$H+}`; that previously caused `Generate(10003)` to loop after the result reached 255 characters. Level 3 remains deferred until `Locate`, `BuildWindowIndex`, and exact SHA-256 `LocateByHash` can be implemented and tested.
- Fixture SHA-256 verified: not locally verified for Object Pascal because hash-window APIs are not implemented.
