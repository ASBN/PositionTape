# SPEC-COMPLIANCE — ocaml

- Language: OCaml
- Runtime/compiler: `ocaml`; not installed on PATH in the current Windows environment.
- Conformance level: Level 2
- Generate: Implemented by `generate`.
- GenerateMarkerComplete: Implemented by `generate_marker_complete`.
- Validate: Implemented by `validate` with mismatch and truncation diagnostics.
- Locate: Implemented by `locate` over the canonical 100,003-character search window.
- Hash index: Not implemented; OCaml standard library does not provide SHA-256 without an external package.
- Logger integration: Not implemented.
- Known limitations: Not locally executed because `ocaml` is not installed on PATH.
- Fixture SHA-256 verified: Not in this Level 2 implementation.
