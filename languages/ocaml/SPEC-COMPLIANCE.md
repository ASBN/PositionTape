# SPEC-COMPLIANCE — ocaml

- Language: OCaml
- Runtime/compiler: `ocaml` available on PATH; `opam env` is blocked by user-log permissions.
- Conformance level: Level 2
- Generate: Implemented by `generate`.
- GenerateMarkerComplete: Implemented by `generate_marker_complete`.
- Validate: Implemented by `validate` with mismatch and truncation diagnostics.
- Locate: Implemented by `locate` over the canonical 100,003-character search window.
- Hash index: Not implemented; OCaml standard library does not provide SHA-256 without an external package.
- Logger integration: Not implemented.
- Verified locally: yes, 2026-06-26
- Validation command: from repo root, `ocaml languages/ocaml/tests/position_tape_tests.ml`
- Known limitations: Hash-window APIs are not implemented for Level 2; direct interpreter validation passed from the repository root.
- Fixture SHA-256 verified: Not in this Level 2 implementation; generation and marker-complete boundary behavior were locally tested.
