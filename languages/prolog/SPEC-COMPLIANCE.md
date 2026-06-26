# SPEC-COMPLIANCE — prolog

- Language: Prolog
- Runtime/compiler: SWI-Prolog 10.0.2 with `library(crypto)` available on PATH in this checkpoint.
- Conformance level: Level 3
- Generate: Implemented by `generate/2`.
- GenerateMarkerComplete: Implemented by `generate_marker_complete/2`.
- Validate: Implemented by `validate/3` with mismatch and truncation diagnostics.
- Locate: Implemented by `locate/2` over the canonical 100,003-character search window.
- Hash index: Implemented by `build_window_index/2` and `locate_by_hash/3` using SHA-256 via `library(crypto)`.
- Logger integration: Not implemented.
- Verified locally: yes, 2026-06-26
- Validation command: from repo root, `swipl -q -s languages/prolog/tests/position_tape_tests.pl`
- Known limitations: none for Level 3 scope.
- Fixture SHA-256 verified: Not directly checked against fixture files; API generation, marker-complete boundaries, locate, and hash-window behavior were locally tested.
