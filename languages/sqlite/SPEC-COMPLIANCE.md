# SPEC-COMPLIANCE — sqlite

- Language: SQLite SQL
- Runtime/compiler: `sqlite3`; not installed on PATH in the current Windows environment.
- Conformance level: Level 2
- Generate: Implemented by the `position_tape_generate` TEMP view with `position_tape_params('length')`.
- GenerateMarkerComplete: Implemented by `position_tape_generate_marker_complete`.
- Validate: Implemented by `position_tape_validate` with mismatch and truncation columns.
- Locate: Implemented by `position_tape_locate` over the canonical 100,003-character search window.
- Hash index: Not implemented; plain SQLite does not provide SHA-256 in core SQL without optional extensions.
- Logger integration: Not implemented.
- Known limitations: The API is view/table based rather than callable scalar functions; not locally executed because `sqlite3` is not installed on PATH.
- Fixture SHA-256 verified: Not in this Level 2 implementation.
