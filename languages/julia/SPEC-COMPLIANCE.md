# SPEC-COMPLIANCE — julia

- Language: Julia
- Runtime/compiler: Julia 1.12.6 locally during this checkpoint.
- Conformance level: 3
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with SHA-256 fixed-size windows using Julia stdlib `SHA`
- Logger integration: not implemented
- Known limitations: none for Level 3 scope.
- Fixture SHA-256 verified: covered by `languages/julia/tests/position_tape_tests.jl`
