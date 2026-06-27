# SPEC-COMPLIANCE — ocaml

- Language: OCaml
- Runtime/compiler: validated with OCaml 5.4.1; hash-window APIs use Perl `Digest::SHA`.
- Conformance level: Level 3
- Generate: Implemented by `generate`.
- GenerateMarkerComplete: Implemented by `generate_marker_complete`.
- Validate: Implemented by `validate` with mismatch and truncation diagnostics.
- Locate: Implemented by `locate` over the canonical 100,003-character search window.
- Hash index: Implemented by `build_window_index` and `locate_by_hash`.
- Logger integration: Not implemented.
- Verified locally: `ocaml languages/ocaml/tests/position_tape_tests.ml`
- Validation command: from repo root, `ocaml languages/ocaml/tests/position_tape_tests.ml`
- Known limitations: SHA-256 is delegated to installed Perl `Digest::SHA`.
- Fixture SHA-256 verified: covered by `languages/ocaml/tests/position_tape_tests.ml`.
