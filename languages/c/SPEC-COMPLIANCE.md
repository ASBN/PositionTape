# SPEC-COMPLIANCE — c

- Language: C99
- Runtime/compiler: not available in this local environment
- Conformance level: 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with pure C SHA-256 fixed-size windows
- Logger integration: not implemented
- Known limitations: local C compiler is missing, so C tests were not executed in this environment
- Fixture SHA-256 verified: covered by `languages/c/tests/position_tape_tests.c`, not locally executed
