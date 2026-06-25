# SPEC-COMPLIANCE — prolog

- Language: Prolog
- Runtime/compiler: SWI-Prolog with `library(crypto)`; not installed on PATH in the current Windows environment.
- Conformance level: Level 3
- Generate: Implemented by `generate/2`.
- GenerateMarkerComplete: Implemented by `generate_marker_complete/2`.
- Validate: Implemented by `validate/3` with mismatch and truncation diagnostics.
- Locate: Implemented by `locate/2` over the canonical 100,003-character search window.
- Hash index: Implemented by `build_window_index/2` and `locate_by_hash/3` using SHA-256 via `library(crypto)`.
- Logger integration: Not implemented.
- Known limitations: Not locally executed because `swipl` is not installed on PATH.
- Fixture SHA-256 verified: Covered by the test file when SWI-Prolog is available; not executed locally in this checkpoint.
