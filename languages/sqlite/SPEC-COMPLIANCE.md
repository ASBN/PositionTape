# SPEC-COMPLIANCE — sqlite

- Language: SQLite SQL
- Runtime/compiler: `sqlite3` 3.51.2 available on PATH in this checkpoint.
- Conformance level: Level 2
- Generate: Implemented by the `position_tape_generate` TEMP view with `position_tape_params('length')`.
- GenerateMarkerComplete: Implemented by `position_tape_generate_marker_complete`.
- Validate: Implemented by `position_tape_validate` with mismatch and truncation columns.
- Locate: Implemented by `position_tape_locate` over the canonical 100,003-character search window.
- Hash index: Not implemented; the verified SQLite 3.51.2 binary exposes `sha3()` but not exact `sha256()`.
- Logger integration: Not implemented.
- Verified locally: yes, 2026-06-27
- Validation command: from repo root, `Get-Content languages/sqlite/tests/position_tape_tests.sql | sqlite3`
- Known limitations: The API is view/table based rather than callable scalar functions. SQLite must not be marked Level 3 until exact SHA-256 is available and tested.
- Fixture SHA-256 verified: Not in this Level 2 implementation.
