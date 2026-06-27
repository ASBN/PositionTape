# SPEC-COMPLIANCE — sqlite

- Language: SQLite SQL
- Runtime/compiler: `sqlite3` 3.51.2, GNU Octave MinGW `gcc` 15.2.0, and `sqlite3ext.h` from GNU Octave 11.3.0.
- Conformance level: Level 3 verified
- Generate: Implemented by the `position_tape_generate` TEMP view with `position_tape_params('length')`.
- GenerateMarkerComplete: Implemented by `position_tape_generate_marker_complete`.
- Validate: Implemented by `position_tape_validate` with mismatch and truncation columns.
- Locate: Implemented by `position_tape_locate` over the canonical 100,003-character search window.
- HashFragment: Implemented by `position_tape_hash_fragment`, backed by the repo-local `sha256(text)` loadable extension.
- BuildWindowIndex: Implemented by `position_tape_build_window_index` over the canonical 100,003-character search window.
- LocateByHash: Implemented by `position_tape_locate_by_hash`; trims and lowercases the supplied 64-character hex digest.
- Logger integration: Not implemented.
- Verified locally: yes, 2026-06-27
- Extension build command: from repo root, `gcc -shared -O2 -Wall -Wextra -I "C:\Users\alfon\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\include" -o languages\sqlite\extensions\sha256\sha256_extension.dll languages\sqlite\extensions\sha256\sha256_extension.c`
- Extension load command: `.load ./languages/sqlite/extensions/sha256/sha256_extension.dll sqlite3_sha256_init`
- Validation command: from repo root after building the extension, `Get-Content languages/sqlite/tests/position_tape_tests.sql | sqlite3`
- Known limitations: The API is view/table based rather than callable scalar functions. The generated DLL is a local artifact and is not committed.
- Fixture SHA-256 verified: Shared vectors for empty string, `abc`, `PositionTape`, canonical fragment `3123456789412345`, and UTF-8 non-ASCII text are verified through SQLite `sha256(text)`.
