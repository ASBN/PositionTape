# SPEC-COMPLIANCE - COBOL

- Language: COBOL
- Runtime/compiler: GnuCOBOL; `cobc` is not installed on PATH in the current Windows environment.
- Conformance level: Level 1
- Generate: implemented by `languages/cobol/src/position_tape.cob` as a command-line exact-length generator.
- GenerateMarkerComplete: not implemented in this checkpoint.
- Validate: not implemented in this checkpoint.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 path is claimed.
- Logger integration: not implemented.
- Known limitations: fixed output buffer supports lengths up to 10003 for fixture-oriented checks; local `cobc` is missing, so tests were not executed in this environment. Level 3 is deferred because full diagnostics plus exact SHA-256 hash-window support is not a short, locally testable change.
- Fixture SHA-256 verified: not locally verified for COBOL because the compiler is missing.
