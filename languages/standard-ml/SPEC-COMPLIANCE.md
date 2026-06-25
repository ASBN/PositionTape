# SPEC-COMPLIANCE — standard-ml

- Language: Standard ML
- Runtime/compiler: SML/NJ 110.99.9 locally during this checkpoint.
- Conformance level: 3
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with pure SML SHA-256 fixed-size windows
- Logger integration: not implemented
- Known limitations: `buildWindowIndex` returns an association list and is intended for conformance/debug use rather than high-volume production lookup.
- Fixture SHA-256 verified: covered by `languages/standard-ml/tests/position_tape_tests.sml`
