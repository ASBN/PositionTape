# SPEC-COMPLIANCE - COBOL

- Language: COBOL
- Runtime/compiler: GnuCOBOL 3.2.0 is on PATH at `C:\msys64\ucrt64\bin\cobc.exe`.
- Conformance level: Level 1, plus verified hybrid SHA-256 binding probe
- Generate: implemented by `languages/cobol/src/position_tape.cob` as a command-line exact-length generator.
- GenerateMarkerComplete: not implemented in this checkpoint.
- Validate: not implemented in this checkpoint.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no Level 3 hash-window path is claimed.
- Hybrid SHA-256: `languages/cobol/tests/sha256_hybrid_tests.cob` calls the repo-owned C provider in `tools/native/sha256/position_tape_sha256.c` through `position_tape_sha256_hex_cobol`.
- Logger integration: not implemented.
- Verified locally: yes, 2026-06-27; with per-process `COB_CONFIG_DIR=C:\msys64\ucrt64\share\gnucobol\config`, `CPATH=C:\msys64\ucrt64\include`, `LIBRARY_PATH=C:\msys64\ucrt64\lib`, and `cobc -free`, the Level 1 test printed `OK cobol` and the hybrid SHA-256 test printed `OK cobol sha256 hybrid`.
- Known limitations: native PowerShell does not translate `/ucrt64/...` paths for the MSYS2 UCRT64 build by itself. Without the variables above, `cobc` reports `/ucrt64/share/gnucobol/config\default.conf: No such file or directory`; with only `COB_CONFIG_DIR`, it reaches C compilation and then cannot find `libcob.h`. Fixed output buffer supports lengths up to 10003 for fixture-oriented checks. Level 3 is deferred because the COBOL implementation still lacks full diagnostics, direct locate, and hash-window APIs.
- Fixture SHA-256 verified: empty string, `abc`, `PositionTape`, and canonical fragment verified through the hybrid binding; UTF-8 non-ASCII and hash-window locate are not claimed for COBOL.
