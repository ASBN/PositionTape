# SPEC-COMPLIANCE - COBOL

- Language: COBOL
- Runtime/compiler: GnuCOBOL 3.2.0 is on PATH at `C:\msys64\ucrt64\bin\cobc.exe`.
- Conformance level: Level 1
- Generate: implemented by `languages/cobol/src/position_tape.cob` as a command-line exact-length generator.
- GenerateMarkerComplete: not implemented in this checkpoint.
- Validate: not implemented in this checkpoint.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 path is claimed.
- Logger integration: not implemented.
- Verified locally: yes, 2026-06-27; with per-process `COB_CONFIG_DIR=C:\msys64\ucrt64\share\gnucobol\config`, `CPATH=C:\msys64\ucrt64\include`, `LIBRARY_PATH=C:\msys64\ucrt64\lib`, and `cobc -free`, the test compiled in about 1.5 seconds and printed `OK cobol`.
- Known limitations: native PowerShell does not translate `/ucrt64/...` paths for the MSYS2 UCRT64 build by itself. Without the variables above, `cobc` reports `/ucrt64/share/gnucobol/config\default.conf: No such file or directory`; with only `COB_CONFIG_DIR`, it reaches C compilation and then cannot find `libcob.h`. Fixed output buffer supports lengths up to 10003 for fixture-oriented checks. Level 3 is deferred because full diagnostics plus exact SHA-256 hash-window support is not a short, locally testable change.
- Fixture SHA-256 verified: not locally verified for COBOL because hash-window APIs are not implemented.
