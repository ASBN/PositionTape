# SPEC-COMPLIANCE — ocaml

- Language: OCaml
- Runtime/compiler: `ocaml` is not currently available on PATH; hash-window APIs use Perl `Digest::SHA`.
- Conformance level: Level 3 source implementation
- Generate: Implemented by `generate`.
- GenerateMarkerComplete: Implemented by `generate_marker_complete`.
- Validate: Implemented by `validate` with mismatch and truncation diagnostics.
- Locate: Implemented by `locate` over the canonical 100,003-character search window.
- Hash index: Implemented by `build_window_index` and `locate_by_hash`.
- Logger integration: Not implemented.
- Verified locally: not in this checkpoint; `ocaml` is not currently on PATH.
- Validation command: from repo root, `ocaml languages/ocaml/tests/position_tape_tests.ml`
- Known limitations: SHA-256 is delegated to installed Perl `Digest::SHA`; local OCaml execution is pending until `ocaml` is restored on PATH.
- Fixture SHA-256 verified: Not by the OCaml test harness in this checkpoint.
