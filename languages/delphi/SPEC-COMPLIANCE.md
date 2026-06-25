# SPEC-COMPLIANCE - Delphi/Object Pascal

- Language: Delphi/Object Pascal
- Runtime/compiler: Free Pascal or Delphi; `fpc` is not installed on PATH in the current Windows environment.
- Conformance level: Level 2
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `GenerateMarkerComplete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no dependency-free SHA-256 index included.
- Logger integration: not implemented.
- Known limitations: local `fpc` is missing, so Object Pascal tests were not executed in this environment.
- Fixture SHA-256 verified: not locally verified for Object Pascal because the compiler is missing.
